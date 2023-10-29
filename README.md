# pausable\_timer

[![CI](https://github.com/llucax/pausable_timer/workflows/CI/badge.svg)](https://github.com/llucax/pausable_timer/actions?query=branch%3Amain+workflow%3ACI+)
[![Pub Score](https://github.com/llucax/pausable_timer/workflows/Pub%20Score/badge.svg)](https://github.com/llucax/pausable_timer/actions?query=branch%3Amain+workflow%3A%22Pub+Score%22+)
[![Latest Dart version](https://github.com/llucax/pausable_timer/actions/workflows/check-dart.yml/badge.svg)](https://github.com/llucax/pausable_timer/actions/workflows/check-dart.yml)
[![Coverage](https://codecov.io/gh/llucax/pausable_timer/branch/main/graph/badge.svg)](https://codecov.io/gh/llucax/pausable_timer)
[![pub package](https://img.shields.io/pub/v/pausable_timer.svg)](https://pub.dev/packages/pausable_timer)
[![pub points](https://img.shields.io/pub/points/pausable_timer)](https://pub.dev/packages/pausable_timer/score)
[![popularity](https://img.shields.io/pub/popularity/pausable_timer)](https://pub.dev/packages/pausable_timer/score)
[![likes](https://img.shields.io/pub/likes/pausable_timer)](https://pub.dev/packages/pausable_timer/score)
[![Sponsor (llucax)](https://img.shields.io/badge/-Sponsor-555555?style=flat-square)](https://github.com/llucax/llucax/blob/main/sponsoring-platforms.md)[![GitHub Sponsors](https://img.shields.io/badge/--ea4aaa?logo=github&style=flat-square)](https://github.com/sponsors/llucax)[![Liberapay](https://img.shields.io/badge/--f6c915?logo=liberapay&logoColor=black&style=flat-square)](https://liberapay.com/llucax/donate)[![Paypal](https://img.shields.io/badge/--0070ba?logo=paypal&style=flat-square)](https://www.paypal.com/donate?hosted_button_id=UZRR3REUC4SY2)[![Buy Me A Coffee](https://img.shields.io/badge/--ff813f?logo=buy-me-a-coffee&logoColor=white&style=flat-square)](https://www.buymeacoffee.com/llucax)[![Patreon](https://img.shields.io/badge/--f96854?logo=patreon&logoColor=white&style=flat-square)](https://www.patreon.com/llucax)[![Flattr](https://img.shields.io/badge/--6bc76b?logo=flattr&logoColor=white&style=flat-square)](https://flattr.com/@llucax)
[![Sponsor (mateusfccp)](https://img.shields.io/badge/-Sponsor-555555?style=flat-square)](https://github.com/sponsors/mateusfccp)[![GitHub Sponsors](https://img.shields.io/badge/--ea4aaa?logo=github&style=flat-square)](https://github.com/sponsors/mateusfccp)

A [Dart](https://dart.dev/)
[timer](https://api.dart.dev/stable/dart-async/Timer/Timer.html) that can be
paused, resumed and reset.

## Example using `start()`, `pause()` and `reset()`

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

## Example pausable countdown implementation

```dart
/// Example on how to implement countdown making a PausableTimer periodic.

import 'package:pausable_timer/pausable_timer.dart';

void main() async {
  // We make it "late" to be able to use the timer in the timer's callback.
  late final PausableTimer timer;
  var countDown = 5;

  print('Create a periodic timer that fires every 1 second and starts it');
  timer = PausableTimer(
    Duration(seconds: 1),
    () {
      countDown--;
      // If we reached 0, we don't reset and restart the time, so it won't fire
      // again, but it can be reused afterwards if needed. If we cancel the
      // timer, then it can be reused after the countdown is over.
      if (countDown > 0) {
        // we know the callback won't be called before the constructor ends, so
        // it is safe to use !
        timer
          ..reset()
          ..start();
      }
      // This is really what your callback do.
      print('\t$countDown');
    },
  )..start();

  print('And wait 2.1 seconds...');
  print('(0.1 extra to make sure there is no race between the timer and the '
      'waiting here)');
  await Future<void>.delayed(timer.duration * 2.1);
  print('By now 2 events should have fired: 4, 3\n');

  print('We can pause it now');
  timer.pause();

  print('And we wait for 2 more seconds...');
  await Future<void>.delayed(timer.duration * 2);
  print("But our timer doesn't care while it's paused\n");

  print('So we start it again');
  timer.start();
  print('And wait for 3.1 seconds more...');
  await Future<void>.delayed(timer.duration * 3.1);
  print('And we are done: 2, 1 and 0 should have been printed');

  print('The timer should be unpaused, inactive, expired and not cancelled');
  print('isPaused: ${timer.isPaused}');
  print('isActive: ${timer.isActive}');
  print('isExpired: ${timer.isExpired}');
  print('isCancelled: ${timer.isCancelled}');

  print('We can now reset it and start it again, now for 3 seconds');
  countDown = 3;
  timer
    ..reset()
    ..start();
  print('And wait for 3.1 seconds...');
  await Future<void>.delayed(timer.duration * 3.1);
  print('And it should be done printing: 2, 1 and 0');
}
```
