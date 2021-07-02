#!/bin/bash

# Give inputs sensible names
os=$1
venv_create=$2
venv_in_project=$3
venv_path=$4
version=$5
poetry_home_path=$6
installation_script=$7

# Define OS specific help text
if [ "$os" == "Windows" ]; then
  conf="\033[33mConfiguring Poetry for Windows!\033[0m"
  act="source .venv/scripts/activate"
  echo "VENV=.venv/scripts/activate" >>"$GITHUB_ENV"
else
  conf="\033[33mConfiguring Poetry!\033[0m"
  act="source .venv/bin/activate"
  echo "VENV=.venv/bin/activate" >>"$GITHUB_ENV"
fi

# Echo help texts
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

if [ -z "$poetry_home_path" ]; then
  if [ "$os" == "Windows" ]; then
    poetry_home_path="C:/Users/runneradmin/AppData/Roaming/Python/Scripts/"
  else
    poetry_home_path="$HOME/.local/"
  fi
fi

POETRY_HOME=$poetry_home_path python3 $installation_script --yes --version=$version

echo "$poetry_home_path/bin" >>$GITHUB_PATH
export PATH="$poetry_home_path/bin:$PATH"

if [ "$os" == "Windows" ]; then
  # Adding to path on windows doesn't immediately take effect
  # so calling the executable directly here - should be available
  # in next steps regardless.
  "$path/bin/poetry.exe" config virtualenvs.create "$venv_create"
  "$path/bin/poetry.exe" config virtualenvs.in-project "$venv_in_project"
  "$path/bin/poetry.exe" config virtualenvs.path "$venv_path"
else
  poetry config virtualenvs.create "$venv_create"
  poetry config virtualenvs.in-project "$venv_in_project"
  poetry config virtualenvs.path "$venv_path"
fi

