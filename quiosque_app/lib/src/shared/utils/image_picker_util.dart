import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();

/// Proporção do banner do quiosque (16:9, paisagem).
const CropAspectRatio aspectRatioBanner =
    CropAspectRatio(ratioX: 16, ratioY: 9);

/// Proporção da imagem dos itens (quadrada, 1:1).
const CropAspectRatio aspectRatioItem = CropAspectRatio(ratioX: 1, ratioY: 1);

Future<String?> _pegarImagem(
  ImageSource source, {
  CropAspectRatio? aspectRatio,
}) async {
  final XFile? imagem = await _picker.pickImage(source: source);
  if (imagem == null) return null;

  // Trava a proporção do recorte para que a imagem encaixe exatamente no
  // container onde será exibida (banner 16:9, itens 1:1).
  final bool travar = aspectRatio != null;

  final CroppedFile? imagemCortada = await ImageCropper().cropImage(
    sourcePath: imagem.path,
    aspectRatio: aspectRatio,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Ajustar foto',
        toolbarColor: const Color(0xFFC0420A),
        toolbarWidgetColor: Colors.white,
        lockAspectRatio: travar,
        hideBottomControls: travar,
      ),
      IOSUiSettings(
        title: 'Ajustar foto',
        aspectRatioLockEnabled: travar,
        rotateButtonsHidden: travar,
      ),
    ],
  );

  return imagemCortada?.path;
}

/// Abre um bottom sheet (câmera/galeria) e retorna o caminho da imagem
/// escolhida e cortada, ou null se cancelado.
///
/// Informe [aspectRatio] para travar o recorte numa proporção fixa
/// (ex.: [aspectRatioBanner] ou [aspectRatioItem]).
Future<String?> escolherImagem(
  BuildContext context, {
  CropAspectRatio? aspectRatio,
}) {
  return showModalBottomSheet<String?>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final cor = Theme.of(ctx).colorScheme.outline;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Imagem'.toUpperCase(),
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: cor),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.camera_alt, color: cor),
                title: Text('Tirar foto',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: cor)),
                onTap: () async {
                  final path = await _pegarImagem(ImageSource.camera,
                      aspectRatio: aspectRatio);
                  if (ctx.mounted) Navigator.pop(ctx, path);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: cor),
                title: Text('Escolher da galeria',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: cor)),
                onTap: () async {
                  final path = await _pegarImagem(ImageSource.gallery,
                      aspectRatio: aspectRatio);
                  if (ctx.mounted) Navigator.pop(ctx, path);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
