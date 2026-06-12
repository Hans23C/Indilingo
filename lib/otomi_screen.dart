import 'package:flutter/material.dart';

import 'course_data.dart';
import 'language_sections_screen.dart';

class OtomiScreen extends StatelessWidget {
  const OtomiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LanguageSectionsScreen(language: buildCourses()[4]);
  }
}
