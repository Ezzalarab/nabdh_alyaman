// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donor_hive_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DonorDataOnHiveAdapter extends TypeAdapter<DonorDataOnHive> {
  @override
  final int typeId = 0;

  @override
  DonorDataOnHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DonorDataOnHive(
      isShown: fields[2] as String,
      isShownPhone: fields[4] as String,
      isGpsOn: fields[3] as String,
      name: fields[0] as String,
      bloodType: fields[1] as String,
      satae: fields[7] as String,
      district: fields[6] as String,
      neighborhood: fields[8] as String,
      date: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DonorDataOnHive obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.bloodType)
      ..writeByte(2)
      ..write(obj.isShown)
      ..writeByte(3)
      ..write(obj.isGpsOn)
      ..writeByte(4)
      ..write(obj.isShownPhone)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.district)
      ..writeByte(7)
      ..write(obj.satae)
      ..writeByte(8)
      ..write(obj.neighborhood);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DonorDataOnHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
