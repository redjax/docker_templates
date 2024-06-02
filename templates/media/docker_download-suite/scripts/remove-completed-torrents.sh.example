#!/bin/bash

# port, username, password
SERVER="<your server ip>:9091 --auth "${TRANSMISSION_USR}":"${TRANSMISSION_PASS}

# Check if transmission-remote is installed
# if ! command -v transmission-remote &> /dev/null
# then
#  echo "Installing: transmission-cli"
#  sudo apt install -y transmission-cli
# else
#  echo "Skip: transmission-cli install"
# fi


# use transmission-remote to get torrent list from transmission-remote list
TORRENTLIST=`transmission-remote $SERVER --list | sed -e '1d' -e '$d' | awk '{print $1}' | sed -e 's/[^0-9]*//g'`

# for each torrent in the list
for TORRENTID in $TORRENTLIST
do
    INFO=$(transmission-remote $SERVER --torrent $TORRENTID --info)
    echo -e "Processing #$TORRENTID - $(echo $INFO | sed -e 's/.*Name: \(.*\) Hash.*/\1/')"
    
    # check if torrent download is completed
    DL_COMPLETED=`echo $INFO | grep "Done: 100%"`
    # check torrents current state is
    STATE_STOPPED=`echo $INFO | grep "State: Seeding\|State: Stopped\|State: Finished\|State: Idle"`

    # if the torrent is "Stopped", "Finished", or "Idle after downloading 100%"
    if [ "$DL_COMPLETED" ] && [ "$STATE_STOPPED" ]; then
        echo "Torrent #$TORRENTID is completed. Removing torrent from list."
        transmission-remote $SERVER --torrent $TORRENTID --remove
    else
        echo "Torrent #$TORRENTID is not completed. Ignoring."
    fi
done
