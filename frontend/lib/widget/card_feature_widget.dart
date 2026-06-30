// import 'package:flutter/material.dart';

// class CardFeatureWidget extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final String? subtitle;
//   final VoidCallback onTap;
//   final Color iconColor;

//   const CardFeatureWidget({
//     super.key,
//     required this.title,
//     required this.icon,
//     this.subtitle,
//     required this.onTap,
//     this.iconColor = const Color(0xFF4F46E5),
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       borderRadius: BorderRadius.circular(20),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(20),
//         onTap: onTap,
//         child: Ink(
//           decoration: BoxDecoration(
//             color: const Color(0xFFF5F7FB),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: Colors.grey.shade200,
//               width: 1,
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 20,
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 64,
//                   height: 64,
//                   decoration: BoxDecoration(
//                     color: iconColor.withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(18),
//                   ),
//                   child: Icon(
//                     icon,
//                     size: 34,
//                     color: iconColor,
//                   ),
//                 ),

//                 const SizedBox(height: 18),

//                 Text(
//                   title,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF222222),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class CardFeatureWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const CardFeatureWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black12,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(icon, size: 28),

            const SizedBox(height: 8),

            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle ?? '',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}