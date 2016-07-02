alias ccd='cd'
alias geoipecho='wget http://ancient-shore-2349.herokuapp.com/ -O - -q; echo'
alias ipecho='wget http://ipecho.net/plain -O - -q ; echo'
alias iptest='ping 8.8.8.8'
alias $='echo'
alias sublime='open -a "Sublime Text 2"'

foldersize() {
    du -sh * | perl -e 'sub h{%h=(K=>10,M=>20,G=>30);($n,$u)=shift=~/([0-9.]+)(\D)/;return $n*2**$h{$u}}print sort{h($b)<=>h($a)}<>;'
}

killmatch() {
    match=$1
    args=$2
    `ps aux | grep $match | grep -v grep | awk '{print $2}' | xargs kill $args`
}

alarm() {
    waitSecs=`echo $* | bc`
    echo "sleep $waitSecs && /bin/sh -c 'while true ; do cat ~/Sound/32425\^alarm1.mp3 | mpg123 - ; sleep 3 ; done '"
    sleep $waitSecs && /bin/sh -c 'while true ; do cat ~/Sound/32425\^alarm1.mp3 | mpg123 - ; sleep 3 ; done '
}

resetaudio() {
    sudo kextunload -c /System/Library/Extensions/AppleHDA.kext
    sudo kextload /System/Library/Extensions/AppleHDA.kext
    sudo killall coreaudiod
}

addtoclasspath() {
    if (( $# >= 1 )) ; then
        pathToAdd=`(cd $1 && pwd)`
    else
        pathToAdd=`pwd`
    fi
    for jarfile in $pathToAdd/*.jar; do
        export CLASSPATH=$jarfile:$CLASSPATH
        echo "export CLASSPATH=$jarfile:\$CLASSPATH" >> $HOME/.path_local
    done
}

addtopath() {
    if (( $# >= 1 )) ; then
        pathToAdd=`(cd $1 && pwd)`
    else
        pathToAdd=`pwd`
    fi
    export PATH=$pathToAdd:$PATH
    echo "export PATH=$pathToAdd:\$PATH" >> $HOME/.path_local
}

taintmatch() {
    terraform show -module-depth=1 | grep $* | grep ':$' | sed 's/module\.\([^\.]*\)\.\(.*\):$/terraform taint -module=\1 \2/'
}

confirm() {
    while true; do
        echo -n "Do you wish to continue? "
        read yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

save-hostname() {
    (
        if [ -f $HOME/.hostname-saved ]; then
            SAVED_HOSTNAME=`cat $HOME/.hostname-saved`
            CUR_HOSTNAME=`scutil --get LocalHostName`
            echo "Overwriting saved hostname address of $SAVED_HOSTNAME to $CUR_HOSTNAME"
            confirm
        fi
        scutil --get LocalHostName > $HOME/.hostname-saved
        echo 'Stored Hostname overwritten..'
    )
}

restore-hostname() {
    (
        if [ ! -f $HOME/.hostname-saved ]; then
            echo "No stored hostname to restore"
            return;
        fi
        SAVED_HOSTNAME=`cat $HOME/.hostname-saved`
        OLD_HOSTNAME=`scutil --get LocalHostName`
        echo "Restoring Hostname from $OLD_HOSTNAME to $SAVED_HOSTNAME.."
        confirm
        sudo scutil --set LocalHostName $SAVED_HOSTNAME
        echo "Done: Hostname is now $(scutil --get LocalHostName)"
    )
}

save-mac-address() {
    (
        if [ -f $HOME/.mac-saved ]; then
            SAVED_MAC=`cat $HOME/.mac-saved`
            CUR_MAC=`ifconfig en0 | grep ether | sed 's/ether //g' | sed 's/^.//g'`
            echo "Overwriting saved mac address of $SAVED_MAC to $CUR_MAC"
            confirm
        fi
        ifconfig en0 | grep ether | sed 's/ether //g' | sed 's/^.//g' > $HOME/.mac-saved
        echo 'Stored MAC Address overwritten..'
    )
}

restore-mac-address() {
    (
        OLD_MAC=`ifconfig en0 | grep ether | sed 's/ether //g' | sed 's/^.//g'`
        if [ ! -f $HOME/.mac-saved ]; then
            echo 'No Saved MAC to restore'
            return;
        fi
        SAVED_MAC=`cat $HOME/.mac-saved`
        echo "Restoring MAC Address from $OLD_MAC to $SAVED_MAC.."
        confirm
        sudo ifconfig en0 ether $SAVED_MAC
        NEW_MAC=`ifconfig en0 |grep ether| sed 's/ether //g' | sed 's/^.//g'`
        echo "Done: Mac is now $NEW_MAC"
    )
}

spoof-mac() {

    if (( $# >= 1 )) ; then
        (
            OLD_MAC=`ifconfig en0 | grep ether | sed 's/ether //g' | sed 's/^.//g'`
            NEW_RANDOM_MAC=$1
            echo "Changing Mac From $OLD_MAC To $NEW_RANDOM_MAC"
            confirm
            sudo ifconfig en0 ether $NEW_RANDOM_MAC
            NEW_MAC=`ifconfig en0 |grep ether| sed 's/ether //g' | sed 's/^.//g'`
            echo "Changed Mac From $OLD_MAC To $NEW_MAC"
        )
    else
        (
            OLD_MAC=`ifconfig en0 | grep ether | sed 's/ether //g' | sed 's/^.//g'`
            NEW_RANDOM_MAC=`openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//'`
            echo "Changing Mac From $OLD_MAC To $NEW_RANDOM_MAC"
            confirm
            sudo ifconfig en0 ether $NEW_RANDOM_MAC
            NEW_MAC=`ifconfig en0 |grep ether| sed 's/ether //g' | sed 's/^.//g'`
            echo "Changed Mac From $OLD_MAC To $NEW_MAC"
        )
    fi
}

tunnel() {
  createTunnel() {
    /usr/bin/ssh -NTC -f -o ServerAliveInterval=60 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -N -R \*:2232:localhost:22 pi@thomasrooney.me
    if [[ $? -eq 0 ]]; then
      echo Tunnel to thomasrooney.me created successfully
    else
      echo An error occurred creating a tunnel to thomasrooney.me. RC was $?
    fi
  }

  printf %s "$(date)"
  /bin/pidof ssh
  if [[ $? -ne 0 ]]; then
    echo Creating new tunnel connection
    createTunnel
  fi
}

shuffle() {
    if (( $# >= 1 )) ; then
        find $PWD |
        grep $* |
        grep '\.m4a\|\.mp3' |
        perl -MList::Util=shuffle -e 'print shuffle(<STDIN>);' |
        sed 's/\//QQQQ/g' |
        perl -n -MURI::Escape -e 'print uri_escape($_) . "\n";' |
        sed 's/QQQQ/\//g' |
        sed 's/\\0//g' |
        sed 's/...$//g' |
        xargs -I {} /bin/sh -c 'echo {} | tee -a /dev/tty | xargs -I {} /Applications/VLC.app/Contents/MacOS/VLC file://{} --play-and-exit -I dummy'
    else
        find $PWD |
        grep '\.m4a\|\.mp3' |
        perl -MList::Util=shuffle -e 'print shuffle(<STDIN>);' |
        sed 's/\//QQQQ/g' |
        perl -n -MURI::Escape -e 'print uri_escape($_) . "\n";' |
        sed 's/QQQQ/\//g' |
        sed 's/\\0//g' |
        sed 's/...$//g' |
        xargs -I {} /bin/sh -c 'echo {} | tee -a /dev/tty | xargs -I {} /Applications/VLC.app/Contents/MacOS/VLC file://{} --play-and-exit -I dummy'
    fi
}

windows() {
    sudo /usr/sbin/bless -mount /Volumes/BOOTCAMP  -legacy -setBoot  --nextonly
    sudo /sbin/shutdown -r now
}

mkcd() {
    if [ -d $1 ]; then
        echo "Directory already exists."
        return;
    fi

    mkdir $1
    cd $1
}

applySecrets() {
    declare -r SECRETS_DIR=$HOME/.secrets/
    declare SECRET_PASSWORD
    declare -a UNENCRYPTED_FILES
    declare -a ENCRYPTED_FILES
    declare ENCRYPTED_FILE
    declare UNENCRYPTED_FILE
    declare FILENAME
    declare ENV_VARIABLE
    declare SECRET
    declare PREFIX

    # echo -n "Prefix (e.g. TF_): "
    # read PREFIX
    # echo

    echo -n "Using OpenSSL at: "
    if ! which openssl
    then
      echo "Please install openssl"
      return
    fi

    if [ ! -d $SECRETS_DIR ]
    then
      echo "We expect our secrets to be in $SECRETS_DIR.. No such directory found"
      return
    fi

    __ensure_secret_password() {
      if [ -z ${SECRET_PASSWORD} ]
      then
        echo -n "Password: "
        read -s SECRET_PASSWORD
        echo
      fi
    }

    __secret_enc() {
      openssl enc -aes-256-cbc -a -salt -in "$1" -out "$2" -k $SECRET_PASSWORD
    }

    __secret_dec() {
      openssl enc -d -aes-256-cbc -a -salt -in "$1" -k $SECRET_PASSWORD
    }
    UNENCRYPTED_FILES=($(find -E $SECRETS_DIR -type f -maxdepth 1 | grep -v \.enc | grep secret ))
    if [ "${#UNENCRYPTED_FILES[@]}" -gt 0 ]
    then
      echo "You have unencrypted Key files in your directory. We will now encrypt them and delete the unencrypted originals."
      echo "Every time you run subsequently run this script you will be prompted to enter this password."
      if [ "${#ENCRYPTED_FILES[@]}" -gt 0 ]
      then
        echo "Remember to enter the same password as you use for your other encrypted files ($ENCRYPTED_FILES)"
      fi
      __ensure_secret_password
      # Run Command
      for UNENCRYPTED_FILE in ${UNENCRYPTED_FILES[*]}
      do
        printf "   Encrypting: %s\n" $UNENCRYPTED_FILE
        $(__secret_enc $UNENCRYPTED_FILE $UNENCRYPTED_FILE.enc)
        printf "   ... Done. Result at $UNENCRYPTED_FILE.enc\n"
        rm $UNENCRYPTED_FILE
        printf "   ... Deleted $UNENCRYPTED_FILE\n"
      done
    fi

    ENCRYPTED_FILES=($(find -E $SECRETS_DIR -type f -maxdepth 1 | grep \.enc | grep secret))

    for ENCRYPTED_FILE in ${ENCRYPTED_FILES[*]}
    do
      __ensure_secret_password
      FILENAME=$(basename $ENCRYPTED_FILE)
      ENV_VARIABLE=$(echo $FILENAME | perl -pe 's|(.*?)\.secret.*|\1|' | xargs -I {} echo $PREFIX{} )
      SECRET=$(__secret_dec $ENCRYPTED_FILE)
      if [ -z ${ENV_VARIABLE+x} ]
      then
        echo "Environment variable \$$ENV_VARIABLE already set.. resetting"
        unset $ENV_VARIABLE
      fi
      printf "   Decrypting: %s\n" $ENCRYPTED_FILE
      export ${ENV_VARIABLE}=${SECRET}
      printf "   ... Done. \$$ENV_VARIABLE configured\n"
    done
    unset -f __secret_enc
    unset -f __secret_dec
    unset -f __ensure_secret_password
}

source $HOME/.path_local
