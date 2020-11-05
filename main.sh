if [ "$1" == "Windows" ]; then
  ln -s $HOME/.poetry/bin/poetry.bat /usr/bin/poetry
  echo ".-"
  echo "$PATH"
  poetry config virtualenvs.create "$2"
  poetry config virtualenvs.in-project "$3"
  poetry config virtualenvs.path "$4"
else
  source $HOME/.poetry/env
  poetry config virtualenvs.create "$2"
  poetry config virtualenvs.in-project "$3"
  poetry config virtualenvs.path "$4"
fi
