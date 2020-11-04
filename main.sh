if [ "$1" == "Windows" ]; then
  echo "$HOME/.poetry/bin" >> $GITHUB_PATH
  cd $HOME/.poetry/bin
  ./poetry config virtualenvs.create "$2"
  ./poetry config virtualenvs.in-project "$3"
  ./poetry config virtualenvs.path "$4"
else
  source $HOME/.poetry/env
  poetry config virtualenvs.create "$2"
  poetry config virtualenvs.in-project "$3"
  poetry config virtualenvs.path "$4"
fi
