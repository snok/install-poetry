#!/usr/bin/env bash

# Download installation script to a temporary directory
installation_script="$(mktemp)"
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/48339106eb0d403a3c66519317488c8185844b32/install-poetry.py --output "$installation_script"

# Set the installation path conditional on the OS of the runner
if [ "${RUNNER_OS}" == "Windows" ]; then
    path="C:/Users/runneradmin/AppData/Roaming/Python/Scripts"
else
    path="$HOME/.local/"
fi

# Set the `path` action output, so subsequent workflow steps can use this if needed
echo "::set-output name=install-path::$path"

echo -e "\n\033[33mSetting Poetry installation path as $path\033[0m\n"
echo -e "\033[33mInstalling Poetry 👷\033[0m\n"

# Install Poetry
if [ "${VERSION}" == "latest" ]; then
    POETRY_HOME=$path python3 $installation_script --yes ${INSTALLATION_ARGUMENTS}
else
    POETRY_HOME=$path python3 $installation_script --yes --version=${VERSION} ${INSTALLATION_ARGUMENTS}
fi

# Add to $PATH. $GITHUB_PATH is used for persistence to other steps
echo "$path/bin" >>"$GITHUB_PATH"
export PATH="$path/bin:$PATH"

# Windows seems to have issues with path, so assign the executable to a variable
if [ "${RUNNER_OS}" == "Windows" ]; then
    poetry_="$path/bin/poetry.exe"
else
    poetry_=poetry
fi

# Expand any "~" in VIRTUALENVS_PATH
VIRTUALENVS_PATH="${VIRTUALENVS_PATH/#\~/$HOME}"

# Apply poetry config options from the action inputs
$poetry_ config virtualenvs.create ${VIRTUALENVS_CREATE}
$poetry_ config virtualenvs.in-project ${VIRTUALENVS_IN_PROJECT}
$poetry_ config virtualenvs.path ${VIRTUALENVS_PATH}

config="$($poetry_ config --list)"

if echo "$config" | grep -q -c "installer.parallel"; then
    $poetry_ config installer.parallel "${INSTALLER_PARALLEL}"
fi

# Define the venv path
if [ "${RUNNER_OS}" == "Windows" ]; then
    venv_activate_path=".venv/scripts/activate"
else
    venv_activate_path=".venv/bin/activate"
fi

# Add venv activate path to path
echo "VENV=$venv_activate_path" >>"$GITHUB_ENV"

echo -e "\n\033[33mInstallation completed. Configuring settings 🛠\033[0m"
echo -e "\n\033[33mDone ✅\033[0m"

if [ "${VIRTUALENVS_CREATE}" == true ] || [ "${VIRTUALENVS_CREATE}" == "true" ]; then
    echo -e "\n\033[33mIf you are creating a venv in your project, you can activate it by running 'source $venv_activate_path'. If you're running this in an OS matrix, you can use 'source \$VENV' instead, as an OS agnostic option\033[0m"
fi
if [ "${RUNNER_OS}" == "Windows" ]; then
    echo -e "\n\033[33mMake sure to set your default shell to bash when on Windows.\033[0m"
    echo -e "\n\033[33mSee the github action docs for more information and examples.\033[0m"
fi
