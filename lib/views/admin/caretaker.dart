import 'package:flutter/material.dart';

class AdminCareTaker extends StatefulWidget {
  final List<Map<String, dynamic>>? initialPeople;

  const AdminCareTaker({super.key, this.initialPeople});

  @override
  _AdminCareTaker createState() => _AdminCareTaker();
}

class _AdminCareTaker extends State<AdminCareTaker> {
  Map<String, int> caretakerData = {};
  List<MapEntry<String, int>> filteredCaretakers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _calculateCaretakerPatients();
    filteredCaretakers = caretakerData.entries.toList();
  }

  void _calculateCaretakerPatients() {
    List<Map<String, dynamic>> people = [
      {"Name": "John Doe", "Caretaker": "Alice"},
      {"Name": "Mary Smith", "Caretaker": "Emma"},
      {"Name": "Robert Brown", "Caretaker": "Emma"},
      {"Name": "Emily Davis", "Caretaker": "Hannah"},
      {"Name": "William Johnson", "Caretaker": "Emma"},
      {"Name": "Sophia Wilson", "Caretaker": "Hannah"},
      {"Name": "Michael Lee", "Caretaker": "Grace"},
      {"Name": "Olivia Martin", "Caretaker": "Hannah"},
      {"Name": "Daniel Thomas", "Caretaker": "Emma"},
    ];

    if (widget.initialPeople != null) {
      people.addAll(widget.initialPeople!);
    }

    Map<String, int> caretakerCount = {};

    for (var person in people) {
      String caretaker = person["Caretaker"];
      caretakerCount[caretaker] = (caretakerCount[caretaker] ?? 0) + 1;
    }

    setState(() {
      caretakerData = caretakerCount;
      filteredCaretakers = caretakerData.entries.toList();
    });
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
                child: GridView.builder(
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
    );
  }
}
