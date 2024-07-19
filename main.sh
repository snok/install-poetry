#!/usr/bin/env bash

set -eo pipefail

download_script() {
    python -c 'import urllib.request, sys; print(urllib.request.urlopen(f"{sys.argv[1]}").read().decode("utf8"))' $1
}

INSTALL_PATH="${POETRY_HOME:-$HOME/.local}"

YELLOW="\033[33m"
RESET="\033[0m"

INSTALLATION_SCRIPT="$(mktemp)"

if [ "${RUNNER_OS}" == "Windows" ]; then
  download_script https://raw.githubusercontent.com/python-poetry/poetry/48339106eb0d403a3c66519317488c8185844b32/install-poetry.py > "$INSTALLATION_SCRIPT"
else
  download_script https://install.python-poetry.org/ > "$INSTALLATION_SCRIPT"
fi

echo -e "\n${YELLOW}Setting Poetry installation path as $INSTALL_PATH${RESET}\n"
echo -e "${YELLOW}Installing Poetry 👷${RESET}\n"

if [ "$VERSION" == "latest" ]; then
  # Note: If we quote installation arguments, the call below fails
  # shellcheck disable=SC2086
  POETRY_HOME=$INSTALL_PATH python3 "$INSTALLATION_SCRIPT" --yes $INSTALLATION_ARGUMENTS
else
  # shellcheck disable=SC2086
  POETRY_HOME=$INSTALL_PATH python3 "$INSTALLATION_SCRIPT" --yes --version="$VERSION" $INSTALLATION_ARGUMENTS
fi

echo "$INSTALL_PATH/bin" >>"$GITHUB_PATH"
export PATH="$INSTALL_PATH/bin:$PATH"

# Expand any "~" in VIRTUALENVS_PATH
VIRTUALENVS_PATH="${VIRTUALENVS_PATH/#\~/$HOME}"

poetry config virtualenvs.create "$VIRTUALENVS_CREATE"
poetry config virtualenvs.in-project "$VIRTUALENVS_IN_PROJECT"
poetry config virtualenvs.path "$VIRTUALENVS_PATH"

config="$(poetry config --list)"

if echo "$config" | grep -q -c "installer.parallel"; then
  poetry config installer.parallel "$INSTALLER_PARALLEL"
fi

if [ "$RUNNER_OS" == "Windows" ]; then
  # When inside a virtualenv, python uses the scripts dir, with no shortcut
  act="source .venv/scripts/activate"
  echo "VENV=.venv/scripts/activate" >>"$GITHUB_ENV"
else
  act="source .venv/bin/activate"
  echo "VENV=.venv/bin/activate" >>"$GITHUB_ENV"
fi

echo -e "\n${YELLOW}Installation completed. Configuring settings 🛠${RESET}"
echo -e "\n${YELLOW}Done ✅${RESET}"

if [ "$VIRTUALENVS_CREATE" == true ] || [ "$VIRTUALENVS_CREATE" == "true" ]; then
  echo -e "\n${YELLOW}If you are creating a venv in your project, you can activate it by running '$act'. If you're running this in an OS matrix, you can use 'source \$VENV' instead, as an OS agnostic option${RESET}"
fi
if [ "$RUNNER_OS" == "Windows" ]; then
  echo -e "\n${YELLOW}Make sure to set your default shell to bash when on Windows.${RESET}"
  echo -e "\n${YELLOW}See the github action docs for more information and examples.${RESET}"
fi
