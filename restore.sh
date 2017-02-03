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
    -d <dir>      the source directory
    -s <key>      the GPG sign key
    -e <key>      the GPG encrypt key
    -t            restore in a temp dir instead of ${HOME}
    -h            help
    -v            increase verbosity

Example:
    ${PROGNAME} -d /media/usb/backup -s 5BBF59DF126FADEF -e 57F334375840CA38 -t -v
EOF
    exit $exitcode
}

_do_restore() {
    local restore_source=$1
    local restore_target=$2
    local restore_sign_key=$3
    local restore_encrypt_key=$4
    log_debug "Restore source: ${restore_source}"
    log_debug "Restore target: ${restore_target}"
    log_debug "Restore sign key: ${restore_sign_key}"
    log_debug "Restore encrypt key: ${restore_encrypt_key}"
    local opts="--sign-key ${restore_sign_key} --encrypt-key ${restore_encrypt_key} --use-agent"
    [[ -n ${BACKUP_RESTORE_DEBUG} ]] && opts="--verbosity info ${opts}"
    duplicity ${opts} ${restore_source} ${restore_target}
}

do_restore_home_with_file() {
    local restore_dir=$1
    local restore_sign_key=$2
    local restore_encrypt_key=$3
    [[ -d ${restore_dir} ]] || error "${restore_dir} does not exist"
    _do_restore "file://${restore_dir}" "${HOME}" "${restore_sign_key}" "${restore_encrypt_key}"
}

do_restore_test_with_file() {
    local restore_dir=$1
    local restore_sign_key=$2
    local restore_encrypt_key=$3
    [[ -d ${restore_dir} ]] || error "${restore_dir} does not exist"
    rm -rf /tmp/restore-test.* # remove any previous restore test dir
    local temp_dir=$(mktemp -d -p /tmp restore-test.XXXXXXXXXX)
    log_info "Restore test target directory: ${temp_dir}"
    _do_restore "file://${restore_dir}" "${temp_dir}" "${restore_sign_key}" "${restore_encrypt_key}"
}

main() {

    while getopts ":d:s:e:thv" opt
    do
        case "${opt}" in
            d)
                readonly RESTORE_DIR=${OPTARG}
                ;;
            s)
                readonly RESTORE_SIGN_KEY=${OPTARG}
                ;;
            e)
                readonly RESTORE_ENCRYPT_KEY=${OPTARG}
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
    [[ -n ${RESTORE_SIGN_KEY} ]] || usage 1
    [[ -n ${RESTORE_ENCRYPT_KEY} ]] || usage 1

    if [[ -n ${RESTORE_TEST} ]];
    then
        do_restore_test_with_file ${RESTORE_DIR} ${RESTORE_SIGN_KEY} ${RESTORE_ENCRYPT_KEY}
    else
        do_restore_home_with_file ${RESTORE_DIR} ${RESTORE_SIGN_KEY} ${RESTORE_ENCRYPT_KEY}
    fi
}

main ${ARGS}
