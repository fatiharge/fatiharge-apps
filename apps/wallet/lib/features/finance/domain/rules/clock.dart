/// Where "now" comes from, so a test can pin today.
typedef Clock = DateTime Function();

DateTime systemClock() => DateTime.now();
