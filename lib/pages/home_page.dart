import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_prak_tpm/models/barang_model.dart';
import 'package:ta_prak_tpm/pages/detail_page.dart';
import 'package:ta_prak_tpm/services/barang_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Barang>> _barangFuture;

  // Variables untuk search dan filter
  String? selectedCategory = 'Semua';
  String searchQuery = '';
  List<Barang> filteredBarang = [];
  List<Barang> originalBarang = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _barangFuture = BarangService.getBarang();
  }

  void _refresh() {
    setState(() {
      _barangFuture = BarangService.getBarang();
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Method untuk filter barang berdasarkan search query
  void _filterBarang(String query) {
    setState(() {
      searchQuery = query;
      _applyFilters();
    });
  }

  // Method untuk filter barang berdasarkan kategori
  void _filterByCategory(String? category) {
    setState(() {
      selectedCategory = category ?? 'Semua';
      _applyFilters();
    });
  }

  // Method untuk menerapkan semua filter
  void _applyFilters() {
    filteredBarang = originalBarang.where((item) {
      // Filter berdasarkan search query
      bool matchesSearch =
          searchQuery.isEmpty ||
          item.nama!.toLowerCase().contains(searchQuery.toLowerCase());

      // Filter berdasarkan kategori
      bool matchesCategory =
          selectedCategory == 'Semua' || item.kategori == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Method untuk clear search
  void _clearSearch() {
    setState(() {
      searchQuery = '';
      searchController.clear();
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Second Loop',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder<List<Barang>>(
        future: _barangFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Terjadi kesalahan saat mengambil data."),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Data Barang kosong."));
          }

          // Inisialisasi data untuk filter
          if (originalBarang.isEmpty) {
            originalBarang = snapshot.data!;
            filteredBarang = originalBarang;
          }

          return Column(
            children: [
              // Search Bar dan Dropdown Filter
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[50],
                child: Column(
                  children: [
                    // Search TextField
                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        _filterBarang(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari barang...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _clearSearch();
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Dropdown Filter
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          dropdownColor: Colors.white,
                          hint: const Text('Pilih Kategori'),
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: const [
                            DropdownMenuItem(
                              value: 'Semua',
                              child: Text('Semua Kategori'),
                            ),
                            DropdownMenuItem(
                              value: 'atasan',
                              child: Text('Atasan'),
                            ),
                            DropdownMenuItem(
                              value: 'bawahan',
                              child: Text('Bawahan'),
                            ),
                            DropdownMenuItem(
                              value: 'sepatu',
                              child: Text('Sepatu'),
                            ),
                            DropdownMenuItem(
                              value: 'outerwear',
                              child: Text('Outerwear'),
                            ),
                            DropdownMenuItem(
                              value: 'aksesori',
                              child: Text('Aksesori'),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            _filterByCategory(newValue);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // GridView
              Expanded(
                child:
                    filteredBarang.isEmpty &&
                        (searchQuery.isNotEmpty || selectedCategory != 'Semua')
                    ? const Center(
                        child: Text(
                          'Tidak ada barang yang ditemukan',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.65,
                            ),
                        itemCount: filteredBarang.length,
                        itemBuilder: (context, index) {
                          final item = filteredBarang[index];
                          return Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailPage(id: item.id!),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Container untuk gambar
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                        child: Image.network(
                                          item.foto!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Center(
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      size: 50,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Container untuk informasi barang
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Nama barang
                                          Text(
                                            item.nama!,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          const SizedBox(height: 4),

                                          // Kategori
                                          Text(
                                            item.kategori ?? "",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          const SizedBox(height: 8),

                                          // Harga dan tombol hapus
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "\$${item.harga?.toStringAsFixed(2) ?? '0.00'}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ),

                                              // Tombol hapus
                                              InkWell(
                                                onTap: () async {
                                                  final confirmed = await showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                          title: const Text(
                                                            "Hapus Barang",
                                                          ),
                                                          content: const Text(
                                                            "Yakin ingin menghapus barang ini?",
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    false,
                                                                  ),
                                                              child: const Text(
                                                                "Batal",
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    true,
                                                                  ),
                                                              child: const Text(
                                                                "Hapus",
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                  );

                                                  if (confirmed == true) {
                                                    // await BarangService.deleteBarang(item.id!);
                                                    _refresh();
                                                    // Reset filter setelah refresh
                                                    originalBarang.clear();
                                                    filteredBarang.clear();
                                                  }
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  // child: const Icon(
                                                  //   Icons.delete,
                                                  //   color: Colors.red,
                                                  //   size: 20,
                                                  // ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
