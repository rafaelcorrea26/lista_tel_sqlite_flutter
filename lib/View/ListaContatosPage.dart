import 'package:app_sqlite_flutter/Model/Contato.dart';
import 'package:app_sqlite_flutter/Model/ContatoDAO.dart';
import 'package:app_sqlite_flutter/View/ContatosPage.dart';
import 'package:flutter/material.dart';

import 'ContatosPage.dart';

enum Opcoes { crescente, decrescente }

class ListaContatosPage extends StatefulWidget {
  const ListaContatosPage({Key? key}) : super(key: key);

  @override
  _ListaContatosPageState createState() => _ListaContatosPageState();
}

class _ListaContatosPageState extends State<ListaContatosPage> {
  List<Contato> contatos = [];
  ContatoDAO helper = ContatoDAO();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _barraSuperior(),
      body: _listagemFutura(),
      floatingActionButton: _botaoInserir(),
    );
  }

  //Barra superior
  _barraSuperior() {
    return AppBar(
      title: const Text("Lista de contatos"),
      centerTitle: true,
      actions: <Widget>[
        PopupMenuButton<Opcoes>(
          itemBuilder: (context) {
            return <PopupMenuEntry<Opcoes>>[
              const PopupMenuItem<Opcoes>(
                child: Text("Ordem A-Z"),
                value: Opcoes.crescente,
              ),
              const PopupMenuItem<Opcoes>(
                child: Text("Ordem Z-A"),
                value: Opcoes.decrescente,
              )
            ];
          },
          onSelected: _ordenarLista,
        )
      ],
    );
  }

  //Botao flutuante para adicionar contatos
  _botaoInserir() {
    return FloatingActionButton(
      onPressed: () {
        _navCriarAlterar(Contato());

        helper.consultarTodos().then((lista) {
          setState(() {
            contatos = lista;
          });
        });
      },
      child: const Icon(Icons.add),
    );
  }

  //Constroi a lista apenas apos a leitura dos dados
  _listagemFutura() {
    return FutureBuilder(
        future: _listarTodosContatos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return _listaDosContatos();
          }
        });
  }

  //Consulta ao banco de dados
  Future _listarTodosContatos() async {
    await Future.delayed(const Duration(milliseconds: 100));
    List<Contato> lista = await helper.consultarTodos();

    contatos = lista;
  }

  //Componente com a listagem dos contatos
  _listaDosContatos() {
    return ListView.builder(
        padding: const EdgeInsets.all(15.0),
        itemCount: contatos.length,
        itemBuilder: (context, index) {
          return Dismissible(
              key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.redAccent,
                child: Align(
                  alignment: AlignmentDirectional(0.9, 0),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
              ),
              onDismissed: (DismissDirection direction) {
                Contato contatoDesfazer;
                contatoDesfazer = contatos[index];
                helper.delete(contatos[index].id);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Tarefa ${contatoDesfazer.apelido} foi removido com sucesso!',
                      style: const TextStyle(color: Color(0xff060708)),
                    ),
                    backgroundColor: Colors.white,
                    action: SnackBarAction(
                      label: 'Desfazer',
                      textColor: const Color(0xff00d7f3),
                      onPressed: () {
                        setState(() {
                          helper.insert(contatoDesfazer);
                        });
                      },
                    ),
                    duration: const Duration(seconds: 5),
                  ),
                );
                setState(() {});
              },
              child: _contatoCard(context, index));
        });
  }

  //Componente para criacao do card com as informações do contato
  _contatoCard(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        _mostrarOpcoes(context, index);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              imagemContato(contatos[index]),
              const SizedBox(
                width: 10,
              ),
              Column(
                children: <Widget>[
                  Text(
                    contatos[index].apelido,
                    style: const TextStyle(fontSize: 25),
                  ),
                  Text(
                    contatos[index].nome,
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  //Navegacao para pagina de atualizacao ou insercao
  _navCriarAlterar(Contato contato) async {
    final contatoRetornado = await Navigator.push(context, MaterialPageRoute(builder: (context) => ContatosPage(contato)));

    if (contatoRetornado != null) {
      if (contato.id > 0) {
        await helper.update(contatoRetornado);
      } else {
        await helper.insert(contatoRetornado);
      }
      setState(() {});
    }
  }

  //Componente que exibe as opcoes a serem executadas com o contato
  _mostrarOpcoes(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextButton(
                      child: const Text("Editar"),
                      onPressed: () {
                        Navigator.pop(context);
                        _navCriarAlterar(contatos[index]);
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                      child: const Text(
                        "Remover",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        helper.delete(contatos[index].id);
                        //listarTodosContatos();
                        setState(() {});
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  //Componente circular para exibir a imagem do contato no card da lista
  Widget imagemContato(Contato contato) {
    return Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black12),
        child: const Icon(
          Icons.person,
          size: 50,
          color: Colors.blueAccent,
        ));
  }

  //Funcao que ordena os itens da lista
  _ordenarLista(Opcoes opcoes) {
    switch (opcoes) {
      case Opcoes.crescente:
        contatos.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
        break;
      case Opcoes.decrescente:
        contatos.sort((b, a) => b.nome.toLowerCase().compareTo(a.nome.toLowerCase()));
        break;
    }
    setState(() {});
  }
}
