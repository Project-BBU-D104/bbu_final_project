import 'package:flutter/material.dart';
import 'package:frontend/screen/role/widget/role_form_widget.dart';

class EditRoleWidget extends StatelessWidget {
  const EditRoleWidget({super.key, required this.roleId});

  final int roleId;

  @override
  Widget build(BuildContext context) => RoleFormWidget(roleId: roleId);
}
