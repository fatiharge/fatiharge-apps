import 'package:flutter/material.dart';
import 'package:wallet/config/injectable.dart';
import 'package:wallet/features/finance/domain/models/currency.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/presentation/views/setting_option_tile.dart';

/// Talks to the repository directly rather than through a cubit, the way the
/// language section does: nothing outside this screen reacts to the choice at
/// the moment it is made — the cubits read it when they are next built.
class CurrencySection extends StatefulWidget {
  const CurrencySection({super.key});

  @override
  State<CurrencySection> createState() => _CurrencySectionState();
}

class _CurrencySectionState extends State<CurrencySection> {
  final SettingsRepository _settings = getIt<SettingsRepository>();

  late Currency _selected = _settings.readCurrency();

  Future<void> _select(Currency currency) async {
    setState(() => _selected = currency);
    await _settings.writeCurrency(currency);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final currency in Currency.values)
        SettingOptionTile(
          icon: Icons.payments_outlined,
          label: '${currency.symbol}  ${currency.code}',
          selected: currency == _selected,
          onTap: () => _select(currency),
        ),
    ],
  );
}
