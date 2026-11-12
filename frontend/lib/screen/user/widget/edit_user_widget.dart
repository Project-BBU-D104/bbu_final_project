import 'package:flutter/material.dart';
import 'package:frontend/screen/user/widget/user_form_widget.dart';

class EditUserWidget extends StatelessWidget {
  const EditUserWidget({super.key, required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context) => UserFormWidget(userId: userId);
}
