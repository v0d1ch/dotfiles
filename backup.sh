#!/bin/sh


spd-say 'backup starting'
# check to see is git command line installed in this machine
IS_GIT_AVAILABLE="$(git --version)"
if [[ $IS_GIT_AVAILABLE == *"version"* ]]; then
  echo "Git is Available"
else
  echo "Git is not installed"
  exit 1
fi

host=$(cat /etc/hostname)


cp  /etc/nixos/configuration.nix $host
cp  /etc/nixos/hardware-configuration.nix $host
cp  /etc/nixos/nvim/* nvim
cp  -R $HOME/.xmonad/* home/.xmonad
cp  -R $HOME/.xmobarrc home
cp  -R $HOME/.config/alacritty home/alacritty


# Check git status
gs="$(git status | grep -i "modified")"
# echo "${gs}"

# If there is a new change
if [[ $gs == *"modified"* ]]; then
  echo "push"
fi


# push to Github
git add --all;
git commit -m "New backup `date +'%Y-%m-%d %H:%M:%S'`";
git push origin master
spd-say 'completed'
