#!/bin/bash

sudo cp tada-keyboard-layout.xkb /usr/share/X11/xkb/symbols/tada
setxkbmap -layout tada

if [[ -f "$HOME/.Xmodmap" ]]; then
  xmodmap "$HOME/.Xmodmap"
fi

# Specify the autostart file and the two lines of code to check
autostart_file="$HOME/.config/autostart/autostart.sh"
setxkb_cmd="setxkbmap -layout tada"
xmodmap_cmd="xmodmap ~/.Xmodmap"

# Check if the file exists
if [[ -f "$autostart_file" ]]; then
    echo "File exists: $autostart_file"
    
    # Initialize flags to track line existence
    setxkb_found=false
    xmodmap_found=false
    
    # Read the file line by line
    while IFS= read -r current_line; do
        # Check if the setxkb command is found
        if [[ "$current_line" == "$setxkb_cmd" ]]; then
            setxkb_found=true
        fi
        
        if [[ -f "$HOME/.Xmodmap" ]]; then
          # Check if the xmodmap command is found after setxkb command
          if [[ "$setxkb_found" == true && "$current_line" == "$xmodmap_cmd" ]]; then
              xmodmap_found=true
              break
          fi
        else
          xmodmap_found=true
        fi
    done < "$autostart_file"
    
    # If both lines are found in the correct order
    if [[ "$setxkb_found" == true && "$xmodmap_found" == true ]]; then
        echo "Setup finished."
    elif [[ "$setxkb_found" == true && "$xmodmap_found" == false ]]; then
        echo "Setxkb command found, but xmodmap command is missing while .Xmodmap file exsits. Appending command now."
        echo "$xmodmap_cmd" >> "$autostart_file"
    else
        echo "Adding layout to autostart file."
        echo "$setxkb_cmd" >> "$autostart_file"

        if [[ -f "$HOME/.Xmodmap" ]]; then
          echo "$xmodmap_cmd" >> "$autostart_file"
        fi
    fi
else
    echo "Autostart file does not exist. Creating the file and adding layout."
    echo "$setxkb_cmd" > "$autostart_file"
    if [[ -f "$HOME/.Xmodmap" ]]; then
      echo "$xmodmap_cmd" >> "$autostart_file"
    fi
fi
