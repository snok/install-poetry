if [ "$1" == "Windows" ]; then
  echo "$HOME/.poetry/bin" >> $GITHUB_PATH
  cd $HOME/.poetry
  ls -la
  cd lib
  ls -la
else
  source $HOME/.poetry/env
fi