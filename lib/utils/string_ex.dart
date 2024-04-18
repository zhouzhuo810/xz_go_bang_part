
extension StringNullEx on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// 比较两个字符串是否相等，如果都为null或空串，通过[emptySame]来决定是否相等。如果需要相等则[emptySame]置为true即可，默认false
  bool equal(String? other, [bool emptySame = false]) {
    if (isNullOrEmpty && other.isNullOrEmpty) {
      return emptySame;
    }

    if (isNotNullOrEmpty && other.isNotNullOrEmpty) {
      return this == other;
    }

    // this 和 other 中至少有一个是null或空串，而另外一个是有值的，因此始终不相等
    return false;
  }

  /// 解决系统默认换行，从中文与（英文或数字）处截断问题，加了此处理后，只会在单行显示不下的字符处换行，不会提前换行
  String ellipsis() {
    return fixSoftWrap() ?? '';
  }

  /// 解决系统默认换行，从中文与（英文或数字）处截断问题，加了此处理后，只会在单行显示不下的字符处换行，不会提前换行
  String? fixSoftWrap() {
    var data = this;
    if (data == null || data.length < 2) {
      return data;
    }

    if (data.length > 100) {
      // 超过100个字符不处理，防止影响性能，一般使用此方法都是展示标签，不会在输入框使用，因此字符长度不会太长
      return data;
    }

    String strs = '';
    int offset = 0;
    while (offset < data.length) {
      if (offset < data.length - 1) {
        var str = data.substring(offset, offset + 2);
        if (str.isEmoji) {
          offset += 2;
          strs += '$str\u200b';
        } else {
          strs += '${data.substring(offset, offset + 1)}\u200b';
          offset++;
        }
      } else {
        strs += '${data.substring(offset, offset + 1)}\u200b';
        offset++;
      }
    }

    return strs;
  }

  /// 是否是表情符号
  bool get isEmoji {
    var str = this;
    if (str == null || str.length != 2) {
      return false;
    }

    return _isEmojiCharacter(str.codeUnitAt(0)) &&
        _isEmojiCharacter(str.codeUnitAt(1));
  }

  static bool _isEmojiCharacter(int codePoint) {
    return !((codePoint == 0x0) ||
        (codePoint == 0x9) ||
        (codePoint == 0xA) ||
        (codePoint == 0xD) ||
        ((codePoint >= 0x20) && (codePoint <= 0xD7FF)) ||
        ((codePoint >= 0xE000) && (codePoint <= 0xFFFD)));
  }

  /// 判断如果该值为空或者为空字符串时，需要格式化成什么值
  String ifEmptyFormat(String value) {
    if (isNullOrEmpty) {
      return value;
    } else {
      return this!;
    }
  }

  /// 将两个字符串拼接在一起
  ///
  /// [delimiter]为字符之间的分隔符，[emptyAppend]表示字符为空串时是否参与拼接
  String? append(String? str,
      {String delimiter = "", bool emptyAppend = false}) {
    if (this == null || (this!.isEmpty && !emptyAppend)) {
      return str;
    }

    if (str == null || (str.isEmpty && !emptyAppend)) {
      return this;
    }

    return '${this!}$delimiter$str';
  }
}
