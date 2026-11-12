import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/app_theme.dart';
import 'package:skillswap/features/skills/data/repositories/skill_repository.dart';
import 'package:skillswap/features/skills/data/services/category_firestore_service.dart';
import 'package:skillswap/features/skills/presentation/add_edit_skill_screen.dart';
import 'package:skillswap/features/skills/presentation/widgets/skill_card.dart';
import 'package:skillswap/shared/enums/skill_type.dart';
import 'package:skillswap/shared/models/category_model.dart';
import 'package:skillswap/shared/models/skill_model.dart';

class MySkillsScreen extends StatefulWidget {
  const MySkillsScreen({
    super.key,
    required this.userId,
    required this.skillRepository,
  });

  final String userId;
  final SkillRepository skillRepository;

  @override
  State<MySkillsScreen> createState() => _MySkillsScreenState();
}

class _MySkillsScreenState extends State<MySkillsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    widget.skillRepository.ensureCategoriesSeeded();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _navigateToAddSkill() async {
    final activeType =
        _tabController.index == 0 ? SkillType.offered : SkillType.wanted;

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditSkillScreen(
          userId: widget.userId,
          skillRepository: widget.skillRepository,
          initialType: activeType,
        ),
      ),
    );

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Skill created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _navigateToEditSkill(SkillModel skill) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditSkillScreen(
          userId: widget.userId,
          skillRepository: widget.skillRepository,
          existingSkill: skill,
        ),
      ),
    );

    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Skill updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _confirmDelete(SkillModel skill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Skill'),
        content: Text('Are you sure you want to delete "${skill.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.skillRepository.deleteSkill(skill.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Skill deleted.'),
              backgroundColor: AppColors.subtle,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete skill: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildSkillList({
    required SkillType type,
    required Map<String, String> categoryNames,
  }) {
    return StreamBuilder<List<SkillModel>>(
      stream: widget.skillRepository.watchUserSkills(
        widget.userId,
        type: type,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final skills = snapshot.data ?? [];

        if (skills.isEmpty) {
          final isOffered = type == SkillType.offered;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOffered
                        ? Icons.school_outlined
                        : Icons.lightbulb_outline,
                    size: 64,
                    color: AppColors.subtle.withAlpha(120),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isOffered
                        ? 'No skills offered yet'
                        : 'No wanted skills yet',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isOffered
                        ? 'Share what you can teach and start exchanging knowledge.'
                        : 'Add skills you want to learn to find matching teachers.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.subtle,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _navigateToAddSkill,
                    icon: const Icon(Icons.add),
                    label: Text(
                      isOffered ? 'Add Offered Skill' : 'Add Wanted Skill',
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: skills.length,
          itemBuilder: (context, index) {
            final skill = skills[index];
            final categoryName = categoryNames[skill.categoryId];

            return SkillCard(
              skill: skill,
              categoryName: categoryName,
              isOwner: true,
              onEdit: () => _navigateToEditSkill(skill),
              onDelete: () => _confirmDelete(skill),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoryModel>>(
      stream: widget.skillRepository.watchCategories(),
      initialData: CategoryFirestoreService.defaultCategoryModels,
      builder: (context, categorySnapshot) {
        final categories = categorySnapshot.data ??
            CategoryFirestoreService.defaultCategoryModels;
        final categoryMap = {for (final c in categories) c.id: c.name};

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Skills'),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: AppColors.accent,
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  icon: Icon(Icons.school_outlined, size: 20),
                  text: 'Offered (Teaching)',
                ),
                Tab(
                  icon: Icon(Icons.lightbulb_outline, size: 20),
                  text: 'Wanted (Learning)',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildSkillList(
                type: SkillType.offered,
                categoryNames: categoryMap,
              ),
              _buildSkillList(
                type: SkillType.wanted,
                categoryNames: categoryMap,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _navigateToAddSkill,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add Skill'),
          ),
        );
      },
    );
  }
}

