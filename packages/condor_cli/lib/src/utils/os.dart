import 'package:condor_cli/src/utils/process.dart';
import 'package:io/io.dart';

OperatingSystemInterface osInterface = OperatingSystemInterface();

class OperatingSystemInterface {
  String? which(String executableName) {
    final result = process.runSync('which', [executableName]);
    if (result.exitCode != ExitCode.success.code) {
      return null;
    }

    return (result.stdout as String?)?.trim();
  }
}
