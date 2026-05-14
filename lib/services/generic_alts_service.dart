import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class GenericAltItem {
  final String brandName;
  final double brandPrice;
  final String mappedGenericName;
  final double genericMrp;

  GenericAltItem({
    required this.brandName,
    required this.brandPrice,
    required this.mappedGenericName,
    required this.genericMrp,
  });
}

class GenericAltsService {
  static final GenericAltsService _instance = GenericAltsService._internal();

  factory GenericAltsService() {
    return _instance;
  }

  GenericAltsService._internal();

  List<GenericAltItem> _items = [];
  bool _isLoaded = false;
  bool _isLoading = false;

  bool get isLoaded => _isLoaded;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    if (_isLoaded || _isLoading) return;
    _isLoading = true;

    try {
      final csvString = await rootBundle.loadString('assets/generic_alternative.csv');
      _items = await compute(_parseCsv, csvString);
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading generic alternatives: $e');
    } finally {
      _isLoading = false;
    }
  }

  static List<GenericAltItem> _parseCsv(String csvString) {
    final lines = csvString.split('\n');
    final items = <GenericAltItem>[];

    // Skip header line (usually index 0)
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final row = _splitCsvLine(line);
      if (row.length >= 4) {
        items.add(GenericAltItem(
          brandName: row[0].trim(),
          brandPrice: double.tryParse(row[1]) ?? 0.0,
          mappedGenericName: row[2].trim(),
          genericMrp: double.tryParse(row[3]) ?? 0.0,
        ));
      }
    }
    return items;
  }

  static List<String> _splitCsvLine(String line) {
    if (!line.contains('"')) {
      return line.split(',');
    }
    List<String> result = [];
    StringBuffer current = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      String char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());
    return result;
  }

  List<GenericAltItem> search(String query, {int limit = 50}) {
    if (!_isLoaded || query.trim().isEmpty) return [];

    final q = query.toLowerCase().trim();
    final words = q.split(' ').where((w) => w.isNotEmpty).toList();

    // Score and filter
    final List<Map<String, dynamic>> scoredItems = [];

    for (final item in _items) {
      final brandLower = item.brandName.toLowerCase();
      final genericLower = item.mappedGenericName.toLowerCase();
      
      int score = 0;
      bool matchesAll = true;
      
      for (final word in words) {
        if (!brandLower.contains(word) && !genericLower.contains(word)) {
          matchesAll = false;
          break;
        }
        
        // Boost exact prefix match
        if (brandLower.startsWith(word) || genericLower.startsWith(word)) {
          score += 10;
        } else {
          score += 1;
        }
      }

      if (matchesAll) {
        scoredItems.add({'item': item, 'score': score});
      }
    }

    scoredItems.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    return scoredItems.take(limit).map((e) => e['item'] as GenericAltItem).toList();
  }
}
