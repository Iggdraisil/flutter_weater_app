import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'delegate.dart';
import 'entity/weatherEntity.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather app',
      theme: ThemeData.light(),
      home: MyHomePage(title: 'Cities Weather'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List weatherTargets = List<WeatherEntity>();
  Map<String, dynamic> user;

  _update() {
    showSearch(context: context, delegate: CustomSearchDelegate())
        .then((value) {
      var city = value['city'];
      get(
          Uri.https("api.met.no", "/weatherapi/locationforecast/2.0/compact.json",
              {"lat": '${value['latitude']}', "lon": '${value['longitude']}'}),
          headers: {
            'Content-type': 'application/json'
          }).then((value) => {
            setState(() {
              var json = jsonDecode(value.body)['properties']['timeseries'];
              weatherTargets.add(WeatherEntity(
                  city: city,
                  todayTemperature: json[0]['data']['instant']['details']['air_temperature'],
                  tomorrowTemperature: json[24]['data']['instant']['details']['air_temperature'],
                  dayAfterTomorrowTemperature: json[48]['data']['instant']['details']['air_temperature']
              ));
            })
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(
      fontSize: 20,
      fontStyle: FontStyle.italic,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: new ListView.builder(
                  itemCount: weatherTargets.length,
                  itemBuilder: (BuildContext context, int index) {
                    WeatherEntity weatherInfo = weatherTargets[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(weatherInfo.city, style: style),
                        Text("${weatherInfo.todayTemperature}", style: style),
                        Text("${weatherInfo.tomorrowTemperature}", style: style),
                        Text("${weatherInfo.dayAfterTomorrowTemperature}", style: style),
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _update,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
