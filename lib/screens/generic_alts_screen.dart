import 'package:chikitsa/services/language_service.dart';
import 'package:chikitsa/services/generic_alts_service.dart';
import 'package:flutter/material.dart';

class GenericAltsScreen extends StatefulWidget {
  const GenericAltsScreen({super.key});

  @override
  State<GenericAltsScreen> createState() => _GenericAltsScreenState();
}

class _GenericAltsScreenState extends State<GenericAltsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _service = GenericAltsService();
  
  String _searchQuery = "";
  List<GenericAltItem> _results = [];
  bool _isLoadingService = true;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    await _service.loadData();
    if (mounted) {
      setState(() {
        _isLoadingService = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _results = _service.search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.current;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.get('GENERIC_TITLE')),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: lang.get('GENERIC_SEARCH_HINT'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged("");
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoadingService
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_searchQuery.isEmpty) ...[
                        // Recent Searches Header
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            lang.get('GENERIC_RECENT'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        _buildComparisonCard(
                          context,
                          brandName: 'Pan-D',
                          genericName: 'Pantoprazole + Domperidone',
                          brandPrice: 199,
                          genericPrice: 45,
                          // dosage info can be hardcoded or omitted for dummy recents
                        ),
                        _buildComparisonCard(
                          context,
                          brandName: 'Shelcal 500',
                          genericName: 'Calcium + Vitamin D3',
                          brandPrice: 140,
                          genericPrice: 60,
                        ),
                        _buildComparisonCard(
                          context,
                          brandName: 'Dolo 650',
                          genericName: 'Paracetamol 650mg',
                          brandPrice: 35,
                          genericPrice: 12,
                        ),
                      ] else if (_results.isNotEmpty) ...[
                        // Search Results
                        ..._results.map((item) => _buildComparisonCard(
                              context,
                              brandName: item.brandName,
                              genericName: item.mappedGenericName,
                              brandPrice: item.brandPrice,
                              genericPrice: item.genericMrp,
                            )),
                      ] else ...[
                        // No results
                        const SizedBox(height: 48),
                        const Center(
                          child: Text(
                            'No alternatives found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(
    BuildContext context, {
    required String brandName,
    required String genericName,
    required double brandPrice,
    required double genericPrice,
    String? dosage,
  }) {
    final theme = Theme.of(context);
    final lang = LanguageService.current;

    final savings = brandPrice - genericPrice;
    final savingsPercent = (savings / brandPrice * 100).round();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          // Header with Savings
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.savings, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${lang.get('GENERIC_SAVE')} $savingsPercent%',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (dosage != null) ...[
                  const Spacer(),
                  Text(
                    dosage,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Branded Side
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.get('GENERIC_BRAND'),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        brandName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${brandPrice.toInt()}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),

                // VS Divider
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

                // Generic Side
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        lang.get('GENERIC_ALT'),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        genericName,
                        textAlign: TextAlign.end,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${genericPrice.toInt()}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
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
