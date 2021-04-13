#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# build.sh
#
# The main script that runs the build
#


#TODO:
#    - Make build.sh accept arguments.
#    - Optionally use /tmp folder for work dir
#    - Optionally use UEFI bot in run_archiso QEMU

# Internal config
base_path="$( cd "$( dirname "$0" )" && pwd )"
work_dir="/tmp/archiso-tmp"
#"${base_path}/work"
out_dir="${base_path}/out"
date_today="$( date +'%Y.%m.%d' )"

# mkarchiso -v -w /path/to/work_dir -o /path/to/out_dir /path/to/profile/
# find . -type f -print0 | xargs -0 dos2unix
# chmod -R 755 work/
# ln -sfn /usr/lib/systemd/system/sddm.service display-manager.service

_config_iso() {
    echo "[makeiso] Checking dependencies..."
    if [ ! -f "/usr/bin/mkarchiso" ]; then
        echo "[makeiso] ERROR: package 'archiso' not found."
        exit 1
    fi
}

_build_iso() {
    # Check if work_dir exists and delete then
    # Necessary for rebuild the iso with base configurations if have any changes.
    # See https://wiki.archlinux.org/index.php/Archiso#Removal_of_work_directory
    if [ -d "${work_dir}" ]; then
        echo "[makeiso] Deleting work folder..."
        echo "[makeiso] Succesfully deleted $(rm -rfv "${work_dir}" | wc -l) files"
    fi
    exec mkarchiso -v -w "${work_dir}" -o "${out_dir}" "${base_path}/base"
}

_run_iso() {
    run_archiso -u -i "${base_path}/out/luminos-main-${date_today}-x86_64.iso"
}

_config_iso
_build_iso
_run_iso

exit 0