// import 'package:flutter/material.dart';
// import 'package:frontend/controllers/supplier_controller.dart';
// import 'package:get/get.dart';

// class SupplierAddForm extends StatelessWidget {
//   const SupplierAddForm({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final SupplierController controller = Get.find<SupplierController>();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Supplier Details",
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Color.fromARGB(255, 12, 12, 12),
//           ),
//         ),
//         const Text(
//           "Enter information below to register a supplier",
//           style: TextStyle(
//             fontSize: 14,
//             color: Color.fromARGB(255, 84, 83, 83),
//           ),
//         ),
//         const SizedBox(height: 20),

//         const Text(
//           "SUPPLIER PHOTO",
//           style: TextStyle(
//             color: Color.fromARGB(255, 26, 25, 25),
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 6),
//         InkWell(
//           onTap: () => controller.pickPhoto(),
//           child: Obx(
//             () => Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               decoration: BoxDecoration(
//                 color: const Color.fromARGB(255, 22, 191, 185),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: const Color.fromARGB(255, 12, 10, 10).withOpacity(0.3),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     controller.photoPath.isEmpty
//                         ? Icons.add_a_photo
//                         : Icons.check_circle,
//                     color: const Color.fromARGB(255, 25, 56, 45),
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     controller.photoPath.isEmpty
//                         ? "Upload Supplier Photo"
//                         : "Photo Selected",
//                     style: const TextStyle(
//                       color: Color.fromARGB(255, 10, 9, 9),
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),

//         _buildField(
//           "SUPPLIER NAME",
//           "e.g. Dara Pactics Co., Ltd.",
//           Icons.business,
//           (v) => controller.name.value = v,
//         ),
//         _buildField(
//           "PHONE NUMBER",
//           "+855 (012) 345-678",
//           Icons.phone,
//           (v) => controller.phone.value = v,
//         ),
//         _buildField(
//           "EMAIL ADDRESS",
//           "official@supplier.corp",
//           Icons.email,
//           (v) => controller.email.value = v,
//         ),
//         _buildField(
//           "ADDRESS",
//           "Full operational street address, City, State, ZIP",
//           Icons.location_on,
//           (v) => controller.address.value = v,
//           maxLines: 3,
//         ),
//       ],
//     );
//   }

//   Widget _buildField(
//     String label,
//     String hint,
//     IconData icon,
//     Function(String) onChange, {
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
//               color: Color.fromARGB(255, 46, 46, 46),
//               fontSize: 11,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 6),
//           TextFormField(
//             maxLines: maxLines,
//             style: const TextStyle(color: Color.fromARGB(255, 8, 8, 8)),
//             onChanged: onChange,
//             decoration: InputDecoration(
//               hintText: hint,
//               hintStyle: const TextStyle(
//                 color: Color.fromARGB(255, 130, 130, 130),
//                 fontSize: 14,
//               ),
//               prefixIcon: Icon(icon, color: const Color.fromARGB(255, 7, 7, 7)),
//               filled: true,
//               fillColor: const Color.fromARGB(255, 213, 215, 220),
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
