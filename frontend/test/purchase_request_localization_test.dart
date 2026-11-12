import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/localization/en_us.dart';
import 'package:frontend/localization/km_kh.dart';

const purchaseRequestKeys = [
  'Purchase Requests',
  'Manage purchase requests.',
  'Search Purchase Requests',
  'Add Purchase Request',
  'Edit Purchase Request',
  'Purchase Request Detail',
  'Request details',
  'Requested Items',
  'Add Item',
  'Edit Request',
  'Delete request',
  'Request Type',
  'Requested By',
  'Approved By',
  'Request Date',
  'Approved Date',
  'Request type is required',
  'Requester is required',
  'Approver is required',
  'Reason is required',
  'Select a warehouse',
  'Select a product',
  'Enter a quantity greater than zero',
  'Enter a unit',
  'Choose a product and enter a unit and quantity for each item',
  'Do you want to delete this purchase request?',
  'No items in this request',
  'No purchase requests yet',
  'No matching purchase requests',
  'Unable to load purchase requests. Please try again.',
  'Unable to save purchase request. Please try again.',
  'Unable to open purchase request. Please try again.',
  'Unable to delete purchase request. Please try again.',
  'Purchase request created successfully',
  'Purchase request updated successfully',
  'Purchase request deleted successfully',
  'Pending',
  'Approved',
  'Rejected',
  'Request Details',
  'Create Request',
  'Save Changes',
  'Item',
  'Remove item',
  'Request No',
];

void main() {
  test('purchase request copy exists in English and Khmer', () {
    for (final key in purchaseRequestKeys) {
      expect(enUS[key], isNotNull, reason: key);
      expect(kmKH[key], isNotNull, reason: key);
      expect(kmKH[key], isNot(key), reason: key);
    }
  });
}
