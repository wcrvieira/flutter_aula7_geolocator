import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? temperature;
  String? humidity;
  String? lat;
  String? long;
  bool isLoading = false;

  Future<void> getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      final response = await http.get(Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current=temperature_2m&hourly=temperature_2m&current=relative_humidity_2m&forecast_days=1'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          temperature = '${data['current']['temperature_2m']} °C';
          humidity = '${data['current']['relative_humidity_2m']} %';
          lat = '${data['latitude']}º';
          long = '${data['longitude']}º';
        });
      } else {
        // Handle error
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      // Handle error
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('Clima'),
        ),
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Latitude: $lat\n'
                      'Longitude: $long \n'
                      'Temperatura: $temperature \n'
                      'Umidade: $humidity',
                      style: const TextStyle(
                        fontFamily: 'Tahoma',
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: getCurrentLocation,
          child: const Icon(Icons.thermostat),
        ),
      ),
    );
  }
}
