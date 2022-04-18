import 'dart:convert';

class Contato {
  int id = 0;
  String nome = "";
  String apelido = "";
  String telefone = "";
  String email = "";
  String imagem = "";
  Contato();

  Map<String, Object> toMap() {
    Map<String, Object> map = {'nome': nome, 'apelido': apelido, 'telefone': telefone, 'email': email, 'imagem': imagem};
    if (id > 0) {
      map["id"] = id;
    }
    return map;
  }

  Contato.fromMap(Map map) {
    id = map['id'];
    nome = map['nome'];
    apelido = map['apelido'];
    telefone = map['telefone'];
    email = map['email'];
    imagem = map['imagem'];
  }

  @override
  String toString() {
    return 'Doador{id: $id, '
        'nome: $nome,'
        'apelido: $nome,'
        'telefone: $telefone,'
        'email: $email,'
        'imagem: $imagem}';
  }

  String? geraJson() {
    String dados = json.encode(this);
    return dados;
  }
}
