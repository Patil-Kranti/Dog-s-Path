import 'dart:async';

import 'package:flutter/material.dart';

class NetworkImageModified extends StatelessWidget {
  final String url;
  NetworkImageModified(this.url);
  Future<bool> cacheImage(String url, BuildContext context) async {
    bool hasNoError = true;
    var output = Completer<bool>();
    precacheImage(
      NetworkImage(url),
      context,
      onError: (e, stackTrace) => hasNoError = false,
    ).then((_) => output.complete(hasNoError));
    return output.future;
  }

  @override
  Widget build(context) {
    return FutureBuilder(
      future: cacheImage(url, context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none ||
            snapshot.hasError) {
          return Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Center(
                child: Image.asset(
              "assets/images/noImage.jpg",
              fit: BoxFit.fitWidth,
            )),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.data == false) {
          return Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Center(
                child: Image.asset(
              "assets/images/noImage.jpg",
            )),
          );
        }
        return Container(
          child: Image.network(
            url,
            fit: BoxFit.fill,
          ),
        );
      },
    );
  }
}
