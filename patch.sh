#!/usr/bin/env bash

set -euo pipefail

err_report() {
    echo "Error on line $(caller)" >&2
    awk 'NR>L-4 && NR<L+4 { printf "%-5d%3s%s\n",NR,(NR==L?">>>":""),$0 }' L=$1 $0
}
trap 'err_report $LINENO' ERR

err_exit() {
    printf "\n⚠️ ${1}\n\nExiting.\n"
    exit 1
}

out_relpath="result/bin/tresorit-fhs"
tresorit_launcher_file="tresorit_launcher.sh"
tresorit_relpath=".local/share/tresorit"
de_autostart_relpath=".config/autostart"
de_app_registry_relpath=".local/share/applications"
tresorit_desktop="tresorit.desktop"
tresorit_fhs_desktop="tresorit-fhs.desktop"
tresorit_autostart_relpath="${de_autostart_relpath}/${tresorit_desktop}"
self_path="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"
out_path="${self_path}/${out_relpath}"

if ! [ -h "${out_path}" ]; then
    err_exit "The output of \"nix build\" could not be found at \"${out_relpath}\"."
fi

printf "Creating Tresorit launcher...\n"
tresorit_fhs_shell=$(readlink -f "${out_path}")
cat > "${tresorit_launcher_file}" <<EOF
printf "Starting Tresorit within FHS environment...\n"
${tresorit_fhs_shell} -c "${HOME}/${tresorit_relpath}/tresorit --hidden" &
printf "Done.\n"
EOF
chmod +x "${tresorit_launcher_file}"
mv "${tresorit_launcher_file}" "${HOME}/${tresorit_relpath}/"

if ! [ -d "${HOME}/${de_autostart_relpath}" ]; then
    mkdir "${HOME}/${de_autostart_relpath}"
fi
if [ -f "${HOME}"/${tresorit_autostart_relpath} ]; then
    printf "Removing Tresorit's broken startup config...\n"
    mv "${HOME}/${tresorit_autostart_relpath}" \
       "${HOME}/${tresorit_autostart_relpath}.bk"
else
    cp "${HOME}/${de_app_registry_relpath}/${tresorit_desktop}" \
       "${HOME}/${tresorit_autostart_relpath}.bk"
fi

printf "Patching Tresorit startup config...\n"
if ! [ -f "${HOME}/${tresorit_autostart_relpath}.bk" ]; then
    err_exit "Expected to find \"${tresorit_desktop}.bk\", but it is not present."
fi
cp "${HOME}/${tresorit_autostart_relpath}.bk" \
   "${HOME}/${de_autostart_relpath}/${tresorit_fhs_desktop}"
sed -i \
    "s|^Name=Tresorit$|Name=Tresorit FHS|" \
    "${HOME}/${de_autostart_relpath}/${tresorit_fhs_desktop}"
sed -i \
    "s|^Exec=.*$|Exec=${HOME}/${tresorit_relpath}/${tresorit_launcher_file}|" \
    "${HOME}/${de_autostart_relpath}/${tresorit_fhs_desktop}"

printf "Patching Tresorit application config...\n"
if [ -f "${HOME}/${de_app_registry_relpath}/${tresorit_desktop}" ]; then
    mv "${HOME}/${de_app_registry_relpath}/${tresorit_desktop}" \
       "${HOME}/${de_app_registry_relpath}/${tresorit_desktop}.bk"
fi
cp "${HOME}/${de_app_registry_relpath}/${tresorit_desktop}.bk" \
   "${HOME}/${de_app_registry_relpath}/${tresorit_fhs_desktop}"
sed -i \
    "s|^Name=Tresorit$|Name=Tresorit FHS|" \
    "${HOME}/${de_app_registry_relpath}/${tresorit_fhs_desktop}"
sed -i \
    "s|^Exec=.*$|Exec=${HOME}/${tresorit_relpath}/${tresorit_launcher_file}|" \
    "${HOME}/${de_app_registry_relpath}/${tresorit_fhs_desktop}"

printf "Done.\n"
