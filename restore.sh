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
    -s <dir>      the source directory
    -k <key>      the GPG key
    -t            restore in a temp dir instead of ${HOME}
    -x            increase verbosity

Example:
    ${PROGNAME} -s /media/usb/backup -k E588ECCD -t
EOF
    exit $exitcode
}

main() {

    while getopts ":s:h:k:xt" opt
    do
        case "${opt}" in
            s)
                readonly RESTORE_DIR=${OPTARG}
                ;;
            h)
                usage 0
                ;;
            k)
                readonly RESTORE_KEYID=${OPTARG}
                ;;
            x)
                declare -g -r BACKUP_RESTORE_DEBUG=1
                ;;
            t)
                readonly RESTORE_TEST=1
                ;;
            \?)
                usage 1
                ;;
        esac
    done

    [[ -n ${RESTORE_DIR} ]] || usage 1
    [[ -n ${RESTORE_KEYID} ]] || usage 1

    if [[ -n ${RESTORE_TEST} ]];
    then
        do_restore_test_with_file ${RESTORE_DIR} ${RESTORE_KEYID}
    else
        do_restore_home_with_file ${RESTORE_DIR} ${RESTORE_KEYID}
    fi
}

main ${ARGS}
