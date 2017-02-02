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

_do_restore() {
    local restore_source=$1
    local restore_target=$2
    local restore_keyid=$3
    log_debug "Restore source: ${restore_source}"
    log_debug "Restore target: ${restore_target}"
    log_debug "Restore key: ${restore_keyid}"
    local opts="--encrypt-key ${restore_keyid} --use-agent"
    [[ -n ${BACKUP_RESTORE_DEBUG} ]] && opts="--verbosity info ${opts}"
    duplicity ${opts} ${restore_source} ${restore_target}
}

do_restore_home_with_file() {
    local restore_dir=$1
    local restore_keyid=$2
    [[ -d ${restore_dir} ]] || error "${restore_dir} does not exist"
    _do_restore "file://${restore_dir}" "${HOME}" "${restore_keyid}"
}

do_restore_test_with_file() {
    local restore_dir=$1
    local restore_keyid=$2
    [[ -d ${restore_dir} ]] || error "${restore_dir} does not exist"
    rm -rf /tmp/restore-test.* # remove any previous restore test dir
    local temp_dir=$(mktemp -d -p /tmp restore-test.XXXXXXXXXX)
    log_info "Restore test target directory: ${temp_dir}"
    _do_restore "file://${restore_dir}" "${temp_dir}" "${restore_keyid}"
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
