[![release](https://img.shields.io/github/release/snok/install-poetry.svg)](https://github.com/snok/install-poetry/releases/latest)
[![tests](https://github.com/snok/install-poetry/workflows/test/badge.svg)](https://github.com/snok/install-poetry)

# Install Poetry action

A Github action for installing and configuring Poetry.

The action installs Poetry, adds executables to the runners system path, and sets relevant Poetry config settings.

> Inspired by [dschep's](https://github.com/dschep) [archived poetry action](https://github.com/dschep/install-poetry-action).

## Usage

If all you need is default Poetry, simply add this to your workflow:

```yaml
- name: Install Poetry
  uses: snok/install-poetry@v1.1.0
```

If you want to set Poetry config settings, or install a specific version, you can specify these as inputs:

```yaml
- name: Install and configure Poetry
  uses: snok/install-poetry@v1.1.0
  with:
    version: 1.1.4
    virtualenvs-create: true
    virtualenvs-in-project: false
    virtualenvs-path: ~/my-custom-path
```

The action is fully tested for MacOS and Ubuntu runners, on Poetry versions >= 1.1.0. 

If you're using this with Windows, see the [Running on Windows](#windows) section.

## Defaults

The config defaults are
```yaml
version: 1.1.4
virtualenvs-create: true
virtualenvs-in-project: false
virtualenvs-path: {cache-dir}/virtualenvs
```

If you want to access one of the experimental config settings or make changes to the Poetry
config *after* invoking this action, you can do that in a separate step like this:

```yaml
- uses: snok/install-poetry@v1.1.0
- run: poetry config experimental.new-installer false
```

## Real workflows and tips

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
      - name: Install Poetry
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
          pytest tests/
          coverage report
```

<a id="mtesting"></a>
### Matrix testing

This example includes a linting job, which has nothing to do with the matrix
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
      - name: Install Poetry
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
    - name: Install Poetry
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
   
   but we recommend using the $VENV environment variable
   
   ```yaml
   - run: |
       source $VENV
       pytest --version
   ```
   
   the $VENV environment variable is set by us, and will point to the OS-specific
   in-project default path 
   (`.venv/bin/activate` on UNIX and `.venv/scripts/activate` on Windows). 
   This eliminates the need for duplicate conditional code. 

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
      - name: Install Poetry
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

All of the examples listed above use these settings

```yaml
- name: Install Poetry
  uses: snok/install-poetry@v1.1.0
  with:
    virtualenvs-create: true
    virtualenvs-in-project: true
```

While this should work for most, there might be valid reasons for wanting 
different `virtualenvs` settings.

In general there are two other combinations:

1. Creating a VENV, but not in the project dir

    If you're using the default settings, the venv location changes 
    from `.venv` to using `{cache-dir}/virtualenvs`. You can also
    change the path to whatever you'd like.
    
    If you're using the default, this directory will be different depending 
    on the OS, making it a little harder to write OS agnostic workflows. However,
    it is possible to bypass this issue completely by taking advantage of `poetry run`.
    
    Using the last two steps in the [Matrix testing](#mtesting) example as a 
    starting point, this is how we would install a matrix-specific dependency
    and run our test suite:
    
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
   
   With a remote VENV you can bypass the VENV activation and 
   do something like this instead:
   
    ```yaml
    - name: Install django ${{ matrix.django-version }}
      run: poetry add "Django==${{ matrix.django-version }}"
    - name: Run tests
      run: |
        poetry run pytest tests/
        poetry run coverage report
    ```
   
   > We have never needed to cache remote VENVs in our Github Actions, but if 
   you have, please feel free to submit a PR explaining how it's done.

2. Skipping VENV creation

    If you want to skip VENV creation, all the original examples are valid if 
    you simply remove the VENV activation logic:
    
    ```yaml
    source .venv/bin/activate
    ```
     
    If you want to cache your dependencies, you will want to set up something
    resembling the the linting job caching step in the [Matrix testing](#mtesting) 
    example. In this case, you should cache the pip wheels instead of the VENV, 
    meaning you won't cache installed dependencies; just the installables. 
    This is still worth doing, as it still saves you a fair bit
    of time for each run, and it reduces the strain on PyPi.

## Contributing
Contributions are always welcome; submit a PR!

## License
install-poetry is licensed under an MIT license. See the license file for details.

## Showing your support

Leave a ★ if this project helped you!