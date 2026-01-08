// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyboard_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KeyboardSettingsAdapter extends TypeAdapter<KeyboardSettings> {
  @override
  final int typeId = 0;

  @override
  KeyboardSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KeyboardSettings(
      hapticFeedback: fields[0] == null ? true : fields[0] as bool,
      soundOnKeyPress: fields[1] == null ? false : fields[1] as bool,
      showSuggestions: fields[2] == null ? true : fields[2] as bool,
      autoCapitalize: fields[3] == null ? true : fields[3] as bool,
      showNumberRow: fields[4] == null ? true : fields[4] as bool,
      keyHeight: fields[5] == null ? 48.0 : fields[5] as double,
      fontSize: fields[6] == null ? 18.0 : fields[6] as double,
      themeName: fields[7] == null ? 'Light' : fields[7] as String,
      defaultLanguageIndex: fields[8] == null ? 0 : fields[8] as int,
      swipeToDelete: fields[9] == null ? true : fields[9] as bool,
      longPressForSymbols: fields[10] == null ? true : fields[10] as bool,
      suggestionCount: fields[11] == null ? 5 : fields[11] as int,
      showPreview: fields[12] == null ? true : fields[12] as bool,
      keySpacing: fields[13] == null ? 4.0 : fields[13] as double,
      enableGlideTyping: fields[14] == null ? false : fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, KeyboardSettings obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.hapticFeedback)
      ..writeByte(1)
      ..write(obj.soundOnKeyPress)
      ..writeByte(2)
      ..write(obj.showSuggestions)
      ..writeByte(3)
      ..write(obj.autoCapitalize)
      ..writeByte(4)
      ..write(obj.showNumberRow)
      ..writeByte(5)
      ..write(obj.keyHeight)
      ..writeByte(6)
      ..write(obj.fontSize)
      ..writeByte(7)
      ..write(obj.themeName)
      ..writeByte(8)
      ..write(obj.defaultLanguageIndex)
      ..writeByte(9)
      ..write(obj.swipeToDelete)
      ..writeByte(10)
      ..write(obj.longPressForSymbols)
      ..writeByte(11)
      ..write(obj.suggestionCount)
      ..writeByte(12)
      ..write(obj.showPreview)
      ..writeByte(13)
      ..write(obj.keySpacing)
      ..writeByte(14)
      ..write(obj.enableGlideTyping);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyboardSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
