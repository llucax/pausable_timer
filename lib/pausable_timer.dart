// Copyright 2020, Google LLC.
// Copyright 2020, Leandro Lucarella.
// Copyright 2023, Mateus Felipe Cordeiro Caetano Pinto.
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:async' show Timer, Zone;

import 'package:clock/clock.dart' show clock;

/// A [Timer] that can be paused, resumed and reset.
///
/// This implementation is roughly based on
/// [this comment](https://github.com/dart-lang/sdk/issues/43329#issuecomment-687024252).
final class PausableTimer implements Timer {
  /// The [Zone] where the [_callback] will be run.
  ///
  /// Dart generally calls asynchronous callbacks in the zone where they were
  /// originally "created".
  ///
  /// Such callbacks are first registered, because that makes it possible for
  /// special zones to record more information about the point where the
  /// callback is created (say, remember the stack trace, which is what the
  /// stack_trace package does).
  ///
  /// That is, we call [Zone.registerCallback] to enable zones to know about the
  /// callback creation as well as the later [Zone.run] for running it.
  ///
  /// If you just store the callback, but don't register it at the time it's
  /// stored, then we can still run it in the correct zone when necessary, but
  /// such special zones would stop working for that callback.
  ///
  /// This explanation comes from:
  /// https://github.com/dart-lang/sdk/issues/43329#issuecomment-687720625
  final Zone _zone;

  /// The [Stopwatch] used to keep track of the elapsed time.
  ///
  /// This allows us to pause the timer and resume from where it left of.
  ///
  /// When the timer expires, this stopwatch is set to null.
  Stopwatch? _stopwatch = clock.stopwatch();

  /// The currently active [Timer].
  ///
  /// This is null whenever this timer is not currently active.
  Timer? _timer;

  /// The callback to call when this timer expires.
  ///
  /// If this timer was [cancel]ed, then this callback is null.
  void Function()? _callback;

  /// The number of times this timer has expired.
  int _tick = 0;

  /// Starts the [_timer] to run [_callback] in [_zone] and increment [_tick].
  ///
  /// It also starts the [_stopwatch] and clears [_timer] and [_stopwatch] when
  /// the [_timer] expires.
  ///
  /// It will assert if _stopwatch is null (the timer was cancelled), so callers
  /// should make sure the timer wasn't cancelled before calling this function.
  void _startTimer() {
    assert(_stopwatch != null);
    _timer = _zone.createTimer(
      _originalDuration - _stopwatch!.elapsed,
      () {
        _tick++;
        _timer = null;
        _stopwatch = null;
        _zone.run(_callback!);
      },
    );
    _stopwatch!.start();
  }

  /// Creates a new timer.
  ///
  /// The [callback] is invoked after the given [duration], but can be [pause]d
  /// in between or [reset]. The [elapsed] time is only accounted for while the
  /// timer [isActive].
  ///
  /// The timer [isPaused] when created, and must be [start]ed manually.
  ///
  /// The [duration] must be equals or bigger than [Duration.zero].
  /// If it is [Duration.zero], the [callback] will still not be called until
  /// the timer is [start]ed.
  PausableTimer(Duration duration, void Function() callback)
      : assert(duration >= Duration.zero),
        _originalDuration = duration,
        _zone = Zone.current {
    _callback = _zone.bindCallback(callback);
  }

  /// The original duration this [Timer] was created with.
  Duration get duration => _originalDuration;
  final Duration _originalDuration;

  /// The time this [Timer] have been active.
  ///
  /// If the timer is paused, the elapsed time is also not computed anymore, so
  /// [elapsed] is always less than or equals to the [duration].
  Duration get elapsed => _stopwatch?.elapsed ?? _originalDuration;

  /// True if this [Timer] is armed but not currently active.
  ///
  /// If this timer [isExpired] or [isCancelled], it is not considered to be
  /// paused.
  bool get isPaused => _timer == null && !isExpired && !isCancelled;

  /// True if this [Timer] has expired.
  bool get isExpired => _stopwatch == null;

  /// True if this [Timer] was cancelled.
  bool get isCancelled => _callback == null;

  /// True if this [Timer] is armed and counting.
  @override
  bool get isActive => _timer != null;

  @override
  int get tick => _tick;

  /// Cancels the timer.
  ///
  /// Once a [Timer] has been canceled, the callback function will not be called
  /// by the timer and the timer can't be activated again. Calling [start],
  /// [pause] or [reset] will have no effect. Calling [cancel] more than once on
  /// a [Timer] is also allowed, and will have no further effect.
  @override
  void cancel() {
    _stopwatch?.stop();
    _timer?.cancel();
    _timer = null;
    _callback = null;
  }

  /// Starts (or resumes) the timer.
  ///
  /// Starts counting for the original duration or from where it was left of if
  /// [pause]ed.
  ///
  /// It does nothing if the timer [isActive], [isExpired] or [isCancelled].
  void start() {
    if (isActive || isExpired || isCancelled) return;
    _startTimer();
  }

  /// Pauses an active timer.
  ///
  /// The [elapsed] time is not accounted anymore and the timer will not be
  /// fired until it is [start]ed again.
  ///
  /// Nothing happens if the timer [isPaused], [isExpired] or [isCancelled].
  void pause() {
    _stopwatch?.stop();
    _timer?.cancel();
    _timer = null;
  }

  /// Resets the timer.
  ///
  /// Sets the timer to its original [duration] and rearms it if it was already
  /// expired (so it can be started again).
  ///
  /// Does not change whether the timer [isActive] or [isPaused].
  void reset() {
    if (isCancelled) return;
    _stopwatch = clock.stopwatch();
    if (isActive) {
      _timer!.cancel(); // it has to be non-null if it's active
      _startTimer();
    }
  }
}
