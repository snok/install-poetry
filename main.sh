if [ "$1" == "Windows" ]; then
a
  printenv
  echo "--------------"
  echo "poetry=$HOME/.poetry/bin/poetry" >> $GITHUB_ENV
  printenv
  ls -la
  ./poetry.bat
  ./poetry config virtualenvs.create "$2"
  ./poetry config virtualenvs.in-project "$3"
  ./poetry config virtualenvs.path "$4"
else
  source $HOME/.poetry/env
  poetry config virtualenvs.create "$2"
  poetry config virtualenvs.in-project "$3"
  poetry config virtualenvs.path "$4"
fi
