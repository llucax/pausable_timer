import 'package:test/test.dart';
import 'package:fake_async/fake_async.dart' show fakeAsync;

import 'package:pausable_timer/pausable_timer.dart';

void main() {
  const oneSecond = Duration(seconds: 1);

  var numCalls = 0;
  void callback() => numCalls++;
  setUp(() => numCalls = 0);

  void expectState(
    PausableTimer timer,
    Duration duration,
    State state, {
    Duration elapsed = Duration.zero,
    int withCalls = 0,
  }) {
    expect(timer.isActive, state == State.active, reason: 'Property: isActive');
    expect(timer.isPaused, state == State.paused, reason: 'Property: isPaused');
    expect(timer.isExpired, state == State.expired || state == State.expiredCancelled, reason: 'Property: isExpired');
    expect(timer.isCancelled, state == State.cancelled || state == State.expiredCancelled, reason: 'Property: isCancelled');
    expect(timer.duration, duration, reason: 'Property: duration');
    expect(timer.elapsed, elapsed, reason: 'Property: elapsed');
    expect(numCalls, withCalls, reason: 'Property: numCalls');
    expect(timer.tick, numCalls, reason: 'Property: ticks');
  }

  test("A pausable timer duration can't be less than zero", () {
    expect(
      () => PausableTimer(Duration(seconds: -1), () {}),
      throwsA(isA<AssertionError>()),
    );
  });

  test("A pausable timer should initially be paused with the duration set to the given duration", () {
    for (final duration in [Duration.zero, oneSecond]) {
      final timer = PausableTimer(duration, callback);
      expectState(timer, duration, State.paused);
    }
  });

  test('start()', () {
    fakeAsync((fakeTime) {
      final timer = PausableTimer(oneSecond, callback);

      // Wait for a couple of seconds and it should be still paused
      fakeTime.elapse(oneSecond * 2);
      expectState(timer, oneSecond, State.paused);

      timer.start();
      expectState(timer, oneSecond, State.active);

      // Wait for half the duration, it should be still running
      fakeTime.elapse(oneSecond ~/ 2);
      expectState(timer, oneSecond, State.active, elapsed: oneSecond ~/ 2);

      // start again should do nothing
      timer.start();
      expectState(timer, oneSecond, State.active, elapsed: oneSecond ~/ 2);

      // Wait again for half the duration and it should have expired
      fakeTime.elapse(oneSecond ~/ 2);
      expectState(timer, oneSecond, State.expired, elapsed: oneSecond, withCalls: 1);

      // Wait for a couple more seconds, nothing should happen
      fakeTime.elapse(oneSecond * 2);
      expectState(timer, oneSecond, State.expired, elapsed: oneSecond, withCalls: 1);

      // start when it's already expired should do nothing
      timer.start();
      expectState(timer, oneSecond, State.expired, elapsed: oneSecond, withCalls: 1);
    });
  });

  test('pause()', () {
    fakeAsync((fakeTime) {
      final timer = PausableTimer(oneSecond, callback);

      timer.start();
      expectState(timer, oneSecond, State.active);

      // Wait for half the duration, it should be still running
      fakeTime.elapse(oneSecond ~/ 2);
      expectState(timer, oneSecond, State.active, elapsed: oneSecond ~/ 2);
      var elapsed = timer.elapsed;

      // Pause it
      timer.pause();
      expectState(timer, oneSecond, State.paused, elapsed: elapsed);
      elapsed = timer.elapsed;

      // Wait for a couple more seconds, nothing should happen
      fakeTime.elapse(oneSecond * 2);
      expectState(timer, oneSecond, State.paused, elapsed: elapsed);

      // pause should do nothing either, even if more time passes
      timer.pause();
      fakeTime.elapse(oneSecond * 2);
      expectState(timer, oneSecond, State.paused, elapsed: elapsed);

      // Resume the timer, it should be State.active again
      timer.start();
      expectState(timer, oneSecond, State.active, elapsed: elapsed);

      // Wait for the remaining time, then it should be expired
      fakeTime.elapse(oneSecond - timer.elapsed);
      expectState(timer, oneSecond, State.expired, elapsed: oneSecond, withCalls: 1);

      // Wait for a couple more seconds, nothing should happen
      fakeTime.elapse(oneSecond * 2);
      expectState(timer, oneSecond, State.expired, elapsed: oneSecond, withCalls: 1);

      // pause when it's already expired should do nothing
      timer.pause();
      expectState(timer, oneSecond, State.expired, elapsed: oneSecond, withCalls: 1);
    });
  });

  test('reset()', () {
    fakeAsync((fakeTime) {
      final timer = PausableTimer(oneSecond, callback);

      // resetting the timer upon start should be a NOP
      timer.reset();
      expectState(timer, oneSecond, State.paused);

      // start and reset after half the time passed
      timer.start();
      fakeTime.elapse(oneSecond ~/ 2);
      expectState(timer, oneSecond, State.active, elapsed: oneSecond ~/ 2);
      // reset should bring the elapsed time to zero-ish again but it should
      // be still State.active
      timer.reset();
      expectState(timer, oneSecond, State.active);

      // let some time pass again, pause and reset, it should be reset to
      // nothing elapsed and still be paused
      fakeTime.elapse(oneSecond ~/ 3);
      timer.pause();
      fakeTime.elapse(oneSecond ~/ 3);
      expectState(timer, oneSecond, State.paused, elapsed: oneSecond ~/ 3);
      timer.reset();
      expectState(timer, oneSecond, State.paused);
    });
  });

  group('cancel()', () {
    test('just after creation', () {
      fakeAsync((fakeTime) {
        // cancel just after creation
        final timer = PausableTimer(oneSecond, callback);
        timer.cancel();
        expectState(timer, oneSecond, State.cancelled);
        fakeTime.elapse(oneSecond * 2);
        expectState(timer, oneSecond, State.cancelled);
      });
    });

    test('after start()', () {
      fakeAsync((fakeTime) {
        // cancel in the middle of the timer time
        final timer = PausableTimer(oneSecond, callback);
        timer.start();
        fakeTime.elapse(oneSecond ~/ 2);
        timer.cancel();
        expectState(timer, oneSecond, State.cancelled, elapsed: oneSecond ~/ 2);
        // calling cancel again should do nothing
        timer.cancel();
        expectState(timer, oneSecond, State.cancelled, elapsed: oneSecond ~/ 2);
      });
    });

    test('after pause()', () {
      fakeAsync((fakeTime) {
        // cancel after expiration should do nothing
        final timer = PausableTimer(oneSecond, callback);
        timer.start();
        fakeTime.elapse(oneSecond);
        expectState(timer, oneSecond, State.expired, elapsed: oneSecond, withCalls: 1);
        timer.cancel();
        expectState(timer, oneSecond, State.expiredCancelled, elapsed: oneSecond, withCalls: 1);
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
        expectState(timer, oneSecond, State.cancelled, elapsed: oneSecond ~/ 2);
        timer.pause();
        expectState(timer, oneSecond, State.cancelled, elapsed: oneSecond ~/ 2);
        timer.reset();
        expectState(timer, oneSecond, State.cancelled, elapsed: oneSecond ~/ 2);
      });
    });
  });
}

enum State {
  active,
  paused,
  expired,
  cancelled,
  expiredCancelled;
}
