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
    -d <dir>      the backup repository
    -t            restore in a temp dir instead of ${HOME}
    -h            help
    -v            increase verbosity

Example:
    ./${PROGNAME} -d /media/usb/backup -t -v
EOF
    exit $exitcode
}

_do_restore() {
    local restore_source=$1
    local restore_target=$2
    log_debug "Restore source: ${restore_source}"
    log_debug "Restore target: ${restore_target}"
    local globalflags="-r ${restore_source}"
    [[ -n ${BACKUP_RESTORE_DEBUG} ]] && globflags="${globalflags} -v"
    restic ${globalflags} restore latest --target ${restore_target}
    log_info "Command run: restic ${globalflags} restore latest --target ${restore_target}"
}

do_restore_home() {
    local restore_dir=$1
    [[ -d ${restore_dir} ]] || error "${restore_dir} does not exist"
    _do_restore "${restore_dir}" "${HOME}"
}

do_restore_test() {
    local restore_dir=$1
    [[ -d ${restore_dir} ]] || error "${restore_dir} does not exist"
    rm -rf /tmp/restore-test.* # remove any previous restore test dir
    local temp_dir=$(mktemp -d -p /tmp restore-test.XXXXXXXXXX)
    log_info "Restore test target directory: ${temp_dir}"
    _do_restore "${restore_dir}" "${temp_dir}"
}

main() {

    while getopts ":d:thv" opt
    do
        case "${opt}" in
            d)
                readonly RESTORE_DIR=${OPTARG}
                ;;
            t)
                readonly RESTORE_TEST=1
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

    [[ -n ${RESTORE_DIR} ]] || usage 1

    if [[ -n ${RESTORE_TEST} ]];
    then
        do_restore_test ${RESTORE_DIR}
    else
        do_restore_home ${RESTORE_DIR}
    fi
}

main ${ARGS}
