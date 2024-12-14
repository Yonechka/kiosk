import 'package:flutter/material.dart';
import 'package:kiosk/const/app_strings.dart';
import 'package:kiosk/const/theme/app_colors.dart';
import 'package:kiosk/print_thermal/ui/printer_screen.dart';
import 'package:kiosk/thermal_print/ui/thermal_print_screen.dart';
import 'package:kiosk/webview/widget/iconbutton_widget.dart';

class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppbarWidget({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      centerTitle: true,
      title: const Text(AppStrings.appTitle),
      leading: IconbuttonWidget(function: () {}, iconData: Icons.devices),
      actions: [
        IconbuttonWidget(
          function: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ThermalPrintScreen(),
              ),
            );
          },
          iconData: Icons.print,
        ),
        IconbuttonWidget(
          function: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrinterScreen()),
            );
          },
          iconData: Icons.settings,
        ),
      ],
    );
  }
}
