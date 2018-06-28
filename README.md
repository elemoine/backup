# Restic-based backup and restore scripts

The `backup.sh` script is used to back up the user's homedir (`$HOME`). And
`restore.sh` is used to restore it.

## Backup

Use `backup.sh -h` to know how to use `backup.sh` to back up your homedir.
Here is an example:

```bash
$ ./backup.sh -d /media/usb/backup -v
```

`-d` is used to specify the backup target directory. `-v` is used to increase
the verbosity.

## Restore

Use `restore.sh -h` to know how to use `restore.sh` to restore your homedir.
Here is an example:

```bash
$ ./restore.sh -d /media/usb/backup -t -v
```

`-d` is used to specify the source directory of the restore operation. `-v`
is used to increase the verbosity.

`-t` means create a temporary directory in `/tmp` and do the restore in this
directory. This is useful for testing restores and when you don't want to mess
up with your homedir.
