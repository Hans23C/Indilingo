import 'package:flutter/material.dart';

import 'course_data.dart';
import 'language_sections_screen.dart';
import 'menu_screens.dart';
import 'ranks_screen.dart';

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

  late final List<CourseLanguage> _languages = buildCourses();
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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mapAnimationController.dispose();
    _mapController.dispose();
    super.dispose();
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

    final target = Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(
        viewportWidth / 2 - focus.dx * viewportWidth * scale,
        viewportHeight / 2 - focus.dy * viewportHeight * scale,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _languages[_currentPage];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _MainDrawer(languages: _languages),
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
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/mapa_inicio.png',
                    fit: BoxFit.cover,
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
                  ...List.generate(languages.length, (index) {
                    final language = languages[index];
                    final selected = index == selectedIndex;
                    final markerSize = selected ? 34.0 : 24.0;
                    return Positioned(
                      left:
                          language.mapFocus.dx * constraints.maxWidth -
                          markerSize / 2,
                      top:
                          language.mapFocus.dy * constraints.maxHeight -
                          markerSize / 2,
                      child: GestureDetector(
                        onTap: () => onMarkerTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: markerSize,
                          height: markerSize,
                          decoration: BoxDecoration(
                            color: language.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: language.color.withValues(alpha: 0.45),
                                blurRadius: selected ? 16 : 8,
                                spreadRadius: selected ? 4 : 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            language.icon,
                            color: Colors.white,
                            size: selected ? 18 : 13,
                          ),
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
              child: Icon(language.icon, color: language.color, size: 30),
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
                      Icon(language.rank.icon, color: language.color, size: 18),
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
          final barHeight = 104 * (language.exp / maxExp);

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
