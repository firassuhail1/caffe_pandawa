import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class PengaturanPrinter extends StatefulWidget {
  const PengaturanPrinter({super.key});

  @override
  State<PengaturanPrinter> createState() => _PengaturanPrinterState();
}

class _PengaturanPrinterState extends State<PengaturanPrinter> {
  bool connected = false;
  String selectedDeviceName = "";
  List<BluetoothInfo> devices = [];

  @override
  void initState() {
    super.initState();
    _checkBluetoothStatus();
  }

  Future<void> _checkBluetoothStatus() async {
    if (!mounted) return;
    final bool isEnabled = await PrintBluetoothThermal.bluetoothEnabled;
    final bool isConnected = await PrintBluetoothThermal.connectionStatus;
    setState(() => connected = isEnabled && isConnected);
  }

  Future<void> _scanDevices() async {
    setState(() => devices = []);

    if (await Permission.bluetoothScan.isDenied) {
      await Permission.bluetoothScan.request();
    }
    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();
    }

    final List<BluetoothInfo> result =
        await PrintBluetoothThermal.pairedBluetooths;
    setState(() => devices = result);
  }

  Future<void> _connectToDevice(String mac, String name) async {
    setState(() {
      connected = false;
      selectedDeviceName = name;
    });

    final bool result =
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    if (result) {
      setState(() => connected = true);
      _showConnectionFlushbar('Berhasil terhubung ke $name');
    }

    _checkBluetoothStatus();
  }

  Future<void> _disconnectPrinter() async {
    final bool status = await PrintBluetoothThermal.disconnect;
    setState(() => connected = false);
    if (status) {
      _showConnectionFlushbar('Printer berhasil di putus');
    }
  }

  void _showConnectionFlushbar(String message) {
    Flushbar(
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: Colors.green.shade600,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pengaturan Printer",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _scanDevices,
              icon: const Icon(Icons.refresh),
              label: const Text("Scan Perangkat"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: connected
                  ? _buildConnectedPrinterCard()
                  : devices.isEmpty
                      ? const Center(
                          child: Text(
                            "Belum ada perangkat ditemukan.\nSilakan scan terlebih dahulu.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemCount: devices.length,
                          itemBuilder: (context, index) {
                            final device = devices[index];
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue[100],
                                  child: const Icon(Icons.print,
                                      color: Colors.blue),
                                ),
                                title: Text(device.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(device.macAdress),
                                trailing: OutlinedButton.icon(
                                  onPressed: () => _connectToDevice(
                                      device.macAdress, device.name),
                                  icon: const Icon(Icons.bluetooth_connected,
                                      size: 16),
                                  label: const Text("Hubungkan"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blueAccent,
                                    side: const BorderSide(
                                        color: Colors.blueAccent),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedPrinterCard() {
    return ListView.separated(
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: 1,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.print, color: Colors.blue),
            ),
            title: Text(
              selectedDeviceName, // tampilkan nama device dari BluetoothInfo
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Terhubung ke perangkat"),
            trailing: OutlinedButton.icon(
              onPressed: _disconnectPrinter,
              icon: const Icon(Icons.link_off, size: 16),
              label: const Text("Putuskan"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
