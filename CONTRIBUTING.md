# Contributing

## Releasing

At some point this should be automated, but for now to make a new release you
should follow this checklist:

- [ ] Define what will be the next version of the package
  - This package uses [semantic versioning](http://semver.org/), so take it
    into account when releasing a new version
- [ ] Update the version in `pubspec.yaml`
- [ ] Add an entry to `CHANGELOG.md` describing the relevant changes
- [ ] Run `dart pub publish -n` and make sure there are no warnings and the
  version is correct
- [ ] Commit and push the changes to a new branch and open a PR
- [ ] Merge the PR and pull the changes
- [ ] Tag the release with `tag -a v<version>` and use the contents added to
  `CHANGELOG.md` as the message
  - Example: for the 3.0.0 version, tag the release as `v3.0.0`
- [ ] Push the tag
  - Once the tag is pushed, GitHub Actions are going to automatically release
    it to pub.dev
- [ ] Create a GitHub release for the tag using the tag message as release
  notes

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
