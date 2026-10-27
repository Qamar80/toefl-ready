/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toefl_pro/app/core/theme/app_colors.dart';

TextStyle poppins(double size, {FontWeight w = FontWeight.w600, Color? color}) =>
    GoogleFonts.poppins(fontSize: size, fontWeight: w, color: color);
TextStyle body(double size, {FontWeight w = FontWeight.w400, Color? color}) =>
    GoogleFonts.inter(fontSize: size, fontWeight: w, color: color);
Color muted(BuildContext c) =>
    Theme.of(c).brightness == Brightness.dark ? Colors.white60 : AppColors.grey;
Color tint(BuildContext c, Color color) =>
    color.withOpacity(Theme.of(c).brightness == Brightness.dark ? .2 : .1);

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(16);
    return Material(
      color: color ?? Theme.of(context).colorScheme.surface,
      borderRadius: r,
      child: InkWell(
        onTap: onTap,
        borderRadius: r,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: r,
            border: Border.all(color: borderColor ?? Theme.of(context).dividerColor),
          ),
          child: child,
        ),
      ),
    );
  }
}
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icon;

  const PrimaryButton(
      this.label, {
        super.key,
        this.onPressed,
        this.color = AppColors.indigo600,
        this.icon,
      });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: poppins(14.5),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 6),
              Icon(icon, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const GhostButton(
      this.label, {
        super.key,
        this.onPressed,
        this.icon,
        this.color,
      });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor:
          color ?? Theme.of(context).colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          side: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              if (label.isNotEmpty) const SizedBox(width: 4),
            ],
            if (label.isNotEmpty)
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: poppins(13.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

*/
/*class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icon;
  const PrimaryButton(this.label,
      {super.key, this.onPressed, this.color = AppColors.indigo600, this.icon});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(label, style: poppins(14.5)),
            if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 18)],
          ]),
        ),
      );
}

class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  const GhostButton(this.label, {super.key, this.onPressed, this.icon, this.color});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: color ?? Theme.of(context).colorScheme.onSurface,
            side: BorderSide(color: Theme.of(context).dividerColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
            Text(label, style: poppins(13.5)),
          ]),
        ),
      );
}*//*


class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: poppins(15),
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: body(
                  12.5,
                  w: FontWeight.w600,
                  color: AppColors.indigo600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

*/
/*  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: poppins(15)),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!, style: body(12.5, w: FontWeight.w600, color: AppColors.indigo600)),
            ),
        ]),
      );*//*

                   }

             enum OptState { normal, selected, correct, wrong }

class OptionTile extends StatelessWidget {
  final String letter, text;
  final OptState state;
  final VoidCallback? onTap;
  const OptionTile(this.letter, this.text, {super.key, this.state = OptState.normal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    Color bg = surface, border = Theme.of(context).dividerColor;
    Color badgeBg = tint(context, AppColors.grey), badgeFg = muted(context);
    IconData? trailing;
    switch (state) {
      case OptState.selected:
        bg = tint(context, AppColors.indigo600);
        border = AppColors.indigo600;
        badgeBg = AppColors.indigo600;
        badgeFg = Colors.white;
        break;
      case OptState.correct:
        bg = tint(context, AppColors.teal600);
        border = AppColors.teal600;
        badgeBg = AppColors.teal600;
        badgeFg = Colors.white;
        trailing = Icons.check_circle;
        break;
      case OptState.wrong:
        bg = tint(context, AppColors.rose);
        border = AppColors.rose;
        badgeBg = AppColors.rose;
        badgeFg = Colors.white;
        trailing = Icons.cancel;
        break;
      case OptState.normal:
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: state == OptState.normal ? 1 : 1.5),
          ),
          child: Row(children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
              child: Text(letter, style: body(12, w: FontWeight.w700, color: badgeFg)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: body(13.5, w: FontWeight.w500))),
            if (trailing != null) Icon(trailing, size: 20, color: border),
          ]),
        ),
      ),
    );
  }
}

class ThinProgress extends StatelessWidget {
  final double value;
  final Color color;
  final double height;
  const ThinProgress(this.value, {super.key, this.color = AppColors.indigo600, this.height = 6});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: value.clamp(0, 1),
          minHeight: height,
          color: color,
          backgroundColor: tint(context, color),
        ),
      );
}

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const IconBadge(this.icon, {super.key, this.color = AppColors.teal600, this.size = 40});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: tint(context, color), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: size * .5),
      );
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const Pill(this.text, {super.key, this.color = AppColors.indigo600, this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: tint(context, color), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 4)],
          Text(text, style: body(11, w: FontWeight.w600, color: color)),
        ]),
      );
}
class TimerPill extends StatelessWidget {
  final String label;
  final Color color;

  const TimerPill(
      this.label, {
        super.key,
        this.color = AppColors.indigo600,
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey,
          //color: color.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 17,
            color: color,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
              fontFeatures: const [
                FontFeature.tabularFigures(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

*/
/*
class TimerPill extends StatelessWidget {
  final String label;
  final Color color;
  const TimerPill(this.label,
      {super.key, this.color = AppColors.indigo600});

  @override
  Widget build(BuildContext context) => Pill(label, color: color, icon: Icons.timer_outlined);
}
*//*


class ProgressRing extends StatelessWidget {
  final double value, size;
  final Widget child;
  final Color color;
  final Color? trackColor;
  const ProgressRing(this.value,
      {super.key, required this.child, this.size = 90, this.color = AppColors.indigo600, this.trackColor});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: Stack(alignment: Alignment.center, children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: trackColor ?? tint(context, color),
            ),
          ),
          child,
        ]),
      );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, message;
  final String? cta;
  final VoidCallback? onCta;
  const EmptyState(
      {super.key, required this.icon, required this.title, required this.message, this.cta, this.onCta});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(color: tint(context, AppColors.indigo600), shape: BoxShape.circle),
              child: Icon(icon, size: 48, color: AppColors.indigo600),
            ),
            const SizedBox(height: 18),
            Text(title, style: poppins(17), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(message, style: body(13, color: muted(context)), textAlign: TextAlign.center),
            if (cta != null) ...[
              const SizedBox(height: 18),
              SizedBox(width: 200, child: PrimaryButton(cta!, onPressed: onCta)),
            ],
          ]),
        ),
      );
}
*/
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toefl_pro/app/core/theme/app_colors.dart';

// ───────────── Typography ─────────────
// NOTE: the function is still called `poppins` so no other screen needs to change,
// but it now renders Plus Jakarta Sans (headings / UI labels).
TextStyle poppins(double size, {FontWeight w = FontWeight.w600, Color? color}) =>
    GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: w, color: color);

/// Body / UI text (Inter).
TextStyle body(double size, {FontWeight w = FontWeight.w400, Color? color}) =>
    GoogleFonts.inter(fontSize: size, fontWeight: w, color: color);

/// Long-form reading text: passages, Complete the Words (Source Serif 4).
TextStyle serif(double size, {FontWeight w = FontWeight.w400, Color? color}) =>
    GoogleFonts.sourceSerif4(fontSize: size, fontWeight: w, color: color);

Color muted(BuildContext c) =>
    Theme.of(c).brightness == Brightness.dark ? Colors.white60 : AppColors.grey;

Color tint(BuildContext c, Color color) =>
    color.withOpacity(Theme.of(c).brightness == Brightness.dark ? .2 : .1);

// ───────────── Card ─────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(16);
    return Material(
      color: color ?? Theme.of(context).colorScheme.surface,
      borderRadius: r,
      child: InkWell(
        onTap: onTap,
        borderRadius: r,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: r,
            border: Border.all(color: borderColor ?? Theme.of(context).dividerColor),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ───────────── Buttons ─────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icon;

  const PrimaryButton(
      this.label, {
        super.key,
        this.onPressed,
        this.color = AppColors.blueColor,
        this.icon,
      });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: poppins(14.5, w: FontWeight.w700),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 6),
              Icon(icon, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const GhostButton(
      this.label, {
        super.key,
        this.onPressed,
        this.icon,
        this.color,
      });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color ?? Theme.of(context).colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          side: const BorderSide(
            color: Colors.grey,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        /*
        style: OutlinedButton.styleFrom(
          foregroundColor: color ?? Theme.of(context).colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          side: BorderSide(color: Theme.of(context).dividerColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),*/
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              if (label.isNotEmpty) const SizedBox(width: 4),
            ],
            if (label.isNotEmpty)
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: poppins(13.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  // Optional image or icon
  final String? assetImage;
  final IconData? icon;

  const SectionHeader(
      this.title, {
        super.key,
        this.action,
        this.onAction,
        this.assetImage,
        this.icon,
      });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Show asset image first, otherwise show icon
          if (assetImage != null) ...[
            Image.asset(
              assetImage!,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
          ] else if (icon != null) ...[
            Icon(
              icon,
              size: 24,
              color: AppColors.indigo600,
            ),
            const SizedBox(width: 8),
          ],

          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: poppins(18, w: FontWeight.w700),
            ),
          ),

          if (action != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: body(
                  12.5,
                  w: FontWeight.w600,
                  color: AppColors.indigo600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ───────────── Section header ─────────────
/*class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: poppins(18, w: FontWeight.w700),
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: body(12.5, w: FontWeight.w600, color: AppColors.indigo600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}*/
// ───────────── Option tile ─────────────
enum OptState { normal, selected, correct, wrong }

class OptionTile extends StatelessWidget {
  final String letter, text;
  final OptState state;
  final VoidCallback? onTap;

  // Optional icon and asset image
  final IconData? icon;
  final String? assetImage;

  const OptionTile(
      this.letter,
      this.text, {
        super.key,
        this.state = OptState.normal,
        this.onTap,
        this.icon,
        this.assetImage,
      });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    Color bg = surface;
    Color border = Theme.of(context).dividerColor;
    Color badgeBg = tint(context, AppColors.grey);
    Color badgeFg = muted(context);

    IconData? trailing;

    switch (state) {
      case OptState.selected:
        bg = tint(context, AppColors.indigo600);
        border = AppColors.indigo600;
        badgeBg = AppColors.indigo600;
        badgeFg = Colors.white;
        break;

      case OptState.correct:
        bg = tint(context, AppColors.teal600);
        border = AppColors.teal600;
        badgeBg = AppColors.teal600;
        badgeFg = Colors.white;
        trailing = Icons.check_circle;
        break;

      case OptState.wrong:
        bg = tint(context, AppColors.rose);
        border = AppColors.rose;
        badgeBg = AppColors.rose;
        badgeFg = Colors.white;
        trailing = Icons.cancel;
        break;

      case OptState.normal:
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: border,
              width: state == OptState.normal ? 1 : 1.5,
            ),
          ),
          child: Row(
            children: [
              // Letter badge
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  letter,
                  style: poppins(
                    12,
                    w: FontWeight.w700,
                    color: badgeFg,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  text,
                  style: body(
                    13.5,
                    w: FontWeight.w500,
                  ).copyWith(height: 1.4),
                ),
              ),

              // Asset image takes priority; otherwise show icon
              if (assetImage != null)
                Image.asset(
                  assetImage!,
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                )
              else if (icon != null)
                Icon(
                  icon,
                  size: 22,
                  color: badgeFg,
                ),

              // Correct / wrong status icon
              if (trailing != null) ...[
                const SizedBox(width: 8),
                Icon(
                  trailing,
                  size: 20,
                  color: border,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/*// ───────────── Option tile ─────────────
enum OptState { normal, selected, correct, wrong }

class OptionTile extends StatelessWidget {
  final String letter, text;
  final OptState state;
  final VoidCallback? onTap;

  const OptionTile(this.letter, this.text, {super.key, this.state = OptState.normal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    Color bg = surface, border = Theme.of(context).dividerColor;
    Color badgeBg = tint(context, AppColors.grey), badgeFg = muted(context);
    IconData? trailing;
    switch (state) {
      case OptState.selected:
        bg = tint(context, AppColors.indigo600);
        border = AppColors.indigo600;
        badgeBg = AppColors.indigo600;
        badgeFg = Colors.white;
        break;
      case OptState.correct:
        bg = tint(context, AppColors.teal600);
        border = AppColors.teal600;
        badgeBg = AppColors.teal600;
        badgeFg = Colors.white;
        trailing = Icons.check_circle;
        break;
      case OptState.wrong:
        bg = tint(context, AppColors.rose);
        border = AppColors.rose;
        badgeBg = AppColors.rose;
        badgeFg = Colors.white;
        trailing = Icons.cancel;
        break;
      case OptState.normal:
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: state == OptState.normal ? 1 : 1.5),
          ),
          child: Row(children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
              child: Text(letter, style: poppins(12, w: FontWeight.w700, color: badgeFg)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: body(13.5, w: FontWeight.w500).copyWith(height: 1.4))),
            if (trailing != null) Icon(trailing, size: 20, color: border),
          ]),
        ),
      ),
    );
  }
}*/

// ───────────── Progress / badges / pills ─────────────
class ThinProgress extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const ThinProgress(this.value, {super.key, this.color = AppColors.indigo600, this.height = 6});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: LinearProgressIndicator(
      value: value.clamp(0, 1),
      minHeight: height,
      color: color,
      backgroundColor: tint(context, color),
    ),
  );
}

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const IconBadge(this.icon, {super.key, this.color = AppColors.teal600, this.size = 40});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: tint(context, color), borderRadius: BorderRadius.circular(12)),
    child: Icon(icon, color: color, size: size * .5),
  );
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const Pill(this.text, {super.key, this.color = AppColors.indigo600, this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(color: tint(context, color), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 4)],
      Text(text, style: body(11, w: FontWeight.w600, color: color)),
    ]),
  );
}

class TimerPill extends StatelessWidget {
  final String label;
  final Color color;

  const TimerPill(
      this.label, {
        super.key,
        this.color = AppColors.blueColor,
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 17, color: color),
          const SizedBox(width: 7),
          Text(
            label,
            style: poppins(13, w: FontWeight.w700, color: color).copyWith(
              letterSpacing: 0.3,
              // Keeps digits the same width so the timer doesn't jitter.
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressRing extends StatelessWidget {
  final double value, size;
  final Widget child;
  final Color color;
  final Color? trackColor;

  const ProgressRing(
      this.value, {
        super.key,
        required this.child,
        this.size = 90,
        this.color = AppColors.indigo600,
        this.trackColor,
      });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(alignment: Alignment.center, children: [
      SizedBox.expand(
        child: CircularProgressIndicator(
          value: value,
          strokeWidth: 8,
          strokeCap: StrokeCap.round,
          color: color,
          backgroundColor: trackColor ?? tint(context, color),
        ),
      ),
      child,
    ]),
  );
}

// ───────────── Empty state ─────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, message;
  final String? cta;
  final VoidCallback? onCta;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.cta,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(color: tint(context, AppColors.indigo600), shape: BoxShape.circle),
          child: Icon(icon, size: 48, color: AppColors.indigo600),
        ),
        const SizedBox(height: 18),
        Text(title, style: poppins(17, w: FontWeight.w700), textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(
          message,
          style: body(13, color: muted(context)).copyWith(height: 1.45),
          textAlign: TextAlign.center,
        ),
        if (cta != null) ...[
          const SizedBox(height: 18),
          SizedBox(width: 200, child: PrimaryButton(cta!, onPressed: onCta)),
        ],
      ]),
    ),
  );
}