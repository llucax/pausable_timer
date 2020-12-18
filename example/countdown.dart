/// Example on how to implement countdown making a PausableTimer periodic.

import 'package:pausable_timer/pausable_timer.dart';

void main() async {
  // We need to make it nullable because we have a "circular dependency" between
  // the callback and the variable. Since we are using the same variable we are
  // initializing, the compiler can't guarantee the callback won't be called
  // before the PausableTimer constructor finishes.
  PausableTimer? timerInit;
  var countDown = 5;

  print('Create a periodic timer that fires every 1 second and starts it');
  timerInit = PausableTimer(
    Duration(seconds: 1),
    () {
      countDown--;
      // If we reached 0, we don't reset and restart the time, so it won't fire
      // again, but it can be reused afterwards if needed. If we cancel the
      // timer, then it can be reused after the countdown is over.
      if (countDown > 0) {
        // we know the callback won't be called before the constructor ends, so
        // it is safe to use !
        timerInit!
          ..reset()
          ..start();
      }
      // This is really what your callback do.
      print('\t$countDown');
    },
  )..start();

  // We create a new non-nullable binding for the timer to avoid writing timer!
  // everywhere when we *know* it will be non-null.
  final timer = timerInit;

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
