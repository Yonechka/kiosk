import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiosk/thermal_print/ui/thermal_print_screen.dart';
import 'package:kiosk/webview/bloc/webview_bloc.dart';

void dialogWidget(BuildContext context, String url) {
  final TextEditingController passwordController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.blueAccent),
              hintText: 'Submit',
              hintStyle: TextStyle(color: Colors.blueAccent.shade200),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.blueAccent.shade200,
                  width: 1.5,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 12,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(iconColor: Colors.red),
            child: Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              String enteredPassword = passwordController.text;
              if (enteredPassword == '123') {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThermalPrintScreen(),
                  ),
                );
              }
              if (enteredPassword == '1123') {
                Navigator.pop(context);

                final webviewBloc = context.read<WebviewBloc>();

                webviewBloc.controller.reload();
              }
              if (enteredPassword == '1233') {
                Navigator.pop(context);

                final webviewBloc = context.read<WebviewBloc>();

                webviewBloc.controller.loadRequest(Uri.parse(url));
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Submit', style: TextStyle(fontSize: 16)),
          ),
        ],
      );
    },
  );
}
