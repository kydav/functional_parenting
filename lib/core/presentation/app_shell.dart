import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class AppShell extends ConsumerWidget {
  final String location;
  final Widget child;

  const AppShell({required this.location, required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    return isWide
        ? _DesktopShell(location: location, child: child)
        : _MobileShell(location: location, child: child);
  }
}

// ─── Nav definitions ──────────────────────────────────────────────────────────

class _NavDef {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavDef({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const _navItems = [
  _NavDef(
    path: '/today',
    icon: Icons.wb_sunny_outlined,
    activeIcon: Icons.wb_sunny,
    label: 'Today',
  ),
  _NavDef(
    path: '/learn',
    icon: Icons.menu_book_outlined,
    activeIcon: Icons.menu_book,
    label: 'Learn',
  ),
  _NavDef(
    path: '/tools',
    icon: Icons.handyman_outlined,
    activeIcon: Icons.handyman,
    label: 'Tools',
  ),
  _NavDef(
    path: '/workshops',
    icon: Icons.event_outlined,
    activeIcon: Icons.event,
    label: 'Workshops',
  ),
];

const _settingsNav = _NavDef(
  path: '/profile',
  icon: Icons.person_outline_rounded,
  activeIcon: Icons.person_rounded,
  label: 'Profile',
);

bool _isActive(String location, String path) =>
    location == path || location.startsWith('$path/');

// ─── Brand logo ───────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kBlue, kSage],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              'fp',
              style: TextStyle(
                color: kNavy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        ...[
          const SizedBox(width: 10),
          const Text(
            'Functional\nParenting',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.1,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Desktop shell ────────────────────────────────────────────────────────────

class _DesktopShell extends StatelessWidget {
  final String location;
  final Widget child;
  const _DesktopShell({required this.location, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      body: Row(
        children: [
          _Sidebar(location: location),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  final String location;
  const _Sidebar({required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    return Container(
      width: 244,
      color: kNavy,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 22, 20, 28),
              child: Align(alignment: Alignment.centerLeft, child: _Logo()),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _navItems
                    .map(
                      (item) => _SidebarItem(
                        item: item,
                        active: _isActive(location, item.path),
                        onTap: () => context.go(item.path),
                      ),
                    )
                    .toList(),
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            _SidebarItem(
              item: _settingsNav,
              active: _isActive(location, _settingsNav.path),
              onTap: () => context.go(_settingsNav.path),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: kBlue,
                    child: Text(
                      auth.userInitials,
                      style: const TextStyle(
                        color: kNavy,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      auth.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.logout,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    onPressed: () => ref.read(authNotifierProvider).signOut(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Sign out',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final _NavDef item;
  final bool active;
  final VoidCallback onTap;
  const _SidebarItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: active ? kNavySoft : kNavy,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: Colors.white.withValues(alpha: 0.06),
          mouseCursor: SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(
                  active ? item.activeIcon : item.icon,
                  color: active ? kBlue : Colors.white.withValues(alpha: 0.6),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Mobile shell ─────────────────────────────────────────────────────────────

class _MobileShell extends StatelessWidget {
  final String location;
  final Widget child;
  const _MobileShell({required this.location, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      body: child,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: _FloatingNav(location: location),
        ),
      ),
    );
  }
}

class _FloatingNav extends StatelessWidget {
  final String location;
  const _FloatingNav({required this.location});

  @override
  Widget build(BuildContext context) {
    final items = [..._navItems, _settingsNav];
    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: kNavy,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          final active = _isActive(location, item.path);
          final color = active ? kBlue : Colors.white.withValues(alpha: 0.55);
          return Expanded(
            child: GestureDetector(
              onTap: () => context.go(item.path),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    active ? item.activeIcon : item.icon,
                    color: color,
                    size: 22,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
