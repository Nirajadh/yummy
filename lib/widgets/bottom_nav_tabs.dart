import 'package:flutter/material.dart';

class BottomNavTabs extends StatefulWidget {
  final List<NavigationDestination> destinations;
  final List<Widget> pages;
  final int initialIndex;

  const BottomNavTabs({
    super.key,
    required this.destinations,
    required this.pages,
    this.initialIndex = 0,
  }) : assert(destinations.length == pages.length);

  @override
  State<BottomNavTabs> createState() => _BottomNavTabsState();
}

class _BottomNavTabsState extends State<BottomNavTabs> {
  late int _currentIndex = widget.initialIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: widget.pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: widget.destinations,
        onDestinationSelected: (index) {
          if (_currentIndex == index) return;
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}
