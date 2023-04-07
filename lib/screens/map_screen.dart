import 'package:label_marker/label_marker.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../proves/mapTitleProvider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with AutomaticKeepAliveClientMixin<MapScreen> {
  @override
  bool get wantKeepAlive => true;

  Set<Marker> markers = {};
  GoogleMapController? controller;
  Color myColor = const Color(0xFFF8B195);

  @override
  void initState() {
    super.initState();
    initMap();
  }

  void initMap() {
    final List<LatLng> locations = [
      const LatLng(37.500936916629, 126.86674390514),
      const LatLng(37.500923425185846, 126.86637168943172),
    ];
    for (int i = 0; i < locations.length; i++) {
      final title = "Aily_${i + 1}";
      final selectedLocation = locations[i];
      markers
          .addLabelMarker(LabelMarker(
        label: title,
        markerId: MarkerId(title),
        position: selectedLocation,
        backgroundColor: myColor,
        onTap: () {
          _onMarkerTapped(title);
        },
      ))
          .then(
            (value) {
          if (i == locations.length - 1) {
            controller?.animateCamera(
              CameraUpdate.newLatLngBounds(
                LatLngBounds(
                  southwest: locations[1],
                  northeast: locations[0],
                ),
                50.0, // padding
              ),
            );
          }
        },
      );
    }
  }

  void _onMarkerTapped(String title) {
    final TitleProvider titleProvider = Provider.of<TitleProvider>(context, listen: false);
    titleProvider.addTitle(title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text('선택됨 : $title'),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Color backColor = const Color(0xFFF6F1F6);

    return Scaffold(
      backgroundColor: backColor,
      body: MapWidget(context),
    );
  }

  Widget MapWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.500936916629, 126.86674390514),
          zoom: 18,
        ),
        markers: markers,
        onMapCreated: ((mapController) {
          setState(() {
            controller = mapController;
          });
        }),
      ),
    );
  }
}