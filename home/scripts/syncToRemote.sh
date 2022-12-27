#!/usr/bin/env bash


spd-say 'sync to remote starting'
rclone sync ~/Documents/google-drive-local/ google_drive:
spd-say 'sync to remote end'

