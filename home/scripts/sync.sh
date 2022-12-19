#!/usr/bin/env bash

function syncLocal 
   rclone sync google_drive: ~/Documents/google-drive-local/
end

function syncRemote
   rclone sync ~/Documents/google-drive-local/ google_drive:
end
