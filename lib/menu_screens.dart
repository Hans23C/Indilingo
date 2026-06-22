import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'course_data.dart';
import 'profile_avatar.dart';
import 'theme_controller.dart';
import 'user_progress_controller.dart';

class ProfileScreen extends StatefulWidget {
  final List<CourseLanguage> languages;

  const ProfileScreen({super.key, required this.languages});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _savingPhoto = false;

  Future<void> _pickProfilePhoto(CourseLanguage strongest) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Elegir de galeria'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Tomar foto'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      setState(() => _savingPhoto = true);
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 78,
        maxWidth: 900,
        maxHeight: 900,
      );
      if (picked == null) return;

      final directory = await getApplicationSupportDirectory();
      final profilesDir = Directory(
        '${directory.path}${Platform.pathSeparator}profiles',
      );
      if (!await profilesDir.exists()) {
        await profilesDir.create(recursive: true);
      }

      final extension = picked.path.split('.').last.toLowerCase();
      final safeExtension = extension.length <= 5 ? extension : 'jpg';
      final fileName =
          '${UserProgressController.currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.$safeExtension';
      final savedFile = await File(
        picked.path,
      ).copy('${profilesDir.path}${Platform.pathSeparator}$fileName');

      await UserProgressController.updateProfilePhotoPath(savedFile.path);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil actualizada')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la foto')),
      );
    } finally {
      if (mounted) setState(() => _savingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalExp = widget.languages.fold<int>(
      0,
      (total, item) => total + item.exp,
    );
    final totalStreak = widget.languages.fold<int>(
      0,
      (total, item) => total + item.streakDays,
    );
    final strongest = widget.languages.reduce((a, b) => a.exp >= b.exp ? a : b);
    final user = UserProgressController.currentUser;

    return _MenuPage(
      title: 'Mi perfil',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                ProfileAvatar(
                  user: user,
                  language: strongest,
                  radius: 52,
                  showEditBadge: true,
                  onTap: _savingPhoto
                      ? null
                      : () => _pickProfilePhoto(strongest),
                ),
                const SizedBox(height: 14),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dialecto destacado: ${strongest.name}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  onPressed: _savingPhoto
                      ? null
                      : () => _pickProfilePhoto(strongest),
                  icon: _savingPhoto
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_a_photo_outlined),
                  label: Text(_savingPhoto ? 'Guardando...' : 'Cambiar foto'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _InfoTile(
            icon: Icons.bolt_outlined,
            title: '$totalExp EXP total',
            subtitle: 'Suma de todos tus dialectos.',
          ),
          _InfoTile(
            icon: Icons.local_fire_department_outlined,
            title: '$totalStreak dias de racha',
            subtitle: 'Constancia acumulada entre dialectos.',
          ),
          _InfoTile(
            icon: strongest.rank.icon,
            title: strongest.rank.name,
            subtitle: 'Tu rango mas alto actualmente.',
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool reminders = true;
  bool sounds = true;
  bool dailyGoal = true;

  @override
  Widget build(BuildContext context) {
    return _MenuPage(
      title: 'Configuracion',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            value: reminders,
            onChanged: (value) => setState(() => reminders = value),
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Recordatorios diarios'),
            subtitle: const Text('Avisos para conservar tu racha.'),
          ),
          SwitchListTile(
            value: sounds,
            onChanged: (value) => setState(() => sounds = value),
            secondary: const Icon(Icons.volume_up_outlined),
            title: const Text('Sonidos de actividad'),
            subtitle: const Text('Efectos al completar ejercicios.'),
          ),
          SwitchListTile(
            value: dailyGoal,
            onChanged: (value) => setState(() => dailyGoal = value),
            secondary: const Icon(Icons.flag_outlined),
            title: const Text('Meta diaria'),
            subtitle: const Text('Objetivo de practica por dia.'),
          ),
        ],
      ),
    );
  }
}

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _MenuPage(
      title: 'Tema',
      child: ValueListenableBuilder<bool>(
        valueListenable: AppThemeController.isDarkMode,
        builder: (context, isDarkMode, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isDarkMode
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 42,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Modo oscuro',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isDarkMode
                          ? 'La aplicacion esta usando colores oscuros.'
                          : 'Activa esta opcion para volver oscura la aplicacion.',
                      style: const TextStyle(height: 1.3),
                    ),
                    const SizedBox(height: 18),
                    SwitchListTile(
                      value: isDarkMode,
                      contentPadding: EdgeInsets.zero,
                      onChanged: AppThemeController.setDarkMode,
                      secondary: const Icon(Icons.contrast_outlined),
                      title: Text(
                        isDarkMode ? 'Oscuro activado' : 'Activar oscuro',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _MenuPage(
      title: 'Ayuda',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _InfoTile(
            icon: Icons.school_outlined,
            title: 'Como avanzo?',
            subtitle:
                'Completa actividades de lectura, escritura, gramatica y racha para ganar EXP.',
          ),
          _InfoTile(
            icon: Icons.workspace_premium_outlined,
            title: 'Como subo de rango?',
            subtitle:
                'Cada dialecto tiene su propia EXP. Al acumular mas EXP, subes de rango en ese dialecto.',
          ),
          _InfoTile(
            icon: Icons.local_fire_department_outlined,
            title: 'Que es la racha?',
            subtitle:
                'Es el registro de los dias en los que entras y practicas dentro de la aplicacion.',
          ),
          _InfoTile(
            icon: Icons.help_outline,
            title: 'Soporte',
            subtitle:
                'Si algo falla, revisa tu conexion o vuelve a iniciar sesion.',
          ),
        ],
      ),
    );
  }
}

class _MenuPage extends StatelessWidget {
  final String title;
  final Widget child;

  const _MenuPage({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(title)),
      body: SafeArea(child: child),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(height: 1.25)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
