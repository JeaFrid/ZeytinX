import 'dart:async';
import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:zeytin_local_storage/zeytin_local_storage.dart';
import 'package:zeytinx/zeytinx.dart';

class ZeytinX {
  final String namespace;
  final String truckID;
  ZeytinX(this.namespace, this.truckID);
  Uuid uuid = Uuid();
  ZeytinStorage? zeytin;
  Future<void> initialize(String basePath) async {
    zeytin = ZeytinStorage(namespace: namespace, truckID: truckID);
    await zeytin!.initialize(basePath);
  }

  bool get isInitialized => zeytin != null;
  Future<ZeytinXResponse> _run(
      Future<ZeytinXResponse> Function() action) async {
    if (zeytin == null) {
      return ZeytinXResponse(
          isSuccess: false, message: "Error", error: "Engine not initialized");
    }
    try {
      return await action();
    } catch (e, s) {
      ZeytinXPrint.errorPrint(e.toString());
      ZeytinXPrint.errorPrint(s.toString());
      return ZeytinXResponse(
          isSuccess: false, message: "Error", error: "$e, $s");
    }
  }

  Future<ZeytinXResponse> multiple({
    required Future<ZeytinXResponse> Function(List<String> boxes) processes,
    required Future<ZeytinXResponse> Function() onSuccess,
    required Future<ZeytinXResponse> Function(String e, StackTrace s) onError,
  }) async {
    return await _run(
      () async {
        ZeytinXResponse res = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: "Unknown Error!",
        );
        try {
          if (zeytin == null) {
            res = ZeytinXResponse(
                isSuccess: false,
                message: "Error",
                error: "Engine not initialized");
          }
          List<String> boxes = [];
          await zeytin!.getAllBoxes(
            onSuccess: (result) {
              boxes = result;
            },
            onError: (e, s) {
              onError(e, StackTrace.fromString(s));
              res = ZeytinXResponse(
                  isSuccess: false, message: "Error", error: "$e, $s");
            },
          );
          return await processes(boxes);
        } catch (e) {
          return res;
        }
      },
    );
  }

  Future<ZeytinXResponse> add({
    required String box,
    String? tag,
    required Map<String, dynamic> value,
    bool isEncrypt = false,
    Duration? ttl,
  }) async {
    return await _run(
      () async {
        ZeytinXResponse res = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: "Unknown Error!",
        );
        String id = uuid.v4();
        await zeytin!.add(
          data: ZeytinValue(box, tag ?? id, value),
          isEncrypt: isEncrypt,
          ttl: ttl,
          onSuccess: () {
            res = ZeytinXResponse(
              isSuccess: true,
              data: ZeytinValue(box, tag ?? id, value).toMap(),
              message: "Oki Doki!",
            );
          },
          onError: (e, s) {
            res = ZeytinXResponse(
              isSuccess: false,
              message: "Error",
              error: "$e, $s",
            );
          },
        );
        return res;
      },
    );
  }

  Future<ZeytinXResponse> addBatch({
    required String box,
    String? tag,
    required List<ZeytinValue> entries,
    bool isEncrypt = false,
    Duration? ttl,
  }) async {
    return await _run(
      () async {
        ZeytinXResponse res = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: "Unknown Error!",
        );
        await zeytin!.addBatch(
          boxId: box,
          entries: entries,
          isEncrypt: isEncrypt,
          ttl: ttl,
          onSuccess: () {
            res = ZeytinXResponse(
              isSuccess: true,
              message: "Oki Doki!",
            );
          },
          onError: (e, s) {
            res = ZeytinXResponse(
              isSuccess: false,
              message: "Error",
              error: "$e, $s",
            );
          },
        );
        return res;
      },
    );
  }

  Future<ZeytinXResponse> getBox({
    required String box,
  }) async {
    return await _run(
      () async {
        ZeytinXResponse res = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: "Unknown Error!",
        );
        await zeytin!.getBox(
          boxId: box,
          onSuccess: (a) {
            Map<String, dynamic> data = {};
            for (var element in a) {
              data.addAll({element.tag: element.value});
            }
            res = ZeytinXResponse(
              isSuccess: true,
              data: data,
              message: "Oki Doki!",
            );
          },
          onError: (e, s) {
            res = ZeytinXResponse(
              isSuccess: false,
              message: "Error",
              error: "$e, $s",
            );
          },
        );
        return res;
      },
    );
  }

  Future<ZeytinXResponse> get({
    required String box,
    required String tag,
  }) async {
    return await _run(
      () async {
        ZeytinXResponse res = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: "Unknown Error!",
        );
        await zeytin!.get(
          boxId: box,
          tag: tag,
          onSuccess: (v) {
            res = ZeytinXResponse(
              isSuccess: true,
              data: v.toMap(),
              message: "Oki Doki!",
            );
          },
          onError: (e, s) {
            res = ZeytinXResponse(
              isSuccess: false,
              message: "Error",
              error: "$e, $s",
            );
          },
        );
        return res;
      },
    );
  }

  Future<ZeytinXResponse> update({
    required String box,
    required String tag,
    required Future<Map<String, dynamic>> Function(
            Map<String, dynamic> currentValue)
        value,
  }) async {
    return await _run(
      () async {
        ZeytinXResponse res = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: "Unknown Error!",
        );
        await zeytin!.get(
          boxId: box,
          tag: tag,
          onSuccess: (v) async {
            Map<String, dynamic> data = await value(v.value!);
            res = await add(box: box, tag: tag, value: data);
          },
          onError: (e, s) {
            res = ZeytinXResponse(
              isSuccess: false,
              message: "Error",
              error: "$e, $s",
            );
          },
        );

        return res;
      },
    );
  }

  Future<bool> contains({
    required String box,
    required String tag,
  }) async {
    if (zeytin == null) {
      return false;
    }
    try {
      bool res = false;
      await zeytin!.contains(
        boxId: box,
        tag: tag,
        onSuccess: (v) {
          res = v;
        },
        onError: (e, s) {
          res = false;
        },
      );
      return res;
    } catch (e) {
      return false;
    }
  }

  Future<bool> exists({
    required String box,
    required String tag,
  }) async {
    if (zeytin == null) {
      return false;
    }
    try {
      bool res = false;
      await zeytin!.existsTag(
        boxId: box,
        tag: tag,
        onSuccess: (v) {
          res = v;
        },
        onError: (e, s) {
          res = false;
        },
      );
      return res;
    } catch (e) {
      return false;
    }
  }

  Future<bool> existsBox({
    required String box,
    required String tag,
  }) async {
    if (zeytin == null) {
      return false;
    }
    try {
      bool res = false;
      await zeytin!.existsBox(
        boxId: box,
        onSuccess: (v) {
          res = v;
        },
        onError: (e, s) {
          res = false;
        },
      );
      return res;
    } catch (e) {
      return false;
    }
  }

  Future<bool> existsTruck({
    required String box,
    required String tag,
  }) async {
    if (zeytin == null) {
      return false;
    }
    try {
      bool res = false;
      await zeytin!.existsTruck(
        onSuccess: (v) {
          res = v;
        },
        onError: (e, s) {
          res = false;
        },
      );
      return res;
    } catch (e) {
      return false;
    }
  }

  Future<ZeytinXResponse> remove({
    required String box,
    required String tag,
  }) async {
    return await _run(
      () async {
        ZeytinXResponse res = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: "Unknown Error!",
        );
        await zeytin!.remove(
          boxId: box,
          tag: tag,
          onSuccess: () {
            res = ZeytinXResponse(
              isSuccess: true,
              message: "Oki Doki!",
            );
          },
          onError: (e, s) {
            res = ZeytinXResponse(
              isSuccess: false,
              message: "Error",
              error: "$e, $s",
            );
          },
        );
        return res;
      },
    );
  }

  Future<ZeytinXResponse> removeBox({
    required String box,
  }) async {
    return await _run(
      () async {
        ZeytinXResponse res = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: "Unknown Error!",
        );
        await zeytin!.removeBox(
          boxId: box,
          onSuccess: () {
            res = ZeytinXResponse(
              isSuccess: true,
              message: "Oki Doki!",
            );
          },
          onError: (e, s) {
            res = ZeytinXResponse(
              isSuccess: false,
              message: "Error",
              error: "$e, $s",
            );
          },
        );
        return res;
      },
    );
  }

  Future<ZeytinXResponse> removeTruck({
    required String box,
  }) async {
    return await _run(
      () async {
        ZeytinXResponse res = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: "Unknown Error!",
        );
        await zeytin!.removeTruck(
          onSuccess: () {
            res = ZeytinXResponse(
              isSuccess: true,
              message: "Oki Doki!",
            );
          },
          onError: (e, s) {
            res = ZeytinXResponse(
              isSuccess: false,
              message: "Error",
              error: "$e, $s",
            );
          },
        );
        return res;
      },
    );
  }

  Future<List<String>> getAllTrucks() async {
    if (zeytin == null) {
      return [];
    }
    try {
      List<String> res = [];
      await zeytin!.getAllTrucks(
        onSuccess: (result) {
          res = result;
        },
        onError: (e, s) {
          res = [];
        },
      );
      return res;
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getAllBoxes() async {
    if (zeytin == null) {
      return [];
    }
    try {
      List<String> res = [];
      await zeytin!.getAllBoxes(
        onSuccess: (result) {
          res = result;
        },
        onError: (e, s) {
          res = [];
        },
      );
      return res;
    } catch (e) {
      return [];
    }
  }

  Future<ZeytinXResponse> search({
    required String box,
    required String field,
    required String prefix,
  }) async {
    return await _run(
      () async {
        ZeytinXResponse res = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: "Unknown Error!",
        );
        await zeytin!.search(
          boxId: box,
          field: field,
          prefix: prefix,
          onSuccess: (result) {
            res = ZeytinXResponse(
              isSuccess: true,
              data: {"results": result.map((e) => e.toMap()).toList()},
              message: "Oki Doki!",
            );
          },
          onError: (e, s) {
            res = ZeytinXResponse(
              isSuccess: false,
              message: "Error",
              error: "$e, $s",
            );
          },
        );
        return res;
      },
    );
  }

  Future<ZeytinXResponse> filter({
    required String box,
    required bool Function(Map<String, dynamic>) predicate,
  }) async {
    return await _run(
      () async {
        ZeytinXResponse res = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: "Unknown Error!",
        );
        await zeytin!.filter(
          boxId: box,
          predicate: predicate,
          onSuccess: (result) {
            res = ZeytinXResponse(
              isSuccess: true,
              data: {"results": result.map((e) => e.toMap()).toList()},
              message: "Oki Doki!",
            );
          },
          onError: (e, s) {
            res = ZeytinXResponse(
              isSuccess: false,
              message: "Error",
              error: "$e, $s",
            );
          },
        );
        return res;
      },
    );
  }

  Future<ZeytinXResponse> compact() async {
    return await _run(
      () async {
        ZeytinXResponse res = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: "Unknown Error!",
        );
        await zeytin!.compact(
          onSuccess: () {
            res = ZeytinXResponse(
              isSuccess: true,
              message: "Oki Doki!",
            );
          },
          onError: (e, s) {
            res = ZeytinXResponse(
              isSuccess: false,
              message: "Error",
              error: "$e, $s",
            );
          },
        );
        return res;
      },
    );
  }

  Future<ZeytinXResponse> removeAllZeytin() async {
    return await _run(
      () async {
        ZeytinXResponse res = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: "Unknown Error!",
        );
        await zeytin!.deleteAll(
          onSuccess: () {
            res = ZeytinXResponse(
              isSuccess: true,
              message: "Oki Doki!",
            );
          },
          onError: (e, s) {
            res = ZeytinXResponse(
              isSuccess: false,
              message: "Error",
              error: "$e, $s",
            );
          },
        );
        return res;
      },
    );
  }

  Stream<Map<String, dynamic>> get observer => zeytin!.changes;
  StreamSubscription observerBox({
    required String box,
    required Function(ZeytinXOperation event) operations,
  }) {
    return observer.listen((eventMap) {
      final operation = ZeytinXOperation.fromMap(eventMap);
      if (operation.boxId == box) {
        operations(operation);
      }
    });
  }

  StreamSubscription observerTag({
    required String box,
    required String tag,
    required Function(ZeytinXOperation event) operations,
  }) {
    return observer.listen((eventMap) {
      final operation = ZeytinXOperation.fromMap(eventMap);
      if (operation.boxId == box && operation.tag == tag) {
        operations(operation);
      }
    });
  }

  Future<ZeytinXResponse> dispose() async {
    return await _run(
      () async {
        ZeytinXResponse res = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: "Unknown Error!",
        );
        await zeytin!.close(
          onSuccess: () {
            res = ZeytinXResponse(
              isSuccess: true,
              message: "Oki Doki!",
            );
          },
          onError: (e, s) {
            res = ZeytinXResponse(
              isSuccess: false,
              message: "Error",
              error: "$e, $s",
            );
          },
        );
        return res;
      },
    );
  }

  Stream<ZeytinXResponse> exportToStream({List<String>? targetBoxes}) async* {
    if (zeytin == null) {
      yield ZeytinXResponse(
          isSuccess: false, message: "Error", error: "Engine not initialized");
      return;
    }

    List<String> boxes = targetBoxes ?? [];
    if (targetBoxes == null) {
      await zeytin!.getAllTrucks(
        onSuccess: (result) {
          boxes = result;
        },
        onError: (e, s) {},
      );
    }

    for (String box in boxes) {
      ZeytinXResponse? boxResponse;
      await zeytin!.getBox(
        boxId: box,
        onSuccess: (elements) {
          Map<String, dynamic> boxContent = {};
          for (var element in elements) {
            boxContent[element.tag] = element.value;
          }
          boxResponse = ZeytinXResponse(
            isSuccess: true,
            data: {box: boxContent},
            message: "Box $box exported",
          );
        },
        onError: (e, s) {
          boxResponse = ZeytinXResponse(
            isSuccess: false,
            message: "Error on box $box",
            error: "$e, $s",
          );
        },
      );
      if (boxResponse != null) {
        yield boxResponse!;
      }
      await Future.delayed(Duration.zero);
    }
  }

  Future<ZeytinXResponse> exportToJson({List<String>? targetBoxes}) async {
    return await _run(
      () async {
        ZeytinXResponse res = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: "Unknown Error!",
        );

        List<String> boxes = targetBoxes ?? [];

        if (targetBoxes == null) {
          await zeytin!.getAllTrucks(
            onSuccess: (result) {
              boxes = result;
            },
            onError: (e, s) {},
          );
        }

        Map<String, dynamic> exportedData = {};

        for (String box in boxes) {
          await zeytin!.getBox(
            boxId: box,
            onSuccess: (elements) {
              Map<String, dynamic> boxContent = {};
              for (var element in elements) {
                boxContent[element.tag] = element.value;
              }
              exportedData[box] = boxContent;
            },
            onError: (e, s) {},
          );
        }

        res = ZeytinXResponse(
          isSuccess: true,
          data: exportedData,
          message: "Oki Doki!",
        );

        return res;
      },
    );
  }

  Future<ZeytinXResponse> importFromJson({
    required String jsonStr,
    bool isEncrypt = false,
    Duration? ttl,
  }) async {
    return await _run(
      () async {
        ZeytinXResponse res = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: "Unknown Error!",
        );

        Map<String, dynamic> importedData = jsonDecode(jsonStr);

        for (String box in importedData.keys) {
          Map<String, dynamic> boxContent = importedData[box];
          List<ZeytinValue> entries = [];

          boxContent.forEach((tag, value) {
            entries.add(ZeytinValue(box, tag, value));
          });

          if (entries.isNotEmpty) {
            await zeytin!.addBatch(
              boxId: box,
              entries: entries,
              isEncrypt: isEncrypt,
              ttl: ttl,
              onSuccess: () {},
              onError: (e, s) {
                throw Exception("Batch add error in box $box: $e, $s");
              },
            );
          }
        }

        res = ZeytinXResponse(
          isSuccess: true,
          message: "Oki Doki!",
        );

        return res;
      },
    );
  }
}

class ZeytinXMiner {
  ZeytinX x;
  ZeytinXMiner(this.x);

  Map<String, Map<String, dynamic>> datas = {};
  List<String> boxes = [];
  List<StreamSubscription> streamers = [];

  Future<void> _listener() async {
    boxes = await x.getAllTrucks();
    for (var element in boxes) {
      final subscription = x.observerBox(
        box: element,
        operations: (event) {
          if (event.type != ZeytinOpType.deleteBox &&
              event.type != ZeytinOpType.clearAll) {
            datas[element] ??= {};
          }

          switch (event.type) {
            case ZeytinOpType.put:
              if (event.tag != null && event.value != null) {
                datas[element]![event.tag!] = event.value!.value;
              }
              break;
            case ZeytinOpType.delete:
              if (event.tag != null) {
                datas[element]?.remove(event.tag);
              }
              break;
            case ZeytinOpType.deleteBox:
              datas.remove(element);
              break;
            case ZeytinOpType.batch:
              if (event.batchEntries != null) {
                for (var entry in event.batchEntries!) {
                  datas[element]![entry.tag] = entry.value;
                }
              }
              break;
            case ZeytinOpType.clearAll:
              datas.clear();
              break;
          }
        },
      );

      streamers.add(subscription);
    }
  }

  void assignWorkers() {
    final workerSub = x.exportToStream().listen(
      (event) {
        if (!event.isSuccess || event.data == null) return;
        for (var entry in event.data!.entries) {
          datas[entry.key] = Map<String, dynamic>.from(entry.value as Map);
        }
      },
      onDone: () {
        _listener();
      },
    );

    streamers.add(workerSub);
  }

  Map<String, dynamic>? get(String box, String tag) {
    return datas[box]?[tag];
  }

  Map<String, dynamic>? getBox(String box) {
    return datas[box];
  }

  bool containsBox(String box) {
    return datas.containsKey(box);
  }

  bool containsTag(String box, String tag) {
    return datas[box]?.containsKey(tag) ?? false;
  }

  List<String> get loadedBoxes {
    return datas.keys.toList();
  }

  List<Map<String, dynamic>> filter(
    String box,
    bool Function(Map<String, dynamic>) predicate,
  ) {
    final boxData = datas[box];
    if (boxData == null) return [];

    return boxData.values
        .where((value) => value is Map<String, dynamic> && predicate(value))
        .cast<Map<String, dynamic>>()
        .toList();
  }

  void dispose() {
    for (var sub in streamers) {
      sub.cancel();
    }
    streamers.clear();
  }
}
