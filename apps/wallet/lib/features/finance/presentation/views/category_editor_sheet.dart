import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wallet/features/finance/domain/models/category.dart';
import 'package:wallet/features/finance/presentation/format/category_icons.dart';
import 'package:wallet/generated/locale_keys.g.dart';

class CategoryDraft {
  const CategoryDraft({
    required this.name,
    required this.icon,
    required this.colorArgb,
  });

  final String name;
  final CategoryIcon icon;
  final int colorArgb;
}

/// The same set the seeded categories use, so one added by hand cannot look
/// out of place next to them.
const categoryPalette = <int>[
  0xFFE57373,
  0xFF64B5F6,
  0xFF81C784,
  0xFFFFB74D,
  0xFF4DB6AC,
  0xFFBA68C8,
  0xFF7986CB,
  0xFFA1887F,
  0xFF4FC3F7,
  0xFF66BB6A,
  0xFFF06292,
  0xFF9CCC65,
  0xFF90A4AE,
];

class CategoryEditorSheet extends StatefulWidget {
  const CategoryEditorSheet({super.key});

  @override
  State<CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<CategoryEditorSheet> {
  final TextEditingController _name = TextEditingController();

  CategoryIcon _icon = CategoryIcon.other;
  int _colorArgb = categoryPalette.last;
  bool _showError = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr(LocaleKeys.categories_add),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.tr(LocaleKeys.categories_name),
                errorText: _showError
                    ? context.tr(LocaleKeys.categories_invalid_name)
                    : null,
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            Text(
              context.tr(LocaleKeys.categories_icon),
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final icon in CategoryIcon.values)
                  IconButton(
                    onPressed: () => setState(() => _icon = icon),
                    isSelected: _icon == icon,
                    tooltip: context.tr(iconLabelKey(icon)),
                    icon: Icon(iconFor(icon)),
                    style: IconButton.styleFrom(
                      backgroundColor: _icon == icon
                          ? Color(_colorArgb).withValues(alpha: 0.16)
                          : null,
                      foregroundColor: _icon == icon ? Color(_colorArgb) : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              context.tr(LocaleKeys.categories_colour),
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                for (final (index, argb) in categoryPalette.indexed)
                  _ColorDot(
                    argb: argb,
                    label: context.tr(
                      LocaleKeys.categories_colour_indexed,
                      namedArgs: {'index': '${index + 1}'},
                    ),
                    selected: argb == _colorArgb,
                    onTap: () => setState(() => _colorArgb = argb),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: Text(context.tr(LocaleKeys.common_save)),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_name.text.trim().isEmpty) {
      setState(() => _showError = true);
      return;
    }
    Navigator.of(context).pop(
      CategoryDraft(
        name: _name.text,
        icon: _icon,
        colorArgb: _colorArgb,
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.argb,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  /// The dot people see. The tap target around it is larger — see [build].
  static const double _diameter = 40;

  final int argb;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    selected: selected,
    button: true,
    child: InkResponse(
      onTap: onTap,
      // A 40dp dot is the size the palette wants to look right; 48dp is the
      // size a thumb needs. The tap area is grown past the paint rather than
      // the dot being drawn bigger.
      radius: kMinInteractiveDimension / 2,
      child: SizedBox(
        width: kMinInteractiveDimension,
        height: kMinInteractiveDimension,
        child: Center(
          child: Container(
            width: _diameter,
            height: _diameter,
            decoration: BoxDecoration(
              color: Color(argb),
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 3,
                    )
                  : null,
            ),
            child: selected
                ? const Icon(Icons.check, size: 20, color: Colors.white)
                : null,
          ),
        ),
      ),
    ),
  );
}
