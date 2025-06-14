import 'package:flutter/material.dart';
import 'package:balance/components/ui/bordered_icon_button.dart';
import 'package:balance/main.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      actionsPadding: EdgeInsets.only(right: 15),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://github.com/CMOISDEAD.png'),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('Good morning', style: TextStyle(fontSize: 14)),
              Text(
                'CMOISDEAD',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
      actions: [
        BorderedIconButton(
          onPressed: () {
            themeNotifier.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
          },
          icon: isDarkMode
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
