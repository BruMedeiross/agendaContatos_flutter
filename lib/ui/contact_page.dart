import 'dart:async';
import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class ContactPage extends StatefulWidget {

  final Contact contact;

  ContactPage({this.contact});//{entre chaves é um parametro opcional}

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  //contollers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode(); //foco no campo nome

  bool _userEdited = false;

  //contato que estamos editado na pagina
  Contact _editedContact;

  @override
  void initState() {
    super.initState();

    if(widget.contact == null){
      _editedContact = Contact();// novo contato
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());//editado apenas

      //setando os dados do controler na variaveis
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //quando sair da tela - chama fun
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          //se for um contato novo aparece novo contato caso contrario parace o contato a ser editado
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){//botao salvar contato
            if(_editedContact.name != null && _editedContact.name.isNotEmpty){
              //pop tira um elemento da pilha de telas
              //pop volta para a homePage, e passa os dados que estao em editedContact para a homePage
              Navigator.pop(context, _editedContact);
            } else {
              //se o campo nome estiver vazio - foca no nome(erro)
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector( //possibilita click na imagem
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: _editedContact.img != null ?
                        FileImage(File(_editedContact.img)) :
                        AssetImage("images/person.png"),
                        fit: BoxFit.cover
                    ),
                  ),
                ),
                onTap: (){
                  //ao clicar na imagem(fonte da imagem)
                  ImagePicker.pickImage(source: ImageSource.gallery).then((file){
                    if(file == null) return;
                    setState(() {
                      _editedContact.img = file.path;
                    });
                  });
                },
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text){
                  _userEdited = true;//useredited caso mude o nome
                  setState(() {
                    _editedContact.name = text; //atualiza o edidContact e AppBar
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text){
                  _userEdited = true;
                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress, //tipo de input do teclado
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone"),
                onChanged: (text){
                  _userEdited = true;
                  _editedContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop(){
    if(_userEdited){
      showDialog(context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Descartar Alterações?"),
            content: Text("Se sair as alterações serão perdidas."),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: (){
                  Navigator.pop(context); //sai do alert para continuar para salvar
                },
              ),
              FlatButton(
                child: Text("Sim"),
                onPressed: (){
                  Navigator.pop(context);//sai do alert
                  Navigator.pop(context);//sai da pag
                },
              ),
            ],
          );
        }
      );
      //se tiver dig algo não consegue sair da tela automaticamente
      return Future.value(false);
    } else {
      //se nao tiver dig nada consegue sair automaticamente
      return Future.value(true);
    }
  }

}
