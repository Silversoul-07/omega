import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/content_item.dart';
import '../../models/enums.dart';
import '../../models/profile_type.dart';
import '../../services/database_service.dart';
import 'dart:convert';

/// Full-form Add content screen with AI autofill option
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
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseService();

  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _totalController;
  late TextEditingController _categoryController;
  late TextEditingController _notesController;

  // Form state
  late ContentType _selectedType;
  late ContentStatus _selectedStatus;
  bool _isLoadingAI = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _totalController = TextEditingController(text: '0');
    _categoryController = TextEditingController();
    _notesController = TextEditingController();
    _selectedType = widget.selectedProfile?.contentType ?? ContentType.anime;
    _selectedStatus = ContentStatus.planToWatch;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _totalController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _autofillWithAI() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoadingAI = true);

    try {
      // TODO: Replace with user's API key from settings
      const apiKey = 'AIzaSyBTkAegcUu8FFXsIGbARLFmZ4VH9ot8wAg';

      if (apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
        throw Exception('Please add your Gemini API key in Settings');
      }

      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      final prompt = '''
You are a content metadata assistant. Given a title, return structured JSON data about it.

Title: "${_titleController.text}"
Type: ${_selectedType.displayName}

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

      // Autofill the form
      setState(() {
        if (parsed['title'] != null) {
          _titleController.text = parsed['title'];
        }
        if (parsed['totalEpisodes'] != null) {
          _totalController.text = parsed['totalEpisodes'].toString();
        }
        if (parsed['genres'] != null && (parsed['genres'] as List).isNotEmpty) {
          _categoryController.text = (parsed['genres'] as List).join(', ');
        }
        if (parsed['description'] != null) {
          _notesController.text = parsed['description'];
        }
        _isLoadingAI = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Autofilled with AI!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoadingAI = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveContent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final newItem = ContentItem(
        title: _titleController.text.trim(),
        type: _selectedType,
        status: _selectedStatus,
        progress: 0,
        total: int.tryParse(_totalController.text) ?? 0,
        category: _categoryController.text.trim().isNotEmpty
            ? _categoryController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      await _db.addContentItem(newItem);

      if (mounted) {
        // Clear form
        _titleController.clear();
        _totalController.text = '0';
        _categoryController.clear();
        _notesController.clear();
        setState(() {
          _selectedStatus = ContentStatus.planToWatch;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${newItem.title}" to library!'),
            backgroundColor: Colors.green,
          ),
        );

        // Switch to Library tab (index 3)
        DefaultTabController.of(context).animateTo(3);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field with AI button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        hintText: 'Enter content title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isLoadingAI ? null : _autofillWithAI,
                    icon: _isLoadingAI
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome),
                    tooltip: 'Autofill with AI',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Type dropdown
              DropdownButtonFormField<ContentType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: ContentType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_getTypeIcon(type), size: 20),
                        const SizedBox(width: 8),
                        Text(type.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 20),

              // Status dropdown
              DropdownButtonFormField<ContentStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.bookmark),
                ),
                items: ContentStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
              const SizedBox(height: 20),

              // Total episodes/chapters
              TextFormField(
                controller: _totalController,
                decoration: const InputDecoration(
                  labelText: 'Total Episodes/Chapters',
                  hintText: '0 if unknown',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final num = int.tryParse(value);
                    if (num == null || num < 0) {
                      return 'Must be a positive number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category/Genre
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category/Genre',
                  hintText: 'e.g., Action, Shonen, Fantasy',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
              ),
              const SizedBox(height: 20),

              // Notes/Description
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes/Description',
                  hintText: 'Add notes or description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _saveContent,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Add to Library',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Help text
              Center(
                child: Text(
                  '💡 Tip: Click the star icon to autofill with AI',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.anime:
        return Icons.animation;
      case ContentType.comic:
        return Icons.auto_stories;
      case ContentType.novel:
        return Icons.menu_book;
      case ContentType.movie:
        return Icons.movie;
      case ContentType.tvSeries:
        return Icons.tv;
    }
  }
}
