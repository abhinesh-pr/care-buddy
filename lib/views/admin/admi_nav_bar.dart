import 'package:carebud/views/admin/add_user.dart';
import 'package:carebud/views/admin/caretaker.dart';
import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

import 'admin_dashboard.dart';

class AdminNavBar extends StatefulWidget {
  static final GlobalKey<_AdminNavBarState> adminNavKey = GlobalKey();

  final List<Map<String, dynamic>>? initialPeople;

  const AdminNavBar({Key? key, this.initialPeople}) : super(key: key);

  @override
  _AdminNavBarState createState() => _AdminNavBarState();
}

class _AdminNavBarState extends State<AdminNavBar> {
  int selectedIndex = 0;
  final PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: "Care",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "Buddy",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 20),
            icon: Icon(Icons.logout, size: 28, color: Colors.red),
            onPressed: () {},
          ),
        ],
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // Set height of the bottom border
          child: Container(
            color:  isDarkMode ? Color(0xFF515151) : Color(0xFFCFCFCF), // Set border color
            height: 0.7, // Set border thickness
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              children:[
                AdminDash(),
                AddUser(),
                AdminCareTaker(),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.white, // Set background color
              border: Border(
                top: BorderSide(color: isDarkMode ? Color(0xFF515151) : Color(0xFFCFCFCF), width: 0.7), // Border for the top
                left: BorderSide(color: isDarkMode ? Color(0xFF515151) : Color(0xFFCFCFCF), width: 0.7), // Border for the left
                right: BorderSide(color: isDarkMode ? Color(0xFF515151) : Color(0xFFCFCFCF), width: 0.7), // Border for the right
                bottom: BorderSide.none, // No border for the bottom // Set border width
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(35), // Set border radius
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(35), // Same border radius for the clipped region
              ),
              child: Container(
                color: isDarkMode ? Colors.black : Colors.white, // Background color for clipped region
                child: StylishBottomBar(
                  backgroundColor: isDarkMode ? Colors.black12 : Colors.white, // Bottom nav bar background color
                  option: AnimatedBarOptions(
                    barAnimation: BarAnimation.fade,
                    iconStyle: IconStyle.simple,
                    opacity: 0.8,
                  ),
                  items: [
                    BottomBarItem(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded,size: 30,),
                      selectedColor: Colors.blue,
                      unSelectedColor: isDarkMode ? Colors.white : Colors.grey,
                      title: const Text('Home'),
                    ),
                    BottomBarItem(
                      icon: Icon(Icons.add_circle_outline),
                      selectedIcon: Icon(Icons.add_circle,size: 30,),
                      selectedColor: Colors.blue,
                      unSelectedColor: isDarkMode ? Colors.white : Colors.grey,
                      title: const Text('Tasks'),
                    ),
                    BottomBarItem(
                      icon: Icon(Icons.supervisor_account_outlined),
                      selectedIcon: Icon(Icons.supervisor_account,size: 30,),
                      selectedColor: Colors.blue,
                      unSelectedColor: isDarkMode ? Colors.white : Colors.grey,
                      title: const Text('Library'),
                    ),
                  ],
                  hasNotch: true,
                  currentIndex: selectedIndex,
                  onTap: onTabTapped,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}