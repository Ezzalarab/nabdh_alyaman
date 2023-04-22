import 'package:hive/hive.dart';

part 'donor_hive_data.g.dart';

@HiveType(typeId: 0)
class DonorDataOnHive extends HiveObject {
  @HiveField(0)
  late String? name;
  @HiveField(1)
  late String? bloodType;
  @HiveField(2)
  late String? isShown;
  @HiveField(3)
  late String? isGpsOn;
  @HiveField(4)
  late String? isShownPhone;
  @HiveField(5)
  late String? date;
  @HiveField(6)
  late String? district;
  @HiveField(7)
  late String? satae;
  @HiveField(8)
  late String? neighborhood;

  DonorDataOnHive(
      {this.isShown,
      this.isShownPhone,
      this.isGpsOn,
      this.name,
      this.bloodType,
      this.satae,
      this.district,
      this.neighborhood,
      this.date});
}
