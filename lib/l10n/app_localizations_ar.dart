// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ولي الأمر';

  @override
  String get home => 'الرئيسية';

  @override
  String get myChildren => 'أبنائي';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get assignments => 'الواجبات';

  @override
  String get attendance => 'الحضور';

  @override
  String get grades => 'الدرجات';

  @override
  String get fees => 'الرسوم الدراسية';

  @override
  String get settings => 'الإعدادات';

  @override
  String get selectChild => 'اختر الابن';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'طاب مساؤك';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String welcomeParent(String name) {
    return 'مرحباً بك، $name';
  }

  @override
  String get parentAccount => 'حساب ولي الأمر';

  @override
  String get quickAccess => 'الوصول السريع';

  @override
  String get absenceRequest => 'طلب غياب';

  @override
  String get gradesAndAnalytics => 'الدرجات والتحليلات';

  @override
  String get schoolAssignments => 'الواجبات المدرسية';

  @override
  String get attendanceRecord => 'سجل الحضور';

  @override
  String get exams => 'الاختبارات';

  @override
  String get account => 'الحساب';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get editProfile => 'تعديل بيانات الحساب';

  @override
  String get app => 'التطبيق';

  @override
  String get appearance => 'المظهر';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get activitiesAndMessages => 'الأنشطة والرسائل';

  @override
  String get support => 'الدعم';

  @override
  String get helpCenter => 'مركز المساعدة';

  @override
  String get contactUs => 'تواصل معنا';

  @override
  String get aboutApp => 'عن التطبيق';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmation => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get ok => 'حسناً';

  @override
  String get generalNotification => 'إشعار عام';

  @override
  String get publicHolidayTomorrow => 'غداً إجازة رسمية.';

  @override
  String get oneHourAgo => 'منذ 1 ساعة';

  @override
  String get privateMessageFromAdmin => 'رسالة خاصة من الإدارة';

  @override
  String get reviewWithAdmin => 'نرجو مراجعة الإدارة بشأن مستوى الطالب.';

  @override
  String get yesterday => 'أمس';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get welcomeBack => 'مرحباً بك مجدداً في تطبيق رياض ومدارس أنوار العلى';

  @override
  String get phoneNumberOrUsername => 'رقم الهاتف / اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get forgotPasswordComingSoon =>
      'سيتم تفعيل ميزة استعادة كلمة المرور قريباً.';

  @override
  String versionLabel(String version) {
    return 'الإصدار $version';
  }

  @override
  String get pleaseSelectStudent => 'الرجاء اختيار الطالب';

  @override
  String get noAssignmentsForToday => 'لا توجد واجبات لهذا اليوم';

  @override
  String get totalFees => 'إجمالي الرسوم';

  @override
  String get paid => 'تم الدفع';

  @override
  String get remaining => 'المتبقي';

  @override
  String get paymentHistory => 'سجل المدفوعات';

  @override
  String get financialPayment => 'دفعة مالية';

  @override
  String get pleaseSelectChildToViewExams =>
      'الرجاء اختيار ابن لعرض جداول الاختبارات الخاصة به';

  @override
  String get firstSemester => 'الفصل الدراسي الأول';

  @override
  String get secondSemester => 'الفصل الدراسي الثاني';

  @override
  String noScheduleAddedFor(String period) {
    return 'لا يوجد جدول مضاف لـ $period';
  }

  @override
  String get noGradesYet => 'لا توجد درجات حتى الآن';

  @override
  String get finalResultNote => 'المحصلة النهائية (مجموع الأشهر ÷ 15)';

  @override
  String get children => 'الابناء';

  @override
  String get attendanceBehavior => 'مواظبة';

  @override
  String get oral => 'شفوي';

  @override
  String get homework => 'واجبات';

  @override
  String get written => 'تحريري';

  @override
  String get midTermFinalExam => 'الاختبار النصفي / النهائي';

  @override
  String get totalTermGrades => 'مجموع درجات الترم';

  @override
  String get totalYearlyGrades => 'المجموع الكلي للمادة (سنة)';

  @override
  String get absenceRequestSentSuccessfully => 'تم إرسال طلب الغياب بنجاح';

  @override
  String get errorSendingAbsenceRequest => 'حدث خطأ أثناء الإرسال';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get reasonOptional => 'السبب (اختياري)';

  @override
  String get noRegisteredStudents => 'لا يوجد طلاب مسجلين';

  @override
  String get exampleMedicalAppointment => 'مثال: موعد طبي...';

  @override
  String get sendAbsenceRequest => 'إرسال طلب الغياب';

  @override
  String get attendanceDays => 'أيام الحضور';

  @override
  String get absenceDays => 'أيام الغياب';

  @override
  String get pleaseSelectStudentToViewAttendance =>
      'الرجاء اختيار الطالب لعرض سجل الحضور';

  @override
  String get saturday => 'السبت';

  @override
  String get sunday => 'الأحد';

  @override
  String get monday => 'الاثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String currencySar(String amount) {
    return '$amount ر.ي';
  }

  @override
  String get math => 'الرياضيات';

  @override
  String get science => 'العلوم';

  @override
  String get arabicLanguage => 'اللغة العربية';

  @override
  String get englishLanguage => 'اللغة الإنجليزية';

  @override
  String get quran => 'القرآن الكريم';

  @override
  String get socialStudies => 'الاجتماعيات';

  @override
  String get history => 'التاريخ';

  @override
  String get physics => 'الفيزياء';

  @override
  String get month1 => 'الشهر الأول';

  @override
  String get month2 => 'الشهر الثاني';

  @override
  String get month3 => 'الشهر الثالث';

  @override
  String get month4 => 'الشهر الرابع';

  @override
  String get month5 => 'الشهر الخامس';

  @override
  String get month6 => 'الشهر السادس';

  @override
  String get finalExam => 'اختبار نهاية الترم';

  @override
  String get assignmentMath => 'حل التمارين صفحة 45 من كتاب الطالب.';

  @override
  String get assignmentScience => 'مراجعة الفصل الثالث استعداداً للاختبار.';

  @override
  String get assignmentArabic => 'كتابة موضوع تعبير عن أهمية القراءة.';

  @override
  String get assignmentHistory => 'تلخيص الدرس الثاني.';

  @override
  String get assignmentPhysics => 'حل مسائل الحركة بتسارع ثابت.';

  @override
  String get assignmentQuran => 'حفظ سورة النبأ.';

  @override
  String get assignmentMath2 => 'جدول الضرب من 1 إلى 5.';

  @override
  String get examQuran1 => 'تسميع سورة البقرة من آية 1 إلى 50';

  @override
  String get examQuran2 => 'تسميع سورة البقرة من 50 إلى 100';

  @override
  String get examMath1 => 'الباب الأول فقط';

  @override
  String get examMath2 => 'شامل';

  @override
  String get examArabic => 'النصوص والقواعد النحوية';

  @override
  String get examScience => 'الوحدة الثانية';

  @override
  String get examSocial => 'الجغرافيا والتاريخ';

  @override
  String get examEnglish => 'شامل كامل الكتاب';

  @override
  String get childName1 => 'أحمد محمد عبدالله';

  @override
  String get childGrade1 => 'الصف الخامس - شعبة (أ)';

  @override
  String get childName2 => 'سارة محمد عبدالله';

  @override
  String get childGrade2 => 'الصف الثالث - شعبة (ب)';

  @override
  String get childName3 => 'عمر محمد عبدالله';

  @override
  String get childGrade3 => 'الصف الأول - شعبة (ج)';

  @override
  String get teacherAccount => 'حساب المعلم';

  @override
  String get teacherName => 'أستاذ أحمد محمد';

  @override
  String get classGrade5A => 'الصف الخامس - أ';

  @override
  String get classGrade6B => 'الصف السادس - ب';

  @override
  String get subjectLughati => 'لغتي';

  @override
  String get myClasses => 'فصولي';

  @override
  String get messages => 'الرسائل';

  @override
  String get comingSoon => 'قريباً...';

  @override
  String get emergencyMeetingTitle => 'طلب اجتماع طارئ';

  @override
  String get emergencyMeetingMessage =>
      'اجتماع طارئ لأعضاء هيئة التدريس في المكتبة المدرسية الساعة 12 ظهراً لمناقشة سير الاختبارات.';

  @override
  String get todayAt10am => 'اليوم، 10:00 ص';

  @override
  String get gradesAlertTitle => 'تنبيه رصد الدرجات';

  @override
  String get gradesAlertMessage =>
      'يرجى استكمال رصد درجات الشهر الأول لجميع الطلاب قبل نهاية هذا الأسبوع.';

  @override
  String get selectHint => 'اختر';

  @override
  String get appNameTeacherPortal => 'رياض ومدارس أنوار العلى - بوابة المعلم';

  @override
  String get loginSubtitle => 'قم بتسجيل الدخول للوصول إلى فصولك ودرجاتك';

  @override
  String get employeeId => 'الرقم الوظيفي';

  @override
  String get pleaseEnterEmployeeId => 'الرجاء إدخال الرقم الوظيفي';

  @override
  String get pleaseEnterPassword => 'الرجاء إدخال كلمة المرور';

  @override
  String get today => 'اليوم';

  @override
  String get present => 'حضور';

  @override
  String get absent => 'غياب';

  @override
  String get noRecord => 'بلا سجل';

  @override
  String get all => 'الكل';

  @override
  String get searchStudentHint => 'بحث باسم الطالب...';

  @override
  String studentAttendanceRecord(String id) {
    return 'سجل حضور الطالب #$id';
  }

  @override
  String get noCurrentAssignments => 'لا توجد واجبات حالية.';

  @override
  String attachmentsCount(String count) {
    return '$count مرفقات';
  }

  @override
  String get trackSubmissionsAndFeedback => 'متابعة التسليمات والملاحظات';

  @override
  String submissionsCount(String submitted, String total) {
    return 'التسليمات: $submitted / $total';
  }

  @override
  String dueWithDate(String date) {
    return 'التسليم: $date';
  }

  @override
  String get submissionsTracking => 'متابعة التسليمات';

  @override
  String get teacherFeedback => 'ملاحظات المعلم';

  @override
  String get addNoteHint => 'إضافة ملاحظة للطالب...';

  @override
  String get gradesRecord => 'سجل الدرجات';

  @override
  String get noSearchResults => 'لا توجد نتائج مطابقة للبحث';

  @override
  String averageLabel(Object max) {
    return 'المحصلة ($max)';
  }

  @override
  String finalExamLabel(Object max) {
    return 'اختبار النهائي ($max)';
  }

  @override
  String get monthlyTotal => 'المجموع الشهري';

  @override
  String get totalGrade => 'المجموع الكلي';

  @override
  String get gradesSavedSuccessfully => 'تم حفظ الدرجات بنجاح';

  @override
  String recordMonthGrades(String month) {
    return 'رصد درجات الشهر $month';
  }

  @override
  String get recordTotalFinal => 'رصد المحصلة والنهائي';

  @override
  String monthGrades(String month) {
    return 'درجات الشهر $month';
  }

  @override
  String get endTermGrades => 'درجات نهاية الترم';

  @override
  String get saveGrades => 'حفظ الدرجات';

  @override
  String get addNewAssignment => 'إضافة واجب جديد';

  @override
  String get classLabel => 'الفصل';

  @override
  String get subjectLabel => 'المادة';

  @override
  String get assignmentTitleLabel => 'عنوان الواجب';

  @override
  String get assignmentDescLabel => 'وصف الواجب والتفاصيل';

  @override
  String get saveAndSendAssignment => 'حفظ وإرسال الواجب';

  @override
  String get dueDateLabel => 'تاريخ التسليم';

  @override
  String get dueDay => 'يوم التسليم';

  @override
  String get selectDueDate => 'حدد تاريخ التسليم';

  @override
  String get attachFilesOrImages => 'إرفاق ملفات أو صور';

  @override
  String studentWithId(String id) {
    return 'الطالب #$id';
  }

  @override
  String get noStudentsPresent => 'لا يوجد طلاب حاضرون حالياً';

  @override
  String get noStudentsAbsent => 'لا يوجد طلاب غائبون حالياً';

  @override
  String get noStudentsInSection => 'لا يوجد طلاب في هذه الشعبة';

  @override
  String get assignmentTitleHint => 'مثال: حل التمارين صفحة 45...';

  @override
  String get assignmentDescHint => 'اكتب تفاصيل الواجب هنا...';

  @override
  String get assignmentSelectFiles => 'سيتم فتح اختيار الملفات والصور.';

  @override
  String get assignmentSaveError =>
      'الرجاء إكمال جميع الحقول واختيار الفصل والمادة.';

  @override
  String get assignmentSaveSuccess =>
      'تمت إضافة الواجب وإرسال إشعار للطلاب وأولياء الأمور.';

  @override
  String get fileFormatHint => 'PDF, JPG, PNG (الحد الأقصى 10MB)';

  @override
  String get submissionStatusSubmitted => 'تم التسليم';

  @override
  String get submissionStatusLate => 'متأخر';

  @override
  String get submissionStatusNotSubmitted => 'لم يسلم';

  @override
  String homeworkLabel(String max) {
    return 'الواجب ($max)';
  }

  @override
  String attendanceLabel(String max) {
    return 'المواظبة ($max)';
  }

  @override
  String behaviorLabel(String max) {
    return 'السلوك ($max)';
  }

  @override
  String oralLabel(String max) {
    return 'الشفهي ($max)';
  }

  @override
  String writtenLabel(String max) {
    return 'التحريري ($max)';
  }
}
