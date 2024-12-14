import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiosk/thermal_print/ui/thermal_print_screen.dart';
import 'package:kiosk/webview/bloc/webview_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPage extends StatelessWidget {
  const WebviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WebviewBloc(),
      child: Scaffold(
        body: Stack(
          children: [
            BlocBuilder<WebviewBloc, WebviewState>(
              builder: (context, state) {
                if (state is PageLoading) {
                  return Stack(
                    children: [
                      WebViewWidget(
                        controller: context.read<WebviewBloc>().controller,
                      ),
                      LinearProgressIndicator(value: state.progress / 100.0),
                    ],
                  );
                } else if (state is PageLoaded) {
                  return WebViewWidget(
                    controller: context.read<WebviewBloc>().controller,
                  );
                } else if (state is PrintingInProgress) {
                  return Stack(
                    children: [
                      WebViewWidget(
                        controller: context.read<WebviewBloc>().controller,
                      ),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  );
                } else if (state is PrintSuccess) {
                  return Stack(
                    children: [
                      WebViewWidget(
                        controller: context.read<WebviewBloc>().controller,
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Printing successful',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (state is PrintFailure) {
                  return Stack(
                    children: [
                      WebViewWidget(
                        controller: context.read<WebviewBloc>().controller,
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Printing failed: ${state.error}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),

            Positioned(
              bottom: 5,
              left: 5,
              child: InkWell(
                onDoubleTap: () {
                  log("Thermal Print Screen");
                  showDialogs(context);
                },
                child: CircleAvatar(radius: 5, backgroundColor: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDialogs(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelStyle: TextStyle(color: Colors.blueAccent),
                hintText: 'Enter Password',
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
}
