![tests](https://github.com/sondrelg/install-poetry/workflows/test/badge.svg)

# Install Poetry action

A Github action for installing and configuring Poetry.

The action installs Poetry, adds it to path, and sets relevant config settings.

## Implementation

To simply install Poetry, using the default settings, you can add this to your workflow:

```yaml
- uses: dschep/install-poetry-action@v1.3
```

If you wish to configure Poetry, or specify the version, you specify your settings using the `with` keyword:

```yaml
- name: Install and configure Poetry
  uses: dschep/install-poetry-action@v1.3
  with:
    version: 1.1.4
    virtualenvs-create: true
    virtualenvs-in-project: false
    virtualenvs-path: .venv
```