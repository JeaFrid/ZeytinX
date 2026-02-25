import 'dart:async';
import 'dart:io';
import 'package:test/test.dart';
import 'package:zeytin_local_storage/zeytin_local_storage.dart';
import 'package:zeytinx/zeytinx.dart';

void main() {
  late ZeytinStorage zeytin;
  late ZeytinXUser userService;
  late ZeytinXSocial socialService;
  late ZeytinXChat chatService;
  late ZeytinXCommunity communityService;

  final String testDbPath = "./zeytinx_test_db";

  setUpAll(() async {
    zeytin = ZeytinStorage(namespace: "test_namespace", truckID: "test_truck");

    await zeytin.initialize(testDbPath);

    userService = ZeytinXUser(zeytin);
    socialService = ZeytinXSocial(zeytin);
    chatService = ZeytinXChat(zeytin);
    communityService = ZeytinXCommunity(zeytin);
  });

  tearDownAll(() async {
    final completer = Completer<void>();
    await zeytin.deleteAll(
      onSuccess: () => completer.complete(),
      onError: (e, s) => completer.completeError(e),
    );
    await completer.future;

    final dir = Directory(testDbPath);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });

  group('User Service Tests', () {
    test('Should create a new user', () async {
      var response = await userService.create(
        "test_user",
        "test@mail.com",
        "password123",
      );

      expect(response.isSuccess, isTrue);
      expect(response.data, isNotNull);
      expect(response.data!['username'], equals('test_user'));
    });

    test('Should not allow duplicate email registration', () async {
      var response = await userService.create(
        "test_user2",
        "test@mail.com",
        "password123",
      );

      expect(response.isSuccess, isFalse);
      expect(response.message, equals("Email available"));
    });

    test('Should login successfully', () async {
      var response = await userService.login("test@mail.com", "password123");

      expect(response.isSuccess, isTrue);
      expect(response.data!['email'], equals('test@mail.com'));
    });
  });

  group('Social Service Tests', () {
    late ZeytinXUserModel mockUser;

    setUpAll(() async {
      var res = await userService.create(
        "social_user",
        "social@mail.com",
        "123456",
      );
      mockUser = ZeytinXUserModel.fromJson(res.data!);
    });

    test('Should create a post and like it', () async {
      var postModel = ZeytinXSocialModel(
        user: mockUser,
        text: "Unit test post",
      );

      var createRes = await socialService.createPost(postModel: postModel);
      expect(createRes.isSuccess, isTrue);

      String postId = createRes.data!['id'];

      var likeRes = await socialService.addLike(user: mockUser, postID: postId);
      expect(likeRes.isSuccess, isTrue);

      var fetchedPost = await socialService.getPost(id: postId);
      expect(fetchedPost.likes, contains(mockUser.uid));
    });
  });

  group('Chat Service Tests', () {
    late ZeytinXUserModel userA;
    late ZeytinXUserModel userB;

    setUpAll(() async {
      userA = ZeytinXUserModel.fromJson(
        (await userService.create("Chat_A", "a@chat.com", "123456")).data!,
      );
      userB = ZeytinXUserModel.fromJson(
        (await userService.create("Chat_B", "b@chat.com", "123456")).data!,
      );
    });

    test('Should create a private chat and send a message', () async {
      var chatRes = await chatService.createChat(
        chatName: "Test Chat",
        participants: [userA, userB],
        type: ZeytinXChatType.private,
      );

      expect(chatRes.isSuccess, isTrue);
      String chatId = chatRes.data!['chatID'];

      var msgRes = await chatService.sendMessage(
        chatId: chatId,
        sender: userA,
        text: "Hello",
      );

      expect(msgRes.isSuccess, isTrue);

      var messages = await chatService.getMessages(chatId: chatId);
      expect(messages.length, greaterThanOrEqualTo(1));
      expect(messages.first.text, equals("Hello"));
    });
  });

  group('Community Service Tests', () {
    late ZeytinXUserModel adminUser;

    setUpAll(() async {
      adminUser = ZeytinXUserModel.fromJson(
        (await userService.create("Admin", "admin@com.com", "123456")).data!,
      );
    });

    test('Should create a community and a room', () async {
      var comRes = await communityService.createCommunity(
        name: "Flutter Developers",
        creator: adminUser,
        participants: [adminUser],
      );

      expect(comRes.isSuccess, isTrue);
      String comId = comRes.data!['id'];

      var roomRes = await communityService.createRoom(
        communityId: comId,
        admin: adminUser,
        roomName: "General",
      );

      expect(roomRes.isSuccess, isTrue);

      var rooms = await communityService.getCommunityRooms(communityId: comId);
      expect(rooms.length, equals(1));
      expect(rooms.first.name, equals("General"));
    });
  });
}
