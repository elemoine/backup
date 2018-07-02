#!/bin/bash

set -e

. "functions.sh"

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"
readonly USERID=$(id --user --name)

usage() {
    local exitcode=$1
    cat <<- EOF
Usage: ${PROGNAME} options

OPTIONS:
    -d <dir>      the backup repository
    -h            help
    -v            increase verbosity

Example:
    ./${PROGNAME} -d /media/usb/backup -v
EOF
    exit $exitcode
}

do_backup_home() {
    local repository=$1
    log_debug "Backup repository: ${repository}"
    local globalflags="-r ${repository}"
    [[ -n ${BACKUP_RESTORE_DEBUG} ]] && globflags="${globalflags} -v"
    local flags="--exclude-file excludes.txt"
    restic ${globalflags} backup ${flags} ${HOME}
    restic ${globalflags} check
    restic ${globalflags} snapshots
    log_info "Command run: restic ${globalflags} backup ${flags} ${HOME}"
}

main() {

    while getopts ":d:hv" opt
    do
        case "${opt}" in
            d)
                readonly BACKUP_DIR=${OPTARG}
                ;;
            h)
                usage 0
                ;;
            v)
                declare -g -r BACKUP_RESTORE_DEBUG=1
                ;;
            \?)
                usage 1
                ;;
        esac
    done

    [[ -n ${BACKUP_DIR} ]] || usage 1

    do_backup_home ${BACKUP_DIR}
}

main ${ARGS}
