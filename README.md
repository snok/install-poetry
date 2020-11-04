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

The action is fully tested for MacOS and Ubuntu runners, on Poetry versions >= 1.1.0.

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
- name: Disables experimental installer
  run: poetry config experimental.new-installer false
```

## Real workflow examples

- [Basic testing](#testing)
- [Matrix testing](#mtesting)
- [Codecov upload](#codecov)



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
        uses: snok/install-poetry@v1.0.0
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

```yaml
name: test

on: pull_request

jobs:
  linting:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
        with:
          python-version: 3
      - uses: actions/cache@v2
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip
          restore-keys: |
            ${{ runner.os }}-pip-
            ${{ runner.os }}-
      - run: python -m pip install black flake8 isort
      - run: |
          flake8 .
          black . --check
          isort .
  test:
    needs: linting
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        python-version: [ "3.6", "3.7", "3.8", "3.9" ]
        django-version: [ "2.2", "3.0", "3.1" ]
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
        uses: snok/install-poetry@v1.0.0
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
          poetry add "Django==${{ matrix.django-version }}"
      - name: Run tests
        run: |
          source .venv/bin/activate
          poetry run pytest tests/
          poetry run coverage report
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
      uses: snok/install-poetry@v1.0.0
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

## Contributing
Contributions are always welcome; submit a PR!

## License
install-poetry is licensed under an MIT license. See the license file for details.

## Showing your support

Leave a ★ if this project helped you!