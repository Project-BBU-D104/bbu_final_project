// import 'package:flutter/material.dart';
// import 'package:frontend/controllers/supplier_controller.dart';
// import 'package:get/get.dart';

// class SupplierBottomAction extends StatelessWidget {
//   const SupplierBottomAction({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final SupplierController controller = Get.find<SupplierController>();

//     return Obx(() {
//       final isEdit = controller.isEditMode.value;

//       return Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50.0),
//         color: const Color.fromARGB(255, 255, 255, 255),
//         child: Row(
//           children: [
//             Expanded(
//               child: TextButton(
//                 onPressed: () => controller.cancelAction(),
//                 child: Text(
//                   isEdit ? "Cancel" : "CANCEL",
//                   style: const TextStyle(
//                     color: Color.fromARGB(255, 235, 67, 67),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               flex: 2,
//               child: ElevatedButton.icon(
//                 onPressed: () => controller.saveAction(),
//                 icon: Icon(
//                   isEdit ? Icons.edit_document : Icons.save_rounded,
//                   color: Colors.black,
//                 ),
//                 label: Text(
//                   isEdit ? "Save Changes" : "Save Supplier",
//                   style: const TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(255, 51, 225, 161),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }
