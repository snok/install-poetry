# Help texts
if [ "$1" == "Windows" ]; then
  conf='Configuring Poetry for Windows!'
  act='source .venv/scripts/activate'
else
  conf='Configuring Poetry!'
  act='source .venv/bin/activate'
fi
echo -e "\n\n----------------------------------------------------------------------------------------------------\n\n$conf"
if [ $2 == true ] || [ "$2" == "true" ]; then
    echo -e "\n\nIf you are creating a venv in your project, you can activate it by running `$act` 🚀"
fi
echo -e '\n\n----------------------------------------------------------------------------------------------------\n'

# Poetry configuration
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
