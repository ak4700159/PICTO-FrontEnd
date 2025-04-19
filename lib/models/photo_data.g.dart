// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhotoDataAdapter extends TypeAdapter<PhotoData> {
  @override
  final int typeId = 2;

  @override
  PhotoData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PhotoData(
      photoId: fields[0] as int?,
      data: fields[1] as Uint8List,
      contentType: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PhotoData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.photoId)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.contentType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
