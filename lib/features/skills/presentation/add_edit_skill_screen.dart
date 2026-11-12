import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/app_theme.dart';
import 'package:skillswap/features/skills/data/repositories/skill_repository.dart';
import 'package:skillswap/features/skills/data/services/category_firestore_service.dart';
import 'package:skillswap/shared/enums/skill_type.dart';
import 'package:skillswap/shared/models/category_model.dart';
import 'package:skillswap/shared/models/skill_model.dart';

class AddEditSkillScreen extends StatefulWidget {
  const AddEditSkillScreen({
    super.key,
    required this.userId,
    required this.skillRepository,
    this.existingSkill,
    this.initialType,
  });

  final String userId;
  final SkillRepository skillRepository;
  final SkillModel? existingSkill;
  final SkillType? initialType;

  @override
  State<AddEditSkillScreen> createState() => _AddEditSkillScreenState();
}

class _AddEditSkillScreenState extends State<AddEditSkillScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late SkillType _selectedType;
  String? _selectedCategoryId;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    widget.skillRepository.ensureCategoriesSeeded();
    _selectedType = widget.existingSkill?.type ??
        widget.initialType ??
        SkillType.offered;
    _selectedCategoryId = widget.existingSkill?.categoryId;
    _titleController =
        TextEditingController(text: widget.existingSkill?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.existingSkill?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      setState(() => _errorMessage = 'Please select a category for this skill.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();

      if (widget.existingSkill == null) {
        final newSkill = SkillModel(
          id: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          categoryId: _selectedCategoryId!,
          ownerId: widget.userId,
          type: _selectedType,
          createdAt: now,
          updatedAt: now,
        );
        await widget.skillRepository.createSkill(newSkill);
      } else {
        await widget.skillRepository.updateSkill(widget.existingSkill!.id, {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'categoryId': _selectedCategoryId!,
          'type': _selectedType.toJson(),
        });
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Failed to save skill: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingSkill != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Skill' : 'Add New Skill'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Skill Type',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 10),
              SegmentedButton<SkillType>(
                segments: const [
                  ButtonSegment<SkillType>(
                    value: SkillType.offered,
                    label: Text('I can teach'),
                    icon: Icon(Icons.school_outlined),
                  ),
                  ButtonSegment<SkillType>(
                    value: SkillType.wanted,
                    label: Text('I want to learn'),
                    icon: Icon(Icons.lightbulb_outline),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (newSelection) {
                  setState(() => _selectedType = newSelection.first);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return _selectedType == SkillType.offered
                          ? AppColors.primary
                          : AppColors.accent;
                    }
                    return null;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return AppColors.onBackground;
                  }),
                ),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Skill Title',
                  hintText: 'e.g. Flutter Mobile Development, Spanish...',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a title.';
                  }
                  if (v.trim().length < 2) {
                    return 'Title must be at least 2 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              StreamBuilder<List<CategoryModel>>(
                stream: widget.skillRepository.watchCategories(),
                initialData: CategoryFirestoreService.defaultCategoryModels,
                builder: (context, snapshot) {
                  final categories = (snapshot.data != null && snapshot.data!.isNotEmpty)
                      ? snapshot.data!
                      : CategoryFirestoreService.defaultCategoryModels;

                  final hasValidSelection = _selectedCategoryId != null &&
                      categories.any((c) => c.id == _selectedCategoryId);
                  final effectiveValue =
                      hasValidSelection ? _selectedCategoryId : null;

                  return DropdownButtonFormField<String>(
                    initialValue: effectiveValue,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    hint: const Text('Select category'),
                    items: categories
                        .map(
                          (cat) => DropdownMenuItem<String>(
                            value: cat.id,
                            child: Text(
                              cat.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (catId) {
                      setState(() => _selectedCategoryId = catId);
                    },
                    validator: (v) =>
                        v == null ? 'Please select a category.' : null,
                  );
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: _selectedType == SkillType.offered
                      ? 'Describe your experience, what topics you can cover, and your teaching style...'
                      : 'Describe what you hope to learn, your current level, and your learning goals...',
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a description.';
                  }
                  if (v.trim().length < 10) {
                    return 'Description must be at least 10 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(isEditing ? 'Update Skill' : 'Create Skill'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
