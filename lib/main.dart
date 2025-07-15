import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:html' as html;


void main() {
  
  runApp(const DHLCloneApp());
  
}

class DHLCloneApp extends StatelessWidget {
  const DHLCloneApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DHL Tracking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      fontFamily: 'Roboto',
    ),
      home: const DHLTrackingScreen(),
    );
  }
}


class DHLTrackingScreen extends StatefulWidget {
  const DHLTrackingScreen({super.key});

  @override
  State<DHLTrackingScreen> createState() => _DHLTrackingScreenState();
}

class _DHLTrackingScreenState extends State<DHLTrackingScreen> {
  String _formattedDeliveryTime() {
    final now = DateTime.now();
    final deliveryTime = now.subtract(const Duration(minutes: 131));

    final hours = deliveryTime.hour.toString().padLeft(2, '0');
    final minutes = deliveryTime.minute.toString().padLeft(2, '0');

    return 'Vandaag om $hours:$minutes uur';
  }
  String _street = 'Locatie ophalen...';
  String _city = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (html.window.navigator.geolocation != null) {
      try {
        final position = await html.window.navigator.geolocation.getCurrentPosition();
        final latitude = position.coords?.latitude;
        final longitude = position.coords?.longitude;

        if (latitude == null || longitude == null) {
          setState(() {
            _street = "Kan locatie niet bepalen";
            _city = "";
          });
          return;
        }

        final url =
            'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json&addressdetails=1';

        final response = await html.window.fetch(url, {
          'method': 'GET',
          'headers': {'User-Agent': 'DHLCloneApp/1.0'}
        });

        final responseText = await response.text();
        final data = jsonDecode(responseText);

        setState(() {
          _street = "${data['address']['road'] ?? 'Straat'} ${data['address']['house_number'] ?? ''}";
          _city = data['address']['city'] ??
                  data['address']['town'] ??
                  data['address']['village'] ??
                  '';
        });
      } catch (e) {
        setState(() {
          _street = "Locatie ophalen mislukt";
          _city = "";
        });
      }
    } else {
      setState(() {
        _street = "Geolocatie niet ondersteund in deze browser";
        _city = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: ListView(
          children: [
            // 🔽 Huidige locatie tonen
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.arrow_back),
                  Text(
                    'ZALANDO',
                    
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                  Icon(Icons.share),
                ],
              ),
            ),

            const Divider(
              thickness: 1,
              height: 1,
              color: Color(0xFFE0E0E0), // Lichtgrijs, pas aan indien gewenst
            ),

            // Gele speech bubble
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: YellowBubble(text: 'Bezorgd bij de buren'),
            ),
            const SizedBox(height: 24),

            // Tijdlijn
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TimelineWidget(),
            ),
            const SizedBox(height: 32),

            // Bezorgtijd
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bezorgd op', style: TextStyle(color: Colors.black54, fontSize: 13)),
                  SizedBox(height: 4),
                  Text(
                    _formattedDeliveryTime(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Vraag over pakket card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13.0),
              child: Card(
                color: const Color(0xFFFFFFFF),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                child: ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Heb je een vraag over je pakket?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('Tracy helpt je verder', style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Divider(
              thickness: 1,
              height: 1,
              color: Color(0xFFE0E0E0), // Lichtgrijs, pas aan indien gewenst
            ),

            AddressBlock(
              title: 'Bij de buren',
              name: '$_street\n$_city',
              //name: 'Amaril 5\n2719TR Zoetermeer\nNL',
            ),
                        const Divider(
              thickness: 1,
              height: 1,
              color: Color(0xFFE0E0E0), // Lichtgrijs, pas aan indien gewenst
            ),

            const AddressBlock(
              title: 'Ontvanger',
              name: 'Stefan Janssen',
            ),
            
            const Divider(
              thickness: 1,
              height: 1,
              color: Color(0xFFE0E0E0), // Lichtgrijs, pas aan indien gewenst
            ),

            const AddressBlock(
              title: 'Verzender',
              name: 'Zalando\n7550WB Hengelo\nNederland',
            ),

            const Divider(
              thickness: 1,
              height: 1,
              color: Color(0xFFE0E0E0), // Lichtgrijs, pas aan indien gewenst
            ),

            const AddressBlock(
              title: 'Zendingsnummer',
              name: 'JVGL06091660510722276251',
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13.0),
              child: Card(
                color: const Color(0xFFFFFFFF),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                child: ListTile(
                  title: const Text('Toon details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  //subtitle: const Text('Tracy helpt je verder'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// 🔶 Gele speech bubble
class YellowBubble extends StatelessWidget {
  final String text;
  const YellowBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3C1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 13,
        ),
      ),
    );
  }
}

// 📍 Tijdlijn met bollen + huisje
class TimelineWidget extends StatelessWidget {
  const TimelineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double width = constraints.maxWidth;
      //double spacing = width / 3;

      return Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Gele lijn
          Positioned(
            top: 16,
            left: 12,
            right: 12,
            child: Container(height: 4, color: Colors.amber),
          ),
          // Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/images/house.png',
                width: MediaQuery.of(context).size.width * 0.9,  // Breedte van het scherm pakken
                fit: BoxFit.cover,
              ),
            ],
          )
        ],
      );
    });
  }

  Widget buildDot() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
    );
  }
}

// 🏠 Adresblok
class AddressBlock extends StatelessWidget {
  final String title;
  final String name;
  const AddressBlock({super.key, required this.title, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
