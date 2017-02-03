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
    -s <key>      the GPG sign key
    -e <key>      the GPG encrypt key
    -h            help
    -v            increase verbosity

Example:
    ${PROGNAME} -d /media/usb/backup -s 5BBF59DF126FADEF -e 57F334375840CA38 -v
EOF
    exit $exitcode
}

_do_backup_home() {
    local target=$1
    local backup_sign_key=$2
    local backup_encrypt_key=$3
    log_debug "Backup target: ${target}"
    log_debug "Backup sign key: ${backup_sign_key}"
    log_debug "Backup encrypt key: ${backup_encrypt_key}"
    local opts=
    # full backup if latest full backup is older than 1 month
    opts="--full-if-older-than 1M"
    opts="${opts} --sign-key ${backup_sign_key} --encrypt-key ${backup_encrypt_key}"
    opts="${opts} --use-agent --exclude-filelist excludes.txt"
    [[ -n ${BACKUP_RESTORE_DEBUG} ]] && opts="--verbosity info ${opts}"
    duplicity ${opts} ${HOME} ${target}
}

do_backup_home_with_file() {
    local backup_dir=$1
    local backup_sign_key=$2
    local backup_encrypt_key=$3
    [[ -d ${backup_dir} ]] || error "${backup_dir} does not exist"
    _do_backup_home "file://${backup_dir}" "${backup_sign_key}" "${backup_encrypt_key}"
}

do_backup_home_with_scp() {
    local backup_host=$1
    local backup_sign_key=$2
    local backup_encrypt_key=$3
    local backup_dir="/share/MD0_DATA/homes/admin/backups/workstations/${USERID}"
    _do_backup_home "scp://${backup_host}/${backup_dir}" "${backup_sign_key}" "${backup_encrypt_key}"
}

main() {

    while getopts ":d:s:e:hv" opt
    do
        case "${opt}" in
            d)
                readonly BACKUP_DIR=${OPTARG}
                ;;
            s)
                readonly BACKUP_SIGN_KEY=${OPTARG}
                ;;
            e)
                readonly BACKUP_ENCRYPT_KEY=${OPTARG}
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
    [[ -n ${BACKUP_SIGN_KEY} ]] || usage 1
    [[ -n ${BACKUP_ENCRYPT_KEY} ]] || usage 1

    do_backup_home_with_file ${BACKUP_DIR} ${BACKUP_SIGN_KEY} ${BACKUP_ENCRYPT_KEY}
}

main ${ARGS}
