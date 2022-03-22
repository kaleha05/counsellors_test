final String messageTable = 'chats';

class MessageFields {
  static final List<String> values = [
    /// Add all fields
    id, senderId, message, receiverId
  ];

  static final String id = '_id';
  static final String senderId = 'senderId';
  static final String message = 'text';
  static final String receiverId = 'receiverId';
}

class TextMsg {
  final String id;
  final String senderId;
  final String message;
  final String receiverId;

  const TextMsg({
    required this.id,
    required this.senderId,
    required this.message,
    required this.receiverId
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': senderId,
      'message': message,
      'receiver': receiverId
    };
  }

  TextMsg copy({
    required String id,
    required String senderId,
    required String message,
    required String receiverId
  }) =>
      TextMsg(
          id: id,
          senderId: senderId,
          message: message,
          receiverId: receiverId
      );

  // converts message from json to text message format
  static TextMsg fromJson(Map<String, Object?> json) => TextMsg(
      id: json[MessageFields.id] as String,
      senderId: json[MessageFields.senderId] as String,
      message: json[MessageFields.message] as String,
      receiverId: json[MessageFields.receiverId] as String
  );

  //converts message to json
  Map<String, Object> toJson() => {
    MessageFields.id: id,
    MessageFields.senderId: senderId,
    MessageFields.message: message,
    MessageFields.receiverId: receiverId
  };

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Message{id: $id, sender: $senderId, message: $message, receiver: $receiverId}';
  }
}