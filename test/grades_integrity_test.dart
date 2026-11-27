import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anwarteacher/core/models/academic_grade.dart';
import 'package:anwarteacher/core/network/api_client.dart';
import 'package:anwarteacher/core/providers/classes_provider.dart';
import 'package:anwarteacher/core/providers/connectivity_provider.dart';
import 'package:anwarteacher/core/providers/grades_provider.dart';
import 'package:anwarteacher/core/providers/subjects_provider.dart';
import 'package:anwarteacher/core/services/grades_local_service.dart';

class _FakeClasses extends Classes {
  @override
  Map<String, String> get nameToIdMap => {'الصف الخامس - أ': '12'};
  @override
  List<String> build() => ['الصف الخامس - أ'];
}

class _FakeSelectedClass extends SelectedClass {
  @override
  String build() => 'الصف الخامس - أ';
}

class _FakeSubjects extends Subjects {
  @override
  Map<String, String> get nameToIdMap => {'الرياضيات': '5'};
  @override
  List<String> build() => ['الرياضيات'];
}

class _FakeSelectedSubject extends SelectedSubject {
  @override
  String build() => 'الرياضيات';
}

class _FakeConnectivity extends ConnectivityNotifier {
  @override
  ConnectivityStatus build() => ConnectivityStatus.online;
}

class _MockAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;
  _MockAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      handler(options);

  @override
  void close({bool force = false}) {}
}

StudentSubjectGrade _makeStudent(String id, String name, {double hw = 0, bool saved = false}) {
  return StudentSubjectGrade(
    studentId: id,
    studentName: name,
    subjectId: '5',
    firstTerm: TermRecord(
      termIndex: 1,
      months: [
        MonthRecord(monthIndex: 1, homework: hw, isSaved: saved),
        const MonthRecord(monthIndex: 2),
        const MonthRecord(monthIndex: 3),
      ],
    ),
    secondTerm: const TermRecord(
      termIndex: 2,
      months: [
        MonthRecord(monthIndex: 1),
        MonthRecord(monthIndex: 2),
        MonthRecord(monthIndex: 3),
      ],
    ),
  );
}

ProviderContainer _createContainer({
  required Future<ResponseBody> Function(RequestOptions options) onHttp,
  List<Map<String, dynamic>>? initialGradesJson,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local/api/'));
  dio.httpClientAdapter = _MockAdapter(onHttp);

  return ProviderContainer(
    overrides: [
      apiClientProvider.overrideWithValue(dio),
      classesProvider.overrideWith(() => _FakeClasses()),
      selectedClassProvider.overrideWith(() => _FakeSelectedClass()),
      subjectsProvider.overrideWith(() => _FakeSubjects()),
      selectedSubjectProvider.overrideWith(() => _FakeSelectedSubject()),
      connectivityProvider.overrideWith(() => _FakeConnectivity()),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('1. Updating grade from positive (15) to 0 sends 0 in bulk payload', () async {
    Map<String, dynamic>? capturedPostBody;

    final container = _createContainer(onHttp: (opts) async {
      if (opts.method == 'GET') {
        return ResponseBody.fromString(
          '{"success":true,"classId":"12","subjectId":"5","grades":['
          '{"studentId":"202671","studentName":"طالب 1","subjectId":"5",'
          '"firstTerm":{"termIndex":1,"months":[{"monthIndex":1,"homework":15,"attendance":0,"behavior":0,"oral":0,"written":0,"isSaved":true},{"monthIndex":2,"homework":0,"attendance":0,"behavior":0,"oral":0,"written":0,"isSaved":false},{"monthIndex":3,"homework":0,"attendance":0,"behavior":0,"oral":0,"written":0,"isSaved":false}],"finalExam":0,"isFinalSaved":false},'
          '"secondTerm":{"termIndex":2,"months":[{"monthIndex":1,"homework":0,"attendance":0,"behavior":0,"oral":0,"written":0,"isSaved":false},{"monthIndex":2,"homework":0,"attendance":0,"behavior":0,"oral":0,"written":0,"isSaved":false},{"monthIndex":3,"homework":0,"attendance":0,"behavior":0,"oral":0,"written":0,"isSaved":false}],"finalExam":0,"isFinalSaved":false}'
          '}]}',
          200,
          headers: {'content-type': ['application/json']},
        );
      }
      capturedPostBody = opts.data as Map<String, dynamic>;
      return ResponseBody.fromString(
        '{"success":true,"summary":{"total":1,"succeeded":1,"failed":0},'
        '"results":[{"index":0,"student_id":202671,"term":"1","month":"m1","success":true,"status":200}]}',
        200,
        headers: {'content-type': ['application/json']},
      );
    });
    addTearDown(container.dispose);

    final sub = container.listen(gradesDataProvider, (_, _) {});
    addTearDown(sub.close);
    for (int i = 0; i < 20 && container.read(gradesDataProvider).grades.isEmpty; i++) {
      await Future.delayed(const Duration(milliseconds: 25));
    }

    final current = container.read(gradesDataProvider).grades.first;
    final zeroed = current.copyWith(
      firstTerm: current.firstTerm.copyWith(
        months: [
          current.firstTerm.months[0].copyWith(homework: 0),
          current.firstTerm.months[1],
          current.firstTerm.months[2],
        ],
      ),
    );
    await container.read(gradesDataProvider.notifier).updateStudentGrade(
          '202671',
          zeroed,
          changedPeriodKey: '202671_1_m1',
        );

    final res = await container.read(gradesDataProvider.notifier).sendGradesToAdministration(
          selectedStudentIds: {'202671'},
        );

    expect(res.isSuccess, true);
    expect(capturedPostBody, isNotNull);
    final items = capturedPostBody!['items'] as List;
    expect(items.length, 1);
    expect(items.first['hw_grade'], 0.0);
    expect(container.read(gradesDataProvider).unsyncedStudentIds, isEmpty);
  });

  test('2. Handles 423, 422, 500, and timeout without swallowing errors or clearing draft', () async {
    for (final mode in ['423', '422', '500', 'timeout']) {
      SharedPreferences.setMockInitialValues({});
      final container = _createContainer(onHttp: (opts) async {
        if (opts.method == 'GET') {
          return ResponseBody.fromString(
            '{"success":true,"classId":"12","subjectId":"5","grades":['
            '{"studentId":"1","studentName":"طالب 1","subjectId":"5",'
            '"firstTerm":{"termIndex":1,"months":[{"monthIndex":1,"homework":0,"attendance":0,"behavior":0,"oral":0,"written":0,"isSaved":false}],"finalExam":0,"isFinalSaved":false},'
            '"secondTerm":{"termIndex":2,"months":[],"finalExam":0,"isFinalSaved":false}'
            '}]}',
            200,
            headers: {'content-type': ['application/json']},
          );
        }
        if (mode == 'timeout') {
          throw DioException(
            requestOptions: opts,
            type: DioExceptionType.receiveTimeout,
            message: 'Timeout',
          );
        }
        if (mode == '500') {
          throw DioException(
            requestOptions: opts,
            response: Response(requestOptions: opts, statusCode: 500),
            type: DioExceptionType.badResponse,
            message: 'Server Error 500',
          );
        }
        return ResponseBody.fromString(
          '{"success":false,"summary":{"total":1,"succeeded":0,"failed":1},'
          '"results":[{"index":0,"student_id":1,"term":"1","month":"m1","success":false,"status":$mode,"message":"خطأ $mode"}]}',
          mode == '422' ? 422 : 200,
          headers: {'content-type': ['application/json']},
        );
      });

      container.read(gradesDataProvider);
      await Future.delayed(const Duration(milliseconds: 50));

      await container.read(gradesDataProvider.notifier).updateStudentGrade(
            '1',
            _makeStudent('1', 'طالب 1', hw: 12),
            changedPeriodKey: '1_1_m1',
          );

      final res = await container.read(gradesDataProvider.notifier).sendGradesToAdministration(
            selectedStudentIds: {'1'},
          );

      expect(res.isSuccess, false, reason: 'Mode $mode must NOT report success');
      expect(res.isError, true, reason: 'Mode $mode must report error');
      expect(container.read(gradesDataProvider).unsyncedStudentIds, contains('1'),
          reason: 'Mode $mode must keep student unsynced');
      container.dispose();
    }
  });

  test('3. Sending selected students + partial failure keeps failed & unselected students unsynced', () async {
    List<dynamic>? sentItems;
    final container = _createContainer(onHttp: (opts) async {
      if (opts.method == 'GET') {
        return ResponseBody.fromString(
          '{"success":true,"classId":"12","subjectId":"5","grades":['
          '{"studentId":"1","studentName":"طالب 1","subjectId":"5","firstTerm":{"termIndex":1,"months":[{"monthIndex":1,"homework":0,"isSaved":false}],"finalExam":0},"secondTerm":{"termIndex":2,"months":[]}},'
          '{"studentId":"2","studentName":"طالب 2","subjectId":"5","firstTerm":{"termIndex":1,"months":[{"monthIndex":1,"homework":0,"isSaved":false}],"finalExam":0},"secondTerm":{"termIndex":2,"months":[]}},'
          '{"studentId":"3","studentName":"طالب 3","subjectId":"5","firstTerm":{"termIndex":1,"months":[{"monthIndex":1,"homework":0,"isSaved":false}],"finalExam":0},"secondTerm":{"termIndex":2,"months":[]}}'
          ']}',
          200,
          headers: {'content-type': ['application/json']},
        );
      }
      sentItems = (opts.data as Map<String, dynamic>)['items'] as List;
      // Student 1 succeeds, Student 2 fails (423), Student 3 was not selected
      return ResponseBody.fromString(
        '{"success":false,"summary":{"total":2,"succeeded":1,"failed":1},'
        '"results":['
        '{"index":0,"student_id":1,"term":"1","month":"m1","success":true,"status":200},'
        '{"index":1,"student_id":2,"term":"1","month":"m1","success":false,"status":423,"message":"مقفل"}'
        ']}',
        200,
        headers: {'content-type': ['application/json']},
      );
    });
    addTearDown(container.dispose);

    final sub = container.listen(gradesDataProvider, (_, _) {});
    addTearDown(sub.close);
    for (int i = 0; i < 20 && container.read(gradesDataProvider).grades.isEmpty; i++) {
      await Future.delayed(const Duration(milliseconds: 25));
    }

    final n = container.read(gradesDataProvider.notifier);
    await n.updateStudentGrade('1', _makeStudent('1', 'طالب 1', hw: 10), changedPeriodKey: '1_1_m1');
    await n.updateStudentGrade('2', _makeStudent('2', 'طالب 2', hw: 11), changedPeriodKey: '2_1_m1');
    await n.updateStudentGrade('3', _makeStudent('3', 'طالب 3', hw: 12), changedPeriodKey: '3_1_m1');

    final res = await n.sendGradesToAdministration(selectedStudentIds: {'1', '2'});

    expect(sentItems!.length, 2);
    expect(sentItems!.map((e) => e['student_id']), containsAll([1, 2]));
    expect(sentItems!.map((e) => e['student_id']), isNot(contains(3)));
    expect(res.isPartial, true);
    expect(res.succeededCount, 1);
    expect(res.failedCount, 1);
    final state = container.read(gradesDataProvider);
    expect(state.unsyncedStudentIds, isNot(contains('1')));
    expect(state.unsyncedStudentIds, containsAll(['2', '3']));
  });

  test('4. Editing a student during in-flight submission preserves the newer edit as unsynced', () async {
    final completer = Completer<ResponseBody>();
    final container = _createContainer(onHttp: (opts) async {
      if (opts.method == 'GET') {
        return ResponseBody.fromString(
          '{"success":true,"classId":"12","subjectId":"5","grades":['
          '{"studentId":"1","studentName":"طالب 1","subjectId":"5","firstTerm":{"termIndex":1,"months":[{"monthIndex":1,"homework":0,"isSaved":false}],"finalExam":0},"secondTerm":{"termIndex":2,"months":[]}}'
          ']}',
          200,
          headers: {'content-type': ['application/json']},
        );
      }
      return completer.future;
    });
    addTearDown(container.dispose);

    final sub = container.listen(gradesDataProvider, (_, _) {});
    addTearDown(sub.close);
    for (int i = 0; i < 20 && container.read(gradesDataProvider).grades.isEmpty; i++) {
      await Future.delayed(const Duration(milliseconds: 25));
    }

    final n = container.read(gradesDataProvider.notifier);
    await n.updateStudentGrade('1', _makeStudent('1', 'طالب 1', hw: 10), changedPeriodKey: '1_1_m1');

    final sendFuture = n.sendGradesToAdministration(selectedStudentIds: {'1'});
    await Future.delayed(const Duration(milliseconds: 20));

    // Concurrent edit while request is in flight!
    await n.updateStudentGrade('1', _makeStudent('1', 'طالب 1', hw: 14), changedPeriodKey: '1_1_m1');

    completer.complete(ResponseBody.fromString(
      '{"success":true,"summary":{"total":1,"succeeded":1,"failed":0},'
      '"results":[{"index":0,"student_id":1,"term":"1","month":"m1","success":true,"status":200}]}',
      200,
      headers: {'content-type': ['application/json']},
    ));

    await sendFuture;

    final state = container.read(gradesDataProvider);
    expect(state.grades.first.firstTerm.months.first.homework, 14.0);
    expect(state.unsyncedStudentIds, contains('1'));
    expect(state.hasUnsyncedChanges, true);
  });

  test('5. Disposing provider before 350ms debounce flushes last edit to local storage', () async {
    final container = _createContainer(onHttp: (opts) async {
      return ResponseBody.fromString(
        '{"success":true,"classId":"12","subjectId":"5","grades":['
        '{"studentId":"1","studentName":"طالب 1","subjectId":"5","firstTerm":{"termIndex":1,"months":[{"monthIndex":1,"homework":0,"isSaved":false}],"finalExam":0},"secondTerm":{"termIndex":2,"months":[]}}'
        ']}',
        200,
        headers: {'content-type': ['application/json']},
      );
    });

    final sub = container.listen(gradesDataProvider, (_, _) {});
    addTearDown(sub.close);
    for (int i = 0; i < 20 && container.read(gradesDataProvider).grades.isEmpty; i++) {
      await Future.delayed(const Duration(milliseconds: 25));
    }

    await container.read(gradesDataProvider.notifier).updateStudentGrade(
          '1',
          _makeStudent('1', 'طالب 1', hw: 13),
          changedPeriodKey: '1_1_m1',
        );

    // Immediately dispose BEFORE 350ms debounce!
    container.dispose();
    await Future.delayed(const Duration(milliseconds: 30));

    final cached = await GradesLocalService.getCachedGrades('12', '5');
    expect(cached, isNotNull);
    expect(cached!.grades.first.firstTerm.months.first.homework, 13.0);
    expect(cached.unsyncedStudentIds, contains('1'));
  });
}
