import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:kiosk/const/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:kiosk/core/models/all_penumpang.dart';
import 'package:kiosk/core/models/penumpang.dart';
import 'package:kiosk/core/sources/printer_services.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'webview_event.dart';
part 'webview_state.dart';

class WebviewBloc extends Bloc<WebviewEvent, WebviewState> {
  late final WebViewController controller;
  List<dynamic>? lastReceivedData = [];
  List<Printer> printers = [];
  final Uri baseUrl = Uri.parse("https://example.com");

  WebviewBloc() : super(WebviewInitial()) {
    on<WebviewEvent>((event, emit) {
      emit(const PageLoading(0));
    });

    on<PageProgress>((event, emit) {
      emit(PageLoading(event.progress));
    });

    on<PageFinished>((event, emit) async {
      emit(PageLoaded(event.url, lastReceivedData ?? []));
      log("Page finished loading: ${event.url}");

      try {
        await controller.runJavaScript("""
          var viewport = document.querySelector('meta[name=viewport]');
          if (viewport) {
            viewport.setAttribute('content', 'width=device-width, initial-scale=0.414, maximum-scale=1.0, user-scalable=no');
          }
          document.querySelectorAll('input, textarea').forEach(function(element) {
            element.setAttribute('readonly', true);
          });
          document.activeElement.blur();

          // Kirim data setelah JavaScriptChannel tersedia
          if (window.JavaScriptChannel) {
            window.JavaScriptChannel.postMessage(JSON.stringify(currentDatas));
            console.log('data sent from JS');
          } else {
            console.log('JavaScriptChannel tidak tersedia saat ini');
          }
        """);
        log("JavaScript executed successfully.");
      } catch (e) {
        log("Error running JavaScript: $e");
      }
    });

    on<DataReceived>((event, emit) async {
      if (ThermalPrint.isPrintingInProgress) {
        log("Printing is already in progress, skipping new print request.");
        return;
      }

      try {
        log("Received data from JavaScript: ${event.data}");

        await ThermalPrint.scanAndPrint(event.data);

        log("Printing process triggered successfully.");
      } catch (e) {
        log("Error during printing: $e");
      }
    });

    controller =
        WebViewController()
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                add(PageStarted(AppStrings.devUrl));
              },
              onProgress: (progress) {
                add(PageProgress(progress));
              },
              onPageFinished: (url) {
                add(PageFinished(AppStrings.devUrl));
              },
            ),
          )
          ..loadRequest(Uri.parse(AppStrings.devUrl))
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..addJavaScriptChannel(
            "JavaScriptChannel",
            onMessageReceived: (JavaScriptMessage message) {
              try {
                // Menerima pesan dari JavaScript (format JSON)
                log("Received data from JavaScript: ${message.message}");

                // Parse JSON menjadi objek Dart
                var decodedData = jsonDecode(message.message);

                // Ambil array "data" dari JSON
                List data = decodedData['data'];

                // Ambil semua nilai "value" dari setiap objek dalam array "data"
                List<String> values = [];
                for (var item in data) {
                  // Cek jika item memiliki key 'value'
                  if (item.containsKey('value')) {
                    var value = item['value'];

                    // Cek jika value tidak kosong atau hanya terdiri dari spasi
                    if (value.trim().isNotEmpty) {
                      values.add(
                        value,
                      ); // Ambil nilai "value" yang tidak kosong
                    }
                  }
                }

                log("Values extracted: $values");

                // Masukkan values ke dalam Penumpang
                if (values.length >= 3) {
                  String companyName =
                      values[0]; // Ambil nilai pertama untuk companyName
                  String header = values[1]; // Ambil nilai kedua untuk header
                  List<String> details = values.sublist(
                    2,
                  ); // Sisanya untuk details

                  // Membagi data dalam kelipatan 18
                  int chunkSize = 18;
                  int numberOfChunks = (details.length / chunkSize).floor();

                  // Deklarasi list untuk menampung semua penumpang
                  List<Penumpang> penumpangList = [];

                  for (
                    int chunkIndex = 0;
                    chunkIndex < numberOfChunks;
                    chunkIndex++
                  ) {
                    // Ambil bagian data sesuai chunkSize
                    List<String> chunk = details.sublist(
                      chunkIndex * chunkSize,
                      (chunkIndex + 1) * chunkSize,
                    );

                    // Buat objek Penumpang dengan data yang sesuai
                    Penumpang penumpang = Penumpang(
                      companyName: companyName,
                      header: header,
                      ticketNo: [chunk[0]],
                      qrCode: [chunk[1]],
                      penumpang: [chunk[2]],
                      passengerName: [chunk[3]],
                      pergi: [chunk[4]],
                      departureDate: [chunk[5]],
                      scheduleCode: [chunk[6]],
                      pickUp: [chunk[7]],
                      departure: [chunk[8]],
                      departurePoolName: [chunk[9]],
                      departureTime: [chunk[10]],
                      kursi: [chunk[11]],
                      seatNo: [chunk[12]],
                      dropOff: [chunk[13]],
                      destination: [chunk[14]],
                      destinationPoolName: [chunk[15]],
                      ticketPrice: [chunk[16]],
                      transactionTime: [chunk[17]],
                    );

                    // Tambahkan ke penumpangList
                    penumpangList.add(penumpang);
                  }

                  // Gabungkan semua data dari penumpangList
                  if (penumpangList.isNotEmpty) {
                    Penumpang combinedPenumpang = combinePenumpangData(
                      companyName,
                      header,
                      penumpangList,
                    );

                    // Log data penumpang yang digabung
                    log("Combined Penumpang:");
                    log("Company Name: ${combinedPenumpang.companyName}");
                    log("Header: ${combinedPenumpang.header}");
                    log("Ticket No: ${combinedPenumpang.ticketNo}");
                    log("QR Code: ${combinedPenumpang.qrCode}");
                    log("Penumpang: ${combinedPenumpang.penumpang}");
                    log("Passenger Name: ${combinedPenumpang.passengerName}");
                    log("Pergi: ${combinedPenumpang.pergi}");
                    log("Departure Date: ${combinedPenumpang.departureDate}");
                    log("Schedule Code: ${combinedPenumpang.scheduleCode}");
                    log("Pick Up: ${combinedPenumpang.pickUp}");
                    log("Departure: ${combinedPenumpang.departure}");
                    log(
                      "Departure Pool Name: ${combinedPenumpang.departurePoolName}",
                    );
                    log("Departure Time: ${combinedPenumpang.departureTime}");
                    log("Kursi: ${combinedPenumpang.kursi}");
                    log("Seat No: ${combinedPenumpang.seatNo}");
                    log("Drop Off: ${combinedPenumpang.dropOff}");
                    log("Destination: ${combinedPenumpang.destination}");
                    log(
                      "Destination Pool Name: ${combinedPenumpang.destinationPoolName}",
                    );
                    log("Ticket Price: ${combinedPenumpang.ticketPrice}");
                    log(
                      "Transaction Time: ${combinedPenumpang.transactionTime}",
                    );

                    // Kirim data hasil penggabungan
                    add(DataReceived(combinedPenumpang));
                  }
                } else {
                  log("Insufficient data to create Penumpang object");
                }
              } catch (e) {
                // Tangani error jika ada
                log("Error parsing message: $e");
              }
            },
          )
          ..setBackgroundColor(Colors.transparent);
  }
}
