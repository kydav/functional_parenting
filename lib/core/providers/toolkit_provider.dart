import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_parenting/core/models/action_plan.dart';
import 'package:functional_parenting/core/models/behavior_log.dart';
import 'package:functional_parenting/core/providers/auth_provider.dart';
import 'package:functional_parenting/core/services/toolkit_repository.dart';

final toolkitRepositoryProvider = Provider<ToolkitRepository>((ref) {
  final uid = ref.watch(authNotifierProvider).currentUser?.uid ?? '';
  return ToolkitRepository(FirebaseFirestore.instance, uid);
});

final behaviorLogsProvider = StreamProvider<List<BehaviorLog>>(
  (ref) => ref.watch(toolkitRepositoryProvider).watchLogs(),
);

final actionPlansProvider = StreamProvider<List<ActionPlan>>(
  (ref) => ref.watch(toolkitRepositoryProvider).watchPlans(),
);
