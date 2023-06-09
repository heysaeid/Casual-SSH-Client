#!/bin/bash

SSH_CONFIG_FILE="$HOME/.ssh/sessions.conf"
SSH_SESSIONS=($(awk -F',' '{print $1}' "$SSH_CONFIG_FILE"))

get_sessions () {
  for i in "${!SSH_SESSIONS[@]}"; do
    echo "[$i] ${SSH_SESSIONS[$i]}"
  done
}

if [[ "$1" == "add" ]]; then
  # Prompt the user for the new SSH session information
  read -p "Enter a name for the new SSH session: " SSH_NAME
  read -p "Enter the remote host for the new SSH session: " SSH_HOST
  read -p "Enter the SSH user for the new SSH session: " SSH_USER
  read -p "Enter the SSH password for the session: " SSH_PASSWORD
  read -p "Enter the SSH port for the new SSH session (leave blank for default): " SSH_PORT

  # If no SSH port was provided, use the default (22)
  if [[ -z "$SSH_PORT" ]]; then
    SSH_PORT=22
  fi

  # Append the new SSH session to the configuration file
  echo "${SSH_NAME},${SSH_HOST},${SSH_USER},${SSH_PASSWORD},${SSH_PORT}" >> "$SSH_CONFIG_FILE"
  echo "SSH session added: $SSH_NAME"
  exit 0
elif [[ "$1" == "remove" ]]; then
  # Display the list of SSH sessions and prompt the user to select one to remove
  echo "Select an SSH session to remove:"
  get_sessions
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
elif [[ "$1" == "edit" ]]; then
  # Display existing sessions
  for i in "${!SSH_SESSIONS[@]}"; do
    echo "[$i] ${SSH_SESSIONS[$i]}"
  done

  # Prompt the user for the session they want to modify
  read -p "Enter the index of the session to modify: " session_index
  session_index=$((session_index+1))

  # Get the existing session information
  existing_session_info=$(sed -n "${session_index}p" "$SSH_CONFIG_FILE")
  session_name=$(echo "$existing_session_info" | cut -d',' -f1)
  server_address=$(echo "$existing_session_info" | cut -d',' -f2)
  port_number=$(echo "$existing_session_info" | cut -d',' -f3)
  username=$(echo "$existing_session_info" | cut -d',' -f4)
  password=$(echo "$existing_session_info" | cut -d',' -f5)

  # Prompt the user for new session information
  read -p "Enter new session name [$session_name]: " new_session_name
  read -p "Enter new server address [$server_address]: " new_server_address
  read -p "Enter new port number [$port_number]: " new_port_number
  read -p "Enter new username [$username]: " new_username
  read -sp "Enter new password: " new_password
  echo -e "\n"

  # Replace the existing session information with the new session information
  sed -i "${session_index}s/.*/${new_session_name:-$session_name},${new_server_address:-$server_address},${new_port_number:-$port_number},${new_username:-$username},${new_password:-$password}/" "$SSH_CONFIG_FILE"
  echo "Session modified successfully!"
elif [[ "$1" == "ls" ]]; then
  get_sessions
elif [[ "$1" == "ssh" ]]; then
  tmux new-session -d -s casual
  counter=1
  for session_name in $(echo "$2" | sed "s/,/ /g"); do
    session_info=$(grep "^$session_name," "$SSH_CONFIG_FILE")
    if [[ -z "$session_info" ]]; then
      echo "Error: Session '$session_name' not found in config file '$SSH_CONFIG_FILE'"
      exit 1
    fi
    
    session_host=$(echo "$session_info" | awk -F',' '{print $2}')
    session_user=$(echo "$session_info" | awk -F',' '{print $3}')
    session_password=$(echo "$session_info" | awk -F',' '{print $4}')
    session_port=$(echo "$session_info" | awk -F',' '{print $5}')
    echo $session_info

    if [[ "$counter" == "1" ]]; then
      tmux send-keys "sshpass -p '$session_password' ssh -t -p $session_port $session_user@$session_host" C-m
    else 
      tmux split-window -h "sshpass -p '$session_password' ssh -t -p $session_port $session_user@$session_host"    
    fi
    
    counter=$((counter+1))
  done

  if [[ "$3" == "sync" ]]; then
    tmux setw synchronize-panes on
  fi

  tmux attach -t casual
fi