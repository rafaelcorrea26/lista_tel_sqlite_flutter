import 'dart:async';
import 'package:app_sqlite_flutter/Model/Contato.dart';
import 'Connection.dart';

class ContatoDAO {
  Future<Map> get() async {
    var _db = await Connection.get();
    Map result = Map();
    List<Map> items = await _db.query('contato');

    if (items.isNotEmpty) {
      result = items.first;
    }
    return result;
  }

  Future<List<Contato>> consultar() async {
    var _db = await Connection.get();
    List<Map> retorno = await _db.rawQuery("SELECT * FROM contato ");
    List<Contato> contatos = [];
    for (Map jogador in retorno) {
      contatos.add(Contato.fromMap(jogador));
    }
    return contatos;
  }

  Future<List<Contato>> consultarTodos() async {
    var _db = await Connection.get();

    List<Map> retorno = await _db.query('contato');
    List<Contato> contatos = [];
    print(retorno);

    for (Map map in retorno) {
      contatos.add(Contato.fromMap(map));
    }

    return contatos;
  }

  Future<Contato> searchId(int id) async {
    var _db = await Connection.get();
    List<Map> items = await _db.query('contato', where: 'id =?', whereArgs: [id]);

    if (items.isNotEmpty) {
      return Contato.fromMap(items.first);
    } else {
      return null!;
    }
  }

  Future insert(Contato contato) async {
    try {
      var _db = await Connection.get();
      await _db.insert('contato', contato.toMap());
      print('Contato inserido: ' + contato.nome);
      print('Contato cadastrado!');
    } catch (ex) {
      print(ex);
      return;
    }
  }

  update(Contato contato) async {
    try {
      var _db = await Connection.get();
      await _db.update('usuario', contato.toMap(), where: "id = ?", whereArgs: [contato.id]);
      print('Contato alterado: ' + contato.nome);
    } catch (ex) {
      print(ex);
      return;
    }
  }

  delete(int id) async {
    try {
      var _db = await Connection.get();
      await _db.delete('contato', where: "id = ?", whereArgs: [id]);
      print('Contato deletado: ' + id.toString());
    } on Exception catch (_) {
      print("Erro ao deletar id: "[id]);
      throw Exception("Erro ao deletar id: "[id]);
    }
  }

  Future<bool> existTelefone(String telefone) async {
    var _db = await Connection.get();
    List<Map> retorno = await _db.query('contato', where: " telefone = ?", whereArgs: [telefone]);
    if (retorno.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
