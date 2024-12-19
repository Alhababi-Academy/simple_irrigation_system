import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool waterPumpStatus = false;
  bool manualControl = false;
  bool autoControl = true; // Default to automatic control
  double temperature = 0.0;
  double humidity = 0.0;
  int soilMoisture = 0;
  bool isPumpButtonDisabled = false; // Track if button is temporarily disabled
  Timer? _hourlyTimer;

  @override
  void initState() {
    super.initState();
    _getDataFromRealtimeDatabase();
    _startHourlyDataSaving();
  }

  @override
  void dispose() {
    _hourlyTimer?.cancel();
    super.dispose();
  }

  void _getDataFromRealtimeDatabase() {
    _database.child('plant').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      setState(() {
        waterPumpStatus = data?['pump_status'] ?? false;
        manualControl = data?['manual_control'] ?? false;
        autoControl = data?['auto_control'] ?? true;
        temperature = (data?['temperature'] ?? 0.0).toDouble();
        humidity = (data?['humidity'] ?? 0.0).toDouble();
        soilMoisture = data?['soil_moisture'] ?? 0;
      });
    });
  }

  void _startHourlyDataSaving() {
    _hourlyTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      final formattedTime =
          "${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}";
      final data = {
        'time': formattedTime,
        'temperature': temperature,
        'humidity': humidity,
        'soil_moisture': soilMoisture,
        'pump_status': waterPumpStatus,
      };

      // Save data to Firestore
      _firestore.collection("LiveData").add(data);
    });
  }

  void _toggleManualControl(bool value) {
    setState(() {
      manualControl = value;
      autoControl = !value; // Ensure only one control is enabled
      waterPumpStatus = false; // Immediately turn off the pump in manual mode
    });

    _database.child('plant').update({
      'manual_control': manualControl,
      'auto_control': autoControl,
      'pump_status': waterPumpStatus,
    });
  }

  void _toggleAutoControl(bool value) {
    setState(() {
      autoControl = value;
      manualControl = !value; // Ensure only one control is enabled
      waterPumpStatus = false; // Turn off pump in auto mode
    });

    _database.child('plant').update({
      'auto_control': autoControl,
      'manual_control': manualControl,
      'pump_status': false, // Reset pump status in auto mode
    });
  }

  Future<void> _toggleWaterPump() async {
    if (manualControl && !isPumpButtonDisabled) {
      setState(() {
        isPumpButtonDisabled = true; // Disable button temporarily
        waterPumpStatus = !waterPumpStatus;
      });

      await _database.child('plant').update({
        'pump_status': waterPumpStatus,
      });

      // Wait for the database update to process
      await Future.delayed(const Duration(seconds: 2));

      // Re-enable the button
      setState(() {
        isPumpButtonDisabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'مضخة المياه: ${waterPumpStatus ? "تعمل" : "لا تعمل"}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'التحكم اليدوي: ${manualControl ? "مفعل" : "غير مفعل"}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        CupertinoSwitch(
                          value: manualControl,
                          onChanged: (value) => _toggleManualControl(value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'التحكم التلقائي: ${autoControl ? "مفعل" : "غير مفعل"}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        CupertinoSwitch(
                          value: autoControl,
                          onChanged: (value) => _toggleAutoControl(value),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: manualControl && !isPumpButtonDisabled
                    ? _toggleWaterPump
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: manualControl ? Colors.blue : Colors.grey,
                  elevation: 0, // Remove highlight effect
                ),
                child: Text(
                  waterPumpStatus ? 'إيقاف المضخة' : 'تشغيل المضخة',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              CustomIndicator(
                value: temperature,
                maxValue: 100,
                label: 'درجة الحرارة (°م)',
                color: Colors.orange,
              ),
              const SizedBox(height: 30),
              CustomIndicator(
                value: humidity,
                maxValue: 100,
                label: 'الرطوبة (%)',
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 30),
              CustomIndicator(
                value: soilMoisture.toDouble(),
                maxValue: 1023,
                label: 'رطوبة التربة',
                color: Colors.green,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomIndicator extends StatelessWidget {
  final double value;
  final double maxValue;
  final String label;
  final Color color;

  const CustomIndicator({
    super.key,
    required this.value,
    required this.maxValue,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        SizedBox(
          width: 150,
          height: 150,
          child: CircularProgressIndicator(
            value: value / maxValue,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 12,
          ),
        ),
        const SizedBox(height: 10),
        Text('${value.toInt()} / ${maxValue.toInt()}',
            style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
