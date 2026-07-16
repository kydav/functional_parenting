import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/models/content.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/content_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/**
 * In-app content CMS. Admin-only (routing gates access via [isAdminProvider]).
 * Reads/writes the Firestore collections through [ContentRepository]; when
 * Firebase isn't configured it shows the seed content read-only.
 */
///
class AdminScreen extends HookConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(contentRepositoryProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Content CMS'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: kNavy,
            unselectedLabelColor: kTextSecondary,
            indicatorColor: kNavy,
            tabs: [
              Tab(text: 'Tips'),
              Tab(text: 'Challenges'),
              Tab(text: 'Reflections'),
              Tab(text: 'Scripts'),
            ],
          ),
        ),
        body: Column(
          children: [
            if (repo == null) const _DemoBanner(),
            const Expanded(
              child: TabBarView(
                children: [
                  _TipsTab(),
                  _ChallengesTab(),
                  _ReflectionsTab(),
                  _ScriptsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kSage.withValues(alpha: 0.4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: const Text(
        "Demo mode — Firebase not connected. Showing seed content read-only; edits won't save.",
        style: TextStyle(fontSize: 12, color: kNavy),
      ),
    );
  }
}

// ─── Shared list scaffolding ──────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool active;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ItemCard({
    required this.title,
    required this.subtitle,
    required this.active,
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: active ? 1 : 0.5,
      child: SoftCard(
        onTap: onEdit,
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Switch(value: active, onChanged: onToggle, activeThumbColor: kNavy),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              color: kTextSecondary,
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps a stream-backed list with loading/error/empty states + an add FAB.
class _TabScaffold<T> extends StatelessWidget {
  final AsyncValue<List<T>> async;
  final Widget Function(List<T> items) builder;
  final VoidCallback? onAdd;

  const _TabScaffold({required this.async, required this.builder, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      floatingActionButton: onAdd == null
          ? null
          : FloatingActionButton.extended(
              onPressed: onAdd,
              backgroundColor: kNavy,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('No items yet. Tap Add or Seed.'))
            : builder(items),
      ),
    );
  }
}

Widget _list(int count, IndexedWidgetBuilder builder) => ListView.separated(
  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
  itemCount: count,
  separatorBuilder: (_, _) => const SizedBox(height: 10),
  itemBuilder: builder,
);

int _nextOrder(Iterable<CmsItem> items) => items.isEmpty
    ? 0
    : items.map((e) => e.order).reduce((a, b) => a > b ? a : b) + 1;

Future<bool> _confirmDelete(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete item?'),
      content: const Text("This can't be undone."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return ok ?? false;
}

void _openSheet(BuildContext context, Widget child) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: child,
    ),
  );
}

// ─── Tips tab ─────────────────────────────────────────────────────────────────

class _TipsTab extends ConsumerWidget {
  const _TipsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(tipsStreamProvider);
    final repo = ref.watch(contentRepositoryProvider);

    return _TabScaffold<ParentingTip>(
      async: async,
      onAdd: repo == null
          ? null
          : () => _openSheet(
              context,
              _TipSheet(
                order: _nextOrder(async.value ?? const []),
                onSave: repo.saveTip,
              ),
            ),
      builder: (items) => _list(items.length, (context, i) {
        final t = items[i];
        return _ItemCard(
          title: t.text,
          subtitle: t.source ?? '',
          active: t.active,
          onToggle: repo == null
              ? null
              : (v) => repo.saveTip(t.copyWith(active: v)),
          onEdit: repo == null
              ? null
              : () => _openSheet(
                  context,
                  _TipSheet(existing: t, onSave: repo.saveTip),
                ),
          onDelete: repo == null
              ? null
              : () async {
                  if (await _confirmDelete(context)) await repo.deleteTip(t.id);
                },
        );
      }),
    );
  }
}

class _TipSheet extends HookWidget {
  final ParentingTip? existing;
  final int order;
  final Future<void> Function(ParentingTip) onSave;

  const _TipSheet({required this.onSave, this.existing, this.order = 0});

  @override
  Widget build(BuildContext context) {
    final text = useTextEditingController(text: existing?.text ?? '');
    final source = useTextEditingController(text: existing?.source ?? '');
    return _SheetScaffold(
      title: existing == null ? 'New tip' : 'Edit tip',
      onSave: () {
        if (text.text.trim().isEmpty) return false;
        onSave(
          (existing ?? ParentingTip(id: '', text: '', order: order)).copyWith(
            text: text.text.trim(),
            source: source.text.trim().isEmpty ? null : source.text.trim(),
          ),
        );
        return true;
      },
      fields: [
        _Field(label: 'Tip', controller: text, maxLines: 4),
        _Field(label: 'Source (optional)', controller: source),
      ],
    );
  }
}

// ─── Challenges tab ───────────────────────────────────────────────────────────

class _ChallengesTab extends ConsumerWidget {
  const _ChallengesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(challengesStreamProvider);
    final repo = ref.watch(contentRepositoryProvider);

    return _TabScaffold<ParentingChallenge>(
      async: async,
      onAdd: repo == null
          ? null
          : () => _openSheet(
              context,
              _ChallengeSheet(
                order: _nextOrder(async.value ?? const []),
                onSave: repo.saveChallenge,
              ),
            ),
      builder: (items) => _list(items.length, (context, i) {
        final c = items[i];
        return _ItemCard(
          title: c.title,
          subtitle: c.description,
          active: c.active,
          onToggle: repo == null
              ? null
              : (v) => repo.saveChallenge(c.copyWith(active: v)),
          onEdit: repo == null
              ? null
              : () => _openSheet(
                  context,
                  _ChallengeSheet(existing: c, onSave: repo.saveChallenge),
                ),
          onDelete: repo == null
              ? null
              : () async {
                  if (await _confirmDelete(context)) {
                    await repo.deleteChallenge(c.id);
                  }
                },
        );
      }),
    );
  }
}

class _ChallengeSheet extends HookWidget {
  final ParentingChallenge? existing;
  final int order;
  final Future<void> Function(ParentingChallenge) onSave;

  const _ChallengeSheet({required this.onSave, this.existing, this.order = 0});

  @override
  Widget build(BuildContext context) {
    final title = useTextEditingController(text: existing?.title ?? '');
    final desc = useTextEditingController(text: existing?.description ?? '');
    return _SheetScaffold(
      title: existing == null ? 'New challenge' : 'Edit challenge',
      onSave: () {
        if (title.text.trim().isEmpty || desc.text.trim().isEmpty) return false;
        onSave(
          (existing ??
                  ParentingChallenge(
                    id: '',
                    title: '',
                    description: '',
                    order: order,
                  ))
              .copyWith(
                title: title.text.trim(),
                description: desc.text.trim(),
              ),
        );
        return true;
      },
      fields: [
        _Field(label: 'Title', controller: title),
        _Field(label: 'Description', controller: desc, maxLines: 4),
      ],
    );
  }
}

// ─── Reflections tab ──────────────────────────────────────────────────────────

class _ReflectionsTab extends ConsumerWidget {
  const _ReflectionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(reflectionsStreamProvider);
    final repo = ref.watch(contentRepositoryProvider);

    return _TabScaffold<ReflectionPrompt>(
      async: async,
      onAdd: repo == null
          ? null
          : () => _openSheet(
              context,
              _ReflectionSheet(
                order: _nextOrder(async.value ?? const []),
                onSave: repo.saveReflection,
              ),
            ),
      builder: (items) => _list(items.length, (context, i) {
        final r = items[i];
        return _ItemCard(
          title: r.prompt,
          subtitle: '',
          active: r.active,
          onToggle: repo == null
              ? null
              : (v) => repo.saveReflection(r.copyWith(active: v)),
          onEdit: repo == null
              ? null
              : () => _openSheet(
                  context,
                  _ReflectionSheet(existing: r, onSave: repo.saveReflection),
                ),
          onDelete: repo == null
              ? null
              : () async {
                  if (await _confirmDelete(context)) {
                    await repo.deleteReflection(r.id);
                  }
                },
        );
      }),
    );
  }
}

class _ReflectionSheet extends HookWidget {
  final ReflectionPrompt? existing;
  final int order;
  final Future<void> Function(ReflectionPrompt) onSave;

  const _ReflectionSheet({required this.onSave, this.existing, this.order = 0});

  @override
  Widget build(BuildContext context) {
    final prompt = useTextEditingController(text: existing?.prompt ?? '');
    return _SheetScaffold(
      title: existing == null ? 'New reflection' : 'Edit reflection',
      onSave: () {
        if (prompt.text.trim().isEmpty) return false;
        onSave(
          (existing ?? ReflectionPrompt(id: '', prompt: '', order: order))
              .copyWith(prompt: prompt.text.trim()),
        );
        return true;
      },
      fields: [
        _Field(label: 'Reflection prompt', controller: prompt, maxLines: 4),
      ],
    );
  }
}

// ─── Scripts tab ──────────────────────────────────────────────────────────────

class _ScriptsTab extends ConsumerWidget {
  const _ScriptsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(scriptsStreamProvider);
    final repo = ref.watch(contentRepositoryProvider);

    return _TabScaffold<Script>(
      async: async,
      onAdd: repo == null
          ? null
          : () => _openSheet(
              context,
              _ScriptSheet(
                order: _nextOrder(async.value ?? const []),
                onSave: repo.saveScript,
              ),
            ),
      builder: (items) => _list(items.length, (context, i) {
        final s = items[i];
        return _ItemCard(
          title: s.situation,
          subtitle: '${s.category} · ${s.script}',
          active: s.active,
          onToggle: repo == null
              ? null
              : (v) => repo.saveScript(s.copyWith(active: v)),
          onEdit: repo == null
              ? null
              : () => _openSheet(
                  context,
                  _ScriptSheet(existing: s, onSave: repo.saveScript),
                ),
          onDelete: repo == null
              ? null
              : () async {
                  if (await _confirmDelete(context)) {
                    await repo.deleteScript(s.id);
                  }
                },
        );
      }),
    );
  }
}

class _ScriptSheet extends HookWidget {
  final Script? existing;
  final int order;
  final Future<void> Function(Script) onSave;

  const _ScriptSheet({required this.onSave, this.existing, this.order = 0});

  @override
  Widget build(BuildContext context) {
    final situation = useTextEditingController(text: existing?.situation ?? '');
    final category = useTextEditingController(text: existing?.category ?? '');
    final script = useTextEditingController(text: existing?.script ?? '');
    final why = useTextEditingController(text: existing?.why ?? '');
    return _SheetScaffold(
      title: existing == null ? 'New script' : 'Edit script',
      onSave: () {
        if (situation.text.trim().isEmpty || script.text.trim().isEmpty) {
          return false;
        }
        onSave(
          (existing ??
                  Script(
                    id: '',
                    situation: '',
                    category: '',
                    script: '',
                    order: order,
                  ))
              .copyWith(
                situation: situation.text.trim(),
                category: category.text.trim(),
                script: script.text.trim(),
                why: why.text.trim().isEmpty ? null : why.text.trim(),
              ),
        );
        return true;
      },
      fields: [
        _Field(label: 'Situation', controller: situation),
        _Field(label: 'Category', controller: category),
        _Field(label: 'What to say', controller: script, maxLines: 3),
        _Field(label: 'Why it works (optional)', controller: why, maxLines: 3),
      ],
    );
  }
}

// ─── Shared sheet building blocks ─────────────────────────────────────────────

class _Field {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  const _Field({
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });
}

/// Bottom-sheet scaffold. [onSave] returns false to signal a validation failure
/// (keeps the sheet open); true dismisses it.
class _SheetScaffold extends StatelessWidget {
  final String title;
  final List<_Field> fields;
  final bool Function() onSave;

  const _SheetScaffold({
    required this.title,
    required this.fields,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            for (final f in fields) ...[
              Text(f.label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 6),
              TextField(controller: f.controller, maxLines: f.maxLines),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 4),
            FilledButton(
              onPressed: () {
                if (onSave()) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
