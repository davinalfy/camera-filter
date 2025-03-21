import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camera/camera.dart';
import 'BiodataService.dart';
import 'widget/takepicture_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //panggil model
  biodataservice? service;
  String? selectedDocId;

  // Controller untuk input field
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final addressController = TextEditingController();

  //jalan saat screen show
  @override
  void initState() {
    service = biodataservice(FirebaseFirestore.instance);
    super.initState();
  }

  @override
  void dispose() {
    // Membersihkan controller saat widget dihapus
    nameController.dispose();
    ageController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(hintText: 'Age'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(hintText: 'Address'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder(
                  stream: service?.getBiodata(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData && snapshot.data?.docs.isEmpty == true) {
                      return const Center(child: Text('No data found'));
                    }

                    final documents = snapshot.data?.docs ?? [];
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        final docId = doc.id;

                        return ListTile(
                          title: Text(doc['name']),
                          subtitle: Text(doc['age']),
                          onTap: () {
                            setState(() {
                              nameController.text = doc['name'];
                              ageController.text = doc['age'];
                              addressController.text = doc['address'];
                              selectedDocId = docId;
                            });
                          },
                          trailing: IconButton(
                            onPressed: () {
                              service?.delete(docId);
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            child: const Icon(Icons.add),
            onPressed: () {
              final Name = nameController.text.trim();
              final Age = ageController.text.trim();
              final Address = addressController.text.trim();

              if (Name.isEmpty || Age.isEmpty || Address.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All fields must be filled')),
                );
                return;
              }

              if (selectedDocId != null) {
                service?.update(selectedDocId!, {'name': Name, 'age': Age, 'address': Address});
                selectedDocId = null;
              } else {
                service?.add({'name': Name, 'age': Age, "address": Address});
              }

              nameController.clear();
              ageController.clear();
              addressController.clear();
            },
          ),
          const SizedBox(height: 16), 
          FloatingActionButton(
            heroTag: "btn2",
            child: const Icon(Icons.camera_alt),
            onPressed: () async {
              final cameras = await availableCameras();

              if (cameras.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TakePictureScreen(cameras: cameras),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera not found')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}