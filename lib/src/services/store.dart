import 'package:uuid/uuid.dart';
import 'package:zeytin_local_storage/zeytin_local_storage.dart';
import 'package:zeytinx/zeytinx.dart';

class ZeytinXStore {
  final ZeytinStorage zeytin;
  static const String _box = 'stores';
  final _uuid = const Uuid();

  ZeytinXStore(this.zeytin);

  Future<ZeytinXResponse> createStore({
    required ZeytinXStoreModel storeModel,
  }) async {
    String id = _uuid.v1();
    var newStore = storeModel.copyWith(id: id, createdAt: DateTime.now());
    ZeytinXResponse? response;

    await zeytin.add(
      data: ZeytinValue(_box, id, newStore.toJson()),
      onSuccess: () {
        response = ZeytinXResponse(
          isSuccess: true,
          message: "ok",
          data: newStore.toJson(),
        );
      },
      onError: (e, s) {
        response = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: e.toString(),
        );
      },
    );

    return response ??
        ZeytinXResponse(isSuccess: false, message: "Unknown error");
  }

  Future<ZeytinXResponse> deleteStore({required String id}) async {
    ZeytinXResponse? response;

    await zeytin.remove(
      boxId: _box,
      tag: id,
      onSuccess: () {
        response = ZeytinXResponse(isSuccess: true, message: "ok");
      },
      onError: (e, s) {
        response = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: e.toString(),
        );
      },
    );

    return response ??
        ZeytinXResponse(isSuccess: false, message: "Unknown error");
  }

  Future<ZeytinXResponse> updateStore({
    required String id,
    required ZeytinXStoreModel storeModel,
  }) async {
    ZeytinXResponse? response;
    var newStore = storeModel.copyWith(id: id);

    await zeytin.add(
      data: ZeytinValue(_box, id, newStore.toJson()),
      onSuccess: () {
        response = ZeytinXResponse(
          isSuccess: true,
          message: "ok",
          data: newStore.toJson(),
        );
      },
      onError: (e, s) {
        response = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: e.toString(),
        );
      },
    );

    return response ??
        ZeytinXResponse(isSuccess: false, message: "Unknown error");
  }

  Future<ZeytinXStoreModel> getStore({required String id}) async {
    ZeytinXStoreModel? store;

    await zeytin.get(
      boxId: _box,
      tag: id,
      onSuccess: (result) {
        if (result.value != null) {
          store = ZeytinXStoreModel.fromJson(result.value!);
        }
      },
      onError: (e, s) {},
    );
    return store ?? ZeytinXStoreModel.empty();
  }

  Future<List<ZeytinXStoreModel>> getAllStores() async {
    List<ZeytinXStoreModel> list = [];

    await zeytin.getBox(
      boxId: _box,
      onSuccess: (results) {
        for (var element in results) {
          if (element.value != null) {
            list.add(ZeytinXStoreModel.fromJson(element.value!));
          }
        }
      },
      onError: (e, s) {
        ZeytinXPrint.errorPrint(e.toString());
      },
    );

    return list;
  }
}
