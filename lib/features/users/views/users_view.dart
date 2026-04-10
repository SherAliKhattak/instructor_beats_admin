import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/admin_ui_constants.dart';
import 'package:instructor_beats_admin/core/input_validation.dart';
import 'package:instructor_beats_admin/core/formatters.dart';
import 'package:instructor_beats_admin/core/widgets/app_text_field.dart';
import 'package:instructor_beats_admin/core/widgets/empty_state_message.dart';
import 'package:instructor_beats_admin/core/widgets/pagination_controls.dart';
import 'package:instructor_beats_admin/core/widgets/section_header.dart';
import 'package:instructor_beats_admin/features/users/controllers/users_controller.dart';
import 'package:instructor_beats_admin/models/app_user_model.dart';

class UsersView extends GetView<UsersController> {
  const UsersView({super.key});

  Future<void> _editName(BuildContext context, AppUserModel u) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) =>
          _EditUserDisplayNameDialog(user: u, usersController: controller),
    );
  }

  Future<void> _add(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _AddUserDialog(usersController: controller),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppUserModel u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete user?'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await controller.deleteUser(u.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Users',
            trailing: FilledButton.icon(
              onPressed: () => _add(context),
              style: FilledButton.styleFrom(
                minimumSize: Size(0, AdminUi.controlHeight),
                maximumSize: Size(double.infinity, AdminUi.controlHeight),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Add user'),
            ),
          ),
          const SizedBox(height: 14),
          if (wide)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search name or email',
                    ),
                    onChanged: controller.setSearch,
                  ),
                ),
                const SizedBox(width: 12),
                const SizedBox.shrink(),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search name or email',
                  ),
                  onChanged: controller.setSearch,
                ),
                const SizedBox(height: 10),
                const SizedBox.shrink(),
              ],
            ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              controller.searchQuery.value;
              controller.currentPage.value;
              final items = controller.pageItems;
              final listEmpty = controller.filtered.isEmpty;
              if (listEmpty) {
                final noUsers = controller.data.users.isEmpty;
                return Column(
                  children: [
                    Expanded(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: EmptyStateMessage(
                          icon: Icons.people_outline_rounded,
                          title: noUsers
                              ? 'No members yet'
                              : 'No matching members',
                          message: noUsers
                              ? 'Tap Add user to invite someone. They will get a sign-in with the email and password you choose.'
                              : 'Try another search or clear the search box to see everyone.',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    PaginationControls(
                      currentPage: controller.currentPage.value,
                      totalItems: controller.filtered.length,
                      itemsPerPage: controller.itemsPerPage,
                      onPageChanged: controller.setPage,
                    ),
                  ],
                );
              }
              if (!wide) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final u = items[i];
                          return _UserCard(
                            user: u,
                            onEdit: () => _editName(context, u),
                            onToggle: () => controller.toggleDisabled(u),
                            onDelete: () => _confirmDelete(context, u),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    PaginationControls(
                      currentPage: controller.currentPage.value,
                      totalItems: controller.filtered.length,
                      itemsPerPage: controller.itemsPerPage,
                      onPageChanged: controller.setPage,
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth,
                                ),
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                  ),
                                  headingTextStyle: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    letterSpacing: 0.2,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                  dataTextStyle: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                  columnSpacing: 24,
                                  horizontalMargin: 18,
                                  headingRowHeight: 52,
                                  dataRowMinHeight: 56,
                                  dataRowMaxHeight: 62,
                                  dividerThickness: 0.5,
                                  columns: const [
                                    DataColumn(label: Text('Name')),
                                    DataColumn(label: Text('Email')),
                                    DataColumn(label: Text('Created')),
                                    DataColumn(label: Text('Status')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: List.generate(items.length, (i) {
                                    final u = items[i];
                                    return DataRow.byIndex(
                                      index: i,
                                      color: WidgetStateProperty.resolveWith(
                                        (_) => i.isEven
                                            ? Colors.transparent
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .surface
                                                  .withValues(alpha: 0.2),
                                      ),
                                      cells: [
                                        DataCell(Text(u.displayName)),
                                        DataCell(Text(u.email)),
                                        DataCell(
                                          Text(
                                            adminDateFormat.format(u.createdAt),
                                          ),
                                        ),
                                        DataCell(
                                          _StatusBadge(
                                            label: u.disabled
                                                ? 'Disabled'
                                                : 'Active',
                                            icon: u.disabled
                                                ? Icons.person_off_outlined
                                                : Icons.check_circle_outline,
                                            color: u.disabled
                                                ? Colors.orangeAccent
                                                : Colors.greenAccent,
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              _TableActionIcon(
                                                tooltip: 'Edit',
                                                onPressed: () =>
                                                    _editName(context, u),
                                                icon: Icons.edit_outlined,
                                              ),
                                              const SizedBox(width: 6),
                                              _TableActionIcon(
                                                tooltip: 'Delete',
                                                onPressed: () =>
                                                    _confirmDelete(context, u),
                                                icon: Icons.delete_outline,
                                                danger: true,
                                              ),
                                              const SizedBox(width: 6),
                                              TextButton(
                                                onPressed: () => controller
                                                    .toggleDisabled(u),
                                                child: Text(
                                                  u.disabled
                                                      ? 'Enable'
                                                      : 'Disable',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PaginationControls(
                    currentPage: controller.currentPage.value,
                    totalItems: controller.filtered.length,
                    itemsPerPage: controller.itemsPerPage,
                    onPageChanged: controller.setPage,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final AppUserModel user;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          user.displayName,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(user.email),
        trailing: Wrap(
          spacing: 0,
          children: [
            TextButton(onPressed: onEdit, child: const Text('Edit')),
            TextButton(
              onPressed: onToggle,
              child: Text(user.disabled ? 'Enable' : 'Disable'),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableActionIcon extends StatelessWidget {
  const _TableActionIcon({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.danger = false,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = danger ? Colors.redAccent : scheme.onSurfaceVariant;
    return Semantics(
      button: true,
      label: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

ButtonStyle _dialogOutlineStyle(ColorScheme scheme, double h) =>
    OutlinedButton.styleFrom(
      minimumSize: Size(0, h),
      maximumSize: Size(double.infinity, h),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      side: BorderSide(color: scheme.outline.withValues(alpha: 0.9)),
    );

ButtonStyle _dialogFilledStyle(double h) => FilledButton.styleFrom(
  minimumSize: Size(0, h),
  maximumSize: Size(double.infinity, h),
  padding: const EdgeInsets.symmetric(horizontal: 16),
);

class _AddUserDialog extends StatefulWidget {
  const _AddUserDialog({required this.usersController});

  final UsersController usersController;

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameC;
  late final TextEditingController _emailC;
  late final TextEditingController _passwordC;
  var _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController();
    _emailC = TextEditingController();
    _passwordC = TextEditingController();
  }

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      final ok = await widget.usersController.addUser(
        name: _nameC.text,
        email: _emailC.text,
        password: _passwordC.text,
      );
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop();
      } else {
        setState(() => _submitting = false);
      }
    } catch (_) {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final h = AdminUi.controlHeight;
    final titleStyle =
        Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800) ??
        TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        );

    return Dialog(
      backgroundColor: scheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 12, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add user', style: titleStyle),
                        const SizedBox(height: 6),
                        Text(
                          'Creates their sign-in and profile so they can use Instructor Beats.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              SizedBox(height: AdminUi.sectionGap),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthTextField(
                          label: 'Name',
                          placeholder: 'User name',
                          leadingIcon: Icons.person_outline_rounded,
                          controller: _nameC,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter a name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AdminUi.fieldGap),
                        AuthTextField(
                          label: 'Email',
                          placeholder: 'user@email.com',
                          leadingIcon: Icons.mail_outline_rounded,
                          controller: _emailC,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter an email';
                            }
                            if (!isPlausibleEmail(v.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AdminUi.fieldGap),
                        AuthTextField(
                          label: 'Password',
                          placeholder: 'At least 6 characters',
                          leadingIcon: Icons.lock_outline_rounded,
                          controller: _passwordC,
                          obscureText: true,
                          helperText: 'Used to sign in to the consumer app.',
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Enter a password';
                            }
                            if (v.length < 6) {
                              return 'Use at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: AdminUi.sectionGap),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: h,
                      child: OutlinedButton(
                        onPressed: _submitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: _dialogOutlineStyle(scheme, h),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: h,
                      child: FilledButton(
                        onPressed: _submitting ? null : _submit,
                        style: _dialogFilledStyle(h),
                        child: _submitting
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: scheme.onPrimary,
                                ),
                              )
                            : const Text('Add'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditUserDisplayNameDialog extends StatefulWidget {
  const _EditUserDisplayNameDialog({
    required this.user,
    required this.usersController,
  });

  final AppUserModel user;
  final UsersController usersController;

  @override
  State<_EditUserDisplayNameDialog> createState() =>
      _EditUserDisplayNameDialogState();
}

class _EditUserDisplayNameDialogState
    extends State<_EditUserDisplayNameDialog> {
  late final TextEditingController _c;
  var _submitting = false;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.user.displayName);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final ok = await widget.usersController.updateDisplayName(
        widget.user,
        _c.text,
      );
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop();
      } else {
        setState(() => _submitting = false);
      }
    } catch (_) {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final h = AdminUi.controlHeight;
    final titleStyle =
        Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800) ??
        TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        );

    return Dialog(
      backgroundColor: scheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 12, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Edit user', style: titleStyle),
                        const SizedBox(height: 6),
                        Text(
                          'Update how this user appears in the admin list.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              SizedBox(height: AdminUi.sectionGap),
              AuthTextField(
                label: 'Display name',
                placeholder: 'Enter display name',
                leadingIcon: Icons.person_outline_rounded,
                controller: _c,
              ),
              SizedBox(height: AdminUi.sectionGap),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: h,
                      child: OutlinedButton(
                        onPressed: _submitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: _dialogOutlineStyle(scheme, h),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: h,
                      child: FilledButton(
                        onPressed: _submitting ? null : _save,
                        style: _dialogFilledStyle(h),
                        child: _submitting
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: scheme.onPrimary,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
