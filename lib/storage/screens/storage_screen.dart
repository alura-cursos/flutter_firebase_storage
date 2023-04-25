import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_firebase_storage/storage/models/image_custom_info.dart';
import 'package:flutter_firebase_storage/storage/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';

import '../../authentication/components/show_snackbar.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  String? urlPhoto;
  List<ImageCustomInfo> listFiles = [];

  final StorageService _storageService = StorageService();

  @override
  void initState() {
    reload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Foto de Perfil"),
        actions: [
          IconButton(
            onPressed: () {
              uploadImage();
            },
            icon: const Icon(Icons.upload),
          ),
          IconButton(
            onPressed: () {
              reload();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(children: [
          (urlPhoto != null)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(64),
                  child: Image.network(
                    urlPhoto!,
                    width: 128,
                    height: 128,
                    fit: BoxFit.cover,
                  ),
                )
              : const CircleAvatar(
                  radius: 64,
                  child: Icon(Icons.person),
                ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Divider(color: Colors.black),
          ),
          const Text(
            "Histórico de Imagens",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(
              listFiles.length,
              (index) {
                ImageCustomInfo imageInfo = listFiles[index];
                return ListTile(
                  onTap: () {
                    selectImage(imageInfo);
                  },
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      imageInfo.urlDownload,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(imageInfo.name),
                  subtitle: Text(imageInfo.size),
                  trailing: IconButton(
                    onPressed: () {
                      deleteImage(imageInfo);
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                );
              },
            ),
          )
        ]),
      ),
    );
  }

  uploadImage() {
    ImagePicker imagePicker = ImagePicker();

    imagePicker
        .pickImage(
      source: ImageSource.gallery,
      maxHeight: 2000,
      maxWidth: 2000,
      imageQuality: 50,
    )
        .then((XFile? image) {
      if (image != null) {
        _storageService
            .upload(file: File(image.path), fileName: DateTime.now().toString())
            .then((String urlDownload) {
          setState(() {
            urlPhoto = urlDownload;
          });
          reload();
        });
      } else {
        showSnackBar(context: context, mensagem: "Nenhuma imagem selecionada.");
      }
    });
  }

  reload() {
    // _storageService
    //     .getDownloadUrlByFileName(fileName: "user_photo")
    //     .then((urlDownload) {
    //   setState(() {
    //     urlPhoto = urlDownload;
    //   });
    // });

    _storageService.listAllFiles().then((List<ImageCustomInfo> listFilesInfo) {
      setState(() {
        listFiles = listFilesInfo;
      });
    });
  }

  selectImage(ImageCustomInfo imageInfo) {
    setState(() {
      urlPhoto = imageInfo.urlDownload;
    });
  }

  deleteImage(ImageCustomInfo imageInfo) {
    _storageService.deleteByReference(ref: imageInfo.ref).then((value) {
      if (urlPhoto == imageInfo.urlDownload) {
        urlPhoto = null;
      }
      reload();
    });
  }
}
