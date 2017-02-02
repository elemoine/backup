#!/bin/bash

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
    -d <dir>      the backup target directory
    -k <key>      the GPG key
    -x            increase verbosity

Example:
    ${PROGNAME} -d /media/usb/backup -k E588ECCD
EOF
    exit $exitcode
}

main() {

    while getopts ":d:h:k:x" opt
    do
        case "${opt}" in
            d)
                readonly BACKUP_DIR=${OPTARG}
                ;;
            h)
                usage 0
                ;;
            k)
                readonly BACKUP_KEYID=${OPTARG}
                ;;
            x)
                declare -g -r BACKUP_RESTORE_DEBUG=1
                ;;
            \?)
                usage 1
                ;;
        esac
    done

    [[ -n ${BACKUP_DIR} ]] || usage 1
    [[ -n ${BACKUP_KEYID} ]] || usage 1

    do_backup_home_with_file ${BACKUP_DIR} ${BACKUP_KEYID}
}

main ${ARGS}
