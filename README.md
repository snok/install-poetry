[![release](https://img.shields.io/github/release/snok/install-poetry.svg)](https://github.com/snok/install-poetry/releases/latest)
[![tests](https://github.com/snok/install-poetry/workflows/test/badge.svg)](https://github.com/snok/install-poetry)

# Install Poetry action

A Github action for installing and configuring Poetry.

The action installs Poetry, adds executables to the runners system path, and sets relevant Poetry config settings.

> Inspired by [dschep's](https://github.com/dschep) [archived poetry action](https://github.com/dschep/install-poetry-action).

## Usage

If all you want to do is install Poetry, simply add this to your workflow:

```yaml
- uses: snok/install-poetry@v1.0.0
```

If you wish to also edit Poetry config settings, or install a specific version, you can use the `with` keyword:

```yaml
- name: Install and configure Poetry
  uses: snok/install-poetry@v1.0.0
  with:
    version: 1.1.4
    virtualenvs-create: true
    virtualenvs-in-project: false
    virtualenvs-path: .venv
```

The action is fully tested for MacOS and Ubuntu runners, on Poetry versions >= 1.1.0. If you're using this with Windows, see the [Running on Windows](#windows) section.

## Defaults

The config defaults are
```yaml
version: 1.1.4
virtualenvs-create: true
virtualenvs-in-project: false
virtualenvs-path: {cache-dir}/virtualenvs
```

If you wish to change other config settings, you can do that in a following step like this

```yaml
- run: poetry config experimental.new-installer false
```

## Real workflow examples

- [Basic testing](#testing)
- [Matrix testing](#mtesting)
- [Codecov upload](#codecov)
- [Running on Windows](#windows)
- [Other VENV creation variations](#ovcv)

<a id="testing"></a>
### Basic testing

```
name: test

on: pull_request

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      #----------------------------------------------
      #       check-out repo and set-up python     
      #----------------------------------------------
      - name: Check out repository
        uses: actions/checkout@v2
      - name: Set up python 
        uses: actions/setup-python@v2
        with:
          python-version: 3.9
      #----------------------------------------------
      #  -----  install & configure poetry  -----      
      #----------------------------------------------
      - name: Install poetry
        uses: snok/install-poetry@v1.1.0
        with:
          virtualenvs-create: true
          virtualenvs-in-project: true
      #----------------------------------------------
      #       load cached venv if cache exists      
      #----------------------------------------------
      - name: Load cached venv
        id: cached-poetry-dependencies
        uses: actions/cache@v2
        with:
          path: .venv
          key: venv-${{ runner.os }}-${{ hashFiles('**/poetry.lock') }}
      #----------------------------------------------
      # install dependencies if cache does not exist 
      #----------------------------------------------
      - name: Install dependencies
        run: poetry install
        if: steps.cached-poetry-dependencies.outputs.cache-hit != 'true'
      #----------------------------------------------
      #              run test suite   
      #----------------------------------------------
      - name: Run tests
        run: |
          source .venv/bin/activate
          poetry run pytest tests/
          poetry run coverage report
```

<a id="mtesting"></a>
### Matrix testing

This example includes a linting pre-job, which has nothing to do with the matrix
logic, but we thought might be useful for someone to see how works.

```yaml
name: test

on: pull_request

jobs:
  linting:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
      - uses: actions/cache@v2
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip
          restore-keys: ${{ runner.os }}-pip
      - run: python -m pip install black flake8 isort
      - run: |
          flake8 .
          black . --check
          isort .
  test:
    needs: linting
    strategy:
      fail-fast: true
      matrix:
        os: [ "ubuntu-latest", "macos-latest" ]
        python-version: [ "3.6", "3.7", "3.8", "3.9" ]
        django-version: [ "2.2", "3.0", "3.1" ]
    runs-on: ${{ matrix.os }}
    steps:
      #----------------------------------------------
      #       check-out repo and set-up python     
      #----------------------------------------------
      - name: Check out repository
        uses: actions/checkout@v2
      - name: Set up python ${{ matrix.python-version }}
        uses: actions/setup-python@v2
        with:
          python-version: ${{ matrix.python-version }}
      #----------------------------------------------
      #  -----  install & configure poetry  -----      
      #----------------------------------------------
      - name: Install poetry
        uses: snok/install-poetry@v1.1.0
        with:
          virtualenvs-create: true
          virtualenvs-in-project: true
      #----------------------------------------------
      #       load cached venv if cache exists      
      #----------------------------------------------
      - name: Load cached venv
        id: cached-poetry-dependencies
        uses: actions/cache@v2
        with:
          path: .venv
          key: venv-${{ runner.os }}-${{ hashFiles('**/poetry.lock') }}
      #----------------------------------------------
      # install dependencies if cache does not exist 
      #----------------------------------------------
      - name: Install dependencies
        run: poetry install
        if: steps.cached-poetry-dependencies.outputs.cache-hit != 'true'
      #----------------------------------------------
      #    add matrix specifics and run test suite   
      #----------------------------------------------
      - name: Install django ${{ matrix.django-version }}
        run: |
          source .venv/bin/activate
          pip install "Django==${{ matrix.django-version }}"
      - name: Run tests
        run: |
          source .venv/bin/activate
          pytest tests/
          coverage report
```

<a id="codecov"></a>
### Codecov upload

```yaml
name: coverage

on:
  push:
    branches:
      - master

jobs:
  codecov:
    runs-on: ubuntu-latest
    steps:
      #----------------------------------------------
      #       check-out repo and set-up python     
      #----------------------------------------------
    - uses: actions/checkout@v2
    - uses: actions/setup-python@v2
      with:
        python-version: 3.9
      #----------------------------------------------
      #  -----  install & configure poetry  -----      
      #----------------------------------------------
    - name: Install poetry
      uses: snok/install-poetry@v1.1.0
      with:
        virtualenvs-create: true
        virtualenvs-in-project: true
      #----------------------------------------------
      #       load cached venv if cache exists      
      #----------------------------------------------
    - name: Load cached venv
      id: cached-poetry-dependencies
      uses: actions/cache@v2
      with:
        path: .venv
        key: venv-${{ runner.os }}-${{ hashFiles('**/poetry.lock') }}
      #----------------------------------------------
      # install dependencies if cache does not exist 
      #----------------------------------------------
    - name: Install dependencies
      run: poetry install
      if: steps.cached-poetry-dependencies.outputs.cache-hit != 'true'
      #----------------------------------------------
      #    run test suite and output coverage file   
      #----------------------------------------------
    - name: Test with pytest
      run: poetry run pytest --cov=<project-dir> --cov-report=xml
      #----------------------------------------------
      #             upload coverage stats              
      # (requires CODECOV_TOKEN in repository secrets)   
      #----------------------------------------------
    - name: Upload coverage
      uses: codecov/codecov-action@v1
      with:
        file: ./coverage.xml
        fail_ci_if_error: true
```

<a id="windows"></a>
### Running on Windows

Running this action on Windows will work, but two things are important to note:

1. You need to set the default shell to bash
    
    ```yaml
    defaults:
      run:
        shell: bash
    ```
2. If you are running an OS matrix, and want to activate your venv in-project, you *can* do this

   ```yaml
   - run: |
       source .venv/bin/activate
       pytest --version
     if: runner.os != 'Windows'
   - run: |
       source .venv/scripts/activate
       pytest --version
     if: runner.os == 'Windows'
   ```
   
   but we recommend you do this
   
   ```yaml
   - run: |
       source $VENV
       pytest --version
   ```
   
   the $VENV environment variable is set by us, and will point to the OS-specific
   in-project default path 
   (`.venv/bin/activate` on UNIX and `.venv/scripts/activate` on Windows).

Full Windows workflow:
   
```yaml
name: test

on: pull_request

jobs: 
  test-windows:
    needs: set-env
    strategy:
      matrix: [ubuntu-latest, macos-latest, windows-latest]
    # 1. Set default shell
    defaults:
      run:
        shell: bash
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v2
      - name: Install poetry
        uses: snok/install-poetry@v1.1.0
        with:
          virtualenvs-create: true
          virtualenvs-in-project: true
      - uses: actions/setup-python@v2
      - run: poetry install
      # 2. Use $VENV environment variable 
      # to remove the need for conditional blocks and duplicate code
      - run: | 
          source $VENV
          pytest --version
```

<a id="ovcv"></a>
### Other VENV creation variations

All of the examples listed above use

```yaml
- name: Install poetry
  uses: snok/install-poetry@v1.1.0
  with:
    virtualenvs-create: true
    virtualenvs-in-project: true
```

which might not suit your workflow. 

There are two other options you can use:

1. Creating your VENV, but not in the project dir

    If you're using the default settings, the venv location changes 
    from `.venv` to using `{cache-dir}/virtualenvs`.
    
    This directory will change depending on the OS, making it a little harder
    to write OS agnostic instructions, but you can bypass this issue completely
    by taking advantage of the built-in `poetry run` command.
    
    Using the last two steps in the [Matrix testing](#mtesting) example as a starting point
    
    ```yaml
    - name: Install django ${{ matrix.django-version }}
      run: |
        source .venv/bin/activate
        pip install "Django==${{ matrix.django-version }}"
    - name: Run tests
      run: |
        source .venv/bin/activate
        pytest tests/
        coverage report
    ```
   
   these steps activate the VENV, then operate inside that environment.
   
   With a remote VENV you could do something like this instead
   
    ```yaml
    - name: Install django ${{ matrix.django-version }}
      run: poetry add "Django==${{ matrix.django-version }}"
    - name: Run tests
      run: |
        poetry run pytest tests/
        poetry run coverage report
    ```
   
   We have never tested caching of a remote VENV in Github Actions, but if you
   have, feel free to submit a PR explaining how.

2. Skipping VENV creation

    If you want to skip venv creation, you *can* use the other examples, by 
    ignoring the VENV activation lines.
    
    For caching, you will want to do something similar to the linting job 
    in the [Matrix testing](#mtesting) example,
    where we're caching pip wheels instead of the VENV. This won't cache installed dependencies; just the installables, which
    will still save you a lot of time and reduce the strain on PyPi.

## Contributing
Contributions are always welcome; submit a PR!

## License
install-poetry is licensed under an MIT license. See the license file for details.

## Showing your support

Leave a ★ if this project helped you!