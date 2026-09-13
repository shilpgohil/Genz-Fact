import 'package:intl/intl.dart';

String formatBytes(int? bytes) {
  if (bytes == null || bytes < 0) return 'Unknown size';
  if (bytes < 1024) return '$bytes B';
  const units = ['KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var unit = 'B';
  for (final next in units) {
    if (value < 1024) break;
    value /= 1024;
    unit = next;
  }
  if (value >= 100 || (value - value.round()).abs() < 0.05) {
    return '${value.round()} $unit';
  }
  final digits = value >= 10 ? 1 : 2;
  return '${value.toStringAsFixed(digits)} $unit';
}

String formatCount(int n, String singular, [String? plural]) {
  final p = plural ?? '${singular}s';
  return n == 1 ? '1 $singular' : '$n $p';
}

String formatDayHeader(DateTime date, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final d = DateTime(date.year, date.month, date.day);
  final t = DateTime(today.year, today.month, today.day);
  final diff = t.difference(d).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (date.year == today.year) {
    return DateFormat('EEEE, MMM d').format(date);
  }
  return DateFormat('EEEE, MMM d, y').format(date);
}

String formatMonthYear(DateTime date) => DateFormat('MMMM y').format(date);

String formatShortDate(DateTime date) => DateFormat('MMM d, y').format(date);

String formatTime(DateTime date) => DateFormat('h:mm a').format(date);

String formatDuration(Duration duration) {
  final h = duration.inHours;
  final m = duration.inMinutes.remainder(60);
  final s = duration.inSeconds.remainder(60);
  if (h > 0) {
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '$m:${s.toString().padLeft(2, '0')}';
}

enum DayPart { morning, afternoon, evening, night }

DayPart dayPartOf(DateTime time) {
  final h = time.hour;
  if (h >= 5 && h < 12) return DayPart.morning;
  if (h >= 12 && h < 17) return DayPart.afternoon;
  if (h >= 17 && h < 21) return DayPart.evening;
  return DayPart.night;
}

String dayPartLabel(DayPart part) {
  switch (part) {
    case DayPart.morning:
      return 'Morning';
    case DayPart.afternoon:
      return 'Afternoon';
    case DayPart.evening:
      return 'Evening';
    case DayPart.night:
      return 'Night';
  }
}
