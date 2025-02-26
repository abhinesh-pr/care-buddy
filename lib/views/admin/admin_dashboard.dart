import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDash extends StatefulWidget {
  const AdminDash({super.key});

  @override
  _AdminDash createState() => _AdminDash();
}

class _AdminDash extends State<AdminDash> {
  TextEditingController searchController = TextEditingController();

  void updateSearch(String query) {
    setState(() {});
  }

  Stream<List<Map<String, dynamic>>> fetchPatients() async* {
    List<Map<String, dynamic>> allPatients = [];

    QuerySnapshot caretakerSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userType', isEqualTo: 'Care Taker')
        .get();

    for (var caretakerDoc in caretakerSnapshot.docs) {
      String caretakerId = caretakerDoc.id;
      String caretakerName = caretakerDoc['name']; // Fetch caretaker name

      QuerySnapshot patientSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(caretakerId)
          .collection('patients')
          .get();

      for (var patientDoc in patientSnapshot.docs) {
        Map<String, dynamic> patientData =
        patientDoc.data() as Map<String, dynamic>;
        patientData['caretakerId'] = caretakerId;
        patientData['caretakerName'] = caretakerName; // Add caretaker name
        allPatients.add(patientData);
      }
    }

    yield allPatients;
  }


  void _showPersonDetails(BuildContext context, Map<String, dynamic> person) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Patient Details',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _infoRow('Name', person['name']),
              _infoRow('Age', person['age'].toString()),
              _infoRow('Contact', person['contact']),
              _infoRow('Medical Condition', person['condition']),
              _infoRow(
                'Medicines',
                person['medicines']
                    ?.map<String>((m) => '${m['name']} (${m['time']})')
                    .join(', ') ??
                    'None',
              ),
              _infoRow('Caretaker', person['caretakerName'] ?? 'Unknown'),
              _infoRow('Caretaker Id', person['caretakerId'] ?? 'None'),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: searchController,
                onChanged: updateSearch,
                decoration: InputDecoration(
                  hintText: "Search by Name...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: fetchPatients(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No patients found"));
                    }

                    List<Map<String, dynamic>> peopleData = snapshot.data!;
                    List<Map<String, dynamic>> displayedData = searchController.text.isEmpty
                        ? peopleData
                        : peopleData.where((person) {
                      return person["name"]
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase());
                    }).toList();

                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1,
                      ),
                      itemCount: displayedData.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _showPersonDetails(context, displayedData[index]),
                          child: PersonCard(data: displayedData[index]),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PersonCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const PersonCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFbde0fe),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 7,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Name: ${data["name"]}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("Age: ${data["age"]}", style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 5),
          Text("Caretaker: ${data["caretakerName"]}", style: const TextStyle(fontSize: 14)),

        ],
      ),
    );
  }
}
