import 'package:flutter/material.dart';

import 'Mapa.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> lugares = ["Fortaleza", "Rio de Janeiro", "São Paulo"];

  _abrirMapa() {}

  _adicionarLocal() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Mapa()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Minhas viagens"),
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Color(0xff0066cc),
            onPressed: () {
              _adicionarLocal();
            }),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: lugares.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Card(
                      child: ListTile(
                        title: Text(lugares[index]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                print("Teste");
                              },
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.remove_circle,
                                    color: Colors.red),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ));
  }
}
