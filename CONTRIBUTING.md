# Contributing

## Releasing

At some point this should be automated, but for now to make a new release you
should follow this checklist:

- [ ] Update the version in `pubspec.yaml` (use X.Y.Z)
- [ ] Add an entry to `CHANGELOG.md` (use X.Y.Z)
- [ ] Commit and push the changes creating a PR
- [ ] Merge the PR and pull the changes
- [ ] Run `dart pub publish -n` and make sure there are no warnings and the
  version is correct
- [ ] Tag the release with `tag -a vX.Y.Z` and use the contents added to
  `CHANGELOG.md` as the message
- [ ] Push the tag
- [ ] Create a GitHub release for the tag using the tag message as release
  notes
- [ ] If there is a milestone called `vX.Y.Z`, close it. Otherwise if there is
  a milestone `next`, rename it to `vX.Y.Z` and close it. Otherwise create
  a new milestone and assign all the issues and PRs that were added for this
  version
- [ ] Create a new `next` milestone
- [ ] Publish the package via `dart pub publish`

## Git Hooks

This repository provides some useful Git hooks to make sure new commits have
some basic health.

The hooks are provided in the `.githooks/` directory and can be easily used by
configuring git to use this directory for hooks instead of the default
`.git/hooks/`:

```sh
git config core.hooksPath .githooks
```

So far there is a hook to prevent commits with the `WIP` word in the message to
be pushed, and one hook to run `flutter analyze` and `flutter test` before
a new commit is created. The later can take some time, but it can be easily
disabled temporarily by using `git commit --no-verify` if you are, for example,
just changing the README file or amending a commit message.
