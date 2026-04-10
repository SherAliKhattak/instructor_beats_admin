import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/admin_ui_constants.dart';
import 'package:instructor_beats_admin/core/formatters.dart';
import 'package:instructor_beats_admin/core/widgets/app_text_field.dart';
import 'package:instructor_beats_admin/core/widgets/empty_state_message.dart';
import 'package:instructor_beats_admin/core/widgets/pagination_controls.dart';
import 'package:instructor_beats_admin/core/widgets/section_header.dart';
import 'package:instructor_beats_admin/features/categories/controllers/categories_controller.dart';
import 'package:instructor_beats_admin/models/category_model.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  Future<void> _edit(BuildContext context, CategoryModel c) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _CategoryEditorDialog.edit(
        categoriesController: controller,
        category: c,
      ),
    );
  }

  Future<void> _add(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _CategoryEditorDialog.add(
        categoriesController: controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = controller.data;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Categories',
            trailing: FilledButton.icon(
              onPressed: () => _add(context),
              style: FilledButton.styleFrom(
                minimumSize: Size(0, AdminUi.controlHeight),
                maximumSize: Size(double.infinity, AdminUi.controlHeight),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add category'),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search category name',
            ),
            onChanged: controller.setSearch,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(
              () {
                controller.searchQuery.value;
                controller.currentPage.value;
                final items = controller.pageItems;
                final listEmpty = controller.filtered.isEmpty;
                return Column(
                  children: [
                    Expanded(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: listEmpty
                            ? EmptyStateMessage(
                                icon: Icons.category_outlined,
                                title: data.categories.isEmpty
                                    ? 'No categories yet'
                                    : 'No matching categories',
                                message: data.categories.isEmpty
                                    ? 'Use Add category to create labels for your music (for example HIIT or Yoga).'
                                    : 'Try another search or clear the search box to see all categories.',
                              )
                            : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (context, _) =>
                              const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final c = items[i];
                            final inUse =
                                data.songs.any((s) => s.categoryId == c.id);
                            return ListTile(
                              title: Text(
                                c.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                'Added ${adminDateFormat.format(c.createdAt)}'
                                '${inUse ? ' • In use' : ''}',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => _edit(context, c),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: inUse
                                        ? null
                                        : () async {
                                            final ok = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text(
                                                  'Delete category?',
                                                ),
                                                content: const Text(
                                                  'Only unused categories can be deleted (no songs use this category).',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          ctx,
                                                          false,
                                                        ),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  FilledButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          ctx,
                                                          true,
                                                        ),
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (ok == true) {
                                              controller.deleteCategory(c.id);
                                            }
                                          },
                                  ),
                                ],
                              ),
                            );
                          },
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
              },
            ),
          ),
        ],
      ),
    );
  }
}

ButtonStyle _categoryDialogOutline(ColorScheme scheme, double h) =>
    OutlinedButton.styleFrom(
      minimumSize: Size(0, h),
      maximumSize: Size(double.infinity, h),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      side: BorderSide(color: scheme.outline.withValues(alpha: 0.9)),
    );

ButtonStyle _categoryDialogFilled(double h) => FilledButton.styleFrom(
      minimumSize: Size(0, h),
      maximumSize: Size(double.infinity, h),
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );

class _CategoryEditorDialog extends StatefulWidget {
  const _CategoryEditorDialog._({
    required this.categoriesController,
    required this.isEdit,
    this.category,
  });

  factory _CategoryEditorDialog.add({
    required CategoriesController categoriesController,
  }) {
    return _CategoryEditorDialog._(
      categoriesController: categoriesController,
      isEdit: false,
    );
  }

  factory _CategoryEditorDialog.edit({
    required CategoriesController categoriesController,
    required CategoryModel category,
  }) {
    return _CategoryEditorDialog._(
      categoriesController: categoriesController,
      isEdit: true,
      category: category,
    );
  }

  final CategoriesController categoriesController;
  final bool isEdit;
  final CategoryModel? category;

  @override
  State<_CategoryEditorDialog> createState() => _CategoryEditorDialogState();
}

class _CategoryEditorDialogState extends State<_CategoryEditorDialog> {
  late final TextEditingController _c;
  var _submitting = false;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.category?.name ?? '');
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_submitting) return;
    final trimmed = _c.text.trim();
    if (trimmed.isEmpty) return;
    setState(() => _submitting = true);
    try {
      final ok = widget.isEdit
          ? await widget.categoriesController.updateCategory(
              widget.category!.id,
              trimmed,
            )
          : await widget.categoriesController.addCategory(trimmed);
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
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ) ??
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
                        Text(
                          widget.isEdit ? 'Edit category' : 'Add category',
                          style: titleStyle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.isEdit
                              ? 'Rename this category for all songs that use it.'
                              : 'Create a label used to group songs.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    height: 1.35,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed:
                        _submitting ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              SizedBox(height: AdminUi.sectionGap),
              AuthTextField(
                label: 'Category name',
                placeholder:
                    widget.isEdit ? 'e.g. HIIT' : 'e.g. Yoga',
                leadingIcon: Icons.category_outlined,
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
                        style: _categoryDialogOutline(scheme, h),
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
                        style: _categoryDialogFilled(h),
                        child: _submitting
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: scheme.onPrimary,
                                ),
                              )
                            : Text(widget.isEdit ? 'Save' : 'Add'),
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
