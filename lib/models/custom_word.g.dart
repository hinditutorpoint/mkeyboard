// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_word.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomWordAdapter extends TypeAdapter<CustomWord> {
  @override
  final int typeId = 1;

  @override
  CustomWord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomWord(
      englishWord: fields[0] as String,
      translatedWord: fields[1] as String,
      languageIndex: fields[2] as int,
      usageCount: fields[3] == null ? 0 : fields[3] as int,
      createdAt: fields[4] as DateTime,
      lastUsed: fields[5] as DateTime?,
      isPinned: fields[6] == null ? false : fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CustomWord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.englishWord)
      ..writeByte(1)
      ..write(obj.translatedWord)
      ..writeByte(2)
      ..write(obj.languageIndex)
      ..writeByte(3)
      ..write(obj.usageCount)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.lastUsed)
      ..writeByte(6)
      ..write(obj.isPinned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomWordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
