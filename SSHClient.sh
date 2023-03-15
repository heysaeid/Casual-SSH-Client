#!/bin/bash

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
