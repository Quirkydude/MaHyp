import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/models/emergency_contact_model.dart';
import '../providers/emergency_contacts_provider.dart';

/// Emergency Contacts Page — manage doctor, family, and pharmacist contacts.
class EmergencyContactsPage extends ConsumerWidget {
  const EmergencyContactsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(emergencyContactsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Emergency Contacts',
        showBackButton: true,
      ),
      body: contactsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryTurquoise),
        ),
        error: (_, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              const Text('Could not load contacts'),
              TextButton(
                onPressed: () =>
                    ref.read(emergencyContactsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (contacts) => contacts.isEmpty
            ? _buildEmptyState(context, ref)
            : _buildList(context, ref, contacts),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        backgroundColor: AppColors.primaryTurquoise,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text(
          'Add Contact',
          style: AppTextStyles.button.copyWith(fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryTurquoise.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.contacts_outlined,
                size: 50,
                color: AppColors.primaryTurquoise,
              ),
            ),
            const SizedBox(height: 24),
            Text('No Emergency Contacts', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Add your doctor, family members, or pharmacist so you can reach them quickly in an emergency.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddSheet(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add First Contact'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTurquoise,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
      BuildContext context, WidgetRef ref, List<EmergencyContactModel> contacts) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return _ContactCard(
          contact: contact,
          onCall: () => _callContact(context, contact.phone),
          onDelete: () => _confirmDelete(context, ref, contact),
        );
      },
    );
  }

  Future<void> _callContact(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open phone dialer'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, EmergencyContactModel contact) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Contact?'),
        content: Text('Remove ${contact.name} from your emergency contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(emergencyContactsProvider.notifier)
                  .deleteContact(contact.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${contact.name} removed'),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () => ref
                        .read(emergencyContactsProvider.notifier)
                        .addContact(contact),
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddContactSheet(
        onSave: (contact) {
          ref.read(emergencyContactsProvider.notifier).addContact(contact);
        },
      ),
    );
  }
}

// ── Contact Card ───────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final EmergencyContactModel contact;
  final VoidCallback onCall;
  final VoidCallback onDelete;

  const _ContactCard({
    required this.contact,
    required this.onCall,
    required this.onDelete,
  });

  Color get _relationColor {
    switch (contact.relation) {
      case ContactRelation.doctor:
        return AppColors.primaryTurquoise;
      case ContactRelation.family:
        return AppColors.success;
      case ContactRelation.pharmacist:
        return AppColors.warning;
      case ContactRelation.other:
        return AppColors.textSecondary;
    }
  }

  IconData get _relationIcon {
    switch (contact.relation) {
      case ContactRelation.doctor:
        return Icons.local_hospital;
      case ContactRelation.family:
        return Icons.family_restroom;
      case ContactRelation.pharmacist:
        return Icons.local_pharmacy;
      case ContactRelation.other:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Relation icon circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _relationColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_relationIcon, color: _relationColor, size: 26),
            ),

            const SizedBox(width: 14),

            // Name + relation + phone
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _relationColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          contact.relationLabel,
                          style: TextStyle(
                            color: _relationColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact.phone,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Call button
            IconButton(
              onPressed: onCall,
              icon: const Icon(Icons.phone_rounded),
              color: AppColors.success,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.success.withValues(alpha: 0.1),
              ),
            ),

            // Delete button
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add Contact Bottom Sheet ───────────────────────────────────────────────────

class _AddContactSheet extends StatefulWidget {
  final void Function(EmergencyContactModel) onSave;

  const _AddContactSheet({required this.onSave});

  @override
  State<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<_AddContactSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  ContactRelation _relation = ContactRelation.doctor;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    widget.onSave(EmergencyContactModel(
      id: '',
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      relation: _relation,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.inputBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('Add Emergency Contact',
                style: AppTextStyles.h3),
            const SizedBox(height: 20),

            // Name field
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline,
                    color: AppColors.primaryTurquoise),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter a name' : null,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Phone field
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone_outlined,
                    color: AppColors.primaryTurquoise),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter a phone number' : null,
            ),
            const SizedBox(height: 16),

            // Relation chips
            Text('Relation',
                style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ContactRelation.values.map((r) {
                final label = EmergencyContactModel(
                        id: '', name: '', phone: '', relation: r)
                    .relationLabel;
                return ChoiceChip(
                  label: Text(label),
                  selected: _relation == r,
                  onSelected: (_) => setState(() => _relation = r),
                  selectedColor: AppColors.primaryTurquoise,
                  labelStyle: TextStyle(
                    color: _relation == r
                        ? AppColors.white
                        : AppColors.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTurquoise,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Contact',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
