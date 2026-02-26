class ZeytinXValue {
  final String box;
  final String tag;
  final Map<String, dynamic>? value;

  ZeytinXValue(this.box, this.tag, this.value);

  ZeytinXValue copyWith({
    String? box,
    String? tag,
    Map<String, dynamic>? value,
  }) {
    return ZeytinXValue(
      box ?? this.box,
      tag ?? this.tag,
      value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'box': box,
      'tag': tag,
      'value': value,
    };
  }

  factory ZeytinXValue.fromMap(Map<String, dynamic> map) {
    return ZeytinXValue(
      (map['box'] ?? "") as String,
      (map['tag'] ?? "") as String,
      map['value'] != null
          ? Map<String, dynamic>.from(map['value'] as Map)
          : null,
    );
  }

  @override
  String toString() => 'ZeytinXValue(box: $box, tag: $tag, value: $value)';
}
