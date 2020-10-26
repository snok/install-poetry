![tests](https://github.com/sondrelg/install-poetry/workflows/test/badge.svg)

# Install Poetry action

A Github action for installing and configuring Poetry.

The action installs Poetry, adds executables to the runners system path, and sets relevant Poetry config settings.

Action inspired by archived [dschep/install-poetry-action](https://github.com/dschep/install-poetry-action).

## Implementation

If all you want to do is install Poetry (using the default settings) simply add this to your workflow:

```yaml
- uses: dschep/install-poetry-action@v1.3
```

If you wish to edit the Poetry settings, or set a specific version (default latest), you specify your settings using the `with` keyword:

```yaml
- name: Install and configure Poetry
  uses: dschep/install-poetry-action@v1.3
  with:
    version: 1.1.4
    virtualenvs-create: true
    virtualenvs-in-project: false
    virtualenvs-path: .venv
```

## Example

```yaml
name: test

on: pull_request

jobs:
  test:
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
        uses: sondrelg/install-poetry@v0.1.0
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
        run: |
          source $HOME/.poetry/env
          poetry install
        if: steps.cached-poetry-dependencies.outputs.cache-hit != 'true'
      #----------------------------------------------
      #    add matrix specifics and run test suite   
      #----------------------------------------------
      - name: Install django ${{ matrix.django-version }}
        run: |
          source $HOME/.poetry/env
          poetry add "Django==${{ matrix.django-version }}"
      - name: Run tests
        run: |
          source $HOME/.poetry/env
          poetry run pytest --cov=django_guid tests/
          poetry run coverage report
```
