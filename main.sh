#!/usr/bin/env bash

installation_script="$(mktemp)"
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/48339106eb0d403a3c66519317488c8185844b32/install-poetry.py --output "$installation_script"

if [ "${RUNNER_OS}" == "Windows" ]; then
    path="C:/Users/runneradmin/AppData/Roaming/Python/Scripts"
else
    path="$HOME/.local/"
fi

echo -e "\n\033[33mSetting Poetry installation path as $path\033[0m\n"
echo -e "\033[33mInstalling Poetry 👷\033[0m\n"

if [ "${VERSION}" == "latest" ]; then
    POETRY_HOME=$path python3 $installation_script --yes ${INSTALLATION_ARGUMENTS}
else
    POETRY_HOME=$path python3 $installation_script --yes --version=${VERSION} ${INSTALLATION_ARGUMENTS}
fi

echo "$path/bin" >>"$GITHUB_PATH"
export PATH="$path/bin:$PATH"

if [ "${RUNNER_OS}" == "Windows" ]; then
    poetry_="$path/bin/poetry.exe"
else
    poetry_=poetry
fi

# Expand any "~" in VIRTUALENVS_PATH
VIRTUALENVS_PATH="${VIRTUALENVS_PATH/#\~/$HOME}"

$poetry_ config virtualenvs.create ${VIRTUALENVS_CREATE}
$poetry_ config virtualenvs.in-project ${VIRTUALENVS_IN_PROJECT}
$poetry_ config virtualenvs.path ${VIRTUALENVS_PATH}

# Parse plugin array from comma- or whitespace-delimited string
read -r -a plugins <<< "$(echo "$POETRY_PLUGINS" | tr "," " ")"
if [ ${#plugins[@]} -gt 0 ]; then

    # Ensure poetry version >= 1.2
    # Simplistic version comparison, will need to be updated if Poetry 2.X is released
    major=${VERSION:0:1}
    minor=${VERSION:2:1}
    if [ $major -lt 1 ] || [ $minor -lt 2 ]; then
        echo "Use of plugins requires Poetry version >= 1.2"
        exit 1
    fi

    # Install plugins
    for plugin in "${plugins[@]}"
    do
        echo "Installing plugin: $plugin"
        $poetry_ plugin add "$plugin"
    done 
fi

config="$($poetry_ config --list)"

if echo "$config" | grep -q -c "installer.parallel"; then
    $poetry_ config installer.parallel "${INSTALLER_PARALLEL}"
fi

if [ "${RUNNER_OS}" == "Windows" ]; then
    act="source .venv/scripts/activate"
    echo "VENV=.venv/scripts/activate" >>"$GITHUB_ENV"
else
    act="source .venv/bin/activate"
    echo "VENV=.venv/bin/activate" >>"$GITHUB_ENV"
fi

echo -e "\n\033[33mInstallation completed. Configuring settings 🛠\033[0m"
echo -e "\n\033[33mDone ✅\033[0m"

if [ "${VIRTUALENVS_CREATE}" == true ] || [ "${VIRTUALENVS_CREATE}" == "true" ]; then
    echo -e "\n\033[33mIf you are creating a venv in your project, you can activate it by running '$act'. If you're running this in an OS matrix, you can use 'source \$VENV' instead, as an OS agnostic option\033[0m"
fi
if [ "${RUNNER_OS}" == "Windows" ]; then
    echo -e "\n\033[33mMake sure to set your default shell to bash when on Windows.\033[0m"
    echo -e "\n\033[33mSee the github action docs for more information and examples.\033[0m"
fi
