#!/usr/bin/env bash

installation_script="$(mktemp)"
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/48339106eb0d403a3c66519317488c8185844b32/install-poetry.py --output "$installation_script"

if [ "${{ runner.os }}" == "Windows" ]; then
    path="C:/Users/runneradmin/AppData/Roaming/Python/Scripts"
else
    path="$HOME/.local/"
fi

echo -e "\n\033[33mSetting Poetry installation path as $path\033[0m\n"
echo -e "\033[33mInstalling Poetry 👷\033[0m\n"

if [ "${{ inputs.version }}" == "latest" ]; then
    POETRY_HOME=$path python3 $installation_script --yes ${{ inputs.installation-arguments}}
else
    POETRY_HOME=$path python3 $installation_script --yes --version=${{ inputs.version }} ${{ inputs.installation-arguments}}
fi

echo "$path/bin" >>$GITHUB_PATH
export PATH="$path/bin:$PATH"

if [ "${{ runner.os }}" == "Windows" ]; then
    poetry_="$path/bin/poetry.exe"
else
    poetry_=poetry
fi

$poetry_ config virtualenvs.create ${{ inputs.virtualenvs-create }}
$poetry_ config virtualenvs.in-project ${{ inputs.virtualenvs-in-project }}
$poetry_ config virtualenvs.path ${{ inputs.virtualenvs-path }}

config="$($poetry_ config --list)"

if echo "$config" | grep -q -c "installer.parallel"; then
    $poetry_ config installer.parallel "${{ inputs.installer-parallel }}"
fi

if [ "${{ runner.os }}" == "Windows" ]; then
    act="source .venv/scripts/activate"
    echo "VENV=.venv/scripts/activate" >>"$GITHUB_ENV"
else
    act="source .venv/bin/activate"
    echo "VENV=.venv/bin/activate" >>"$GITHUB_ENV"
fi

echo -e "\n\033[33mInstallation completed. Configuring settings 🛠\033[0m"
echo -e "\n\033[33mDone ✅\033[0m"

if [ "${{ inputs.virtualenvs-create }}" == true ] || [ "${{ inputs.virtualenvs-create }}" == "true" ]; then
    echo -e "\n\033[33mIf you are creating a venv in your project, you can activate it by running '$act'. If you're running this in an OS matrix, you can use 'source \$VENV' instead, as an OS agnostic option\033[0m"
fi
if [ "${{ runner.os }}" == "Windows" ]; then
    echo -e "\n\033[33mMake sure to set your default shell to bash when on Windows.\033[0m"
    echo -e "\n\033[33mSee the github action docs for more information and examples.\033[0m"
fi
