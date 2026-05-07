import 'package:flutter/material.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final void Function(int)? onTab;

  const MainScaffold({
    Key? key,
    required this.child,
    required this.currentIndex,
    this.onTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFFFF4500);
    final textColor = const Color(0xFFF0F0F0);
    final background = const Color(0xFF1C1C1C);
    return Scaffold(
      backgroundColor: background,
      body: child,

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: background,
        selectedItemColor: primary,
        unselectedItemColor: textColor.withOpacity(0.5),
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.token), label: 'Tokens'),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'LeaderBord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'League',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
