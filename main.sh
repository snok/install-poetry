if [ "$1" == "Windows" ]; then
  pip install poetry
else
  echo "$HOME/.poetry/bin" >> $GITHUB_PATH
  source $HOME/.poetry/env
fi