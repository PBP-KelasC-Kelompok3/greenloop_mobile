import 'package:flutter/material.dart';
import 'features/courier/presentation/courier_page.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  // Data ringkas untuk header aplikasi kelompok
  final String appName = "GreenLoop";
  final String kelas = "PBP C";

  final List<ItemHomepage> items = [
    ItemHomepage("Lihat Daftar", Icons.list_alt, Colors.green.shade700),
    ItemHomepage("Tambah Data", Icons.add_circle, Colors.amber.shade700),
    ItemHomepage("Live Impact", Icons.eco, Colors.teal),
    ItemHomepage("Halaman Kurir", Icons.local_shipping, const Color(0xFF176B45), 
      page: const CourierDashboardPage()),
    ItemHomepage("Logout", Icons.logout, Colors.redAccent),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GreenLoop Mobile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InfoCard(title: 'Aplikasi', content: appName),
                InfoCard(title: 'Kelas', content: kelas),
              ],
            ),
            const SizedBox(height: 16.0),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  'Selamat datang di GreenLoop Mobile!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: GridView.count(
                primary: true,
                padding: const EdgeInsets.all(20),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
                children: items.map((item) => ItemCard(item)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 2.5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8.0),
              Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;
  final Widget? page;

  ItemHomepage(this.name, this.icon, this.color, {this.page});
}

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (item.page != null) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => item.page!),
            );
            return;
          }
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text('Kamu telah menekan tombol ${item.name}!')));
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30),
                const SizedBox(height: 6),
                Text(item.name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}