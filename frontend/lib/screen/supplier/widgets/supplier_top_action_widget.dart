// import 'package:flutter/material.dart';
// import 'package:frontend/controllers/supplier_controller.dart';
// import 'package:get/get.dart';

// class SupplierTopAction extends StatelessWidget implements PreferredSizeWidget {
//   const SupplierTopAction({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final SupplierController controller = Get.find<SupplierController>();

//     return Obx(
//       () => AppBar(
//         backgroundColor: const Color.fromARGB(255, 254, 254, 254),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back,
//             color: Color.fromARGB(255, 13, 9, 9),
//           ),
//           onPressed: () => controller.cancelAction(),
//         ),
//         title: Text(
//           controller.isEditMode.value ? "Edit Supplier" : "Add Supplier",
//           style: const TextStyle(
//             color: Color.fromARGB(255, 8, 6, 6),
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.notifications_none,
//               color: Color.fromARGB(255, 11, 11, 11),
//             ),
//             onPressed: () {},
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
