import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String apiKey = '47c82a7551033730e6ccfa8099fab7b5';
  String city = 'Jakarta';
  List<String> cities = ['Jakarta', 'Surabaya', 'Bandung', 'Yogyakarta', 'Medan'];
  List<dynamic> weatherData = [];
  Map<String, dynamic>? currentWeather;
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
    fetchCurrentWeather();
  }

  Future<void> fetchWeatherData() async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherData = data['list'];
          weatherData.sort((a, b) =>
              a['main']['temp'].compareTo(b['main']['temp'])); // Urutkan suhu
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  Future<void> fetchCurrentWeather() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          currentWeather = data;
        });
      } else {
        throw Exception('Failed to fetch current weather');
      }
    } catch (e) {
      print(e);
    }
  }

  String getWeatherIcon(String iconCode) {
    return 'http://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  void searchCity(String cityName) {
    setState(() {
      city = cityName;
      isLoading = true;
    });
    fetchWeatherData();
    fetchCurrentWeather();
    searchController.clear(); // Clear search input
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App - $city'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search City',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search),
                              onPressed: () {
                                if (searchController.text.isNotEmpty) {
                                  searchCity(searchController.text);
                                }
                              },
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              searchCity(value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (currentWeather != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Image.network(
                              getWeatherIcon(currentWeather!['weather'][0]['icon']),
                              width: 50,
                              height: 50,
                            ),
                            title: Text(
                              '${currentWeather!['main']['temp']} °C',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${currentWeather!['weather'][0]['description']}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Feels Like: ${currentWeather!['main']['feels_like']} °C\n'
                              'Humidity: ${currentWeather!['main']['humidity']}%\n'
                              'Wind Speed: ${currentWeather!['wind']['speed']} m/s',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: weatherData.length,
                    itemBuilder: (context, index) {
                      final item = weatherData[index];
                      final temp = item['main']['temp'];
                      final description = item['weather'][0]['description'];
                      final dateTime = item['dt_txt'];
                      final iconCode = item['weather'][0]['icon'];

                      return Card(
                        child: ListTile(
                          leading: Image.network(
                            getWeatherIcon(iconCode),
                            width: 50,
                            height: 50,
                          ),
                          title: Text('$temp °C - $description'),
                          subtitle: Text(dateTime),
                          trailing: Icon(Icons.arrow_forward),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WeatherDetailScreen(item: item),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class WeatherDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  WeatherDetailScreen({required this.item});

  String getWeatherIcon(String iconCode) {
    return 'http://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  @override
  Widget build(BuildContext context) {
    final temp = item['main']['temp'];
    final feelsLike = item['main']['feels_like'];
    final description = item['weather'][0]['description'];
    final iconCode = item['weather'][0]['icon'];
    final dateTime = item['dt_txt'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                getWeatherIcon(iconCode),
                width: 100,
                height: 100,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Temperature: $temp °C',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              'Feels Like: $feelsLike °C',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Description: $description',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Date & Time: $dateTime',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}