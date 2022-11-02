import 'package:geocoding/geocoding.dart';

Future getPlace(lat, lng) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

  print(placemarks[0]);
  // this is all you need
  Placemark placeMark = placemarks[0];

  String name = placeMark.name ?? '';
  String subLocality = placeMark.subLocality ?? '';
  String locality = placeMark.locality ?? '';
  String administrativeArea = placeMark.administrativeArea ?? '';
  String postalCode = placeMark.postalCode ?? '';
  String country = placeMark.country ?? '';
  String address =
      "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";

  // print(address);
  return address;
}
