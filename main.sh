operating_system=$1
echo "$operating_system"
if [ "$1" == "Windows" ]; then
  echo "Windows block"
  echo "%USERPROFILE%\.poetry\bin"
  cd "%USERPROFILE%\.poetry\lib"
else
  echo "Else block"
  echo "$HOME/.poetry/bin" >> $GITHUB_PATH
  source $HOME/.poetry/env
fi