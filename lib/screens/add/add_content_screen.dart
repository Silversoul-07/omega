import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/content_item.dart';
import '../../models/enums.dart';
import '../../models/profile_type.dart';
import '../../services/database_service.dart';
import 'dart:convert';

/// Add content screen with AI autofill
class AddContentScreen extends StatefulWidget {
  final ProfileType? selectedProfile;

  const AddContentScreen({
    super.key,
    this.selectedProfile,
  });

  @override
  State<AddContentScreen> createState() => _AddContentScreenState();
}

class _AddContentScreenState extends State<AddContentScreen> {
  final _searchController = TextEditingController();
  final _db = DatabaseService();

  bool _isLoading = false;
  Map<String, dynamic>? _aiResult;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchWithAI() async {
    if (_searchController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a title');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _aiResult = null;
    });

    try {
      // TODO: Replace with user's API key from settings
      const apiKey = 'YOUR_GEMINI_API_KEY_HERE';

      if (apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
        throw Exception('Please add your Gemini API key in Settings');
      }

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      final contentType = widget.selectedProfile?.contentType.displayName ?? 'content';
      final prompt = '''
You are a content metadata assistant. Given a title, return structured JSON data about it.

Title: "${_searchController.text}"
Type: $contentType

Return ONLY valid JSON in this exact format (no markdown, no explanation):
{
  "title": "Clean title",
  "description": "Brief 1-2 sentence synopsis",
  "releaseYear": 2024,
  "genres": ["Genre1", "Genre2"],
  "totalEpisodes": 12,
  "creator": "Studio or Author name"
}

Important:
- Use null for unknown fields
- totalEpisodes: number of episodes/chapters/pages
- For movies: totalEpisodes is 1
- Keep description under 200 characters
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text == null) {
        throw Exception('No response from AI');
      }

      // Clean response (remove markdown code blocks if present)
      String jsonText = response.text!.trim();
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      }
      if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      jsonText = jsonText.trim();

      final parsed = jsonDecode(jsonText) as Map<String, dynamic>;

      setState(() {
        _aiResult = parsed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addToLibrary() async {
    if (_aiResult == null) return;

    try {
      final newItem = ContentItem(
        title: _aiResult!['title'] ?? _searchController.text,
        type: widget.selectedProfile?.contentType ?? ContentType.anime,
        status: ContentStatus.planToWatch,
        progress: 0,
        total: _aiResult!['totalEpisodes'] ?? 0,
        category: (_aiResult!['genres'] as List?)?.join(', '),
        notes: _aiResult!['description'],
      );

      await _db.addContentItem(newItem);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${newItem.title}" to library!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Content',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter title (e.g., "Attack on Titan Season 1")',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.auto_awesome),
                        onPressed: _searchWithAI,
                        tooltip: 'Search with AI',
                      ),
              ),
              onSubmitted: (_) => _searchWithAI(),
              enabled: !_isLoading,
            ),
          ),

          // Error message
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // AI Result
          if (_aiResult != null)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          _aiResult!['title'] ?? 'Unknown',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),

                        // Creator & Year
                        if (_aiResult!['creator'] != null || _aiResult!['releaseYear'] != null)
                          Text(
                            [
                              if (_aiResult!['creator'] != null) _aiResult!['creator'],
                              if (_aiResult!['releaseYear'] != null) _aiResult!['releaseYear'].toString(),
                            ].join(' • '),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        const SizedBox(height: 16),

                        // Description
                        if (_aiResult!['description'] != null) ...[
                          Text(
                            _aiResult!['description'],
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Genres
                        if (_aiResult!['genres'] != null && (_aiResult!['genres'] as List).isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (_aiResult!['genres'] as List).map((genre) {
                              return Chip(
                                label: Text(genre.toString()),
                                backgroundColor: widget.selectedProfile?.color.withOpacity(0.1),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Total episodes
                        if (_aiResult!['totalEpisodes'] != null)
                          ListTile(
                            leading: Icon(
                              Icons.format_list_numbered,
                              color: widget.selectedProfile?.color,
                            ),
                            title: const Text('Episodes/Chapters'),
                            trailing: Text(
                              _aiResult!['totalEpisodes'].toString(),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),

                        const SizedBox(height: 24),

                        // Add button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _addToLibrary,
                            icon: const Icon(Icons.add),
                            label: const Text('Add to Library'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Empty state
          if (!_isLoading && _aiResult == null && _error == null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 80,
                        color: widget.selectedProfile?.color.withOpacity(0.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'AI-Powered Quick Add',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enter a title and let AI autofill all the details for you',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
