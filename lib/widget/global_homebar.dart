import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GlobalHomeBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int)? onTap;

  const GlobalHomeBar({
    Key? key,
    this.selectedIndex = 0,
    this.onTap,
  }) : super(key: key);

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
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: selectedIndex == 0 ? Colors.deepPurple : Colors.grey, size: 30),
              onPressed: () => onTap?.call(0),
              tooltip: 'Home',
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/doctor.svg',
                height: 30,
                width: 30,
                color: selectedIndex == 1 ? Colors.deepPurple : Colors.grey,
              ),
              onPressed: () => onTap?.call(1),
              tooltip: 'Doctor',
            ),
            IconButton(
              icon: Icon(Icons.medication, color: selectedIndex == 2 ? Colors.deepPurple : Colors.grey, size: 30),
              onPressed: () => onTap?.call(2),
              tooltip: 'Pills',
            ),
            IconButton(
              icon: Icon(Icons.settings, color: selectedIndex == 3 ? Colors.deepPurple : Colors.grey, size: 30),
              onPressed: () => onTap?.call(3),
              tooltip: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}