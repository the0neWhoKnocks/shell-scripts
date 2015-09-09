#!/bin/sh

# use pid for unique identifier of file
tempFile=/tmp/git_commit_$$.txt
# get the previous git commit message
previousMsg=$(git log -n 1 --pretty=format:"%B")

# set the path to your preferred editor along with it's args
editorPath='"C:/Program Files (x86)/Notepad++/notepad++.exe" -multiInst -nosession -noPlugin'

# handle Cygwin paths
if [ -d "/cygdrive" ]; then
  # replace Cygwin home with proper OS path that editor can use
  winHome=$(cygpath -wpm /home)
  editMsgPath=`echo "$*" | sed "s|\/home|${winHome}|"`
  
  # replace Cygwin paths with proper OS path that editor can use
  editMsgPath=`echo "$editMsgPath" | sed -E 's/\/cygdrive\/([[:alpha:]])/\1:/'`
fi



# build out the message
touch "$tempFile"
echo "$previousMsg" > "$tempFile"
cat "$editMsgPath" >> "$tempFile"
cat "$tempFile" > "$editMsgPath"

# remove temp file
rm "$tempFile"

# eval so quotes & args are parsed properly
eval "$editorPath" "$editMsgPath"
