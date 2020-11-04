if [ "$1" == "Windows" ]; then
#  echo "%USERPROFILE%\.poetry\bin" >> $GITHUB_PATH
  python -c 'import os; print(os.getenv("USERPROFILE", ""))'
else
  echo "Else block"
  echo "$HOME/.poetry/bin" >> $GITHUB_PATH
  source $HOME/.poetry/env
fi