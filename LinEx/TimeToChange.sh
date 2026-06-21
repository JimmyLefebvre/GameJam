#!/bin/sh
printf '\033c\033]0;%s\a' ProjetGameJam
base_path="$(dirname "$(realpath "$0")")"
"$base_path/TimeToChange.x86_64" "$@"
