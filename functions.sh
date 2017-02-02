#!/bin/bash

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
    [[ -n ${BACKUP_RESTORE_DEBUG} ]] && echo "${msg}"
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
