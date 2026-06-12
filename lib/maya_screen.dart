import 'package:flutter/material.dart';

import 'course_data.dart';
import 'language_sections_screen.dart';

class MayaScreen extends StatelessWidget {
  const MayaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LanguageSectionsScreen(language: buildCourses()[1]);
  }
}
