if [ "$1" == "Windows" ]; then
#  echo "%USERPROFILE%\.poetry\bin" >> $GITHUB_PATH
  cd ..
  ls -la
  echo "------------------"
  cd ..
  ls -la
  echo "------------------"
  cd ..
  ls -la
  echo "------------------"
  cd ..
  ls -la
  echo "-------- outer layer ----------"
  cd usr
  ls -la
  echo "------------------"
  cd ..
  ls -la
  echo "-------- outer layer ----------"
  cd tmp
  ls -la
  echo "------------------"
  cd ..
  ls -la
  echo "-------- outer layer ----------"
else
  echo "Else block"
  echo "$HOME/.poetry/bin" >> $GITHUB_PATH
  source $HOME/.poetry/env
fi