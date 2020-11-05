echo "$1"
echo -e "\n\n  ----------------------------------------------------------------------------------------------------"
if [ $1 == Windows ]; then
  echo -e '\n\nConfiguring Poetry for Windows!\n\nIf you are creating a venv in your project, you can activate it by running `source .venv/scripts/activate` 🚀\n\n'
  ln -s $HOME/.poetry/bin/poetry.bat poetry
  $HOME/.poetry/bin/poetry.bat config virtualenvs.create $2
  $HOME/.poetry/bin/poetry.bat config virtualenvs.in-project $3
  $HOME/.poetry/bin/poetry.bat config virtualenvs.path $4
else
  echo -e '\n\nConfiguring Poetry!\n\nIf you are creating a venv in your project, you can activate it by running `source .venv/bin/activate` 🚀\n\n'
  source $HOME/.poetry/env
  poetry config virtualenvs.create $2
  poetry config virtualenvs.in-project $3
  poetry config virtualenvs.path $4
fi
