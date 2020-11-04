operating_system=$1
echo "$operating_system"
if [[ operating_system == 'Windows' ]]; then
  echo "%USERPROFILE%\.poetry\bin"
  cd "%USERPROFILE%\.poetry\lib"
else
  echo "$HOME/.poetry/bin" >> $GITHUB_PATH
  source $HOME/.poetry/env
fi