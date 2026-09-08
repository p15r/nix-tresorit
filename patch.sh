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

tresorit_fhs_changed="false"
if [ -f "${HOME}/.local/share/applications/tresorit.desktop" ]; then
    printf "Patch Tresorit application config...\n"
    mv "${HOME}/.local/share/applications/tresorit.desktop" \
       "${HOME}/.local/share/applications/tresorit.desktop.bk"
    sed -i 's/^/# /' "${HOME}/.local/share/applications/tresorit.desktop.bk"
    cp "${HOME}/.local/share/applications/tresorit.desktop.bk" \
       "${HOME}/.local/share/applications/tresorit-fhs.desktop"
    sed -i 's/^# //' "${HOME}/.local/share/applications/tresorit-fhs.desktop"
    sed -i \
        "s|^Name=Tresorit$|Name=Tresorit FHS|" \
        "${HOME}/.local/share/applications/tresorit-fhs.desktop"
    sed -i \
        "s|^Exec=.*$|Exec=${HOME}/.local/share/tresorit/tresorit_fhs_launcher.sh|" \
        "${HOME}/.local/share/applications/tresorit-fhs.desktop"
    tresorit_fhs_changed="true"
fi

if ! [ -d "${HOME}/.config/autostart" ]; then
    printf "Create ~/.config/autostart...\n"
    mkdir "${HOME}/.config/autostart"
fi

if [ -f "${HOME}"/.config/autostart/tresorit.desktop ]; then
    printf "Disable Tresorit's broken startup config...\n"
    mv "${HOME}/.config/autostart/tresorit.desktop" \
       "${HOME}/.config/autostart/tresorit.desktop.bk"
    sed -i 's/^/# /' "${HOME}/.config/autostart/tresorit.desktop.bk"
fi

if [ -f "${HOME}/.config/autostart/tresorit-fhs.desktop" ] && ! grep -Fq -- "--hidden" "${HOME}/.config/autostart/tresorit-fhs.desktop" > /dev/null 2>&1; then
    printf "Found old installation (<2026-09-08), updating Tresorit FHS autostart config.\n"
    tresorit_fhs_changed="true"
fi

if ! [ -f "${HOME}/.config/autostart/tresorit-fhs.desktop" ] || [ ${tresorit_fhs_changed} == "true" ]; then
    printf "Register Tresorit FHS autostart config...\n"
    cp "${HOME}/.local/share/applications/tresorit-fhs.desktop" \
       "${HOME}/.config/autostart/tresorit-fhs.desktop"
    sed -E -i \
        "s|^Exec=(.*)$|Exec=\1 --hidden|" \
        "${HOME}/.config/autostart/tresorit-fhs.desktop"
fi
