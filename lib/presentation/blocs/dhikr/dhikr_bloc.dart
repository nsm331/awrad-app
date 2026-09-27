import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/sub_category.dart';
import '../../../domain/repositories/dhikr_repository.dart';
import '../../../domain/repositories/statistics_repository.dart';
import 'dhikr_event.dart';
import 'dhikr_state.dart';

/// BLoC managing the interactive counting engine, chapter progression,
/// and automated streak logging for Dhikr sessions.
class DhikrBloc extends Bloc<DhikrEvent, DhikrState> {
  final DhikrRepository _dhikrRepository;
  final StatisticsRepository _statsRepository;

  DhikrBloc({
    required DhikrRepository dhikrRepository,
    required StatisticsRepository statsRepository,
  })  : _dhikrRepository = dhikrRepository,
        _statsRepository = statsRepository,
        super(const DhikrState()) {
    on<LoadDhikrList>(_onLoadDhikrList);
    on<IncrementCounter>(_onIncrementCounter);
    on<ResetDhikrSession>(_onResetDhikrSession);
    on<PreviousDhikr>(_onPreviousDhikr);
    on<NextDhikr>(_onNextDhikr);
    on<JumpToDhikr>(_onJumpToDhikr);
  }

  Future<void> _onLoadDhikrList(
    LoadDhikrList event,
    Emitter<DhikrState> emit,
  ) async {
    emit(state.copyWith(status: DhikrStatus.loading));

    SubCategory? subCat = event.subCategory;
    if (subCat == null) {
      final subCatResult = await _dhikrRepository.getSubCategoryById(event.subCategoryId);
      if (subCatResult is Success<SubCategory>) {
        subCat = subCatResult.data;
      }
    }

    final itemsResult = await _dhikrRepository.getDhikrItemsBySubCategory(event.subCategoryId);

    if (itemsResult is Success) {
      final items = (itemsResult as Success).data;

      int safeIndex = event.initialIndex;
      if (event.targetDhikrId != null) {
        final found = items.indexWhere((it) => it.id == event.targetDhikrId);
        if (found != -1) {
          safeIndex = found;
        }
      }

      safeIndex = safeIndex.clamp(
        0,
        items.isEmpty ? 0 : items.length - 1,
      ).toInt();

      emit(DhikrState(
        status: items.isEmpty ? DhikrStatus.error : DhikrStatus.loaded,
        subCategory: subCat,
        items: items,
        currentDhikrIndex: safeIndex,
        currentCounter: 0,
        isSetCompleted: false,
        justCompletedItem: false,
        errorMessage: items.isEmpty ? 'لا توجد أذكار مسجلة لهذا الباب' : null,
      ));
    } else {
      emit(state.copyWith(
        status: DhikrStatus.error,
        errorMessage: 'تعذر تحميل بيانات الأذكار من قاعدة البيانات',
      ));
    }
  }

  Future<void> _onIncrementCounter(
    IncrementCounter event,
    Emitter<DhikrState> emit,
  ) async {
    if (state.status != DhikrStatus.loaded && state.status != DhikrStatus.completed) {
      return;
    }

    final item = state.currentItem;
    if (item == null) return;

    final nextCounter = state.currentCounter + 1;

    // Check if this Dhikr item has reached its prescribed repeat count
    if (nextCounter >= item.repeatCount) {
      // Check if all items in this chapter are now completed
      if (state.currentDhikrIndex >= state.items.length - 1) {
        emit(state.copyWith(
          currentCounter: item.repeatCount,
          isSetCompleted: true,
          justCompletedItem: true,
          status: DhikrStatus.completed,
        ));

        // Automatically log completion to SQLite for streak tracking
        final subCatId = state.subCategory?.id ?? item.subCategoryId;
        final now = DateTime.now();
        final dateStr =
            '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        try {
          await _statsRepository.logCompletion(
            subCategoryId: subCatId,
            completedDate: dateStr,
            isStreakEligible: true,
          );
        } catch (e, st) {
          developer.log(
            'Error logging Dhikr completion: $e',
            name: 'DhikrBloc',
            error: e,
            stackTrace: st,
          );
        }
      } else {
        // Automatically transition to the next Dhikr item
        emit(state.copyWith(
          currentDhikrIndex: state.currentDhikrIndex + 1,
          currentCounter: 0,
          justCompletedItem: true,
        ));
      }
    } else {
      // Normal increment within current item
      emit(state.copyWith(
        currentCounter: nextCounter,
        justCompletedItem: false,
      ));
    }
  }

  void _onResetDhikrSession(
    ResetDhikrSession event,
    Emitter<DhikrState> emit,
  ) {
    emit(state.copyWith(
      currentDhikrIndex: 0,
      currentCounter: 0,
      isSetCompleted: false,
      justCompletedItem: false,
      status: DhikrStatus.loaded,
    ));
  }

  void _onPreviousDhikr(
    PreviousDhikr event,
    Emitter<DhikrState> emit,
  ) {
    if (state.hasPrevious) {
      emit(state.copyWith(
        currentDhikrIndex: state.currentDhikrIndex - 1,
        currentCounter: 0,
        justCompletedItem: false,
      ));
    }
  }

  void _onNextDhikr(
    NextDhikr event,
    Emitter<DhikrState> emit,
  ) {
    if (state.hasNext) {
      emit(state.copyWith(
        currentDhikrIndex: state.currentDhikrIndex + 1,
        currentCounter: 0,
        justCompletedItem: false,
      ));
    }
  }

  void _onJumpToDhikr(
    JumpToDhikr event,
    Emitter<DhikrState> emit,
  ) {
    if (event.index >= 0 && event.index < state.items.length) {
      emit(state.copyWith(
        currentDhikrIndex: event.index,
        currentCounter: 0,
        justCompletedItem: false,
      ));
    }
  }
}
