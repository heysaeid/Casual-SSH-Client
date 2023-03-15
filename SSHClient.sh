#!/bin/bash

SSH_CONFIG_FILE="$HOME/.ssh/sessions.conf"

if [[ "$1" == "--add" ]]; then
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
fi

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