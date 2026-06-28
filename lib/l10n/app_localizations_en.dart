// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Parent App';

  @override
  String get home => 'Home';

  @override
  String get myChildren => 'My Children';

  @override
  String get notifications => 'Notifications';

  @override
  String get assignments => 'Assignments';

  @override
  String get attendance => 'Attendance';

  @override
  String get grades => 'Grades';

  @override
  String get fees => 'Tuition Fees';

  @override
  String get settings => 'Settings';

  @override
  String get selectChild => 'Select Child';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String welcomeParent(String name) {
    return 'Welcome, $name';
  }

  @override
  String get parentAccount => 'Parent Account';

  @override
  String get quickAccess => 'Quick Access';

  @override
  String get absenceRequest => 'Absence Request';

  @override
  String get gradesAndAnalytics => 'Grades & Analytics';

  @override
  String get schoolAssignments => 'School Assignments';

  @override
  String get attendanceRecord => 'Attendance Record';

  @override
  String get exams => 'Exams';

  @override
  String get account => 'Account';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit account details';

  @override
  String get app => 'App';

  @override
  String get appearance => 'Appearance';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get activitiesAndMessages => 'Activities and messages';

  @override
  String get support => 'Support';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get aboutApp => 'About App';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get generalNotification => 'General Notification';

  @override
  String get publicHolidayTomorrow => 'Tomorrow is a public holiday.';

  @override
  String get oneHourAgo => '1 hour ago';

  @override
  String get privateMessageFromAdmin => 'Private message from administration';

  @override
  String get reviewWithAdmin =>
      'Please review with administration regarding the student\'s level.';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get login => 'Login';

  @override
  String get welcomeBack => 'Welcome back to Riyadh & Anwar Al-Ola Schools app';

  @override
  String get phoneNumberOrUsername => 'Phone Number / Username';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get teacherRole => 'Teacher';

  @override
  String get assistantRole => 'Assistant';

  @override
  String get forgotPasswordComingSoon =>
      'Password recovery feature will be activated soon.';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get pleaseSelectStudent => 'Please select a student';

  @override
  String get noAssignmentsForToday => 'No assignments for today';

  @override
  String get totalFees => 'Total Fees';

  @override
  String get paid => 'Paid';

  @override
  String get remaining => 'Remaining';

  @override
  String get paymentHistory => 'Payment History';

  @override
  String get financialPayment => 'Financial Payment';

  @override
  String get pleaseSelectChildToViewExams =>
      'Please select a child to view their exam schedules';

  @override
  String get firstSemester => 'First Semester';

  @override
  String get secondSemester => 'Second Semester';

  @override
  String noScheduleAddedFor(String period) {
    return 'No schedule added for $period';
  }

  @override
  String get noGradesYet => 'No grades yet';

  @override
  String get finalResultNote => 'Final result (total months ÷ 15)';

  @override
  String get children => 'Children';

  @override
  String get attendanceBehavior => 'Attendance/Behavior';

  @override
  String get oral => 'Oral';

  @override
  String get homework => 'Homework';

  @override
  String get written => 'Written';

  @override
  String get midTermFinalExam => 'Mid-term / Final Exam';

  @override
  String get totalTermGrades => 'Total Term Grades';

  @override
  String get totalYearlyGrades => 'Total Yearly Grades (Subject)';

  @override
  String get absenceRequestSentSuccessfully =>
      'Absence request sent successfully';

  @override
  String get errorSendingAbsenceRequest => 'Error sending absence request';

  @override
  String get selectDate => 'Select Date';

  @override
  String get reasonOptional => 'Reason (Optional)';

  @override
  String get noRegisteredStudents => 'No registered students';

  @override
  String get exampleMedicalAppointment => 'Example: Medical appointment...';

  @override
  String get sendAbsenceRequest => 'Send Absence Request';

  @override
  String get attendanceDays => 'Attendance Days';

  @override
  String get absenceDays => 'Absence Days';

  @override
  String get pleaseSelectStudentToViewAttendance =>
      'Please select student to view attendance';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String currencySar(String amount) {
    return '$amount R.Y';
  }

  @override
  String get math => 'Math';

  @override
  String get science => 'Science';

  @override
  String get arabicLanguage => 'Arabic Language';

  @override
  String get englishLanguage => 'English Language';

  @override
  String get quran => 'Holy Quran';

  @override
  String get socialStudies => 'Social Studies';

  @override
  String get history => 'History';

  @override
  String get physics => 'Physics';

  @override
  String get month1 => 'First Month';

  @override
  String get month2 => 'Second Month';

  @override
  String get month3 => 'Third Month';

  @override
  String get month4 => 'Fourth Month';

  @override
  String get month5 => 'Fifth Month';

  @override
  String get month6 => 'Sixth Month';

  @override
  String get finalExam => 'End of Term Exam';

  @override
  String get assignmentMath => 'Solve exercises page 45 from student book.';

  @override
  String get assignmentScience => 'Review chapter three for the exam.';

  @override
  String get assignmentArabic =>
      'Write an essay about the importance of reading.';

  @override
  String get assignmentHistory => 'Summarize the second lesson.';

  @override
  String get assignmentPhysics =>
      'Solve constant acceleration motion problems.';

  @override
  String get assignmentQuran => 'Memorize Surah An-Naba.';

  @override
  String get assignmentMath2 => 'Multiplication table from 1 to 5.';

  @override
  String get examQuran1 => 'Recite Surah Al-Baqarah from verse 1 to 50';

  @override
  String get examQuran2 => 'Recite Surah Al-Baqarah from 50 to 100';

  @override
  String get examMath1 => 'Chapter one only';

  @override
  String get examMath2 => 'Comprehensive';

  @override
  String get examArabic => 'Texts and grammar';

  @override
  String get examScience => 'Second unit';

  @override
  String get examSocial => 'Geography and history';

  @override
  String get examEnglish => 'Comprehensive whole book';

  @override
  String get childName1 => 'Ahmed Mohammed Abdullah';

  @override
  String get childGrade1 => 'Grade 5 - Section (A)';

  @override
  String get childName2 => 'Sarah Mohammed Abdullah';

  @override
  String get childGrade2 => 'Grade 3 - Section (B)';

  @override
  String get childName3 => 'Omar Mohammed Abdullah';

  @override
  String get childGrade3 => 'Grade 1 - Section (C)';

  @override
  String get teacherAccount => 'Teacher Account';

  @override
  String get teacherName => 'Mr. Ahmed Mohammed';

  @override
  String get classGrade5A => 'Grade 5 - A';

  @override
  String get classGrade6B => 'Grade 6 - B';

  @override
  String get subjectLughati => 'Arabic (Lughati)';

  @override
  String get myClasses => 'My Classes';

  @override
  String get messages => 'Messages';

  @override
  String get comingSoon => 'Coming soon...';

  @override
  String get emergencyMeetingTitle => 'Emergency Meeting Request';

  @override
  String get emergencyMeetingMessage =>
      'Emergency meeting for faculty members in the school library at 12 PM to discuss exams.';

  @override
  String get todayAt10am => 'Today, 10:00 AM';

  @override
  String get gradesAlertTitle => 'Grades Recording Alert';

  @override
  String get gradesAlertMessage =>
      'Please complete recording the first month\'s grades for all students before the end of this week.';

  @override
  String get selectHint => 'Select';

  @override
  String get appNameTeacherPortal => 'Anwar Al-Ola Schools - Teacher Portal';

  @override
  String get loginSubtitle => 'Sign in to access your classes and grades';

  @override
  String get employeeId => 'Employee ID';

  @override
  String get pleaseEnterEmployeeId => 'Please enter your employee ID';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get today => 'Today';

  @override
  String get present => 'Present';

  @override
  String get absent => 'Absent';

  @override
  String get noRecord => 'No Record';

  @override
  String get all => 'All';

  @override
  String get searchStudentHint => 'Search by student name or civil ID...';

  @override
  String studentAttendanceRecord(String id) {
    return 'Student Attendance Record #$id';
  }

  @override
  String get noCurrentAssignments => 'No current assignments.';

  @override
  String attachmentsCount(String count) {
    return '$count attachments';
  }

  @override
  String get trackSubmissionsAndFeedback => 'Track Submissions & Feedback';

  @override
  String submissionsCount(String submitted, String total) {
    return 'Submissions: $submitted / $total';
  }

  @override
  String dueWithDate(String date) {
    return 'Due: $date';
  }

  @override
  String get submissionsTracking => 'Submissions Tracking';

  @override
  String get teacherFeedback => 'Teacher Feedback';

  @override
  String get addNoteHint => 'Add feedback for the student...';

  @override
  String get gradesRecord => 'Grades Record';

  @override
  String get noSearchResults => 'No search results match';

  @override
  String averageLabel(Object max) {
    return 'Average ($max)';
  }

  @override
  String finalExamLabel(Object max) {
    return 'Final Exam ($max)';
  }

  @override
  String get monthlyTotal => 'Monthly Total';

  @override
  String get totalGrade => 'Total Grade';

  @override
  String get gradesSavedSuccessfully => 'Grades saved successfully';

  @override
  String recordMonthGrades(String month) {
    return 'Record Month $month Grades';
  }

  @override
  String get recordTotalFinal => 'Record Total & Final';

  @override
  String monthGrades(String month) {
    return 'Month $month Grades';
  }

  @override
  String get endTermGrades => 'End of Term Grades';

  @override
  String get saveGrades => 'Save Grades';

  @override
  String get addNewAssignment => 'Add New Assignment';

  @override
  String get classLabel => 'Class';

  @override
  String get subjectLabel => 'Subject';

  @override
  String get assignmentTitleLabel => 'Assignment Title';

  @override
  String get assignmentDescLabel => 'Assignment Description & Details';

  @override
  String get saveAndSendAssignment => 'Save & Send Assignment';

  @override
  String get dueDateLabel => 'Due Date';

  @override
  String get dueDay => 'Due Day';

  @override
  String get selectDueDate => 'Select Due Date';

  @override
  String get attachFilesOrImages => 'Attach files or images';

  @override
  String studentWithId(String id) {
    return 'Student #$id';
  }

  @override
  String get noStudentsPresent => 'No students present currently';

  @override
  String get noStudentsAbsent => 'No students absent currently';

  @override
  String get noStudentsInSection => 'No students in this class section';

  @override
  String get assignmentTitleHint => 'e.g. Solve exercises page 45...';

  @override
  String get assignmentDescHint => 'Write assignment details here...';

  @override
  String get assignmentSelectFiles => 'File and image selection will open.';

  @override
  String get assignmentSaveError =>
      'Please complete all fields and select class and subject.';

  @override
  String get assignmentSaveSuccess =>
      'Assignment added and notification sent to students and parents.';

  @override
  String get fileFormatHint => 'PDF, JPG, PNG (Max 10MB)';

  @override
  String get submissionStatusSubmitted => 'Submitted';

  @override
  String get submissionStatusLate => 'Late';

  @override
  String get submissionStatusNotSubmitted => 'Not Submitted';

  @override
  String homeworkLabel(String max) {
    return 'Homework ($max)';
  }

  @override
  String attendanceLabel(String max) {
    return 'Attendance ($max)';
  }

  @override
  String behaviorLabel(String max) {
    return 'Behavior ($max)';
  }

  @override
  String oralLabel(String max) {
    return 'Oral ($max)';
  }

  @override
  String writtenLabel(String max) {
    return 'Written ($max)';
  }

  @override
  String get assistantHome => 'Home';

  @override
  String get assistantClasses => 'My Classes & Students';

  @override
  String get assistantReports => 'Attendance Reports';

  @override
  String get assistantHistory => 'Attendance History';

  @override
  String studentsCount(int count) {
    return 'Students: $count';
  }

  @override
  String get attendanceStats => 'Daily Attendance Stats';

  @override
  String get quickTasks => 'Quick Tasks Access';

  @override
  String get totalTrackStudents => 'Total Track Students';

  @override
  String get cumulativeAttendanceRate => 'Cumulative Attendance Rate';

  @override
  String get dailyAttendance => 'Daily Attendance';

  @override
  String get dailyAbsence => 'Daily Absence';

  @override
  String get cumulativeAttendanceStats => 'Cumulative Student Attendance Stats';

  @override
  String get monaAlHarbi => 'Ms. Mona Al-Harbi';

  @override
  String get prepAssistant => 'Preparation Assistant';

  @override
  String recordDaysCount(int count) {
    return 'Record days: $count days';
  }

  @override
  String get prepAssistantDescription =>
      'Daily attendance & student checking supervisor';

  @override
  String get totalStudents => 'Total Students';

  @override
  String get presentToday => 'Present Today';

  @override
  String get absentToday => 'Absent Today';

  @override
  String get pending => 'Pending';

  @override
  String get scanQr => 'Scan QR Code';

  @override
  String get noMatchingResults => 'No matching results found';

  @override
  String civilIdLabel(String id) {
    return 'Civil ID: $id';
  }

  @override
  String get presentLabel => 'Present';

  @override
  String get absentLabel => 'Absent';

  @override
  String get attendanceDaysLabel => 'Attendance Days';

  @override
  String get absenceDaysLabel => 'Absence Days';

  @override
  String get sundayShort => 'Sun';

  @override
  String get mondayShort => 'Mon';

  @override
  String get tuesdayShort => 'Tue';

  @override
  String get wednesdayShort => 'Wed';

  @override
  String get thursdayShort => 'Thu';

  @override
  String get attendanceThisMonth => 'Attendance This Month';

  @override
  String get absenceThisMonth => 'Absence This Month';

  @override
  String get absentPlural => 'Absent';

  @override
  String get presentPlural => 'Present';

  @override
  String noAttendanceRecordForToday(String date) {
    return 'No attendance record registered for today:\n$date';
  }

  @override
  String get parentOrGuardian => 'Parent / Guardian';

  @override
  String get parentPhone => 'Parent Phone';

  @override
  String get contactWhatsApp => 'Contact via WhatsApp';

  @override
  String get details => 'Details';

  @override
  String get finishAndSendReport => 'Finish & Send Attendance Report';

  @override
  String get reportSentSuccess => 'Attendance report submitted successfully';

  @override
  String get reportSentFail =>
      'Failed to submit report, please try again later';

  @override
  String get attendanceSummary => 'Attendance Summary';

  @override
  String get confirmSendReport =>
      'Are you sure you want to finish and send the attendance report to the school administration? This action cannot be undone.';

  @override
  String get unmarked => 'Not Marked';

  @override
  String unmarkedWarning(int count) {
    return 'Warning: There are $count students whose attendance has not been marked.';
  }

  @override
  String get sendAndConfirm => 'Send & Confirm';

  @override
  String scanSuccess(String name) {
    return 'Student attendance registered successfully:\n$name';
  }

  @override
  String get qrScannerTitle => 'Student Attendance QR Scanner';

  @override
  String get pointCameraHint =>
      'Point the camera at the student\'s QR code printed on their smart card';

  @override
  String get scanSimPanel =>
      'Scan Simulation Panel (for testing/running without camera):';

  @override
  String get chooseStudentSim => 'Choose a student to simulate scan';

  @override
  String get simScanBtn => 'Simulate QR scan for selected student';
}
