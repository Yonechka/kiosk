import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';

class ThermalPrintScreen extends StatefulWidget {
  const ThermalPrintScreen({super.key});

  @override
  State<ThermalPrintScreen> createState() => _ThermalPrintScreenState();
}

class _ThermalPrintScreenState extends State<ThermalPrintScreen> {
  final _flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;

  List<Printer> printers = [];

  StreamSubscription<List<Printer>>? _devicesStreamSubscription;

  void startScan() async {
    _devicesStreamSubscription?.cancel();
    await _flutterThermalPrinterPlugin.getPrinters(
      connectionTypes: [ConnectionType.USB, ConnectionType.BLE],
    );
    _devicesStreamSubscription = _flutterThermalPrinterPlugin.devicesStream
        .listen((List<Printer> event) {
          log(event.map((e) => e.name).toList().toString());
          setState(() {
            printers = event;
            printers.removeWhere(
              (element) => element.name == null || element.name == '',
            );
          });
        });
  }

  void printTicket(int index) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm72, profile);
    List<int> bytes = [];

    bytes += generator.text(
      "company_name",
      styles: const PosStyles(
        bold: true,
        height: PosTextSize.size3,
        width: PosTextSize.size3,
        align: PosAlign.center,
        fontType: PosFontType.fontB,
      ),
    );
    bytes += generator.text(
      "CALL CENTER & WHATSAPP",
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      "---------------------",
      styles: const PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.text(
      "ticket_no",
      styles: const PosStyles(
        bold: true,
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.emptyLines(1);
    bytes += generator.qrcode(
      "qr_code",
      size: QRSize.size8,
      align: PosAlign.center,
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      "PENUMPANG",
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      "passenger_name",
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.emptyLines(1);
    bytes += generator.text(
      "PERGI",
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      "departure_date",
      styles: const PosStyles(bold: true, align: PosAlign.center),
    );
    bytes += generator.text(
      "schedule_code",
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      "PICK UP:",
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      "departure",
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      "departure_pool_name",
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      "departure_time",
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.emptyLines(1);
    bytes += generator.text(
      "KURSI",
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.emptyLines(1);
    bytes += generator.text(
      "seat_no",
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size7,
        width: PosTextSize.size7,
      ),
    );
    bytes += generator.emptyLines(1);
    bytes += generator.text(
      "DROP OFF",
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      "destination",
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      "destination_pool_name",
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      "ticket_price",
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size4,
        width: PosTextSize.size4,
      ),
    );
    bytes += generator.text(
      // DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
      "transaction_time",
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.text(
      "---------------------",
      styles: const PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.text(
      "Terima Kasih Telah Menggunakan Kruzzi",
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    bytes += generator.cut();

    await _flutterThermalPrinterPlugin.printData(
      printers[index],
      bytes,
      longData: true,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startScan();
    });
  }

  stopScan() {
    _flutterThermalPrinterPlugin.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () {
              // startScan();
              startScan();
              log("start scan button");
            },
            child: const Text('Get Printers'),
          ),
          ElevatedButton(
            onPressed: () {
              // startScan();
              log("stop scan button");
              stopScan();
            },
            child: const Text('Stop Scan'),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: printers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () async {
                    if (printers[index].isConnected ?? false) {
                      await _flutterThermalPrinterPlugin.disconnect(
                        printers[index],
                      );
                    } else {
                      await _flutterThermalPrinterPlugin.connect(
                        printers[index],
                      );
                    }
                  },
                  title: Text(printers[index].name ?? 'No Name'),
                  subtitle: Text("Connected: ${printers[index].isConnected}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.connect_without_contact),
                    onPressed: () async {
                      printTicket(index);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                labelText: "Test Scanner",
                labelStyle: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                hintText: 'Scan your item here',
                hintStyle: TextStyle(color: Colors.grey.shade300),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade500,
                    width: 2.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
