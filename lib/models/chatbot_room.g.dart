// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatbot_room.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatbotRoomAdapter extends TypeAdapter<ChatbotRoom> {
  @override
  final int typeId = 0;

  @override
  ChatbotRoom read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatbotRoom(
      createdDatetime: fields[1] as int,
    )
      ..messages = (fields[0] as List).cast<ChatbotMsg>()
      ..listName = fields[2] as String?;
  }

  @override
  void write(BinaryWriter writer, ChatbotRoom obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.messages)
      ..writeByte(1)
      ..write(obj.createdDatetime)
      ..writeByte(2)
      ..write(obj.listName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatbotRoomAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
