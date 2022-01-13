import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

//nome das colunas e tabela
final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper {
  //padrao singleton - apenas um objeto podera ser acessado da classe
  //static - somente um , final - nao é alteravel, ContactHelper - objeto,
  // _instance somente ele sera acessado atraves de factory

  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  //banco de dados
  Database _db;

  //inicializar o db, funcao assincrona
  Future<Database> get db async {
    if(_db != null){
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }


  //inicializar o db caso seja nullo
  Future<Database> initDb() async {
    //onde esta armazenado
    final databasesPath = await getDatabasesPath();
    //caminho do arquivo armazenado
    final path = join(databasesPath, "contactsnew.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
            "$phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }
  //funcoes de salvar contato
  //funcoes<lista> pegar (parametro contact)
  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
                     //parametro  insert(table e values)
    contact.id = await dbContact.insert(contactTable, contact.toMap()); //tranfomado em mapa - toMap
    return contact;
  }
  //obter os dados do contato pesquisado
  //funcoes<lista> pegar (parametro id)
  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    //retorna uma lista de dds
    List<Map> maps = await dbContact.query(contactTable,
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
      where: "$idColumn = ?",
      whereArgs: [id]);
    //se houver o contato
    if(maps.length > 0){
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }
  //funcoes<retorna um inteiro> excluir (parametro id)
  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
                          //delete o contato (tabela, onde? na colunaId, qual? o id passado
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }


  //funcoes<inteiro> atualiza (parametro contact)
  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    //atualize o contato (na tabela, onde? na colunaId, qual? o id passado
    return await dbContact.update(contactTable,
        contact.toMap(),
        where: "$idColumn = ?",
        whereArgs: [contact.id]);
  }
 //<list>
  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    //tranforma mapa em contato
    List<Contact> listContact = List();
    for(Map m in listMap){ //para cada mapa, tranf em contato na lista
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }
   //obter a quantidade de itens da lista
  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }
  //fechar o banco
  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }

}

//molde contatos - o que sera armazenado - nome email etc
class Contact {

  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  //contrutor do mapa de Contato
  Contact.fromMap(Map map){
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }


  //Contato tranf em mapa
  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if(id != null){
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }

}