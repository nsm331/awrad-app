import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awrad_app/presentation/blocs/tasbeeh/tasbeeh_cubit.dart';
import 'package:awrad_app/presentation/blocs/tasbeeh/tasbeeh_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TasbeehCubit Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'awrad_tasbeeh_total_count': 10,
        'awrad_tasbeeh_target': 33,
        'awrad_tasbeeh_selected_index': 1,
      });
      prefs = await SharedPreferences.getInstance();
    });

    test('loads initial state correctly from SharedPreferences', () {
      final cubit = TasbeehCubit(prefs);

      expect(cubit.state.count, 0);
      expect(cubit.state.totalCount, 10);
      expect(cubit.state.target, 33);
      expect(cubit.state.selectedDhikrIndex, 1);
      expect(cubit.state.currentDhikr, kPresetTasbeehAdhkar[1]);
      expect(cubit.state.isTargetReached, false);
      expect(cubit.state.progress, 0.0);
    });

    test('increment increases count and totalCount, persists to prefs', () {
      final cubit = TasbeehCubit(prefs);

      final targetReached = cubit.increment();

      expect(targetReached, false);
      expect(cubit.state.count, 1);
      expect(cubit.state.totalCount, 11);
      expect(cubit.state.progress, closeTo(1 / 33, 0.001));
      expect(prefs.getInt('awrad_tasbeeh_total_count'), 11);
    });

    test('triggers targetReached when cycle completes', () {
      final cubit = TasbeehCubit(prefs);
      cubit.setTarget(3);

      expect(cubit.increment(), false); // count = 1
      expect(cubit.increment(), false); // count = 2
      expect(cubit.increment(), true); // count = 3 == target
      expect(cubit.state.isTargetReached, true);
      expect(cubit.state.progress, 1.0);
    });

    test('reset clears current count and target reached while preserving totalCount', () {
      final cubit = TasbeehCubit(prefs);
      cubit.increment();
      cubit.increment();
      expect(cubit.state.count, 2);

      cubit.reset();

      expect(cubit.state.count, 0);
      expect(cubit.state.isTargetReached, false);
      expect(cubit.state.totalCount, 12);
      expect(cubit.state.progress, 0.0);
    });

    test('resetTotal clears lifetime totalCount in state and prefs', () {
      final cubit = TasbeehCubit(prefs);
      expect(cubit.state.totalCount, 10);

      cubit.resetTotal();

      expect(cubit.state.totalCount, 0);
      expect(prefs.getInt('awrad_tasbeeh_total_count'), 0);
    });

    test('setTarget updates target and persists', () {
      final cubit = TasbeehCubit(prefs);
      cubit.setTarget(100);

      expect(cubit.state.target, 100);
      expect(prefs.getInt('awrad_tasbeeh_target'), 100);

      // Open / free count (target = 0)
      cubit.setTarget(0);
      expect(cubit.state.target, 0);
      expect(cubit.state.progress, 0.0);
    });

    test('selectDhikr updates selected Dhikr and persists', () {
      final cubit = TasbeehCubit(prefs);
      cubit.selectDhikr(4);

      expect(cubit.state.selectedDhikrIndex, 4);
      expect(cubit.state.currentDhikr, kPresetTasbeehAdhkar[4]);
      expect(prefs.getInt('awrad_tasbeeh_selected_index'), 4);
    });
  });
}
