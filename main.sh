if [ "$1" == "Windows" ]; then
  echo "Windows block"
  echo "%USERPROFILE%\.poetry\bin" >> $GITHUB_PATH
  cd "%USERPROFILE%"
  ls -la
  echo "------------------"
  cd "$2"
  ls -la
else
  echo "Else block"
  echo "$HOME/.poetry/bin" >> $GITHUB_PATH
  source $HOME/.poetry/env
fi