#!/bin/bash

SSH_CONFIG_FILE="$HOME/.ssh/sessions.conf"
SSH_SESSIONS=($(awk -F',' '{print $1}' "$SSH_CONFIG_FILE"))

if [[ "$1" == "add" ]]; then
  # Prompt the user for the new SSH session information
  read -p "Enter a name for the new SSH session: " SSH_NAME
  read -p "Enter the remote host for the new SSH session: " SSH_HOST
  read -p "Enter the SSH user for the new SSH session: " SSH_USER
  read -p "Enter the SSH port for the new SSH session (leave blank for default): " SSH_PORT

  # If no SSH port was provided, use the default (22)
  if [[ -z "$SSH_PORT" ]]; then
    SSH_PORT=22
  fi

  # Append the new SSH session to the configuration file
  echo "${SSH_NAME},${SSH_HOST},${SSH_USER},${SSH_PORT}" >> "$SSH_CONFIG_FILE"
  echo "SSH session added: $SSH_NAME"
  exit 0
elif [[ "$1" == "remove" ]]; then
  # Display the list of SSH sessions and prompt the user to select one to remove
  echo "Select an SSH session to remove:"
  for i in "${!SSH_SESSIONS[@]}"; do
    echo "[$i] ${SSH_SESSIONS[$i]}"
  done
  read -p "Enter selection: " selection

  # Check if the selection is valid
  if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ "$selection" -lt 0 ]] || [[ "$selection" -ge ${#SSH_SESSIONS[@]} ]]; then
    echo "Invalid selection: $selection"
    exit 1
  fi

  # Remove the selected SSH session from the configuration file
  session_name=${SSH_SESSIONS[$selection]}
  sed -i "/^${session_name},/d" "$SSH_CONFIG_FILE"

  echo "SSH session removed: $session_name"
  exit 0
else
  # Check if the user specified a number of panes
  if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <num_panes>"
    exit 1
  fi

  num_panes=$1

  # Create a new tmux session with the specified number of panes
  tmux new-session -d -s ssh-session "bash"
  for i in $(seq 2 $num_panes); do
    tmux split-window "bash"
  done

  # Synchronize input between the panes
  tmux setw synchronize-panes on

  # Attach to the tmux session
  tmux attach -t ssh-session
fi