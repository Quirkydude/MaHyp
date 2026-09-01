import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/emergency_contacts_service.dart';
import '../../data/models/emergency_contact_model.dart';

final emergencyContactsServiceProvider = Provider<EmergencyContactsService>(
  (ref) => EmergencyContactsService(),
);

final emergencyContactsProvider =
    AsyncNotifierProvider<
      EmergencyContactsNotifier,
      List<EmergencyContactModel>
    >(EmergencyContactsNotifier.new);

class EmergencyContactsNotifier
    extends AsyncNotifier<List<EmergencyContactModel>> {
  EmergencyContactsService get _service =>
      ref.read(emergencyContactsServiceProvider);

  @override
  Future<List<EmergencyContactModel>> build() => _service.getContacts();

  Future<void> addContact(EmergencyContactModel contact) async {
    final added = await _service.addContact(contact);
    state = AsyncData([...?state.value, added]);
  }

  Future<void> deleteContact(String id) async {
    await _service.deleteContact(id);
    state = AsyncData(state.value?.where((c) => c.id != id).toList() ?? []);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.getContacts());
  }
}
