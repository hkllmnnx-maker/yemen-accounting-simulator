import '../models/financial_accounting/financial_exercise.dart';

/// تمارين قسم "المحاسبة المالية من القيد إلى التحليل المالي".
///
/// كل تمرين يحاكي عملية واقعية من بيئة يمنية ويحتوي:
/// - سيناريو واقعي.
/// - تاريخ العملية.
/// - وصف العملية.
/// - المطلوب.
/// - تلميحات وأخطاء شائعة.
/// - القيد الصحيح المتوقّع.
/// - شرح تفصيلي للحل.

final List<FinancialExercise> financialExercises = [
  // ====================================================================
  // المستوى 5 - قيود اليومية البسيطة
  // ====================================================================
  FinancialExercise(
    id: 'fa_ex_capital_cash',
    lessonId: 'fa_l5',
    title: 'تأسيس مؤسسة برأس مال نقدي',
    scenario:
        'الأخ "أحمد عبد الله" قرّر تأسيس مؤسسة تجارية باسم "النور التجارية" '
        'في مدينة صنعاء، وأحضر مبلغ 5,000,000 ريال يمني وأودعها في صندوق المؤسسة '
        'كرأس مال لبدء النشاط.',
    operationDate: _d(2024, 1, 1),
    operationText:
        'إيداع 5,000,000 ر.ي في صندوق المؤسسة من قبل صاحبها كرأس مال نقدي افتتاحي.',
    requirement:
        'اكتب قيد اليومية اللازم لتسجيل عملية التأسيس، مع توضيح طرفي القيد والبيان.',
    hints: [
      'الصندوق أصل، يزيد بالمدين.',
      'رأس المال حق ملكية، يزيد بالدائن.',
      'القيد بسيط: حساب واحد مدين وحساب واحد دائن.',
    ],
    commonMistakes: [
      'وضع رأس المال في الجانب المدين بسبب الاعتقاد أنه "ملك صاحب المنشأة".',
      'تسجيل القيد بالبنك بدلًا من الصندوق دون داعٍ.',
    ],
    solutionExplanation:
        'عند التأسيس النقدي يزيد الصندوق فيكون مدينًا، ويظهر التزام المنشأة تجاه صاحبها '
        'كرأس مال (حقوق ملكية) فيكون دائنًا. القيد متوازن لأن الجانبين بنفس المبلغ.',
    expected: FinExpectedEntry(
      date: _d(2024, 1, 1),
      description: 'تأسيس المنشأة برأس مال نقدي.',
      lines: [
        FinJournalLine(accountId: 'cash', side: 'debit', amount: 5000000),
        FinJournalLine(accountId: 'capital', side: 'credit', amount: 5000000),
      ],
    ),
    xpReward: 10,
  ),

  FinancialExercise(
    id: 'fa_ex_purchase_cash',
    lessonId: 'fa_l5',
    title: 'شراء بضاعة نقدًا',
    scenario:
        'بعد التأسيس بأيام، اتجه المحاسب إلى سوق الجملة لتزويد المحل بالبضاعة. '
        'اشترى من السوق المركزي في صنعاء بضائع متنوّعة بمبلغ إجمالي 1,200,000 ر.ي '
        'دفع المبلغ كاملًا نقدًا من صندوق المؤسسة.',
    operationDate: _d(2024, 1, 5),
    operationText: 'شراء بضاعة نقدًا بمبلغ 1,200,000 ر.ي من السوق المركزي.',
    requirement: 'سجّل قيد اليومية لعملية الشراء النقدي مع البيان المناسب.',
    hints: [
      'المشتريات أصل (يصبح مخزون لاحقًا)، يزيد بالمدين.',
      'الصندوق ينقص، فهو دائن.',
    ],
    commonMistakes: [
      'تسجيل المبلغ في حساب "المخزون" مباشرة دون استخدام حساب المشتريات.',
      'الخلط بين الشراء النقدي والشراء الآجل.',
    ],
    solutionExplanation:
        'عملية الشراء النقدي تزيد المشتريات (يصبح مدين) وتنقص الصندوق (يصبح دائن). '
        'في نظام الجرد الدوري نستخدم حساب "المشتريات" مباشرة.',
    expected: FinExpectedEntry(
      date: _d(2024, 1, 5),
      description: 'شراء بضاعة نقدًا.',
      lines: [
        FinJournalLine(accountId: 'purchases', side: 'debit', amount: 1200000),
        FinJournalLine(accountId: 'cash', side: 'credit', amount: 1200000),
      ],
    ),
    xpReward: 8,
  ),

  FinancialExercise(
    id: 'fa_ex_rent_payment',
    lessonId: 'fa_l5',
    title: 'دفع إيجار شهر المحل',
    scenario:
        'في بداية كل شهر يقوم صاحب المؤسسة بسداد إيجار المحل التجاري الذي '
        'يقع في شارع الستين بصنعاء. الإيجار الشهري المتفق عليه مع المالك هو '
        '150,000 ر.ي، يُدفع نقدًا.',
    operationDate: _d(2024, 1, 7),
    operationText: 'دفع إيجار شهر يناير للمحل بمبلغ 150,000 ر.ي نقدًا للمالك.',
    requirement: 'اكتب قيد اليومية المناسب لتسجيل دفع الإيجار.',
    hints: ['مصروف الإيجار يزيد، فهو مدين.', 'الصندوق ينقص، فهو دائن.'],
    commonMistakes: [
      'تسجيل الإيجار كأصل (إيجار مدفوع مقدمًا) رغم أنه عن الشهر الحالي.',
      'تسجيل المصروف في الجانب الدائن.',
    ],
    solutionExplanation:
        'إيجار شهر حالي = مصروف يخصّ الفترة، فيُسجَّل مدينًا في حساب مصروف الإيجار، '
        'ويُسجَّل الصندوق دائنًا لأن النقدية خرجت.',
    expected: FinExpectedEntry(
      date: _d(2024, 1, 7),
      description: 'دفع إيجار المحل لشهر يناير 2024.',
      lines: [
        FinJournalLine(
          accountId: 'rent_expense',
          side: 'debit',
          amount: 150000,
        ),
        FinJournalLine(accountId: 'cash', side: 'credit', amount: 150000),
      ],
    ),
  ),

  FinancialExercise(
    id: 'fa_ex_collect_customer',
    lessonId: 'fa_l5',
    title: 'تحصيل من عميل',
    scenario:
        'العميل "محلات البركة" في تعز كان عليه مديونية سابقة قدرها 400,000 ر.ي. '
        'في 12/1/2024 سدّد جزءًا من مديونيته نقدًا بمبلغ 300,000 ر.ي للمحاسب.',
    operationDate: _d(2024, 1, 12),
    operationText:
        'تحصيل 300,000 ر.ي نقدًا من العميل محلات البركة سداد جزء من مديونيته.',
    requirement: 'اكتب قيد اليومية اللازم لتسجيل عملية التحصيل من العميل.',
    hints: [
      'الصندوق يزيد (مدين).',
      'العملاء (أصل) ينقصون لأن المديونية قلّت (دائن).',
    ],
    commonMistakes: [
      'تسجيل الإيراد عند التحصيل، رغم أن الإيراد كان قد سُجّل سابقًا عند البيع الآجل.',
      'الخلط بين المدين والدائن في حساب العملاء.',
    ],
    solutionExplanation:
        'التحصيل من عميل ليس إيرادًا جديدًا؛ هو تحويل أصل (مديونية عميل) إلى أصل آخر (نقدية). '
        'فيُسجَّل الصندوق مدينًا والعملاء دائنًا.',
    expected: FinExpectedEntry(
      date: _d(2024, 1, 12),
      description: 'تحصيل جزئي من العميل محلات البركة.',
      lines: [
        FinJournalLine(accountId: 'cash', side: 'debit', amount: 300000),
        FinJournalLine(
          accountId: 'accounts_receivable',
          side: 'credit',
          amount: 300000,
        ),
      ],
    ),
  ),

  // ====================================================================
  // المستوى 6 - قيود اليومية المركبة
  // ====================================================================
  FinancialExercise(
    id: 'fa_ex_partial_purchase',
    lessonId: 'fa_l6',
    title: 'شراء بضاعة جزء نقدًا والباقي بالأجل',
    scenario:
        'تعاقد المحاسب مع "مؤسسة سبأ للتوريدات" في صنعاء على شراء بضائع بمبلغ '
        '1,000,000 ر.ي. تم دفع 400,000 ر.ي نقدًا والباقي 600,000 ر.ي قُيّد على '
        'حساب الموردين ليُسدَّد لاحقًا.',
    operationDate: _d(2024, 1, 9),
    operationText:
        'شراء بضاعة بمبلغ 1,000,000 ر.ي، دفع 400,000 نقدًا والباقي بالأجل.',
    requirement: 'اكتب قيد اليومية المركّب الذي يعكس هذه العملية.',
    hints: [
      'المشتريات تزيد بقيمة العملية كاملة (مدين).',
      'الصندوق ينقص بـ 400,000 (دائن).',
      'الموردون يزيدون بـ 600,000 (دائن).',
    ],
    commonMistakes: [
      'تسجيل المشتريات بمبلغ 400,000 فقط (المدفوع نقدًا).',
      'إغفال جانب الموردين.',
      'عدم توازن القيد بسبب أخطاء حسابية.',
    ],
    solutionExplanation:
        'القيد مركب: حساب واحد مدين (المشتريات) وحسابان دائنان (الصندوق + الموردون). '
        'إجمالي المدين = إجمالي الدائن = 1,000,000.',
    expected: FinExpectedEntry(
      date: _d(2024, 1, 9),
      description: 'شراء بضاعة من مؤسسة سبأ، نصفها نقدًا والباقي آجل.',
      lines: [
        FinJournalLine(accountId: 'purchases', side: 'debit', amount: 1000000),
        FinJournalLine(accountId: 'cash', side: 'credit', amount: 400000),
        FinJournalLine(
          accountId: 'accounts_payable',
          side: 'credit',
          amount: 600000,
        ),
      ],
    ),
    xpReward: 12,
  ),

  FinancialExercise(
    id: 'fa_ex_sale_with_discount',
    lessonId: 'fa_l6',
    title: 'بيع مع منح خصم نقدي',
    scenario:
        'باع المحاسب بضاعة لعميل "محلات الإيمان" بقيمة فاتورة 500,000 ر.ي، '
        'لكن نظرًا لسداده النقدي الفوري مُنح خصمًا قدره 25,000 ر.ي، '
        'فدفع العميل 475,000 ر.ي نقدًا.',
    operationDate: _d(2024, 1, 14),
    operationText:
        'بيع نقدي بقيمة 500,000 ر.ي مع منح خصم 25,000، تحصيل 475,000 ر.ي نقدًا.',
    requirement: 'اكتب قيد اليومية المركب الذي يعكس البيع مع الخصم المسموح به.',
    hints: [
      'الصندوق يزيد بـ 475,000 (مدين).',
      'الخصم المسموح به (مصروف) يزيد بـ 25,000 (مدين).',
      'إيرادات المبيعات تزيد بقيمة الفاتورة الكاملة 500,000 (دائن).',
    ],
    commonMistakes: [
      'تسجيل الإيرادات بـ 475,000 فقط (المُحصّل) دون الإفصاح عن الخصم.',
      'إدراج الخصم كإيراد بدل المصروف.',
    ],
    solutionExplanation:
        'الإيراد يجب أن يُسجَّل بكامل قيمة الفاتورة (500,000) ليعكس المبيعات الفعلية. '
        'الخصم المسموح به مصروف يخفّض صافي الربح. القيد متوازن: 475,000 + 25,000 = 500,000.',
    expected: FinExpectedEntry(
      date: _d(2024, 1, 14),
      description: 'بيع نقدي لمحلات الإيمان مع منح خصم.',
      lines: [
        FinJournalLine(accountId: 'cash', side: 'debit', amount: 475000),
        FinJournalLine(
          accountId: 'discount_allowed',
          side: 'debit',
          amount: 25000,
        ),
        FinJournalLine(accountId: 'sales', side: 'credit', amount: 500000),
      ],
    ),
    xpReward: 12,
  ),

  FinancialExercise(
    id: 'fa_ex_purchase_credit',
    lessonId: 'fa_l6',
    title: 'شراء بضاعة بالأجل',
    scenario:
        'تعاقد المحاسب مع "شركة الأمين" في الحديدة على شراء كمية إضافية من '
        'البضائع بقيمة 750,000 ر.ي، مع تأجيل السداد إلى نهاية الشهر دون أي دفعة مقدّمة.',
    operationDate: _d(2024, 1, 11),
    operationText: 'شراء بضاعة بالأجل من شركة الأمين بمبلغ 750,000 ر.ي.',
    requirement: 'اكتب قيد اليومية اللازم لتسجيل الشراء الآجل.',
    hints: [
      'لا يوجد تدفق نقدي في هذا القيد.',
      'المشتريات تزيد (مدين)، الموردون يزيدون (دائن).',
    ],
    commonMistakes: [
      'إدخال الصندوق في القيد رغم عدم وجود نقدية تدفع.',
      'تسجيل القيد بمبلغ مختلف على الجانبين.',
    ],
    solutionExplanation:
        'الشراء الآجل لا يُؤثّر على النقدية. تزيد المشتريات (أصل) وتزيد الموردون (التزام).',
    expected: FinExpectedEntry(
      date: _d(2024, 1, 11),
      description: 'شراء بضاعة بالأجل من شركة الأمين.',
      lines: [
        FinJournalLine(accountId: 'purchases', side: 'debit', amount: 750000),
        FinJournalLine(
          accountId: 'accounts_payable',
          side: 'credit',
          amount: 750000,
        ),
      ],
    ),
  ),

  FinancialExercise(
    id: 'fa_ex_sale_partial',
    lessonId: 'fa_l6',
    title: 'بيع بضاعة جزء نقدًا والباقي بالأجل',
    scenario:
        'باع المحاسب بضاعة للعميل "محلات النصر" بقيمة 900,000 ر.ي، '
        'دفع العميل 350,000 ر.ي نقدًا والباقي 550,000 ر.ي على ذمته.',
    operationDate: _d(2024, 1, 16),
    operationText:
        'بيع بضاعة بقيمة 900,000 ر.ي، تحصيل 350,000 نقدًا والباقي على العميل.',
    requirement: 'اكتب قيد اليومية المركب الذي يعكس هذه العملية.',
    hints: [
      'الصندوق يزيد بـ 350,000 (مدين).',
      'العملاء يزيدون بـ 550,000 (مدين).',
      'إيرادات المبيعات تزيد بـ 900,000 (دائن).',
    ],
    commonMistakes: [
      'تسجيل الإيراد بـ 350,000 فقط.',
      'الخلط بين العملاء والموردين.',
    ],
    solutionExplanation:
        'القيد مركب: مدينان (الصندوق + العملاء) ودائن واحد (إيرادات المبيعات). '
        'إجمالي المدين 900,000 = إجمالي الدائن 900,000.',
    expected: FinExpectedEntry(
      date: _d(2024, 1, 16),
      description: 'بيع بضاعة لمحلات النصر، نصفه نقدًا والباقي آجل.',
      lines: [
        FinJournalLine(accountId: 'cash', side: 'debit', amount: 350000),
        FinJournalLine(
          accountId: 'accounts_receivable',
          side: 'debit',
          amount: 550000,
        ),
        FinJournalLine(accountId: 'sales', side: 'credit', amount: 900000),
      ],
    ),
    xpReward: 12,
  ),

  // ====================================================================
  // تمارين إضافية تنتمي للمستويات الأساسية - لإثراء القسم
  // ====================================================================
  FinancialExercise(
    id: 'fa_ex_pay_supplier',
    lessonId: 'fa_l5',
    title: 'سداد لمورد',
    scenario:
        'استدعى صاحب "مؤسسة سبأ للتوريدات" المحاسب لسداد جزء من المديونية '
        'القائمة. تمّ سداد 400,000 ر.ي نقدًا.',
    operationDate: _d(2024, 1, 18),
    operationText: 'سداد 400,000 ر.ي نقدًا لمؤسسة سبأ على الحساب.',
    requirement: 'اكتب قيد اليومية لتسجيل السداد.',
    hints: [
      'الموردون (التزام) ينقص، فيكون مدينًا.',
      'الصندوق ينقص، فيكون دائنًا.',
    ],
    commonMistakes: [
      'تسجيل المصروف عند السداد، والصواب أنه إنقاص لالتزام.',
      'وضع الموردين دائنًا (هذا للزيادة فقط).',
    ],
    solutionExplanation:
        'السداد لمورد: ننقص الالتزام (الموردون مدين) وننقص الصندوق (دائن).',
    expected: FinExpectedEntry(
      date: _d(2024, 1, 18),
      description: 'سداد جزء من مديونية مؤسسة سبأ.',
      lines: [
        FinJournalLine(
          accountId: 'accounts_payable',
          side: 'debit',
          amount: 400000,
        ),
        FinJournalLine(accountId: 'cash', side: 'credit', amount: 400000),
      ],
    ),
  ),

  FinancialExercise(
    id: 'fa_ex_salaries',
    lessonId: 'fa_l5',
    title: 'دفع رواتب الموظفين',
    scenario:
        'في نهاية شهر يناير وزّع المحاسب رواتب موظفي المحل (3 موظفين) بإجمالي '
        '450,000 ر.ي نقدًا.',
    operationDate: _d(2024, 1, 30),
    operationText: 'صرف رواتب الموظفين لشهر يناير بإجمالي 450,000 ر.ي نقدًا.',
    requirement: 'اكتب قيد اليومية للرواتب المدفوعة.',
    hints: ['مصروف الرواتب مدين.', 'الصندوق دائن.'],
    commonMistakes: [
      'تسجيل الرواتب كالتزام رغم أنها دُفعت فعلًا.',
      'الخلط بين رواتب مستحقّة (لم تُدفع) ورواتب مدفوعة (هذا التمرين).',
    ],
    solutionExplanation:
        'بما أن الرواتب دُفعت نقدًا، فالعملية: مصروف رواتب مدين، صندوق دائن.',
    expected: FinExpectedEntry(
      date: _d(2024, 1, 30),
      description: 'صرف رواتب يناير 2024.',
      lines: [
        FinJournalLine(
          accountId: 'salaries_expense',
          side: 'debit',
          amount: 450000,
        ),
        FinJournalLine(accountId: 'cash', side: 'credit', amount: 450000),
      ],
    ),
  ),

  FinancialExercise(
    id: 'fa_ex_electricity',
    lessonId: 'fa_l5',
    title: 'دفع فاتورة كهرباء',
    scenario:
        'وصلت فاتورة الكهرباء للمحل عن شهر يناير بمبلغ 35,000 ر.ي، تمّ سدادها '
        'نقدًا في 28/1/2024.',
    operationDate: _d(2024, 1, 28),
    operationText: 'سداد فاتورة الكهرباء لشهر يناير 35,000 ر.ي نقدًا.',
    requirement: 'اكتب قيد اليومية لسداد الكهرباء.',
    hints: ['مصروف الكهرباء مدين.', 'الصندوق دائن.'],
    commonMistakes: ['استخدام حساب "مصروفات متنوعة" رغم وجود حساب مخصص.'],
    solutionExplanation:
        'الكهرباء مصروف تشغيلي يخصّ الفترة. مدين 35,000 / دائن 35,000.',
    expected: FinExpectedEntry(
      date: _d(2024, 1, 28),
      description: 'فاتورة كهرباء يناير 2024.',
      lines: [
        FinJournalLine(
          accountId: 'electricity_expense',
          side: 'debit',
          amount: 35000,
        ),
        FinJournalLine(accountId: 'cash', side: 'credit', amount: 35000),
      ],
    ),
  ),

  FinancialExercise(
    id: 'fa_ex_buy_equipment',
    lessonId: 'fa_l5',
    title: 'شراء أصل ثابت (أثاث)',
    scenario:
        'اشترى المحاسب أثاثًا للمكتب الإداري بمبلغ 800,000 ر.ي نقدًا من معرض '
        'الأثاث في صنعاء.',
    operationDate: _d(2024, 1, 6),
    operationText: 'شراء أثاث ومعدات للمكتب بمبلغ 800,000 ر.ي نقدًا.',
    requirement: 'اكتب قيد اليومية لتسجيل شراء الأصل الثابت.',
    hints: [
      'الأثاث أصل ثابت يزيد، فهو مدين.',
      'الصندوق ينقص (دائن).',
      'لا تُعالج الأصول الثابتة كمصروفات!',
    ],
    commonMistakes: [
      'تسجيل الأثاث كمصروف، وهذا خطأ شائع.',
      'استخدام حساب المشتريات بدل الأثاث (المشتريات للبضاعة المعدّة للبيع).',
    ],
    solutionExplanation:
        'الأثاث أصل ثابت يدوم لسنوات، فيُسجَّل في حسابه ويُهلك تدريجياً عبر مصروف الإهلاك. '
        'القيد: أثاث مدين، صندوق دائن.',
    expected: FinExpectedEntry(
      date: _d(2024, 1, 6),
      description: 'شراء أثاث للمكتب الإداري.',
      lines: [
        FinJournalLine(accountId: 'equipment', side: 'debit', amount: 800000),
        FinJournalLine(accountId: 'cash', side: 'credit', amount: 800000),
      ],
    ),
    xpReward: 10,
  ),

  // ====================================================================
  // المستوى 9 - تسويات جردية
  // ====================================================================
  FinancialExercise(
    id: 'fa_ex_depreciation',
    lessonId: 'fa_l9',
    title: 'إهلاك الأصول الثابتة',
    scenario:
        'في نهاية السنة، يجب إثبات إهلاك الأثاث المشترى بقيمة 800,000 ر.ي. '
        'تم اعتماد طريقة القسط الثابت بنسبة 10% سنويًا، أي أن الإهلاك السنوي '
        'يساوي 80,000 ر.ي.',
    operationDate: _d(2024, 12, 31),
    operationText:
        'تسجيل قسط الإهلاك السنوي للأثاث 80,000 ر.ي (10% من تكلفة 800,000).',
    requirement: 'اكتب قيد التسوية لإثبات إهلاك الأثاث.',
    hints: ['مصروف الإهلاك مدين.', 'مجمع الإهلاك (حساب مقابل للأصل) دائن.'],
    commonMistakes: [
      'إنقاص حساب الأثاث مباشرة بدل استخدام مجمع الإهلاك.',
      'تسجيل القيمة الكاملة للأثاث كمصروف (وهذا خطأ كبير).',
    ],
    solutionExplanation:
        'لا نخفّض حساب الأصل الأصلي، بل نُنشئ "مجمع إهلاك" يُخصم من تكلفة الأصل عند العرض. '
        'القيد: مصروف الإهلاك مدين 80,000 / مجمع إهلاك المعدات دائن 80,000.',
    expected: FinExpectedEntry(
      date: _d(2024, 12, 31),
      description: 'قسط إهلاك سنوي للأثاث.',
      lines: [
        FinJournalLine(
          accountId: 'depreciation_expense',
          side: 'debit',
          amount: 80000,
        ),
        FinJournalLine(
          accountId: 'accumulated_depreciation',
          side: 'credit',
          amount: 80000,
        ),
      ],
    ),
    xpReward: 12,
  ),

  FinancialExercise(
    id: 'fa_ex_accrued_salary',
    lessonId: 'fa_l9',
    title: 'تسوية رواتب مستحقة',
    scenario:
        'في 31/12/2024 لم تُدفع رواتب آخر شهر للموظفين بعد، وقدرها 200,000 ر.ي. '
        'يجب تسجيلها كمصروف للفترة وإثبات الالتزام.',
    operationDate: _d(2024, 12, 31),
    operationText:
        'إثبات رواتب مستحقّة للموظفين عن شهر ديسمبر 200,000 ر.ي لم تُدفع بعد.',
    requirement: 'اكتب قيد التسوية اللازم.',
    hints: [
      'مصروف الرواتب مدين (المصروف يخصّ الفترة).',
      'رواتب مستحقّة دائن (التزام جديد).',
      'لا تستخدم الصندوق لأن المبلغ لم يُدفع نقدًا.',
    ],
    commonMistakes: [
      'تسجيل الصندوق دائنًا رغم أن النقدية لم تخرج.',
      'إغفال القيد كاملًا، فتأتي قائمة الدخل بمصروفات أقل من الواقع.',
    ],
    solutionExplanation:
        'مبدأ الاستحقاق يُلزمنا بإثبات المصروف عند استحقاقه. '
        'مصروف الرواتب مدين، رواتب مستحقّة دائن. عند الدفع لاحقًا نقفل الالتزام.',
    expected: FinExpectedEntry(
      date: _d(2024, 12, 31),
      description: 'تسوية رواتب مستحقة لشهر ديسمبر.',
      lines: [
        FinJournalLine(
          accountId: 'salaries_expense',
          side: 'debit',
          amount: 200000,
        ),
        FinJournalLine(
          accountId: 'salaries_payable',
          side: 'credit',
          amount: 200000,
        ),
      ],
    ),
    xpReward: 10,
  ),

  // ====================================================================
  // تمارين إضافية متفرقة لإثراء القسم
  // ====================================================================
  FinancialExercise(
    id: 'fa_ex_sales_returns',
    lessonId: 'fa_l6',
    title: 'مردودات مبيعات',
    scenario:
        'أرجع العميل "محلات الإيمان" بضاعة بقيمة 50,000 ر.ي بسبب عيب في '
        'بعض القطع، وقد تم استرجاع المبلغ نقدًا.',
    operationDate: _d(2024, 1, 20),
    operationText:
        'استرجاع بضاعة بقيمة 50,000 ر.ي من العميل وإعادة المبلغ نقدًا.',
    requirement: 'اكتب قيد اليومية لتسجيل المردودات.',
    hints: ['مردودات المبيعات (تخفّض الإيراد) مدين.', 'الصندوق ينقص، دائن.'],
    commonMistakes: [
      'إنقاص حساب المبيعات مباشرة بدل استخدام حساب مردودات المبيعات.',
    ],
    solutionExplanation:
        'نستخدم حسابًا مستقلًا "مردودات المبيعات" لإظهار حجم المردودات في التقارير. '
        'القيد: مردودات مبيعات مدين / صندوق دائن.',
    expected: FinExpectedEntry(
      date: _d(2024, 1, 20),
      description: 'مردودات مبيعات من محلات الإيمان.',
      lines: [
        FinJournalLine(
          accountId: 'sales_returns',
          side: 'debit',
          amount: 50000,
        ),
        FinJournalLine(accountId: 'cash', side: 'credit', amount: 50000),
      ],
    ),
  ),

  FinancialExercise(
    id: 'fa_ex_discount_earned',
    lessonId: 'fa_l6',
    title: 'سداد لمورد مع خصم مكتسب',
    scenario:
        'بعد التفاوض مع "مؤسسة سبأ"، حصل المحاسب على خصم 30,000 ر.ي عند سداد '
        'مديونية قدرها 600,000 ر.ي. المبلغ المدفوع نقدًا 570,000 ر.ي.',
    operationDate: _d(2024, 1, 25),
    operationText:
        'سداد مديونية المورد 600,000 ر.ي مع الحصول على خصم نقدي 30,000 ر.ي.',
    requirement: 'اكتب قيد اليومية المركب.',
    hints: [
      'الموردون (التزام) ينقص بـ 600,000 (مدين).',
      'الصندوق ينقص بـ 570,000 (دائن).',
      'الخصم المكتسب (إيراد) يزيد بـ 30,000 (دائن).',
    ],
    commonMistakes: [
      'تسجيل الخصم المكتسب كمصروف بدل إيراد.',
      'تسجيل الموردين بـ 570,000 فقط.',
    ],
    solutionExplanation:
        'القيد مركب: مدين واحد (الموردون 600,000) ودائنان (الصندوق 570,000 + الخصم المكتسب 30,000). '
        'القيد متوازن.',
    expected: FinExpectedEntry(
      date: _d(2024, 1, 25),
      description: 'سداد مديونية مؤسسة سبأ مع الحصول على خصم.',
      lines: [
        FinJournalLine(
          accountId: 'accounts_payable',
          side: 'debit',
          amount: 600000,
        ),
        FinJournalLine(accountId: 'cash', side: 'credit', amount: 570000),
        FinJournalLine(
          accountId: 'discount_earned',
          side: 'credit',
          amount: 30000,
        ),
      ],
    ),
    xpReward: 12,
  ),

  FinancialExercise(
    id: 'fa_ex_sale_cash',
    lessonId: 'fa_l5',
    title: 'بيع بضاعة نقدًا',
    scenario:
        'باع المحاسب بضاعة في المحل لزبون عابر بمبلغ 250,000 ر.ي، تمّ التحصيل '
        'فورًا في الصندوق.',
    operationDate: _d(2024, 1, 15),
    operationText: 'بيع نقدي لزبون بمبلغ 250,000 ر.ي.',
    requirement: 'اكتب قيد اليومية لتسجيل البيع النقدي.',
    hints: ['الصندوق يزيد، مدين.', 'إيرادات المبيعات تزيد، دائن.'],
    commonMistakes: [
      'وضع المبيعات في الجانب المدين.',
      'إدراج العملاء رغم أن العملية نقدية.',
    ],
    solutionExplanation:
        'البيع النقدي: الصندوق مدين، إيرادات المبيعات دائن. هذا أبسط أنواع البيع.',
    expected: FinExpectedEntry(
      date: _d(2024, 1, 15),
      description: 'مبيعات نقدية للزبائن.',
      lines: [
        FinJournalLine(accountId: 'cash', side: 'debit', amount: 250000),
        FinJournalLine(accountId: 'sales', side: 'credit', amount: 250000),
      ],
    ),
  ),
];

DateTime _d(int y, int m, int d) => DateTime(y, m, d);

/// مساعِد للحصول على التمارين الخاصة بمستوى معيّن.
List<FinancialExercise> exercisesForLesson(String lessonId) {
  return financialExercises.where((e) => e.lessonId == lessonId).toList();
}

/// مساعد للحصول على تمرين بمعرّفه.
FinancialExercise? findExerciseById(String id) {
  for (final e in financialExercises) {
    if (e.id == id) return e;
  }
  return null;
}
