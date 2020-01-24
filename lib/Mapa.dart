import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class Mapa extends StatefulWidget {
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

  // 2º Passo: Metodo necessario para criação do mapa - onMapCreated: _onMapCreated,
  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  //3º Passo: Lista para os marcadores - markers: _marcadores,
  Set<Marker> _marcadores = {};

  //3º Passo: cria os marcadores no mapa ao chamar onLongPress no mapa onLongPress: _adicionarMarcador,
  _adicionarMarcador(LatLng latLng) async {
    List<Placemark> listaEnderecos = await Geolocator()
        .placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    if (listaEnderecos != null && listaEnderecos.length > 0) {
      Placemark endereco = listaEnderecos[0];
      String rua = endereco.thoroughfare;

      Marker marcador = Marker(
          markerId: MarkerId("marcador-${latLng.latitude},${latLng.longitude}"),
          position: latLng,
          infoWindow: InfoWindow(title: rua));

      setState(() {
        _marcadores.add(marcador);

        // 5º Passo: criação da fase de envio para firebase.
        // Cria um map do marcador da viagem para firebase
        Map<String,dynamic> viagem = Map();
        viagem["titulo"] = rua;
        viagem["latitude"] = latLng.latitude;
        viagem["longitude"] = latLng.longitude;
        _db.collection("viagens").add(viagem);

      });
    }
  }

  //4º Passo: - initialCameraPosition: _posicaoCamera ou criar initialCameraPosition: CameraPosition(target: LatLng(-3.844066, -38.493272), zoom: 16);
  // Posição da camera inicial para metodo _adicionarListenerLocalizacao();
  CameraPosition _posicaoCamera =
      CameraPosition(target: LatLng(-3.844066, -38.493272), zoom: 16);

  //4º Passo:
  _movimentaCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(_posicaoCamera));
  }

  //4º Passo:
  _adicionarListenerLocalizacao() {
    //cria o objeto do Geolcator
    var geolocator = Geolocator();
    //cria a precisão da localização feita pelo ponto selecionado
    var locationsOptions = LocationOptions(accuracy: LocationAccuracy.high);
    //cria adicionar a posição para o objeto _posicaoCamera *Position position vem do movimento da camera
    geolocator.getPositionStream(locationsOptions).listen((Position position) {
      setState(() {
        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 16);
        // salva o proximo movimento da camera atraves novo moviemnto salvo no objeto _posicaoCamera
        _movimentaCamera();
      });
    });
  }



  @override
  void initState() {
    super.initState();
    //4º Passo:
    //Inicia o mapa com as configurações selecionadas
    _adicionarListenerLocalizacao();
  }

  @override
  void dispose() {
    super.dispose();
    _movimentaCamera();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Mapa"),
        ),
        body: Container(
          child: GoogleMap(
            markers: _marcadores,
            mapType: MapType.normal,
            initialCameraPosition: _posicaoCamera,
            onMapCreated: _onMapCreated,
            onLongPress: _adicionarMarcador,
          ),
        ));
  }
}
