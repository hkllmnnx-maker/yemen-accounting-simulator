/// سيناريوهات التدريب العملي

class TrainingStep {
  final String instruction;
  final String hint;
  // قواعد التحقق:
  // type: 'text', 'number', 'choice'
  final String type;
  final String fieldKey; // مفتاح الحقل
  final String? expectedValue; // القيمة المتوقعة (للتحقق)
  final List<String>? choices; // للاختيارات
  final double? expectedNumber;
  final double? tolerance;

  const TrainingStep({
    required this.instruction,
    required this.hint,
    required this.type,
    required this.fieldKey,
    this.expectedValue,
    this.choices,
    this.expectedNumber,
    this.tolerance,
  });
}

class TrainingScenario {
  final String id;
  final String title;
  final String description;
  final String yemeniContext;
  final List<TrainingStep> steps;
  final String successMessage;
  final String? badgeId;
  final int xpReward;

  const TrainingScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.yemeniContext,
    required this.steps,
    required this.successMessage,
    this.badgeId,
    this.xpReward = 10,
  });
}

const List<TrainingScenario> appTrainings = [
  // ========================================
  TrainingScenario(
    id: 'training_company_setup',
    title: 'إنشاء شركة جديدة',
    description: 'تدرّب على إعداد بيانات الشركة ابتداءً، تمامًا كما يحدث في أي نظام محاسبي يمني.',
    yemeniContext:
        'أنت محاسب في "مؤسسة النور التجارية" في صنعاء، طُلب منك إعداد النظام المحاسبي لأول مرة.',
    steps: [
      TrainingStep(
        instruction: 'أدخل اسم الشركة',
        hint: 'الإجابة المطلوبة: مؤسسة النور التجارية',
        type: 'text',
        fieldKey: 'companyName',
        expectedValue: 'مؤسسة النور التجارية',
      ),
      TrainingStep(
        instruction: 'اختر مدينة الشركة',
        hint: 'الإجابة المطلوبة: صنعاء',
        type: 'choice',
        fieldKey: 'city',
        expectedValue: 'صنعاء',
        choices: ['صنعاء', 'عدن', 'تعز', 'إب', 'الحديدة'],
      ),
      TrainingStep(
        instruction: 'اختر العملة الأساسية للشركة',
        hint: 'الإجابة المطلوبة: ريال يمني (YER)',
        type: 'choice',
        fieldKey: 'currency',
        expectedValue: 'YER',
        choices: ['YER', 'USD', 'SAR'],
      ),
      TrainingStep(
        instruction: 'أدخل السنة المالية',
        hint: 'الإجابة المطلوبة: 2024',
        type: 'number',
        fieldKey: 'fiscalYear',
        expectedNumber: 2024,
        tolerance: 0,
      ),
    ],
    successMessage:
        'أحسنت! لقد أعددت بيانات الشركة بنجاح. هذه أول خطوة في أي نظام محاسبي يمني.',
    badgeId: 'badge_beginner',
    xpReward: 15,
  ),

  // ========================================
  TrainingScenario(
    id: 'training_chart_of_accounts',
    title: 'استكشاف شجرة الحسابات',
    description: 'تعرّف على شجرة الحسابات اليمنية الافتراضية وتأكد من معرفتك بتصنيفات الحسابات.',
    yemeniContext:
        'محاسب مؤسسة النور يحتاج معرفة تصنيف كل حساب رئيسي.',
    steps: [
      TrainingStep(
        instruction: 'إلى أي مجموعة ينتمي حساب "الصندوق الرئيسي"؟',
        hint: 'النقدية تكون من الأصول',
        type: 'choice',
        fieldKey: 'cashGroup',
        expectedValue: 'الأصول',
        choices: ['الأصول', 'الالتزامات', 'الإيرادات', 'المصروفات'],
      ),
      TrainingStep(
        instruction: 'إلى أي مجموعة ينتمي حساب "العملاء"؟',
        hint: 'العملاء يدينون لنا، فهم أصل من أصول الشركة',
        type: 'choice',
        fieldKey: 'customersGroup',
        expectedValue: 'الأصول',
        choices: ['الأصول', 'الالتزامات', 'الإيرادات', 'المصروفات'],
      ),
      TrainingStep(
        instruction: 'إلى أي مجموعة ينتمي حساب "الموردون"؟',
        hint: 'نحن مدينون للموردين بقيمة المشتريات الآجلة',
        type: 'choice',
        fieldKey: 'suppliersGroup',
        expectedValue: 'الالتزامات',
        choices: ['الأصول', 'الالتزامات', 'الإيرادات', 'المصروفات'],
      ),
      TrainingStep(
        instruction: 'إلى أي مجموعة ينتمي حساب "إيرادات المبيعات"؟',
        hint: 'الواضح من اسمه',
        type: 'choice',
        fieldKey: 'salesGroup',
        expectedValue: 'الإيرادات',
        choices: ['الأصول', 'الالتزامات', 'الإيرادات', 'المصروفات'],
      ),
      TrainingStep(
        instruction: 'إلى أي مجموعة ينتمي حساب "مصروف الإيجار"؟',
        hint: 'كل ما تنفقه الشركة دوريًا...',
        type: 'choice',
        fieldKey: 'rentGroup',
        expectedValue: 'المصروفات',
        choices: ['الأصول', 'الالتزامات', 'الإيرادات', 'المصروفات'],
      ),
    ],
    successMessage:
        'ممتاز! أنت تعرف تصنيف الحسابات الرئيسية. هذه أساس فهم أي نظام محاسبي.',
    badgeId: 'badge_chart_master',
    xpReward: 20,
  ),

  // ========================================
  TrainingScenario(
    id: 'training_journal_entry',
    title: 'تسجيل قيد يومي',
    description:
        'تدرّب على تسجيل قيد إثبات مصروف كهرباء في النظام المحاسبي.',
    yemeniContext:
        'في نهاية الشهر، استلمت مؤسسة النور فاتورة كهرباء بمبلغ 30,000 ر.ي ودُفعت من الصندوق.',
    steps: [
      TrainingStep(
        instruction: 'ما الحساب الذي يُسجّل مدينًا؟',
        hint: 'المصروف يُسجل دائمًا مدينًا عند إثباته',
        type: 'choice',
        fieldKey: 'debitAccount',
        expectedValue: 'مصروف الكهرباء',
        choices: ['الصندوق الرئيسي', 'مصروف الكهرباء', 'الإيرادات', 'العملاء'],
      ),
      TrainingStep(
        instruction: 'ما الحساب الذي يُسجّل دائنًا؟',
        hint: 'المبلغ خرج من الصندوق نقدًا',
        type: 'choice',
        fieldKey: 'creditAccount',
        expectedValue: 'الصندوق الرئيسي',
        choices: ['الصندوق الرئيسي', 'مصروف الكهرباء', 'الإيرادات', 'العملاء'],
      ),
      TrainingStep(
        instruction: 'أدخل قيمة القيد بالريال اليمني',
        hint: 'القيمة 30,000',
        type: 'number',
        fieldKey: 'amount',
        expectedNumber: 30000,
        tolerance: 0.5,
      ),
    ],
    successMessage:
        'صحيح! القيد: من ح/ مصروف الكهرباء 30,000 إلى ح/ الصندوق الرئيسي 30,000.',
    badgeId: 'badge_journal_pro',
    xpReward: 25,
  ),

  // ========================================
  TrainingScenario(
    id: 'training_receipt_voucher',
    title: 'سند قبض من عميل',
    description: 'تدرّب على إصدار سند قبض من عميل آجل.',
    yemeniContext:
        'العميل "محلات البركة - تعز" سدّد 50,000 ر.ي من مديونيته. صدر سند قبض.',
    steps: [
      TrainingStep(
        instruction: 'ماذا يحدث لرصيد الصندوق بعد سند القبض؟',
        hint: 'سند القبض = استلام نقد من العميل',
        type: 'choice',
        fieldKey: 'cashEffect',
        expectedValue: 'يزيد',
        choices: ['يزيد', 'ينقص', 'لا يتغير'],
      ),
      TrainingStep(
        instruction: 'ماذا يحدث لمديونية العميل بعد سند القبض؟',
        hint: 'العميل دفع جزءًا من ديْنه',
        type: 'choice',
        fieldKey: 'customerEffect',
        expectedValue: 'تنقص',
        choices: ['تزيد', 'تنقص', 'لا تتغير'],
      ),
      TrainingStep(
        instruction: 'أدخل المبلغ المُحصَّل',
        hint: 'المبلغ 50,000',
        type: 'number',
        fieldKey: 'amount',
        expectedNumber: 50000,
        tolerance: 0.5,
      ),
    ],
    successMessage:
        'ممتاز! القيد: من ح/ الصندوق 50,000 إلى ح/ محلات البركة (عميل) 50,000. مديونية العميل نقصت 50,000.',
    badgeId: 'badge_voucher_master',
    xpReward: 20,
  ),

  // ========================================
  TrainingScenario(
    id: 'training_payment_voucher',
    title: 'سند صرف لمورد',
    description: 'تدرّب على إصدار سند صرف لسداد مديونية مورد.',
    yemeniContext:
        'مؤسسة النور سدّدت 80,000 ر.ي لـ "مؤسسة سبأ للتوريدات".',
    steps: [
      TrainingStep(
        instruction: 'ماذا يحدث لرصيد الصندوق بعد سند الصرف؟',
        hint: 'سند الصرف = دفع نقد للمورد',
        type: 'choice',
        fieldKey: 'cashEffect',
        expectedValue: 'ينقص',
        choices: ['يزيد', 'ينقص', 'لا يتغير'],
      ),
      TrainingStep(
        instruction: 'ماذا يحدث لمديونيتنا تجاه المورد؟',
        hint: 'دفعنا له جزءًا من ديوننا',
        type: 'choice',
        fieldKey: 'supplierEffect',
        expectedValue: 'تنقص',
        choices: ['تزيد', 'تنقص', 'لا تتغير'],
      ),
      TrainingStep(
        instruction: 'أدخل المبلغ المدفوع',
        hint: 'المبلغ 80,000',
        type: 'number',
        fieldKey: 'amount',
        expectedNumber: 80000,
        tolerance: 0.5,
      ),
    ],
    successMessage:
        'القيد: من ح/ مؤسسة سبأ (مورد) 80,000 إلى ح/ الصندوق 80,000.',
    xpReward: 20,
  ),

  // ========================================
  TrainingScenario(
    id: 'training_add_customer',
    title: 'إضافة عميل يمني',
    description: 'تدرّب على إضافة عميل جديد ببيانات يمنية حقيقية.',
    yemeniContext: 'مؤسسة النور تتعامل مع عميل جديد في تعز.',
    steps: [
      TrainingStep(
        instruction: 'أدخل اسم العميل',
        hint: 'الإجابة: محلات البركة',
        type: 'text',
        fieldKey: 'customerName',
        expectedValue: 'محلات البركة',
      ),
      TrainingStep(
        instruction: 'اختر مدينة العميل',
        hint: 'الإجابة: تعز',
        type: 'choice',
        fieldKey: 'city',
        expectedValue: 'تعز',
        choices: ['صنعاء', 'عدن', 'تعز', 'إب', 'الحديدة'],
      ),
      TrainingStep(
        instruction: 'هل تعامل العميل آجل أم نقدي؟',
        hint: 'الإجابة: آجل',
        type: 'choice',
        fieldKey: 'kind',
        expectedValue: 'آجل',
        choices: ['آجل', 'نقدي'],
      ),
      TrainingStep(
        instruction: 'أدخل حد الائتمان للعميل (ر.ي)',
        hint: 'مثلاً 500,000',
        type: 'number',
        fieldKey: 'creditLimit',
        expectedNumber: 500000,
        tolerance: 1,
      ),
    ],
    successMessage:
        'تمت إضافة العميل بنجاح. يمكنك الآن إصدار فواتير له ومتابعة كشف حسابه.',
    xpReward: 15,
  ),

  // ========================================
  TrainingScenario(
    id: 'training_sale_invoice',
    title: 'تسجيل فاتورة بيع',
    description: 'تدرّب على إصدار فاتورة بيع نقدية لعميل.',
    yemeniContext:
        'مؤسسة النور باعت 5 كراتين من السكر لمحلات البركة. سعر الكرتون 13,500 ر.ي.',
    steps: [
      TrainingStep(
        instruction: 'كم كرتون تم بيعه؟',
        hint: 'الإجابة: 5',
        type: 'number',
        fieldKey: 'qty',
        expectedNumber: 5,
        tolerance: 0,
      ),
      TrainingStep(
        instruction: 'ما سعر الكرتون الواحد؟',
        hint: 'الإجابة: 13,500',
        type: 'number',
        fieldKey: 'unitPrice',
        expectedNumber: 13500,
        tolerance: 1,
      ),
      TrainingStep(
        instruction: 'احسب إجمالي الفاتورة (الكمية × السعر)',
        hint: '5 × 13,500',
        type: 'number',
        fieldKey: 'total',
        expectedNumber: 67500,
        tolerance: 1,
      ),
      TrainingStep(
        instruction: 'في فاتورة البيع النقدية، الصندوق يكون:',
        hint: 'الصندوق يستلم النقد',
        type: 'choice',
        fieldKey: 'cashSide',
        expectedValue: 'مدينًا',
        choices: ['مدينًا', 'دائنًا'],
      ),
    ],
    successMessage:
        'ممتاز! إجمالي الفاتورة 67,500 ر.ي. القيد: الصندوق مدين، إيرادات المبيعات دائن.',
    badgeId: 'badge_sales_pro',
    xpReward: 25,
  ),

  // ========================================
  TrainingScenario(
    id: 'training_purchase_invoice',
    title: 'تسجيل فاتورة شراء',
    description: 'تدرّب على إصدار فاتورة شراء آجلة من مورد.',
    yemeniContext:
        'مؤسسة النور اشترت 20 كرتون أرز من مؤسسة سبأ بسعر 8,500 ر.ي للكرتون آجلًا.',
    steps: [
      TrainingStep(
        instruction: 'احسب إجمالي الفاتورة',
        hint: '20 × 8,500',
        type: 'number',
        fieldKey: 'total',
        expectedNumber: 170000,
        tolerance: 1,
      ),
      TrainingStep(
        instruction: 'ما الحساب الذي يصبح مدينًا (يستلم البضاعة)؟',
        hint: 'البضاعة تدخل المخزون',
        type: 'choice',
        fieldKey: 'debit',
        expectedValue: 'المخزون',
        choices: ['المخزون', 'الموردون', 'الصندوق', 'العملاء'],
      ),
      TrainingStep(
        instruction: 'ما الحساب الذي يصبح دائنًا (لم ندفع نقدًا، فهو علينا)؟',
        hint: 'الشراء آجل = دين على الشركة لصالح المورد',
        type: 'choice',
        fieldKey: 'credit',
        expectedValue: 'الموردون',
        choices: ['المخزون', 'الموردون', 'الصندوق', 'العملاء'],
      ),
    ],
    successMessage:
        'القيد: من ح/ المخزون 170,000 إلى ح/ الموردون 170,000. مديونية المورد علينا زادت.',
    xpReward: 25,
  ),

  // ========================================
  TrainingScenario(
    id: 'training_expenses',
    title: 'تسجيل المصروفات التشغيلية',
    description: 'تدرب على تسجيل مصروفات الإيجار والكهرباء والرواتب.',
    yemeniContext: 'مصروفات شهر مارس لمؤسسة النور',
    steps: [
      TrainingStep(
        instruction: 'إيجار المحل 50,000 ر.ي. ما الحساب المدين؟',
        hint: 'مصروف الإيجار',
        type: 'choice',
        fieldKey: 'rentDr',
        expectedValue: 'مصروف الإيجار',
        choices: ['مصروف الإيجار', 'الصندوق', 'العملاء', 'الموردون'],
      ),
      TrainingStep(
        instruction: 'فاتورة كهرباء 25,000 ر.ي. ما الحساب الدائن؟',
        hint: 'الصندوق هو من دفع',
        type: 'choice',
        fieldKey: 'elecCr',
        expectedValue: 'الصندوق الرئيسي',
        choices: ['مصروف الكهرباء', 'الصندوق الرئيسي', 'العملاء', 'الموردون'],
      ),
      TrainingStep(
        instruction: 'راتب موظف 100,000 ر.ي. أدخل قيمة المصروف.',
        hint: 'الإجابة: 100,000',
        type: 'number',
        fieldKey: 'salary',
        expectedNumber: 100000,
        tolerance: 1,
      ),
    ],
    successMessage:
        'كل المصروفات تُسجل: المصروف مدين، الصندوق دائن (إذا دُفعت نقدًا).',
    xpReward: 20,
  ),

  // ========================================
  TrainingScenario(
    id: 'training_inventory',
    title: 'استعراض المخزون',
    description: 'تدرّب على فهم بيانات الأصناف ومتابعة المخزون.',
    yemeniContext:
        'كمحاسب، عليك معرفة كيفية حساب قيمة المخزون وهامش الربح.',
    steps: [
      TrainingStep(
        instruction:
            'صنف "سكر أبيض" تكلفته 12,000 وسعر بيعه 13,500. ما هامش الربح للكرتون؟',
        hint: 'سعر البيع - التكلفة',
        type: 'number',
        fieldKey: 'margin',
        expectedNumber: 1500,
        tolerance: 1,
      ),
      TrainingStep(
        instruction: 'إذا كان لديك 50 كرتون سكر، ما قيمة المخزون بالتكلفة؟',
        hint: '50 × 12,000',
        type: 'number',
        fieldKey: 'invValue',
        expectedNumber: 600000,
        tolerance: 1,
      ),
    ],
    successMessage:
        'ممتاز! تعرف الآن كيف تحسب قيمة المخزون وهامش الربح.',
    xpReward: 15,
  ),

  // ========================================
  TrainingScenario(
    id: 'training_currency',
    title: 'فروقات العملة',
    description: 'تدرّب على فهم تأثير تغيّر سعر صرف الدولار.',
    yemeniContext:
        'مؤسسة النور اشترت من مورد خارجي بـ 1,000 دولار وسعر الصرف 530 ر.ي.',
    steps: [
      TrainingStep(
        instruction: 'احسب قيمة الفاتورة بالريال اليمني',
        hint: '1,000 × 530',
        type: 'number',
        fieldKey: 'invYer',
        expectedNumber: 530000,
        tolerance: 10,
      ),
      TrainingStep(
        instruction:
            'عند السداد أصبح سعر الصرف 540. كم يصبح المبلغ بالريال اليمني؟',
        hint: '1,000 × 540',
        type: 'number',
        fieldKey: 'payYer',
        expectedNumber: 540000,
        tolerance: 10,
      ),
      TrainingStep(
        instruction: 'ما قيمة فرق العملة (الخسارة)؟',
        hint: '540,000 - 530,000',
        type: 'number',
        fieldKey: 'diff',
        expectedNumber: 10000,
        tolerance: 1,
      ),
    ],
    successMessage:
        'فرق العملة 10,000 ر.ي يُسجل كمصروف فروقات صرف.',
    xpReward: 30,
  ),

  // ========================================
  TrainingScenario(
    id: 'training_reports',
    title: 'استخراج التقارير المالية',
    description: 'تدرّب على فهم التقارير الأساسية في النظام.',
    yemeniContext: 'مدير مؤسسة النور طلب منك ميزان المراجعة وقائمة الدخل.',
    steps: [
      TrainingStep(
        instruction: 'في ميزان المراجعة، يجب أن:',
        hint: 'مدين = دائن',
        type: 'choice',
        fieldKey: 'tbCheck',
        expectedValue: 'مجموع المدين = مجموع الدائن',
        choices: [
          'مجموع المدين أكبر',
          'مجموع الدائن أكبر',
          'مجموع المدين = مجموع الدائن',
        ],
      ),
      TrainingStep(
        instruction:
            'إيرادات الشركة 2,500,000 ومصروفاتها 1,800,000. ما صافي الربح؟',
        hint: 'الإيرادات - المصروفات',
        type: 'number',
        fieldKey: 'profit',
        expectedNumber: 700000,
        tolerance: 1,
      ),
      TrainingStep(
        instruction:
            'في المركز المالي: الأصول = الالتزامات + ?',
        hint: 'العنصر المتبقي في معادلة الميزانية',
        type: 'choice',
        fieldKey: 'eqEq',
        expectedValue: 'حقوق الملكية',
        choices: ['الإيرادات', 'المصروفات', 'حقوق الملكية', 'المخزون'],
      ),
    ],
    successMessage:
        'ممتاز! أنت الآن تفهم التقارير الثلاثة الأساسية: ميزان المراجعة، قائمة الدخل، المركز المالي.',
    badgeId: 'badge_reports_master',
    xpReward: 35,
  ),
];
