import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';
import 'package:memoria/models/item_model.dart';
import 'package:memoria/services/ai_service.dart';
import 'package:memoria/services/storage_service.dart';
import 'package:memoria/widgets/item_card.dart';

class SmartSearchScreen extends StatefulWidget {
  const SmartSearchScreen({super.key});

  @override
  State<SmartSearchScreen> createState() => _SmartSearchScreenState();
}

class _SmartSearchScreenState extends State<SmartSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SavedItem> _searchResults = [];
  List<SavedItem> _allItems = [];
  bool _isSearching = false;
  List<String> _recentSearches = [
    'Passport',
    'Bills from last month',
    'Medical receipts',
    'Travel documents',
  ];
  
  @override
  void initState() {
    super.initState();
    _loadItems();
  }
  
  void _loadItems() {
    _allItems = StorageService.getAllItems();
  }
  
  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
    });
    
    // Use AI smart search
    final results = AIService.smartSearch(_allItems, query);
    
    // Add to recent searches if not already present
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
    }
    
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }
  
  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Recent Searches',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          padding: const EdgeInsets.all(16),
          children: _recentSearches.map((search) {
            return GestureDetector(
              onTap: () {
                _searchController.text = search;
                _performSearch(search);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search, size: 14),
                    const SizedBox(width: 6),
                    Text(search),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildSearchExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Try searching for:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildExampleTile(
          icon: Icons.search,
          title: 'Find my passport',
          subtitle: 'Search for ID documents',
        ),
        _buildExampleTile(
          icon: Icons.receipt,
          title: 'Bills from last month',
          subtitle: 'Find recent bills',
        ),
        _buildExampleTile(
          icon: Icons.description,
          title: 'Receipt with ₹450',
          subtitle: 'Search by amount',
        ),
        _buildExampleTile(
          icon: Icons.note,
          title: 'Blue handwritten note',
          subtitle: 'Search by description',
        ),
      ],
    );
  }
  
  Widget _buildExampleTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.royalBlue),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        _searchController.text = title;
        _performSearch(title);
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Smart Search'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search naturally like: "Find my passport from last year"',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              onChanged: _performSearch,
              onSubmitted: _performSearch,
            ),
          ),
          
          // Results or Suggestions
          Expanded(
            child: _isSearching
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppConstants.royalBlue,
                    ),
                  )
                : _searchResults.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ItemCard(item: _searchResults[index]),
                          );
                        },
                      )
                    : ListView(
                        children: [
                          if (_searchController.text.isEmpty) ...[
                            _buildRecentSearches(),
                            const SizedBox(height: 24),
                            _buildSearchExamples(),
                          ] else
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 80,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No results found',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try different keywords or natural language',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.4),
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