import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class CustomSearchDelegate extends SearchDelegate {
  Map _result;
  DateTime _lastError = DateTime.now();

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) => RaisedButton(
        onPressed: () => this.close(context, _result),
        child: Text("result: city"),
      );

  @override
  Widget buildSuggestions(BuildContext context) {
    return Column(
      children: <Widget>[
        FutureBuilder(
          future: fetchCities(query),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (!snapshot.hasData || snapshot.data.length == 0) {
              return Center();
            } else {
              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    var result = snapshot.data[index];
                    return ListTile(
                      onTap: () {
                        _result = result;
                        query = _result['city'];
                        this.close(context, _result);
                      },
                      title: Text(result['city']),
                    );
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Future<List<dynamic>> fetchCities(String text) async {
    var result = await get(
        Uri.https(
          "wft-geo-db.p.rapidapi.com",
          "/v1/geo/cities",
          {"namePrefix": text, "countryIds": '1'}
        ),
      headers: {
        'x-rapidapi-host': 'wft-geo-db.p.rapidapi.com',
        'x-rapidapi-key': '65c9f8b7b0msh67214abd7cc67c0p1f5db9jsnd4dfaf1a6de8'
      }
    );
    List<dynamic> finresult = jsonDecode(result.body)['data'];
    return finresult;
  }
}
