# Duplicity-based backup and restore scripts

The `backup.sh` script is used to back up the user's homedir (`$HOME`). And
`restore.sh` is used to restore it.

## Backup

Use `backup.sh -h` to know how to use `backup.sh` to back up your homedir.
Here is an example:

```bash
$ ./backup.sh -d /media/usb/backup -k E588ECCD
```

`-d` is used to specify the backup target directory. Note that `file://` is the
only supported Duplicity backend at this point.

`-k` is used to specify the id of the GPG key to use for encryption and
signing.  Use `gpg2 --list-secret-keys <your.email@blabla.com>` to know the id
of your key.

## Restore

Use `restore.sh -h` to know how to use `restore.sh` to restore your homedir.
Here is an example:

```bash
$ ./restore -s /media/usb/backup -k E588ECCD -t
```

`-s` is used to specify the source directory of the restore operation. Again,
`file://` is the only supported backend at this point.

As previously, `-k` is used to specify the id of the GPG key.

`-t` means create a temporary directory in `/tmp` and do the restore in this
directory. This is useful for testing restores and when you don't want to mess
up with your homedir.
