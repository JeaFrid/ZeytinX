import 'dart:async';

import 'package:uuid/uuid.dart';
import 'package:zeytin_local_storage/zeytin_local_storage.dart';
import 'package:zeytinx/src/utils/operation.dart';
import 'package:zeytinx/zeytinx.dart';

class ZeytinX {
  final String namespace;
  final String truckID;
  final String basePath;
  ZeytinX(this.namespace, this.basePath, this.truckID);
  Uuid uuid = Uuid();
  ZeytinStorage? zeytin;
  Future<void> initialize(String basePath) async {
    zeytin = ZeytinStorage(namespace: namespace, truckID: truckID);
    await zeytin!.initialize(basePath);
  }

  Future<ZeytinXResponse> _run(
      Future<ZeytinXResponse> Function() action) async {
    if (zeytin == null) {
      return ZeytinXResponse(
          isSuccess: false, message: "Error", error: "Engine not initialized");
    }
    try {
      return await action();
    } catch (e, s) {
      return ZeytinXResponse(
          isSuccess: false, message: "Error", error: "$e, $s");
    }
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
        await zeytin!.add(
          data: ZeytinValue(box, tag ?? uuid.v4(), value),
          isEncrypt: isEncrypt,
          ttl: ttl,
          onSuccess: () {
            res = ZeytinXResponse(
              isSuccess: true,
              data: value,
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
    String? tag,
    required List<ZeytinValue> entries,
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
}
