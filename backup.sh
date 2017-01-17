#!/bin/bash

duplicity --exclude-filelist excludes.txt ${HOME} file:///media/usb/backup
