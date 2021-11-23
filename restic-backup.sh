#!/bin/sh

RESTIC_BIN=/usr/bin/restic
CFG_DIR=/home/$USER/.config/restic/
LOGFILE=/home/$USER/restic.log

# Get the environment also in this file, in case it's not read properly
. $CFG_DIR/env.conf

# Run backup
$RESTIC_BIN backup \
            --files-from $CFG_DIR/includes.txt \
            --exclude-file $CFG_DIR/excludes.txt

# Remove snapshots according to policy
# If run cron more frequently, might add --keep-hourly 24
$RESTIC_BIN forget \
            --keep-daily 7 \
            --keep-weekly 4 \
            --keep-monthly 12 \
            --keep-yearly 7

# Remove unneeded data from the repository
$RESTIC_BIN prune

# Check the repository for errors
$RESTIC_BIN check

# Done