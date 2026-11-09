import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screen/auth/widget/input_login_widget.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('shows its label and inline validation error', (tester) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: InputLoginWidget(
              controller: controller,
              label: 'Username',
              hint: 'Enter username',
              icon: Icons.person_outline,
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'Username is required'
                  : null,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Username is required'), findsNothing);

    formKey.currentState!.validate();
    await tester.pump();

    expect(find.text('Username is required'), findsOneWidget);

    controller.dispose();
  });
}