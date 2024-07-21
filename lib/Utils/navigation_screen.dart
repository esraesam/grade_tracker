import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grade_tracker/Utils/constants.dart';
import 'package:grade_tracker/View/Navigation%20Screens/Home%20Screens/pdf_display_screen.dart';
import 'package:grade_tracker/View/Navigation%20Screens/Upload%20Pdf%20Screens/upload_pdf_screen.dart';

class NavigationScreen extends StatefulWidget {
  String? paymentId;
  NavigationScreen({super.key, this.paymentId});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    List<Widget> pages = <Widget>[
      // const CartScreen(),
      const DisplayPdfScreen(),
      const UploadPdfScreen(),
    ];

    return Scaffold(
      body: Center(
        child: pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        selectedItemColor: primaryColor,
        unselectedItemColor: const Color.fromARGB(255, 238, 238, 238),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              FontAwesomeIcons.filePdf,
              size: _selectedIndex == 0 ? 30 : 21,
            ),
            label: "All Pdfs",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              FontAwesomeIcons.upload,
              size: _selectedIndex == 1 ? 31 : 22,
            ),
            label: "Upload Pdf",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
