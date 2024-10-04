import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_database/firebase_database.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  bool waterPumpStatus = false;
  double temperature = 0.0;
  double humidity = 0.0;

  @override
  void initState() {
    super.initState();
    _getDataFromFirebase();
  }

  void _getDataFromFirebase() {
    _dbRef.child("plant").onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          waterPumpStatus = data['pump_status'] ?? false;
          temperature = (data['temperature'] ?? 0.0).toDouble();
          humidity = (data['humidity'] ?? 0.0).toDouble();
        });
      }
    });
  }

  void _toggleWaterPump() {
    _dbRef.child("plant").update({'pump_status': !waterPumpStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Water Pump Status
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'مضخة المياه: ${waterPumpStatus ? "شغالة" : "طافيه"}',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Temperature Display with Circle
            CustomIndicator(
              value: temperature,
              maxValue: 100,
              label: 'درجة الحرارة (°م)',
              color: Colors.orange,
            ),
            const SizedBox(height: 30),

            // Humidity Display with Circle
            CustomIndicator(
              value: humidity,
              maxValue: 100,
              label: 'الرطوبة (%)',
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Custom Indicator Widget
class CustomIndicator extends StatelessWidget {
  final double value;
  final double maxValue;
  final String label;
  final Color color;

  const CustomIndicator({
    Key? key,
    required this.value,
    required this.maxValue,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        SizedBox(
          width: 150, // Increased width for a larger circle
          height: 150, // Increased height for a larger circle
          child: CircularProgressIndicator(
            value: value / maxValue,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 12, // You can adjust the stroke width if needed
          ),
        ),
        const SizedBox(height: 10),
        Text('${value.toInt()} / ${maxValue.toInt()}',
            style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
