/// Entry point for Awrad (أَوْرَاد) — an offline Islamic Dhikr companion.
///
/// Phase 5 Architecture:
///  1. Flutter bindings initialized.
///  2. Portrait orientation locked.
///  3. Offline SQLite database seeded from Hisn al-Muslim JSON asset.
///  4. SharedPreferences initialized for Theme, Typography, Sound, Haptic, and Notifications persistence.
///  5. Clean Architecture dependency injection via MultiRepositoryProvider and MultiBlocProvider.
///  6. Dynamic Material 3 Theme engine with Arabic RTL localization.
///  7. Offline Local Notifications engine with exact Daily Morning & Evening reminders deep-linking.
///
/// All operations are 100% offline. Zero network calls.
library;

import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/notification_service.dart';
import 'core/services/sound_service.dart';
import 'data/datasources/local/database_helper.dart';
import 'data/repositories/dhikr_repository_impl.dart';
import 'data/repositories/statistics_repository_impl.dart';
import 'domain/repositories/dhikr_repository.dart';
import 'domain/repositories/statistics_repository.dart';
import 'presentation/blocs/category/category_cubit.dart';
import 'presentation/blocs/dhikr/dhikr_bloc.dart';
import 'presentation/blocs/search/search_cubit.dart';
import 'presentation/blocs/settings/settings_cubit.dart';
import 'presentation/blocs/stats/stats_cubit.dart';
import 'presentation/blocs/tasbeeh/tasbeeh_cubit.dart';
import 'presentation/blocs/theme/theme_cubit.dart';
import 'presentation/blocs/theme/theme_state.dart';
import 'presentation/screens/dhikr/dhikr_reading_screen.dart';
import 'presentation/screens/main_screen.dart';

/// Global navigator key allowing headless navigation upon notification deep-link tap.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Deep-links into the Dhikr reader for the specified sub-category payload.
void handleNotificationPayload(String payload) {
  developer.log('Routing notification payload: $payload', name: 'main');
  int? subCatId;
  if (payload == 'morning' ||
      payload == NotificationService.morningSubCategoryId) {
    subCatId = 2; // أذكار الصباح
  } else if (payload == 'evening' ||
      payload == NotificationService.eveningSubCategoryId) {
    subCatId = 3; // أذكار المساء
  } else {
    subCatId = int.tryParse(payload);
  }

  if (subCatId != null) {
    appNavigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => DhikrReadingScreen(
          subCategoryId: subCatId,
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for a focused Dhikr experience.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Seed the database from bundled Hisn al-Muslim JSON asset on first launch.
  try {
    await DatabaseHelper.instance.seedIfNeeded();
  } catch (e, st) {
    developer.log(
      'Database seed check error: $e',
      name: 'main',
      error: e,
      stackTrace: st,
    );
  }

  // Initialize offline local notifications and register the deep-link callback
  await NotificationService.instance.initialize(
    onNotificationTap: handleNotificationPayload,
  );

  // Initialize offline audio click service
  SoundService.instance.initialize();

  // Initialize SharedPreferences for persistence
  final prefs = await SharedPreferences.getInstance();

  // Instantiate Repositories
  final dhikrRepository = DhikrRepositoryImpl();
  final statisticsRepository = StatisticsRepositoryImpl();

  runApp(
    AwradApp(
      prefs: prefs,
      dhikrRepository: dhikrRepository,
      statisticsRepository: statisticsRepository,
    ),
  );
}

/// Root application widget for Awrad.
class AwradApp extends StatefulWidget {
  final SharedPreferences prefs;
  final DhikrRepository dhikrRepository;
  final StatisticsRepository statisticsRepository;

  const AwradApp({
    super.key,
    required this.prefs,
    required this.dhikrRepository,
    required this.statisticsRepository,
  });

  @override
  State<AwradApp> createState() => _AwradAppState();
}

class _AwradAppState extends State<AwradApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the app was launched by tapping a notification
      final pendingPayload =
          NotificationService.instance.consumeInitialPayload();
      if (pendingPayload != null && pendingPayload.isNotEmpty) {
        handleNotificationPayload(pendingPayload);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DhikrRepository>.value(
            value: widget.dhikrRepository),
        RepositoryProvider<StatisticsRepository>.value(
            value: widget.statisticsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (_) => ThemeCubit(widget.prefs),
          ),
          BlocProvider<SettingsCubit>(
            create: (_) => SettingsCubit(widget.prefs),
          ),
          BlocProvider<CategoryCubit>(
            create: (_) => CategoryCubit(widget.dhikrRepository),
          ),
          BlocProvider<TasbeehCubit>(
            create: (_) => TasbeehCubit(widget.prefs),
          ),
          BlocProvider<StatsCubit>(
            create: (_) => StatsCubit(widget.statisticsRepository),
          ),
          BlocProvider<SearchCubit>(
            create: (_) => SearchCubit(widget.dhikrRepository),
          ),
          BlocProvider<DhikrBloc>(
            create: (_) => DhikrBloc(
              dhikrRepository: widget.dhikrRepository,
              statsRepository: widget.statisticsRepository,
            ),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              navigatorKey: appNavigatorKey,
              title: 'أَوْرَاد',
              debugShowCheckedModeBanner: false,
              theme: themeState.lightTheme,
              darkTheme: themeState.darkTheme,
              themeMode: themeState.themeMode,
              locale: const Locale('ar'),
              supportedLocales: const [
                Locale('ar'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const MainScreen(),
            );
          },
        ),
      ),
    );
  }
}
