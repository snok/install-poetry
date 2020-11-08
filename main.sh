# Give inputs sensible names
os=$1
venv_create=$2
venv_in_project=$3
venv_path=$4

# Define OS specific help text
if [ "$os" == "Windows" ]; then
  conf="\033[33mConfiguring Poetry for Windows!\033[0m"
  act="source .venv/scripts/activate"
  echo "VENV=.venv/scripts/activate" >> "$GITHUB_ENV"
else
  conf="\033[33mConfiguring Poetry!\033[0m"
  act="source .venv/bin/activate"
  echo "VENV=.venv/bin/activate" >> "$GITHUB_ENV"
fi

# Echo help texts
echo -e "\n\n-------------------------------------------------------------------------------\n\n$conf 🎉"
if [ $venv_create == true ] || [ "$venv_create" == "true" ]; then
  # If user is creating a venv in-project we tell them how to activate venv
  echo -e "\n\n\033[33mIf you are creating a venv in your project, you can activate it by running '$act'\033[0m"
  echo -e "\n\033[33mIf you're running this in an OS matrix, use 'source \$VENV'\033[0m"
fi
if [ "$os" == "Windows" ]; then
  # If $SHELL isn't some variation of bash, output a yellow-texted warning
  echo -e "\n\n\033[33mMake sure to set your default shell to bash when on Windows.\033[0m"
  echo -e "\n\033[33mSee the package docs for more information and examples.\033[0m"
fi
echo -e '\n-------------------------------------------------------------------------------\n'

# Configure Poetry
if [ "$os" == "Windows" ]; then
  ln -s "$HOME/.poetry/bin/poetry.bat" "poetry"
  "$HOME/.poetry/bin/poetry.bat" config virtualenvs.create "$venv_create"
  "$HOME/.poetry/bin/poetry.bat" config virtualenvs.in-project "$venv_in_project"
  "$HOME/.poetry/bin/poetry.bat" config virtualenvs.path "$venv_path"
else
  source $HOME/.poetry/env
  poetry config virtualenvs.create "$venv_create"
  poetry config virtualenvs.in-project "$venv_in_project"
  poetry config virtualenvs.path "$venv_path"
fi
