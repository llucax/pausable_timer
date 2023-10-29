import 'package:test/test.dart';
import 'package:fake_async/fake_async.dart' show fakeAsync;

import 'package:pausable_timer/pausable_timer.dart';

void main() {
  const oneSecond = Duration(seconds: 1);
  const halfSecond = Duration(milliseconds: 500);

  var numCalls = 0;
  void callback() => numCalls++;
  setUp(() => numCalls = 0);

  group('A timer', () {
    test("duration can't be less than zero", () {
      expect(
        () => PausableTimer(Duration(seconds: -1), callback),
        throwsA(isA<AssertionError>()),
      );
    });

    test("duration should be set to the given duration", () {
      for (final duration in [Duration.zero, oneSecond]) {
        final timer = PausableTimer(duration, callback);
        expect(timer.duration, duration);
      }
    });

    test("shouldn't start automatically", () {
      fakeAsync((async) {
        final timer = PausableTimer(oneSecond, callback);
        expect(timer.isActive, isFalse);

        async.elapse(oneSecond * 2);
        expect(timer.isActive, isFalse);
      });
    });

    test("should call it's callback after the given duration", () {
      fakeAsync((async) {
        final timer = PausableTimer(oneSecond, callback);

        timer.start();
        async.elapse(oneSecond - Duration(microseconds: 1));
        expect(numCalls, 0);
        expect(timer.isExpired, isFalse);

        async.elapse(Duration(microseconds: 1));
        expect(numCalls, 1);
        expect(timer.isExpired, isTrue);
      });
    });

    test("should do nothing after it's expired", () {
      fakeAsync((async) {
        final timer = PausableTimer(oneSecond, callback);

        timer.start();
        async.elapse(oneSecond);
        expect(numCalls, 1);
        expect(timer.isExpired, isTrue);

        async.elapse(oneSecond * 2);
        expect(numCalls, 1);
        expect(timer.isExpired, isTrue);
      });
    });
  });

  group('A periodic timer', () {
    test("duration can't be less than zero", () {
      expect(
            () => PausableTimer.periodic(Duration(seconds: -1), callback),
        throwsA(isA<AssertionError>()),
      );
    });

    test("duration should be set to the given duration", () {
      for (final duration in [Duration.zero, oneSecond]) {
        final timer = PausableTimer.periodic(duration, callback);
        expect(timer.duration, duration);
      }
    });

    test("shouldn't start automatically", () {
      fakeAsync((async) {
        final timer = PausableTimer.periodic(oneSecond, callback);
        expect(timer.isActive, isFalse);

        async.elapse(oneSecond * 2);
        expect(timer.isActive, isFalse);
      });
    });

    test("should not expire after executing it's callback", () {
      fakeAsync((async) {
        final timer = PausableTimer.periodic(oneSecond, callback);

        timer.start();
        async.elapse(oneSecond);
        expect(timer.isActive, true);
      });
    });

    test("should call it's callback after the given duration", () {
      fakeAsync((async) {
        final timer = PausableTimer(oneSecond, callback);

        timer.start();
        async.elapse(oneSecond - Duration(microseconds: 1));
        expect(numCalls, 0);
        expect(timer.isExpired, isFalse);

        async.elapse(Duration(microseconds: 1));
        expect(numCalls, 1);
        expect(timer.isExpired, isTrue);
      });
    });

    test("should call it's callback as many times as it's duration requires", () {
      fakeAsync((async) {
        final timer = PausableTimer.periodic(oneSecond, callback);

        timer.start();
        async.elapse(oneSecond * 100);
        expect(numCalls, 100);
      });
    });
  });

  group('Starting', () {
    test("an active timer should do nothing", () {
      fakeAsync((async) {
        final timer = PausableTimer(oneSecond, callback);

        timer.start();
        final initialState = timer.state;

        timer.start();
        final finalState = timer.state;

        expect(initialState, finalState);
      });
    });

    test("a paused timer should resume it's timer", () {
      fakeAsync((async) {
        final timer = PausableTimer(oneSecond, callback);

        timer.start();
        async.elapse(halfSecond);

        timer.pause();
        expect(timer.elapsed, halfSecond);

        timer.start();
        expect(timer.elapsed, halfSecond);

        async.elapse(halfSecond);
        expect(timer.isExpired, isTrue);
        expect(numCalls, 1);
      });
    });

    test("an expired timer should do nothing", () {
      fakeAsync((async) {
        final timer = PausableTimer(oneSecond, callback);

        timer.start();
        async.elapse(oneSecond);
        expect(numCalls, 1);
        expect(timer.isExpired, isTrue);

        timer.start();
        expect(numCalls, 1);
        expect(timer.isExpired, isTrue);

        async.elapse(oneSecond);

        expect(numCalls, 1);
        expect(timer.isExpired, isTrue);
      });
    });

    test("a cancelled timer should do nothing", () {
      fakeAsync((async) {
        final timer = PausableTimer(oneSecond, callback);

        timer.start();
        async.elapse(halfSecond);
        timer.cancel();
        async.elapse(oneSecond);
        expect(timer.isCancelled, isTrue);
        expect(numCalls, 0);

        timer.start();
        expect(timer.isCancelled, isTrue);
        async.elapse(oneSecond);
        expect(timer.isCancelled, isTrue);
        expect(numCalls, 0);
      });
    });

    test("an active periodic timer should do nothing", () {
      fakeAsync((async) {
        final timer = PausableTimer.periodic(oneSecond, callback);

        timer.start();
        final initialState = timer.state;

        timer.start();
        final finalState = timer.state;

        expect(initialState, finalState);
      });
    });

    test("a paused periodic timer should resume it's timer", () {
      fakeAsync((async) {
        final timer = PausableTimer.periodic(oneSecond, callback);

        timer.start();
        async.elapse(halfSecond);

        timer.pause();
        expect(timer.elapsed, halfSecond);

        timer.start();
        expect(timer.elapsed, halfSecond);

        async.elapse(halfSecond);
        expect(numCalls, 1);
      });
    });

    test("a cancelled periodic timer should do nothing", () {
      fakeAsync((async) {
        final timer = PausableTimer.periodic(oneSecond, callback);

        timer.start();
        async.elapse(halfSecond);
        timer.cancel();
        async.elapse(oneSecond);
        expect(timer.isCancelled, isTrue);
        expect(numCalls, 0);

        timer.start();
        expect(timer.isCancelled, isTrue);
        async.elapse(oneSecond);
        expect(timer.isCancelled, isTrue);
        expect(numCalls, 0);
      });
    });
  });

  group('Pausing', () {
    test('an active timer should prevent the callback from executing', () {
      fakeAsync((async) {
        final timer = PausableTimer(oneSecond, callback);

        timer.start();
        expect(timer.isActive, isTrue);

        async.elapse(halfSecond);
        timer.pause();
        expect(timer.isPaused, isTrue);

        async.elapse(oneSecond);
        expect(timer.isPaused, isTrue);
        expect(numCalls, 0);
      });
    });

    test('a paused timer should do nothing', () {
      fakeAsync((async) {
        final timer = PausableTimer(oneSecond, callback);

        final initialState = timer.state;

        async.elapse(oneSecond);
        timer.pause();
        final finalState = timer.state;

        expect(initialState, finalState);
      });
    });

    test('an expired timer should do nothing', () {
      fakeAsync((async) {
        final timer = PausableTimer(oneSecond, callback);

        timer.start();
        async.elapse(oneSecond);
        final initialState = timer.state;

        timer.pause();
        final finalState = timer.state;

        expect(initialState, finalState);
      });
    });

    test('a cancelled timer should do nothing', () {
      fakeAsync((async) {
        final timer = PausableTimer(oneSecond, callback);

        timer.cancel();
        final initialState = timer.state;

        async.elapse(oneSecond);

        timer.pause();
        final finalState = timer.state;

        expect(initialState, finalState);
      });
    });

    test('an active periodic timer should prevent the callback from executing', () {
      fakeAsync((async) {
        final timer = PausableTimer.periodic(oneSecond, callback);

        timer.start();
        expect(timer.isActive, isTrue);

        async.elapse(halfSecond);
        timer.pause();
        expect(timer.isPaused, isTrue);

        async.elapse(oneSecond);
        expect(timer.isPaused, isTrue);
        expect(numCalls, 0);
      });
    });

    test('a paused periodic timer should do nothing', () {
      fakeAsync((async) {
        final timer = PausableTimer.periodic(oneSecond, callback);

        final initialState = timer.state;

        async.elapse(oneSecond);
        timer.pause();
        final finalState = timer.state;

        expect(initialState, finalState);
      });
    });

    test('a cancelled periodic timer should do nothing', () {
      fakeAsync((async) {
        final timer = PausableTimer.periodic(oneSecond, callback);

        timer.cancel();
        final initialState = timer.state;

        async.elapse(oneSecond);

        timer.pause();
        final finalState = timer.state;

        expect(initialState, finalState);
      });
    });
  });

  group('Resetting', () {
    test("an active timer should revert it's timer to zero", () {
      fakeAsync((async) {
        final timer = PausableTimer(oneSecond, callback);

        timer.start();
        async.elapse(halfSecond);
        expect(timer.isActive, isTrue);
        expect(timer.elapsed, halfSecond);

        timer.reset();
        expect(timer.isActive, isTrue);
        expect(timer.elapsed, Duration.zero);
      });
    });

    test("a paused timer should revert it's timer to zero", () {
      fakeAsync((async) {
        final timer = PausableTimer(oneSecond, callback);

        timer.start();
        async.elapse(halfSecond);
        timer.pause();
        expect(timer.isPaused, isTrue);
        expect(timer.elapsed, halfSecond);

        timer.reset();
        expect(timer.isPaused, isTrue);
        expect(timer.elapsed, Duration.zero);
      });
    });

    test("an expired timer should revert it's timer to zero and it's status to paused", () {
      fakeAsync((async) {
        final timer = PausableTimer(oneSecond, callback);

        timer.start();
        async.elapse(oneSecond);
        expect(timer.isExpired, isTrue);
        expect(numCalls, 1);

        timer.reset();
        expect(timer.isPaused, isTrue);
        expect(timer.elapsed, Duration.zero);
      });
    });

    test('a cancelled timer should do nothing', () {
      fakeAsync((async) {
        final timer = PausableTimer(oneSecond, callback);

        timer.cancel();
        final initialState = timer.state;

        timer.reset();
        final finalState = timer.state;

        expect(initialState, finalState);
      });
    });

    test("an active periodic timer should revert it's timer to zero", () {
      fakeAsync((async) {
        final timer = PausableTimer.periodic(oneSecond, callback);

        timer.start();
        async.elapse(halfSecond);
        expect(timer.isActive, isTrue);
        expect(timer.elapsed, halfSecond);

        timer.reset();
        expect(timer.isActive, isTrue);
        expect(timer.elapsed, Duration.zero);
      });
    });

    test("a paused periodic timer should revert it's timer to zero", () {
      fakeAsync((async) {
        final timer = PausableTimer.periodic(oneSecond, callback);

        timer.start();
        async.elapse(halfSecond);
        timer.pause();
        expect(timer.isPaused, isTrue);
        expect(timer.elapsed, halfSecond);

        timer.reset();
        expect(timer.isPaused, isTrue);
        expect(timer.elapsed, Duration.zero);
      });
    });

    test('a cancelled periodic timer should do nothing', () {
      fakeAsync((async) {
        final timer = PausableTimer.periodic(oneSecond, callback);

        timer.cancel();
        final initialState = timer.state;

        timer.reset();
        final finalState = timer.state;

        expect(initialState, finalState);
      });
    });
  });

  group('Cancelling', () {
    test('an active timer should prevent the callback from executing', () {
      fakeAsync((async) {
        final timer = PausableTimer(oneSecond, callback);

        timer.start();
        expect(timer.isActive, isTrue);

        async.elapse(halfSecond);
        timer.cancel();
        expect(timer.isCancelled, isTrue);

        async.elapse(oneSecond);
        expect(timer.isCancelled, isTrue);
        expect(numCalls, 0);
      });
    });

    test('a cancelled timer should do nothing', () {
      fakeAsync((async) {
        final timer = PausableTimer(oneSecond, callback);

        timer.cancel();
        final initialState = timer.state;

        async.elapse(oneSecond);

        timer.cancel();
        final finalState = timer.state;

        expect(initialState, finalState);
      });
    });

    test('an active periodic timer should prevent the callback from executing', () {
      fakeAsync((async) {
        final timer = PausableTimer.periodic(oneSecond, callback);

        timer.start();
        expect(timer.isActive, isTrue);

        async.elapse(halfSecond);
        timer.cancel();
        expect(timer.isCancelled, isTrue);

        async.elapse(oneSecond);
        expect(timer.isCancelled, isTrue);
        expect(numCalls, 0);
      });
    });

    test('a cancelled periodic timer should do nothing', () {
      fakeAsync((async) {
        final timer = PausableTimer.periodic(oneSecond, callback);

        timer.cancel();
        final initialState = timer.state;

        async.elapse(oneSecond);

        timer.cancel();
        final finalState = timer.state;

        expect(initialState, finalState);
      });
    });
  });
}

extension on PausableTimer {
  (bool, bool, bool, bool, Duration, Duration, int) get state => (isActive, isPaused, isExpired, isCancelled, duration, elapsed, tick);
}
