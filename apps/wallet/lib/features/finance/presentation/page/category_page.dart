import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/finance/application/category/category_cubit.dart';
import 'package:wallet/features/finance/application/category/category_state.dart';
import 'package:wallet/features/finance/presentation/views/category_editor_sheet.dart';
import 'package:wallet/features/finance/presentation/views/category_view.dart';
import 'package:wallet/generated/locale_keys.g.dart';

/// Reached from settings rather than from the tabs: it is set up once and
/// rarely revisited.
@RoutePage()
class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<CategoryCubit>()..start(),
    child: BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: Text(context.tr(LocaleKeys.categories_title))),
        floatingActionButton: state.isEmpty
            ? null
            : FloatingActionButton(
                onPressed: () => _add(context),
                tooltip: context.tr(LocaleKeys.categories_add),
                child: const Icon(Icons.add),
              ),
        body: state.loading
            ? const Center(child: CircularProgressIndicator())
            : CategoryView(
                active: state.active,
                archived: state.archived,
                onAdd: () => _add(context),
                onArchive: (category) =>
                    context.read<CategoryCubit>().archive(category.id),
                onRestore: (category) =>
                    context.read<CategoryCubit>().restore(category.id),
              ),
      ),
    ),
  );

  Future<void> _add(BuildContext context) async {
    final cubit = context.read<CategoryCubit>();
    final draft = await showModalBottomSheet<CategoryDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const CategoryEditorSheet(),
    );
    if (draft == null) return;

    await cubit.add(
      name: draft.name,
      icon: draft.icon,
      colorArgb: draft.colorArgb,
    );
  }
}
