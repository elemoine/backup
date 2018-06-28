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
    -n            dry-run

Example:
    ./${PROGNAME} -d /media/usb/backup -s 5BBF59DF126FADEF -e 57F334375840CA38 -t -v
EOF
    exit $exitcode
}

_do_restore() {
    local restore_source=$1
    local restore_target=$2
    local restore_sign_key=$3
    local restore_encrypt_key=$4
    local restore_dryrun=$5
    log_debug "Restore source: ${restore_source}"
    log_debug "Restore target: ${restore_target}"
    [[ ${restore_sign_key} != "none" ]] && log_debug "Restore sign key: ${restore_sign_key}"
    [[ ${restore_encrypt_key} != "none" ]] && log_debug "Restore encrypt key: ${restore_encrypt_key}"
    local opts=""
    [[ ${restore_sign_key} != "none" ]] && opts="${opts} --sign-key ${restore_sign_key}"
    [[ ${restore_encrypt_key} != "none" ]] && opts="${opts} --encrypt-key ${restore_encrypt_key}"
    [[ ${restore_sign_key} != "none" || ${restore_encrypt_key} != "none" ]] && opts="${opts} --use-agent"
    [[ -n ${BACKUP_RESTORE_DEBUG} ]] && opts="--verbosity info ${opts}"
    [[ -n ${restore_dryrun} ]] && opts="--dry-run ${opts}"
    duplicity ${opts} ${restore_source} ${restore_target}
    log_info "Command run: duplicity ${opts} ${restore_source} ${restore_target}"
}

do_restore_home_with_file() {
    local restore_dir=$1
    local restore_sign_key=$2
    local restore_encrypt_key=$3
    local restore_dryrun=$4
    [[ -d ${restore_dir} ]] || error "${restore_dir} does not exist"
    _do_restore "file://${restore_dir}" "${HOME}" "${restore_sign_key}" "${restore_encrypt_key}" "${restore_dryrun}"
}

do_restore_test_with_file() {
    local restore_dir=$1
    local restore_sign_key=$2
    local restore_encrypt_key=$3
    local restore_dryrun=$4
    [[ -d ${restore_dir} ]] || error "${restore_dir} does not exist"
    rm -rf /tmp/restore-test.* # remove any previous restore test dir
    local temp_dir=$(mktemp -d -p /tmp restore-test.XXXXXXXXXX)
    log_info "Restore test target directory: ${temp_dir}"
    _do_restore "file://${restore_dir}" "${temp_dir}" "${restore_sign_key}" "${restore_encrypt_key}" "${restore_dryrun}"
}

main() {

    while getopts ":d:s:e:thvn" opt
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
            n)
                readonly RESTORE_DRYRUN=1
                ;;
            \?)
                usage 1
                ;;
        esac
    done

    [[ -n ${RESTORE_DIR} ]] || usage 1
    [[ -n ${RESTORE_SIGN_KEY} ]] || readonly RESTORE_SIGN_KEY="none"
    [[ -n ${RESTORE_ENCRYPT_KEY} ]] || readonly RESTORE_ENCRYPT_KEY="none"

    if [[ -n ${RESTORE_TEST} ]];
    then
        do_restore_test_with_file ${RESTORE_DIR} ${RESTORE_SIGN_KEY} ${RESTORE_ENCRYPT_KEY} ${RESTORE_DRYRUN}
    else
        do_restore_home_with_file ${RESTORE_DIR} ${RESTORE_SIGN_KEY} ${RESTORE_ENCRYPT_KEY} ${RESTORE_DRYRUN}
    fi
}

main ${ARGS}
