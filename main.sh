if [ "$1" == "Windows" ]; then
#  echo "%USERPROFILE%\.poetry\bin" >> $GITHUB_PATH
  cd ..
  cd ..
  cd ..
  cd ..
  echo "-------- outer layer ----------"
  ls -la
  cd usr
  cd bin
  echo "------- usr/bin ----------"
  ls -la
  cd ..
  cd ..
  echo "-------- outer layer ----------"
  ls -la
  cd tmp
  cd bin
  echo "------- tmp/bin -----------"
  ls -la
else
  echo "Else block"
  echo "$HOME/.poetry/bin" >> $GITHUB_PATH
  source $HOME/.poetry/env
fi