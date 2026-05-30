import 'package:flutter_test/flutter_test.dart';
import 'package:nabdh_alyaman/data/models/donor_profile_dto.dart';

void main() {
  test('DonorProfileDto maps API JSON to Donor entity', () {
    final dto = DonorProfileDto.fromJson({
      'userId': 42,
      'fullName': 'أحمد',
      'bloodType': 'O+',
      'birthDate': '1990-05-01',
      'isShown': true,
      'isPhoneShown': false,
      'isGpsOn': true,
      'stateId': 100,
      'districtId': 1001,
      'lat': 15.37,
      'lon': 44.19,
      'imageUrl': '99',
      'user': {
        'phone': '967771234567',
        'email': 'a@b.com',
        'emailMissing': false,
        'emailVerified': true,
      },
    });

    final donor = dto.toDonor();
    expect(donor.id, '42');
    expect(donor.name, 'أحمد');
    expect(donor.phone, '967771234567');
    expect(donor.email, 'a@b.com');
    expect(donor.emailMissing, false);
    expect(donor.emailVerified, true);
    expect(donor.bloodType, 'O+');
    expect(donor.isShown, '1');
    expect(donor.isShownPhone, '0');
    expect(donor.isGpsOn, '1');
    expect(donor.state, '100');
    expect(donor.district, '1001');
  });
}
