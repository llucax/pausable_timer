## 3.1.0+3

- Fix README.md reference to `yaml` file

## 3.1.0+2

- Update README.md countdown example to use `PausableTimer.periodic`
- Rename `.yml` files to `.yaml`, which is the [recommended](https://yaml.org/faq.html) extension
- Use single quote in `wip.yaml` so that backticks won't expand to commands

## 3.1.0+1

- Automate pub.dev publishing with GitHub Actions

## 3.1.0

- Provide `.periodic` constructor (#45)
  - A periodic timer should behave similar to [Timer.periodic](https://api.dart.dev/stable/dart-async/Timer/Timer.periodic.html)

## 3.0.0

- **BREAKING:** `PausableTimer` is now `final`
- Minor cleanups and fixes in documentations and tests

## 2.0.0+1

- Update and test against Dart 3.1.

[More details available in
GitHub](https://github.com/llucax/pausable_timer/milestone/14?closed=1).

## 2.0.0

- Update and test against Dart 3.0.
- Bump dependencies and configuration to work with Dart 3.0.
- Because of the above, drop support for Dart 2.x.

**NOTE:** If you need to use Dart 2.x you can stick to the 1.x branch series.
Even more, those releases seem to be forward-compatible with Dart 3.0, so
upgrading should only be necessary if you also need to bump other dependencies.

**WANTED:** It's been almost 2 years since the last time I used Dart or
Flutter, and while I enjoy maintaining open source projects, it is becoming
more and more difficult to keep up to date with changes in Dart and maintaining
this project, so **I'm looking for a maintainer willing to take over this
project** to ensure its health in the future.  Please [get in
touch](https://github.com/llucax/pausable_timer/discussions/55) if you are
interested.

[More details available in
GitHub](https://github.com/llucax/pausable_timer/milestone/13?closed=1).

## 1.0.0+7

- Update and test against Dart 2.19.

[More details available in
GitHub](https://github.com/llucax/pausable_timer/milestone/12?closed=1).

## 1.0.0+6

- Add funding link to `pubspec.yaml`.
- Update and test against Dart 2.18.

[More details available in
GitHub](https://github.com/llucax/pausable_timer/milestone/11?closed=1).

## 1.0.0+5

- Update and test against Dart 2.17.

[More details available in
GitHub](https://github.com/llucax/pausable_timer/milestone/9?closed=1).

## 1.0.0+4

- Update and test against Dart 2.16.

[More details available in
GitHub](https://github.com/llucax/pausable_timer/milestone/8?closed=1).

## 1.0.0+3

- Update and test against Dart 2.15.
- Update dependencies.

[More details available in
GitHub](https://github.com/llucax/pausable_timer/milestone/8?closed=1).

## 1.0.0+2

- Improve CI of the project
- Update example to use `late` instead of an extra variable to avoid `!`.
- Update and test against Dart 2.14.

[More details available in
GitHub](https://github.com/llucax/pausable_timer/milestone/7?closed=1).

## 1.0.0+1

This is a symbolic release marking that this package is stable (it has
been used for some time now without further issues) and there is no plan
to change the API in a near future.

The code is exacly the same as in version v0.2.0+1.

## 1.0.0

Unpublished version due to errors in the release process.

## 0.2.0+1

- Fix minimum dart SDK version (use a final release, not a pre-release).

**NOTE:** Unless critical issues are found, this release will be released as
1.0.0 with no other changes since it has been pretty stable for a while now,
and no API breaking changes are expected for a long while either.

## 0.2.0

- Bump dependencies.

**NOTE:** Due to a wrongly specified minimum dart SDK version, this version was
never published in pub.dev.

## 0.2.0-nullsafety.0

- Make package [null-safe](https://dart.dev/null-safety).

  **NOTE:** This means the minimum supported Dart version has been bumped to 2.12.

## 0.1.0+2

- Add example implementing a pausable countdown.

## 0.1.0+1

- Add build status and sponsorship badges.

## 0.1.0

- Initial version.
