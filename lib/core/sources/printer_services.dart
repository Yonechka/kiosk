import 'dart:async';
import 'dart:developer';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:kiosk/core/models/penumpang.dart';

class ThermalPrint {
  static bool isPrintingInProgress =
      false; // Flag untuk melacak status pencetakan
  static StreamSubscription<List<Printer>>? devicesStreamSubscription;

  static Future<void> scanAndPrint(Penumpang values) async {
    if (isPrintingInProgress) {
      log("Printing already in progress. Skipping scanAndPrint call.");
      return;
    }

    isPrintingInProgress = true; // Set flag untuk mencegah pemanggilan ulang
    final flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;

    log("scanAndPrint called");

    // Hentikan scan sebelumnya jika masih berjalan
    log("Stopping previous scan...");
    await flutterThermalPrinterPlugin.stopScan();

    log("Starting scan...");
    try {
      // Mulai pemindaian perangkat
      await flutterThermalPrinterPlugin.getPrinters(
        connectionTypes: [ConnectionType.USB, ConnectionType.BLE],
      );
    } catch (e) {
      log("Error during getPrinters call: $e");
      isPrintingInProgress = false;
      return;
    }

    devicesStreamSubscription = flutterThermalPrinterPlugin.devicesStream
        .listen((List<Printer> event) async {
          log("Received devices list: $event");

          final printers =
              event
                  .where((printer) => printer.name?.isNotEmpty ?? false)
                  .toList();

          if (printers.isNotEmpty) {
            try {
              final selectedPrinter = printers.first;
              log("Connecting to printer: ${selectedPrinter.name}");
              await flutterThermalPrinterPlugin.connect(selectedPrinter);
              log("Successfully connected to printer: ${selectedPrinter.name}");

              // Cetak tiket
              await printTicket(
                selectedPrinter,
                values,
              ); // Pass values to printTicket

              // Hentikan scan dan langganan
              await flutterThermalPrinterPlugin.stopScan();
              log("Stopping scan after print completed.");
              await devicesStreamSubscription?.cancel();
            } catch (e) {
              log("Error during printing: $e");
            } finally {
              isPrintingInProgress = false; // Reset flag setelah selesai
            }
          } else {
            log("No printers found.");
            isPrintingInProgress =
                false; // Reset flag jika tidak ada printer ditemukan
          }
        });
  }

  static Future<void> printTicket(Printer printer, Penumpang values) async {
    log("Printing ticket for printer: ${printer.name}");
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm72, profile);
    List<int> bytes = [];

    // Data Header
    String companyName = values.companyName;
    String header = values.header;

    // Data passenger

    // Header
    bytes += generator.text(
      companyName,
      styles: const PosStyles(
        bold: true,
        height: PosTextSize.size3,
        width: PosTextSize.size3,
        align: PosAlign.center,
        fontType: PosFontType.fontB,
      ),
    );
    bytes += generator.text(
      header,
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      "---------------------",
      styles: const PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    int data = values.ticketNo.length;
    // Data Body (Details)
    for (var i = 0; i < data; i++) {
      bytes += generator.text(
        values.ticketNo[i],
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.emptyLines(1);
      bytes += generator.qrcode(
        values.qrCode[i],
        size: QRSize.size8,
        align: PosAlign.center,
      );
      bytes += generator.feed(1);
      bytes += generator.text(
        values.penumpang[i],
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        values.passengerName[i],
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.emptyLines(1);
      bytes += generator.text(
        values.pergi[i],
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        values.departureDate[i],
        styles: const PosStyles(bold: true, align: PosAlign.center),
      );
      bytes += generator.text(
        values.scheduleCode[i],
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        values.pickUp[i],
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        values.departure[i],
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.text(
        values.departurePoolName[i],
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        values.departureTime[i],
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.emptyLines(1);
      bytes += generator.text(
        values.kursi[i],
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.emptyLines(1);
      bytes += generator.text(
        values.seatNo[i],
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size7,
          width: PosTextSize.size7,
        ),
      );
      bytes += generator.emptyLines(1);
      bytes += generator.text(
        values.dropOff[i],
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        values.destination[i],
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.text(
        values.destinationPoolName[i],
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        values.ticketPrice[i],
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size4,
          width: PosTextSize.size4,
        ),
      );
      bytes += generator.text(
        // DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
        values.transactionTime[i],
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        "---------------------",
        styles: const PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
    }

    // Footer
    bytes += generator.text(
      "Terima Kasih Telah Menggunakan $companyName",
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );

    bytes += generator.cut();

    // Kirim data untuk dicetak
    try {
      await FlutterThermalPrinter.instance.printData(
        printer,
        bytes,
        longData: true,
      );
      log("Ticket printed successfully.");
    } catch (e) {
      log("Error printing ticket: $e");
    }
  }
}
