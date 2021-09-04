The scripts in the scripts folder should not ever change.

Previous versions of the action would curl scripts from the repos main branch,
meaning that if we remove them, old pinned versions of the action will break.
