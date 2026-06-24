import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../core/lumio_controller.dart';
import '../core/lumio_models.dart';
import '../core/lumio_theme.dart';

class LumioApp extends StatefulWidget {
  const LumioApp({super.key, required this.controller});

  final LumioController controller;

  @override
  State<LumioApp> createState() => _LumioAppState();
}

class _LumioAppState extends State<LumioApp> {
  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumio',
      debugShowCheckedModeBanner: false,
      theme: LumioTheme.light(),
      home: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          if (widget.controller.isLoading) {
            return const _BootScreen();
          }
          if (!widget.controller.isAuthenticated) {
            return _AuthScreen(controller: widget.controller);
          }
          return _LumioShell(controller: widget.controller);
        },
      ),
    );
  }
}

class _AuthScreen extends StatefulWidget {
  const _AuthScreen({required this.controller});

  final LumioController controller;

  @override
  State<_AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<_AuthScreen> {
  final email = TextEditingController(text: 'saqlain@lumio.edu');
  final password = TextEditingController(text: 'Student@123');
  final name = TextEditingController();
  final inviteCode = TextEditingController();
  bool register = false;
  bool obscure = true;
  UserRole selectedRole = UserRole.student;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    inviteCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 920;
            final intro = _AuthIntro(controller: widget.controller);
            final form = _AuthForm(
              controller: widget.controller,
              email: email,
              password: password,
              name: name,
              inviteCode: inviteCode,
              register: register,
              obscure: obscure,
              selectedRole: selectedRole,
              onToggleMode: () => setState(() => register = !register),
              onToggleObscure: () => setState(() => obscure = !obscure),
              onRoleChanged: (role) => setState(() => selectedRole = role),
              onDemoStudent: () {
                setState(() {
                  register = false;
                  email.text = 'saqlain@lumio.edu';
                  password.text = 'Student@123';
                });
              },
              onDemoInstructor: () {
                setState(() {
                  register = false;
                  email.text = 'umer.iqbal@comsats.edu.pk';
                  password.text = 'Instructor@123';
                });
              },
              onSubmit: _submit,
            );

            return SingleChildScrollView(
              padding: EdgeInsets.all(compact ? 18 : 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: compact
                      ? Column(
                          children: [intro, const SizedBox(height: 18), form],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(flex: 6, child: intro),
                            const SizedBox(width: 28),
                            Expanded(flex: 4, child: form),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final ok = register
        ? await widget.controller.registerAccount(
            name: name.text,
            email: email.text,
            password: password.text,
            role: selectedRole,
            inviteCode: inviteCode.text,
          )
        : await widget.controller.signIn(
            email: email.text,
            password: password.text,
          );
    if (!ok || !mounted) return;
    FocusScope.of(context).unfocus();
  }
}

class _AuthIntro extends StatelessWidget {
  const _AuthIntro({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: LumioTheme.ink,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _LumioMark(size: 58),
          const SizedBox(height: 26),
          Text(
            'Lumio',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'AI-powered collaborative academic intelligence with strict role-based access.',
            style: TextStyle(
              color: Color(0xFFD8E1F0),
              fontSize: 17,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _StatusPill(
                label: 'Student workspace',
                color: LumioTheme.teal,
                dark: true,
              ),
              _StatusPill(
                label: 'Instructor analytics',
                color: LumioTheme.blue,
                dark: true,
              ),
              _StatusPill(
                label: 'RTDB accounts',
                color: LumioTheme.amber,
                dark: true,
              ),
            ],
          ),
          const SizedBox(height: 26),
          _AuthCapability(
            icon: Icons.lock_outline,
            title: 'Authenticated sessions',
            detail: 'The dashboard is inaccessible until an account signs in.',
          ),
          _AuthCapability(
            icon: Icons.badge_outlined,
            title: 'Fixed account roles',
            detail: 'Students cannot switch into instructor views from the UI.',
          ),
          _AuthCapability(
            icon: Icons.storage_outlined,
            title: 'Database-ready auth',
            detail: controller.databaseConnected
                ? 'Connected to Firebase Realtime Database.'
                : 'Using local seed accounts until Firebase rules allow access.',
          ),
        ],
      ),
    );
  }
}

class _AuthCapability extends StatelessWidget {
  const _AuthCapability({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: LumioTheme.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(
                    color: Color(0xFFC8D2E3),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.controller,
    required this.email,
    required this.password,
    required this.name,
    required this.inviteCode,
    required this.register,
    required this.obscure,
    required this.selectedRole,
    required this.onToggleMode,
    required this.onToggleObscure,
    required this.onRoleChanged,
    required this.onDemoStudent,
    required this.onDemoInstructor,
    required this.onSubmit,
  });

  final LumioController controller;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController name;
  final TextEditingController inviteCode;
  final bool register;
  final bool obscure;
  final UserRole selectedRole;
  final VoidCallback onToggleMode;
  final VoidCallback onToggleObscure;
  final ValueChanged<UserRole> onRoleChanged;
  final VoidCallback onDemoStudent;
  final VoidCallback onDemoInstructor;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return _LumioCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(
            icon: register
                ? Icons.person_add_alt_1_outlined
                : Icons.login_outlined,
            title: register ? 'Create Account' : 'Sign In',
          ),
          const SizedBox(height: 8),
          Text(
            register
                ? 'New accounts are created with one fixed role.'
                : 'Use a Lumio account to open the correct workspace.',
            style: const TextStyle(color: LumioTheme.muted, height: 1.35),
          ),
          const SizedBox(height: 18),
          if (register) ...[
            TextField(
              controller: name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.account_circle_outlined),
                labelText: 'Full name',
              ),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.mail_outline),
              labelText: 'Email',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: password,
            obscureText: obscure,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.password_outlined),
              labelText: 'Password',
              suffixIcon: IconButton(
                tooltip: obscure ? 'Show password' : 'Hide password',
                onPressed: onToggleObscure,
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          if (register) ...[
            const SizedBox(height: 14),
            SegmentedButton<UserRole>(
              segments: const [
                ButtonSegment(
                  value: UserRole.student,
                  icon: Icon(Icons.school_outlined),
                  label: Text('Student'),
                ),
                ButtonSegment(
                  value: UserRole.instructor,
                  icon: Icon(Icons.analytics_outlined),
                  label: Text('Instructor'),
                ),
              ],
              selected: {selectedRole},
              onSelectionChanged: (roles) => onRoleChanged(roles.first),
            ),
            if (selectedRole == UserRole.instructor) ...[
              const SizedBox(height: 12),
              TextField(
                controller: inviteCode,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                  labelText: 'Instructor invite code',
                ),
              ),
            ],
          ],
          if (controller.authError != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: LumioTheme.coral.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: LumioTheme.coral.withValues(alpha: 0.22),
                ),
              ),
              child: Text(
                controller.authError!,
                style: const TextStyle(
                  color: LumioTheme.coral,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: controller.isAuthenticating ? null : onSubmit,
              icon: controller.isAuthenticating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(register ? Icons.person_add_alt : Icons.login),
              label: Text(register ? 'Create and Enter' : 'Sign In'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: controller.isAuthenticating ? null : onToggleMode,
              icon: Icon(
                register
                    ? Icons.login_outlined
                    : Icons.person_add_alt_1_outlined,
              ),
              label: Text(
                register ? 'Use Existing Account' : 'Register New Account',
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 10),
          const Text(
            'Demo accounts',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: onDemoStudent,
                icon: const Icon(Icons.school_outlined),
                label: const Text('Student'),
              ),
              OutlinedButton.icon(
                onPressed: onDemoInstructor,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Instructor'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Student: saqlain@lumio.edu / Student@123\nInstructor: umer.iqbal@comsats.edu.pk / Instructor@123',
            style: TextStyle(color: LumioTheme.muted, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 260,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LumioMark(size: 64),
              SizedBox(height: 22),
              LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LumioShell extends StatelessWidget {
  const _LumioShell({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1060;
        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                _SideNavigation(controller: controller),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(controller: controller),
                      Expanded(child: _Content(controller: controller)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const _LumioMark(size: 34),
                const SizedBox(width: 10),
                Text(
                  controller.selectedSection.label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            actions: [
              _UserMenu(controller: controller, iconOnly: true),
              const SizedBox(width: 6),
            ],
          ),
          drawer: Drawer(
            child: _SideNavigation(controller: controller, compact: true),
          ),
          body: _Content(controller: controller),
        );
      },
    );
  }
}

class _SideNavigation extends StatelessWidget {
  const _SideNavigation({required this.controller, this.compact = false});

  final LumioController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final sections = controller.availableSections;
    return Container(
      width: compact ? null : 258,
      color: LumioTheme.ink,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Row(
                children: [
                  const _LumioMark(size: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lumio',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        Text(
                          controller.activeCourse.code,
                          style: const TextStyle(
                            color: Color(0xFFB8C2D6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _SessionSummary(controller: controller, dark: true),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 14),
                itemCount: sections.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final section = sections[index];
                  final selected = controller.selectedSection == section;
                  return _NavButton(
                    icon: _sectionIcon(section),
                    label: section.label,
                    selected: selected,
                    onTap: () {
                      controller.selectSection(section);
                      if (compact) Navigator.of(context).maybePop();
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: _SyncPanel(controller: controller, dark: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: selected
            ? Colors.white.withValues(alpha: 0.13)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? LumioTheme.amber : const Color(0xFFB8C2D6),
                  size: 21,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFFCFD6E6),
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
      decoration: const BoxDecoration(
        color: LumioTheme.surface,
        border: Border(bottom: BorderSide(color: LumioTheme.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.selectedSection.label,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.currentUser.name} / ${controller.activeGroup.name}',
                  style: const TextStyle(
                    color: LumioTheme.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search Lumio',
                isDense: true,
                suffixIcon: IconButton(
                  tooltip:
                      controller.availableSections.contains(
                        WorkspaceSection.chatbot,
                      )
                      ? 'AI Chatbot'
                      : 'Resources',
                  onPressed: () => controller.selectSection(
                    controller.availableSections.contains(
                          WorkspaceSection.chatbot,
                        )
                        ? WorkspaceSection.chatbot
                        : WorkspaceSection.resources,
                  ),
                  icon: const Icon(Icons.auto_awesome_outlined),
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  if (controller.availableSections.contains(
                    WorkspaceSection.chatbot,
                  )) {
                    controller.selectSection(WorkspaceSection.chatbot);
                    controller.askChatbot(value);
                  } else {
                    controller.selectSection(WorkspaceSection.resources);
                  }
                }
              },
            ),
          ),
          const SizedBox(width: 14),
          _UserMenu(controller: controller),
          const SizedBox(width: 14),
          _SyncPanel(controller: controller),
        ],
      ),
    );
  }
}

class _SessionSummary extends StatelessWidget {
  const _SessionSummary({required this.controller, this.dark = false});

  final LumioController controller;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: dark ? Colors.white.withValues(alpha: 0.14) : LumioTheme.line,
        ),
      ),
      child: Row(
        children: [
          _Avatar(user: user, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: dark ? Colors.white : LumioTheme.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  user.role.label,
                  style: TextStyle(
                    color: dark ? const Color(0xFFB8C2D6) : LumioTheme.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserMenu extends StatelessWidget {
  const _UserMenu({required this.controller, this.iconOnly = false});

  final LumioController controller;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Account',
      onSelected: (value) {
        if (value == 'profile') {
          controller.selectSection(WorkspaceSection.profile);
        }
        if (value == 'logout') {
          controller.signOut();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.currentUser.name,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(
                controller.currentUser.role.label,
                style: const TextStyle(color: LumioTheme.muted),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'profile',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.account_circle_outlined),
            title: Text('Profile'),
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: ListTile(
            dense: true,
            leading: Icon(Icons.logout_outlined),
            title: Text('Logout'),
          ),
        ),
      ],
      child: iconOnly
          ? const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.account_circle_outlined),
            )
          : SizedBox(
              width: 220,
              child: _SessionSummary(controller: controller),
            ),
    );
  }
}

class _SyncPanel extends StatelessWidget {
  const _SyncPanel({required this.controller, this.dark = false});

  final LumioController controller;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = controller.databaseConnected
        ? LumioTheme.teal
        : LumioTheme.amber;
    return Tooltip(
      message: controller.databaseStatus,
      child: InkWell(
        onTap: controller.isSyncing ? null : () => controller.syncNow(),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: dark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
            border: Border.all(
              color: dark
                  ? Colors.white.withValues(alpha: 0.12)
                  : LumioTheme.line,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              controller.isSyncing
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    )
                  : Icon(Icons.cloud_sync_outlined, color: color, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  controller.databaseConnected ? 'Live DB' : 'Demo DB',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: dark ? Colors.white : LumioTheme.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    final child = switch (controller.selectedSection) {
      WorkspaceSection.overview => _HomeOverview(controller: controller),
      WorkspaceSection.profile => _ProfileScreen(controller: controller),
      WorkspaceSection.matchmaking => _MatchmakingScreen(
        controller: controller,
      ),
      WorkspaceSection.chatbot => _ChatbotScreen(controller: controller),
      WorkspaceSection.workspace => _WorkspaceScreen(controller: controller),
      WorkspaceSection.summarizer => _SummarizerScreen(controller: controller),
      WorkspaceSection.resources => _ResourcesScreen(controller: controller),
      WorkspaceSection.insights => _InsightsScreen(controller: controller),
      WorkspaceSection.analytics => _AnalyticsScreen(controller: controller),
      WorkspaceSection.predictions => _PredictionsScreen(
        controller: controller,
      ),
    };

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, viewport) {
          final mediaWidth = MediaQuery.sizeOf(context).width;
          final availableWidth = viewport.hasBoundedWidth
              ? math.min(viewport.maxWidth, mediaWidth)
              : mediaWidth;
          final inset = availableWidth < 640 ? 16.0 : 24.0;
          final width = (availableWidth - (inset * 2)).clamp(0.0, 1320.0);
          return SingleChildScrollView(
            padding: EdgeInsets.all(inset),
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(width: width, child: child),
            ),
          );
        },
      ),
    );
  }
}

class _HomeOverview extends StatelessWidget {
  const _HomeOverview({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    final overdue = controller.activeTasks
        .where((task) => task.isOverdue)
        .length;
    final activeRequests = controller.incomingSyncRequests
        .where((request) => request.status == RequestStatus.pending)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroBand(controller: controller),
        const SizedBox(height: 18),
        _MetricGrid(
          children: [
            _MetricTile(
              icon: Icons.groups_2_outlined,
              label: 'Group Progress',
              value: '${(controller.activeGroup.progress * 100).round()}%',
              accent: LumioTheme.teal,
              detail: controller.activeGroup.name,
            ),
            _MetricTile(
              icon: Icons.task_alt_outlined,
              label: 'Tasks Completed',
              value: '${(controller.taskCompletionRate * 100).round()}%',
              accent: LumioTheme.blue,
              detail: '${controller.activeTasks.length} tracked tasks',
            ),
            _MetricTile(
              icon: Icons.menu_book_outlined,
              label: 'Knowledge Health',
              value:
                  '${(controller.activeCourse.knowledgeBaseHealth * 100).round()}%',
              accent: LumioTheme.amber,
              detail: controller.activeCourse.title,
            ),
            _MetricTile(
              icon: Icons.warning_amber_rounded,
              label: controller.currentRole == UserRole.instructor
                  ? 'At Risk'
                  : 'Open Requests',
              value:
                  '${controller.currentRole == UserRole.instructor ? controller.atRiskStudents.length : activeRequests}',
              accent: overdue > 0 ? LumioTheme.coral : LumioTheme.teal,
              detail: overdue > 0
                  ? '$overdue overdue task(s)'
                  : 'All deadlines visible',
            ),
          ],
        ),
        const SizedBox(height: 18),
        _AdaptiveColumns(
          left: Column(
            children: [
              _WorkspacePulse(controller: controller),
              const SizedBox(height: 18),
              _RecommendationsPanel(controller: controller),
            ],
          ),
          right: Column(
            children: [
              _ActivityFeed(controller: controller),
              const SizedBox(height: 18),
              _CoursePanel(controller: controller),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroBand extends StatelessWidget {
  const _HeroBand({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: LumioTheme.ink,
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mediaWidth = MediaQuery.sizeOf(context).width;
          final rawContentWidth = math.min(
            constraints.hasBoundedWidth ? constraints.maxWidth : mediaWidth,
            mediaWidth - 76,
          );
          final contentWidth = rawContentWidth < 760
              ? math.max(240.0, math.min(rawContentWidth, 320.0))
              : rawContentWidth;
          final compact = contentWidth < 760;
          final main = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusPill(
                label:
                    '${controller.activeCourse.code} / ${controller.activeCourse.semester}',
                color: LumioTheme.amber,
                dark: true,
              ),
              const SizedBox(height: 18),
              Text(
                'Hello, ${controller.currentUser.name}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.currentRole == UserRole.instructor
                    ? '${controller.groups.length} groups under supervision, ${controller.atRiskStudents.length} intervention queue item(s).'
                    : '${controller.activeGroup.name} is ${(controller.activeGroup.progress * 100).round()}% through the current sprint.',
                style: const TextStyle(
                  color: Color(0xFFD8E1F0),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: contentWidth, child: main),
                const SizedBox(height: 18),
                SizedBox(
                  width: contentWidth,
                  child: _MiniRadar(controller: controller),
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: main),
              const SizedBox(width: 24),
              SizedBox(width: 330, child: _MiniRadar(controller: controller)),
            ],
          );
        },
      ),
    );
  }
}

class _MiniRadar extends StatelessWidget {
  const _MiniRadar({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Tasks', controller.taskCompletionRate),
      ('RAG', controller.activeCourse.knowledgeBaseHealth),
      ('Group', controller.activeGroup.progress),
      ('Engage', controller.currentUser.engagementScore / 100),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    item.$1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: item.$2.clamp(0, 1),
                      minHeight: 9,
                      backgroundColor: Colors.white.withValues(alpha: 0.14),
                      color: item.$1 == 'RAG'
                          ? LumioTheme.amber
                          : LumioTheme.teal,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(item.$2 * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _WorkspacePulse extends StatelessWidget {
  const _WorkspacePulse({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    return _LumioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.view_kanban_outlined,
            title: 'Workspace Pulse',
          ),
          const SizedBox(height: 18),
          Row(
            children: TaskStatus.values.map((status) {
              final count = controller.activeTasks
                  .where((task) => task.status == status)
                  .length;
              final color = switch (status) {
                TaskStatus.todo => LumioTheme.amber,
                TaskStatus.inProgress => LumioTheme.blue,
                TaskStatus.completed => LumioTheme.teal,
              };
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withValues(alpha: 0.22)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.label,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$count',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: _EngagementLineChart(users: controller.activeGroupMembers),
          ),
        ],
      ),
    );
  }
}

class _RecommendationsPanel extends StatelessWidget {
  const _RecommendationsPanel({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    return _LumioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.auto_awesome_outlined,
            title: 'AI Study Recommendations',
          ),
          const SizedBox(height: 12),
          ...controller.studyRecommendations.map(
            (item) => _ListRow(
              icon: Icons.bolt_outlined,
              title: item,
              detail:
                  'Personalized from tasks, resources, and engagement trend.',
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityFeed extends StatelessWidget {
  const _ActivityFeed({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    return _LumioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.timeline_outlined,
            title: 'Activity Feed',
          ),
          const SizedBox(height: 10),
          ...controller.activity.take(6).map((item) {
            final actor = controller.users.firstWhere(
              (user) => user.id == item.actorId,
              orElse: () => controller.currentUser,
            );
            return _ListRow(
              icon: _activityIcon(item.kind),
              title: item.title,
              detail:
                  '${actor.name} / ${_relative(item.createdAt)} / ${item.detail}',
            );
          }),
        ],
      ),
    );
  }
}

class _CoursePanel extends StatelessWidget {
  const _CoursePanel({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    return _LumioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.event_note_outlined,
            title: 'Course Deadlines',
          ),
          const SizedBox(height: 12),
          ...controller.courses
              .where(
                (course) => controller.currentUser.courses.contains(course.id),
              )
              .map((course) {
                final days = course.deadline.difference(DateTime.now()).inDays;
                return _ListRow(
                  icon: Icons.calendar_month_outlined,
                  title: '${course.code} / ${course.title}',
                  detail:
                      '$days day(s) left / KB ${(course.knowledgeBaseHealth * 100).round()}%',
                  trailing: _StatusPill(
                    label: DateFormat('MMM d').format(course.deadline),
                    color: days < 14 ? LumioTheme.coral : LumioTheme.teal,
                  ),
                );
              }),
        ],
      ),
    );
  }
}

class _ProfileScreen extends StatefulWidget {
  const _ProfileScreen({required this.controller});

  final LumioController controller;

  @override
  State<_ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<_ProfileScreen> {
  late TextEditingController name;
  late TextEditingController major;
  late TextEditingController skills;
  late TextEditingController interests;
  late TextEditingController availability;
  late bool publicProfile;
  String? loadedUserId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (loadedUserId != widget.controller.currentUser.id) {
      _load(disposeOld: true);
    }
  }

  @override
  void dispose() {
    name.dispose();
    major.dispose();
    skills.dispose();
    interests.dispose();
    availability.dispose();
    super.dispose();
  }

  void _load({bool disposeOld = false}) {
    if (disposeOld) {
      name.dispose();
      major.dispose();
      skills.dispose();
      interests.dispose();
      availability.dispose();
    }
    final user = widget.controller.currentUser;
    loadedUserId = user.id;
    name = TextEditingController(text: user.name);
    major = TextEditingController(text: user.major);
    skills = TextEditingController(text: user.skills.join(', '));
    interests = TextEditingController(text: user.interests.join(', '));
    availability = TextEditingController(text: user.availability.join(', '));
    publicProfile = user.visibilityPublic;
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.controller.currentUser;
    return _AdaptiveColumns(
      left: _LumioCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PanelTitle(
              icon: Icons.account_circle_outlined,
              title: 'Profile Management',
            ),
            const SizedBox(height: 18),
            _ProfileHeader(user: user),
            const SizedBox(height: 18),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: major,
              decoration: const InputDecoration(labelText: 'Academic role'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: skills,
              decoration: const InputDecoration(labelText: 'Skills'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: interests,
              decoration: const InputDecoration(
                labelText: 'Academic interests',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: availability,
              decoration: const InputDecoration(
                labelText: 'Weekly availability',
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Public discovery profile',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text('Visible to peers in matchmaking'),
              value: publicProfile,
              onChanged: (value) => setState(() => publicProfile = value),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () {
                  widget.controller.updateProfile(
                    name: name.text.trim(),
                    major: major.text.trim(),
                    skills: _split(skills.text),
                    interests: _split(interests.text),
                    availability: _split(availability.text),
                    visibilityPublic: publicProfile,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile saved')),
                  );
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Profile'),
              ),
            ),
          ],
        ),
      ),
      right: Column(
        children: [
          _LumioCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PanelTitle(
                  icon: Icons.security_outlined,
                  title: 'Role Access',
                ),
                const SizedBox(height: 14),
                _ListRow(
                  icon: Icons.verified_user_outlined,
                  title: user.role.label,
                  detail: user.email,
                ),
                _ListRow(
                  icon: Icons.visibility_outlined,
                  title: publicProfile ? 'Discoverable' : 'Private',
                  detail: 'Profile visibility control',
                ),
                _ListRow(
                  icon: Icons.key_outlined,
                  title: 'Session',
                  detail: 'Local JWT-style demo session',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _LumioCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PanelTitle(
                  icon: Icons.class_outlined,
                  title: 'Enrolled Courses',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.controller.courses
                      .where((course) => user.courses.contains(course.id))
                      .map(
                        (course) => _StatusPill(
                          label: '${course.code} ${course.title}',
                          color: LumioTheme.blue,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchmakingScreen extends StatelessWidget {
  const _MatchmakingScreen({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.currentRole == UserRole.instructor) {
      return _InstructorMatchmaking(controller: controller);
    }
    final matches = controller.peerMatches;
    return _AdaptiveColumns(
      left: Column(
        children: [
          _LumioCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PanelTitle(
                  icon: Icons.hub_outlined,
                  title: 'Peer Discovery',
                ),
                const SizedBox(height: 12),
                _MatchmakingNotificationBar(controller: controller),
                const SizedBox(height: 16),
                ...matches.map(
                  (match) =>
                      _PeerMatchCard(controller: controller, match: match),
                ),
              ],
            ),
          ),
        ],
      ),
      right: Column(
        children: [
          _SyncInboxPanel(controller: controller),
          const SizedBox(height: 18),
          _SentSyncRequestsPanel(controller: controller),
          const SizedBox(height: 18),
          _SkillGapPanel(controller: controller, matches: matches),
        ],
      ),
    );
  }
}

class _InstructorMatchmaking extends StatelessWidget {
  const _InstructorMatchmaking({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LumioCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PanelTitle(
                icon: Icons.groups_3_outlined,
                title: 'Group Formation Oversight',
              ),
              const SizedBox(height: 16),
              ...controller.groups.map((group) {
                final members = controller.users
                    .where((user) => group.memberIds.contains(user.id))
                    .toList();
                final skills = members
                    .expand((member) => member.skills)
                    .map((skill) => skill.toLowerCase())
                    .toSet();
                final gaps = group.requiredSkills
                    .where((skill) => !skills.contains(skill.toLowerCase()))
                    .toList();
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: _softBox(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              group.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _StatusPill(
                            label: '${(group.progress * 100).round()}%',
                            color: LumioTheme.teal,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: members
                            .map(
                              (member) => _StatusPill(
                                label: member.name,
                                color: LumioTheme.blue,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        gaps.isEmpty
                            ? 'Skill coverage complete'
                            : 'Missing: ${gaps.join(', ')}',
                        style: TextStyle(
                          color: gaps.isEmpty
                              ? LumioTheme.teal
                              : LumioTheme.coral,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _PeerMatchCard extends StatelessWidget {
  const _PeerMatchCard({required this.controller, required this.match});

  final LumioController controller;
  final PeerMatch match;

  @override
  Widget build(BuildContext context) {
    final alreadySent = controller.requests.any(
      (request) =>
          request.fromUserId == controller.currentUser.id &&
          request.toUserId == match.user.id &&
          request.status == RequestStatus.pending,
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _softBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(user: match.user),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      match.user.major,
                      style: const TextStyle(
                        color: LumioTheme.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _ScoreBadge(score: match.score),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: match.score / 100, minHeight: 8),
          const SizedBox(height: 12),
          _ChipLine(title: 'Skill overlap', values: match.skillOverlap),
          _ChipLine(title: 'Availability', values: match.availabilityOverlap),
          _ChipLine(title: 'Interests', values: match.interestOverlap),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: alreadySent
                  ? null
                  : () => controller.sendSyncRequest(match),
              icon: Icon(
                alreadySent
                    ? Icons.hourglass_top_outlined
                    : Icons.send_outlined,
              ),
              label: Text(alreadySent ? 'Pending' : 'Send Sync Request'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchmakingNotificationBar extends StatelessWidget {
  const _MatchmakingNotificationBar({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    final count = controller.pendingIncomingSyncCount;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: count > 0
            ? LumioTheme.amber.withValues(alpha: 0.10)
            : LumioTheme.mint,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: count > 0
              ? LumioTheme.amber.withValues(alpha: 0.24)
              : const Color(0xFFD7EFEB),
        ),
      ),
      child: Row(
        children: [
          _NotificationIcon(count: count),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count == 0
                      ? 'No new sync invitations'
                      : '$count sync invitation${count == 1 ? '' : 's'} waiting',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Only requests sent directly to you appear in this inbox.',
                  style: TextStyle(color: LumioTheme.muted, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: LumioTheme.line),
          ),
          child: const Icon(
            Icons.notifications_active_outlined,
            color: LumioTheme.teal,
          ),
        ),
        if (count > 0)
          Positioned(
            right: -5,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: LumioTheme.coral,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SyncInboxPanel extends StatelessWidget {
  const _SyncInboxPanel({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    final incoming = controller.incomingSyncRequests;
    return _LumioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _PanelTitle(
                  icon: Icons.mark_email_unread_outlined,
                  title: 'Request Inbox',
                ),
              ),
              _NotificationIcon(count: controller.pendingIncomingSyncCount),
            ],
          ),
          const SizedBox(height: 12),
          if (incoming.isEmpty)
            const _ListRow(
              icon: Icons.inbox_outlined,
              title: 'No received requests',
              detail: 'Invitations from other students will appear here.',
            ),
          ...incoming.take(5).map((request) {
            final from = controller.users.firstWhere(
              (user) => user.id == request.fromUserId,
            );
            final to = controller.users.firstWhere(
              (user) => user.id == request.toUserId,
            );
            return _ListRow(
              icon: Icons.link_outlined,
              title: '${from.name} -> ${to.name}',
              detail: request.message,
              trailing: request.status == RequestStatus.pending
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Accept',
                          onPressed: () {
                            final ok = controller.updateRequestStatus(
                              request.id,
                              RequestStatus.accepted,
                            );
                            if (!ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Only the recipient can respond to this request.',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.check_circle_outline,
                            color: LumioTheme.teal,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Decline',
                          onPressed: () {
                            final ok = controller.updateRequestStatus(
                              request.id,
                              RequestStatus.declined,
                            );
                            if (!ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Only the recipient can respond to this request.',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: LumioTheme.coral,
                          ),
                        ),
                      ],
                    )
                  : _StatusPill(
                      label: request.status.label,
                      color: request.status == RequestStatus.accepted
                          ? LumioTheme.teal
                          : LumioTheme.coral,
                    ),
            );
          }),
        ],
      ),
    );
  }
}

class _SentSyncRequestsPanel extends StatelessWidget {
  const _SentSyncRequestsPanel({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    final outgoing = controller.outgoingSyncRequests;
    return _LumioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.outbox_outlined,
            title: 'Sent Requests',
          ),
          const SizedBox(height: 12),
          if (outgoing.isEmpty)
            const _ListRow(
              icon: Icons.send_outlined,
              title: 'No sent requests',
              detail: 'Send a sync invitation from peer discovery.',
            ),
          ...outgoing.take(5).map((request) {
            final to = controller.users.firstWhere(
              (user) => user.id == request.toUserId,
            );
            return _ListRow(
              icon: Icons.send_outlined,
              title: 'To ${to.name}',
              detail: request.message,
              trailing: _StatusPill(
                label: request.status.label,
                color: request.status == RequestStatus.accepted
                    ? LumioTheme.teal
                    : request.status == RequestStatus.declined
                    ? LumioTheme.coral
                    : LumioTheme.amber,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SkillGapPanel extends StatelessWidget {
  const _SkillGapPanel({required this.controller, required this.matches});

  final LumioController controller;
  final List<PeerMatch> matches;

  @override
  Widget build(BuildContext context) {
    final best = matches.isEmpty ? null : matches.first;
    return _LumioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.extension_outlined,
            title: 'Skill Gap Analysis',
          ),
          const SizedBox(height: 12),
          _ChipLine(
            title: 'Required',
            values: controller.activeGroup.requiredSkills,
          ),
          const SizedBox(height: 8),
          if (best != null)
            _ChipLine(
              title: 'After best match',
              values: best.missingSkills.isEmpty
                  ? const ['Covered']
                  : best.missingSkills,
            ),
        ],
      ),
    );
  }
}

class _ChatbotScreen extends StatefulWidget {
  const _ChatbotScreen({required this.controller});

  final LumioController controller;

  @override
  State<_ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<_ChatbotScreen> {
  final question = TextEditingController();
  final title = TextEditingController();
  final tags = TextEditingController();
  final content = TextEditingController();

  @override
  void dispose() {
    question.dispose();
    title.dispose();
    tags.dispose();
    content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AdaptiveColumns(
      left: _LumioCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PanelTitle(
              icon: Icons.smart_toy_outlined,
              title: 'RAG Academic Chatbot',
            ),
            const SizedBox(height: 14),
            Container(
              constraints: const BoxConstraints(minHeight: 430),
              child: Column(
                children: [
                  ...widget.controller.chat.map(
                    (message) => _ChatBubble(message: message),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: question,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Ask from course resources',
                      suffixIcon: IconButton(
                        tooltip: 'Send',
                        icon: const Icon(Icons.send_outlined),
                        onPressed: _send,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      right: _LumioCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PanelTitle(
              icon: Icons.library_add_outlined,
              title: 'Knowledge Base',
            ),
            const SizedBox(height: 14),
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Resource title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: tags,
              decoration: const InputDecoration(labelText: 'Tags'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: content,
              minLines: 6,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Course material text',
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () {
                  if (title.text.trim().isEmpty ||
                      content.text.trim().isEmpty) {
                    return;
                  }
                  widget.controller.addResource(
                    title: title.text.trim(),
                    content: content.text.trim(),
                    tags: _split(tags.text),
                    type: 'Text',
                  );
                  title.clear();
                  tags.clear();
                  content.clear();
                },
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Ingest'),
              ),
            ),
            const SizedBox(height: 18),
            ...widget.controller.activeResources
                .take(4)
                .map(
                  (resource) => _ListRow(
                    icon: Icons.article_outlined,
                    title: resource.title,
                    detail: resource.summary,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  void _send() {
    final text = question.text.trim();
    if (text.isEmpty) return;
    widget.controller.askChatbot(text);
    question.clear();
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final assistant = message.sender == 'assistant';
    return Align(
      alignment: assistant ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        width: MediaQuery.sizeOf(context).width < 760 ? double.infinity : null,
        constraints: const BoxConstraints(maxWidth: 700),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: assistant ? LumioTheme.mint : LumioTheme.ink,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: assistant ? const Color(0xFFCDEBE6) : LumioTheme.ink,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: assistant ? LumioTheme.ink : Colors.white,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            if (message.citations.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: message.citations
                    .map(
                      (citation) =>
                          _StatusPill(label: citation, color: LumioTheme.blue),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkspaceScreen extends StatefulWidget {
  const _WorkspaceScreen({required this.controller});

  final LumioController controller;

  @override
  State<_WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<_WorkspaceScreen> {
  final title = TextEditingController();
  final description = TextEditingController();
  String? assignee;
  TaskPriority priority = TaskPriority.medium;

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assignee ??= widget.controller.activeGroupMembers.first.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LumioCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PanelTitle(
                icon: Icons.add_task_outlined,
                title: 'Task Manager',
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    child: TextField(
                      controller: title,
                      decoration: const InputDecoration(
                        labelText: 'Task title',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: TextField(
                      controller: description,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 210,
                    child: DropdownButtonFormField<String>(
                      initialValue: assignee,
                      decoration: const InputDecoration(labelText: 'Assignee'),
                      items: widget.controller.activeGroupMembers
                          .map(
                            (user) => DropdownMenuItem(
                              value: user.id,
                              child: Text(
                                user.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => assignee = value),
                    ),
                  ),
                  SizedBox(
                    width: 170,
                    child: DropdownButtonFormField<TaskPriority>(
                      initialValue: priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: TaskPriority.values
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(
                        () => priority = value ?? TaskPriority.medium,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      if (title.text.trim().isEmpty) return;
                      widget.controller.addTask(
                        title: title.text.trim(),
                        description: description.text.trim(),
                        assigneeId:
                            assignee ?? widget.controller.currentUser.id,
                        priority: priority,
                      );
                      title.clear();
                      description.clear();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Task'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 980;
            final columns = TaskStatus.values
                .map(
                  (status) => _KanbanColumn(
                    controller: widget.controller,
                    status: status,
                  ),
                )
                .toList();
            if (compact) {
              return Column(
                children: columns
                    .map(
                      (column) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: column,
                      ),
                    )
                    .toList(),
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columns
                  .map(
                    (column) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: column,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({required this.controller, required this.status});

  final LumioController controller;
  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final items = controller.activeTasks
        .where((task) => task.status == status)
        .toList();
    return _LumioCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  status.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              _StatusPill(
                label: '${items.length}',
                color: _statusColor(status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No tasks',
                  style: TextStyle(color: LumioTheme.muted),
                ),
              ),
            ),
          ...items.map((task) => _TaskCard(controller: controller, task: task)),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.controller, required this.task});

  final LumioController controller;
  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    final assignee = controller.users.firstWhere(
      (user) => user.id == task.assigneeId,
      orElse: () => controller.currentUser,
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: _softBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              _StatusPill(
                label: task.priority.label,
                color: _priorityColor(task.priority),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.description,
            style: const TextStyle(color: LumioTheme.muted, height: 1.35),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Avatar(user: assignee, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${assignee.name} / ${DateFormat('MMM d').format(task.dueDate)}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              if (task.status != TaskStatus.todo)
                IconButton(
                  tooltip: 'Move back',
                  onPressed: () => controller.moveTask(
                    task.id,
                    TaskStatus.values[task.status.index - 1],
                  ),
                  icon: const Icon(Icons.chevron_left),
                ),
              if (task.status != TaskStatus.completed)
                IconButton(
                  tooltip: 'Move forward',
                  onPressed: () => controller.moveTask(
                    task.id,
                    TaskStatus.values[task.status.index + 1],
                  ),
                  icon: const Icon(Icons.chevron_right),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummarizerScreen extends StatefulWidget {
  const _SummarizerScreen({required this.controller});

  final LumioController controller;

  @override
  State<_SummarizerScreen> createState() => _SummarizerScreenState();
}

class _SummarizerScreenState extends State<_SummarizerScreen> {
  final title = TextEditingController(text: 'Sprint Planning Meeting');
  final transcript = TextEditingController(
    text:
        'We agreed to keep the Firebase repository separate from UI code. '
        'Saqlain will complete RAG retrieval and citations by Friday. '
        'Muazim will polish the Flutter dashboard and workspace board. '
        'Decision: instructor analytics must show contribution threshold alerts. '
        'Action item: Hina will validate acceptance criteria before the demo.',
  );

  @override
  void dispose() {
    title.dispose();
    transcript.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final latest = widget.controller.meetings.isNotEmpty
        ? widget.controller.meetings.first
        : null;
    return _AdaptiveColumns(
      left: _LumioCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PanelTitle(
              icon: Icons.summarize_outlined,
              title: 'AI Meeting Summarizer',
            ),
            const SizedBox(height: 14),
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Meeting title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: transcript,
              minLines: 12,
              maxLines: 18,
              decoration: const InputDecoration(
                labelText: 'Transcript or meeting log',
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () {
                  widget.controller.summarizeMeeting(
                    title: title.text,
                    transcript: transcript.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Meeting summarized and tasks extracted'),
                    ),
                  );
                },
                icon: const Icon(Icons.auto_fix_high_outlined),
                label: const Text('Summarize'),
              ),
            ),
          ],
        ),
      ),
      right: Column(
        children: [
          if (latest != null) _MeetingSummaryCard(summary: latest),
          const SizedBox(height: 18),
          _LumioCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PanelTitle(
                  icon: Icons.archive_outlined,
                  title: 'Summary Archive',
                ),
                const SizedBox(height: 12),
                ...widget.controller.meetings
                    .take(5)
                    .map(
                      (meeting) => _ListRow(
                        icon: Icons.description_outlined,
                        title: meeting.title,
                        detail:
                            '${meeting.decisions.length} decisions / ${meeting.actionItems.length} actions',
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MeetingSummaryCard extends StatelessWidget {
  const _MeetingSummaryCard({required this.summary});

  final MeetingSummary summary;

  @override
  Widget build(BuildContext context) {
    return _LumioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(icon: Icons.fact_check_outlined, title: summary.title),
          const SizedBox(height: 12),
          _BulletSection(title: 'Agenda', items: summary.agendaItems),
          _BulletSection(title: 'Decisions', items: summary.decisions),
          _BulletSection(title: 'Action Items', items: summary.actionItems),
        ],
      ),
    );
  }
}

class _ResourcesScreen extends StatefulWidget {
  const _ResourcesScreen({required this.controller});

  final LumioController controller;

  @override
  State<_ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<_ResourcesScreen> {
  final query = TextEditingController();
  final title = TextEditingController();
  final tags = TextEditingController();
  final content = TextEditingController();

  @override
  void dispose() {
    query.dispose();
    title.dispose();
    tags.dispose();
    content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = query.text.toLowerCase();
    final items = widget.controller.activeResources.where((resource) {
      return q.isEmpty ||
          resource.title.toLowerCase().contains(q) ||
          resource.tags.any((tag) => tag.toLowerCase().contains(q)) ||
          resource.summary.toLowerCase().contains(q);
    }).toList();
    return _AdaptiveColumns(
      left: _LumioCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PanelTitle(
              icon: Icons.folder_copy_outlined,
              title: 'Shared Notes and Resources',
            ),
            const SizedBox(height: 14),
            TextField(
              controller: query,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Search by tag, title, or summary',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            ...items.map((resource) => _ResourceCard(resource: resource)),
          ],
        ),
      ),
      right: _LumioCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PanelTitle(
              icon: Icons.note_add_outlined,
              title: 'Collaborative Note',
            ),
            const SizedBox(height: 14),
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: tags,
              decoration: const InputDecoration(labelText: 'Tags'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: content,
              minLines: 9,
              maxLines: 14,
              decoration: const InputDecoration(labelText: 'Note content'),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () {
                  if (title.text.trim().isEmpty ||
                      content.text.trim().isEmpty) {
                    return;
                  }
                  widget.controller.addResource(
                    title: title.text.trim(),
                    content: content.text.trim(),
                    tags: _split(tags.text),
                    type: 'Note',
                  );
                  title.clear();
                  tags.clear();
                  content.clear();
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Note'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({required this.resource});

  final ResourceItem resource;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _softBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  resource.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              _StatusPill(
                label: 'v${resource.version}',
                color: LumioTheme.blue,
              ),
              const SizedBox(width: 8),
              _StatusPill(label: resource.type, color: LumioTheme.amber),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            resource.summary,
            style: const TextStyle(color: LumioTheme.muted, height: 1.35),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: resource.tags
                .map((tag) => _StatusPill(label: tag, color: LumioTheme.teal))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _InsightsScreen extends StatelessWidget {
  const _InsightsScreen({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    return _AdaptiveColumns(
      left: Column(
        children: [
          _LumioCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PanelTitle(
                  icon: Icons.insights_outlined,
                  title: 'Personalized Insights',
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 260,
                  child: _EngagementLineChart(users: [controller.currentUser]),
                ),
                const SizedBox(height: 16),
                ...controller.studyRecommendations.map(
                  (item) => _ListRow(
                    icon: Icons.auto_awesome_outlined,
                    title: item,
                    detail: 'Weekly digest item',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      right: Column(
        children: [
          _LumioCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PanelTitle(
                  icon: Icons.compare_arrows_outlined,
                  title: 'Peer Benchmark',
                ),
                const SizedBox(height: 14),
                _BenchmarkRow(
                  label: 'Contribution',
                  value: controller.currentUser.contributionScore,
                  average: controller.averageContribution,
                ),
                _BenchmarkRow(
                  label: 'Engagement',
                  value: controller.currentUser.engagementScore,
                  average: 71,
                ),
                _BenchmarkRow(
                  label: 'Task Completion',
                  value: controller.taskCompletionRate * 100,
                  average: 62,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _LumioCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PanelTitle(
                  icon: Icons.schedule_outlined,
                  title: 'Study Schedule',
                ),
                const SizedBox(height: 12),
                ...controller.activeTasks
                    .where((task) => task.status != TaskStatus.completed)
                    .take(4)
                    .map(
                      (task) => _ListRow(
                        icon: Icons.radio_button_checked,
                        title: task.title,
                        detail:
                            '${task.priority.label} / ${DateFormat('MMM d').format(task.dueDate)}',
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenchmarkRow extends StatelessWidget {
  const _BenchmarkRow({
    required this.label,
    required this.value,
    required this.average,
  });

  final String label;
  final double value;
  final double average;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${value.round()} / avg ${average.round()}',
                style: const TextStyle(
                  color: LumioTheme.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (value / 100).clamp(0, 1),
            minHeight: 8,
            color: value >= average ? LumioTheme.teal : LumioTheme.amber,
          ),
        ],
      ),
    );
  }
}

class _AnalyticsScreen extends StatelessWidget {
  const _AnalyticsScreen({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MetricGrid(
          children: [
            _MetricTile(
              icon: Icons.groups_outlined,
              label: 'Groups',
              value: '${controller.groups.length}',
              accent: LumioTheme.blue,
              detail: 'Active course teams',
            ),
            _MetricTile(
              icon: Icons.trending_up_outlined,
              label: 'Average Score',
              value: '${controller.averageContribution.round()}%',
              accent: LumioTheme.teal,
              detail: 'Contribution average',
            ),
            _MetricTile(
              icon: Icons.warning_amber_outlined,
              label: 'Free-Rider Alerts',
              value: '${controller.atRiskStudents.length}',
              accent: LumioTheme.coral,
              detail: 'Below threshold or high risk',
            ),
            _MetricTile(
              icon: Icons.folder_open_outlined,
              label: 'Reports',
              value: 'CSV',
              accent: LumioTheme.amber,
              detail: 'Export ready',
            ),
          ],
        ),
        const SizedBox(height: 18),
        _AdaptiveColumns(
          left: _LumioCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PanelTitle(
                  icon: Icons.bar_chart_outlined,
                  title: 'Contribution Analytics',
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 300,
                  child: _ContributionBarChart(
                    users: controller.students,
                    threshold: controller.freeRiderThreshold,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Text(
                      'Threshold',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Expanded(
                      child: Slider(
                        value: controller.freeRiderThreshold,
                        min: 35,
                        max: 85,
                        divisions: 10,
                        label: '${controller.freeRiderThreshold.round()}%',
                        onChanged: controller.setFreeRiderThreshold,
                      ),
                    ),
                    Text(
                      '${controller.freeRiderThreshold.round()}%',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),
          right: Column(
            children: [
              _LumioCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _PanelTitle(
                      icon: Icons.report_outlined,
                      title: 'Alerts',
                    ),
                    const SizedBox(height: 12),
                    ...controller.atRiskStudents.map(
                      (student) => _ListRow(
                        icon: Icons.priority_high_outlined,
                        title: student.name,
                        detail:
                            'Contribution ${student.contributionScore.round()} / Engagement ${student.engagementScore.round()}',
                        trailing: _StatusPill(
                          label: student.riskTier.label,
                          color: _riskColor(student.riskTier),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _LumioCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _PanelTitle(
                      icon: Icons.file_download_outlined,
                      title: 'Assessment Export',
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: controller.exportAnalyticsCsv()),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('CSV copied to clipboard'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy_outlined),
                      label: const Text('Copy CSV Report'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PredictionsScreen extends StatelessWidget {
  const _PredictionsScreen({required this.controller});

  final LumioController controller;

  @override
  Widget build(BuildContext context) {
    return _AdaptiveColumns(
      left: _LumioCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PanelTitle(
              icon: Icons.health_and_safety_outlined,
              title: 'Predictive Engagement',
            ),
            const SizedBox(height: 16),
            ...controller.students.map((student) => _RiskCard(user: student)),
          ],
        ),
      ),
      right: _LumioCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PanelTitle(
              icon: Icons.lightbulb_outline,
              title: 'Intervention Panel',
            ),
            const SizedBox(height: 12),
            ...controller.atRiskStudents.map((student) {
              final action = switch (student.riskTier) {
                RiskTier.high =>
                  'Schedule a check-in and rebalance task ownership.',
                RiskTier.medium =>
                  'Assign a visible task and monitor response latency.',
                RiskTier.low => 'Keep normal weekly monitoring.',
              };
              return _ListRow(
                icon: Icons.medical_information_outlined,
                title: student.name,
                detail: action,
                trailing: _StatusPill(
                  label: student.riskTier.label,
                  color: _riskColor(student.riskTier),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({required this.user});

  final LumioUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _softBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(user: user),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Predicted engagement ${user.engagementScore.round()}%',
                      style: const TextStyle(color: LumioTheme.muted),
                    ),
                  ],
                ),
              ),
              _StatusPill(
                label: user.riskTier.label,
                color: _riskColor(user.riskTier),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: _TinyTrend(
              values: user.engagementTrend,
              color: _riskColor(user.riskTier),
            ),
          ),
        ],
      ),
    );
  }
}

class _LumioCard extends StatelessWidget {
  const _LumioCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: padding, child: child),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: LumioTheme.teal),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1100
            ? 4
            : width >= 740
            ? 2
            : 1;
        final itemWidth = (width - ((columns - 1) * 14)) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.detail,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return _LumioCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: LumioTheme.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  detail,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: LumioTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdaptiveColumns extends StatelessWidget {
  const _AdaptiveColumns({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 940) {
          return Column(children: [left, const SizedBox(height: 18), right]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: left),
            const SizedBox(width: 18),
            Expanded(flex: 4, child: right),
          ],
        );
      },
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.icon,
    required this.title,
    required this.detail,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: LumioTheme.mint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 19, color: LumioTheme.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(color: LumioTheme.muted, height: 1.35),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final LumioUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Avatar(user: user, size: 58),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              Text(
                user.email,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: LumioTheme.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _StatusPill(
          label: user.role.label,
          color: user.role == UserRole.student
              ? LumioTheme.teal
              : LumioTheme.blue,
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user, this.size = 42});

  final LumioUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = user.role == UserRole.instructor
        ? LumioTheme.blue
        : LumioTheme.teal;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      alignment: Alignment.center,
      child: Text(
        user.avatarSeed,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    this.dark = false,
  });

  final String label;
  final Color color;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: dark
            ? color.withValues(alpha: 0.18)
            : color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: dark ? Colors.white : Color.lerp(color, LumioTheme.ink, 0.2),
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 80
        ? LumioTheme.teal
        : score >= 65
        ? LumioTheme.amber
        : LumioTheme.coral;
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 2),
      ),
      child: Text(
        '${score.round()}%',
        style: TextStyle(color: color, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _ChipLine extends StatelessWidget {
  const _ChipLine({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: LumioTheme.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: (values.isEmpty ? ['None'] : values)
                .map(
                  (value) => _StatusPill(label: value, color: LumioTheme.teal),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 7, color: LumioTheme.teal),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: LumioTheme.muted,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LumioMark extends StatelessWidget {
  const _LumioMark({this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: LumioTheme.teal,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.psychology_alt_outlined,
            color: Colors.white,
            size: size * 0.58,
          ),
          Positioned(
            right: size * 0.16,
            top: size * 0.15,
            child: Container(
              width: size * 0.18,
              height: size * 0.18,
              decoration: const BoxDecoration(
                color: LumioTheme.amber,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EngagementLineChart extends StatelessWidget {
  const _EngagementLineChart({required this.users});

  final List<LumioUser> users;

  @override
  Widget build(BuildContext context) {
    final palette = [
      LumioTheme.teal,
      LumioTheme.blue,
      LumioTheme.amber,
      LumioTheme.coral,
    ];
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (_) => const FlLine(color: LumioTheme.line),
        ),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: const LineTouchData(enabled: true),
        lineBarsData: users.asMap().entries.map((entry) {
          final trend = entry.value.engagementTrend;
          return LineChartBarData(
            spots: trend
                .asMap()
                .entries
                .map(
                  (point) =>
                      FlSpot(point.key.toDouble(), point.value.toDouble()),
                )
                .toList(),
            isCurved: true,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            color: palette[entry.key % palette.length],
            belowBarData: BarAreaData(
              show: entry.key == 0,
              color: palette[entry.key % palette.length].withValues(
                alpha: 0.08,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ContributionBarChart extends StatelessWidget {
  const _ContributionBarChart({required this.users, required this.threshold});

  final List<LumioUser> users;
  final double threshold;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: 100,
        minY: 0,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (_) => const FlLine(color: LumioTheme.line),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: threshold,
              color: LumioTheme.coral,
              strokeWidth: 1.2,
              dashArray: [6, 4],
            ),
          ],
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 34),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= users.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    users[index].avatarSeed,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: users.asMap().entries.map((entry) {
          final user = entry.value;
          final color = user.contributionScore < threshold
              ? LumioTheme.coral
              : LumioTheme.teal;
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: user.contributionScore,
                color: color,
                width: 18,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(5),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _TinyTrend extends StatelessWidget {
  const _TinyTrend({required this.values, required this.color});

  final List<int> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: values
                .asMap()
                .entries
                .map(
                  (entry) =>
                      FlSpot(entry.key.toDouble(), entry.value.toDouble()),
                )
                .toList(),
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.10),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _softBox() {
  return BoxDecoration(
    color: LumioTheme.surface,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: LumioTheme.line),
  );
}

IconData _sectionIcon(WorkspaceSection section) => switch (section) {
  WorkspaceSection.overview => Icons.dashboard_outlined,
  WorkspaceSection.profile => Icons.account_circle_outlined,
  WorkspaceSection.matchmaking => Icons.hub_outlined,
  WorkspaceSection.chatbot => Icons.smart_toy_outlined,
  WorkspaceSection.workspace => Icons.view_kanban_outlined,
  WorkspaceSection.summarizer => Icons.summarize_outlined,
  WorkspaceSection.resources => Icons.folder_copy_outlined,
  WorkspaceSection.insights => Icons.insights_outlined,
  WorkspaceSection.analytics => Icons.analytics_outlined,
  WorkspaceSection.predictions => Icons.health_and_safety_outlined,
};

IconData _activityIcon(String kind) => switch (kind) {
  'task' => Icons.task_alt_outlined,
  'resource' => Icons.article_outlined,
  'database' => Icons.storage_outlined,
  'analytics' => Icons.analytics_outlined,
  'meeting' => Icons.groups_outlined,
  'chat' => Icons.smart_toy_outlined,
  'matchmaking' => Icons.hub_outlined,
  _ => Icons.bolt_outlined,
};

Color _statusColor(TaskStatus status) => switch (status) {
  TaskStatus.todo => LumioTheme.amber,
  TaskStatus.inProgress => LumioTheme.blue,
  TaskStatus.completed => LumioTheme.teal,
};

Color _priorityColor(TaskPriority priority) => switch (priority) {
  TaskPriority.low => LumioTheme.teal,
  TaskPriority.medium => LumioTheme.blue,
  TaskPriority.high => LumioTheme.amber,
  TaskPriority.critical => LumioTheme.coral,
};

Color _riskColor(RiskTier tier) => switch (tier) {
  RiskTier.low => LumioTheme.teal,
  RiskTier.medium => LumioTheme.amber,
  RiskTier.high => LumioTheme.coral,
};

String _relative(DateTime time) {
  final delta = DateTime.now().difference(time);
  if (delta.inMinutes < 60) return '${delta.inMinutes}m ago';
  if (delta.inHours < 24) return '${delta.inHours}h ago';
  return '${delta.inDays}d ago';
}

List<String> _split(String value) {
  return value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}
