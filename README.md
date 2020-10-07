# pausable\_timer

[![Coverage]](https://codecov.io/gh/llucax/pausable_timer)

A [Dart](https://dart.dev/)
[timer](https://api.dart.dev/stable/dart-async/Timer/Timer.html) that can be
paused, resumed and reset.

## Example

```dart

import 'package:pausable_timer/pausable_timer.dart';

void main() async {
  final timer = PausableTimer(Duration(seconds: 1), () => print('yes!'));
  // PausableTimer starts paused, so we have to start it manually.
  timer.start();

  Future<void>.delayed(timer.duration ~/ 2);
  print('Not yet fired, still 1/2 second to go!');

  timer.pause();

  // When paused, time can pass but the timer won't be fired
  Future<void>.delayed(timer.duration);

  // Now we can resume the timer
  timer.start();
  Future<void>.delayed(timer.duration ~/ 2);

  // Now it should have fired and "yes!" should have been printed, but we can
  // re-arm the timer via reset() and use it again.

  timer.reset();
  timer.start();
  Future<void>.delayed(timer.duration);
  // And it should fire again.
  print('We should have 2 ticks now: ${timer.ticks}');

  // And we can arm it again
  timer.reset();
  timer.start();

  // And we can cancel it, but once the timer is cancelled, it can't be armed
  // again, but it can still be queried for information.
  timer.cancel();
  print('${timer.duration} ${timer.elapsed} ${timer.ticks} ${timer.isPaused}');
}
```

## Development

### Git Hooks

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

[Coverage]: (https://codecov.io/gh/llucax/pausable_timer/branch/main/graph/badge.svg)
