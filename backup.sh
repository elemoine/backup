#!/bin/bash

usage() {
    echo "Usage: $0 [-l <dev>] [-r]"
    exit 1
}

error() {
    local errmsg="$1"
    echo "Error: ${errmsg}"
    exit 1
}

log_info() {
    local msg="$1"
    echo "${msg}"
}

while getopts ":l:r" opt; do
    case "${opt}" in
        l)
            dev=${OPTARG}
            ;;
        r)
            usage
            ;;
        \?)
            usage
            ;;
    esac
done

main() {
    [[ -n ${dev} ]] || error "no device defined"

    local mountpoint=$(findmnt -n -f -o target ${dev})
    [[ -n ${mountpoint} ]] || error "${DEV} is not mounted"
    log_info "Mount point: $mountpoint"

    local backupdir=${mountpoint}/backup
    [[ -d ${backupdir} ]] || error "${backupdir} does not exist"
    log_info "Backup directory: ${backupdir}"

    duplicity --exclude-filelist excludes.txt ${HOME} file://${backupdir}
}

main
