import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class InputFotoPerfil extends StatefulWidget {
  /// Chamado sempre que a seleção muda. Recebe o arquivo escolhido,
  /// ou `null` quando o usuário remove a foto.
  final void Function(File? arquivo)? onImagemSelecionada;

  /// URL/caminho da foto atual (perfil já existente), exibida até o usuário
  /// escolher uma nova.
  final String? imagemInicialUrl;

  const InputFotoPerfil({
    super.key,
    this.onImagemSelecionada,
    this.imagemInicialUrl,
  });

  @override
  State<InputFotoPerfil> createState() => _InputFotoPerfilState();
}

class _InputFotoPerfilState extends State<InputFotoPerfil> {
  File? _imagemSelecionada;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pegarImagem(ImageSource source) async {
    final XFile? imagem = await _picker.pickImage(source: source);
    if (imagem == null) return;

    // Abre a tela de corte
    final CroppedFile? imagemCortada = await ImageCropper().cropImage(
      sourcePath: imagem.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ajustar foto',
          toolbarColor: const Color(0xFF1A237E),
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Ajustar foto',
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    if (imagemCortada != null) {
      setState(() {
        _imagemSelecionada = File(imagemCortada.path);
      });
      widget.onImagemSelecionada?.call(_imagemSelecionada);
    }
  }

  void _abrirModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Foto de perfil'.toUpperCase(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.outline,),
                  title: Text('Tirar foto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,color: Theme.of(context).colorScheme.outline),),
                  onTap: () {
                    Navigator.pop(context);
                    _pegarImagem(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.outline,),
                  title: Text('Escolher da galeria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,color: Theme.of(context).colorScheme.outline),),
                  onTap: () {
                    Navigator.pop(context);
                    _pegarImagem(ImageSource.gallery);
                  },
                ),
                // Opção de remover, caso já tenha imagem
                if (_imagemSelecionada != null)
                  ListTile(
                    leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.outline),
                    title: Text(
                      'Remover foto',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,color: Theme.of(context).colorScheme.outline),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _imagemSelecionada = null);
                      widget.onImagemSelecionada?.call(null);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto de perfil:',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _abrirModal,
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _imagemSelecionada != null
                    ? Image.file(
                      _imagemSelecionada!,
                      // fit: BoxFit.cover
                      fit: BoxFit.contain,
                    )
                    : (widget.imagemInicialUrl != null &&
                            widget.imagemInicialUrl!.isNotEmpty)
                        ? Image.network(
                            widget.imagemInicialUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(Icons.add_a_photo,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.outline),
                            ),
                          )
                        : Center(
                            child: Icon(Icons.add_a_photo,
                                size: 48,
                                color: Theme.of(context).colorScheme.outline),
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}