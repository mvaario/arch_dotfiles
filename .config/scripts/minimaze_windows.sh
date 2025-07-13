#!/bin/bash

TMP_FILE="$XDG_RUNTIME_DIR/hyprland-show-desktop"


# Get all active workspaces on all monitors
mapfile -t WORKSPACES < <(hyprctl monitors -j | jq -r '.[].activeWorkspace.name')

for CURRENT_WORKSPACE in "${WORKSPACES[@]}"; do
  TMP_WORKSPACE_FILE="$TMP_FILE-$CURRENT_WORKSPACE"

  if [ -s "$TMP_WORKSPACE_FILE" ]; then
    mapfile -t ADDRESS_ARRAY < "$TMP_WORKSPACE_FILE"
    CMDS=""
    for address in "${ADDRESS_ARRAY[@]}"; do
      CMDS+="dispatch movetoworkspacesilent name:$CURRENT_WORKSPACE,address:$address;"
    done

    if [[ -n "$CMDS" ]]; then
      hyprctl --batch "$CMDS"
    fi

    rm "$TMP_WORKSPACE_FILE"
  else
    mapfile -t ADDRESS_ARRAY < <(hyprctl clients -j | jq -r --arg CW "$CURRENT_WORKSPACE" '.[] 
      | select(.workspace.name == $CW and (.class | ascii_downcase) != "waybar") 
      | .address')

    CMDS=""
    TMP_ADDRESS=""
    for address in "${ADDRESS_ARRAY[@]}"; do
      if [[ -n "$address" ]]; then
        TMP_ADDRESS+="$address\n"
        CMDS+="dispatch movetoworkspacesilent special:desktop,address:$address;"
      fi
    done

    if [[ -n "$CMDS" ]]; then
      hyprctl --batch "$CMDS"
      echo -e "$TMP_ADDRESS" | sed '/^$/d' > "$TMP_WORKSPACE_FILE"
    fi
  fi
done
