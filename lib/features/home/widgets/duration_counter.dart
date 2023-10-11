import 'dart:async';

class StopwatchBloc {
  final _stopwatch = Stopwatch();
  final _controller = StreamController<Duration>();

  Stream<Duration> get elapsedStream => _controller.stream;

  void start() {
    _stopwatch.start();
    Timer.periodic(Duration(milliseconds: 100), _updateTime);
  }

  void stop() {
    _stopwatch.stop();
  }

  void reset() {
    _stopwatch.reset();
    _controller.add(Duration(seconds: 0));
  }

  void _updateTime(Timer timer) {
    if (_stopwatch.isRunning) {
      _controller.add(_stopwatch.elapsed);
    }
  }

  void dispose() {
    _controller.close();
  }
}
