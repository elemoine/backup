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
            lbackup="yes"
            lbackupdev=${OPTARG}
            ;;
        r)
            rbackup="yes"
            ;;
        \?)
            usage
            ;;
    esac
done

main() {

    if [[ ${lbackup} == "yes" ]]; then
        #
        # local backup
        #
        local mountpoint=$(findmnt -n -f -o target ${lbackupdev})
        [[ -n ${mountpoint} ]] || error "${lbackupdev} is not mounted"
        log_info "Mount point: ${mountpoint}"

        local backupdir=${mountpoint}/backup
        [[ -d ${backupdir} ]] || error "${backupdir} does not exist"
        log_info "Local backup directory: ${backupdir}"

        duplicity --use-agent --verbosity info --exclude-filelist excludes.txt ${HOME} file://${backupdir}
    fi

    if [[ ${rbackup} == "yes" ]]; then
        #
        # remote backup
        #
        local username=$(id --user --name)
        local backupdir="/share/MD0_DATA/homes/admin/backups/workstations/${username}"
        log_info "Remote backup directory: ${backupdir}"

        duplicity --use-agent --verbosity info --exclude-filelist excludes.txt ${HOME} scp://backup/${backupdir}
    fi
}

main
