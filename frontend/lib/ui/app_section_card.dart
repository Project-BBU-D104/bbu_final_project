import 'package:flutter/material.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/ui/app_list_card.dart';

/// A shared section surface with an optional translated semantic heading.
class AppSectionCard extends StatelessWidget {
  const AppSectionCard({super.key, this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) => AppListCard(
    margin: EdgeInsets.zero,
    child: title == null
        ? child
        : AppFormSection(title: title!, children: [child]),
  );
}
