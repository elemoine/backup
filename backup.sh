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
    -n            dry-run

Example:
    ./${PROGNAME} -d /media/usb/backup -s 5BBF59DF126FADEF -e 57F334375840CA38 -v
EOF
    exit $exitcode
}

_do_backup_home() {
    local target=$1
    local backup_sign_key=$2
    local backup_encrypt_key=$3
    local backup_dryrun=$4
    log_debug "Backup target: ${target}"
    [[ ${backup_sign_key} != "none" ]] && log_debug "Backup sign key: ${backup_sign_key}"
    [[ ${backup_encrypt_key} != "none" ]] && log_debug "Backup encrypt key: ${backup_encrypt_key}"
    # full backup if latest full backup is older than 1 month
    local opts="--full-if-older-than 1M"
    [[ ${backup_sign_key} != "none" ]] && opts="${opts} --sign-key ${backup_sign_key}"
    [[ ${backup_encrypt_key} != "none" ]] && opts="${opts} --encrypt-key ${backup_encrypt_key}"
    [[ ${backup_sign_key} != "none" || ${backup_encrypt_key} != "none" ]] && opts="${opts} --use-agent"
    opts="${opts} --exclude-filelist excludes.txt"
    [[ -n ${BACKUP_RESTORE_DEBUG} ]] && opts="--verbosity info ${opts}"
    [[ -n ${backup_dryrun} ]] && opts="--dry-run ${opts}"
    duplicity ${opts} ${HOME} ${target}
    log_info "Command run: duplicity ${opts} ${HOME} ${target}"
}

do_backup_home_with_file() {
    local backup_dir=$1
    local backup_sign_key=$2
    local backup_encrypt_key=$3
    local backup_dryrun=$4
    [[ -d ${backup_dir} ]] || error "${backup_dir} does not exist"
    _do_backup_home "file://${backup_dir}" "${backup_sign_key}" "${backup_encrypt_key}" "${backup_dryrun}"
}

do_backup_home_with_scp() {
    local backup_host=$1
    local backup_sign_key=$2
    local backup_encrypt_key=$3
    local backup_dryrun=$4
    local backup_dir="/share/MD0_DATA/homes/admin/backups/workstations/${USERID}"
    _do_backup_home "scp://${backup_host}/${backup_dir}" "${backup_sign_key}" "${backup_encrypt_key}" "${backup_dryrun}"
}

main() {

    while getopts ":d:s:e:hvn" opt
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
            n)
                readonly BACKUP_DRYRUN=1
                ;;
            \?)
                usage 1
                ;;
        esac
    done

    [[ -n ${BACKUP_DIR} ]] || usage 1
    [[ -n ${BACKUP_SIGN_KEY} ]] || readonly BACKUP_SIGN_KEY="none"
    [[ -n ${BACKUP_ENCRYPT_KEY} ]] || readonly BACKUP_ENCRYPT_KEY="none"

    do_backup_home_with_file ${BACKUP_DIR} ${BACKUP_SIGN_KEY} ${BACKUP_ENCRYPT_KEY} ${BACKUP_DRYRUN}
}

main ${ARGS}
