// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:login_indilingo/course_data.dart';
import 'package:login_indilingo/main.dart';

void main() {
  testWidgets('Muestra la pantalla de inicio de sesiÃƒÂ³n', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const IndilingoApp());

    expect(find.text('Bienvenido a INDIlingo'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });

  test('Cada dialecto tiene rangos y 70 actividades por apartado', () {
    final courses = buildCourses();

    expect(courses, hasLength(5));
    for (final language in courses) {
      final sectionTitles = language.sections.map((section) => section.title);

      expect(language.sections, hasLength(4));
      expect(sectionTitles, contains('Racha'));
      expect(sectionTitles, isNot(contains('Hablado')));
      expect(language.rank, rankForExp(language.exp));

      for (final section in language.sections) {
        if (section.area == SkillArea.racha) {
          expect(section.activities, isEmpty);
        } else {
          expect(section.activities, hasLength(maxActivitiesPerSection));
        }
      }
    }
  });
}
