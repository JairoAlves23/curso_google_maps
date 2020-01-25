import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class Mapa extends StatefulWidget {

  // Atributo para envio do ID da viagem
  String idViagem;
 
  // Construto de rececimento do ID da viagem
  Mapa({ this.idViagem });

  @override
  _MapaState createState() => _MapaState();
}

class _MapaState extends State<Mapa> {

  /* 
  
  antes de iniciar configurar...

  dependencies:
  geolocator: ^5.2.0

   Permissão do usuario para pegar sua localização atual 
   Permissions
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   */

  /* Instancia do firebase */

  // 5º Passo: criação da fase de envio para firebase.
  Firestore _db = Firestore.instance;

  // 1º Passo: Complete para GoogleMapController
  Completer<GoogleMapController> _controller = Completer();
  
  //3º Passo: Lista para os marcadores - markers: _marcadores,
  Set<Marker> _marcadores = {};

  CameraPosition _posicaoCamera = CameraPosition(
      target: LatLng(-3.844066, -38.493272),
      zoom: 18
  );

  // 2º Passo: Metodo necessario para criação do mapa - onMapCreated: _onMapCreated,
  _onMapCreated( GoogleMapController controller ){
    _controller.complete( controller );
  }

   //3º Passo: cria os marcadores no mapa ao chamar onLongPress no mapa onLongPress: _adicionarMarcador,
  _adicionarMarcador( LatLng latLng ) async {

    List<Placemark> listaEnderecos = await Geolocator()
        .placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    if( listaEnderecos != null && listaEnderecos.length > 0 ){

      Placemark endereco = listaEnderecos[0];
      String rua = endereco.thoroughfare;

      //41.890250, 12.492242
      Marker marcador = Marker(
          markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
          position: latLng,
          infoWindow: InfoWindow(
              title: rua
          )
      );

      setState(() {
        _marcadores.add( marcador );

        //Salva no firebase
        // 5º Passo: criação da fase de envio para firebase.
        // Cria um map do marcador da viagem para firebase
        Map<String, dynamic> viagem = Map();
        viagem["titulo"] = rua;
        viagem["latitude"] = latLng.latitude;
        viagem["longitude"] = latLng.longitude;

        _db.collection("viagens")
        .add( viagem );

      });

    }

  }

  //4º Passo: - initialCameraPosition: _posicaoCamera ou criar initialCameraPosition: CameraPosition(target: LatLng(-3.844066, -38.493272), zoom: 16);
  // Posição da camera inicial para metodo _adicionarListenerLocalizacao();
  _movimentarCamera() async {

    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        _posicaoCamera
      )
    );

  }

  _adicionarListenerLocalizacao(){

    //-23.579934, -46.660715

    var geolocator = Geolocator();
    var locationOptions = LocationOptions(accuracy: LocationAccuracy.high);
    geolocator.getPositionStream( locationOptions ).listen((Position position){

      setState(() {
        if(!mounted) { return; }
        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
          zoom: 18
        );
        _movimentarCamera();
      });

    });

  }

  _recuperaViagemParaID(String idViagem) async {

    if( idViagem != null ){

      //exibir marcador para id viagem
      DocumentSnapshot documentSnapshot = await _db
          .collection("viagens")
          .document( idViagem )
          .get();

      var dados = documentSnapshot.data;

      String titulo = dados["titulo"];
      LatLng latLng = LatLng(
          dados["latitude"],
          dados["longitude"]
      );

     if(!mounted) { return; }
      setState(() {

        Marker marcador = Marker(
            markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
            position: latLng,
            infoWindow: InfoWindow(
                title: titulo
            )
        );

        _marcadores.add( marcador );
        _posicaoCamera = CameraPosition(
            target: latLng,
          zoom: 18
        );
        _movimentarCamera();

      });

    }else{
      _adicionarListenerLocalizacao();
    }

  }

@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _adicionarListenerLocalizacao();
     _movimentarCamera();
  }

  
  @override
  void initState() {
    super.initState();

    //Recupera viagem pelo ID
    _recuperaViagemParaID( widget.idViagem );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapa"),),
      body: Container(
        child: GoogleMap(
            markers: _marcadores,
            mapType: MapType.normal,
            initialCameraPosition: _posicaoCamera,
            onMapCreated: _onMapCreated,
          onLongPress: _adicionarMarcador,
        ),
      ),
    );
  }
}
