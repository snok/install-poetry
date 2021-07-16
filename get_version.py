"""
Simple script used to tag our releases with major and minor git tags.

This lets users use the action with @v1 or @v1.1 references, and not have
to use the complete tag (with patch version specified).
"""

import sys

from packaging import version

if __name__ == '__main__':
    ref = sys.argv[1]  # ref will usually look like refs/tags/v1.0.1
    major = sys.argv[2] == 'major'
    version = version.parse(ref.split('refs/tags/v')[1])

    if major:
        print(f'v{version.major}')
    else:
        print(f'v{version.major}.{version.minor}')
