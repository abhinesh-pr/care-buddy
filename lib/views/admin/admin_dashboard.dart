import 'package:flutter/material.dart';

class AdminDash extends StatefulWidget {
  final List<Map<String, dynamic>>? initialPeople;

  const AdminDash( {super.key, this.initialPeople});

  @override
  _AdminDash createState() => _AdminDash();
}

class _AdminDash extends State<AdminDash> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> people = [
    {
      "Name": "John Doe",
      "Age": "65",
      "Contact": "9876543210",
      "Condition": "Diabetes, High BP",
      "Medicines": ["Metformin", "Amlodipine", "Atorvastatin"],
      "Caretaker": "Alice"
    },
    {
      "Name": "Mary Smith",
      "Age": "72",
      "Contact": "9865321470",
      "Condition": "Asthma",
      "Medicines": ["Salbutamol", "Budesonide"],
      "Caretaker": "Bob"
    },
    {
      "Name": "Robert Brown",
      "Age": "80",
      "Contact": "9854123670",
      "Condition": "Arthritis",
      "Medicines": ["Ibuprofen", "Paracetamol"],
      "Caretaker": "Charlie"
    },
    {
      "Name": "Emily Davis",
      "Age": "69",
      "Contact": "9845632170",
      "Condition": "Hypertension",
      "Medicines": ["Lisinopril", "Hydrochlorothiazide"],
      "Caretaker": "David"
    },
    {
      "Name": "William Johnson",
      "Age": "75",
      "Contact": "9832145760",
      "Condition": "Chronic Kidney Disease",
      "Medicines": ["Erythropoietin", "Calcium Acetate"],
      "Caretaker": "Emma"
    },
    {
      "Name": "Sophia Wilson",
      "Age": "78",
      "Contact": "9823651470",
      "Condition": "Osteoporosis",
      "Medicines": ["Alendronate", "Calcitonin"],
      "Caretaker": "Frank"
    },
    {
      "Name": "Michael Lee",
      "Age": "82",
      "Contact": "9812475630",
      "Condition": "Heart Disease",
      "Medicines": ["Aspirin", "Metoprolol", "Simvastatin"],
      "Caretaker": "Grace"
    },
    {
      "Name": "Olivia Martin",
      "Age": "67",
      "Contact": "9803124750",
      "Condition": "Parkinson’s Disease",
      "Medicines": ["Levodopa", "Carbidopa"],
      "Caretaker": "Hannah"
    },
    {
      "Name": "Daniel Thomas",
      "Age": "74",
      "Contact": "9798562140",
      "Condition": "Alzheimer’s Disease",
      "Medicines": ["Donepezil", "Memantine"],
      "Caretaker": "Isabella"
    },
  ];
  List<Map<String, dynamic>> filteredPeople = [];

  @override
  void initState() {
    super.initState();
    people = widget.initialPeople != null ? [...people, ...widget.initialPeople!] : people;
    filteredPeople = List.from(people);
  }


  void updateSearch(String query) {
    setState(() {
      filteredPeople = people
          .where((person) => person["Name"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
                  'Person Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _infoRow('Name', person['Name']),
              _infoRow('Age', person['Age'].toString()),
              _infoRow('Contact', person['Contact']),
              _infoRow('Medical Condition', person['Condition']),
              _infoRow('Medicines', person['Medicines'].join(', ')),
              _infoRow('Caretaker', person['Caretaker']),
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
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1,
                  ),
                  itemCount: filteredPeople.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _showPersonDetails(context, filteredPeople[index]),
                      child: PersonCard(data: filteredPeople[index]),
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
        color: Color(0xFFbde0fe),
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
          Text("Name: ${data["Name"]}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("Age: ${data["Age"]}", style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 5),
          Text("Caretaker: ${data["Caretaker"]}", style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
