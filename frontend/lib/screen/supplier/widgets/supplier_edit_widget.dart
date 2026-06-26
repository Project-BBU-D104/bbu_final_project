// import 'package:flutter/material.dart';
// import 'package:frontend/controllers/supplier_controller.dart';
// import 'package:get/get.dart';

// class SupplierEditForm extends StatelessWidget {
//   const SupplierEditForm({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final SupplierController controller = Get.find<SupplierController>();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Color(0xFF161A26),
//               ),
//               child: const Icon(
//                 Icons.info_outline,
//                 color: Color(0xFF33E1A1),
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 10),
//             const Text(
//               "Core Details",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),

//         const Text(
//           "Supplier Photo",
//           style: TextStyle(
//             color: Colors.grey,
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 6),
//         ListTile(
//           tileColor: const Color(0xFF161A26),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           leading: const CircleAvatar(
//             backgroundColor: Colors.grey,
//             child: Icon(Icons.person, color: Colors.white),
//           ),
//           title: const Text(
//             "Change Supplier Photo",
//             style: TextStyle(color: Colors.white, fontSize: 14),
//           ),
//           trailing: const Icon(Icons.camera_alt, color: Colors.grey),
//           onTap: () => controller.pickPhoto(),
//         ),
//         const SizedBox(height: 16),

//         _buildField("Supplier Name", controller.nameCtrl),
//         _buildField("Phone Number", controller.phoneCtrl),
//         _buildField("Contact Email", controller.emailCtrl),
//         _buildField("Address", controller.addressCtrl, maxLines: 3),
//       ],
//     );
//   }

//   Widget _buildField(
//     String label,
//     TextEditingController ctrl, {
//     int maxLines = 1,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               color: Colors.grey,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 6),
//           TextFormField(
//             controller: ctrl,
//             maxLines: maxLines,
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: const Color(0xFF161A26),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
