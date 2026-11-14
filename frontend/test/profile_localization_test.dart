import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/localization/en_us.dart';
import 'package:frontend/localization/km_kh.dart';

const editKeys = ['Edit Profile', 'Update your personal and contact information.',
  'Personal information', 'Contact details', 'Full Name', 'Email Address',
  'Phone Number', 'Photo URL', 'Name is required', 'Enter a valid email', 'Save',
  'Cancel', 'Close', 'Saving...', 'Profile updated successfully'];
void main() {
  for (final key in editKeys) {
    test('account form translates $key', () {
      expect(enUS[key], isNotEmpty);
      expect(kmKH[key], isNotEmpty);
      expect(kmKH[key], isNot(key));
    });
  }
}
