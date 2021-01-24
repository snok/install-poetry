[![release](https://img.shields.io/github/release/snok/install-poetry.svg)](https://github.com/snok/install-poetry/releases/latest)
[![tests](https://github.com/snok/install-poetry/workflows/test/badge.svg)](https://github.com/snok/install-poetry)

# Install Poetry Action

A Github action for installing and configuring Poetry.

The action installs Poetry, adds executables to the runners system path, and sets relevant Poetry config settings.

> Inspired by [dschep's](https://github.com/dschep) [archived poetry action](https://github.com/dschep/install-poetry-action).

## Usage

If all you need is default Poetry, simply add this to your workflow:

```yaml
- name: Install Poetry
  uses: snok/install-poetry@v1.1.1
```

If you want to set Poetry config settings, or install a specific version, you can specify inputs

```yaml
- name: Install and configure Poetry
  uses: snok/install-poetry@v1.1.1
  with:
    version: 1.1.4
    virtualenvs-create: true
    virtualenvs-in-project: false
    virtualenvs-path: ~/my-custom-path
```

The action is fully tested for MacOS and Ubuntu runners, on Poetry versions >= 1.1.0. 

If you're using this with Windows, see the [Running on Windows](#windows) section.

## Defaults

The config default settings are
```yaml
version: 1.1.4
virtualenvs-create: true
virtualenvs-in-project: false
virtualenvs-path: {cache-dir}/virtualenvs
```

If you want to make further config changes - to change one of the `experimental` Poetry config settings, 
or just to make changes to the Poetry config *after* invoking the action -
you can do so in a subsequent step, like this

```yaml
- uses: snok/install-poetry@v1.1.1
- run: poetry config experimental.new-installer false
```

## Workflows and tips

This section contains a collection of workflow examples to help

- Give you a starting point for setting up your own workflow,
- Demonstrate how to implement caching for performance improvements
- Clarify the implications of different settings

Some of the examples are a bit long, so here are some links

- [Testing](#testing)
- [Testing (using matrix)](#mtesting)
- [Codecov upload](#codecov)
- [Running on Windows](#windows)
- [Virtualenv variations](#ovcv)

<a id="testing"></a>
#### Testing

A basic example workflow for running your test-suite can be structured like this.

```yaml
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
        uses: snok/install-poetry@v1.1.1
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
        if: steps.cached-poetry-dependencies.outputs.cache-hit != 'true'
        run: poetry install --no-interaction --no-root
      #----------------------------------------------
      # install your root project, if required 
      #----------------------------------------------      
      - name: Install library
        run: poetry install --no-interaction
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
#### Testing using a matrix

A more extensive example for running your test-suite on combinations of multiple 
operating systems, python versions, or package-versions, can be structured like this.

*The linting job has nothing to do with the matrix, and is only included 
for inspiration.*

```yaml
name: test

on: pull_request

jobs:
  linting:
    runs-on: ubuntu-latest
    steps:
      #----------------------------------------------
      #       check-out repo and set-up python     
      #----------------------------------------------
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
      #----------------------------------------------
      #        load pip cache if cache exists      
      #----------------------------------------------
      - uses: actions/cache@v2
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip
          restore-keys: ${{ runner.os }}-pip
      #----------------------------------------------
      #          install and run linters      
      #----------------------------------------------
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
        uses: snok/install-poetry@v1.1.1
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
        if: steps.cached-poetry-dependencies.outputs.cache-hit != 'true'
        run: poetry install --no-interaction --no-root
      #----------------------------------------------
      # install your root project, if required 
      #----------------------------------------------      
      - name: Install library
        run: poetry install --no-interaction
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
#### Codecov upload

This section contains a simple codecov upload. See the 
[codecov action](https://github.com/codecov/codecov-action) for more information.

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
      uses: snok/install-poetry@v1.1.1
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
        if: steps.cached-poetry-dependencies.outputs.cache-hit != 'true'
        run: poetry install --no-interaction --no-root
      #----------------------------------------------
      # install your root project, if required 
      #----------------------------------------------      
      - name: Install library
        run: poetry install --no-interaction
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
#### Running on Windows

Running this action on Windows is supported, but two things are important to note:

1. You need to set the job-level default shell to `bash`
    
    ```yaml
    defaults:
      run:
        shell: bash
    ```
2. If you are running an OS matrix, and want to activate your venv `in-project` 
you have to deal with different folder structures on different operating systems.
To make this work, you *can* do this

   ```yaml
   - run: |
       source .venv/scripts/activate
       pytest --version
     if: runner.os == 'Windows'
   - run: |
       source .venv/bin/activate
       pytest --version
     if: runner.os != 'Windows'
   ```
   
   but we think this is an annoying way to have to structure our workflows,
   so we set a custom environment variable, `$VENV` which will point to the 
   OS-specific venv activation script, whether you're running UNIX or Windows.
   This means you can do this instead
   
   ```yaml
   - run: |
       source $VENV
       pytest --version
   ```

For context, a full os-matrix using `windows-latest` could be set up like this:
   
```yaml
name: test

on: pull_request

jobs: 
  test-windows:
    strategy:
      matrix: [ "ubuntu-latest", "macos-latest", "windows-latest" ]
    defaults:
      run:
        shell: bash
    runs-on: ${{ matrix.os }}
    steps:
      - name: Check out repository
        uses: actions/checkout@v2
      - name: Set up python 
        uses: actions/setup-python@v2
        with:
          python-version: 3.9
      - name: Install Poetry
        uses: snok/install-poetry@v1.1.1
        with:
          virtualenvs-create: true
          virtualenvs-in-project: true
      - name: Load cached venv
        id: cached-poetry-dependencies
        uses: actions/cache@v2
        with:
          path: .venv
          key: venv-${{ runner.os }}-${{ hashFiles('**/poetry.lock') }}
      - name: Install dependencies
        run: poetry install --no-interaction --no-root
        if: steps.cached-poetry-dependencies.outputs.cache-hit != 'true'
      - name: Install library
        run: poetry install --no-interaction
      - run: | 
          source $VENV
          pytest --version
```

##### Caching on Windows runners

For some reason, caching your `venv` does not seem to work as expected on Windows runners. You can see an
example of what happens [here](https://github.com/snok/install-poetry/actions/runs/507576956), where a 
workflow stalls and runs for over 3 hours before it was manually cancelled.

If you do want to cache your dependencies on a Windows runner, you should look
into caching your pip wheels instead of your venv; this seems to work fine.

<a id="ovcv"></a>
#### Virtualenv variations

All of the examples we've added use these Poetry settings

```yaml
- name: Install Poetry
  uses: snok/install-poetry@v1.1.1
  with:
    virtualenvs-create: true
    virtualenvs-in-project: true
```

While this should work for most, and we generally prefer creating our 
`virtualenvs` in-project to make the caching step as simple as possible, 
there are valid reasons for not wanting to construct a venv in your project directory. 

There are two other relevant scenarios:

1. Creating a venv, but not in the project dir
    
    If you're using the default settings, the venv location changes 
    from `.venv` to using `{cache-dir}/virtualenvs`. You can also
    change the path to whatever you'd like. Generally though, this can make
    things a little tricky, because the directory will be vary depending 
    on the OS, making it harder to write OS agnostic workflows. 

    A solution to this is to bypass this issue completely by taking advantage of
    Poetry's `poetry run` command.
     
    Using the last two steps in the [Matrix testing](#mtesting) example as an 
    example, this is how we have otherwise documented installing a 
    matrix-specific dependency and running the test suite:
    
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
   
   With a remote venv you can do this instead:
   
    ```yaml
    - name: Install django ${{ matrix.django-version }}
      run: poetry add "Django==${{ matrix.django-version }}"
    - name: Run tests
      run: |
        poetry run pytest tests/
        poetry run coverage report
    ```
   
   > We have never needed to cache remote VENVs in our Github Actions, but if 
   you've done this, please feel free to submit a PR explaining how it's done.

2. Skipping venv creation

    If you want to skip venv creation, all the original examples are made valid 
    by simply removing the venv activation line: `source .venv/bin/activate`.
    
    To enable caching in this case, you will want to set up something resembling 
    the the linting job caching step in the [Matrix testing](#mtesting); caching 
    your pip wheels rather than your installed dependencies.
    
    Since you're not caching your whole venv, you will need to re-install
    dependencies every time you run the job; caching will, however, still save 
    you the time it would take to download the wheels (and it will reduce the strain on PyPi).

## Contributing
Contributions are always welcome; submit a PR!

## License
install-poetry is licensed under an MIT license. See the license file for details.

## Showing your support
Leave a ✭ if this project helped you!