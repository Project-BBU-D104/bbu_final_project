import 'package:flutter/material.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UserCardListWidget extends StatelessWidget {
  
   final UserModel userList;
  const UserCardListWidget({super.key, required this.userList});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.find<UserController>()
    .gotoUserDetail(userList),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top section: avatar + info + status badge
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar with online indicator
                  Stack(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF00C896),
                            width: 2,
                          ),
                          color: const Color(0xFF1A2A3A),
                        ),
                        child: const CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFF1A2A3A),
                          child: Icon(
                            Icons.person,
                            color: Color(0xFF00C896),
                            size: 32,
                          ),
                        ),
                      ),
                      // Online dot
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C896),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Name, email, role
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userList.username,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D1B2A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userList.email ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7A8D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.date_range_outlined,
                              size: 14,
                              color: Color(0xFF6B7A8D),
                            ),
                            SizedBox(width: 4),
                            Text(
                              userList.createdAt != null
                              ? DateFormat('dd MMM yyyy').format(userList.createdAt!)
                              : "",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7A8D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Active badge
                                   
                  StatusWidget(text: "Active"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}