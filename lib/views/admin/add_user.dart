import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'admin_dashboard.dart';

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
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _caretakerController = TextEditingController();
  List<Map<String, String>> _medicines = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
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
                  Container(
                    width: double.infinity,
                    child: UserTypeDropDown(
                      onUserTypeSelected: (value) {
                        setState(() {
                          _userType = value ?? 'Semester 1';
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(_nameController, "Name", Icons.person),
                  _buildTextField(_ageController, "Age", LucideIcons.calendarHeart, TextInputType.number),
                  _buildTextField(_contactController, "Contact", Icons.phone, TextInputType.phone),
                  _buildTextField(_addressController, "Address", Icons.home),
                  if (_userType == "Patient") ...[
                    _buildTextField(_conditionController, "Condition", Icons.local_hospital),
                    _buildMedicinesSection(),
                    SizedBox(height: 10),
                    _buildTextField(_caretakerController, "Caretaker", Icons.supervisor_account),
                  ],
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_userType == "Patient") {
                            Map<String, dynamic> newPatient = {
                              "Name": _nameController.text,
                              "Age": _ageController.text,
                              "Contact": _contactController.text,
                              "Condition": _conditionController.text,
                              "Medicines": _medicines.map((m) => m['medicine']).toList(),
                              "Caretaker": _caretakerController.text,
                            };

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminDash(initialPeople: [newPatient]),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.blueAccent
                      ),
                      child: Text("Submit", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
                  child: _buildTextField(
                    TextEditingController(text: _medicines[index]['medicine']),
                    "Medicine Name",
                    Icons.medical_services,
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
                          _medicines[index]['time'] = pickedTime.format(context);
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
                        _medicines[index]['time']!.isEmpty ? "Select Time" : _medicines[index]['time']!,
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
            onPressed: () => setState(() => _medicines.add({"medicine": "", "time": ""})),
            icon: Icon(Icons.add, color: Colors.white,),
            label: Text("Add Medicine"),
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blueAccent),)

          ),
        ),
      ],
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
