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

_do_backup_home() {
    local target=$1
    local backup_keyid=$2
    log_debug "Backup target: ${target}"
    log_debug "Backup key: ${backup_keyid}"
    local opts="--encrypt-sign-key ${backup_keyid} --use-agent --exclude-filelist excludes.txt"
    [[ -n ${BACKUP_RESTORE_DEBUG} ]] && opts="--verbosity info ${opts}"
    duplicity ${opts} ${HOME} ${target}
}

do_backup_home_with_file() {
    local backup_dir=$1
    local backup_keyid=$2
    [[ -d ${backup_dir} ]] || error "${backup_dir} does not exist"
    _do_backup_home "file://${backup_dir}" "${backup_keyid}"
}

do_backup_home_with_scp() {
    local backup_host=$1
    local backup_keyid=$2
    local backup_dir="/share/MD0_DATA/homes/admin/backups/workstations/${USERID}"
    _do_backup_home "scp://${backup_host}/${backup_dir}" "${backup_keyid}"
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
