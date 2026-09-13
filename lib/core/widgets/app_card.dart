import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Plain rounded, softly-shadowed white card. The base surface used
/// throughout the app instead of bare [Container]/[Material] blocks, so
/// every list/detail screen shares the same elevation and corner radius.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// A titled card that groups a list of [ListTile]-shaped rows with dividers
/// between them, per the "Pengaturan" screen's section styling.
class AppSectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const AppSectionCard({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 8),
            child: Text(
              title!.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.6,
                color: AppColors.deepGreen,
              ),
            ),
          ),
        AppCard(
          padding: EdgeInsets.zero,
          // A plain colored Container sits between this Column's ListTiles
          // and the Scaffold's Material, which silently swallows their ink
          // splashes/background — re-declaring a transparent Material here
          // gives them a paint surface directly above the card's own color.
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 68),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A [ListTile]-shaped row with a colored circular icon badge, for use
/// inside an [AppSectionCard] or [AppCard].
class AppIconTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const AppIconTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 14,
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, color: Colors.grey) : null),
    );
  }
}
