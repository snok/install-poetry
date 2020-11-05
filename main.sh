# Define OS specific help text
if [ "$1" == "Windows" ]; then
  conf="Configuring Poetry for Windows!"
  act="source .venv/scripts/activate"
  echo "VENV=.venv/scripts/activate" >> $GITHUB_ENV
else
  conf="Configuring Poetry!"
  act="source .venv/bin/activate"
  echo "VENV=.venv/bin/activate" >> $GITHUB_ENV
fi

# Echo help texts
echo -e "\n\n-------------------------------------------------------------------------------\n\n\033[33$conf\033[0m 🎉"
if [ $2 == true ] || [ "$2" == "true" ]; then
  # If user is creating a venv in-project we tell them how to activate venv
  echo -e "\n\nIf you are creating a venv in your project, you can activate it by running '${act}'\033[0m"
  echo -e "\n\nIf you're running this in an OS matrix, an even better option is to use 'source \$VENV'\033[0m"
fi
if [ "$1" == "Windows" ]; then
  # If $SHELL isn't some variation of bash, output a yellow-texted warning
  echo -e "\n\n\033[33mMake sure to set your default shell to bash when on Windows.\033[0m"
  echo -e "\n\033[33mSee the package docs for more information and examples.\033[0m"
fi
echo -e '\n-------------------------------------------------------------------------------\n'

# Configure Poetry
if [ "$1" == "Windows" ]; then
  ln -s "$HOME/.poetry/bin/poetry.bat" "poetry"
  "$HOME/.poetry/bin/poetry.bat" config virtualenvs.create "$2"
  "$HOME/.poetry/bin/poetry.bat" config virtualenvs.in-project "$3"
  "$HOME/.poetry/bin/poetry.bat" config virtualenvs.path "$4"
else
  source $HOME/.poetry/env
  poetry config virtualenvs.create "$2"
  poetry config virtualenvs.in-project "$3"
  poetry config virtualenvs.path "$4"
fi
