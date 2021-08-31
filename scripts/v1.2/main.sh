#!/bin/bash

# Give inputs sensible names
os=$1
venv_create=$2
venv_in_project=$3
venv_path=$4
installer_parallel=$5
version=$6
installation_script=$7

# Set path for each OS - done because Poetry inference is inconsistent
# on mac-runners, and we need to know the install path so we can add it to $GITHUB_PATH
if [ "$os" == "Windows" ]; then
  path="C:/Users/runneradmin/AppData/Roaming/Python/Scripts/"
else
  path="$HOME/.local/"
fi

# Install Poetry
POETRY_HOME=$path python3 $installation_script --yes --version=$version

# Add to path
echo "$path/bin" >>$GITHUB_PATH
export PATH="$path/bin:$PATH"

# Configure Poetry
if [ "$os" == "Windows" ]; then
  # Adding to path on windows doesn't immediately take effect
  # so calling the executable directly here - should be available
  # in next steps regardless.
  "$path/bin/poetry.exe" config virtualenvs.create "$venv_create"
  "$path/bin/poetry.exe" config virtualenvs.in-project "$venv_in_project"
  "$path/bin/poetry.exe" config virtualenvs.path "$venv_path"
  "$path/bin/poetry.exe" config installer.parallel "$installer_parallel"
else
  poetry config virtualenvs.create "$venv_create"
  poetry config virtualenvs.in-project "$venv_in_project"
  poetry config virtualenvs.path "$venv_path"
  poetry config installer.parallel "$installer_parallel"
fi

# Define OS specific help texts
if [ "$os" == "Windows" ]; then
  conf="\033[33mConfiguring Poetry for Windows!\033[0m"
  act="source .venv/scripts/activate"
  echo "VENV=.venv/scripts/activate" >>"$GITHUB_ENV"
else
  conf="\033[33mConfiguring Poetry!\033[0m"
  act="source .venv/bin/activate"
  echo "VENV=.venv/bin/activate" >>"$GITHUB_ENV"
fi

# Output help texts
echo -e "\n\n-------------------------------------------------------------------------------\n\n$conf 🎉"
if [ "$venv_create" == true ] || [ "$venv_create" == "true" ]; then
  # If user is creating a venv in-project we tell them how to activate venv
  echo -e "\n\n\033[33mIf you are creating a venv in your project, you can activate it by running '$act'\033[0m"
  echo -e "\n\033[33mIf you're running this in an OS matrix, use 'source \$VENV'\033[0m"
fi
if [ "$os" == "Windows" ]; then
  # If $SHELL isn't some variation of bash, output a yellow-texted warning
  echo -e "\n\n\033[33mMake sure to set your default shell to bash when on Windows.\033[0m"
  echo -e "\n\033[33mSee the github action docs for more information and examples.\033[0m"
fi
echo -e '\n-------------------------------------------------------------------------------\n'
