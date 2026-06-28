import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'ولي الأمر'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @myChildren.
  ///
  /// In ar, this message translates to:
  /// **'أبنائي'**
  String get myChildren;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @assignments.
  ///
  /// In ar, this message translates to:
  /// **'الواجبات'**
  String get assignments;

  /// No description provided for @attendance.
  ///
  /// In ar, this message translates to:
  /// **'الحضور'**
  String get attendance;

  /// No description provided for @grades.
  ///
  /// In ar, this message translates to:
  /// **'الدرجات'**
  String get grades;

  /// No description provided for @fees.
  ///
  /// In ar, this message translates to:
  /// **'الرسوم الدراسية'**
  String get fees;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @selectChild.
  ///
  /// In ar, this message translates to:
  /// **'اختر الابن'**
  String get selectChild;

  /// No description provided for @goodMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In ar, this message translates to:
  /// **'طاب مساؤك'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get goodEvening;

  /// No description provided for @welcomeParent.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك، {name}'**
  String welcomeParent(String name);

  /// No description provided for @parentAccount.
  ///
  /// In ar, this message translates to:
  /// **'حساب ولي الأمر'**
  String get parentAccount;

  /// No description provided for @quickAccess.
  ///
  /// In ar, this message translates to:
  /// **'الوصول السريع'**
  String get quickAccess;

  /// No description provided for @absenceRequest.
  ///
  /// In ar, this message translates to:
  /// **'طلب غياب'**
  String get absenceRequest;

  /// No description provided for @gradesAndAnalytics.
  ///
  /// In ar, this message translates to:
  /// **'الدرجات والتحليلات'**
  String get gradesAndAnalytics;

  /// No description provided for @schoolAssignments.
  ///
  /// In ar, this message translates to:
  /// **'الواجبات المدرسية'**
  String get schoolAssignments;

  /// No description provided for @attendanceRecord.
  ///
  /// In ar, this message translates to:
  /// **'سجل الحضور'**
  String get attendanceRecord;

  /// No description provided for @exams.
  ///
  /// In ar, this message translates to:
  /// **'الاختبارات'**
  String get exams;

  /// No description provided for @account.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get account;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل بيانات الحساب'**
  String get editProfile;

  /// No description provided for @app.
  ///
  /// In ar, this message translates to:
  /// **'التطبيق'**
  String get app;

  /// No description provided for @appearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearance;

  /// No description provided for @light.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get dark;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @activitiesAndMessages.
  ///
  /// In ar, this message translates to:
  /// **'الأنشطة والرسائل'**
  String get activitiesAndMessages;

  /// No description provided for @support.
  ///
  /// In ar, this message translates to:
  /// **'الدعم'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In ar, this message translates to:
  /// **'مركز المساعدة'**
  String get helpCenter;

  /// No description provided for @contactUs.
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا'**
  String get contactUs;

  /// No description provided for @aboutApp.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutApp;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تسجيل الخروج؟'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'حسناً'**
  String get ok;

  /// No description provided for @generalNotification.
  ///
  /// In ar, this message translates to:
  /// **'إشعار عام'**
  String get generalNotification;

  /// No description provided for @publicHolidayTomorrow.
  ///
  /// In ar, this message translates to:
  /// **'غداً إجازة رسمية.'**
  String get publicHolidayTomorrow;

  /// No description provided for @oneHourAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ 1 ساعة'**
  String get oneHourAgo;

  /// No description provided for @privateMessageFromAdmin.
  ///
  /// In ar, this message translates to:
  /// **'رسالة خاصة من الإدارة'**
  String get privateMessageFromAdmin;

  /// No description provided for @reviewWithAdmin.
  ///
  /// In ar, this message translates to:
  /// **'نرجو مراجعة الإدارة بشأن مستوى الطالب.'**
  String get reviewWithAdmin;

  /// No description provided for @yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get yesterday;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك مجدداً في تطبيق رياض ومدارس أنوار العلى'**
  String get welcomeBack;

  /// No description provided for @phoneNumberOrUsername.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف / اسم المستخدم'**
  String get phoneNumberOrUsername;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// No description provided for @teacherRole.
  ///
  /// In ar, this message translates to:
  /// **'معلّـم'**
  String get teacherRole;

  /// No description provided for @assistantRole.
  ///
  /// In ar, this message translates to:
  /// **'مشرفة تحضير'**
  String get assistantRole;

  /// No description provided for @forgotPasswordComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تفعيل ميزة استعادة كلمة المرور قريباً.'**
  String get forgotPasswordComingSoon;

  /// No description provided for @versionLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String versionLabel(String version);

  /// No description provided for @pleaseSelectStudent.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء اختيار الطالب'**
  String get pleaseSelectStudent;

  /// No description provided for @noAssignmentsForToday.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد واجبات لهذا اليوم'**
  String get noAssignmentsForToday;

  /// No description provided for @totalFees.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الرسوم'**
  String get totalFees;

  /// No description provided for @paid.
  ///
  /// In ar, this message translates to:
  /// **'تم الدفع'**
  String get paid;

  /// No description provided for @remaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get remaining;

  /// No description provided for @paymentHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل المدفوعات'**
  String get paymentHistory;

  /// No description provided for @financialPayment.
  ///
  /// In ar, this message translates to:
  /// **'دفعة مالية'**
  String get financialPayment;

  /// No description provided for @pleaseSelectChildToViewExams.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء اختيار ابن لعرض جداول الاختبارات الخاصة به'**
  String get pleaseSelectChildToViewExams;

  /// No description provided for @firstSemester.
  ///
  /// In ar, this message translates to:
  /// **'الفصل الدراسي الأول'**
  String get firstSemester;

  /// No description provided for @secondSemester.
  ///
  /// In ar, this message translates to:
  /// **'الفصل الدراسي الثاني'**
  String get secondSemester;

  /// No description provided for @noScheduleAddedFor.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد جدول مضاف لـ {period}'**
  String noScheduleAddedFor(String period);

  /// No description provided for @noGradesYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد درجات حتى الآن'**
  String get noGradesYet;

  /// No description provided for @finalResultNote.
  ///
  /// In ar, this message translates to:
  /// **'المحصلة النهائية (مجموع الأشهر ÷ 15)'**
  String get finalResultNote;

  /// No description provided for @children.
  ///
  /// In ar, this message translates to:
  /// **'الابناء'**
  String get children;

  /// No description provided for @attendanceBehavior.
  ///
  /// In ar, this message translates to:
  /// **'مواظبة'**
  String get attendanceBehavior;

  /// No description provided for @oral.
  ///
  /// In ar, this message translates to:
  /// **'شفوي'**
  String get oral;

  /// No description provided for @homework.
  ///
  /// In ar, this message translates to:
  /// **'واجبات'**
  String get homework;

  /// No description provided for @written.
  ///
  /// In ar, this message translates to:
  /// **'تحريري'**
  String get written;

  /// No description provided for @midTermFinalExam.
  ///
  /// In ar, this message translates to:
  /// **'الاختبار النصفي / النهائي'**
  String get midTermFinalExam;

  /// No description provided for @totalTermGrades.
  ///
  /// In ar, this message translates to:
  /// **'مجموع درجات الترم'**
  String get totalTermGrades;

  /// No description provided for @totalYearlyGrades.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الكلي للمادة (سنة)'**
  String get totalYearlyGrades;

  /// No description provided for @absenceRequestSentSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب الغياب بنجاح'**
  String get absenceRequestSentSuccessfully;

  /// No description provided for @errorSendingAbsenceRequest.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء الإرسال'**
  String get errorSendingAbsenceRequest;

  /// No description provided for @selectDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر التاريخ'**
  String get selectDate;

  /// No description provided for @reasonOptional.
  ///
  /// In ar, this message translates to:
  /// **'السبب (اختياري)'**
  String get reasonOptional;

  /// No description provided for @noRegisteredStudents.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد طلاب مسجلين'**
  String get noRegisteredStudents;

  /// No description provided for @exampleMedicalAppointment.
  ///
  /// In ar, this message translates to:
  /// **'مثال: موعد طبي...'**
  String get exampleMedicalAppointment;

  /// No description provided for @sendAbsenceRequest.
  ///
  /// In ar, this message translates to:
  /// **'إرسال طلب الغياب'**
  String get sendAbsenceRequest;

  /// No description provided for @attendanceDays.
  ///
  /// In ar, this message translates to:
  /// **'أيام الحضور'**
  String get attendanceDays;

  /// No description provided for @absenceDays.
  ///
  /// In ar, this message translates to:
  /// **'أيام الغياب'**
  String get absenceDays;

  /// No description provided for @pleaseSelectStudentToViewAttendance.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء اختيار الطالب لعرض سجل الحضور'**
  String get pleaseSelectStudentToViewAttendance;

  /// No description provided for @saturday.
  ///
  /// In ar, this message translates to:
  /// **'السبت'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In ar, this message translates to:
  /// **'الأحد'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In ar, this message translates to:
  /// **'الاثنين'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In ar, this message translates to:
  /// **'الثلاثاء'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In ar, this message translates to:
  /// **'الأربعاء'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In ar, this message translates to:
  /// **'الخميس'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In ar, this message translates to:
  /// **'الجمعة'**
  String get friday;

  /// No description provided for @currencySar.
  ///
  /// In ar, this message translates to:
  /// **'{amount} ر.ي'**
  String currencySar(String amount);

  /// No description provided for @math.
  ///
  /// In ar, this message translates to:
  /// **'الرياضيات'**
  String get math;

  /// No description provided for @science.
  ///
  /// In ar, this message translates to:
  /// **'العلوم'**
  String get science;

  /// No description provided for @arabicLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة العربية'**
  String get arabicLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة الإنجليزية'**
  String get englishLanguage;

  /// No description provided for @quran.
  ///
  /// In ar, this message translates to:
  /// **'القرآن الكريم'**
  String get quran;

  /// No description provided for @socialStudies.
  ///
  /// In ar, this message translates to:
  /// **'الاجتماعيات'**
  String get socialStudies;

  /// No description provided for @history.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get history;

  /// No description provided for @physics.
  ///
  /// In ar, this message translates to:
  /// **'الفيزياء'**
  String get physics;

  /// No description provided for @month1.
  ///
  /// In ar, this message translates to:
  /// **'الشهر الأول'**
  String get month1;

  /// No description provided for @month2.
  ///
  /// In ar, this message translates to:
  /// **'الشهر الثاني'**
  String get month2;

  /// No description provided for @month3.
  ///
  /// In ar, this message translates to:
  /// **'الشهر الثالث'**
  String get month3;

  /// No description provided for @month4.
  ///
  /// In ar, this message translates to:
  /// **'الشهر الرابع'**
  String get month4;

  /// No description provided for @month5.
  ///
  /// In ar, this message translates to:
  /// **'الشهر الخامس'**
  String get month5;

  /// No description provided for @month6.
  ///
  /// In ar, this message translates to:
  /// **'الشهر السادس'**
  String get month6;

  /// No description provided for @finalExam.
  ///
  /// In ar, this message translates to:
  /// **'اختبار نهاية الترم'**
  String get finalExam;

  /// No description provided for @assignmentMath.
  ///
  /// In ar, this message translates to:
  /// **'حل التمارين صفحة 45 من كتاب الطالب.'**
  String get assignmentMath;

  /// No description provided for @assignmentScience.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة الفصل الثالث استعداداً للاختبار.'**
  String get assignmentScience;

  /// No description provided for @assignmentArabic.
  ///
  /// In ar, this message translates to:
  /// **'كتابة موضوع تعبير عن أهمية القراءة.'**
  String get assignmentArabic;

  /// No description provided for @assignmentHistory.
  ///
  /// In ar, this message translates to:
  /// **'تلخيص الدرس الثاني.'**
  String get assignmentHistory;

  /// No description provided for @assignmentPhysics.
  ///
  /// In ar, this message translates to:
  /// **'حل مسائل الحركة بتسارع ثابت.'**
  String get assignmentPhysics;

  /// No description provided for @assignmentQuran.
  ///
  /// In ar, this message translates to:
  /// **'حفظ سورة النبأ.'**
  String get assignmentQuran;

  /// No description provided for @assignmentMath2.
  ///
  /// In ar, this message translates to:
  /// **'جدول الضرب من 1 إلى 5.'**
  String get assignmentMath2;

  /// No description provided for @examQuran1.
  ///
  /// In ar, this message translates to:
  /// **'تسميع سورة البقرة من آية 1 إلى 50'**
  String get examQuran1;

  /// No description provided for @examQuran2.
  ///
  /// In ar, this message translates to:
  /// **'تسميع سورة البقرة من 50 إلى 100'**
  String get examQuran2;

  /// No description provided for @examMath1.
  ///
  /// In ar, this message translates to:
  /// **'الباب الأول فقط'**
  String get examMath1;

  /// No description provided for @examMath2.
  ///
  /// In ar, this message translates to:
  /// **'شامل'**
  String get examMath2;

  /// No description provided for @examArabic.
  ///
  /// In ar, this message translates to:
  /// **'النصوص والقواعد النحوية'**
  String get examArabic;

  /// No description provided for @examScience.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة الثانية'**
  String get examScience;

  /// No description provided for @examSocial.
  ///
  /// In ar, this message translates to:
  /// **'الجغرافيا والتاريخ'**
  String get examSocial;

  /// No description provided for @examEnglish.
  ///
  /// In ar, this message translates to:
  /// **'شامل كامل الكتاب'**
  String get examEnglish;

  /// No description provided for @childName1.
  ///
  /// In ar, this message translates to:
  /// **'أحمد محمد عبدالله'**
  String get childName1;

  /// No description provided for @childGrade1.
  ///
  /// In ar, this message translates to:
  /// **'الصف الخامس - شعبة (أ)'**
  String get childGrade1;

  /// No description provided for @childName2.
  ///
  /// In ar, this message translates to:
  /// **'سارة محمد عبدالله'**
  String get childName2;

  /// No description provided for @childGrade2.
  ///
  /// In ar, this message translates to:
  /// **'الصف الثالث - شعبة (ب)'**
  String get childGrade2;

  /// No description provided for @childName3.
  ///
  /// In ar, this message translates to:
  /// **'عمر محمد عبدالله'**
  String get childName3;

  /// No description provided for @childGrade3.
  ///
  /// In ar, this message translates to:
  /// **'الصف الأول - شعبة (ج)'**
  String get childGrade3;

  /// No description provided for @teacherAccount.
  ///
  /// In ar, this message translates to:
  /// **'حساب المعلم'**
  String get teacherAccount;

  /// No description provided for @teacherName.
  ///
  /// In ar, this message translates to:
  /// **'أستاذ أحمد محمد'**
  String get teacherName;

  /// No description provided for @classGrade5A.
  ///
  /// In ar, this message translates to:
  /// **'الصف الخامس - أ'**
  String get classGrade5A;

  /// No description provided for @classGrade6B.
  ///
  /// In ar, this message translates to:
  /// **'الصف السادس - ب'**
  String get classGrade6B;

  /// No description provided for @subjectLughati.
  ///
  /// In ar, this message translates to:
  /// **'لغتي'**
  String get subjectLughati;

  /// No description provided for @myClasses.
  ///
  /// In ar, this message translates to:
  /// **'فصولي'**
  String get myClasses;

  /// No description provided for @messages.
  ///
  /// In ar, this message translates to:
  /// **'الرسائل'**
  String get messages;

  /// No description provided for @comingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً...'**
  String get comingSoon;

  /// No description provided for @emergencyMeetingTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب اجتماع طارئ'**
  String get emergencyMeetingTitle;

  /// No description provided for @emergencyMeetingMessage.
  ///
  /// In ar, this message translates to:
  /// **'اجتماع طارئ لأعضاء هيئة التدريس في المكتبة المدرسية الساعة 12 ظهراً لمناقشة سير الاختبارات.'**
  String get emergencyMeetingMessage;

  /// No description provided for @todayAt10am.
  ///
  /// In ar, this message translates to:
  /// **'اليوم، 10:00 ص'**
  String get todayAt10am;

  /// No description provided for @gradesAlertTitle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه رصد الدرجات'**
  String get gradesAlertTitle;

  /// No description provided for @gradesAlertMessage.
  ///
  /// In ar, this message translates to:
  /// **'يرجى استكمال رصد درجات الشهر الأول لجميع الطلاب قبل نهاية هذا الأسبوع.'**
  String get gradesAlertMessage;

  /// No description provided for @selectHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر'**
  String get selectHint;

  /// No description provided for @appNameTeacherPortal.
  ///
  /// In ar, this message translates to:
  /// **'رياض ومدارس أنوار العلى - بوابة المعلم'**
  String get appNameTeacherPortal;

  /// No description provided for @loginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قم بتسجيل الدخول للوصول إلى فصولك ودرجاتك'**
  String get loginSubtitle;

  /// No description provided for @employeeId.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الوظيفي'**
  String get employeeId;

  /// No description provided for @pleaseEnterEmployeeId.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال الرقم الوظيفي'**
  String get pleaseEnterEmployeeId;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال كلمة المرور'**
  String get pleaseEnterPassword;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @present.
  ///
  /// In ar, this message translates to:
  /// **'حضور'**
  String get present;

  /// No description provided for @absent.
  ///
  /// In ar, this message translates to:
  /// **'غياب'**
  String get absent;

  /// No description provided for @noRecord.
  ///
  /// In ar, this message translates to:
  /// **'بلا سجل'**
  String get noRecord;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @searchStudentHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث باسم الطالب أو رقم الهوية...'**
  String get searchStudentHint;

  /// No description provided for @studentAttendanceRecord.
  ///
  /// In ar, this message translates to:
  /// **'سجل حضور الطالب #{id}'**
  String studentAttendanceRecord(String id);

  /// No description provided for @noCurrentAssignments.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد واجبات حالية.'**
  String get noCurrentAssignments;

  /// No description provided for @attachmentsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مرفقات'**
  String attachmentsCount(String count);

  /// No description provided for @trackSubmissionsAndFeedback.
  ///
  /// In ar, this message translates to:
  /// **'متابعة التسليمات والملاحظات'**
  String get trackSubmissionsAndFeedback;

  /// No description provided for @submissionsCount.
  ///
  /// In ar, this message translates to:
  /// **'التسليمات: {submitted} / {total}'**
  String submissionsCount(String submitted, String total);

  /// No description provided for @dueWithDate.
  ///
  /// In ar, this message translates to:
  /// **'التسليم: {date}'**
  String dueWithDate(String date);

  /// No description provided for @submissionsTracking.
  ///
  /// In ar, this message translates to:
  /// **'متابعة التسليمات'**
  String get submissionsTracking;

  /// No description provided for @teacherFeedback.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات المعلم'**
  String get teacherFeedback;

  /// No description provided for @addNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ملاحظة للطالب...'**
  String get addNoteHint;

  /// No description provided for @gradesRecord.
  ///
  /// In ar, this message translates to:
  /// **'سجل الدرجات'**
  String get gradesRecord;

  /// No description provided for @noSearchResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج مطابقة للبحث'**
  String get noSearchResults;

  /// No description provided for @averageLabel.
  ///
  /// In ar, this message translates to:
  /// **'المحصلة ({max})'**
  String averageLabel(Object max);

  /// No description provided for @finalExamLabel.
  ///
  /// In ar, this message translates to:
  /// **'اختبار النهائي ({max})'**
  String finalExamLabel(Object max);

  /// No description provided for @monthlyTotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الشهري'**
  String get monthlyTotal;

  /// No description provided for @totalGrade.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الكلي'**
  String get totalGrade;

  /// No description provided for @gradesSavedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الدرجات بنجاح'**
  String get gradesSavedSuccessfully;

  /// No description provided for @recordMonthGrades.
  ///
  /// In ar, this message translates to:
  /// **'رصد درجات الشهر {month}'**
  String recordMonthGrades(String month);

  /// No description provided for @recordTotalFinal.
  ///
  /// In ar, this message translates to:
  /// **'رصد المحصلة والنهائي'**
  String get recordTotalFinal;

  /// No description provided for @monthGrades.
  ///
  /// In ar, this message translates to:
  /// **'درجات الشهر {month}'**
  String monthGrades(String month);

  /// No description provided for @endTermGrades.
  ///
  /// In ar, this message translates to:
  /// **'درجات نهاية الترم'**
  String get endTermGrades;

  /// No description provided for @saveGrades.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الدرجات'**
  String get saveGrades;

  /// No description provided for @addNewAssignment.
  ///
  /// In ar, this message translates to:
  /// **'إضافة واجب جديد'**
  String get addNewAssignment;

  /// No description provided for @classLabel.
  ///
  /// In ar, this message translates to:
  /// **'الفصل'**
  String get classLabel;

  /// No description provided for @subjectLabel.
  ///
  /// In ar, this message translates to:
  /// **'المادة'**
  String get subjectLabel;

  /// No description provided for @assignmentTitleLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الواجب'**
  String get assignmentTitleLabel;

  /// No description provided for @assignmentDescLabel.
  ///
  /// In ar, this message translates to:
  /// **'وصف الواجب والتفاصيل'**
  String get assignmentDescLabel;

  /// No description provided for @saveAndSendAssignment.
  ///
  /// In ar, this message translates to:
  /// **'حفظ وإرسال الواجب'**
  String get saveAndSendAssignment;

  /// No description provided for @dueDateLabel.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ التسليم'**
  String get dueDateLabel;

  /// No description provided for @dueDay.
  ///
  /// In ar, this message translates to:
  /// **'يوم التسليم'**
  String get dueDay;

  /// No description provided for @selectDueDate.
  ///
  /// In ar, this message translates to:
  /// **'حدد تاريخ التسليم'**
  String get selectDueDate;

  /// No description provided for @attachFilesOrImages.
  ///
  /// In ar, this message translates to:
  /// **'إرفاق ملفات أو صور'**
  String get attachFilesOrImages;

  /// No description provided for @studentWithId.
  ///
  /// In ar, this message translates to:
  /// **'الطالب #{id}'**
  String studentWithId(String id);

  /// No description provided for @noStudentsPresent.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد طلاب حاضرون حالياً'**
  String get noStudentsPresent;

  /// No description provided for @noStudentsAbsent.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد طلاب غائبون حالياً'**
  String get noStudentsAbsent;

  /// No description provided for @noStudentsInSection.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد طلاب في هذه الشعبة'**
  String get noStudentsInSection;

  /// No description provided for @assignmentTitleHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: حل التمارين صفحة 45...'**
  String get assignmentTitleHint;

  /// No description provided for @assignmentDescHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب تفاصيل الواجب هنا...'**
  String get assignmentDescHint;

  /// No description provided for @assignmentSelectFiles.
  ///
  /// In ar, this message translates to:
  /// **'سيتم فتح اختيار الملفات والصور.'**
  String get assignmentSelectFiles;

  /// No description provided for @assignmentSaveError.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إكمال جميع الحقول واختيار الفصل والمادة.'**
  String get assignmentSaveError;

  /// No description provided for @assignmentSaveSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة الواجب وإرسال إشعار للطلاب وأولياء الأمور.'**
  String get assignmentSaveSuccess;

  /// No description provided for @fileFormatHint.
  ///
  /// In ar, this message translates to:
  /// **'PDF, JPG, PNG (الحد الأقصى 10MB)'**
  String get fileFormatHint;

  /// No description provided for @submissionStatusSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم'**
  String get submissionStatusSubmitted;

  /// No description provided for @submissionStatusLate.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get submissionStatusLate;

  /// No description provided for @submissionStatusNotSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'لم يسلم'**
  String get submissionStatusNotSubmitted;

  /// No description provided for @homeworkLabel.
  ///
  /// In ar, this message translates to:
  /// **'الواجب ({max})'**
  String homeworkLabel(String max);

  /// No description provided for @attendanceLabel.
  ///
  /// In ar, this message translates to:
  /// **'المواظبة ({max})'**
  String attendanceLabel(String max);

  /// No description provided for @behaviorLabel.
  ///
  /// In ar, this message translates to:
  /// **'السلوك ({max})'**
  String behaviorLabel(String max);

  /// No description provided for @oralLabel.
  ///
  /// In ar, this message translates to:
  /// **'الشفهي ({max})'**
  String oralLabel(String max);

  /// No description provided for @writtenLabel.
  ///
  /// In ar, this message translates to:
  /// **'التحريري ({max})'**
  String writtenLabel(String max);

  /// No description provided for @assistantHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get assistantHome;

  /// No description provided for @assistantClasses.
  ///
  /// In ar, this message translates to:
  /// **'فصولي والطلاب'**
  String get assistantClasses;

  /// No description provided for @assistantReports.
  ///
  /// In ar, this message translates to:
  /// **'تقارير الحضور والغياب'**
  String get assistantReports;

  /// No description provided for @assistantHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الحضور والغياب'**
  String get assistantHistory;

  /// No description provided for @studentsCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الطلاب: {count}'**
  String studentsCount(int count);

  /// No description provided for @attendanceStats.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات التحضير اليومية'**
  String get attendanceStats;

  /// No description provided for @quickTasks.
  ///
  /// In ar, this message translates to:
  /// **'الوصول السريع للمهام'**
  String get quickTasks;

  /// No description provided for @totalTrackStudents.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الطلاب بالمسارات'**
  String get totalTrackStudents;

  /// No description provided for @cumulativeAttendanceRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الحضور التراكمية'**
  String get cumulativeAttendanceRate;

  /// No description provided for @dailyAttendance.
  ///
  /// In ar, this message translates to:
  /// **'الحضور اليومي'**
  String get dailyAttendance;

  /// No description provided for @dailyAbsence.
  ///
  /// In ar, this message translates to:
  /// **'الغياب اليومي'**
  String get dailyAbsence;

  /// No description provided for @cumulativeAttendanceStats.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات حضور الطلاب التراكمية'**
  String get cumulativeAttendanceStats;

  /// No description provided for @monaAlHarbi.
  ///
  /// In ar, this message translates to:
  /// **'أ. منى الحربي'**
  String get monaAlHarbi;

  /// No description provided for @prepAssistant.
  ///
  /// In ar, this message translates to:
  /// **'مشرفة تحضير'**
  String get prepAssistant;

  /// No description provided for @recordDaysCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد أيام الكشوفات: {count} أيام'**
  String recordDaysCount(int count);

  /// No description provided for @prepAssistantDescription.
  ///
  /// In ar, this message translates to:
  /// **'مشرفة تحضير وتفقد الطلاب اليومي'**
  String get prepAssistantDescription;

  /// No description provided for @totalStudents.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الطلاب'**
  String get totalStudents;

  /// No description provided for @presentToday.
  ///
  /// In ar, this message translates to:
  /// **'حاضرون اليوم'**
  String get presentToday;

  /// No description provided for @absentToday.
  ///
  /// In ar, this message translates to:
  /// **'غائبون اليوم'**
  String get absentToday;

  /// No description provided for @pending.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get pending;

  /// No description provided for @scanQr.
  ///
  /// In ar, this message translates to:
  /// **'مسح الكود (QR)'**
  String get scanQr;

  /// No description provided for @noMatchingResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج مطابقة لبحثك'**
  String get noMatchingResults;

  /// No description provided for @civilIdLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهوية: {id}'**
  String civilIdLabel(String id);

  /// No description provided for @presentLabel.
  ///
  /// In ar, this message translates to:
  /// **'حضور'**
  String get presentLabel;

  /// No description provided for @absentLabel.
  ///
  /// In ar, this message translates to:
  /// **'غياب'**
  String get absentLabel;

  /// No description provided for @attendanceDaysLabel.
  ///
  /// In ar, this message translates to:
  /// **'أيام الحضور'**
  String get attendanceDaysLabel;

  /// No description provided for @absenceDaysLabel.
  ///
  /// In ar, this message translates to:
  /// **'أيام الغياب'**
  String get absenceDaysLabel;

  /// No description provided for @sundayShort.
  ///
  /// In ar, this message translates to:
  /// **'أحد'**
  String get sundayShort;

  /// No description provided for @mondayShort.
  ///
  /// In ar, this message translates to:
  /// **'اثنين'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In ar, this message translates to:
  /// **'ثلاثاء'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In ar, this message translates to:
  /// **'أربعاء'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In ar, this message translates to:
  /// **'خميس'**
  String get thursdayShort;

  /// No description provided for @attendanceThisMonth.
  ///
  /// In ar, this message translates to:
  /// **'الحضور هذا الشهر'**
  String get attendanceThisMonth;

  /// No description provided for @absenceThisMonth.
  ///
  /// In ar, this message translates to:
  /// **'الغياب هذا الشهر'**
  String get absenceThisMonth;

  /// No description provided for @absentPlural.
  ///
  /// In ar, this message translates to:
  /// **'غائبون'**
  String get absentPlural;

  /// No description provided for @presentPlural.
  ///
  /// In ar, this message translates to:
  /// **'حاضرون'**
  String get presentPlural;

  /// No description provided for @noAttendanceRecordForToday.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد كشف حضور مسجل لهذا اليوم:\n{date}'**
  String noAttendanceRecordForToday(String date);

  /// No description provided for @parentOrGuardian.
  ///
  /// In ar, this message translates to:
  /// **'ولي الأمر / الوصي'**
  String get parentOrGuardian;

  /// No description provided for @parentPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم هاتف ولي الأمر'**
  String get parentPhone;

  /// No description provided for @contactWhatsApp.
  ///
  /// In ar, this message translates to:
  /// **'تواصل عبر الواتساب'**
  String get contactWhatsApp;

  /// No description provided for @details.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get details;

  /// No description provided for @finishAndSendReport.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء وإرسال تقرير التحضير'**
  String get finishAndSendReport;

  /// No description provided for @reportSentSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تأكيد وإرسال كشف حضور الطلاب بنجاح'**
  String get reportSentSuccess;

  /// No description provided for @reportSentFail.
  ///
  /// In ar, this message translates to:
  /// **'فشل تأكيد وإرسال التقرير، يرجى المحاولة لاحقاً'**
  String get reportSentFail;

  /// No description provided for @attendanceSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص كشف الحضور'**
  String get attendanceSummary;

  /// No description provided for @confirmSendReport.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من إنهاء وإرسال تقرير حضور الطلاب للإدارة المدرسية؟ لا يمكن تعديله لاحقاً.'**
  String get confirmSendReport;

  /// No description provided for @unmarked.
  ///
  /// In ar, this message translates to:
  /// **'غير مرصود'**
  String get unmarked;

  /// No description provided for @unmarkedWarning.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه: هناك عدد {count} طلاب لم يتم رصد حضورهم.'**
  String unmarkedWarning(int count);

  /// No description provided for @sendAndConfirm.
  ///
  /// In ar, this message translates to:
  /// **'إرسال وتأكيد'**
  String get sendAndConfirm;

  /// No description provided for @scanSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل حضور الطالب:\n{name} (بنجاح)'**
  String scanSuccess(String name);

  /// No description provided for @qrScannerTitle.
  ///
  /// In ar, this message translates to:
  /// **'ماسح حضور الطلاب (QR)'**
  String get qrScannerTitle;

  /// No description provided for @pointCameraHint.
  ///
  /// In ar, this message translates to:
  /// **'وجه الكاميرا نحو الرمز الخاص بالطالب المطبوع على بطاقته الذكية'**
  String get pointCameraHint;

  /// No description provided for @scanSimPanel.
  ///
  /// In ar, this message translates to:
  /// **'لوحة محاكاة المسح (للاختبار والتشغيل بدون كاميرا):'**
  String get scanSimPanel;

  /// No description provided for @chooseStudentSim.
  ///
  /// In ar, this message translates to:
  /// **'اختر طالب لمحاكاة مسحه'**
  String get chooseStudentSim;

  /// No description provided for @simScanBtn.
  ///
  /// In ar, this message translates to:
  /// **'محاكاة مسح الكود للطالب المختار'**
  String get simScanBtn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
