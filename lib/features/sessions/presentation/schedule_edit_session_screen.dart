import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skillswap/core/enums/enums.dart';
import 'package:skillswap/core/theme/app_theme.dart';
import 'package:skillswap/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:skillswap/features/sessions/data/repositories/session_repository.dart';
import 'package:skillswap/features/sessions/domain/entities/session.dart';
import 'package:skillswap/features/sessions/domain/entities/skill_swap.dart';
import 'package:skillswap/shared/models/skill_model.dart';
import 'package:skillswap/shared/models/user_model.dart';

class ScheduleEditSessionScreen extends StatefulWidget {
  const ScheduleEditSessionScreen({
    super.key,
    required this.swap,
    required this.user1,
    required this.user2,
    this.skillOfferedByUser1,
    this.skillOfferedByUser2,
    this.existingSession,
    this.sessionRepository,
  });

  final SkillSwap swap;
  final UserModel? user1;
  final UserModel? user2;
  final SkillModel? skillOfferedByUser1;
  final SkillModel? skillOfferedByUser2;
  final Session? existingSession;
  final SessionRepository? sessionRepository;

  @override
  State<ScheduleEditSessionScreen> createState() =>
      _ScheduleEditSessionScreenState();
}

class _ScheduleEditSessionScreenState extends State<ScheduleEditSessionScreen> {
  static const _durations = [30, 45, 60, 90, 120];

  final _formKey = GlobalKey<FormState>();
  late final SessionRepository _sessionRepository;
  late final TextEditingController _titleController;
  late final TextEditingController _meetingLinkController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;

  late String _instructorId;
  late SessionMode _mode;
  late int _durationInMinutes;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditing => widget.existingSession != null;

  @override
  void initState() {
    super.initState();
    _sessionRepository = widget.sessionRepository ?? SessionRepository();
    final existing = widget.existingSession;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _meetingLinkController =
        TextEditingController(text: existing?.meetingLink ?? '');
    _locationController = TextEditingController(text: existing?.location ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _instructorId = existing?.instructorId ?? widget.swap.user1Id;
    if (existing?.mode == SessionMode.hybrid) {
      _mode = existing!.hasPhysicalLocation && !existing.hasOnlineAccess
          ? SessionMode.inPerson
          : SessionMode.online;
    } else {
      _mode = existing?.mode ?? SessionMode.online;
    }
    _durationInMinutes = existing?.durationInMinutes ?? 60;
    if (existing != null) {
      _scheduledDate = DateTime(
        existing.scheduledStartTime.year,
        existing.scheduledStartTime.month,
        existing.scheduledStartTime.day,
      );
      _scheduledTime = TimeOfDay.fromDateTime(existing.scheduledStartTime);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _meetingLinkController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _displayName(UserModel? user, String fallback) {
    final name = user?.fullName.trim();
    if (name != null && name.isNotEmpty) return name;
    return fallback;
  }

  DateTime? get _combinedDateTime {
    final date = _scheduledDate;
    final time = _scheduledTime;
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _scheduledDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() => _scheduledDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _scheduledTime = picked);
    }
  }

  String? _validateUrl(String? value) {
    if (_mode == SessionMode.inPerson) return null;
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Please enter a meeting link.';
    final uri = Uri.tryParse(trimmed);
    final isValid = uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isValid) return 'Enter a valid http or https URL.';
    return null;
  }

  Future<void> _save() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    final start = _combinedDateTime;
    if (start == null) {
      setState(() => _errorMessage = 'Please pick a date and time.');
      return;
    }
    if (!start.isAfter(DateTime.now())) {
      setState(() => _errorMessage = 'Please choose a time in the future.');
      return;
    }

    final learnerId = _instructorId == widget.swap.user1Id
        ? widget.swap.user2Id
        : widget.swap.user1Id;
    final skillId = _instructorId == widget.swap.user1Id
        ? widget.swap.skillOfferedByUser1
        : widget.swap.skillOfferedByUser2;
    final notes = _notesController.text.trim();
    final meetingLink = _mode == SessionMode.inPerson
        ? null
        : _meetingLinkController.text.trim();
    final location = _mode == SessionMode.online
        ? null
        : _locationController.text.trim();

    setState(() => _isLoading = true);
    try {
      if (!_isEditing) {
        final now = DateTime.now();
        await _sessionRepository.createSession(
          Session(
            id: '',
            skillSwapId: widget.swap.id,
            instructorId: _instructorId,
            learnerId: learnerId,
            skillId: skillId,
            title: _titleController.text.trim(),
            scheduledStartTime: start,
            durationInMinutes: _durationInMinutes,
            mode: _mode,
            meetingLink: meetingLink,
            location: location,
            status: SessionStatus.upcoming,
            notes: notes.isEmpty ? null : notes,
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else {
        final existing = widget.existingSession!;
        final didReschedule =
            existing.scheduledStartTime != start;
        await _sessionRepository.updateSession(existing.id, {
          'instructorId': _instructorId,
          'learnerId': learnerId,
          'skillId': skillId,
          'title': _titleController.text.trim(),
          'scheduledStartTime': Timestamp.fromDate(start),
          'durationInMinutes': _durationInMinutes,
          'mode': _mode.toJson(),
          'meetingLink': meetingLink,
          'location': location,
          'notes': notes.isEmpty ? null : notes,
          'status': didReschedule
              ? SessionStatus.rescheduled.toJson()
              : existing.status.toJson(),
        });
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Failed to save session: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user1Name = _displayName(widget.user1, 'Partner 1');
    final user2Name = _displayName(widget.user2, 'Partner 2');
    final user1Skill = widget.skillOfferedByUser1?.title;
    final user2Skill = widget.skillOfferedByUser2?.title;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Session' : 'Schedule Session'),
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
              if (_errorMessage != null) ...[
                AuthErrorBanner(message: _errorMessage!),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title / Topic',
                  hintText: 'e.g. First Python practice',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a session topic.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Date & time',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                        _scheduledDate == null
                            ? 'Pick date'
                            : '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}',
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        _scheduledTime == null
                            ? 'Pick time'
                            : _scheduledTime!.format(context),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Duration',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _durations.map((minutes) {
                  final selected = _durationInMinutes == minutes;
                  final label = minutes == 120 ? '2 hrs' : '$minutes min';
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    selectedColor: AppColors.primary.withAlpha(40),
                    onSelected: (_) {
                      setState(() => _durationInMinutes = minutes);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Who is teaching?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 10),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment<String>(
                    value: widget.swap.user1Id,
                    label: Text(
                      user1Skill == null ? user1Name : '$user1Name\n$user1Skill',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                  ButtonSegment<String>(
                    value: widget.swap.user2Id,
                    label: Text(
                      user2Skill == null ? user2Name : '$user2Name\n$user2Skill',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ],
                selected: {_instructorId},
                onSelectionChanged: (selection) {
                  setState(() => _instructorId = selection.first);
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
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
              const SizedBox(height: 20),
              const Text(
                'Session mode',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 10),
              SegmentedButton<SessionMode>(
                segments: const [
                  ButtonSegment<SessionMode>(
                    value: SessionMode.online,
                    label: Text('Online'),
                    icon: Icon(Icons.videocam),
                  ),
                  ButtonSegment<SessionMode>(
                    value: SessionMode.inPerson,
                    label: Text('In-Person'),
                    icon: Icon(Icons.place),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) {
                  setState(() => _mode = selection.first);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
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
              const SizedBox(height: 16),
              if (_mode != SessionMode.inPerson)
                TextFormField(
                  controller: _meetingLinkController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Meeting link',
                    hintText: 'https://meet.google.com/...',
                    prefixIcon: Icon(Icons.link),
                  ),
                  validator: _validateUrl,
                ),
              if (_mode != SessionMode.online)
                TextFormField(
                  controller: _locationController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Address or venue',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                  validator: (value) {
                    if (_mode == SessionMode.online) return null;
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a location.';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Agenda, prep work, or extra details...',
                  alignLabelWithHint: true,
                ),
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
                    : Text(_isEditing ? 'Update Session' : 'Schedule Session'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
