import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiosk/const/app_strings.dart';
import 'package:kiosk/webview/bloc/webview_bloc.dart';
import 'package:kiosk/webview/widget/dialog_widget.dart';
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
                  return Stack(
                    children: [
                      WebViewWidget(
                        controller: context.read<WebviewBloc>().controller,
                      ),
                    ],
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
                        bottom: 5,
                        left: 5,
                        child: InkWell(
                          onDoubleTap: () {
                            log("Thermal Print Screen");
                            dialogWidget(context, state.url);
                          },
                          child: CircleAvatar(
                            radius: 5,
                            backgroundColor: Colors.green,
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
                  dialogWidget(context, AppStrings.devUrl);
                },
                child: CircleAvatar(radius: 5, backgroundColor: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
