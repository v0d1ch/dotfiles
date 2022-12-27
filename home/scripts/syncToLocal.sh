#!/usr/bin/env bash


spd-say 'sync to local starting'
rclone sync google_drive: ~/Documents/google-drive-local/
spd-say 'sync to local end'
