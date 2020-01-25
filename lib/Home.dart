  import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Mapa.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  // cria stream builder para lista os dados do firebase
  final _controller = StreamController<QuerySnapshot>.broadcast();
  
  // cria instancia do firebase no mapa
  Firestore _db = Firestore.instance;

  // Metodo para navegar a tela de mapa e enviar o ID da viagem
  _abrirMapa(String idViagem){

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => Mapa( idViagem: idViagem, )
        )
    );

  }

// metodo para excluir a viagem pelo ID
  _excluirViagem(String idViagem){

    _db.collection("viagens")
        .document( idViagem )
        .delete();

  }

  _adicionarLocal(){

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => Mapa()
        )
    );

  }

  _adicionarListenerViagens() async {

    final stream = _db.collection("viagens")
        .snapshots();

    stream.listen((dados){
      _controller.add( dados );
    });

  }

  @override
  void initState() {
    super.initState();

    _adicionarListenerViagens();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Minhas viagens"),),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
          backgroundColor: Color(0xff0066cc),
          onPressed: (){
            _adicionarLocal();
          }
      ),
      body: StreamBuilder<QuerySnapshot>(
          // cria a stream pelo carregamento do dados
          stream: Firestore.instance.collection("viagens").snapshots(),
          builder: (context, snapshot){
          switch( snapshot.connectionState ){
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
              case ConnectionState.done:

                // objeto para pegar os dados da coleção viagem
                QuerySnapshot querySnapshot = snapshot.data;
                if(querySnapshot== null) return CircularProgressIndicator();
                // cria uma lista com os documentos da viagem
                List<DocumentSnapshot> viagens = querySnapshot.documents.toList();

                return Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                          itemCount: viagens.length,
                          itemBuilder: (context, index){

                            DocumentSnapshot item = viagens[index];
                            String titulo = item["titulo"];
                            String idViagem = item.documentID;

                            return GestureDetector(
                              onTap: (){
                                _abrirMapa( idViagem );
                              },
                              child: Card(
                                child: ListTile(
                                  title: Text( titulo ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: (){
                                          _excluirViagem( idViagem );
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Icon(
                                            Icons.remove_circle,
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );

                          }
                      ),
                    )
                  ],
                );

                break;
            }
          }
      ),
    );
  }
}
