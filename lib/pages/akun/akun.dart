import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:caffe_pandawa/helpers/logout.dart';
// import 'package:caffe_pandawa/pages/akun/toko_saya/pengaturan_toko.dart';
import 'package:caffe_pandawa/pages/akun/toko_saya/profil_toko.dart';

class Akun extends StatelessWidget {
  const Akun({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // systemOverlayStyle: SystemUiOverlayStyle.dark,
        foregroundColor: Colors.white,
        backgroundColor: Colors.brown,
        elevation: 0,
        title: const Text(
          'Akun Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Handle notification action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // CircleAvatar(
              //   radius: 40,
              //   backgroundColor: Colors.brown.shade100,
              //   child: const CircleAvatar(
              //     radius: 38,
              //     // backgroundImage: AssetImage('assets/images/store_logo.png'),
              //     // Gunakan NetworkImage jika gambar dari internet
              //     backgroundImage: NetworkImage(
              //         'http://127.0.0.1:8000/storage/photos/indomie_goreng.png'),
              //   ),
              // ),
              // const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Caffe Pandawa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: Colors.brown.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Caffe Terverifikasi',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.brown.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  // Handle edit profile action
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat('Transaksi', '127'),
                const VerticalDivider(thickness: 1, color: Colors.grey),
                _buildStat('Produk', '53'),
                const VerticalDivider(thickness: 1, color: Colors.grey),
                _buildStat('Pegawai', '4'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Pengaturan Akun',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildMenuCategory('Toko Saya', [
            MenuItem(
              icon: Icons.store,
              title: 'Profil Toko',
              subtitle: 'Kelola informasi toko Anda',
              action: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProfilToko(),
                  ),
                );
              },
              color: Colors.brown,
            ),
            MenuItem(
              icon: Icons.description,
              title: 'Pengaturan Toko',
              subtitle: 'Hutang, Pembulatan, Dering',
              action: () {
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (_) => PengaturanToko(),
                //   ),
                // );
              },
              color: Colors.brown,
            ),
            MenuItem(
              icon: Icons.people,
              title: 'Karyawan & Izin',
              subtitle: 'Kelola staf dan hak akses',
              action: () {},
              color: Colors.brown,
            ),
          ]),
          const SizedBox(height: 20),
          _buildMenuCategory('Perangkat', [
            MenuItem(
              icon: Icons.print,
              title: 'Pengaturan Printer',
              subtitle: 'Hubungkan dan kelola printer',
              action: () {},
              color: Colors.brown,
            ),
            MenuItem(
              icon: Icons.bluetooth,
              title: 'Bluetooth & Perangkat',
              subtitle: 'Kelola perangkat terhubung',
              action: () {},
              color: Colors.brown,
            ),
            MenuItem(
              icon: Icons.point_of_sale,
              title: 'Mesin Kasir',
              subtitle: 'Pengaturan point of sale',
              action: () {},
              color: Colors.brown,
            ),
            MenuItem(
              icon: Icons.qr_code_scanner,
              title: 'Scanner & Barcode',
              subtitle: 'Pengaturan pemindai',
              action: () {},
              color: Colors.brown,
            ),
          ]),
          const SizedBox(height: 20),
          _buildMenuCategory('Sistem', [
            MenuItem(
              icon: Icons.language,
              title: 'Bahasa',
              subtitle: 'Indonesia',
              action: () {},
              color: Colors.brown,
            ),
            MenuItem(
              icon: Icons.notifications_active,
              title: 'Notifikasi',
              subtitle: 'Atur pemberitahuan aplikasi',
              action: () {},
              color: Colors.brown,
            ),
            MenuItem(
              icon: Icons.security,
              title: 'Keamanan',
              subtitle: 'Kata sandi dan autentikasi',
              action: () {},
              color: Colors.brown,
            ),
            MenuItem(
              icon: Icons.help_outline,
              title: 'Bantuan & Dukungan',
              subtitle: 'Panduan dan kontak support',
              action: () {},
              color: Colors.brown,
            ),
            MenuItem(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              subtitle: 'Versi 2.3.5',
              action: () {},
              color: Colors.brown,
            ),
          ]),
          const SizedBox(height: 30),
          Center(
            child: TextButton(
              onPressed: () {
                confirmLogout(context);
              },
              child: Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMenuCategory(String title, List<MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.shade200,
              indent: 56,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      item.color?.withOpacity(0.1) ?? Colors.grey.shade100,
                  child: Icon(
                    item.icon,
                    color: item.color ?? Colors.grey.shade700,
                  ),
                ),
                title: Text(item.title),
                subtitle: Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: item.action,
              );
            },
          ),
        ),
      ],
    );
  }
}

class MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback action;
  final Color? color;

  MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    this.color,
  });
}
