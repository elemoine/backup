#!/bin/bash

[[ -n $DEV ]] || DEV="/dev/sdb"

error() {
    local errmsg="$1"
    echo "Error: ${errmsg}"
    exit 1
}

main() {
    local mountpoint=$(findmnt -n -f -o target ${DEV})
    [[ -n $mountpoint ]] || error "${DEV} is not mounted"

    local backupdir=${mountpoint}/backup
    [[ -d $backupdir ]] || error "${backupdir} does not exist"

    duplicity --exclude-filelist excludes.txt ${HOME} file://${backupdir}
}

main
