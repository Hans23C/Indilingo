import 'dart:io';

import 'package:flutter/material.dart';

import 'app_asset_image.dart';
import 'course_data.dart';
import 'user_progress_controller.dart';

class ProfileAvatar extends StatelessWidget {
  final AppUser user;
  final CourseLanguage language;
  final double radius;
  final bool showEditBadge;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    required this.user,
    required this.language,
    required this.radius,
    this.showEditBadge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final photo = user.profilePhotoPath.isEmpty
        ? null
        : File(user.profilePhotoPath);
    final hasPhoto = photo != null && photo.existsSync();

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: language.color.withValues(alpha: 0.16),
      backgroundImage: hasPhoto ? FileImage(photo) : null,
      child: hasPhoto
          ? null
          : AppAssetImage(
              asset: language.rank.imageAsset,
              fallbackIcon: language.rank.icon,
              color: language.color,
              size: radius * 1.45,
            ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          if (showEditBadge)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: radius * 0.72,
                height: radius * 0.72,
                decoration: BoxDecoration(
                  color: language.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
