import 'package:wallet/app/features/finance/domain/models/category.dart';

/// On-disk shape of a category.
abstract final class CategoryDto {
  static const _id = 'id';
  static const _name = 'name';
  static const _icon = 'icon';
  static const _colorArgb = 'colorArgb';
  static const _archived = 'archived';

  static Map<String, dynamic> encode(Category category) => <String, dynamic>{
    _id: category.id,
    _name: category.name,
    _icon: category.icon.name,
    _colorArgb: category.colorArgb,
    _archived: category.archived,
  };

  static Category decode(Map<String, dynamic> record) => Category(
    id: record[_id] as String,
    name: record[_name] as String,
    icon: CategoryIcon.values.byName(record[_icon] as String),
    colorArgb: record[_colorArgb] as int,
    archived: record[_archived] as bool? ?? false,
  );
}
