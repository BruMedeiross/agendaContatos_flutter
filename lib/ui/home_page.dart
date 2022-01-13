import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderaz, orderza} //enum = enumerador

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //classe contactHelper permite que existe apenas 1 banco de dados no app
  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List(); //LISTA DE CONTATOS VAZIA

  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }
  /* dados fake
   Contact c  = Contact();
    c.name = "brsrsrsrsr";
    c.email ="bereresrs@mail.com";
    c.phone = "1121212";
    c.img = "imgtest";
    helper.saveContact(c); */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          //menu odenador <OrderOptions>
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderza,
              ),
            ],
            //ordena a lista
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      //BOTÃO FLUTUANTE
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            _showContactPage();
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.red,
      ),
      body: ListView.builder(//CORPO DO APP - LISTA
          padding: EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _contactCard(context, index); //
          }
      ),
    );
  }

  //
  Widget _contactCard(BuildContext context, int index){
    return GestureDetector( //click do card
      child: Card(
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Container(//imagem redonda
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,// formato
                    image: DecorationImage(
                        image: contacts[index].img != null ? //se nao tiver imagem
                          FileImage(File(contacts[index].img)) :
                            AssetImage("images/person.png"),//imagem padrao
                        fit: BoxFit.cover
                    ),
                  ),
                ),
                Expanded(
                 child: Padding(//espaçamento entre a img e textos
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, //alinhamentos do texto
                    children: <Widget>[
                      Text(contacts[index].name ?? "", // se nao tiver texto ficara vazio
                        style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(contacts[index].email ?? "",
                        style: TextStyle(fontSize: 18.0),
                      ),
                      Text(contacts[index].phone ?? "",
                        style: TextStyle(fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                ),
              ],
            ),
        ),
      ),

      onTap: (){
        //ao clicar no contato da main mosta opcoes(editar,ligar, excluir)
        _showOptions(context, index);
      },
    );
  }

  //opceos
  void _showOptions(BuildContext context, int index){
    showModalBottomSheet( //janela de opcoes
        context: context,
        builder: (context){
          return BottomSheet(
            onClosing: (){},
            builder: (context){
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  //ocupar o min espaço possivel no eixo proncipal
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Ligar",
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                        onPressed: (){
                          launch("tel:${contacts[index].phone}");
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Editar",
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                        onPressed: (){
                          Navigator.pop(context); //fecha bottomsheet
                          _showContactPage(contact: contacts[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Excluir",
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                        onPressed: (){
                          helper.deleteContact(contacts[index].id);
                          setState(() {
                            //como houve atualizacao da lista - set state
                            contacts.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
    );
  }
  //passando contatos entre telas {parametro opcional}
  void _showContactPage({Contact contact}) async {
                                    //push coloca elemento na pilha
    final recContact = await Navigator.push(context,
      //rota> tela : contactPage
      MaterialPageRoute(builder: (context) => ContactPage(contact: contact,))
    );
    if(recContact != null){
      if(contact != null){
        await helper.updateContact(recContact); //atualiza
      } else {
        await helper.saveContact(recContact);//salva
      }
      _getAllContacts();
    }
  }

  void _getAllContacts(){
    helper.getAllContacts().then((list){
      setState(() {
        contacts = list;
      });
    });
  }

  // ordena a lista de contatos de acordo com o que for selecionado a-z ou z-a
  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }

}
