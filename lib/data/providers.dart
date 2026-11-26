import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/balancer/balancer.dart';

import '../core/models/player.dart';
import '../core/models/team_constraint.dart';
import 'db/app_database.dart';
import 'repositories/group_repository.dart';
import 'repositories/player_repository.dart';
import 'repositories/session_repository.dart';
import 'repositories/history_repository.dart';
import 'repositories/settings_repository.dart';
import 'history/confirmed_lineup.dart';

/// main()에서 연 데이터베이스로 덮어쓴다.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider를 덮어써야 합니다'),
);

/// main()에서 읽은 기기 id로 덮어쓴다.
final deviceIdProvider = Provider<String>(
  (ref) => throw UnimplementedError('deviceIdProvider를 덮어써야 합니다'),
);

final groupRepositoryProvider = Provider(
  (ref) => GroupRepository(ref.watch(databaseProvider)),
);

final playerRepositoryProvider = Provider(
  (ref) => PlayerRepository(
    ref.watch(databaseProvider),
    ref.watch(deviceIdProvider),
  ),
);

final groupsProvider = StreamProvider<List<GroupInfo>>(
  (ref) => ref.watch(groupRepositoryProvider).watchGroups(),
);

final groupProvider = StreamProvider.family<GroupInfo?, String>(
  (ref, id) => ref.watch(groupRepositoryProvider).watchGroup(id),
);

final playersProvider = StreamProvider.family<List<Player>, String>(
  (ref, groupId) => ref.watch(playerRepositoryProvider).watchPlayers(groupId),
);

final constraintsProvider = StreamProvider.family<List<TeamConstraint>, String>(
  (ref, groupId) =>
      ref.watch(playerRepositoryProvider).watchConstraints(groupId),
);

final sessionRepositoryProvider = Provider(
  (ref) => SessionRepository(ref.watch(databaseProvider)),
);

/// 자동 편성 실행기. 화면이 멈추지 않도록 별도 isolate에서 계산한다.
/// 테스트에서는 같은 isolate에서 바로 계산하도록 덮어쓴다.
final balancerRunnerProvider =
    Provider<Future<BalanceResult> Function(BalanceRequest)>(
      (ref) =>
          (request) => Isolate.run(() => const TeamBalancer().balance(request)),
    );

final historyRepositoryProvider = Provider(
  (ref) => HistoryRepository(
    ref.watch(databaseProvider),
    ref.watch(deviceIdProvider),
  ),
);

final historyProvider = StreamProvider.family<List<ConfirmedLineup>, String>(
  (ref, groupId) => ref.watch(historyRepositoryProvider).watch(groupId),
);

final settingsRepositoryProvider = Provider(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);

final preferencesProvider = StreamProvider.family<GroupPreferences, String>(
  (ref, groupId) => ref.watch(settingsRepositoryProvider).watch(groupId),
);
