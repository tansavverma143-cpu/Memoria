import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/item_model.dart';
import 'package:memoria/services/storage_service.dart';
import 'package:memoria/widgets/item_card.dart';

class AutoCategorizationScreen extends StatefulWidget {
  const AutoCategorizationScreen({super.key});

  @override
  State<AutoCategorizationScreen> createState() => _AutoCategorizationScreenState();
}

class _AutoCategorizationScreenState extends State<AutoCategorizationScreen> {
  List<SavedItem> _uncategorizedItems = [];
  Map<String, List<SavedItem>> _categorizedItems = {};
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    _loadItems();
  }
  
  void _loadItems() {
    final allItems = StorageService.getAllItems();
    
    // Find uncategorized items
    _uncategorizedItems = allItems.where((item) => item.detectedCategory == null).toList();
    
    // Group categorized items
    _categorizedItems = {};
    for (final item in allItems) {
      if (item.detectedCategory != null) {
        _categorizedItems.putIfAbsent(item.detectedCategory!, () => []);
        _categorizedItems[item.detectedCategory]!.add(item);
      }
    }
  }
  
  Future<void> _processAll() async {
    setState(() {
      _isProcessing = true;
    });
    
    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 2));
    
    // In real app, call AI service here
    _loadItems();
    
    setState(() {
      _isProcessing = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Auto-Categorization'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _processAll,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Card
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppConstants.premiumGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                _buildStat('Total', StorageService.getAllItems().length.toString()),
                _buildStat('Uncategorized', _uncategorizedItems.length.toString()),
                _buildStat('Categories', _categorizedItems.keys.length.toString()),
              ],
            ),
          ),
          
          // Process Button
          if (_uncategorizedItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processAll,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: AppConstants.royalBlue,
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            'Process All with AI',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Tab Bar
          DefaultTabController(
            length: 2,
            child: Expanded(
              child: Column(
                children: [
                  TabBar(
                    tabs: const [
                      Tab(text: 'Uncategorized'),
                      Tab(text: 'Categorized'),
                    ],
                    indicatorColor: AppConstants.royalBlue,
                    labelColor: AppConstants.royalBlue,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Uncategorized Tab
                        _uncategorizedItems.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      size: 80,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'All items are categorized!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _uncategorizedItems.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: ItemCard(item: _uncategorizedItems[index]),
                                  );
                                },
                              ),
                        
                        // Categorized Tab
                        ListView(
                          children: _categorizedItems.entries.map((entry) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                  child: Text(
                                    '${entry.key} (${entry.value.length})',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ...entry.value.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    child: ItemCard(item: item),
                                  );
                                }).toList(),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
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
  
  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}