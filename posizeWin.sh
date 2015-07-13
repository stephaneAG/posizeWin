#!/bin/bash

# helper(s)
# look for the line data of some item from external dict & if found do the necessary to add the corresponding entry
lookForDictItem(){
  item="${1}"
  setkeys="${2}"
  # loop over lines in dict
  while read line; do
    #echo $line;
    # parse the line 
    IFS=':' read line_item line_name line_command line_keys <<< "${line}"
    # look for a match
    if [ "$item" == "$line_item" ]; then
      echo "match found: $item"
      # create an entry for the item
      entry=$(createEntry)
      # configure it, with or without keys
      if [ "$setkeys" == "true" ]; then
        configureEntry "${entry}" "${line_name}" "${line_command}" "${line_keys}"
      else
        configureEntry "${entry}" "${line_name}" "${line_command}"
      fi   
    fi
  done < ./stag_posizeWin_dict
}

# configure an entry
configureEntry(){
  entry="${1}"
  name="${2}"
  command="${3}"
  keys="${4}"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${entry}/ name "${name}"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${entry}/ command "${command}"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${entry}/ binding '<key_combination>'
}

# create a new entry & return it's name ( ex: "custom11")
createEntry(){
  # get the current entries
  IFS=', ' read -a customkeybindigs <<< $(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
  # get their number
  customkeybindigsnum="${#customkeybindigs[@]}"
  # get the last entry
  customkeybindigslast="${customkeybindigs[${#customkeybindigs[@]}-1]}"
  # "clean" it by removing the ']' after it
  customkeybindigslastclean="${customkeybindigslast%\]*}"
  # overwrite the last item using it's "clean" version
  customkeybindigs[${#customkeybindigs[@]}-1]="${customkeybindigslastclean}"
  # add a new entry, as well as a trailin ']'
  customkeybindigs[${#customkeybindigs[@]}]="'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${customkeybindigsnum}/']"
  # format the array to match the expected format ( aka, a commas after each item )
  customkeybindigsformatted=$(for i in "${customkeybindigs[@]}"; do printf "%s, " "$i";done)
  # ( strip the trailing, unwanted comma )
  customkeybindigsformatted="${customkeybindigsformatted%,*}"
  # update the entries by feeding the modified array back to gsettings
  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "${customkeybindigsformatted}"
  # echo the name of the entry created
  echo "custom${customkeybindigsnum}"
}

# main function of the script
stag_posizeWin(){
  
  ## the below overhead is necessary if we don't know the dimensions of the screen connected to the hardware executing the script
  dims=$(xdpyinfo  | grep dimensions)
  #echo "[SCREEN DIMENSIONS: $dims ]"
  dims="${dims% pixels*}"
  #echo "[SCREEN DIMENSIONS: $dims ]"
  dims="${dims#* dimensions:}"
  #echo "[SCREEN DIMENSIONS: $dims ]"
  dimWidth="${dims%x*}"
  #echo "[SCREEN WIDTH: $dimWidth ]"
  dimHeight="${dims#*x}"
  #echo "[SCREEN HEIGHT: $dimHeight ]"
  dimHalfWidth=$(( $dimWidth / 2 ))
  #echo "[SCREEN HALF WIDTH: $dimHalfWidth ]"
  dimHalfHeight=$(( $dimHeight / 2 ))
  #echo "[SCREEN HALF HEIGHT: $dimHalfHeight ]"
  
  #echo "[ARG PASSED: $1 ]"

  case "$1" in
    topleft|tl)
      /usr/bin/xdotool windowsize `/usr/bin/xdotool getwindowfocus` $dimHalfWidth $dimHalfHeight && /usr/bin/xdotool windowmove `/usr/bin/xdotool getwindowfocus` 0 0
      ;;
    top|t)
      /usr/bin/xdotool windowsize `/usr/bin/xdotool getwindowfocus` $dimWidth $dimHalfHeight && /usr/bin/xdotool windowmove `/usr/bin/xdotool getwindowfocus` 0 0
      ;;
    topright|tr)
      /usr/bin/xdotool windowsize `/usr/bin/xdotool getwindowfocus` $dimHalfWidth $dimHalfHeight && /usr/bin/xdotool windowmove `/usr/bin/xdotool getwindowfocus` $dimHalfWidth 0
      ;;
    left|l)
      /usr/bin/xdotool windowsize `/usr/bin/xdotool getwindowfocus` $dimHalfWidth $dimHeight && /usr/bin/xdotool windowmove `/usr/bin/xdotool getwindowfocus` 0 0
      ;;
    center|c)
      # R: to make a negative value positive, the following quickie is helpful: "${maybeNegative#*-}"
      winDims=$(xdotool getwindowgeometry --shell $(xdotool getactivewindow) | tr "\n" " ")
      winDims="${winDims% SCREEN*}"
      winDims1="${winDims% WIDTH*}"
      winDims1="${winDims1#* X=}"
      winX="${winDims1% Y*}"
      winY="${winDims1#* Y=}"
      winDims2="${winDims#*WIDTH=}"
      winWidth="${winDims2% *}"
      winHeight="${winDims2#* HEIGHT=}"
      winDimHalfWidth=$(( $winWidth / 2 ))
      winDimHalfHeight=$(( $winHeight / 2 ))
      winCenterX=$(( $winX + $winDimHalfWidth ))
      winCenterY=$(( $winY + $winDimHalfHeight ))
      # WIP START
      # idea
      #(( $winCenterX > $dimHalfWidth )) && winNewX=$(( $winX - ( $winCenterX - $dimHalfWidth ) )) || winNewX=$(( $winX + ( $winCenterX - $dimHalfWidth ) ))
      #(( $winCenterY > $dimHalfHeight )) && winNewY=$(( $winY - ( $winCenterY - $dimHalfHeight ) )) || winNewY=$(( $winY + ( $winCenterY - $dimHalfHeight ) ))
      # debug
      # (( $winCenterX > $dimHalfWidth ))
        # distanceDiffX=$(( $winCenterX - $dimHalfWidth ))
          # newX=$(( $winX - $distanceDiffX ))
      # (( $winCenterY > $dimHalfHeight ))
        # distanceDiffY=$(( $winCenterY - $dimHalfHeight ))
      # WIP END
      # "hackety trick simplifier"
     
      distDiffX=$(( $winCenterX - $dimHalfWidth ))
      distDiffX="${distDiffX#*-}"
      distDiffY=$(( $winCenterY - $dimHalfHeight ))
      distDiffY="${distDiffY#*-}"

      (( $winCenterX > $dimHalfWidth )) && winNewX=$(( $winX - $distDiffX )) || winNewX=$(( $winX + $distDiffX ))
      (( $winCenterY > $dimHalfHeight )) && winNewY=$(( $winY - $distDiffY )) || winNewY=$(( $winY + $distDiffY ))
      
      xdotool windowmove $(xdotool getactivewindow) $winNewX $winNewY
      ;;
    right|r)
      /usr/bin/xdotool windowsize `/usr/bin/xdotool getwindowfocus` $dimHalfWidth $dimHeight && /usr/bin/xdotool windowmove `/usr/bin/xdotool getwindowfocus` $dimHalfWidth 0
      ;;
    bottomleft|bl)
      /usr/bin/xdotool windowsize `/usr/bin/xdotool getwindowfocus` $dimHalfWidth $dimHalfHeight && /usr/bin/xdotool windowmove `/usr/bin/xdotool getwindowfocus` 0 $dimHalfHeight
      ;;
    bottom|b)
      /usr/bin/xdotool windowsize `/usr/bin/xdotool getwindowfocus` $dimWidth $dimHalfHeight && /usr/bin/xdotool windowmove `/usr/bin/xdotool getwindowfocus` 0 $dimHalfHeight
      ;;
    bottomright|br)
      /usr/bin/xdotool windowsize `/usr/bin/xdotool getwindowfocus` $dimHalfWidth $dimHalfHeight && /usr/bin/xdotool windowmove `/usr/bin/xdotool getwindowfocus` $dimHalfWidth $dimHalfHeight
      ;;
    fullscreen|f)
      echo "use F11 like everyone !"
      ;;
    maximize|ma)
      xdotool windowsize $(xdotool getactivewindow) $dimWidth $dimHeight && xdotool windowmove $(xdotool getactivewindow) 0 0
      #xdotool windowsize $(xdotool getactivewindow) 100% 100% && xdotool windowmove $(xdotool getactivewindow) 0 0
      ;;
    minimize|mi)
      xdotool windowminimize $(xdotool getactivewindow)
      ;;
    help|h)
      echo " -- The script arguments available are the following -- "
      echo "help / h - the one you're currently reading ;)"
      echo "winargs / wrgs - displays the winargs available"
      echo "genkey / gnk - generate a list of the 'standard' naming, command & keys mapping, one by line, for easy copy/paste"
      echo "genkey_src / gnks - display the function used to provide the above listing ( more here as a quick reminder of useful one-liner ;p )"
      echo "install / nstl - install all or specific entries in the gsettings GUI panel, with related Name & Command"
      echo "installkeys / nstlk - install all or specific entries in the gsettings GUI panel, with related Name, Command & Keys"
      echo
      echo " -- The so-called 'winargs' ( placement & dimension arguments ) available are the following -- "
      echo $(stag_posizeWin winargs) "fullscreen" "maximize" "minimize"
      ;;
    winargs|wrgs)
      echo "topleft" "top" "topright" "left" "center" "right" "bottomleft" "bottom" "bottomright"
      ;;
    genkey|gnk)
        for i in $(stag_posizeWin winargs); do printf "Window Handling - Resize & Reposition [ %s ]\nbash -c \"~/Documents/stag_psresWin_script_exec.sh %s\"\n" "$i" "$i";done
      ;;
    genkey_src|gnks)
        echo 'for i in $(stag_posizeWin winargs); do printf "Window Handling - Resize & Reposition [ %s ]\nbash -c \"~/Documents/stag_psresWin_script_exec.sh %s\"\n" "$i" "$i";done'
      ;;
    install|nstl)
      shift
      if [ "$1" == "all" ]; then
        echo "installing all entries and corresponding name & command, without keys";
        for item in $(stag_posizeWin winargs)
        do
          lookForDictItem "${item}"
        done
      elif [ "$1" == "" ]; then
        echo "please specify a winarg to install its corresponding entry with corresponding name & command, without keys";
      else
        echo "installing entries and corresponding name & command, without keys, for: $@";
        for item in "${@}"
        do
          #echo "item: ${item}"
          lookForDictItem "${item}"
        done
      fi 
      ;;
    installkeys|nstlk)
      shift
      if [ "$1" == "all" ]; then
        echo "installing all entries and corresponding name, command & keys";
        for item in $(stag_posizeWin winargs)
        do
          lookForDictItem "${item}" "true"
        done
      elif [ "$1" == "" ]; then
        echo "please specify a winarg to install its corresponding entry with corresponding name, command & keys";
      else
        echo "installing entries and corresponding name, command & keys, for: $@";
        for item in "${@}"
        do
          #echo "item: ${item}"
          lookForDictItem "${item}" "true"
        done
      fi
      ;;
  esac
}

# call our 'main' function & pass it all the arguments passed to the script
stag_posizeWin $@



# R: may be useful for next versions of the script
# print the cursor location whenever the mouse enters a currently-visible window
#xdotool search --onlyvisible . behave %@ mouse-enter getmouselocation
