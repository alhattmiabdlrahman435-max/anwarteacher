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

class _FakeClasses extends Classes {
  @override
  Map<String, String> get nameToIdMap => {'الصف الثامن - أ': '12'};
  @override
  List<String> build() => ['الصف الثامن - أ'];
}

class _FakeSelectedClass extends SelectedClass {
  @override
  String build() => 'الصف الثامن - أ';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('TermRecord distinguishes null, 0.0, and positive finalExam', () {
    final tNull = TermRecord.fromMap({'termIndex': 1, 'months': [], 'finalExam': null, 'isFinalSaved': false});
    expect(tNull.finalExam, isNull);
    expect(tNull.isFinalSaved, false);
    expect(tNull.termTotal, 0.0);

    final tZero = TermRecord.fromMap({'termIndex': 1, 'months': [], 'finalExam': 0, 'isFinalSaved': true});
    expect(tZero.finalExam, 0.0);
    expect(tZero.isFinalSaved, true);
    expect(tZero.termTotal, 0.0);

    final tPos = TermRecord.fromMap({'termIndex': 1, 'months': [], 'finalExam': 25.5, 'isFinalSaved': true});
    expect(tPos.finalExam, 25.5);
    expect(tPos.isFinalSaved, true);
    expect(tPos.termTotal, 25.5);
  });

  test('Clearing finalExam sends null in bulk and keeps isFinalSaved=false; saving 0 sends 0.0', () async {
    final List<Map<String, dynamic>> capturedPayloads = [];
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local/api/'));
    dio.httpClientAdapter = _MockAdapter((opts) async {
      if (opts.method == 'GET') {
        return ResponseBody.fromString(
          '{"success":true,"classId":"12","subjectId":"5","grades":['
          '{"studentId":"1","studentName":"طالب 1","subjectId":"5","firstTerm":{"termIndex":1,"months":[],"finalExam":20,"isFinalSaved":true},"secondTerm":{"termIndex":2,"months":[],"finalExam":null,"isFinalSaved":false}},'
          '{"studentId":"2","studentName":"طالب 2","subjectId":"5","firstTerm":{"termIndex":1,"months":[],"finalExam":null,"isFinalSaved":false},"secondTerm":{"termIndex":2,"months":[],"finalExam":null,"isFinalSaved":false}}'
          ']}',
          200,
          headers: {'content-type': ['application/json']},
        );
      }
      final body = opts.data as Map<String, dynamic>;
      capturedPayloads.add(body);
      final items = body['items'] as List;
      final results = [
        for (int i = 0; i < items.length; i++)
          {'index': i, 'student_id': items[i]['student_id'], 'term': items[i]['term'], 'month': items[i]['month'], 'success': true, 'status': 200}
      ];
      return ResponseBody.fromString(
        '{"success":true,"summary":{"total":${items.length},"succeeded":${items.length},"failed":0},"results":${results.map((r) => '{"index":${r['index']},"student_id":${r['student_id']},"term":"${r['term']}","month":"${r['month']}","success":true,"status":200}').toList()}}',
        200,
        headers: {'content-type': ['application/json']},
      );
    });

    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(dio),
        classesProvider.overrideWith(() => _FakeClasses()),
        selectedClassProvider.overrideWith(() => _FakeSelectedClass()),
        subjectsProvider.overrideWith(() => _FakeSubjects()),
        selectedSubjectProvider.overrideWith(() => _FakeSelectedSubject()),
        connectivityProvider.overrideWith(() => _FakeConnectivity()),
      ],
    );
    addTearDown(container.dispose);

    final sub = container.listen(gradesDataProvider, (_, _) {});
    addTearDown(sub.close);
    await Future.delayed(const Duration(milliseconds: 50));

    final notifier = container.read(gradesDataProvider.notifier);
    final grades = container.read(gradesDataProvider).grades;

    // 1. Clear student 1 finalExam -> null
    final s1Cleared = grades[0].copyWith(
      firstTerm: grades[0].firstTerm.copyWith(clearFinalExam: true, isFinalSaved: false),
    );
    await notifier.updateStudentGrade('1', s1Cleared, changedPeriodKey: '1_1_final');

    // 2. Set student 2 finalExam -> 0.0
    final s2Zero = grades[1].copyWith(
      firstTerm: grades[1].firstTerm.copyWith(finalExam: 0.0),
    );
    await notifier.updateStudentGrade('2', s2Zero, changedPeriodKey: '2_1_final');

    final res = await notifier.sendGradesToAdministration(selectedStudentIds: {'1', '2'});
    expect(res.isSuccess, true);
    expect(capturedPayloads.length, 1);
    final sentItems = capturedPayloads.first['items'] as List;
    expect(sentItems.length, 2);
    expect(sentItems[0]['final_exam'], isNull);
    expect(sentItems[1]['final_exam'], 0.0);

    final after = container.read(gradesDataProvider).grades;
    expect(after[0].firstTerm.finalExam, isNull);
    expect(after[0].firstTerm.isFinalSaved, false);
    expect(after[1].firstTerm.finalExam, 0.0);
    expect(after[1].firstTerm.isFinalSaved, true);
  });
}
