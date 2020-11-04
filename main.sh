if [ "$1" == "Windows" ]; then
  $HOME/.poetry/bin/poetry.bat config virtualenvs.create "$2"
  $HOME/.poetry/bin/poetry.bat config virtualenvs.in-project "$3"
  $HOME/.poetry/bin/poetry.bat config virtualenvs.path "$4"
else
  source $HOME/.poetry/env
  poetry config virtualenvs.create "$2"
  poetry config virtualenvs.in-project "$3"
  poetry config virtualenvs.path "$4"
fi
