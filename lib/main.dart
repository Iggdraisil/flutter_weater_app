import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weater_app/widgets/temperature_unit.dart';
import 'package:http/http.dart';

import 'widgets/delegate.dart';
import 'entity/weatherEntity.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather app',
      theme: ThemeData.dark(),
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

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
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
                        Container(
                            width: 125,
                            child: Text(
                                weatherInfo.city,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.amber
                              ),
                            ),
                        ),
                        WeatherInfoWidget(temperature: weatherInfo.todayTemperature),
                        WeatherInfoWidget(temperature: weatherInfo.tomorrowTemperature),
                        WeatherInfoWidget(temperature: weatherInfo.dayAfterTomorrowTemperature),
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _update,
        tooltip: 'New city',
        child: Icon(Icons.add),
      ),
    );
  }
}
