import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// مكتبة الصور المصغّرة الاحترافية للأقسام المحاسبية.
///
/// كل صورة مصغّرة هي عنصر بصري حقيقي مرسوم باستخدام CustomPaint،
/// ومصمَّم خصيصًا ليُعبِّر عن طبيعة القسم - ليست مجرد أيقونة Material عامة.
/// المظهر موحَّد عبر التطبيق: حاوية بتدرّج لوني + رسم تفصيلي + ظل ناعم.

enum ThumbnailKind {
  // محاسبة وقيود
  accountsTree,
  journalEntries,
  ledger,
  trialBalance,
  // أطراف
  customers,
  suppliers,
  // مخزون ومنتجات
  items,
  inventory,
  // فواتير ومبيعات
  sales,
  purchases,
  invoice,
  // سندات
  receiptVoucher,
  paymentVoucher,
  vouchers,
  // تقارير وقوائم
  reports,
  incomeStatement,
  balanceSheet,
  cashReport,
  salesReport,
  inventoryReport,
  financialAnalysis,
  // مالية رئيسية
  cashBox,
  receivables,
  payables,
  inventoryValue,
  // تعليمي
  lessons,
  training,
  quiz,
  progress,
  glossary,
  simulator,
  financialAccounting,
  settings,
  about,
  // عام
  company,
  document,
}

/// عنصر بصري مرسوم خصيصًا لكل قسم محاسبي.
///
/// يستخدم Container بخلفية متدرّجة + إطار + ظل ناعم، ويرسم بداخله
/// رسمًا توضيحيًا مخصصًا حسب النوع المحدّد.
class SectionThumbnail extends StatelessWidget {
  final ThumbnailKind kind;
  final Color color;
  final double size;
  final bool padded;

  const SectionThumbnail({
    super.key,
    required this.kind,
    required this.color,
    this.size = 56,
    this.padded = true,
  });

  @override
  Widget build(BuildContext context) {
    final inner = CustomPaint(
      size: Size.square(size),
      painter: _ThumbnailPainter(kind: kind, color: color),
    );
    if (!padded) return inner;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.16),
            color.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(8), child: inner),
    );
  }
}

class _ThumbnailPainter extends CustomPainter {
  final ThumbnailKind kind;
  final Color color;
  _ThumbnailPainter({required this.kind, required this.color});

  Paint _stroke([double w = 2]) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint _fill([double a = 1.0]) => Paint()
    ..color = color.withValues(alpha: a)
    ..style = PaintingStyle.fill;

  Paint _fillColor(Color c, [double a = 1.0]) => Paint()
    ..color = c.withValues(alpha: a)
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case ThumbnailKind.accountsTree:
        _accountsTree(canvas, size);
      case ThumbnailKind.journalEntries:
        _journalEntries(canvas, size);
      case ThumbnailKind.ledger:
        _ledger(canvas, size);
      case ThumbnailKind.trialBalance:
        _trialBalance(canvas, size);
      case ThumbnailKind.customers:
        _customers(canvas, size);
      case ThumbnailKind.suppliers:
        _suppliers(canvas, size);
      case ThumbnailKind.items:
      case ThumbnailKind.inventory:
        _inventory(canvas, size);
      case ThumbnailKind.sales:
        _sales(canvas, size);
      case ThumbnailKind.purchases:
        _purchases(canvas, size);
      case ThumbnailKind.invoice:
        _invoice(canvas, size);
      case ThumbnailKind.receiptVoucher:
        _receiptVoucher(canvas, size);
      case ThumbnailKind.paymentVoucher:
        _paymentVoucher(canvas, size);
      case ThumbnailKind.vouchers:
        _vouchers(canvas, size);
      case ThumbnailKind.reports:
        _reports(canvas, size);
      case ThumbnailKind.incomeStatement:
        _incomeStatement(canvas, size);
      case ThumbnailKind.balanceSheet:
        _balanceSheet(canvas, size);
      case ThumbnailKind.cashReport:
        _cashReport(canvas, size);
      case ThumbnailKind.salesReport:
        _salesReport(canvas, size);
      case ThumbnailKind.inventoryReport:
        _inventoryReport(canvas, size);
      case ThumbnailKind.financialAnalysis:
        _financialAnalysis(canvas, size);
      case ThumbnailKind.cashBox:
        _cashBox(canvas, size);
      case ThumbnailKind.receivables:
        _receivables(canvas, size);
      case ThumbnailKind.payables:
        _payables(canvas, size);
      case ThumbnailKind.inventoryValue:
        _inventoryValue(canvas, size);
      case ThumbnailKind.lessons:
        _lessons(canvas, size);
      case ThumbnailKind.training:
        _training(canvas, size);
      case ThumbnailKind.quiz:
        _quiz(canvas, size);
      case ThumbnailKind.progress:
        _progress(canvas, size);
      case ThumbnailKind.glossary:
        _glossary(canvas, size);
      case ThumbnailKind.simulator:
        _simulator(canvas, size);
      case ThumbnailKind.financialAccounting:
        _financialAccounting(canvas, size);
      case ThumbnailKind.settings:
        _settings(canvas, size);
      case ThumbnailKind.about:
        _about(canvas, size);
      case ThumbnailKind.company:
        _company(canvas, size);
      case ThumbnailKind.document:
        _document(canvas, size);
    }
  }

  // ========== شجرة الحسابات ==========
  void _accountsTree(Canvas canvas, Size size) {
    final s = size.width;
    final cx = s / 2;
    final root = Rect.fromCenter(
      center: Offset(cx, s * 0.18),
      width: s * 0.36,
      height: s * 0.16,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(root, Radius.circular(s * 0.04)),
      _fill(0.85),
    );
    final branchY = s * 0.55;
    final xs = [s * 0.18, s * 0.5, s * 0.82];
    for (final x in xs) {
      final r = Rect.fromCenter(
        center: Offset(x, branchY),
        width: s * 0.22,
        height: s * 0.13,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, Radius.circular(s * 0.03)),
        _fill(0.55),
      );
      final p = Path()
        ..moveTo(cx, root.bottom)
        ..lineTo(cx, (root.bottom + branchY - s * 0.065) / 2)
        ..lineTo(x, (root.bottom + branchY - s * 0.065) / 2)
        ..lineTo(x, branchY - s * 0.065);
      canvas.drawPath(p, _stroke(s * 0.025));
    }
    final leafY = s * 0.85;
    for (final x in [s * 0.1, s * 0.26, s * 0.74, s * 0.9]) {
      canvas.drawCircle(Offset(x, leafY), s * 0.05, _fill(0.4));
    }
    canvas.drawLine(
      Offset(xs[0], branchY + s * 0.065),
      Offset(s * 0.1, leafY - s * 0.05),
      _stroke(s * 0.022),
    );
    canvas.drawLine(
      Offset(xs[0], branchY + s * 0.065),
      Offset(s * 0.26, leafY - s * 0.05),
      _stroke(s * 0.022),
    );
    canvas.drawLine(
      Offset(xs[2], branchY + s * 0.065),
      Offset(s * 0.74, leafY - s * 0.05),
      _stroke(s * 0.022),
    );
    canvas.drawLine(
      Offset(xs[2], branchY + s * 0.065),
      Offset(s * 0.9, leafY - s * 0.05),
      _stroke(s * 0.022),
    );
  }

  // ========== القيود اليومية ==========
  void _journalEntries(Canvas canvas, Size size) {
    final s = size.width;
    final book = Rect.fromLTWH(s * 0.08, s * 0.18, s * 0.84, s * 0.66);
    canvas.drawRRect(
      RRect.fromRectAndRadius(book, Radius.circular(s * 0.04)),
      _fill(0.18),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(book, Radius.circular(s * 0.04)),
      _stroke(s * 0.025),
    );
    canvas.drawLine(
      Offset(s * 0.5, s * 0.18),
      Offset(s * 0.5, s * 0.84),
      _stroke(s * 0.02),
    );
    for (int i = 0; i < 4; i++) {
      final y = s * 0.3 + i * s * 0.13;
      canvas.drawLine(
        Offset(s * 0.13, y),
        Offset(s * 0.46, y),
        _stroke(s * 0.018),
      );
      canvas.drawLine(
        Offset(s * 0.54, y),
        Offset(s * 0.87, y),
        _stroke(s * 0.018),
      );
    }
    final pen = Path()
      ..moveTo(s * 0.78, s * 0.06)
      ..lineTo(s * 0.94, s * 0.06)
      ..lineTo(s * 0.94, s * 0.14)
      ..lineTo(s * 0.78, s * 0.14)
      ..close();
    canvas.drawPath(pen, _fill(0.7));
  }

  // ========== دفتر الأستاذ ==========
  void _ledger(Canvas canvas, Size size) {
    final s = size.width;
    for (int i = 2; i >= 0; i--) {
      final off = i * s * 0.05;
      final book = Rect.fromLTWH(
        s * 0.12 + off,
        s * 0.18 + off,
        s * 0.7,
        s * 0.62,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(book, Radius.circular(s * 0.03)),
        _fill(0.25 + i * 0.15),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(book, Radius.circular(s * 0.03)),
        _stroke(s * 0.018),
      );
    }
    final top = Rect.fromLTWH(s * 0.12, s * 0.18, s * 0.7, s * 0.62);
    for (int i = 0; i < 3; i++) {
      final y = top.top + s * 0.16 + i * s * 0.13;
      canvas.drawLine(
        Offset(top.left + s * 0.06, y),
        Offset(top.right - s * 0.06, y),
        _stroke(s * 0.018),
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(s * 0.78, s * 0.32, s * 0.06, s * 0.16),
      _fillColor(AppColors.gold, 0.85),
    );
  }

  // ========== ميزان المراجعة ==========
  void _trialBalance(Canvas canvas, Size size) {
    final s = size.width;
    canvas.drawRect(
      Rect.fromLTWH(s * 0.48, s * 0.25, s * 0.04, s * 0.5),
      _fill(0.85),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.3, s * 0.78, s * 0.4, s * 0.06),
        Radius.circular(s * 0.02),
      ),
      _fill(0.85),
    );
    canvas.drawRect(
      Rect.fromLTWH(s * 0.1, s * 0.23, s * 0.8, s * 0.04),
      _fill(0.85),
    );
    final lp = Path()
      ..moveTo(s * 0.05, s * 0.28)
      ..quadraticBezierTo(s * 0.2, s * 0.5, s * 0.35, s * 0.28)
      ..close();
    canvas.drawPath(lp, _fill(0.5));
    canvas.drawPath(lp, _stroke(s * 0.022));
    final rp = Path()
      ..moveTo(s * 0.65, s * 0.28)
      ..quadraticBezierTo(s * 0.8, s * 0.5, s * 0.95, s * 0.28)
      ..close();
    canvas.drawPath(rp, _fill(0.5));
    canvas.drawPath(rp, _stroke(s * 0.022));
    canvas.drawLine(
      Offset(s * 0.2, s * 0.27),
      Offset(s * 0.2, s * 0.32),
      _stroke(s * 0.018),
    );
    canvas.drawLine(
      Offset(s * 0.8, s * 0.27),
      Offset(s * 0.8, s * 0.32),
      _stroke(s * 0.018),
    );
  }

  // ========== العملاء ==========
  void _customers(Canvas canvas, Size size) {
    final s = size.width;
    void person(double cx, double cy, double scale, double a) {
      canvas.drawCircle(
        Offset(cx, cy - s * 0.1 * scale),
        s * 0.09 * scale,
        _fill(a),
      );
      final body = Path()
        ..moveTo(cx - s * 0.16 * scale, cy + s * 0.18 * scale)
        ..quadraticBezierTo(
          cx - s * 0.16 * scale,
          cy - s * 0.02 * scale,
          cx,
          cy - s * 0.02 * scale,
        )
        ..quadraticBezierTo(
          cx + s * 0.16 * scale,
          cy - s * 0.02 * scale,
          cx + s * 0.16 * scale,
          cy + s * 0.18 * scale,
        )
        ..close();
      canvas.drawPath(body, _fill(a));
    }

    person(s * 0.5, s * 0.45, 1.1, 0.85);
    person(s * 0.22, s * 0.55, 0.85, 0.55);
    person(s * 0.78, s * 0.55, 0.85, 0.55);
  }

  // ========== الموردون (شاحنة) ==========
  void _suppliers(Canvas canvas, Size size) {
    final s = size.width;
    final box = Rect.fromLTWH(s * 0.08, s * 0.32, s * 0.46, s * 0.32);
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, Radius.circular(s * 0.02)),
      _fill(0.8),
    );
    final cab = Path()
      ..moveTo(s * 0.54, s * 0.42)
      ..lineTo(s * 0.7, s * 0.42)
      ..lineTo(s * 0.86, s * 0.55)
      ..lineTo(s * 0.86, s * 0.64)
      ..lineTo(s * 0.54, s * 0.64)
      ..close();
    canvas.drawPath(cab, _fill(0.65));
    canvas.drawPath(cab, _stroke(s * 0.02));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.58, s * 0.46, s * 0.18, s * 0.1),
        Radius.circular(s * 0.015),
      ),
      _fillColor(Colors.white, 0.9),
    );
    canvas.drawCircle(
      Offset(s * 0.22, s * 0.72),
      s * 0.075,
      _fillColor(AppColors.textPrimary, 0.85),
    );
    canvas.drawCircle(
      Offset(s * 0.22, s * 0.72),
      s * 0.035,
      _fillColor(Colors.white, 1),
    );
    canvas.drawCircle(
      Offset(s * 0.7, s * 0.72),
      s * 0.075,
      _fillColor(AppColors.textPrimary, 0.85),
    );
    canvas.drawCircle(
      Offset(s * 0.7, s * 0.72),
      s * 0.035,
      _fillColor(Colors.white, 1),
    );
    canvas.drawLine(
      Offset(s * 0.16, s * 0.4),
      Offset(s * 0.46, s * 0.4),
      _stroke(s * 0.015),
    );
    canvas.drawLine(
      Offset(s * 0.16, s * 0.5),
      Offset(s * 0.46, s * 0.5),
      _stroke(s * 0.015),
    );
  }

  // ========== المخزون / الأصناف ==========
  void _inventory(Canvas canvas, Size size) {
    final s = size.width;
    void box(double x, double y, double w, double a) {
      final r = Rect.fromLTWH(x, y, w, w * 0.85);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, Radius.circular(s * 0.02)),
        _fill(a),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, Radius.circular(s * 0.02)),
        _stroke(s * 0.018),
      );
      canvas.drawLine(
        Offset(x, y + w * 0.15),
        Offset(x + w, y + w * 0.15),
        _stroke(s * 0.018),
      );
      canvas.drawLine(
        Offset(x + w / 2, y),
        Offset(x + w / 2, y + w * 0.3),
        _stroke(s * 0.018),
      );
    }

    box(s * 0.08, s * 0.5, s * 0.36, 0.7);
    box(s * 0.56, s * 0.5, s * 0.36, 0.5);
    box(s * 0.32, s * 0.14, s * 0.36, 0.85);
  }

  // ========== المبيعات (نقطة بيع + إيصال) ==========
  void _sales(Canvas canvas, Size size) {
    final s = size.width;
    final base = Rect.fromLTWH(s * 0.16, s * 0.36, s * 0.68, s * 0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(base, Radius.circular(s * 0.05)),
      _fill(0.8),
    );
    final screen = Rect.fromLTWH(s * 0.22, s * 0.42, s * 0.56, s * 0.16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(screen, Radius.circular(s * 0.02)),
      _fillColor(Colors.white, 1),
    );
    canvas.drawLine(
      Offset(s * 0.32, s * 0.46),
      Offset(s * 0.45, s * 0.46),
      _stroke(s * 0.02),
    );
    canvas.drawLine(
      Offset(s * 0.32, s * 0.52),
      Offset(s * 0.45, s * 0.52),
      _stroke(s * 0.02),
    );
    for (int r = 0; r < 2; r++) {
      for (int c = 0; c < 4; c++) {
        canvas.drawCircle(
          Offset(s * 0.27 + c * s * 0.13, s * 0.66 + r * s * 0.1),
          s * 0.035,
          _fillColor(Colors.white, 0.95),
        );
      }
    }
    final receipt = Path()
      ..moveTo(s * 0.32, s * 0.36)
      ..lineTo(s * 0.32, s * 0.08)
      ..lineTo(s * 0.68, s * 0.08)
      ..lineTo(s * 0.68, s * 0.36);
    canvas.drawPath(receipt, _fillColor(Colors.white, 0.95));
    canvas.drawPath(receipt, _stroke(s * 0.02));
    canvas.drawLine(
      Offset(s * 0.36, s * 0.16),
      Offset(s * 0.64, s * 0.16),
      _stroke(s * 0.018),
    );
    canvas.drawLine(
      Offset(s * 0.36, s * 0.22),
      Offset(s * 0.6, s * 0.22),
      _stroke(s * 0.018),
    );
    canvas.drawLine(
      Offset(s * 0.36, s * 0.28),
      Offset(s * 0.58, s * 0.28),
      _stroke(s * 0.018),
    );
  }

  // ========== المشتريات (سلة) ==========
  void _purchases(Canvas canvas, Size size) {
    final s = size.width;
    final cart = Path()
      ..moveTo(s * 0.1, s * 0.32)
      ..lineTo(s * 0.22, s * 0.32)
      ..lineTo(s * 0.32, s * 0.7)
      ..lineTo(s * 0.82, s * 0.7);
    canvas.drawPath(cart, _stroke(s * 0.04));
    final basket = Path()
      ..moveTo(s * 0.24, s * 0.4)
      ..lineTo(s * 0.92, s * 0.4)
      ..lineTo(s * 0.84, s * 0.66)
      ..lineTo(s * 0.32, s * 0.66)
      ..close();
    canvas.drawPath(basket, _fill(0.75));
    canvas.drawPath(basket, _stroke(s * 0.025));
    canvas.drawLine(
      Offset(s * 0.45, s * 0.4),
      Offset(s * 0.43, s * 0.66),
      _stroke(s * 0.02),
    );
    canvas.drawLine(
      Offset(s * 0.6, s * 0.4),
      Offset(s * 0.6, s * 0.66),
      _stroke(s * 0.02),
    );
    canvas.drawLine(
      Offset(s * 0.75, s * 0.4),
      Offset(s * 0.77, s * 0.66),
      _stroke(s * 0.02),
    );
    canvas.drawCircle(
      Offset(s * 0.42, s * 0.82),
      s * 0.055,
      _fillColor(AppColors.textPrimary, 0.9),
    );
    canvas.drawCircle(
      Offset(s * 0.42, s * 0.82),
      s * 0.022,
      _fillColor(Colors.white, 1),
    );
    canvas.drawCircle(
      Offset(s * 0.74, s * 0.82),
      s * 0.055,
      _fillColor(AppColors.textPrimary, 0.9),
    );
    canvas.drawCircle(
      Offset(s * 0.74, s * 0.82),
      s * 0.022,
      _fillColor(Colors.white, 1),
    );
  }

  // ========== فاتورة ==========
  void _invoice(Canvas canvas, Size size) {
    final s = size.width;
    final paper = Path()
      ..moveTo(s * 0.18, s * 0.1)
      ..lineTo(s * 0.78, s * 0.1)
      ..lineTo(s * 0.82, s * 0.18)
      ..lineTo(s * 0.82, s * 0.92)
      ..lineTo(s * 0.74, s * 0.86)
      ..lineTo(s * 0.66, s * 0.92)
      ..lineTo(s * 0.58, s * 0.86)
      ..lineTo(s * 0.5, s * 0.92)
      ..lineTo(s * 0.42, s * 0.86)
      ..lineTo(s * 0.34, s * 0.92)
      ..lineTo(s * 0.26, s * 0.86)
      ..lineTo(s * 0.18, s * 0.92)
      ..close();
    canvas.drawPath(paper, _fillColor(Colors.white, 0.97));
    canvas.drawPath(paper, _stroke(s * 0.022));
    canvas.drawRect(
      Rect.fromLTWH(s * 0.26, s * 0.18, s * 0.48, s * 0.06),
      _fill(0.7),
    );
    for (int i = 0; i < 3; i++) {
      final y = s * 0.32 + i * s * 0.1;
      canvas.drawLine(
        Offset(s * 0.26, y),
        Offset(s * 0.62, y),
        _stroke(s * 0.018),
      );
      canvas.drawLine(
        Offset(s * 0.66, y),
        Offset(s * 0.74, y),
        _stroke(s * 0.025),
      );
    }
    canvas.drawLine(
      Offset(s * 0.26, s * 0.66),
      Offset(s * 0.74, s * 0.66),
      _stroke(s * 0.022),
    );
    canvas.drawRect(
      Rect.fromLTWH(s * 0.5, s * 0.7, s * 0.24, s * 0.08),
      _fillColor(AppColors.gold, 0.9),
    );
  }

  // ========== سند قبض ==========
  void _receiptVoucher(Canvas canvas, Size size) {
    final s = size.width;
    final paper = Rect.fromLTWH(s * 0.16, s * 0.12, s * 0.68, s * 0.58);
    canvas.drawRRect(
      RRect.fromRectAndRadius(paper, Radius.circular(s * 0.04)),
      _fillColor(Colors.white, 0.97),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(paper, Radius.circular(s * 0.04)),
      _stroke(s * 0.022),
    );
    canvas.drawLine(
      Offset(s * 0.22, s * 0.24),
      Offset(s * 0.78, s * 0.24),
      _stroke(s * 0.022),
    );
    canvas.drawLine(
      Offset(s * 0.22, s * 0.34),
      Offset(s * 0.66, s * 0.34),
      _stroke(s * 0.018),
    );
    canvas.drawLine(
      Offset(s * 0.22, s * 0.42),
      Offset(s * 0.7, s * 0.42),
      _stroke(s * 0.018),
    );
    canvas.drawLine(
      Offset(s * 0.22, s * 0.54),
      Offset(s * 0.78, s * 0.54),
      _stroke(s * 0.018),
    );
    canvas.drawCircle(Offset(s * 0.74, s * 0.78), s * 0.16, _fill(0.95));
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.04
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final arrow = Path()
      ..moveTo(s * 0.74, s * 0.7)
      ..lineTo(s * 0.74, s * 0.86)
      ..moveTo(s * 0.66, s * 0.78)
      ..lineTo(s * 0.74, s * 0.86)
      ..lineTo(s * 0.82, s * 0.78);
    canvas.drawPath(arrow, arrowPaint);
  }

  // ========== سند صرف ==========
  void _paymentVoucher(Canvas canvas, Size size) {
    final s = size.width;
    final paper = Rect.fromLTWH(s * 0.16, s * 0.12, s * 0.68, s * 0.58);
    canvas.drawRRect(
      RRect.fromRectAndRadius(paper, Radius.circular(s * 0.04)),
      _fillColor(Colors.white, 0.97),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(paper, Radius.circular(s * 0.04)),
      _stroke(s * 0.022),
    );
    canvas.drawLine(
      Offset(s * 0.22, s * 0.24),
      Offset(s * 0.78, s * 0.24),
      _stroke(s * 0.022),
    );
    canvas.drawLine(
      Offset(s * 0.22, s * 0.34),
      Offset(s * 0.66, s * 0.34),
      _stroke(s * 0.018),
    );
    canvas.drawLine(
      Offset(s * 0.22, s * 0.42),
      Offset(s * 0.7, s * 0.42),
      _stroke(s * 0.018),
    );
    canvas.drawLine(
      Offset(s * 0.22, s * 0.54),
      Offset(s * 0.78, s * 0.54),
      _stroke(s * 0.018),
    );
    canvas.drawCircle(Offset(s * 0.74, s * 0.78), s * 0.16, _fill(0.95));
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.04
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final arrow = Path()
      ..moveTo(s * 0.74, s * 0.86)
      ..lineTo(s * 0.74, s * 0.7)
      ..moveTo(s * 0.66, s * 0.78)
      ..lineTo(s * 0.74, s * 0.7)
      ..lineTo(s * 0.82, s * 0.78);
    canvas.drawPath(arrow, arrowPaint);
  }

  // ========== سندات قبض/صرف معًا ==========
  void _vouchers(Canvas canvas, Size size) {
    final s = size.width;
    final back = Rect.fromLTWH(s * 0.22, s * 0.16, s * 0.56, s * 0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(back, Radius.circular(s * 0.04)),
      _fill(0.55),
    );
    final front = Rect.fromLTWH(s * 0.14, s * 0.24, s * 0.56, s * 0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(front, Radius.circular(s * 0.04)),
      _fillColor(Colors.white, 1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(front, Radius.circular(s * 0.04)),
      _stroke(s * 0.022),
    );
    canvas.drawRect(
      Rect.fromLTWH(s * 0.2, s * 0.32, s * 0.34, s * 0.06),
      _fill(0.7),
    );
    canvas.drawLine(
      Offset(s * 0.2, s * 0.46),
      Offset(s * 0.6, s * 0.46),
      _stroke(s * 0.018),
    );
    canvas.drawLine(
      Offset(s * 0.2, s * 0.54),
      Offset(s * 0.5, s * 0.54),
      _stroke(s * 0.018),
    );
    canvas.drawLine(
      Offset(s * 0.2, s * 0.62),
      Offset(s * 0.55, s * 0.62),
      _stroke(s * 0.018),
    );
    canvas.drawCircle(
      Offset(s * 0.32, s * 0.78),
      s * 0.07,
      _fillColor(AppColors.success, 1),
    );
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.022
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(s * 0.28, s * 0.78),
      Offset(s * 0.36, s * 0.78),
      iconPaint,
    );
    canvas.drawLine(
      Offset(s * 0.32, s * 0.74),
      Offset(s * 0.32, s * 0.82),
      iconPaint,
    );
    canvas.drawCircle(
      Offset(s * 0.5, s * 0.78),
      s * 0.07,
      _fillColor(AppColors.error, 1),
    );
    canvas.drawLine(
      Offset(s * 0.46, s * 0.78),
      Offset(s * 0.54, s * 0.78),
      iconPaint,
    );
  }

  // ========== التقارير (لوحة بيانية) ==========
  void _reports(Canvas canvas, Size size) {
    final s = size.width;
    final board = Rect.fromLTWH(s * 0.1, s * 0.14, s * 0.8, s * 0.66);
    canvas.drawRRect(
      RRect.fromRectAndRadius(board, Radius.circular(s * 0.04)),
      _fill(0.18),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(board, Radius.circular(s * 0.04)),
      _stroke(s * 0.022),
    );
    final cols = [0.3, 0.55, 0.7, 0.45];
    for (int i = 0; i < 4; i++) {
      final x = s * 0.18 + i * s * 0.16;
      final h = s * 0.4 * cols[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, s * 0.7 - h, s * 0.1, h),
          Radius.circular(s * 0.012),
        ),
        _fill(0.85),
      );
    }
    canvas.drawLine(
      Offset(s * 0.14, s * 0.7),
      Offset(s * 0.86, s * 0.7),
      _stroke(s * 0.022),
    );
    canvas.drawRect(
      Rect.fromLTWH(s * 0.42, s * 0.8, s * 0.16, s * 0.06),
      _fill(0.85),
    );
    canvas.drawRect(
      Rect.fromLTWH(s * 0.34, s * 0.86, s * 0.32, s * 0.04),
      _fill(0.85),
    );
  }

  // ========== قائمة الدخل ==========
  void _incomeStatement(Canvas canvas, Size size) {
    final s = size.width;
    final paper = Rect.fromLTWH(s * 0.14, s * 0.12, s * 0.5, s * 0.76);
    canvas.drawRRect(
      RRect.fromRectAndRadius(paper, Radius.circular(s * 0.03)),
      _fillColor(Colors.white, 1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(paper, Radius.circular(s * 0.03)),
      _stroke(s * 0.02),
    );
    canvas.drawRect(
      Rect.fromLTWH(s * 0.18, s * 0.18, s * 0.42, s * 0.05),
      _fill(0.7),
    );
    for (int i = 0; i < 4; i++) {
      final y = s * 0.3 + i * s * 0.1;
      canvas.drawLine(
        Offset(s * 0.18, y),
        Offset(s * 0.48, y),
        _stroke(s * 0.016),
      );
      canvas.drawLine(
        Offset(s * 0.5, y),
        Offset(s * 0.6, y),
        _stroke(s * 0.022),
      );
    }
    final growth = Path()
      ..moveTo(s * 0.7, s * 0.7)
      ..lineTo(s * 0.78, s * 0.55)
      ..lineTo(s * 0.84, s * 0.62)
      ..lineTo(s * 0.94, s * 0.4);
    final gp = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.03
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(growth, gp);
    final arrow = Path()
      ..moveTo(s * 0.94, s * 0.4)
      ..lineTo(s * 0.86, s * 0.4)
      ..moveTo(s * 0.94, s * 0.4)
      ..lineTo(s * 0.94, s * 0.48);
    canvas.drawPath(arrow, gp);
  }

  // ========== المركز المالي (محفظة + أوراق نقدية) ==========
  void _balanceSheet(Canvas canvas, Size size) {
    final s = size.width;
    final wallet = Rect.fromLTWH(s * 0.12, s * 0.32, s * 0.76, s * 0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(wallet, Radius.circular(s * 0.06)),
      _fill(0.85),
    );
    final flap = Rect.fromLTWH(s * 0.12, s * 0.24, s * 0.6, s * 0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(flap, Radius.circular(s * 0.04)),
      _fill(0.65),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.62, s * 0.46, s * 0.22, s * 0.16),
        Radius.circular(s * 0.03),
      ),
      _fillColor(AppColors.gold, 0.95),
    );
    canvas.drawCircle(
      Offset(s * 0.78, s * 0.54),
      s * 0.025,
      _fillColor(Colors.white, 1),
    );
    final bill1 = Rect.fromLTWH(s * 0.2, s * 0.16, s * 0.4, s * 0.1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bill1, Radius.circular(s * 0.015)),
      _fillColor(AppColors.success, 0.9),
    );
    final bill2 = Rect.fromLTWH(s * 0.26, s * 0.1, s * 0.3, s * 0.08);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bill2, Radius.circular(s * 0.015)),
      _fillColor(AppColors.gold, 0.95),
    );
  }

  // ========== تقرير الصندوق ==========
  void _cashReport(Canvas canvas, Size size) {
    final s = size.width;
    void coin(double cy, double r, Color c) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(s * 0.36, cy),
          width: r * 2,
          height: r * 0.6,
        ),
        _fillColor(c, 0.4),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(s * 0.36, cy - r * 0.15),
          width: r * 2,
          height: r * 0.6,
        ),
        _fillColor(c, 1),
      );
    }

    coin(s * 0.78, s * 0.22, AppColors.gold);
    coin(s * 0.66, s * 0.22, AppColors.gold);
    coin(s * 0.54, s * 0.22, AppColors.gold);
    final bill = Rect.fromLTWH(s * 0.5, s * 0.2, s * 0.42, s * 0.24);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bill, Radius.circular(s * 0.02)),
      _fillColor(AppColors.success, 0.92),
    );
    canvas.drawCircle(
      Offset(s * 0.71, s * 0.32),
      s * 0.05,
      _fillColor(Colors.white, 0.45),
    );
    canvas.drawCircle(
      Offset(s * 0.71, s * 0.32),
      s * 0.025,
      _fillColor(Colors.white, 1),
    );
  }

  // ========== تقرير المبيعات (مخطط دائري) ==========
  void _salesReport(Canvas canvas, Size size) {
    final s = size.width;
    final center = Offset(s * 0.5, s * 0.5);
    final r = s * 0.32;
    final rect = Rect.fromCircle(center: center, radius: r);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * 0.42,
      true,
      Paint()..color = color,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2 + math.pi * 2 * 0.42,
      math.pi * 2 * 0.28,
      true,
      Paint()..color = AppColors.gold,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2 + math.pi * 2 * 0.7,
      math.pi * 2 * 0.3,
      true,
      Paint()..color = AppColors.success,
    );
    canvas.drawCircle(center, r * 0.45, _fillColor(Colors.white, 1));
    canvas.drawCircle(center, r * 0.45, _stroke(s * 0.02));
  }

  // ========== تقرير المخزون (كليبورد) ==========
  void _inventoryReport(Canvas canvas, Size size) {
    final s = size.width;
    final board = Rect.fromLTWH(s * 0.18, s * 0.16, s * 0.64, s * 0.74);
    canvas.drawRRect(
      RRect.fromRectAndRadius(board, Radius.circular(s * 0.04)),
      _fill(0.85),
    );
    final paper = Rect.fromLTWH(s * 0.22, s * 0.22, s * 0.56, s * 0.62);
    canvas.drawRRect(
      RRect.fromRectAndRadius(paper, Radius.circular(s * 0.02)),
      _fillColor(Colors.white, 1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.38, s * 0.1, s * 0.24, s * 0.12),
        Radius.circular(s * 0.02),
      ),
      _fill(1),
    );
    for (int i = 0; i < 4; i++) {
      final y = s * 0.32 + i * s * 0.13;
      canvas.drawRect(
        Rect.fromLTWH(s * 0.27, y - s * 0.025, s * 0.05, s * 0.05),
        _fill(0.85),
      );
      canvas.drawLine(
        Offset(s * 0.36, y),
        Offset(s * 0.74, y),
        _stroke(s * 0.018),
      );
    }
  }

  // ========== التحليل المالي (شاشة + خط نمو) ==========
  void _financialAnalysis(Canvas canvas, Size size) {
    final s = size.width;
    final screen = Rect.fromLTWH(s * 0.1, s * 0.18, s * 0.8, s * 0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(screen, Radius.circular(s * 0.03)),
      _fill(0.18),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(screen, Radius.circular(s * 0.03)),
      _stroke(s * 0.022),
    );
    final line = Path()
      ..moveTo(s * 0.16, s * 0.6)
      ..lineTo(s * 0.3, s * 0.5)
      ..lineTo(s * 0.45, s * 0.55)
      ..lineTo(s * 0.6, s * 0.4)
      ..lineTo(s * 0.84, s * 0.28);
    final gp = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.032
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(line, gp);
    for (final p in [
      Offset(s * 0.3, s * 0.5),
      Offset(s * 0.45, s * 0.55),
      Offset(s * 0.6, s * 0.4),
      Offset(s * 0.84, s * 0.28),
    ]) {
      canvas.drawCircle(p, s * 0.025, _fillColor(AppColors.success, 1));
    }
    canvas.drawRect(
      Rect.fromLTWH(s * 0.3, s * 0.7, s * 0.4, s * 0.04),
      _fill(0.85),
    );
    canvas.drawRect(
      Rect.fromLTWH(s * 0.4, s * 0.74, s * 0.2, s * 0.06),
      _fill(0.85),
    );
  }

  // ========== الصندوق (نقد) ==========
  void _cashBox(Canvas canvas, Size size) {
    final s = size.width;
    final box = Rect.fromLTWH(s * 0.12, s * 0.32, s * 0.76, s * 0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, Radius.circular(s * 0.04)),
      _fill(0.85),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.12, s * 0.32, s * 0.76, s * 0.1),
        Radius.circular(s * 0.04),
      ),
      _fillColor(Colors.black, 0.15),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.32, s * 0.36, s * 0.36, s * 0.04),
        Radius.circular(s * 0.01),
      ),
      _fillColor(Colors.black, 0.5),
    );
    canvas.drawCircle(
      Offset(s * 0.5, s * 0.6),
      s * 0.1,
      _fillColor(AppColors.gold, 1),
    );
    final dollarPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.025
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(s * 0.5, s * 0.51),
      Offset(s * 0.5, s * 0.69),
      dollarPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(s * 0.5, s * 0.56), radius: s * 0.04),
      0.5,
      4,
      false,
      dollarPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(s * 0.5, s * 0.64), radius: s * 0.04),
      0.5 + math.pi,
      4,
      false,
      dollarPaint,
    );
    final bill = Rect.fromLTWH(s * 0.36, s * 0.16, s * 0.28, s * 0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bill, Radius.circular(s * 0.015)),
      _fillColor(AppColors.success, 0.95),
    );
  }

  // ========== مديونية العملاء ==========
  void _receivables(Canvas canvas, Size size) {
    final s = size.width;
    canvas.drawCircle(Offset(s * 0.28, s * 0.3), s * 0.1, _fill(0.85));
    final body = Path()
      ..moveTo(s * 0.12, s * 0.62)
      ..quadraticBezierTo(s * 0.12, s * 0.4, s * 0.28, s * 0.4)
      ..quadraticBezierTo(s * 0.44, s * 0.4, s * 0.44, s * 0.62)
      ..close();
    canvas.drawPath(body, _fill(0.85));
    final paper = Rect.fromLTWH(s * 0.5, s * 0.32, s * 0.36, s * 0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(paper, Radius.circular(s * 0.02)),
      _fillColor(Colors.white, 1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(paper, Radius.circular(s * 0.02)),
      _stroke(s * 0.02),
    );
    canvas.drawLine(
      Offset(s * 0.54, s * 0.4),
      Offset(s * 0.82, s * 0.4),
      _stroke(s * 0.018),
    );
    canvas.drawLine(
      Offset(s * 0.54, s * 0.5),
      Offset(s * 0.78, s * 0.5),
      _stroke(s * 0.018),
    );
    canvas.drawLine(
      Offset(s * 0.54, s * 0.6),
      Offset(s * 0.74, s * 0.6),
      _stroke(s * 0.018),
    );
    canvas.drawRect(
      Rect.fromLTWH(s * 0.6, s * 0.66, s * 0.22, s * 0.08),
      _fillColor(AppColors.warning, 0.9),
    );
  }

  // ========== مديونيتنا للموردين ==========
  void _payables(Canvas canvas, Size size) {
    final s = size.width;
    final paper = Rect.fromLTWH(s * 0.14, s * 0.14, s * 0.5, s * 0.62);
    canvas.drawRRect(
      RRect.fromRectAndRadius(paper, Radius.circular(s * 0.03)),
      _fillColor(Colors.white, 1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(paper, Radius.circular(s * 0.03)),
      _stroke(s * 0.022),
    );
    canvas.drawRect(
      Rect.fromLTWH(s * 0.18, s * 0.2, s * 0.3, s * 0.05),
      _fill(0.85),
    );
    for (int i = 0; i < 3; i++) {
      final y = s * 0.34 + i * s * 0.1;
      canvas.drawLine(
        Offset(s * 0.18, y),
        Offset(s * 0.42, y),
        _stroke(s * 0.018),
      );
      canvas.drawLine(
        Offset(s * 0.46, y),
        Offset(s * 0.58, y),
        _stroke(s * 0.022),
      );
    }
    final alert = Path()
      ..moveTo(s * 0.74, s * 0.5)
      ..lineTo(s * 0.92, s * 0.84)
      ..lineTo(s * 0.56, s * 0.84)
      ..close();
    canvas.drawPath(alert, _fillColor(AppColors.warning, 1));
    canvas.drawPath(alert, _stroke(s * 0.022));
    final excl = Paint()
      ..color = Colors.white
      ..strokeWidth = s * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(s * 0.74, s * 0.66),
      Offset(s * 0.74, s * 0.76),
      excl,
    );
    canvas.drawCircle(
      Offset(s * 0.74, s * 0.8),
      s * 0.018,
      _fillColor(Colors.white, 1),
    );
  }

  // ========== قيمة المخزون ==========
  void _inventoryValue(Canvas canvas, Size size) {
    final s = size.width;
    final box = Rect.fromLTWH(s * 0.16, s * 0.32, s * 0.5, s * 0.46);
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, Radius.circular(s * 0.03)),
      _fill(0.85),
    );
    canvas.drawLine(
      Offset(s * 0.16, s * 0.42),
      Offset(s * 0.66, s * 0.42),
      _stroke(s * 0.018),
    );
    canvas.drawLine(
      Offset(s * 0.41, s * 0.32),
      Offset(s * 0.41, s * 0.42),
      _stroke(s * 0.018),
    );
    final tag = Path()
      ..moveTo(s * 0.58, s * 0.16)
      ..lineTo(s * 0.92, s * 0.16)
      ..lineTo(s * 0.92, s * 0.42)
      ..lineTo(s * 0.78, s * 0.56)
      ..lineTo(s * 0.58, s * 0.42)
      ..close();
    canvas.drawPath(tag, _fillColor(AppColors.gold, 1));
    canvas.drawCircle(
      Offset(s * 0.84, s * 0.24),
      s * 0.03,
      _fillColor(Colors.white, 1),
    );
  }

  // ========== الدروس (كتاب + علامة) ==========
  void _lessons(Canvas canvas, Size size) {
    final s = size.width;
    final book = Rect.fromLTWH(s * 0.16, s * 0.18, s * 0.68, s * 0.66);
    canvas.drawRRect(
      RRect.fromRectAndRadius(book, Radius.circular(s * 0.03)),
      _fill(0.85),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.22, s * 0.18, s * 0.56, s * 0.66),
        Radius.circular(s * 0.02),
      ),
      _fillColor(Colors.white, 1),
    );
    for (int i = 0; i < 5; i++) {
      final y = s * 0.3 + i * s * 0.1;
      canvas.drawLine(
        Offset(s * 0.28, y),
        Offset(s * 0.72, y),
        _stroke(s * 0.018),
      );
    }
    final ribbon = Path()
      ..moveTo(s * 0.62, s * 0.1)
      ..lineTo(s * 0.78, s * 0.1)
      ..lineTo(s * 0.78, s * 0.4)
      ..lineTo(s * 0.7, s * 0.34)
      ..lineTo(s * 0.62, s * 0.4)
      ..close();
    canvas.drawPath(ribbon, _fillColor(AppColors.error, 0.9));
  }

  // ========== التدريب (دمبل) ==========
  void _training(Canvas canvas, Size size) {
    final s = size.width;
    canvas.drawRect(
      Rect.fromLTWH(s * 0.22, s * 0.46, s * 0.56, s * 0.08),
      _fill(0.85),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.06, s * 0.32, s * 0.16, s * 0.36),
        Radius.circular(s * 0.04),
      ),
      _fill(1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.78, s * 0.32, s * 0.16, s * 0.36),
        Radius.circular(s * 0.04),
      ),
      _fill(1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.0, s * 0.4, s * 0.06, s * 0.2),
        Radius.circular(s * 0.02),
      ),
      _fill(0.7),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.94, s * 0.4, s * 0.06, s * 0.2),
        Radius.circular(s * 0.02),
      ),
      _fill(0.7),
    );
    final star = Paint()
      ..color = AppColors.gold
      ..strokeWidth = s * 0.025
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(s * 0.5, s * 0.18), Offset(s * 0.5, s * 0.3), star);
    canvas.drawLine(
      Offset(s * 0.36, s * 0.22),
      Offset(s * 0.42, s * 0.28),
      star,
    );
    canvas.drawLine(
      Offset(s * 0.64, s * 0.22),
      Offset(s * 0.58, s * 0.28),
      star,
    );
  }

  // ========== الاختبارات (فقاعة سؤال) ==========
  void _quiz(Canvas canvas, Size size) {
    final s = size.width;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.12, s * 0.14, s * 0.76, s * 0.6),
        Radius.circular(s * 0.08),
      ),
      _fill(0.85),
    );
    final tail = Path()
      ..moveTo(s * 0.32, s * 0.7)
      ..lineTo(s * 0.24, s * 0.88)
      ..lineTo(s * 0.46, s * 0.7)
      ..close();
    canvas.drawPath(tail, _fill(0.85));
    final qPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(s * 0.5, s * 0.34), radius: s * 0.1),
      math.pi,
      math.pi,
      false,
      qPaint,
    );
    canvas.drawLine(
      Offset(s * 0.5, s * 0.44),
      Offset(s * 0.5, s * 0.5),
      qPaint,
    );
    canvas.drawCircle(
      Offset(s * 0.5, s * 0.58),
      s * 0.04,
      _fillColor(Colors.white, 1),
    );
  }

  // ========== التقدم (كأس + قاعدة) ==========
  void _progress(Canvas canvas, Size size) {
    final s = size.width;
    final cup = Path()
      ..moveTo(s * 0.3, s * 0.18)
      ..lineTo(s * 0.7, s * 0.18)
      ..lineTo(s * 0.66, s * 0.5)
      ..quadraticBezierTo(s * 0.5, s * 0.62, s * 0.34, s * 0.5)
      ..close();
    canvas.drawPath(cup, _fillColor(AppColors.gold, 1));
    canvas.drawPath(cup, _stroke(s * 0.022));
    final hLeft = Path()
      ..moveTo(s * 0.3, s * 0.22)
      ..quadraticBezierTo(s * 0.16, s * 0.3, s * 0.32, s * 0.4);
    final hRight = Path()
      ..moveTo(s * 0.7, s * 0.22)
      ..quadraticBezierTo(s * 0.84, s * 0.3, s * 0.68, s * 0.4);
    canvas.drawPath(hLeft, _stroke(s * 0.04));
    canvas.drawPath(hRight, _stroke(s * 0.04));
    canvas.drawRect(
      Rect.fromLTWH(s * 0.46, s * 0.62, s * 0.08, s * 0.12),
      _fillColor(AppColors.gold, 0.85),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.3, s * 0.74, s * 0.4, s * 0.1),
        Radius.circular(s * 0.02),
      ),
      _fillColor(AppColors.gold, 0.85),
    );
    canvas.drawCircle(
      Offset(s * 0.5, s * 0.34),
      s * 0.07,
      _fillColor(Colors.white, 0.85),
    );
  }

  // ========== المعجم (كتب) ==========
  void _glossary(Canvas canvas, Size size) {
    final s = size.width;
    canvas.drawRect(
      Rect.fromLTWH(s * 0.16, s * 0.22, s * 0.16, s * 0.6),
      _fillColor(AppColors.primary, 0.85),
    );
    canvas.drawRect(
      Rect.fromLTWH(s * 0.36, s * 0.18, s * 0.16, s * 0.64),
      _fillColor(AppColors.accent, 0.85),
    );
    canvas.drawRect(
      Rect.fromLTWH(s * 0.56, s * 0.26, s * 0.16, s * 0.56),
      _fillColor(AppColors.gold, 0.95),
    );
    canvas.drawRect(
      Rect.fromLTWH(s * 0.76, s * 0.24, s * 0.1, s * 0.58),
      _fillColor(AppColors.primary, 0.65),
    );
    canvas.drawRect(
      Rect.fromLTWH(s * 0.1, s * 0.82, s * 0.8, s * 0.04),
      _fill(0.4),
    );
    canvas.drawLine(
      Offset(s * 0.42, s * 0.32),
      Offset(s * 0.42, s * 0.7),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..strokeWidth = s * 0.018,
    );
  }

  // ========== المحاكي (شاشة كمبيوتر) ==========
  void _simulator(Canvas canvas, Size size) {
    final s = size.width;
    final monitor = Rect.fromLTWH(s * 0.1, s * 0.16, s * 0.8, s * 0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(monitor, Radius.circular(s * 0.04)),
      _fill(0.85),
    );
    final screen = Rect.fromLTWH(s * 0.14, s * 0.2, s * 0.72, s * 0.42);
    canvas.drawRRect(
      RRect.fromRectAndRadius(screen, Radius.circular(s * 0.02)),
      _fillColor(Colors.white, 1),
    );
    canvas.drawLine(
      Offset(s * 0.18, s * 0.28),
      Offset(s * 0.4, s * 0.28),
      _stroke(s * 0.018),
    );
    canvas.drawLine(
      Offset(s * 0.18, s * 0.34),
      Offset(s * 0.34, s * 0.34),
      _stroke(s * 0.018),
    );
    canvas.drawLine(
      Offset(s * 0.18, s * 0.4),
      Offset(s * 0.36, s * 0.4),
      _stroke(s * 0.018),
    );
    for (int i = 0; i < 3; i++) {
      final h = (i + 1) * s * 0.06;
      canvas.drawRect(
        Rect.fromLTWH(s * 0.5 + i * s * 0.1, s * 0.56 - h, s * 0.06, h),
        _fill(0.85),
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(s * 0.42, s * 0.66, s * 0.16, s * 0.12),
      _fill(0.85),
    );
    canvas.drawRect(
      Rect.fromLTWH(s * 0.3, s * 0.78, s * 0.4, s * 0.04),
      _fill(0.85),
    );
  }

  // ========== المحاسبة المالية (عملة + نمو) ==========
  void _financialAccounting(Canvas canvas, Size size) {
    final s = size.width;
    canvas.drawCircle(
      Offset(s * 0.34, s * 0.5),
      s * 0.24,
      _fillColor(AppColors.gold, 1),
    );
    canvas.drawCircle(Offset(s * 0.34, s * 0.5), s * 0.24, _stroke(s * 0.022));
    final dollarPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(s * 0.34, s * 0.36),
      Offset(s * 0.34, s * 0.64),
      dollarPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(s * 0.34, s * 0.46), radius: s * 0.06),
      0.5,
      4,
      false,
      dollarPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(s * 0.34, s * 0.56), radius: s * 0.06),
      0.5 + math.pi,
      4,
      false,
      dollarPaint,
    );
    final line = Path()
      ..moveTo(s * 0.6, s * 0.7)
      ..lineTo(s * 0.7, s * 0.55)
      ..lineTo(s * 0.78, s * 0.6)
      ..lineTo(s * 0.92, s * 0.4);
    final gp = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.03
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(line, gp);
    canvas.drawCircle(
      Offset(s * 0.92, s * 0.4),
      s * 0.025,
      _fillColor(AppColors.success, 1),
    );
  }

  // ========== الإعدادات (ترس) ==========
  void _settings(Canvas canvas, Size size) {
    final s = size.width;
    final cx = s / 2;
    final cy = s / 2;
    final outerR = s * 0.34;
    final teethR = s * 0.44;
    final path = Path();
    const segments = 32;
    for (int i = 0; i < segments; i++) {
      final angle = i * 2 * math.pi / segments;
      final isOuter = (i % 4 == 1) || (i % 4 == 2);
      final r = isOuter ? teethR : outerR;
      final ax = cx + r * math.cos(angle);
      final ay = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(ax, ay);
      } else {
        path.lineTo(ax, ay);
      }
    }
    path.close();
    canvas.drawPath(path, _fill(0.85));
    canvas.drawPath(path, _stroke(s * 0.022));
    canvas.drawCircle(Offset(cx, cy), s * 0.13, _fillColor(Colors.white, 1));
    canvas.drawCircle(Offset(cx, cy), s * 0.13, _stroke(s * 0.022));
  }

  // ========== عن التطبيق (i) ==========
  void _about(Canvas canvas, Size size) {
    final s = size.width;
    canvas.drawCircle(Offset(s * 0.5, s * 0.5), s * 0.36, _fill(0.85));
    canvas.drawCircle(Offset(s * 0.5, s * 0.5), s * 0.36, _stroke(s * 0.022));
    canvas.drawCircle(
      Offset(s * 0.5, s * 0.34),
      s * 0.04,
      _fillColor(Colors.white, 1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.46, s * 0.42, s * 0.08, s * 0.24),
        Radius.circular(s * 0.02),
      ),
      _fillColor(Colors.white, 1),
    );
  }

  // ========== الشركة (مبنى) ==========
  void _company(Canvas canvas, Size size) {
    final s = size.width;
    final main = Rect.fromLTWH(s * 0.32, s * 0.18, s * 0.4, s * 0.66);
    canvas.drawRRect(
      RRect.fromRectAndRadius(main, Radius.circular(s * 0.03)),
      _fill(0.85),
    );
    final side = Rect.fromLTWH(s * 0.1, s * 0.4, s * 0.22, s * 0.44);
    canvas.drawRRect(
      RRect.fromRectAndRadius(side, Radius.circular(s * 0.02)),
      _fill(0.65),
    );
    final side2 = Rect.fromLTWH(s * 0.72, s * 0.46, s * 0.2, s * 0.38);
    canvas.drawRRect(
      RRect.fromRectAndRadius(side2, Radius.circular(s * 0.02)),
      _fill(0.6),
    );
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 3; c++) {
        canvas.drawRect(
          Rect.fromLTWH(
            s * 0.36 + c * s * 0.1,
            s * 0.26 + r * s * 0.13,
            s * 0.06,
            s * 0.06,
          ),
          _fillColor(AppColors.gold, 0.95),
        );
      }
    }
    canvas.drawRect(
      Rect.fromLTWH(s * 0.46, s * 0.74, s * 0.12, s * 0.1),
      _fillColor(AppColors.textPrimary, 0.6),
    );
  }

  // ========== مستند ==========
  void _document(Canvas canvas, Size size) {
    final s = size.width;
    final paper = Path()
      ..moveTo(s * 0.2, s * 0.1)
      ..lineTo(s * 0.66, s * 0.1)
      ..lineTo(s * 0.82, s * 0.26)
      ..lineTo(s * 0.82, s * 0.9)
      ..lineTo(s * 0.2, s * 0.9)
      ..close();
    canvas.drawPath(paper, _fillColor(Colors.white, 1));
    canvas.drawPath(paper, _stroke(s * 0.022));
    final fold = Path()
      ..moveTo(s * 0.66, s * 0.1)
      ..lineTo(s * 0.66, s * 0.26)
      ..lineTo(s * 0.82, s * 0.26);
    canvas.drawPath(fold, _stroke(s * 0.018));
    for (int i = 0; i < 4; i++) {
      final y = s * 0.4 + i * s * 0.1;
      canvas.drawLine(
        Offset(s * 0.28, y),
        Offset(s * 0.74, y),
        _stroke(s * 0.018),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ThumbnailPainter old) {
    return old.kind != kind || old.color != color;
  }
}
