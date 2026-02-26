import 'package:zeytin_local_storage/zeytin_local_storage.dart';

enum ZeytinOpType { put, delete, deleteBox, batch, clearAll }

class ZeytinXOperation {
  final String truckId;
  final String? boxId;
  final ZeytinOpType type;
  final String? tag;
  final ZeytinValue? value;
  final List<ZeytinValue>? batchEntries;

  ZeytinXOperation({
    required this.truckId,
    this.boxId,
    required this.type,
    this.tag,
    this.value,
    this.batchEntries,
  });

  factory ZeytinXOperation.fromMap(Map<String, dynamic> map) {
    final box = map['boxId'] as String?;
    final tag = map['tag'] as String?;

    ZeytinValue? parsedValue;
    if (map['value'] != null && box != null && tag != null) {
      parsedValue = ZeytinValue(
        box,
        tag,
        Map<String, dynamic>.from(map['value'] as Map),
      );
    }

    List<ZeytinValue>? parsedBatch;
    if (map['entries'] != null && box != null) {
      final entriesMap = Map<String, dynamic>.from(map['entries'] as Map);
      parsedBatch = entriesMap.entries.map((e) {
        return ZeytinValue(
          box,
          e.key,
          e.value != null ? Map<String, dynamic>.from(e.value as Map) : null,
        );
      }).toList();
    }

    return ZeytinXOperation(
      truckId: map['truckId'] as String? ?? 'unknown',
      boxId: box,
      type: ZeytinOpTypeExtension.fromString(map['op'] as String? ?? ''),
      tag: tag,
      value: parsedValue,
      batchEntries: parsedBatch,
    );
  }

  @override
  String toString() {
    return 'ZeytinXOperation(type: $type, truckId: $truckId, boxId: $boxId, tag: $tag)';
  }
}

extension ZeytinOpTypeExtension on ZeytinOpType {
  static ZeytinOpType fromString(String op) {
    switch (op.toUpperCase()) {
      case 'PUT':
      case 'UPDATE':
        return ZeytinOpType.put;
      case 'DELETE':
        return ZeytinOpType.delete;
      case 'DELETE_BOX':
        return ZeytinOpType.deleteBox;
      case 'BATCH':
        return ZeytinOpType.batch;
      case 'CLEAR_ALL':
      case 'DELETE_ALL':
        return ZeytinOpType.clearAll;
      default:
        return ZeytinOpType.put;
    }
  }
}
