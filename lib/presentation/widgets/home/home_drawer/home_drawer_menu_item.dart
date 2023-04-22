import 'package:flutter/material.dart';

class HomeDrawerMenuItem extends StatelessWidget {
  const HomeDrawerMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      onTap: onTap,
    );
  }
}
