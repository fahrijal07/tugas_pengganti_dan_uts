import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite User Data',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const UserListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ========== MODEL USER ==========
class UserModel {
  int? id;
  String name;
  int age;

  UserModel({
    this.id,
    required this.name,
    required this.age,
  });
}

// ========== HALAMAN UTAMA ==========
class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  // Data disimpan dalam List (temporary)
  List<UserModel> userList = [
    UserModel(id: 1, name: 'satu', age: 10),
    UserModel(id: 2, name: 'dua', age: 11),
    UserModel(id: 3, name: 'tiga', age: 12),
    UserModel(id: 4, name: 'empat', age: 13),
  ];

  // Controller untuk form
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  // Variable untuk menyimpan mode (add atau edit)
  int? _editingId;

  // Menampilkan form (Add atau Edit)
  void showUserForm({int? id}) {
    _editingId = id;

    if (id != null) {
      // Mode edit: isi controller dengan data yang ada
      final user = userList.firstWhere((data) => data.id == id);
      nameController.text = user.name;
      ageController.text = user.age.toString();
    } else {
      // Mode add: kosongkan controller
      nameController.clear();
      ageController.clear();
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveUser,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(_editingId == null ? 'TAMBAH' : 'UBAH'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Menyimpan data (Add atau Edit)
  void _saveUser() {
    String name = nameController.text;

    if (name.isEmpty || ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan umur harus diisi!')),
      );
      return;
    }

    int age = int.tryParse(ageController.text) ?? 0;

    if (_editingId == null) {
      // MODE ADD: Tambah data baru
      int nextId = userList.isEmpty ? 1 : userList.last.id! + 1;
      UserModel newUser = UserModel(
        id: nextId,
        name: name,
        age: age,
      );
      setState(() {
        userList.add(newUser);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil ditambahkan!')),
      );
    } else {
      // MODE EDIT: Update data yang ada
      setState(() {
        final user = userList.firstWhere((data) => data.id == _editingId);
        user.name = name;
        user.age = age;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil diubah!')),
      );
    }

    Navigator.pop(context); // Tutup bottomsheet
  }

  // Konfirmasi hapus
  void _confirmDelete(int id, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah anda yakin ingin menghapus user "$name"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  userList.removeWhere((data) => data.id == id);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data berhasil dihapus!')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List User Data'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: userList.isEmpty
          ? const Center(
              child: Text('Belum ada data. Tekan tombol + untuk menambah.'),
            )
          : ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final user = userList[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Umur: ${user.age} tahun'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => showUserForm(id: user.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(user.id!, user.name),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showUserForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
