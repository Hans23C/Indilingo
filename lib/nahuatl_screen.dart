import 'package:flutter/material.dart';

import 'course_data.dart';
import 'language_sections_screen.dart';

class NahuatlScreen extends StatelessWidget {
  const NahuatlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LanguageSectionsScreen(language: buildCourses()[0]);
  }
}
