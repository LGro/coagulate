// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactRecordAdapter extends TypeAdapter<ContactRecord> {
  @override
  final int typeId = 1;

  @override
  ContactRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContactRecord(
      schemaVersion: fields[0] as int,
      coagContactJson: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ContactRecord obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.schemaVersion)
      ..writeByte(1)
      ..write(obj.coagContactJson);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
