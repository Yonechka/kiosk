// import 'package:flutter/material.dart';
// import 'package:kiosk_asmat/constant/app_strings.dart';
// import 'package:kiosk_asmat/view/webview_page.dart';

// class RefreshWidget extends StatelessWidget {
//   const RefreshWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         children: [
//           const Text(
//             AppStrings.loadingText,
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const WebviewPage(
//                     url: AppStrings.webviewLink,
//                   ),
//                 ),
//               );
//             },
//             child: const Icon(
//               Icons.refresh,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
