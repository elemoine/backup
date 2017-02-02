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
    [[ -n ${BACKUP_DEBUG} ]] && echo "${msg}"
}

