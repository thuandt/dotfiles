#!/bin/sh
# Filename: autosource_zshrc.sh
# Description: Automatically source zshrc in all open terminals when modify

# Crontab
# @reboot ~/.bin/autosource_zshrc.sh

# Need for cron
export DISPLAY=:0

while inotifywait -e modify ~/.zshrc ~/.shell_env ~/.shell_aliases ~/.shell_functions ; do
    #sleep to prevent duplicate events on same file
    killall -u $(whoami) -s USR1 zsh && notify-send 'zshrc sourced' && sleep 1
done

## End of file #####