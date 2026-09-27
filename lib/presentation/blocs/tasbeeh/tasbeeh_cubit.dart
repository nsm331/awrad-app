import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tasbeeh_state.dart';

const String _kPrefTasbeehTotal = 'awrad_tasbeeh_total_count';
const String _kPrefTasbeehTarget = 'awrad_tasbeeh_target';
const String _kPrefTasbeehSelected = 'awrad_tasbeeh_selected_index';

/// Cubit managing the free and targeted electronic Tasbeeh counter logic and persistence.
class TasbeehCubit extends Cubit<TasbeehState> {
  final SharedPreferences _prefs;

  TasbeehCubit(this._prefs) : super(_loadInitialState(_prefs));

  static TasbeehState _loadInitialState(SharedPreferences prefs) {
    final total = prefs.getInt(_kPrefTasbeehTotal) ?? 0;
    final target = prefs.getInt(_kPrefTasbeehTarget) ?? 33;
    final selected = prefs.getInt(_kPrefTasbeehSelected) ?? 0;

    return TasbeehState(
      count: 0,
      target: target,
      selectedDhikrIndex: selected.clamp(0, kPresetTasbeehAdhkar.length - 1),
      totalCount: total,
    );
  }

  /// Increments the current counter and updates total lifetime count.
  /// Returns `true` if target cycle was reached on this tap.
  bool increment() {
    final newCount = state.count + 1;
    final newTotal = state.totalCount + 1;
    final targetReached = state.target > 0 && (newCount % state.target == 0);

    _prefs.setInt(_kPrefTasbeehTotal, newTotal);

    emit(state.copyWith(
      count: newCount,
      totalCount: newTotal,
      isTargetReached: targetReached,
    ));

    return targetReached;
  }

  /// Resets the current cycle counter to 0.
  void reset() {
    emit(state.copyWith(
      count: 0,
      isTargetReached: false,
    ));
  }

  /// Resets the lifetime total count to 0.
  void resetTotal() {
    _prefs.setInt(_kPrefTasbeehTotal, 0);
    emit(state.copyWith(totalCount: 0));
  }

  /// Updates the target cycle count (e.g. 33, 100, or 0 for free/open count).
  void setTarget(int target) {
    _prefs.setInt(_kPrefTasbeehTarget, target);
    final targetReached = target > 0 && (state.count > 0 && state.count % target == 0);
    emit(state.copyWith(
      target: target,
      isTargetReached: targetReached,
    ));
  }

  /// Selects a different Dhikr from the preset list.
  void selectDhikr(int index) {
    if (index >= 0 && index < kPresetTasbeehAdhkar.length) {
      _prefs.setInt(_kPrefTasbeehSelected, index);
      emit(state.copyWith(selectedDhikrIndex: index));
    }
  }
}
