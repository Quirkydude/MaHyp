import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/profile/data/models/emergency_contact_model.dart';

class EmergencyContactsService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _collection {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('emergencyContacts');
  }

  Future<List<EmergencyContactModel>> getContacts() async {
    final snap = await _collection.orderBy('name').get();
    return snap.docs.map(EmergencyContactModel.fromFirestore).toList();
  }

  Future<EmergencyContactModel> addContact(
      EmergencyContactModel contact) async {
    final ref = await _collection.add(contact.toFirestore());
    return contact.copyWith(id: ref.id);
  }

  Future<void> updateContact(EmergencyContactModel contact) async {
    await _collection.doc(contact.id).update(contact.toFirestore());
  }

  Future<void> deleteContact(String id) async {
    await _collection.doc(id).delete();
  }
}
