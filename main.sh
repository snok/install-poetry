if [ "$1" == "Windows" ]; then
  echo "$HOME/.poetry/bin" >> $GITHUB_PATH
  cd $HOME/.poetry/lib/poetry
  ls -la
  poetry
else
  source $HOME/.poetry/env
fi
poetry config virtualenvs.create "$2"
poetry config virtualenvs.in-project "$3"
poetry config virtualenvs.path "$4"
