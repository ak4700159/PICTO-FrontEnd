// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comfyui_result_photo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ComfyuiResultPhotoAdapter extends TypeAdapter<ComfyuiResultPhoto> {
  @override
  final int typeId = 4;

  @override
  ComfyuiResultPhoto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ComfyuiResultPhoto(
      type: fields[0] as ComfyuiPhotoType,
      data: fields[1] as Uint8List,
      createdTime: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ComfyuiResultPhoto obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.createdTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComfyuiResultPhotoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ComfyuiPhotoTypeAdapter extends TypeAdapter<ComfyuiPhotoType> {
  @override
  final int typeId = 5;

  @override
  ComfyuiPhotoType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ComfyuiPhotoType.removing;
      case 1:
        return ComfyuiPhotoType.upscaling;
      default:
        return ComfyuiPhotoType.removing;
    }
  }

  @override
  void write(BinaryWriter writer, ComfyuiPhotoType obj) {
    switch (obj) {
      case ComfyuiPhotoType.removing:
        writer.writeByte(0);
        break;
      case ComfyuiPhotoType.upscaling:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComfyuiPhotoTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
