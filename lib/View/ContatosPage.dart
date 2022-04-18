import 'dart:io';

import 'package:app_sqlite_flutter/Controller/Validators.dart';
import 'package:app_sqlite_flutter/Model/Contato.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ContatosPage extends StatefulWidget {
  Contato contato;

  ContatosPage(this.contato);

  @override
  _ContatosPageState createState() => _ContatosPageState();
}

class _ContatosPageState extends State<ContatosPage> {
  Contato _contatoTemporario = Contato();
  var CaminhoImagem = "assets/pictures/profile-picture.jpg";
  File? _arquivo;

  bool contatoFoiAlterdao = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _apelidoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState;

    if (widget.contato.id > 0) {
      //editar Contato
      //duplica o contato para não alterar instância original antes da modificação
      _contatoTemporario = Contato.fromMap(widget.contato.toMap());
      _nomeController.text = _contatoTemporario.nome;
      _apelidoController.text = _contatoTemporario.apelido;
      _telefoneController.text = _contatoTemporario.telefone;
      _emailController.text = _contatoTemporario.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _voltarComAlert,
      child: Scaffold(
        appBar: _barraSuperior(),
        body: corpo(),
        floatingActionButton: _botaoSalvarAlterar(),
      ),
    );
  }

  _barraSuperior() {
    return AppBar(
      title: Text(_contatoTemporario.nome == "" ? "Novo Contato" : _contatoTemporario.nome),
    );
  }

  Future _mostraDialogoEscolha(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Escolha uma opção",
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Divider(
                    height: 1,
                    color: Colors.blue,
                  ),
                  ListTile(
                    onTap: () {
                      _abreGaleria(context);
                    },
                    title: Text("Galeria"),
                    leading: Icon(
                      Icons.account_box,
                      color: Colors.blue,
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.blue,
                  ),
                  ListTile(
                    onTap: () {
                      _abreCamera(context);
                    },
                    title: Text("Câmera"),
                    leading: Icon(
                      Icons.camera,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future _abreCamera(BuildContext context) async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);

      if (image == null) return;

      cropImage(image.path);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future _abreGaleria(BuildContext context) async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null) return;

      cropImage(image.path);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  cropImage(filePath) async {
    File? croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxWidth: 600,
      maxHeight: 600,
      aspectRatio: CropAspectRatio(ratioX: 9, ratioY: 9),
      androidUiSettings: androidUiSettings(),
      iosUiSettings: iosUiSettings(),
    );
    if (croppedImage != null) {
      final imageTemp = croppedImage; //File(croppedImage.path);
      setState(() => this._arquivo = imageTemp);
    }
  }

  static IOSUiSettings iosUiSettings() => IOSUiSettings(
        aspectRatioLockEnabled: false,
      );

  static AndroidUiSettings androidUiSettings() => AndroidUiSettings(
        toolbarTitle: 'Ajuste a Imagem',
        toolbarColor: Colors.red,
        toolbarWidgetColor: Colors.white,
        lockAspectRatio: false,
      );

  _botaoSalvarAlterar() {
    return FloatingActionButton(
      child: const Icon(Icons.save),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          if (_contatoTemporario.nome != "" &&
              _contatoTemporario.nome.isNotEmpty &&
              _contatoTemporario.apelido != "" &&
              _contatoTemporario.apelido.isNotEmpty &&
              _contatoTemporario.telefone != "" &&
              _contatoTemporario.telefone.isNotEmpty &&
              _contatoTemporario.email != "" &&
              _contatoTemporario.email.isNotEmpty) {
            Navigator.pop(context, _contatoTemporario);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Existe campos incorretos!')),
          );
        }
      },
    );
  }

  Widget corpo() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            iconeContato(),
            TextFormField(
              validator: Validators.compose([
                Validators.required('Nome não pode ficar em branco.'),
              ]),
              controller: _nomeController,
              keyboardType: TextInputType.text,
              onChanged: (texto) {
                contatoFoiAlterdao = true;
                setState(() {
                  _contatoTemporario.apelido = texto;
                });
              },
              decoration: InputDecoration(
                labelText: 'Nome',
              ),
            ),
            TextFormField(
              validator: Validators.compose([
                Validators.required('Apelido não pode ficar em branco.'),
              ]),
              controller: _apelidoController,
              keyboardType: TextInputType.text,
              onChanged: (texto) {
                contatoFoiAlterdao = true;
                setState(() {
                  _contatoTemporario.apelido = texto;
                });
              },
              decoration: InputDecoration(
                labelText: 'Apelido',
              ),
            ),
            TextFormField(
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
                TelefoneInputFormatter(),
              ],
              validator: Validators.compose([
                Validators.required('Telefone não pode ficar em branco.'),
              ]),
              controller: _telefoneController,
              keyboardType: TextInputType.text,
              onChanged: (texto) {
                contatoFoiAlterdao = true;
                setState(() {
                  _contatoTemporario.telefone = texto;
                });
              },
              decoration: InputDecoration(
                labelText: 'Telefone',
              ),
            ),
            TextFormField(
              validator: Validators.compose([
                Validators.required('Email não pode ficar em branco.'),
                // Validators.email(""),
              ]),
              controller: _emailController,
              keyboardType: TextInputType.text,
              onChanged: (texto) {
                contatoFoiAlterdao = true;
                setState(() {
                  _contatoTemporario.email = texto;
                });
              },
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Formato padrao para os campos de insercao de textos
  _camposInsercaoTexto(String textoLabel, String campo, TextEditingController controller) {
    return TextFormField(
      validator: Validators.compose([
        Validators.required(textoLabel + ' não pode ficar em branco.'),
      ]),
      controller: controller,
      keyboardType: TextInputType.text,
      onChanged: (texto) {
        contatoFoiAlterdao = true;
        setState(() {
          switch (campo) {
            case "nome":
              _contatoTemporario.nome = texto;
              break;
            case "apelido":
              _contatoTemporario.apelido = texto;
              break;
            case "telefone":
              _contatoTemporario.telefone = texto;
              break;
            case "email":
              _contatoTemporario.email = texto;
              break;
          }
        });
      },
      decoration: InputDecoration(
        labelText: textoLabel,
      ),
    );
  }

  Widget iconeContato() {
    return GestureDetector(
      onTap: () {
        _mostraDialogoEscolha(context);
      },
      child: Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black12),
          child: const Icon(
            Icons.person,
            size: 100,
            color: Colors.blueAccent,
          )),
    );
  }

  Future<bool> _voltarComAlert() {
    if (contatoFoiAlterdao) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Descartar modificações?"),
              content: const Text("Deseja sair sem modificar o contato?"),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text("Sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
