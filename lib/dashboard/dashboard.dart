import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:virtoustack_demo/authentication/authPage.dart';
import 'package:http/http.dart' as http;
import 'package:virtoustack_demo/dashboard/networkImage.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> listOfpaths = List<dynamic>();
  List listofSubPaths = List();
  final CarouselController _imageCarouselController = CarouselController();
  final ItemScrollController _textCarouselController = ItemScrollController();
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: Center(child: Text("Dog's Path")),
        backgroundColor: Colors.blueGrey[900],
        actions: [
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                final facebooklogin = FacebookLogin();
                facebooklogin.logOut();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('_isLoggedIn', false);
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => AuthPage()));
              }),
          IconButton(icon: Icon(Icons.check), onPressed: getPathData),
        ],
      ),
      body: ListView.builder(
        itemCount: listOfpaths.length,
        itemBuilder: (context, index) {
          return Container(
            height: screenWidth,
            child: Card(
              color: Colors.grey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: screenWidth,
                      color: Colors.grey[800],
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 4, 0, 4),
                        child: Text(
                          listOfpaths[index]['title'],
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                      )),
                  Container(
                      width: screenWidth,
                      color: Colors.grey[800],
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 4, 0, 4),
                        child: Text(
                          '${listOfpaths[index]['sub_paths'].length} Sub Paths',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )),
                  Container(
                    color: Colors.grey,
                    height: screenWidth * 0.65,
                    width: screenWidth,
                    child: CarouselSlider.builder(
                      itemCount: listOfpaths[index]['sub_paths'].length - 1,
                      itemBuilder: (context, pos) {
                        return Card(
                          color: Colors.grey,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              NetworkImageModified(
                                listOfpaths[index]['sub_paths'][pos]['image'],
                              ),
                              Container(
                                height: screenWidth * 0.1,
                                width: screenWidth,
                                color: Colors.black,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${listOfpaths[index]['sub_paths'][pos]['title']}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      options: CarouselOptions(
                          viewportFraction: 1, enableInfiniteScroll: false),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getShowAlert();
    getPathData();
  }

  Future<void> getShowAlert() async {
    bool _isLoggedIn;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String profileName = prefs.getString("profileName");
    String profileImage = prefs.getString("profileImage");
    print(profileName);
    _isLoggedIn = prefs.getBool('_isLoggedIn');
    if (_isLoggedIn ?? false) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              elevation: 40,
              backgroundColor: Colors.teal[200],
              content: Container(
                width: MediaQuery.of(context).size.width * 0.25,
                height: MediaQuery.of(context).size.width * 0.25,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(
                          profileImage,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Signed in as $profileName',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ],
            );
          });
    }
  }

  Future<void> getPathData() async {
    listOfpaths.clear();
    listofSubPaths.clear();
    var uri =
        Uri.parse("https://5d55541936ad770014ccdf2d.mockapi.io/api/v1/paths");
    var response = await http.get(uri);
    final body = json.decode(response.body);
    body.removeLast();

    listOfpaths = body;
    setState(() {
      for (var i = 0; i < listOfpaths.length; i++) {
        listofSubPaths.add(listofSubPaths = body[i]['sub_paths']);
      }
    });
    print(listofSubPaths[0]['image']);
  }
}
