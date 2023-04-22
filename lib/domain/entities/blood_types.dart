class BloodTypes {
  static const bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  static List<String> canReceiveFrom({required String bloodType}) {
    List<String> compatibleBLoodTypes = [];
    switch (bloodType) {
      case 'A+':
        compatibleBLoodTypes = [
          'A+',
          'A-',
          'O+',
          'O-',
        ];
        break;
      case 'A-':
        compatibleBLoodTypes = [
          'A-',
          'O-',
        ];
        break;
      case 'B+':
        compatibleBLoodTypes = [
          'B+',
          'B-',
          'O+',
          'O-',
        ];
        break;
      case 'B-':
        compatibleBLoodTypes = [
          'B-',
          'O-',
        ];
        break;
      case 'AB+':
        compatibleBLoodTypes = [
          'AB+',
          'AB-',
          'A+',
          'A-',
          'B+',
          'B-',
          'O+',
          'O-',
        ];
        break;
      case 'AB-':
        compatibleBLoodTypes = [
          'AB-',
          'A-',
          'B-',
          'O-',
        ];
        break;
      case 'O+':
        compatibleBLoodTypes = [
          'O+',
          'O-',
        ];
        break;
      case 'O-':
        compatibleBLoodTypes = [
          'O-',
        ];
        break;
      default:
        compatibleBLoodTypes = [
          'O-',
        ];
        break;
    }
    return compatibleBLoodTypes;
  }
}
