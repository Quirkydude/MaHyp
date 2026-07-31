import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ContactRelation { doctor, family, pharmacist, other }

class EmergencyContactModel extends Equatable {
  final String id;
  final String name;
  final String phone;
  final ContactRelation relation;

  const EmergencyContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
  });

  String get relationLabel {
    switch (relation) {
      case ContactRelation.doctor:
        return 'Doctor';
      case ContactRelation.family:
        return 'Family';
      case ContactRelation.pharmacist:
        return 'Pharmacist';
      case ContactRelation.other:
        return 'Other';
    }
  }

  factory EmergencyContactModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmergencyContactModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      relation: ContactRelation.values.firstWhere(
        (r) => r.name == (data['relation'] as String? ?? 'other'),
        orElse: () => ContactRelation.other,
      ),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'phone': phone,
        'relation': relation.name,
      };

  EmergencyContactModel copyWith({
    String? id,
    String? name,
    String? phone,
    ContactRelation? relation,
  }) =>
      EmergencyContactModel(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        relation: relation ?? this.relation,
      );

  @override
  List<Object?> get props => [id, name, phone, relation];
}
