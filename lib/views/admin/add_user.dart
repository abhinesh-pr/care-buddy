import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../modals/admin/add_user_modal.dart';
import 'admi_nav_bar.dart';

class AddUser extends StatefulWidget {
  @override
  _AddUser createState() => _AddUser();
}

class _AddUser extends State<AddUser> {
  final _formKey = GlobalKey<FormState>();
  String? _userType;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _caretakerController = TextEditingController();
  final TextEditingController _caretakerIdController = TextEditingController();
  final TextEditingController _adminIdController = TextEditingController();
  List<Medicine> _medicines = [];

  Future<bool> _isIdUnique(String field, String id) async {
    if (id.isEmpty) return false;

    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where(field, isEqualTo: id)
        .get();

    return querySnapshot.docs.isEmpty; // Returns true if ID is unique
  }

  Future<void> _saveUserToFirestore() async {
    if (!_formKey.currentState!.validate() || _userType == null) return;

    // Generate a unique user ID for general users
    String userId = FirebaseFirestore.instance.collection('users').doc().id;

    if (_userType == "Care Taker") {
      if (_caretakerIdController.text.isEmpty) {
        Get.snackbar("Error", "Caretaker ID is required!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }
      userId = _caretakerIdController.text;

      // Check if Caretaker ID already exists
      DocumentSnapshot caretakerDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (caretakerDoc.exists) {
        Get.snackbar("Error", "Caretaker ID already exists! Choose a different ID.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }
    }

    if (_userType == "Patient") {
      if (_caretakerIdController.text.isEmpty) {
        Get.snackbar("Error", "Caretaker ID is required for Patients!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }

      String caretakerId = _caretakerIdController.text;
      DocumentSnapshot caretakerDoc =
      await FirebaseFirestore.instance.collection('users').doc(caretakerId).get();

      if (!caretakerDoc.exists) {
        Get.snackbar("Error", "Caretaker ID not found! Please enter a valid Caretaker ID.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }

      // Retrieve caretaker's name
      String caretakerName = caretakerDoc.get('name') ?? 'Unknown Caretaker';

      // Generate a unique patient ID automatically
      String patientId = FirebaseFirestore.instance.collection('users').doc().id;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(caretakerId)
          .collection('patients')
          .doc(patientId)
          .set({
        'id': patientId,
        'name': _nameController.text,
        'age': int.parse(_ageController.text),
        'contact': _contactController.text,
        'address': _addressController.text,
        'condition': _conditionController.text,
        'caretaker': caretakerId,
        'caretakerName': caretakerName, // Store Caretaker Name
        'medicines': _medicines.map((m) => {'name': m.name, 'time': m.time}).toList(),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      Get.snackbar("Success", "Patient added successfully under Caretaker!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);

      AdminNavBar.adminNavKey.currentState?.onTabTapped(0);
      return;
    }

    // Default case: Store general users under /users
    UserModel newUser = UserModel(
      id: userId,
      name: _nameController.text,
      age: int.parse(_ageController.text),
      contact: _contactController.text,
      address: _addressController.text,
      email: (_userType == "Care Taker" || _userType == "Admin") ? _emailController.text : null,
      userType: _userType!,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    await FirebaseFirestore.instance.collection('users').doc(userId).set(newUser.toMap());

    Get.snackbar("Success", "User added successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);

    AdminNavBar.adminNavKey.currentState?.onTabTapped(0);
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserTypeDropDown(onUserTypeSelected: (value) {
                    setState(() {
                      _userType = value;
                    });
                  }),
              if (_userType != null) ...[
                  SizedBox(height: 20,),
                  _buildTextField(_nameController, "Name", Icons.person),
                  _buildTextField(_ageController, "Age", LucideIcons.calendarHeart, TextInputType.number),
                  _buildTextField(_contactController, "Contact", Icons.phone, TextInputType.phone),
                  _buildTextField(_addressController, "Address", Icons.home),
                  if (_userType == "Care Taker" || _userType == "Admin")
                    _buildTextField(_emailController, "Email", Icons.email, TextInputType.emailAddress),
                  if (_userType == "Care Taker")
                    _buildTextField(_caretakerIdController, "Caretaker ID", Icons.badge),
                  if (_userType == "Admin")
                    _buildTextField(_adminIdController, "Admin ID", Icons.admin_panel_settings),
                  if (_userType == "Patient") ...[
                    _buildTextField(_conditionController, "Condition", Icons.local_hospital),
                    _buildMedicinesSection(),
                    _buildTextField(_caretakerIdController, "Caretaker ID", Icons.badge),
                  ],
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveUserToFirestore,
                      child: Text("Submit"),
                    ),
                  ),
                ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text("Medicines", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _medicines.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _medicines[index].name,
                    decoration: InputDecoration(
                      labelText: "Medicine Name",
                      prefixIcon: Icon(Icons.medical_services),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _medicines[index] = Medicine(
                          name: value,
                          time: _medicines[index].time,
                        );
                      });
                    },
                    validator: (value) => value == null || value.isEmpty ? "Enter Medicine Name" : null,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _medicines[index] = Medicine(
                            name: _medicines[index].name,
                            time: pickedTime.format(context),
                          );
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Text(
                        _medicines[index].time.isEmpty ? "Select Time" : _medicines[index].time,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => _medicines.removeAt(index)),
                ),
              ],
            );
          },
        ),
        SizedBox(height: 10),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _medicines.add(Medicine(name: "", time: ""))),
            icon: Icon(Icons.add, color: Colors.white),
            label: Text("Add Medicine"),
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blueAccent)),
          ),
        ),
      ],
    );
  }



  Widget _buildTextField(TextEditingController controller, String label, IconData icon, [TextInputType type = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? "Please enter $label" : null,
      ),
    );
  }
}




class UserTypeDropDown extends StatelessWidget {
  final Function(String?) onUserTypeSelected;
  const UserTypeDropDown({required this.onUserTypeSelected, super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            child: DropdownSearch<String>(
              items: (filter, infinite) => [
                'Patient',
                'Care Taker',
                'Admin',
              ],
              onChanged: onUserTypeSelected,
              suffixProps: DropdownSuffixProps(
                dropdownButtonProps: DropdownButtonProps(
                  iconClosed: Icon(Icons.keyboard_arrow_down, color: isDarkMode ? Colors.white : Colors.black),
                  iconOpened: Icon(Icons.keyboard_arrow_up, color: isDarkMode ? Colors.white : Colors.black),
                ),
              ),
              decoratorProps: DropDownDecoratorProps(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  filled: true,
                  fillColor: Color(0xFFbde0fe),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ),
              popupProps: PopupProps.menu(
                itemBuilder: (context, item, isDisabled, isSelected) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
                constraints: BoxConstraints(maxHeight: 120),
                menuProps: MenuProps(
                  backgroundColor: Color(0xFFbde0fe),
                  margin: EdgeInsets.only(top: 8),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              dropdownBuilder: (context, selectedItem) {
                return Text(
                  selectedItem ?? 'Select User Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
