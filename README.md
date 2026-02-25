# ZeytinX🫒

_Developed with love by JeaFriday!_

ZeytinX is a comprehensive local data management and module library prepared to develop large-scale applications (social media, e-commerce, forum, messaging, community, etc.) using the [zeytin_local_storage](https://pub.dev/packages/zeytin_local_storage) infrastructure.

This package provides user management, real-time chat, social feed, product/store management, notification system, and more under a single roof through standardized models and services.

## Features

ZeytinX offers the following core services and models out of the box:

- **User Management (`ZeytinXUser`)**: Registration, login, profile update, follow/unfollow, blocking, and activity status tracking.
- **Social Media (`ZeytinXSocial`)**: Post creation, liking, commenting, and comment likes.
- **Chat and Messaging (`ZeytinXChat`)**: One-on-one and group chats, text/media messages, reactions, read/delivered status, message pinning, and system messages (e.g., "User joined"). Real-time stream listening support.
- **Community Management (`ZeytinXCommunity`)**: Community creation, sub-rooms (text/voice), invite code creation and validation, announcement boards.
- **E-Commerce (`ZeytinXProducts` & `ZeytinXStore`)**: Store and product creation, product view count, review, and like system.
- **Notification System (`ZeytinXNotificationService`)**: General and in-app notification dispatch, mark as read.
- **Forum (`ZeytinXForum`)**: Category management, thread creation, adding entries to a thread, pinning, locking, and marking as solved.
- **Library / Books (`ZeytinXLibrary`)**: Book and chapter addition, searching by ISBN, reviewing and liking books.

## Installation

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  zeytinx: ^1.0.0
  zeytin_local_storage: ^1.0.0 # ZeytinX's dependency
```

Include it in the project:

```dart
import 'package:zeytinx/zeytinx.dart';
```

## Initialization and Configuration

ZeytinX services require a `ZeytinStorage` object, which is the core data storage unit. You can initialize all services over a single storage reference at the start of your project.

```dart
import 'package:zeytin_local_storage/zeytin_local_storage.dart';
import 'package:zeytinx/zeytinx.dart';

void main() async {
  // Storage initialization
  final storage = ZeytinStorage();

  // Building services
  final userService = ZeytinXUser(storage);
  final chatService = ZeytinXChat(storage);
  final socialService = ZeytinXSocial(storage);

  // App startup...
}
```

## Use Cases

All operations standardly return a `ZeytinXResponse` object. This object contains whether the operation was successful (`isSuccess`), the message, the returned data if any (`data`), and errors (`error`).

### 1. User Operations (Registration, Login, Follow)

Provides user registration, login operations, and profile management.

```dart
// User Registration
ZeytinXResponse response = await userService.create(
  "johndoe",
  "john@example.com",
  "password123"
);

if (response.isSuccess) {
  ZeytinXPrint.successPrint("User created!");
  var newUser = ZeytinXUserModel.fromJson(response.data!);
} else {
  ZeytinXPrint.errorPrint(response.error ?? "Unknown error");
}

// User Login
var loginRes = await userService.login("john@example.com", "password123");

// Follow User
await userService.followUser(
  myUid: "my_id",
  targetUid: "target_user_id"
);
```

### 2. Chat System

You can create private or group messaging, and listen to live messages with a stream structure.

```dart
// Creating a new private chat
var chatRes = await chatService.createChat(
  chatName: "Private Chat",
  participants: [myUser, targetUser],
  type: ZeytinXChatType.private,
);

// Sending a Message
await chatService.sendMessage(
  chatId: chatRes.data!["chatID"],
  sender: myUser,
  text: "Hello, how are you?",
  messageType: ZeytinXMessageType.text,
);

// Listening to Messages Live (Stream)
chatService.listen(
  chatId: "chat_id",
  onMessageReceived: (message) {
    print("New message: ${message.text}");
  },
  onMessageUpdated: (message) {
    print("Message edited: ${message.text}");
  },
  onMessageDeleted: (messageId) {
    print("Message deleted: $messageId");
  }
);

// Adding Reaction to a Message
await chatService.addReaction(
  messageId: "message_id",
  userId: myUser.uid,
  emoji: "👍"
);
```

### 3. Social Media (Feed and Posts)

Post sharing, like, and comment scenarios.

```dart
// Post Creation
var postModel = ZeytinXSocialModel(
  user: myUser,
  text: "The weather is very nice today!",
  category: "General",
);

await socialService.createPost(postModel: postModel);

// Liking a Post
await socialService.addLike(user: myUser, postID: "post_id");

// Commenting
var comment = ZeytinXSocialCommentsModel(
  user: myUser,
  text: "I totally agree!",
);
await socialService.addComment(comment: comment, postID: "post_id");
```

### 4. Community and Invite Codes

It is the foundation of Discord / Slack-like structures.

```dart
// Community Creation
var communityRes = await communityService.createCommunity(
  name: "Flutter Developers",
  creator: myUser,
  participants: [myUser],
  description: "Everything about Flutter."
);

String communityId = communityRes.data!["id"];

// Owning a Room
await communityService.createRoom(
  communityId: communityId,
  admin: myUser,
  roomName: "General Chat",
  type: ZeytinXRoomType.text,
);

// Generating Invite Code (Valid for 2 hours, 10 uses)
var inviteRes = await communityService.createInviteCode(
  communityId: communityId,
  admin: myUser,
  duration: Duration(hours: 2),
  maxUses: 10,
);

String inviteCode = inviteRes.data!["code"];

// User Joining with Invite Code
var validateRes = await communityService.validateInviteCode(code: inviteCode);
if(validateRes.isSuccess) {
  await communityService.useInviteCode(code: inviteCode);
  await communityService.joinCommunity(communityId: communityId, user: newUser);
}
```

### 5. Notifications

You can send in-app or general log notifications to users.

```dart
await notificationService.sendInAppNotification(
  title: "New Message",
  description: "Ahmet sent you a message.",
  tag: "chat_notification",
  targetUserIds: ["target_user_id"],
);

// Get Unread
var unread = await notificationService.getPendingInAppNotifications("user_id");

// Mark as read
await notificationService.markAsSeen(
  notificationId: "notification_id",
  userId: "user_id"
);
```

### 6. Forum Management

Used to create categorized message boards.

```dart
// Add Category
var category = ZeytinXForumCategoryModel(
  id: "",
  title: "Software",
  description: "Software development discussions"
);
await forumService.createCategory(categoryModel: category);

// Open a Thread
var thread = ZeytinXForumThreadModel(
  id: "",
  categoryId: "category_id",
  user: myUser,
  title: "How to Use ZeytinX?",
  content: "About package content and usage...",
);
await forumService.createThread(threadModel: thread);

// Write an Entry to a Thread
var entry = ZeytinXForumEntryModel(
  id: "",
  threadId: "thread_id",
  user: myUser,
  text: "The documentation is very explanatory, thanks.",
);
await forumService.addEntry(entry: entry, threadId: "thread_id");
```

## Utility Classes (Utils)

### ZeytinXResponse

All service methods provide a standardized return type:

- `isSuccess`: Whether the operation was successful (`bool`).
- `message`: Operation result message (`String`).
- `data`: Returned data (`Map<String, dynamic>?`).
- `error`: Error details if any (`String?`).

### Console Outputs (ZeytinXPrint)

You can use the `ZeytinXPrint` class for colorful logging in the terminal:

```dart
ZeytinXPrint.successPrint("Operation successful."); // Green outputs
ZeytinXPrint.errorPrint("An error occurred."); // Red outputs
ZeytinXPrint.warningPrint("Warning, missing data."); // Yellow outputs
```

### Date Formatting Extension

A `.timeAgo` extension has been added to `DateTime` objects. It provides easy usage in social media feeds.

````dart
DateTime date = DateTime.now().subtract(Duration(hours: 2));
print(date.timeAgo); // Output: "2 hours ago"
```# ZeytinX
````
