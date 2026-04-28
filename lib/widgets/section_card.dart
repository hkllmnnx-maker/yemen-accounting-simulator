import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'thumbnails/section_thumbnails.dart';

/// بطاقة قسم رئيسية - تستخدم في لوحة التحكم وشاشات الفهرس.
///
/// التصميم المُحدَّث:
/// - دعم الصور المصغّرة الاحترافية (CustomPaint thumbnails) أو الأيقونات.
/// - تخطيط متجاوب يحافظ على وضوح النص العربي حتى على الشاشات الصغيرة.
/// - حدود ناعمة + ظل + تدرّج لوني لمظهر احترافي موحَّد.
/// - لا يُسمح بقصّ النص بشكل مشوّه: يَلتفّ على سطرين عند الحاجة.
class SectionCard extends StatelessWidget {
  /// أيقونة احتياطية (تُستخدم فقط إذا لم يتم تحديد thumbnail).
  final IconData? icon;

  /// نوع الصورة المصغّرة الحقيقية المرسومة (يُفضَّل دومًا).
  final ThumbnailKind? thumbnail;

  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  const SectionCard({
    super.key,
    this.icon,
    this.thumbnail,
    required this.title,
    this.subtitle,
    this.color = AppColors.primary,
    required this.onTap,
  }) : assert(icon != null || thumbnail != null,
            'يجب تمرير icon أو thumbnail على الأقل');

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withValues(alpha: 0.18), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        splashColor: color.withValues(alpha: 0.10),
        highlightColor: color.withValues(alpha: 0.06),
        child: LayoutBuilder(
          builder: (context, c) {
            // حساب حجم الصورة المصغّرة بناءً على ارتفاع البطاقة المتاح
            // لتجنّب أي تشويه أو ضغط على النص العربي.
            final h = c.maxHeight.isFinite ? c.maxHeight : 140.0;
            final thumbSize = (h * 0.42).clamp(40.0, 68.0);
            final padding = h < 130 ? 8.0 : 10.0;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (thumbnail != null)
                    SectionThumbnail(
                      kind: thumbnail!,
                      color: color,
                      size: thumbSize,
                    )
                  else
                    Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withValues(alpha: 0.18),
                            color.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: color.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child:
                          Icon(icon, color: color, size: thumbSize * 0.55),
                    ),
                  SizedBox(height: h < 130 ? 6 : 8),
                  Flexible(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// بطاقة إحصائية - أيقونة (أو صورة مصغّرة) + تسمية + رقم.
///
/// تخطيطها أفقي، وتستخدم FittedBox لمنع تجاوز الأرقام الطويلة.
class StatCard extends StatelessWidget {
  final IconData? icon;
  final ThumbnailKind? thumbnail;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    this.icon,
    this.thumbnail,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  }) : assert(icon != null || thumbnail != null,
            'يجب تمرير icon أو thumbnail على الأقل');

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withValues(alpha: 0.18), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              if (thumbnail != null)
                SectionThumbnail(
                  kind: thumbnail!,
                  color: color,
                  size: 42,
                )
              else
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.18),
                        color.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// شاشة فارغة عامة - تستخدم لما لا توجد بيانات.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.10),
                    AppColors.accent.withValues(alpha: 0.06),
                  ],
                ),
              ),
              child: Icon(
                icon,
                size: 56,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 18),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// عنوان قسم بمؤشر شريطي يميني - عنصر بصري متكرر.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          if (icon != null) ...[
            Icon(icon, color: c, size: 18),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
