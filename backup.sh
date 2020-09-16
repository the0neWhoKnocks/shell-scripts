#!/bin/bash

if ! type 7z &> /dev/null; then
  echo "Installing 7zip since it's not currently installed"
  brew install p7zip
fi

ZIP_FILE_NAME="$HOME/Desktop/$(date +"%Y-%m-%d_%H-%M-%S")_user-data.zip"
(cd $HOME && 7z a "$ZIP_FILE_NAME" -p "$@" -x'!*.DS_Store')
