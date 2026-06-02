import 'package:flutter/material.dart';
import '../../models/homepage_config.dart';
import 'bdui_header.dart';
import 'bdui_balance_card.dart';
import 'bdui_menu_grid.dart';

class BduiRenderer {
  /// Dynamic UI compiler (JsonDrivenRenderer).
  /// Resolves the layout strings sent from the server into concrete, premium Flutter widgets.
  /// Falls back gracefully for unknown types to ensure maximum reliability and stability.
  static List<Widget> render(HomepageConfig config) {
    final List<Widget> widgets = [];

    for (final String type in config.layout) {
      switch (type.trim().toLowerCase()) {
        case 'header':
          widgets.add(
            BduiHeader(persona: config.persona),
          );
          break;
        case 'balance':
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BduiBalanceCard(persona: config.persona),
            ),
          );
          break;
        case 'features':
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BduiMenuGrid(prioritizedFeatures: config.features),
            ),
          );
          break;
        default:
          debugPrint('[BduiRenderer] Menemukan tipe widget tidak dikenal: "$type". Abaikan.');
          break;
      }
    }

    return widgets;
  }
}
