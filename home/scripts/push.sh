#!/usr/bin/env bash

set _token 'ashusfk3sebfp8u65ung69cc8pnqu5'
set _user 'ujz7utgab9jr7ca7swf9zhas1utwbo'

function push
   set t $argv[1] 
   set m $argv[2] 
   curl -s \
     --form-string "token=$_token" \
     --form-string "user=$_user" \
     --form-string "title=$t" \
     --form-string "message=$m" \
     https://api.pushover.net/1/messages.json
end
