# Duplicity-based backup and restore scripts

The `backup.sh` script is used to back up the user's homedir (`$HOME`). And
`restore.sh` is used to restore it.

Warning: these scripts do not work with Duplicity 0.7.12, because of a bug in
that version. See https://bugs.launchpad.net/duplicity/+bug/1687291. So 0.7.11
should be used for now. See below for how to install Duplicity 0.7.11 in
a virtual environment.

## Backup

Use `backup.sh -h` to know how to use `backup.sh` to back up your homedir.
Here is an example:

```bash
$ ./backup.sh -d /media/usb/backup -s 5BBF59DF126FADEF -e 57F334375840CA38 -v
```

`-d` is used to specify the backup target directory. Note that `file://` is the
only supported Duplicity backend at this point.

`-s` is used to specify the GPG key to use for signing, and `-e` the one for
encrypting. For example, use `gpg2 --list-secret-keys
--with-subkey-fingerprint your.email@blabla.com` to know the id of your key.

## Restore

Use `restore.sh -h` to know how to use `restore.sh` to restore your homedir.
Here is an example:

```bash
$ ./restore.sh -d /media/usb/backup -s 5BBF59DF126FADEF -e 57F334375840CA38 -t -v
```

`-d` is used to specify the source directory of the restore operation. Again,
`file://` is the only supported backend at this point.

As previously, `-s` and `-e` are used to specify the "sign" and "encrypt" GPG
key, respectively.

`-t` means create a temporary directory in `/tmp` and do the restore in this
directory. This is useful for testing restores and when you don't want to mess
up with your homedir.

## Install Duplicity 0.7.11 in a virtual environment

```bash
$ virtualenv duplicity
$ pip install https://code.launchpad.net/duplicity/0.7-series/0.7.11/+download/duplicity-0.7.11.tar.gz
```
