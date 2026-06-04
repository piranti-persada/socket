enum LogLevel { verbose, debug, info, warning, error, fatal, unknown }

class LogcatEntry {
  final DateTime? timestamp;
  final int? pid;
  final int? tid;
  final LogLevel level;
  final String tag;
  final String message;
  final String rawLine;

  const LogcatEntry({
    this.timestamp,
    this.pid,
    this.tid,
    required this.level,
    required this.tag,
    required this.message,
    required this.rawLine,
  });

  static LogLevel _parseLevel(String levelStr) {
    switch (levelStr) {
      case 'V': return LogLevel.verbose;
      case 'D': return LogLevel.debug;
      case 'I': return LogLevel.info;
      case 'W': return LogLevel.warning;
      case 'E': return LogLevel.error;
      case 'F': return LogLevel.fatal;
      default: return LogLevel.unknown;
    }
  }

  // Parses threadtime format: "01-01 12:34:56.789  1234  5678 D Tag: Message"
  static LogcatEntry parse(String line) {
    try {
      if (line.isEmpty) throw const FormatException();
      
      final parts = line.split(RegExp(r'\s+'));
      if (parts.length >= 6) {
        final dateStr = parts[0];
        final timeStr = parts[1];
        final pid = int.tryParse(parts[2]);
        final tid = int.tryParse(parts[3]);
        final level = _parseLevel(parts[4]);
        
        // Tag can contain spaces before the colon
        int colonIndex = line.indexOf(':', line.indexOf(parts[4]));
        if (colonIndex == -1) throw const FormatException();
        
        String tag = line.substring(line.indexOf(parts[4]) + 1, colonIndex).trim();
        String message = line.substring(colonIndex + 1).trim();

        // Basic timestamp parsing (assumes current year since logcat doesn't provide it)
        final now = DateTime.now();
        final dt = DateTime.parse('${now.year}-$dateStr $timeStr');

        return LogcatEntry(
          timestamp: dt,
          pid: pid,
          tid: tid,
          level: level,
          tag: tag,
          message: message,
          rawLine: line,
        );
      }
    } catch (_) {}

    return LogcatEntry(
      level: LogLevel.unknown,
      tag: '',
      message: line,
      rawLine: line,
    );
  }
}
