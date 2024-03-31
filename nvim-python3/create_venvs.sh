#!/bin/bash

# Loop through all directories under /root/workspace
for project_dir in /root/workspace/*; do
  # Check if the item is a directory
  if [ -d "$project_dir" ]; then
    # Form the path where the virtual environment should exist
    venv_path="$project_dir/venv"
    
    # Check if the virtual environment exists; if not, create one
    if [ ! -d "$venv_path" ]; then
      echo "Creating virtual environment for $project_dir"
      python3 -m venv "$venv_path"
    else
      echo "Virtual environment already exists for $project_dir"
    fi
  fi
done

