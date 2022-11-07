import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:userlocation/shared_preferences_storage.dart';
import 'table_result.dart';
import 'user_data.dart';
import 'custom_search.dart';
import 'main.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({
    Key? key,
    // required this.title,
    // required this.email,
    this.user,
  }) : super(key: key);

  // final String title, email;
  final String? user;

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  List<UserData> userData = [];
  List<UserData> usersFiltered = [];

  _getPlace(lat, lng) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

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

  late SharedPreferences sharedPreferences;
  Timer? timer;
  @override
  void initState() {
    readData().then((value) => usersFiltered = userData);
    // usersFiltered = userData;
    timer = Timer.periodic(const Duration(seconds: 60),
        (Timer t) => readData().then((value) => usersFiltered = userData));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> readData() async {
    userData.clear();
    UserData user;
    databaseReference.once().then((DatabaseEvent snapshot) async {
      for (var element in snapshot.snapshot.children) {
        for (var val in element.children) {
          var name = val.children.elementAt(0).value.toString().split("|")[0];
          var type = val.children.elementAt(0).value.toString().split("|")[1];
          var email = val.children.elementAt(1).value.toString();
          var lat = val.children.elementAt(2).value.toString();
          var lng = val.children.elementAt(3).value.toString();
          var address = await _getPlace(
              double.parse(lat.toString()), double.parse(lng.toString()));

          user = UserData(
              name: name,
              email: email,
              type: type,
              lat: lat,
              long: lng,
              address: address);

          setState(() {
            userData.add(user);
          });
        }
      }
    });
    // print(userData);
  }

  // void createData(name, email, lat, long) async {
  //   await databaseReference
  //       .child("Users/${widget.user!.uid}")
  //       .set({"name": name, "email": email, "lat": lat, "long": long});
  //   print("written");
  //   // await ref.set({
  //   //   "name": "John",
  //   //   "lat": 18,
  //   //   "long": 18,
  //   // });
  // }

  TextEditingController controller = TextEditingController();
  String _searchResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.search),
                title: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                        hintText: 'Search', border: InputBorder.none),
                    onChanged: (value) {
                      setState(() {
                        _searchResult = value;
                        usersFiltered = userData
                            .where((user) =>
                                user.name.contains(_searchResult) ||
                                user.email.contains(_searchResult) ||
                                user.address.contains(_searchResult))
                            .toList();
                      });
                    }),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      controller.clear();
                      _searchResult = '';
                      usersFiltered = userData;
                    });
                  },
                ),
              ),
            ),
            usersFiltered.isNotEmpty
                ? TableComponent.buildTableComponen(
                    context: context, userData: usersFiltered)
                : const Expanded(
                    child: Center(
                    child: CircularProgressIndicator(),
                  )),
          ],
        ),
      ),
      // Container(
      //   width: MediaQuery.of(context).size.width,
      //   child: DataTable(
      //     headingRowColor: MaterialStateProperty.all(Colors.green),
      //     columns: const [
      //       //       DataColumn(
      //       //   label: Expanded(
      //       //     child: Text(
      //       //       'Type',
      //       //       style: TextStyle(fontStyle: FontStyle.italic),
      //       //     ),
      //       //   ),
      //       // ),
      //       DataColumn(
      //         label: Expanded(
      //           child: Text(
      //             'Name',
      //             style: TextStyle(
      //                 fontStyle: FontStyle.italic, color: Colors.white),
      //           ),
      //         ),
      //       ),
      //       DataColumn(
      //         label: Expanded(
      //           child: Text(
      //             'Address',
      //             style: TextStyle(
      //                 fontStyle: FontStyle.italic, color: Colors.white),
      //           ),
      //         ),
      //       ),
      //       DataColumn(
      //         label: Expanded(
      //           child: Text(
      //             'Email',
      //             style: TextStyle(
      //                 fontStyle: FontStyle.italic, color: Colors.white),
      //           ),
      //         ),
      //       ),
      //     ],
      //     rows: userData.map((item) {
      //       return DataRow(
      //           color: MaterialStateProperty.all(Colors.lightBlueAccent),
      //           cells: [
      //             DataCell(Container(
      //                 // width: (MediaQuery.of(context).size.width / 10) * 3,
      //                 child: Text(item.name,
      //                     style: const TextStyle(
      //                         color: Colors.red, fontSize: 12)))),

      //             // DataCell(Icon(Icons.power)),
      //             DataCell(Container(
      //               // width: (MediaQuery.of(context).size.width / 10) * 3,
      //               child: Text(item.address,
      //                   style:
      //                       const TextStyle(color: Colors.red, fontSize: 12)),
      //             )),
      //             DataCell(Container(
      //               width: (MediaQuery.of(context).size.width / 10) * 2,
      //               child: Text(item.email,
      //                   style:
      //                       const TextStyle(color: Colors.red, fontSize: 12)),
      //             ))
      //           ]);
      //     }).toList(),
      //   ),
      // ),

      //  ListView.builder(
      //     itemCount: userData.length,
      //     scrollDirection: Axis.vertical,
      //     itemBuilder: (BuildContext context, int index) {
      //       return ListTile(
      //         leading: Text(userData[index].type),
      //         trailing: Text(userData[index].name),
      //         title: Text(userData[index].email),
      //         subtitle: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             // Text(
      //             //   "lat = ${userData[index].lat} ",
      //             //   style: TextStyle(color: Colors.green, fontSize: 15),
      //             // ),
      //             // Text(
      //             //   "lng = ${userData[index].long} ",
      //             //   style: TextStyle(color: Colors.green, fontSize: 15),
      //             // ),
      //             Text(
      //               "address = ${userData[index].address} ",
      //               style: TextStyle(color: Colors.green, fontSize: 15),
      //             ),
      //           ],
      //         ),
      //       );
      //     }),

      // Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: <Widget>[
      //     Text("Name : "),
      //     Text(widget.user!.displayName!),
      //   ],
      // ),
      // Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: <Widget>[
      //     Text("Email : "),
      //     Text(widget.user!.email!),
      //   ],
      // ),
      // Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: <Widget>[
      //     Text("Location : "),
      //     Text("${lat} ${lng}"),
      //   ],
      // ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          EasyLoading.show(status: 'loading...');
          // await FirebaseAuth.instance.signOut();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Sign out Successfully"),
            backgroundColor: Colors.blueAccent,
          ));
          sharedPreferences = await SharedPreferences.getInstance();
          SharePreferencesStore.setPreference(sharedPreferences, false);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false);
          EasyLoading.dismiss();
        },
        tooltip: 'Sign out',
        child: const Icon(Icons.logout),
      ),
    );
  }
}
