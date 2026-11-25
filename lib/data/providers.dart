import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/player.dart';
import '../core/models/team_constraint.dart';
import 'db/app_database.dart';
import 'repositories/group_repository.dart';
import 'repositories/player_repository.dart';

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
