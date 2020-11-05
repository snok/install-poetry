if [ "$1" == "Windows" ]; then
  ln -s $HOME/.poetry/bin/poetry.bat poetry
else
  source $HOME/.poetry/env
fi
