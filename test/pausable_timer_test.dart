import 'package:test/test.dart';
import 'package:fake_async/fake_async.dart' show fakeAsync;

import 'package:pausable_timer/pausable_timer.dart';

void main() {
  final oneSecond = Duration(seconds: 1);
  var numCalls = 0;
  void callback() => numCalls++;

  setUp(() => numCalls = 0);

  final active = 'active';
  final paused = 'paused';
  final expired = 'expired';
  final cancelled = 'cancelled';
  final expiredCancelled = 'expiredCancelled';

  void expectState(PausableTimer timer, Duration duration, dynamic state,
      {Duration elapsed = Duration.zero, int withCalls = 0}) {
    assert(
        [active, paused, expired, cancelled, expiredCancelled].contains(state));
    expect(timer.isActive, state == active, reason: 'Property: isActive');
    expect(timer.isPaused, state == paused, reason: 'Property: isPaused');
    expect(timer.isExpired, state == expired || state == expiredCancelled,
        reason: 'Property: isExpired');
    expect(timer.isCancelled, state == cancelled || state == expiredCancelled,
        reason: 'Property: isCancelled');
    expect(timer.duration, duration, reason: 'Property: duration');
    expect(timer.elapsed, elapsed, reason: 'Property: elapsed');
    expect(numCalls, withCalls, reason: 'Property: numCalls');
    expect(timer.tick, numCalls, reason: 'Property: ticks');
  }

  test('constructor', () {
    final throwsAssertionError = throwsA(isA<AssertionError>());
    expect(() => PausableTimer(Duration(seconds: -1), () {}),
        throwsAssertionError);

    for (final duration in [Duration.zero, oneSecond]) {
      final timer = PausableTimer(duration, callback);
      expectState(timer, duration, paused);
    }
  });

  test('start()', () {
    fakeAsync((fakeTime) {
      final timer = PausableTimer(oneSecond, callback);

      // Wait for a couple of seconds and it should be still paused
      fakeTime.elapse(oneSecond * 2);
      expectState(timer, oneSecond, paused);

      timer.start();
      expectState(timer, oneSecond, active);

      // Wait for half the duration, it should be still running
      fakeTime.elapse(oneSecond ~/ 2);
      expectState(timer, oneSecond, active, elapsed: oneSecond ~/ 2);

      // start again should do nothing
      timer.start();
      expectState(timer, oneSecond, active, elapsed: oneSecond ~/ 2);

      // Wait again for half the duration and it should have expired
      fakeTime.elapse(oneSecond ~/ 2);
      expectState(timer, oneSecond, expired, elapsed: oneSecond, withCalls: 1);

      // Wait for a couple more seconds, nothing should happen
      fakeTime.elapse(oneSecond * 2);
      expectState(timer, oneSecond, expired, elapsed: oneSecond, withCalls: 1);

      // start when it's already expired should do nothing
      timer.start();
      expectState(timer, oneSecond, expired, elapsed: oneSecond, withCalls: 1);
    });
  });

  test('pause()', () {
    fakeAsync((fakeTime) {
      final timer = PausableTimer(oneSecond, callback);

      timer.start();
      expectState(timer, oneSecond, active);

      // Wait for half the duration, it should be still running
      fakeTime.elapse(oneSecond ~/ 2);
      expectState(timer, oneSecond, active, elapsed: oneSecond ~/ 2);
      var elapsed = timer.elapsed;

      // Pause it
      timer.pause();
      expectState(timer, oneSecond, paused, elapsed: elapsed);
      elapsed = timer.elapsed;

      // Wait for a couple more seconds, nothing should happen
      fakeTime.elapse(oneSecond * 2);
      expectState(timer, oneSecond, paused, elapsed: elapsed);

      // pause should do nothing either, even if more time passes
      timer.pause();
      fakeTime.elapse(oneSecond * 2);
      expectState(timer, oneSecond, paused, elapsed: elapsed);

      // Resume the timer, it should be active again
      timer.start();
      expectState(timer, oneSecond, active, elapsed: elapsed);

      // Wait for the remaining time, then it should be expired
      fakeTime.elapse(oneSecond - timer.elapsed);
      expectState(timer, oneSecond, expired, elapsed: oneSecond, withCalls: 1);

      // Wait for a couple more seconds, nothing should happen
      fakeTime.elapse(oneSecond * 2);
      expectState(timer, oneSecond, expired, elapsed: oneSecond, withCalls: 1);

      // pause when it's already expired should do nothing
      timer.pause();
      expectState(timer, oneSecond, expired, elapsed: oneSecond, withCalls: 1);
    });
  });

  test('reset()', () {
    fakeAsync((fakeTime) {
      final timer = PausableTimer(oneSecond, callback);

      // resetting the timer upon start should be a NOP
      timer.reset();
      expectState(timer, oneSecond, paused);

      // start and reset after half the time passed
      timer.start();
      fakeTime.elapse(oneSecond ~/ 2);
      expectState(timer, oneSecond, active, elapsed: oneSecond ~/ 2);
      // reset should bring the elapsed time to zero-ish again but it should
      // be still active
      timer.reset();
      expectState(timer, oneSecond, active);

      // let some time pass again, pause and reset, it should be reset to
      // nothing elapsed and still be paused
      fakeTime.elapse(oneSecond ~/ 3);
      timer.pause();
      fakeTime.elapse(oneSecond ~/ 3);
      expectState(timer, oneSecond, paused, elapsed: oneSecond ~/ 3);
      timer.reset();
      expectState(timer, oneSecond, paused);
    });
  });

  group('cancel()', () {
    test('just after creation', () {
      fakeAsync((fakeTime) {
        // cancel just after creation
        final timer = PausableTimer(oneSecond, callback);
        timer.cancel();
        expectState(timer, oneSecond, cancelled);
        fakeTime.elapse(oneSecond * 2);
        expectState(timer, oneSecond, cancelled);
      });
    });

    test('after start()', () {
      fakeAsync((fakeTime) {
        // cancel in the middle of the timer time
        final timer = PausableTimer(oneSecond, callback);
        timer.start();
        fakeTime.elapse(oneSecond ~/ 2);
        timer.cancel();
        expectState(timer, oneSecond, cancelled, elapsed: oneSecond ~/ 2);
        // calling cancel again should do nothing
        timer.cancel();
        expectState(timer, oneSecond, cancelled, elapsed: oneSecond ~/ 2);
      });
    });

    test('after pause()', () {
      fakeAsync((fakeTime) {
        // cancel after expiration should do nothing
        final timer = PausableTimer(oneSecond, callback);
        timer.start();
        fakeTime.elapse(oneSecond);
        expectState(timer, oneSecond, expired,
            elapsed: oneSecond, withCalls: 1);
        timer.cancel();
        expectState(timer, oneSecond, expiredCancelled,
            elapsed: oneSecond, withCalls: 1);
      });
    });

    test('first, then start(), pause() and reset() do nothing', () {
      fakeAsync((fakeTime) {
        final timer = PausableTimer(oneSecond, callback);
        timer.start();
        fakeTime.elapse(oneSecond ~/ 2);
        timer.cancel();

        // start(), pause() and reset() after cancel() do nothing
        timer.start();
        expectState(timer, oneSecond, cancelled, elapsed: oneSecond ~/ 2);
        timer.pause();
        expectState(timer, oneSecond, cancelled, elapsed: oneSecond ~/ 2);
        timer.reset();
        expectState(timer, oneSecond, cancelled, elapsed: oneSecond ~/ 2);
      });
    });
  });
}
