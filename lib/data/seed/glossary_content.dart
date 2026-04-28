/// قاموس المصطلحات المحاسبية اليمنية
library;

class GlossaryTerm {
  final String term;
  final String definition;
  final String? example;

  const GlossaryTerm({
    required this.term,
    required this.definition,
    this.example,
  });
}

const List<GlossaryTerm> glossary = [
  GlossaryTerm(
    term: 'القيد المحاسبي',
    definition:
        'تسجيل أي عملية مالية في الدفاتر بمعادلة "من ح/... إلى ح/..."، حيث الطرف المدين = الطرف الدائن.',
    example: 'من ح/ الصندوق 100,000 إلى ح/ المبيعات 100,000',
  ),
  GlossaryTerm(
    term: 'مدين (Debit)',
    definition:
        'الطرف اليمين من القيد. يُسجل على المدين زيادة الأصول والمصروفات أو نقص الالتزامات وحقوق الملكية والإيرادات.',
  ),
  GlossaryTerm(
    term: 'دائن (Credit)',
    definition:
        'الطرف اليسار من القيد. يُسجل على الدائن زيادة الالتزامات وحقوق الملكية والإيرادات أو نقص الأصول والمصروفات.',
  ),
  GlossaryTerm(
    term: 'شجرة الحسابات',
    definition:
        'هيكل هرمي يضم جميع الحسابات المُستخدمة في الشركة، مرتبة في خمس مجموعات: الأصول، الالتزامات، حقوق الملكية، الإيرادات، المصروفات.',
  ),
  GlossaryTerm(
    term: 'الأصول',
    definition: 'كل ما تملكه الشركة: نقدية، مخزون، سيارات، عقارات، عملاء (مدينون).',
  ),
  GlossaryTerm(
    term: 'الالتزامات',
    definition: 'كل ما على الشركة من ديون: موردون (دائنون)، قروض، مصروفات مستحقة.',
  ),
  GlossaryTerm(
    term: 'حقوق الملكية',
    definition: 'صافي حق المالك في الشركة = الأصول - الالتزامات.',
  ),
  GlossaryTerm(
    term: 'الإيرادات',
    definition: 'الدخل المحقق من النشاط: مبيعات، إيرادات خدمات، فروق صرف.',
  ),
  GlossaryTerm(
    term: 'المصروفات',
    definition: 'كل المبالغ التي تُنفقها الشركة: إيجار، رواتب، كهرباء، تكلفة بضاعة.',
  ),
  GlossaryTerm(
    term: 'سند القبض',
    definition: 'مستند يُسجل استلام مبلغ نقدي من عميل أو طرف، يزيد رصيد الصندوق/البنك.',
  ),
  GlossaryTerm(
    term: 'سند الصرف',
    definition: 'مستند يُسجل دفع مبلغ نقدي لمورد أو طرف، يُنقص رصيد الصندوق/البنك.',
  ),
  GlossaryTerm(
    term: 'فاتورة بيع نقدية',
    definition: 'فاتورة يدفع فيها العميل المبلغ كاملًا فور الشراء.',
  ),
  GlossaryTerm(
    term: 'فاتورة بيع آجلة',
    definition: 'فاتورة يُسجل المبلغ كمديونية على العميل، يسددها لاحقًا.',
  ),
  GlossaryTerm(
    term: 'مرتجع بيع',
    definition: 'بضاعة أعادها العميل بعد البيع، تُنقص الإيرادات وتزيد المخزون.',
  ),
  GlossaryTerm(
    term: 'مرتجع شراء',
    definition: 'بضاعة أعدناها للمورد، تُنقص المخزون وتُنقص مديونيتنا له.',
  ),
  GlossaryTerm(
    term: 'حد الائتمان',
    definition: 'الحد الأقصى المسموح به لمديونية العميل قبل تجميد التعامل الآجل.',
  ),
  GlossaryTerm(
    term: 'كشف الحساب',
    definition: 'تقرير يُظهر جميع الحركات على حساب معيّن (عميل/مورد/بنك) خلال فترة، ورصيده الحالي.',
  ),
  GlossaryTerm(
    term: 'دفتر الأستاذ',
    definition: 'سجل تفصيلي لكل حساب يُظهر الحركات مرتبة وتحدّث الرصيد.',
  ),
  GlossaryTerm(
    term: 'ميزان المراجعة',
    definition: 'تقرير يُظهر كل الحسابات وأرصدتها للتأكد أن مجموع المدين = مجموع الدائن.',
  ),
  GlossaryTerm(
    term: 'قائمة الدخل',
    definition: 'تقرير يُظهر الإيرادات والمصروفات وصافي الربح أو الخسارة لفترة معيّنة.',
  ),
  GlossaryTerm(
    term: 'المركز المالي (الميزانية)',
    definition: 'تقرير يُظهر الأصول والالتزامات وحقوق الملكية في تاريخ معيّن. الأصول = الالتزامات + حقوق الملكية.',
  ),
  GlossaryTerm(
    term: 'الجرد',
    definition: 'عدّ المخزون فعليًا ومقارنته بما يُظهره النظام، وتسوية أي فروق.',
  ),
  GlossaryTerm(
    term: 'تكلفة البضاعة المباعة',
    definition: 'إجمالي تكلفة شراء البضائع التي بِيعت خلال الفترة.',
  ),
  GlossaryTerm(
    term: 'هامش الربح',
    definition: 'الفرق بين سعر البيع وسعر التكلفة، يمثّل ربح الصنف.',
  ),
  GlossaryTerm(
    term: 'فرق العملة',
    definition:
        'الفرق الذي ينشأ عند تغيّر سعر الصرف بين تاريخ نشأة الالتزام وتاريخ السداد، يُسجل كإيراد أو مصروف فروقات صرف.',
  ),
  GlossaryTerm(
    term: 'الترحيل',
    definition: 'اعتماد القيد ليُؤثر على أرصدة الحسابات. القيد غير المُرحَّل لا يظهر في التقارير.',
  ),
  GlossaryTerm(
    term: 'السنة المالية',
    definition: 'الفترة المحاسبية التي يتم خلالها إعداد التقارير، عادة 12 شهرًا.',
  ),
  GlossaryTerm(
    term: 'الفروع',
    definition: 'مكاتب أو نقاط بيع تابعة للشركة الأم في مدن مختلفة (صنعاء، عدن، تعز...).',
  ),
];

/// شارات الإنجاز
class Badge {
  final String id;
  final String name;
  final String description;
  final String emoji;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
  });
}

const List<Badge> appBadges = [
  Badge(
    id: 'badge_beginner',
    name: 'محاسب مبتدئ',
    description: 'أكملت إعداد بيانات الشركة لأول مرة',
    emoji: '🎓',
  ),
  Badge(
    id: 'badge_chart_master',
    name: 'أتقن شجرة الحسابات',
    description: 'صنّفت الحسابات الرئيسية بشكل صحيح',
    emoji: '🌳',
  ),
  Badge(
    id: 'badge_journal_pro',
    name: 'أتقن القيود اليومية',
    description: 'سجلت قيدًا متوازنًا بنجاح',
    emoji: '📒',
  ),
  Badge(
    id: 'badge_voucher_master',
    name: 'أتقن السندات',
    description: 'أصدرت سندًا بنجاح',
    emoji: '🧾',
  ),
  Badge(
    id: 'badge_sales_pro',
    name: 'أتقن المبيعات',
    description: 'أصدرت فاتورة بيع بنجاح',
    emoji: '🛒',
  ),
  Badge(
    id: 'badge_reports_master',
    name: 'أتقن التقارير',
    description: 'فهمت ميزان المراجعة وقائمة الدخل والمركز المالي',
    emoji: '📊',
  ),
  Badge(
    id: 'badge_complete',
    name: 'محاسب يمني محترف',
    description: 'أنهيت كل الدروس والتدريبات',
    emoji: '🏆',
  ),
];
