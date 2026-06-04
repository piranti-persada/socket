import 'dart:io';
import 'dart:convert';

class ProcessRunnerResult {
  final int exitCode;
  final String stdout;
  final String stderr;

  ProcessRunnerResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  bool get isSuccess => exitCode == 0;
}

class ProcessRunner {
  static Future<ProcessRunnerResult> run(String executable, List<String> args, {Duration? timeout}) async {
    try {
      final processFuture = Process.run(executable, args, stdoutEncoding: utf8, stderrEncoding: utf8);
      
      ProcessResult result;
      if (timeout != null) {
        result = await processFuture.timeout(timeout);
      } else {
        result = await processFuture;
      }
      
      return ProcessRunnerResult(
        exitCode: result.exitCode,
        stdout: result.stdout.toString(),
        stderr: result.stderr.toString(),
      );
    } catch (e) {
      return ProcessRunnerResult(
        exitCode: -1,
        stdout: '',
        stderr: e.toString(),
      );
    }
  }

  static Future<Process> start(String executable, List<String> args) async {
    return await Process.start(executable, args);
  }
}
