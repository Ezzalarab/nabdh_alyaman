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
      isShown: fields[2]?.toString() ?? "",
      isShownPhone: fields[4]?.toString() ?? "",
      isGpsOn: fields[3]?.toString() ?? "",
      name: fields[0]?.toString() ?? "",
      bloodType: fields[1]?.toString() ?? "",
      satae: fields[7]?.toString() ?? "",
      district: fields[6]?.toString() ?? "",
      neighborhood: fields[8]?.toString() ?? "",
      date: fields[5]?.toString() ?? "",
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
