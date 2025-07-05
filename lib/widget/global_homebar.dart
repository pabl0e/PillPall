import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pillpall/profile_page.dart';
import 'package:pillpall/widget/doctor_list.dart';
import 'package:pillpall/widget/landing_page.dart'; // Contains HomePage class
import 'package:pillpall/widget/medication_widget.dart'; // Add medication widget import
import 'package:pillpall/widget/symptom_widget.dart'; // Add symptom widget import
import 'package:pillpall/widget/task_widget.dart';

class GlobalHomeBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int)? onTap;

  const GlobalHomeBar({Key? key, this.selectedIndex = 0, this.onTap})
    : super(key: key);

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
        break;
      case 1:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SymptomWidget()),
        );
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => DoctorListScreen()),
        );
        break;
      case 3:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Task_Widget()),
        );
        break;
      case 4:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MedicationWidget()),
        );
        break;
      case 5:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: selectedIndex == 0 ? Colors.deepPurple : Colors.grey,
                size: 30,
              ),
              onPressed: () {
                if (selectedIndex != 0) {
                  _navigateToPage(context, 0);
                }
                onTap?.call(0);
              },
              tooltip: 'Home',
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/symptoms.svg',
                height: 30,
                width: 30,
                colorFilter: selectedIndex == 1
                    ? ColorFilter.mode(Colors.deepPurple, BlendMode.srcIn)
                    : ColorFilter.mode(Colors.grey, BlendMode.srcIn),
              ),
              onPressed: () {
                if (selectedIndex != 1) {
                  _navigateToPage(context, 1);
                }
                onTap?.call(1);
              },
              tooltip: 'Symptoms',
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/doctor.svg',
                height: 30,
                width: 30,
                color: selectedIndex == 2 ? Colors.deepPurple : Colors.grey,
              ),
              onPressed: () {
                if (selectedIndex != 2) {
                  _navigateToPage(context, 2);
                }
                onTap?.call(2);
              },
              tooltip: 'Doctor',
            ),
            IconButton(
              icon: Icon(
                Icons.task, // Task icon
                color: selectedIndex == 3 ? Colors.deepPurple : Colors.grey,
                size: 30,
              ),
              onPressed: () {
                if (selectedIndex != 3) {
                  _navigateToPage(context, 3);
                }
                onTap?.call(3);
              },
              tooltip: 'Tasks',
            ),
            IconButton(
              icon: Icon(
                Icons.medication,
                color: selectedIndex == 4 ? Colors.deepPurple : Colors.grey,
                size: 30,
              ),
              onPressed: () {
                if (selectedIndex != 4) {
                  _navigateToPage(context, 4);
                }
                onTap?.call(4);
              },
              tooltip: 'Pills',
            ),
            IconButton(
              icon: Icon(
                Icons.settings,
                color: selectedIndex == 5 ? Colors.deepPurple : Colors.grey,
                size: 30,
              ),
              onPressed: () {
                if (selectedIndex != 5) {
                  _navigateToPage(context, 5);
                }
                onTap?.call(5);
              },
              tooltip: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
