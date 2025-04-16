// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatbot_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatbotListAdapter extends TypeAdapter<ChatbotList> {
  @override
  final int typeId = 0;

  @override
  ChatbotList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatbotList(
      createdDatetime: fields[1] as int,
    )
      ..messages = (fields[0] as List).cast<ChatbotMsg>()
      ..listName = fields[2] as String?;
  }

  @override
  void write(BinaryWriter writer, ChatbotList obj) {
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
      other is ChatbotListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
