import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String name;
  int age;
  String contact;
  String address;
  String userType;
  String? email; // Only for Caretaker & Admin
  String? condition; // Only for Patients
  List<Medicine>? medicines; // Only for Patients
  String? caretaker; // Only for Patients (Caretaker Name)
  String? caretakerId; // Only for Patients (Caretaker ID)
  String? adminId; // Only for all users (Admin ID managing the user)
  Timestamp createdAt;
  Timestamp updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.contact,
    required this.address,
    required this.userType,
    this.email,
    this.condition,
    this.medicines,
    this.caretaker,
    this.caretakerId,
    this.adminId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'contact': contact,
      'address': address,
      'userType': userType,
      if (email != null) 'email': email,
      if (condition != null) 'condition': condition,
      if (medicines != null)
        'medicines': medicines!.map((medicine) => medicine.toMap()).toList(),
      if (caretaker != null) 'caretaker': caretaker,
      if (caretakerId != null) 'caretakerId': caretakerId,
      if (adminId != null) 'adminId': adminId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create from Firestore Document
  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      age: (map['age'] ?? 0) is int ? map['age'] : int.tryParse(map['age'].toString()) ?? 0,
      contact: map['contact'] ?? '',
      address: map['address'] ?? '',
      userType: map['userType'] ?? '',
      email: map['email'],
      condition: map['condition'],
      medicines: map['medicines'] != null
          ? List<Medicine>.from((map['medicines'] as List).map((x) => Medicine.fromMap(x)))
          : null,
      caretaker: map['caretaker'],
      caretakerId: map['caretakerId'],
      adminId: map['adminId'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }
}

class Medicine {
  String name;
  String time;

  Medicine({required this.name, required this.time});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'time': time,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      name: map['name'] ?? '',
      time: map['time'] ?? '',
    );
  }
}
