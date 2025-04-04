/// 代码单例
CondorCode code = CondorCode();

/// 代码
class CondorCode {
  /// 查找方法体的结束行号
  ///
  /// [lines] 代码的行数组
  /// [startLineIndex] 方法体的开始行号
  /// 返回一个 record: ({bool found, int endLineIndex})
  ({
    bool found,
    int endLineIndex,
  }) findMethodEndLine(
    List<String> lines,
    int startLineIndex,
  ) {
    var braceCount = 0;
    var foundStartBrace = false;

    for (var i = startLineIndex; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains('{')) {
        if (!foundStartBrace) {
          // 找到了 { 的开始位置
          foundStartBrace = true;
        }
        // 计算行中所有开括号的数量
        braceCount += '{'.allMatches(line).length;
      }
      if (line.contains('}')) {
        // 计算行中所有闭括号的数量
        braceCount -= '}'.allMatches(line).length;
      }
      // 如果我们找到了开始位置并且计数达到0，这就是结束行
      if (foundStartBrace && braceCount <= 0) {
        return (
          found: true,
          endLineIndex: i,
        );
      }
    }
    return (
      found: false,
      endLineIndex: -1,
    );
  }
}
