#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# build.sh
#
# The main script that runs the build
#

# Internal config
base_path="$( cd "$( dirname "$0" )" && pwd )"
work_dir="${base_path}/work"
out_dir="${base_path}/out"
date_today="$( date +'%Y.%m.%d' )"
qemu_running=false

# mkarchiso -v -w /path/to/work_dir -o /path/to/out_dir /path/to/profile/
# find . -type f -print0 | xargs -0 dos2unix
# chmod -R 755 work/
# ln -sfn /usr/lib/systemd/system/sddm.service display-manager.service

_usage() {
    IFS='' read -r -d '' usagetext <<ENDUSAGETEXT || true
usage: build.sh [options]
  options:
     -h               This message
     -T               Use /tmp folder to work directory
     -r               Run latest builded iso

  profile_dir:        Directory of the archiso profile to build
ENDUSAGETEXT
    printf '%s' "${usagetext}"
    exit "${1}"
}

_config_iso() {
    echo "[makeiso] Checking dependencies..."
    if [[ ! -f "/usr/bin/mkarchiso" ]]; then
        echo "[makeiso] ERROR: package 'archiso' not found."
        exit 1
    fi
    if [[ -v override_work_dir ]]; then
        work_dir="$override_work_dir"
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
    qemu_running=true
    run_archiso -u -i "${out_dir}/luminos-main-${date_today}-x86_64.iso"
}

while getopts 'rTh?' arg; do
    case "${arg}" in
        T) override_work_dir="/tmp/archiso-tmp" ;;
        r) _run_iso ;;
        h|?) _usage 0 ;;
        *)
            echo "[makeiso] Invalid argument '${arg}'" 0
            _usage 1
            ;;
    esac
done

if [ "$qemu_running" = false ] ; then
    _config_iso
    _build_iso
fi

exit 0