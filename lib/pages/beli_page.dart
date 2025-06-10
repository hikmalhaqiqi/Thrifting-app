import 'package:flutter/material.dart';
import 'package:ta_prak_tpm/pages/home_page.dart';
import 'package:ta_prak_tpm/services/barang_service.dart';
import 'package:ta_prak_tpm/services/notification_service.dart';

class BeliPage extends StatelessWidget {
  final int id;
  const BeliPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail barang',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(padding: const EdgeInsets.all(20), child: _barangDetail()),
    );
  }

  // Widget untuk menampilkan detail pakaian dari API
  Widget _barangDetail() {
    return FutureBuilder(
      future: BarangService.getBarangById(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print("Error in FutureBuilder: ${snapshot.error}"); // Debug print
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  "Terjadi kesalahan: ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          final barang = snapshot.data!;
          return _barang(barang, context);
        } else {
          return const Center(
            child: Text('Data tidak ditemukan', style: TextStyle(fontSize: 16)),
          );
        }
      },
    );
  }

  Widget _barang(barang, BuildContext context) {
    double usdRate = 15000;
    double hargaUSD = 0;

    // Safety check untuk harga
    try {
      if (barang.harga != null) {
        hargaUSD = barang.harga / usdRate;
      }
    } catch (e) {
      print("Error calculating USD rate: $e");
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            barang.nama ?? 'Nama tidak tersedia',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Harga: Rp ${barang.harga?.toString() ?? '0'}',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 5),
          Text(
            'USD: \$${hargaUSD.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  // Tampilkan loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const AlertDialog(
                        content: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 20),
                            Text("Memproses pembayaran..."),
                          ],
                        ),
                      );
                    },
                  );

                  // Simulasi proses pembayaran
                  await Future.delayed(const Duration(seconds: 2));

                  // Tutup loading dialog
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }

                  // Show local notification menggunakan NotificationService
                  await NotificationService().showPurchaseNotification(
                    barang.nama ?? 'item ini',
                  );

                  // Show in-app confirmation dengan SnackBar
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Pembayaran Berhasil!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Barang "${barang.nama ?? 'ini'}" telah berhasil dibeli',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green[600],
                        duration: const Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                        action: SnackBarAction(
                          label: 'OK',
                          textColor: Colors.white,
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                        ),
                      ),
                    );
                  }

                  // Navigasi ke HomePage dengan delay
                  await Future.delayed(const Duration(milliseconds: 2000));

                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  }
                } catch (e) {
                  print("Error in button onPressed: $e");

                  // Tutup loading dialog jika masih terbuka
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }

                  // Show error snackbar
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.error,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Terjadi kesalahan, silakan coba lagi',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red[600],
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Bayar Sekarang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
