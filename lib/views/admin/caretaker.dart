import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminCareTaker extends StatefulWidget {
  const AdminCareTaker({super.key});

  @override
  _AdminCareTaker createState() => _AdminCareTaker();
}

class _AdminCareTaker extends State<AdminCareTaker> {
  Map<String, int> caretakerData = {};
  List<MapEntry<String, int>> filteredCaretakers = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true; // To track loading state

  @override
  void initState() {
    super.initState();
    _fetchCaretakersFromFirestore();
  }

  Future<void> _fetchCaretakersFromFirestore() async {
    try {
      QuerySnapshot caretakerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'Care Taker')
          .get();

      Map<String, int> caretakerCount = {};

      for (var caretakerDoc in caretakerSnapshot.docs) {
        String caretakerId = caretakerDoc.id;
        String caretakerName = caretakerDoc['name'] ?? 'Unknown';

        // Get the number of patients under this caretaker
        QuerySnapshot patientSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(caretakerId)
            .collection('patients')
            .get();

        int patientCount = patientSnapshot.docs.length;
        caretakerCount[caretakerName] = patientCount;
      }

      setState(() {
        caretakerData = caretakerCount;
        filteredCaretakers = caretakerData.entries.toList();
        isLoading = false; // Data loaded
      });
    } catch (e) {
      print("Error fetching caretakers: $e");
      setState(() {
        isLoading = false; // Stop loading even if there's an error
      });
    }
  }


  void updateSearch(String query) {
    setState(() {
      filteredCaretakers = caretakerData.entries
          .where((entry) => entry.key.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
                  hintText: "Search Caretaker...",
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
                child: isLoading
                    ? const Center(child: CircularProgressIndicator()) // Show loader while fetching data
                    : caretakerData.isEmpty
                    ? const Center(
                  child: Text(
                    "No Caretakers",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
                    : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1,
                  ),
                  itemCount: filteredCaretakers.length,
                  itemBuilder: (context, index) {
                    String caretaker = filteredCaretakers[index].key;
                    int count = filteredCaretakers[index].value;
                    return CaretakerCard(caretaker: caretaker, count: count);
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

class CaretakerCard extends StatelessWidget {
  final String caretaker;
  final int count;

  const CaretakerCard({super.key, required this.caretaker, required this.count});

  Future<void> _fetchCaretakerDetails(BuildContext context) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'Care Taker')
          .where('id', isEqualTo: caretaker) // Fetch by caretakerId
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> caretakerData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        _showCaretakerDetails(context, caretakerData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Caretaker details not found")),
        );
      }
    } catch (e) {
      print("Error fetching caretaker details: $e");
    }
  }


  void _showCaretakerDetails(BuildContext context, Map<String, dynamic> caretakerData) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Caretaker Details',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _infoRow('Name', caretakerData['name']),
              _infoRow('Age', caretakerData['age'].toString()),
              _infoRow('Contact', caretakerData['contact']),
              _infoRow('Address', caretakerData['address']),
              _infoRow('Email', caretakerData['email']),
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
    return GestureDetector(
      onTap: () => _fetchCaretakerDetails(context),
      child: Container(
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
          children: [
            Text(
              caretaker,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Patients: $count",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}