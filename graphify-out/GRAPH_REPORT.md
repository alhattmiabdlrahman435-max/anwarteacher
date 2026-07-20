# Graph Report - .  (2026-07-13)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 2384 nodes · 2974 edges · 133 communities (91 shown, 42 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `53952a2f`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Community 0
- Community 1
- Community 2
- Community 3
- Community 4
- Community 5
- Community 6
- Community 7
- Community 8
- Community 9
- Community 10
- Community 11
- Community 12
- Community 13
- Community 14
- Community 15
- Community 16
- Community 17
- Community 18
- Community 19
- Community 20
- Community 21
- Community 22
- Community 23
- Community 24
- Community 25
- Community 26
- Community 27
- Community 28
- Community 29
- Community 30
- Community 31
- Community 32
- Community 33
- Community 34
- Community 35
- Community 36
- Community 37
- Community 38
- Community 39
- Community 40
- Community 41
- Community 42
- Community 43
- Community 44
- Community 45
- Community 46
- Community 47
- Community 48
- Community 49
- Community 50
- Community 51
- Community 52
- Community 53
- Community 54
- Community 55
- Community 56
- Community 57
- Community 58
- Community 59
- Community 60
- Community 61
- Community 62
- Community 63
- Community 64
- Community 65
- Community 66
- Community 67
- Community 68
- Community 69
- Community 70
- Community 71
- Community 72
- Community 73
- Community 74
- Community 75
- Community 76
- Community 77
- Community 78
- Community 79
- Community 80
- Community 81
- Community 82
- Community 83
- Community 84
- Community 85
- Community 86
- Community 87
- Community 88
- Community 89
- Community 90
- Community 91
- Community 95
- Community 96
- Community 97
- Community 98
- Community 99
- Community 100
- Community 101
- Community 102
- Community 103
- Community 104
- Community 105
- Community 106
- Community 107
- Community 108
- Community 109
- Community 110
- Community 111
- Community 112
- Community 113
- Community 114
- Community 115
- Community 116
- Community 117
- Community 118
- Community 119
- Community 120
- Community 121
- Community 122
- Community 123
- Community 124
- Community 125
- Community 126
- Community 127
- Community 128
- Community 129
- Community 130
- Community 131
- Community 132

## God Nodes (most connected - your core abstractions)
1. `build` - 8 edges
2. `AppLocalizations` - 7 edges
3. `_TeacherAppState` - 6 edges
4. `AppDelegate` - 5 edges
5. `GradesData` - 5 edges
6. `_AddAssignmentScreenState` - 5 edges
7. `build` - 5 edges
8. `build` - 5 edges
9. `GeneratedPluginRegistrant` - 4 edges
10. `apiClient` - 4 edges

## Surprising Connections (you probably didn't know these)
- `apiClient` --references--> `serverErrorProvider`  [EXTRACTED]
  lib/core/network/api_client.dart → lib/core/providers/server_error_provider.g.dart
- `AppLocalizationsAr` --inherits--> `AppLocalizations`  [EXTRACTED]
  lib/l10n/app_localizations_ar.dart → lib/l10n/app_localizations.dart
- `AppLocalizationsEn` --inherits--> `AppLocalizations`  [EXTRACTED]
  lib/l10n/app_localizations_en.dart → lib/l10n/app_localizations.dart
- `build` --references--> `connectivityProvider`  [EXTRACTED]
  lib/core/widgets/connectivity_overlay.dart → lib/core/providers/connectivity_provider.g.dart
- `ConnectivityOverlay` --references--> `connectivityProvider`  [EXTRACTED]
  lib/core/widgets/connectivity_overlay.dart → lib/core/providers/connectivity_provider.g.dart

## Import Cycles
- None detected.

## Communities (133 total, 42 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.01
Nodes (272): app_localizations_ar.dart, app_localizations_en.dart, aboutApp, absenceDays, absenceDaysLabel, absenceRequest, absenceRequestSentSuccessfully, absenceThisMonth (+264 more)

### Community 1 - "Community 1"
Cohesion: 0.01
Nodes (261): app_localizations.dart, aboutApp, absenceDays, absenceDaysLabel, absenceRequest, absenceRequestSentSuccessfully, absenceThisMonth, absent (+253 more)

### Community 2 - "Community 2"
Cohesion: 0.01
Nodes (260): aboutApp, absenceDays, absenceDaysLabel, absenceRequest, absenceRequestSentSuccessfully, absenceThisMonth, absent, absentLabel (+252 more)

### Community 3 - "Community 3"
Cohesion: 0.06
Nodes (34): app_colors.dart, app_spacing.dart, app_typography.dart, _, ../extensions/localization_extension.dart, AppTheme, AdaptiveSliverAppBar, automaticallyImplyLeading (+26 more)

### Community 4 - "Community 4"
Cohesion: 0.05
Nodes (39): ../../../core/utils/constants.dart, absentCount, absentToday, AttendanceHistoryRecord, attendancePercentage, attendanceRate, AttendanceStatus, attendedStudents (+31 more)

### Community 5 - "Community 5"
Cohesion: 0.05
Nodes (38): AppRouterProvider, create, debugGetCreateSourceHash, overrideWithValue, ChangeNotifier, ../../features/assignments/presentation/screens/add_assignment_screen.dart, ../../features/assignments/presentation/screens/assignments_screen.dart, ../../features/assignments/presentation/screens/submissions_tracking_screen.dart (+30 more)

### Community 6 - "Community 6"
Cohesion: 0.06
Nodes (38): _DailyDetailCard, _EmptyRecordCard, _HeaderSummaryCard, _StatusBox, _StudentDetailsModal, _StudentHistoryCard, _ConfirmationDialog, _StudentDetailsModal (+30 more)

### Community 7 - "Community 7"
Cohesion: 0.06
Nodes (34): accent, accentGradient, AppColors, backgroundDark, border, brandGradient, cardDark, dangerRed (+26 more)

### Community 8 - "Community 8"
Cohesion: 0.06
Nodes (32): _, AuthProvider, create, debugGetCreateSourceHash, overrideWithValue, runBuild, Auth, AuthState (+24 more)

### Community 9 - "Community 9"
Cohesion: 0.06
Nodes (32): _animationController, build, child, _controller, createState, dispose, fadeAnimation, _fadeAnimations (+24 more)

### Community 10 - "Community 10"
Cohesion: 0.06
Nodes (28): ../config/app_config.dart, dart:io, activityTimeout, AppConfig, baseUrl, isEncrypted, isLocal, reverbAppKey (+20 more)

### Community 11 - "Community 11"
Cohesion: 0.06
Nodes (30): double get, attendance, behavior, classId, copyWith, finalExam, firstTerm, fromMap (+22 more)

### Community 12 - "Community 12"
Cohesion: 0.07
Nodes (29): AttendanceHistoryEntity, bgColor, _buildCalendarHeader, _buildClassesSliverList, _buildClassHistoryContent, _buildCustomCalendar, _buildInfoRow, _buildStudentsSliverList (+21 more)

### Community 13 - "Community 13"
Cohesion: 0.07
Nodes (29): StudentEntity, absentCount, _AttendanceButton, build, _buildAttendanceButtons, _buildBottomBar, _buildInfoRow, _buildStatCard (+21 more)

### Community 14 - "Community 14"
Cohesion: 0.07
Nodes (27): adjustToSchoolDay, arabic, build, _buildGridDays, createState, _currentMonth, date, dispose (+19 more)

### Community 15 - "Community 15"
Cohesion: 0.07
Nodes (27): StudentReportEntity, AssistantReportsScreen, _AssistantReportsScreenState, build, _buildCalendarDay, _buildCalendarHeader, _buildCustomCalendar, _buildSearchBar (+19 more)

### Community 16 - "Community 16"
Cohesion: 0.07
Nodes (26): ../../../../core/models/academic_grade.dart, ../../../../core/widgets/class_subject_selector.dart, build, _buildFilterChip, _buildFilters, _buildLabeledInput, _buildMonthInputs, _buildReadOnlyBox (+18 more)

### Community 17 - "Community 17"
Cohesion: 0.07
Nodes (26): ../../../../core/models/attendance.dart, ../../../../core/providers/attendance_provider.dart, _attachedImagePath, build, _buildClassDropdown, _buildDetailsField, _buildImageSection, _buildSectionLabel (+18 more)

### Community 18 - "Community 18"
Cohesion: 0.07
Nodes (26): ../../../../core/providers/settings_provider.dart, build, _buildSegment, children, createState, _Divider, icon, leftIcon (+18 more)

### Community 19 - "Community 19"
Cohesion: 0.08
Nodes (26): CustomPainter, AssistantQrScannerScreen, _AssistantQrScannerScreenState, borderRadius, build, _buildCorner, _buildFloatingActionButton, createState (+18 more)

### Community 20 - "Community 20"
Cohesion: 0.07
Nodes (26): AttendanceFilter, build, _buildGridDays, _buildLegendItem, _buildStatItem, _buildStatsBar, _buildStudentCard, createState (+18 more)

### Community 21 - "Community 21"
Cohesion: 0.08
Nodes (25): AndroidFlutterLocalNotificationsPlugin, AndroidNotificationChannel, core/network/pusher_service.dart, core/providers/exams_provider.dart, ../../../../core/providers/grades_provider.dart, core/routing/app_router.dart, core/theme/app_theme.dart, core/widgets/connectivity_overlay.dart (+17 more)

### Community 22 - "Community 22"
Cohesion: 0.08
Nodes (24): BoxFit, double?, activity, classId, copyWith, finalExam, GradeEntry, grades (+16 more)

### Community 23 - "Community 23"
Cohesion: 0.08
Nodes (24): ../../../../core/widgets/adaptive_sliver_app_bar.dart, ../../../../core/widgets/app_drawer.dart, ../../../../core/widgets/empty_state_widget.dart, ClassroomEntity, build, _ClassCard, classroom, _ActionCard (+16 more)

### Community 24 - "Community 24"
Cohesion: 0.08
Nodes (24): ../../../../core/models/report.dart, ../../../../core/providers/reports_provider.dart, ../../../../core/theme/app_typography.dart, build, _buildReportCard, _buildReportsList, _buildTab, _bytesFromBase64 (+16 more)

### Community 25 - "Community 25"
Cohesion: 0.16
Nodes (22): @Riverpod, classesProvider, DailyAttendance, dailyAttendanceProvider, Classes, selectedClassProvider, SelectedClass, gradesDataProvider (+14 more)

### Community 26 - "Community 26"
Cohesion: 0.09
Nodes (23): ../../../../core/providers/classes_provider.dart, _address, _addressController, build, _buildEditableRow, _buildSectionLabel, createState, dispose (+15 more)

### Community 27 - "Community 27"
Cohesion: 0.09
Nodes (22): _, call, create, DailyAttendanceFamily, DailyAttendanceProvider, date, debugGetCreateSourceHash, extends (+14 more)

### Community 28 - "Community 28"
Cohesion: 0.09
Nodes (21): ../../../../core/providers/subjects_provider.dart, ../../../../core/widgets/app_notification.dart, ../../../../core/widgets/modern_dropdown.dart, ../../../../core/widgets/school_date_picker.dart, _buildAttachmentButton, _buildAttachmentOptionCard, _buildDateSelector, _contentController (+13 more)

### Community 29 - "Community 29"
Cohesion: 0.09
Nodes (20): IconData, AppNotificationModel, copyWith, date, icon, iconColor, id, isRead (+12 more)

### Community 30 - "Community 30"
Cohesion: 0.10
Nodes (20): FormState, build, _buildContactRow, _buildFormTextField, _buildSectionTitle, _buildTypeSegment, ContactUsScreen, _ContactUsScreenState (+12 more)

### Community 31 - "Community 31"
Cohesion: 0.10
Nodes (20): AppNotification, AppNotificationType, build, _controller, createState, _currentEntry, dismiss, _dismissTimer (+12 more)

### Community 32 - "Community 32"
Cohesion: 0.11
Nodes (14): Any, Bool, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterSceneDelegate, AppDelegate (+6 more)

### Community 33 - "Community 33"
Cohesion: 0.11
Nodes (19): _, ChildrenProvider, create, CurrentChildProvider, debugGetCreateSourceHash, overrideWithValue, runBuild, childrenProvider (+11 more)

### Community 34 - "Community 34"
Cohesion: 0.10
Nodes (19): _, create, debugGetCreateSourceHash, overrideWithValue, runBuild, SettingsProvider, AppSettings, copyWith (+11 more)

### Community 35 - "Community 35"
Cohesion: 0.10
Nodes (19): _, AssistantClassDetailsFamily, AssistantClassDetailsProvider, call, classId, create, debugGetCreateSourceHash, operator (+11 more)

### Community 36 - "Community 36"
Cohesion: 0.11
Nodes (18): academic,
  behavioral,
  homework,, className, copyWith, createdAt, description, id, imageUrl, psychological (+10 more)

### Community 37 - "Community 37"
Cohesion: 0.11
Nodes (18): assistant_class_details_provider.dart, assistant_classes_provider.dart, AssistantDashboardStatsProvider, create, debugGetCreateSourceHash, overrideWithValue, absent, absentToday (+10 more)

### Community 38 - "Community 38"
Cohesion: 0.15
Nodes (19): ConsumerState, ConsumerStatefulWidget, AddAssignmentScreen, AssistantAttendanceHistoryScreen, _AssistantAttendanceHistoryScreenState, AssistantDashboardScreen, _AssistantDashboardScreenState, AttendanceScreen (+11 more)

### Community 39 - "Community 39"
Cohesion: 0.11
Nodes (18): ConsumerWidget, ../../../../core/providers/notifications_provider.dart, AppDrawer, badgeCount, currentRoute, _DrawerItem, icon, isDark (+10 more)

### Community 40 - "Community 40"
Cohesion: 0.11
Nodes (17): EdgeInsetsGeometry?, build, EmptyStateWidget, icon, message, onRetry, backgroundColor, borderColor (+9 more)

### Community 41 - "Community 41"
Cohesion: 0.11
Nodes (18): Assignment, attachments, classId, content, copyWith, dateCreated, dueDate, id (+10 more)

### Community 42 - "Community 42"
Cohesion: 0.11
Nodes (17): _, ConnectivityNotifierProvider, create, debugGetCreateSourceHash, overrideWithValue, runBuild, Connectivity, connectivityNotifierProvider (+9 more)

### Community 43 - "Community 43"
Cohesion: 0.13
Nodes (15): connectivityProvider, _, create, debugGetCreateSourceHash, overrideWithValue, runBuild, ServerErrorNotifierProvider, serverErrorProvider (+7 more)

### Community 44 - "Community 44"
Cohesion: 0.12
Nodes (15): _, create, debugGetCreateSourceHash, NotificationsProvider, overrideWithValue, runBuild, addNotification, build (+7 more)

### Community 45 - "Community 45"
Cohesion: 0.13
Nodes (15): ../../../../core/models/teacher_schedule.dart, ../../../../core/providers/schedule_provider.dart, build, createState, _daysKeys, _determineInitialDay, _getDayTranslation, _getPeriodColor (+7 more)

### Community 46 - "Community 46"
Cohesion: 0.13
Nodes (14): auth_provider.dart, _, create, debugGetCreateSourceHash, extends, runBuild, TeacherScheduleStateProvider, class TeacherScheduleStateProvider (+6 more)

### Community 47 - "Community 47"
Cohesion: 0.13
Nodes (14): _, create, debugGetCreateSourceHash, ExamsProvider, overrideWithValue, runBuild, examsProvider, build (+6 more)

### Community 48 - "Community 48"
Cohesion: 0.13
Nodes (14): _, create, debugGetCreateSourceHash, overrideWithValue, ReportsProvider, runBuild, addReport, build (+6 more)

### Community 49 - "Community 49"
Cohesion: 0.14
Nodes (14): DateTime, date, ExamPeriod, ExamPeriodExt, ExamSchedule, ExamSubject, ExamTerm, id (+6 more)

### Community 50 - "Community 50"
Cohesion: 0.13
Nodes (14): _buildSnackBar, scaffoldMessengerKey, _show, showError, showErrorContext, showInfo, showInfoContext, showSuccess (+6 more)

### Community 51 - "Community 51"
Cohesion: 0.14
Nodes (13): _, ClassesProvider, create, debugGetCreateSourceHash, overrideWithValue, runBuild, SelectedClassProvider, _classToSubjectsMap (+5 more)

### Community 52 - "Community 52"
Cohesion: 0.14
Nodes (13): _, create, debugGetCreateSourceHash, GradesDataProvider, overrideWithValue, runBuild, classes_provider.dart, ClassSubjectGrades (+5 more)

### Community 53 - "Community 53"
Cohesion: 0.14
Nodes (13): _, AssistantAttendanceHistoryProvider, create, debugGetCreateSourceHash, extends, overrideWithValue, runBuild, class AssistantAttendanceHistoryProvider (+5 more)

### Community 54 - "Community 54"
Cohesion: 0.14
Nodes (13): _, AssistantClassesProvider, create, debugGetCreateSourceHash, overrideWithValue, runBuild, ../../../../core/providers/auth_provider.dart, AssistantClasses (+5 more)

### Community 55 - "Community 55"
Cohesion: 0.14
Nodes (13): _, AssistantReportsProvider, create, debugGetCreateSourceHash, overrideWithValue, runBuild, ../../../../core/network/api_client.dart, AttendanceStatsEntity (+5 more)

### Community 56 - "Community 56"
Cohesion: 0.15
Nodes (13): ../../../../core/widgets/modern_text_field.dart, ../../../../core/widgets/student_avatar.dart, assignmentId, build, _buildStatColumn, _buildStatusOption, _buildStudentCard, createState (+5 more)

### Community 57 - "Community 57"
Cohesion: 0.14
Nodes (13): build, controller, hint, icon, isDark, keyboardType, label, maxLines (+5 more)

### Community 58 - "Community 58"
Cohesion: 0.14
Nodes (13): build, createState, didChangeDependencies, dispose, _onScroll, _position, _removeListener, _setupListener (+5 more)

### Community 59 - "Community 59"
Cohesion: 0.17
Nodes (12): Animation, AnimationController, build, _controller, createState, dispose, _fadeAnimation, _navigationTimer (+4 more)

### Community 60 - "Community 60"
Cohesion: 0.15
Nodes (12): ApiClientProvider, create, debugGetCreateSourceHash, overrideWithValue, Dio, apiClient, apiClientProvider, dio (+4 more)

### Community 61 - "Community 61"
Cohesion: 0.13
Nodes (14): _, AssignmentsDataProvider, create, debugGetCreateSourceHash, overrideWithValue, runBuild, addAssignment, AssignmentsData (+6 more)

### Community 62 - "Community 62"
Cohesion: 0.15
Nodes (12): create, CurrentParentProvider, debugGetCreateSourceHash, overrideWithValue, currentParentProvider, avatarUrl, currentParent, id (+4 more)

### Community 63 - "Community 63"
Cohesion: 0.15
Nodes (12): _, create, debugGetCreateSourceHash, overrideWithValue, runBuild, SelectedSubjectProvider, SubjectsProvider, _fetchForClass (+4 more)

### Community 64 - "Community 64"
Cohesion: 0.17
Nodes (11): AttendanceStatus, AttendanceRecord, AttendanceStatus, copyWith, date, id, note, status (+3 more)

### Community 65 - "Community 65"
Cohesion: 0.18
Nodes (11): ../../../../core/models/assignment.dart, ../../../../core/providers/assignments_provider.dart, ../../../../core/widgets/app_sliver_header.dart, AssignmentsScreen, _AssignmentsScreenState, build, _buildAssignmentCard, createState (+3 more)

### Community 66 - "Community 66"
Cohesion: 0.18
Nodes (10): _, AppSpacing, lg, md, sm, xl, xs, xxl (+2 more)

### Community 67 - "Community 67"
Cohesion: 0.20
Nodes (10): ../../../../core/theme/app_spacing.dart, ../../../../core/widgets/modern_card.dart, build, _buildNotificationCard, createState, _formatDate, initState, NotificationsScreen (+2 more)

### Community 68 - "Community 68"
Cohesion: 0.20
Nodes (9): dart:convert, dart:typed_data, avatarLabel, bytesFromBase64, getImageProvider, isBase64Image, isNetworkUrl, null (+1 more)

### Community 69 - "Community 69"
Cohesion: 0.20
Nodes (9): classId, copyWith, fromMap, id, name, Student, subjectIds, toMap (+1 more)

### Community 70 - "Community 70"
Cohesion: 0.27
Nodes (10): _SchoolDatePickerDialog, _SchoolDatePickerDialogState, StartAlignedCollapsingTitle, _StartAlignedCollapsingTitleState, _StudentAttendanceModal, _StudentAttendanceModalState, GradeEntrySheet, _GradeEntrySheetState (+2 more)

### Community 71 - "Community 71"
Cohesion: 0.22
Nodes (8): Color, backgroundColor, build, isSelected, name, photoUrl, size, StudentAvatar

### Community 72 - "Community 72"
Cohesion: 0.25
Nodes (7): ../../../../core/extensions/localization_extension.dart, ../../../../core/theme/app_colors.dart, AboutAppScreen, build, build, _buildPolicySection, PrivacyPolicyScreen

### Community 73 - "Community 73"
Cohesion: 0.22
Nodes (8): classIds, copyWith, fromMap, id, name, subjectIds, Teacher, toMap

### Community 74 - "Community 74"
Cohesion: 0.28
Nodes (7): build, NotFoundScreen, build, NotFoundScreen, package:flutter/material.dart, package:go_router/go_router.dart, Route /

### Community 75 - "Community 75"
Cohesion: 0.22
Nodes (9): build, main, Route /assignments, Route /attendance, Route /grades, Route /notifications, Route /reports, Route /schedule (+1 more)

### Community 76 - "Community 76"
Cohesion: 0.25
Nodes (7): AppLocalizations get, BuildContext, ../../l10n/app_localizations.dart, loc, LocalizationExtension, toArabicNumbers, translateMock

### Community 77 - "Community 77"
Cohesion: 0.33
Nodes (4): FlutterLocalNotificationsPlugin, GeneratedPluginRegistrant, +registerWithRegistry, NSObject

### Community 78 - "Community 78"
Cohesion: 0.29
Nodes (6): className, endTime, fromJson, startTime, subjectName, TeacherPeriod

### Community 79 - "Community 79"
Cohesion: 0.33
Nodes (7): build, build, _login, initState, Route /assistant/dashboard, Route /dashboard, Route /login

### Community 80 - "Community 80"
Cohesion: 0.29
Nodes (6): android, DefaultFirebaseOptions, ios, package:firebase_core/firebase_core.dart, package:flutter/foundation.dart, static const FirebaseOptions

### Community 81 - "Community 81"
Cohesion: 0.33
Nodes (5): dart:async, DebounceUtil, run, _timer, static Timer?

### Community 82 - "Community 82"
Cohesion: 0.33
Nodes (5): handle_new_rx_page(), __lldb_init_module(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages., SBDebugger, SBFrame

### Community 83 - "Community 83"
Cohesion: 0.40
Nodes (6): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsAr, AppLocalizationsEn, of, LocalizationsDelegate

### Community 84 - "Community 84"
Cohesion: 0.60
Nodes (3): GeneratedPluginRegistrant, FlutterEngine, Keep

### Community 85 - "Community 85"
Cohesion: 0.60
Nodes (3): gradlew script, die(), warn()

### Community 86 - "Community 86"
Cohesion: 0.40
Nodes (5): _NotificationOverlay, _NotificationOverlayState, _RoleCard, _RoleCardState, SingleTickerProviderStateMixin

### Community 88 - "Community 88"
Cohesion: 0.67
Nodes (3): TeacherApp, _TeacherAppState, WidgetsBindingObserver

## Knowledge Gaps
- **1805 isolated node(s):** `flutter_export_environment.sh script`, `XCTest`, `+registerWithRegistry`, `AppConfig`, `isLocal` (+1800 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **42 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `main` connect `Community 75` to `Community 21`?**
  _High betweenness centrality (0.010) - this node is a cross-community bridge._
- **Why does `StudentEntity` connect `Community 13` to `Community 4`, `Community 12`?**
  _High betweenness centrality (0.004) - this node is a cross-community bridge._
- **What connects `flutter_export_environment.sh script`, `XCTest`, `+registerWithRegistry` to the rest of the system?**
  _1805 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.007326007326007326 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.007633587786259542 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.007662835249042145 - nodes in this community are weakly interconnected._
- **Should `Community 3` be split into smaller, more focused modules?**
  _Cohesion score 0.06282051282051282 - nodes in this community are weakly interconnected._