import 'package:equatable/equatable.dart';

/// Available preset remembrances for the electronic Misbaha.
const List<String> kPresetTasbeehAdhkar = [
  'سُبْحَانَ اللَّهِ',
  'الْحَمْدُ لِلَّهِ',
  'لَا إِلَهَ إِلَّا اللَّهُ',
  'اللَّهُ أَكْبَرُ',
  'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
  'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
  'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
];

/// State of the Electronic Misbaha (المسبحة الإلكترونية).
class TasbeehState extends Equatable {
  /// Current cycle count.
  final int count;

  /// Target count before completing a cycle (e.g. 33, 100, 0 for open/unlimited).
  final int target;

  /// Index of the selected Dhikr from [kPresetTasbeehAdhkar].
  final int selectedDhikrIndex;

  /// Total count across all sessions.
  final int totalCount;

  /// Whether the user just hit the target count in the current cycle.
  final bool isTargetReached;

  const TasbeehState({
    this.count = 0,
    this.target = 33,
    this.selectedDhikrIndex = 0,
    this.totalCount = 0,
    this.isTargetReached = false,
  });

  /// The currently selected Dhikr phrase.
  String get currentDhikr => kPresetTasbeehAdhkar[selectedDhikrIndex];

  /// Progress fraction from 0.0 to 1.0 within the current cycle.
  double get progress {
    if (target <= 0) return 0.0;
    if (count == 0) return 0.0;
    final currentCycleCount = count % target;
    if (currentCycleCount == 0 && count > 0) return 1.0;
    return (currentCycleCount / target).clamp(0.0, 1.0);
  }

  TasbeehState copyWith({
    int? count,
    int? target,
    int? selectedDhikrIndex,
    int? totalCount,
    bool? isTargetReached,
  }) {
    return TasbeehState(
      count: count ?? this.count,
      target: target ?? this.target,
      selectedDhikrIndex: selectedDhikrIndex ?? this.selectedDhikrIndex,
      totalCount: totalCount ?? this.totalCount,
      isTargetReached: isTargetReached ?? this.isTargetReached,
    );
  }

  @override
  List<Object?> get props => [
        count,
        target,
        selectedDhikrIndex,
        totalCount,
        isTargetReached,
      ];
}
