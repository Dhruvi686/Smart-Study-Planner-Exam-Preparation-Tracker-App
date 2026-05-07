import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: AppStrings.appTitle,
      child: Center(
        child: Text(AppStrings.welcomeText),
      ),
    );
  }
}
