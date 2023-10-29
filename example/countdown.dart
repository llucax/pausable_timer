// Example on how to implement countdown making a PausableTimer periodic.
import 'dart:async';

import 'package:pausable_timer/pausable_timer.dart';

void main() async {
  // We make it "late" to be able to use the timer in the timer's callback.
  late final PausableTimer timer;
  var countDown = 5;

  print('Create a periodic timer that fires every 1 second and starts it');
  timer = PausableTimer.periodic(
    Duration(seconds: 1),
    () {
      countDown--;

      if (countDown == 0) {
        timer.pause();
      }

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
