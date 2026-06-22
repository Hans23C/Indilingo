import 'package:flutter/material.dart';

import 'app_asset_image.dart';
import 'ai_assistant_screen.dart';
import 'course_data.dart';
import 'language_sections_screen.dart';
import 'menu_screens.dart';
import 'ranks_screen.dart';
import 'user_progress_controller.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryDark = Color(0xFF134343);

  final PageController _pageController = PageController(viewportFraction: 0.9);
  final TransformationController _mapController = TransformationController();
  late final AnimationController _mapAnimationController;
  Animation<Matrix4>? _mapAnimation;

  late List<CourseLanguage> _languages = buildCourses();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _mapAnimationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 420),
        )..addListener(() {
          final animation = _mapAnimation;
          if (animation != null) {
            _mapController.value = animation.value;
          }
        });
    WidgetsBinding.instance.addPostFrameCallback((_) => _zoomMapTo(0));
    UserProgressController.changes.addListener(_reloadCourses);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mapAnimationController.dispose();
    _mapController.dispose();
    UserProgressController.changes.removeListener(_reloadCourses);
    super.dispose();
  }

  void _reloadCourses() {
    if (!mounted) return;
    setState(() => _languages = buildCourses());
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
    _selectLanguage(index);
  }

  void _selectLanguage(int index) {
    setState(() => _currentPage = index);
    _zoomMapTo(index);
  }

  void _zoomMapTo(int index) {
    final focus = _languages[index].mapFocus;
    const scale = 2.15;
    final viewportWidth = (MediaQuery.of(context).size.width - 32).clamp(
      280.0,
      620.0,
    );
    const viewportHeight = 220.0;
    const mapAspectRatio = 774 / 424;
    final availableRatio = viewportWidth / viewportHeight;
    final mapWidth = availableRatio > mapAspectRatio
        ? viewportHeight * mapAspectRatio
        : viewportWidth;
    final mapHeight = mapWidth / mapAspectRatio;
    final mapLeft = (viewportWidth - mapWidth) / 2;
    final mapTop = (viewportHeight - mapHeight) / 2;

    final target = Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(
        viewportWidth / 2 - (mapLeft + focus.dx * mapWidth) * scale,
        viewportHeight / 2 - (mapTop + focus.dy * mapHeight) * scale,
        0,
      );

    _mapAnimation = Matrix4Tween(begin: _mapController.value, end: target)
        .animate(
          CurvedAnimation(
            parent: _mapAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _mapAnimationController.forward(from: 0);
  }

  void _openLanguage(CourseLanguage language) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LanguageSectionsScreen(language: language),
      ),
    ).then((_) => _reloadCourses());
  }

  void _openAssistant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiAssistantScreen(languages: _languages),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _languages[_currentPage];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _MainDrawer(languages: _languages),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAssistant,
        tooltip: 'Asistente inteligente',
        backgroundColor: selected.color,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.smart_toy_outlined),
      ),
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            return IconButton(
              tooltip: 'Abrir menú',
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(
                Icons.menu,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
        title: const SizedBox.shrink(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: const Color(0xFF2098F3)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/images/logo.jpeg',
              height: 40,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.language, color: primaryDark, size: 34),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6C5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEADFA2)),
              ),
              child: const Text(
                'Sigue aprendiendo las lenguas originarias de México.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.25),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _HomeSummary(
                languages: _languages,
                selected: selected,
                onContinue: () => _openLanguage(selected),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _LearningDashboard(
                language: selected,
                onOpenLanguage: () => _openLanguage(selected),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ZoomMap(
                controller: _mapController,
                languages: _languages,
                selectedIndex: _currentPage,
                onMarkerTap: _goTo,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 132,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _languages.length,
                onPageChanged: _selectLanguage,
                itemBuilder: (context, index) {
                  final language = _languages[index];
                  final isSelected = index == _currentPage;

                  return AnimatedScale(
                    duration: const Duration(milliseconds: 220),
                    scale: isSelected ? 1 : 0.94,
                    child: _LanguageCard(
                      language: language,
                      isSelected: isSelected,
                      onTap: () => _openLanguage(language),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_languages.length, (index) {
                final isSelected = index == _currentPage;
                return GestureDetector(
                  onTap: () => _goTo(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: isSelected ? 22 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _languages[index].color
                          : Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _openLanguage(selected),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text('Ver apartados de ${selected.name}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selected.color,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: _ExpChart(
                languages: _languages,
                selectedIndex: _currentPage,
                onTap: _goTo,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _HomeSummary extends StatelessWidget {
  final List<CourseLanguage> languages;
  final CourseLanguage selected;
  final VoidCallback onContinue;

  const _HomeSummary({
    required this.languages,
    required this.selected,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final user = UserProgressController.currentUser;
    final totalExp = languages.fold<int>(0, (total, item) => total + item.exp);
    final totalStreak = languages.fold<int>(
      0,
      (total, item) => total + item.streakDays,
    );
    final completed = selected.exp ~/ expPerActivity;
    final availableActivities = selected.sections
        .where((section) => section.area != SkillArea.racha)
        .fold<int>(0, (total, section) => total + section.activities.length);
    final progress = availableActivities == 0
        ? 0.0
        : (completed / availableActivities).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: selected.color.withValues(alpha: 0.14),
                child: Icon(Icons.person, color: selected.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '$totalExp EXP total · $totalStreak avances de racha',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    color: selected.color,
                    backgroundColor: selected.color.withValues(alpha: 0.12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$completed/$availableActivities',
                style: TextStyle(
                  color: selected.color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton.icon(
              onPressed: onContinue,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text('Continuar ${selected.name}'),
              style: FilledButton.styleFrom(
                backgroundColor: selected.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningDashboard extends StatelessWidget {
  final CourseLanguage language;
  final VoidCallback onOpenLanguage;

  const _LearningDashboard({
    required this.language,
    required this.onOpenLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final practiceSections = language.sections
        .where((section) => section.area != SkillArea.racha)
        .toList();
    final completed = practiceSections.fold<int>(
      0,
      (total, section) => total + (section.exp ~/ expPerActivity),
    );
    final total = practiceSections.fold<int>(
      0,
      (total, section) => total + section.activities.length,
    );
    final nextSection = practiceSections.reduce(
      (a, b) => a.exp <= b.exp ? a : b,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dashboard_outlined, color: language.color),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Dashboard de aprendizaje',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DashboardMetric(
                  icon: Icons.check_circle_outline,
                  label: 'Hechas',
                  value: '$completed',
                  color: language.color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DashboardMetric(
                  icon: Icons.flag_outlined,
                  label: 'Meta',
                  value: '$total',
                  color: language.color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DashboardMetric(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Racha',
                  value: '${language.streakDays}',
                  color: language.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...practiceSections.map((section) {
            final sectionCompleted = section.exp ~/ expPerActivity;
            final sectionTotal = section.activities.length;
            final value = sectionTotal == 0
                ? 0.0
                : (sectionCompleted / sectionTotal).clamp(0.0, 1.0);
            return _SectionProgressLine(
              section: section,
              completed: sectionCompleted,
              total: sectionTotal,
              value: value,
              languageColor: language.color,
            );
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: language.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                AppAssetImage(
                  asset: nextSection.imageAsset,
                  fallbackIcon: nextSection.icon,
                  color: language.color,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sugerencia: continua con ${nextSection.title}, es donde tienes mas espacio para avanzar.',
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onOpenLanguage,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  color: language.color,
                  tooltip: 'Abrir apartados',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DashboardMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _SectionProgressLine extends StatelessWidget {
  final CourseSection section;
  final int completed;
  final int total;
  final double value;
  final Color languageColor;

  const _SectionProgressLine({
    required this.section,
    required this.completed,
    required this.total,
    required this.value,
    required this.languageColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: section.color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppAssetImage(
              asset: section.imageAsset,
              fallbackIcon: section.icon,
              color: languageColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        section.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      '$completed/$total',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 7,
                    color: languageColor,
                    backgroundColor: languageColor.withValues(alpha: 0.10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainDrawer extends StatelessWidget {
  final List<CourseLanguage> languages;

  const _MainDrawer({required this.languages});

  @override
  Widget build(BuildContext context) {
    final totalExp = languages.fold<int>(0, (total, item) => total + item.exp);
    final bestLanguage = languages.reduce((a, b) => a.exp >= b.exp ? a : b);

    return Drawer(
      width: 282,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 14, 0),
                child: Image.asset(
                  'assets/images/logo.jpeg',
                  height: 44,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.language,
                    color: Color(0xFF134343),
                    size: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _open(context, ProfileScreen(languages: languages)),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: bestLanguage.color.withValues(
                        alpha: 0.18,
                      ),
                      child: Icon(
                        Icons.person,
                        color: bestLanguage.color,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Mi perfil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalExp EXP total',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Configuración',
                    onTap: () => _open(context, const SettingsScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.palette_outlined,
                    label: 'Tema',
                    onTap: () => _open(context, const ThemeScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline,
                    label: 'Ayuda',
                    onTap: () => _open(context, const HelpScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.workspace_premium_outlined,
                    label: 'Rangos por dialecto',
                    onTap: () =>
                        _open(context, RanksScreen(languages: languages)),
                  ),
                  _DrawerItem(
                    icon: Icons.smart_toy_outlined,
                    label: 'Asistente inteligente',
                    onTap: () =>
                        _open(context, AiAssistantScreen(languages: languages)),
                  ),
                  const Divider(height: 26),
                  _DrawerItem(
                    icon: Icons.logout,
                    label: 'Cerrar sesión',
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _logout(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF134343)),
      title: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onTap: onTap,
    );
  }
}

class _ZoomMap extends StatelessWidget {
  final TransformationController controller;
  final List<CourseLanguage> languages;
  final int selectedIndex;
  final void Function(int) onMarkerTap;

  const _ZoomMap({
    required this.controller,
    required this.languages,
    required this.selectedIndex,
    required this.onMarkerTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: InteractiveViewer(
          transformationController: controller,
          panEnabled: false,
          scaleEnabled: false,
          minScale: 1,
          maxScale: 2.6,
          boundaryMargin: const EdgeInsets.all(80),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const mapAspectRatio = 774 / 424;
              final availableRatio =
                  constraints.maxWidth / constraints.maxHeight;
              final mapWidth = availableRatio > mapAspectRatio
                  ? constraints.maxHeight * mapAspectRatio
                  : constraints.maxWidth;
              final mapHeight = mapWidth / mapAspectRatio;
              final mapLeft = (constraints.maxWidth - mapWidth) / 2;
              final mapTop = (constraints.maxHeight - mapHeight) / 2;

              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    left: mapLeft,
                    top: mapTop,
                    width: mapWidth,
                    height: mapHeight,
                    child: Image.asset(
                      'assets/images/mapa_inicio.png',
                      fit: BoxFit.fill,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.white,
                        child: const Center(
                          child: Icon(
                            Icons.map_outlined,
                            color: Color(0xFF134343),
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...List.generate(languages.length, (index) {
                    final language = languages[index];
                    final selected = index == selectedIndex;
                    final markerSize = selected ? 42.0 : 30.0;
                    return Positioned(
                      left:
                          mapLeft +
                          language.mapFocus.dx * mapWidth -
                          markerSize / 2,
                      top:
                          mapTop +
                          language.mapFocus.dy * mapHeight -
                          markerSize / 2,
                      child: GestureDetector(
                        onTap: () => onMarkerTap(index),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: markerSize,
                              height: markerSize,
                              decoration: BoxDecoration(
                                color: language.color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: language.color.withValues(
                                      alpha: 0.45,
                                    ),
                                    blurRadius: selected ? 18 : 8,
                                    spreadRadius: selected ? 4 : 1,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: AppAssetImage(
                                  asset: language.imageAsset,
                                  fallbackIcon: language.icon,
                                  color: Colors.white,
                                  size: selected ? 31 : 22,
                                ),
                              ),
                            ),
                            if (selected) ...[
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: language.color,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  language.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final CourseLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? language.color
                : Colors.black.withValues(alpha: 0.06),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: language.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: AppAssetImage(
                  asset: language.imageAsset,
                  fallbackIcon: language.icon,
                  color: language.color,
                  size: 42,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    language.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      AppAssetImage(
                        asset: language.rank.imageAsset,
                        fallbackIcon: language.rank.icon,
                        color: language.color,
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          language.rank.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${language.streakDays} días de racha',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${language.exp} EXP',
              style: TextStyle(
                color: language.color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpChart extends StatelessWidget {
  final List<CourseLanguage> languages;
  final int selectedIndex;
  final void Function(int) onTap;

  const _ExpChart({
    required this.languages,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 174,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(languages.length, (index) {
          final language = languages[index];
          final isSelected = index == selectedIndex;
          final maxExp = languages
              .map((language) => language.exp)
              .reduce((a, b) => a > b ? a : b);
          final barHeight = maxExp == 0 ? 0.0 : 104 * (language.exp / maxExp);

          return GestureDetector(
            onTap: () => onTap(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${language.exp}',
                  style: TextStyle(
                    color: isSelected ? language.color : Colors.black45,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  width: isSelected ? 38 : 28,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? language.color
                        : language.color.withValues(alpha: 0.48),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(9),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 48,
                  child: Text(
                    language.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? language.color : Colors.black54,
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
