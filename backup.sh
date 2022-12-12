#!/bin/sh


# check to see is git command line installed in this machine
IS_GIT_AVAILABLE="$(git --version)"
if [[ $IS_GIT_AVAILABLE == *"version"* ]]; then
  echo "Git is Available"
else
  echo "Git is not installed"
  exit 1
fi



cp  /etc/nixos/configuration.nix .
cp  /etc/nixos/hardware-configuration.nix .
cp  $HOME/.xmonad/* .
cp  $HOME/.doom.d/* .
cp  $HOME/.emacs.d/* .
cp  $HOME/.xmobarrc .



# Check git status
gs="$(git status | grep -i "modified")"
# echo "${gs}"

# If there is a new change
if [[ $gs == *"modified"* ]]; then
  echo "push"
fi


# push to Github
git add -u;
git commit -m "New backup `date +'%Y-%m-%d %H:%M:%S'`";
git push origin master
