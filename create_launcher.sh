#!/usr/bin/env bash

set -euo pipefail

err_report() {
    echo "Error on line $(caller)" >&2
    awk 'NR>L-4 && NR<L+4 { printf "%-5d%3s%s\n",NR,(NR==L?">>>":""),$0 }' L=$1 $0
}
trap 'err_report $LINENO' ERR

die() {
    printf "\n⚠️ ${1}\n\nExiting.\n"
    exit 1
}

self_path="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"
out_path="${self_path}/result/bin/tresorit-fhs"
if ! [ -h "${out_path}" ]; then
    die "The output of \"nix build\" could not be found at \"${out_path}\"."
fi

launcher_script=""
if [ -f "${HOME}/.local/share/tresorit/tresorit_launcher.sh" ]; then
    launcher_script="${HOME}/.local/share/tresorit/tresorit_launcher.sh"
fi
if [ -f "${HOME}/.local/share/tresorit/tresorit_fhs_launcher.sh" ]; then
    launcher_script="${HOME}/.local/share/tresorit/tresorit_fhs_launcher.sh"
fi
if [ "${launcher_script}" != "" ]; then
    launch_cmd=$(grep "tresorit --hidden" "${launcher_script}")
    launch_cmd=${launch_cmd%" &"}
    stop_cmd=$(echo $launch_cmd | sed 's/tresorit \-\-hidden/tresorit-cli stop/')
    printf "Stopping Tresorit FHS...\n"
    # fails if fhs env is corrupted, continue anyway to link to newly built fhs env
    eval "${stop_cmd}" || true
fi

if [ -f "${HOME}/.local/share/tresorit/tresorit_launcher.sh" ]; then
    printf "Found old installation (<=2025-09-14), cleaning it up.\n"
    rm "${HOME}/.local/share/tresorit/tresorit_launcher.sh" # succeeded by "tresorit_fhs_launcher.sh"
    cp ${HOME}/.local/share/applications/tresorit.desktop.bk \
       ${HOME}/.local/share/applications/tresorit.desktop # restore original file, thus triggering patching script
fi

# NixOS 26.06 switches the buildFHSEnv backend from buildFHSEnvChroot to
# bubblewrap, which refuses execution if the user is not root, the setuid bit is
# not set, and Kernel capabilities are present.
# Source: https://github.com/containers/bubblewrap/blob/2f55bae38468d0c50cf5df87b1e481e882b63acb/bubblewrap.c#L797
# This is the case, for example, when using the Ghostty terminal which
# runs its shells with CAP_SYS_NICE.

printf "Creating Tresorit launcher...\n"
tresorit_fhs_shell=$(readlink -f "${out_path}")
cat > "tresorit_fhs_launcher.sh" <<EOF
#!/usr/bin/env bash
${HOME}/.local/share/tresorit/patch.sh
printf "Starting Tresorit within FHS environment...\n"
printf "ℹ️ Dropping all Linux capabilities for bubblewrap.\n"
setpriv --no-new-privs --inh-caps=-all --ambient-caps=-all -- \
    ${tresorit_fhs_shell} -c "${HOME}/.local/share/tresorit/tresorit --hidden" > ${HOME}/.local/share/tresorit/fhs.log 2>&1 &
printf "Done.\n"
EOF
chmod +x "tresorit_fhs_launcher.sh"
mv "tresorit_fhs_launcher.sh" "${HOME}/.local/share/tresorit/tresorit_fhs_launcher.sh"

printf "Copying & running Tresorit application & autostart patching script...\n"
cp ./patch.sh ${HOME}/.local/share/tresorit/patch.sh
${HOME}/.local/share/tresorit/patch.sh

printf "Launching Tresorit FHS daemon...\n"
"${HOME}/.local/share/tresorit/tresorit_fhs_launcher.sh"

printf "Done 🚀\n"
