import 'package:flutter/material.dart';

import '../../../utils/saved_address.dart';
import '../../../utils/saved_address_storage.dart';
import '../../location/screens/add_address_screen.dart';
import '../../shell/widgets/location_tiles.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({Key? key}) : super(key: key);

  @override
  State<SavedAddressesScreen> createState() =>
      _SavedAddressesScreenState();
}

class _SavedAddressesScreenState
    extends State<SavedAddressesScreen> {
  late Future<List<SavedAddress>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = SavedAddressStorage.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved addresses'),
      ),
      body: FutureBuilder<List<SavedAddress>>(
        future: _future,
        builder: (context, snapshot) {
          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return const Center(
              child: Text('No saved addresses yet'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final address = list[index];

              return AddressTile(
                icon: iconForType(address.type),
                title: address.label,
                subtitle: address.address,
                isActive: false, // profile = no selection
                onTap: () async {
                  // 👉 EDIT FLOW (same screen)
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddAddressScreen(existing: address),
                    ),
                  );

                  // Refresh after edit/delete
                  setState(_reload);
                },
              );
            },
          );
        },
      ),

      // ➕ ADD NEW ADDRESS
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddAddressScreen(),
            ),
          );
          setState(_reload);
        },
      ),
    );
  }
}
