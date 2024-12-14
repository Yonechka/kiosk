import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  String connectedDeviceName = "";
  bool connected = false;
  bool isScanning = false;
  List<BluetoothDevice> devices = [];
  List<BluetoothDevice> connectedDevicesList = [];
  Timer? _scanTimer;
  bool isPermissionRequesting = false;

  @override
  void initState() {
    super.initState();
    log("App Initialized");
    checkPermissionsAndBluetoothStatus();
    checkConnectedDevices();
  }

  Future<void> checkConnectedDevices() async {
    try {
      var connectedDevices = FlutterBluePlus.connectedDevices.toList();
      if (connectedDevices.isNotEmpty) {
        setState(() {
          connectedDevicesList = connectedDevices;
        });
        _showSnackBar(
          "Already connected to ${connectedDevices.first.platformName}",
          Colors.green,
        );
      }
    } catch (e) {
      log("Error while checking connected devices: $e");
    }
  }

  Future<void> checkPermissionsAndBluetoothStatus() async {
    if (isPermissionRequesting) return;
    isPermissionRequesting = true;

    var bluetoothState = await FlutterBluePlus.adapterState.first;
    if (bluetoothState == BluetoothAdapterState.off) {
      await FlutterBluePlus.turnOn();
      _showSnackBar("Bluetooth is off. Turning it on...", Colors.red);
    }

    var statuses =
        await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location,
        ].request();

    if (statuses.values.any((status) => status.isDenied)) {
      log("Permissions denied.");
      _showSnackBar(
        "Permissions denied. Please grant all permissions.",
        Colors.red,
      );
    } else {
      log("Permissions granted.");
      _showSnackBar(
        "Permissions granted. You can now scan devices.",
        Colors.green,
      );
    }
    isPermissionRequesting = false;
  }

  void startBluetoothScan() async {
    await checkPermissionsAndBluetoothStatus();
    if (!isScanning) {
      setState(() {
        isScanning = true;
        devices = [];
      });

      log("Starting Bluetooth scan...");
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      _scanTimer = Timer(const Duration(seconds: 5), stopScan);

      try {
        FlutterBluePlus.scanResults.listen((results) {
          setState(() {
            devices =
                results
                    .map((r) => r.device)
                    .where(
                      (device) =>
                          device.platformName.isNotEmpty &&
                          device.advName.isNotEmpty,
                    )
                    .toSet()
                    .toList();

            for (var device in devices) {
              log("Device Added to List:");
              log("- Name: ${device.advName}");
              log("- Platform Name: ${device.platformName}");
              log("- ID: ${device.remoteId}");
            }
          });
        });
      } catch (e) {
        log("Error during scan: $e");
        stopScan();
      }
    }
  }

  void stopScan() async {
    if (isScanning) {
      try {
        await FlutterBluePlus.stopScan();
        log("Scan stopped.");
      } catch (e) {
        log("Error stopping scan: $e");
      }
      setState(() {
        isScanning = false;
      });
      _scanTimer?.cancel();
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    log("Attempting to connect to ${device.platformName}...");

    if (connectedDevicesList.isNotEmpty &&
        device.remoteId != connectedDevicesList.first.remoteId) {
      await disconnect(connectedDevicesList.first);
    }

    try {
      await device.connect(timeout: const Duration(seconds: 10));
      setState(() {
        connected = true;
        connectedDeviceName = device.platformName;
        connectedDevicesList = [device];
      });
      _showSnackBar("Connected to $connectedDeviceName", Colors.green);
    } catch (e) {
      log("Connection failed: $e");
      _showSnackBar("Failed to connect to device", Colors.red);
    }
  }

  Future<void> disconnect(BluetoothDevice device) async {
    log("Disconnecting from ${device.platformName}...");
    try {
      await device.disconnect();
      setState(() {
        connected = false;
        connectedDeviceName = "";
        connectedDevicesList.remove(device);
      });
      _showSnackBar("Device disconnected", Colors.blue);
    } catch (e) {
      log("Error disconnecting device: $e");
    }
  }

  Future<void> printTest() async {
    try {} catch (e) {
      log("Error while printing: $e");
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  void dispose() {
    log("Disposing resources...");
    _scanTimer?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Thermal Print"),
        leading: IconButton(
          onPressed: () {
            log("Navigating back...");
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isScanning ? null : startBluetoothScan,
                  child: const Text("Search"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isScanning ? stopScan : null,
                  child: const Text("Stop Scan"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child:
                isScanning
                    ? const Center(child: CircularProgressIndicator())
                    : devices.isEmpty
                    ? const Center(child: Text("No devices found"))
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        return Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                if (connectedDeviceName !=
                                    device.platformName) {
                                  await connect(device);
                                } else {
                                  _showSnackBar(
                                    "Already connected to this device",
                                    Colors.orange,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      connectedDeviceName == device.platformName
                                          ? Colors.blue.withAlpha(25)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      device.platformName,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
          ),
          if (connectedDevicesList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FloatingActionButton(
                    onPressed: printTest,
                    child: const Icon(Icons.print),
                  ),
                  const Center(
                    child: Text(
                      "Connected Devices",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: connectedDevicesList.length,
                    itemBuilder: (context, index) {
                      final device = connectedDevicesList[index];
                      return InkWell(
                        onTap: () => log("Device: ${device.platformName}"),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                device.platformName,
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                onPressed: () => disconnect(device),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
