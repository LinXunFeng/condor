import 'package:condor_cli/src/utils/utils.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Utils - Flutter', () {
    test('正常获取 Flutter 的版本号', () async {
      final version = await flutter.frameworkVersion() ?? '';
      // print('version = $version');
      expect(version.isNotEmpty, true);
    });
  });
}
