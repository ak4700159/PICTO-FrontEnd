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
      content: fields[1] as String,
      isMe: fields[2] as bool,
      images: (fields[3] as List).cast<PhotoData>(),
      status: fields[4] as ChatbotStatus,
    );
  }

  @override
  void write(BinaryWriter writer, ChatbotMsg obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.sendDatetime)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.isMe)
      ..writeByte(3)
      ..write(obj.images)
      ..writeByte(4)
      ..write(obj.status);
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

class ChatbotStatusAdapter extends TypeAdapter<ChatbotStatus> {
  @override
  final int typeId = 3;

  @override
  ChatbotStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChatbotStatus.sending;
      case 1:
        return ChatbotStatus.isMe;
      case 2:
        return ChatbotStatus.compare;
      case 3:
        return ChatbotStatus.analysis;
      case 4:
        return ChatbotStatus.recommend;
      case 5:
        return ChatbotStatus.intro;
      default:
        return ChatbotStatus.sending;
    }
  }

  @override
  void write(BinaryWriter writer, ChatbotStatus obj) {
    switch (obj) {
      case ChatbotStatus.sending:
        writer.writeByte(0);
        break;
      case ChatbotStatus.isMe:
        writer.writeByte(1);
        break;
      case ChatbotStatus.compare:
        writer.writeByte(2);
        break;
      case ChatbotStatus.analysis:
        writer.writeByte(3);
        break;
      case ChatbotStatus.recommend:
        writer.writeByte(4);
        break;
      case ChatbotStatus.intro:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatbotStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
