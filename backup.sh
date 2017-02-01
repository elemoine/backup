#!/bin/bash

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"
readonly USERID=$(id --user --name)

usage() {
    echo "Usage: ${PROGNAME} -d <backup_directory> -k <key_id> [-x]"
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

log_debug() {
    local msg="$1"
    [[ -n ${BACKUP_DEBUG} ]] && echo "${msg}"
}

_do_backup() {
    local target=$1
    local backup_keyid=$2
    log_debug "Backup target: ${target}"
    log_debug "Backup key: ${backup_keyid}"
    local opts="--encrypt-sign-key ${backup_keyid} --use-agent --exclude-filelist excludes.txt"
    [[ -n ${BACKUP_DEBUG} ]] && opts="--verbosity info ${opts}"
    duplicity ${opts} ${HOME} ${target}
}

do_backup_file() {
    local backup_dir=$1
    local backup_keyid=$2
    [[ -d ${backup_dir} ]] || error "${backup_dir} does not exist"
    _do_backup "file://${backup_dir}" "${backup_keyid}"
}

do_backup_scp() {
    local backup_host=$1
    local backup_keyid=$2
    local backup_dir="/share/MD0_DATA/homes/admin/backups/workstations/${USERID}"
    _do_backup "scp://${backup_host}/${backup_dir}" "${backup_keyid}"
}

main() {

    while getopts ":d:h:k:x" opt
    do
        case "${opt}" in
            d)
                readonly BACKUP_DIR=${OPTARG}
                ;;
            h)
                readonly BACKUP_HOST=${OPTARG}
                ;;
            k)
                readonly BACKUP_KEYID=${OPTARG}
                ;;
            x)
                declare -g -r BACKUP_DEBUG=1
                set -x
                ;;
            \?)
                usage
                ;;
        esac
    done

    [[ -n ${BACKUP_DIR} ]] || usage
    [[ -n ${BACKUP_KEYID} ]] || usage

    do_backup_file ${BACKUP_DIR} ${BACKUP_KEYID}
}

main ${ARGS}
