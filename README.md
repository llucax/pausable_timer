# pausable\_timer

[![CI](https://github.com/llucax/pausable_timer/workflows/CI/badge.svg)](https://github.com/llucax/pausable_timer/actions?query=branch%3Amain+workflow%3ACI+)
[![Coverage](https://codecov.io/gh/llucax/pausable_timer/branch/main/graph/badge.svg)](https://codecov.io/gh/llucax/pausable_timer)
[![pub package](https://img.shields.io/pub/v/pausable_timer.svg)](https://pub.dev/packages/pausable_timer)
[![pub points](https://badges.bar/pausable_timer/pub%20points)](https://pub.dev/packages/pausable_timer/score)
[![popularity](https://badges.bar/pausable_timer/popularity)](https://pub.dev/packages/pausable_timer/score)
[![likes](https://badges.bar/pausable_timer/likes)](https://pub.dev/packages/pausable_timer/score)

[![Donate](https://img.shields.io/badge/Donate-Paypal-0070ba)](https://www.paypal.com/donate?hosted_button_id=UZRR3REUC4SY2)
[![Donate](https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-ffdd00)](https://www.buymeacoffee.com/llucax)
[![Donate](https://img.shields.io/badge/Donate-Flattr-6bc76b)](https://flattr.com/@llucax)

A [Dart](https://dart.dev/)
[timer](https://api.dart.dev/stable/dart-async/Timer/Timer.html) that can be
paused, resumed and reset.

## Example

```dart
import 'package:pausable_timer/pausable_timer.dart';

void main() async {
  print('Create a timer that fires in 1 second, but it is not started yet');
  final timer = PausableTimer(Duration(seconds: 1), () => print('Fired!'));
  print('So we start it');
  timer.start();

  print('And wait 1/2 second...');
  await Future<void>.delayed(timer.duration ~/ 2);
  print('Not yet fired, still 1/2 second to go!');

  print('We can pause it now');
  timer.pause();

  // When paused, time can pass but the timer won't be fired
  print('And we wait a whole second...');
  await Future<void>.delayed(timer.duration);
  print("But our timer doesn't care while it's paused");
  print('It will still wait for ${timer.duration - timer.elapsed} after '
      "it's started again");

  print('So we start it again');
  timer.start();
  print('And wait for 1/2 second again, it should have fired when we are done');
  await Future<void>.delayed(timer.duration ~/ 2);
  print('And we are done, "Fired!" should be up there 👆');
  print('Now our timer completed ${timer.tick} tick');

  print('We can reset it if we want to use it again');
  timer.reset();
  print('We have to start it again after the reset because it was not running');
  timer.start();
  print('Now we wait a whole second in one go...');
  await Future<void>.delayed(timer.duration);
  print('And we are done, so you should see "Fired!" up there again 👆');
  print('Now the timer has ${timer.tick} ticks');

  print('We can reset it and start it again');
  timer.reset();
  timer.start();

  print('And you can cancel it too, so it will not fire again');
  timer.cancel();
  print("After a timer is cancelled, it can't be used again");
  print('But important information can still be retrieved:');
  print('duration: ${timer.duration}');
  print('elapsed: ${timer.elapsed}');
  print('tick: ${timer.tick}');
  print('isPaused: ${timer.isPaused}');
  print('isActive: ${timer.isActive}');
  print('isExpired: ${timer.isExpired}');
  print('isCancelled: ${timer.isCancelled}');
}
```
