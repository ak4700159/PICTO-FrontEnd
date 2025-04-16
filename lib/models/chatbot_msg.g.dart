// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatbot_msg.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatbotMsgAdapter extends TypeAdapter<ChatbotMsg> {
  @override
  final int typeId = 1;

  @override
  ChatbotMsg read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatbotMsg(
      sendDatetime: fields[0] as int,
      content: fields[1] as int,
      isMe: fields[2] as bool,
      imagePath: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChatbotMsg obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.sendDatetime)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.isMe)
      ..writeByte(3)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatbotMsgAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
