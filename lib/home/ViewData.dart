import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataViewPage extends StatelessWidget {
  const DataViewPage({super.key});

  Future<void> _deleteAllData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد من حذف جميع البيانات المحفوظة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      try {
        final firestore = FirebaseFirestore.instance;
        final snapshot = await firestore.collection('LiveData').get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف جميع البيانات بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في حذف البيانات: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final Set<double> seenTemperatures =
        <double>{}; // To track unique temperatures

    return Scaffold(
      appBar: AppBar(
        title: const Text('البيانات المحفوظة'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'حذف جميع البيانات',
            onPressed: () => _deleteAllData(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('LiveData')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('لا توجد بيانات متاحة',
                  textDirection: TextDirection.rtl),
            );
          }

          final dataDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: dataDocs.length,
            itemBuilder: (context, index) {
              final data = dataDocs[index].data() as Map<String, dynamic>;

              final time = data['time'] ?? 'غير معروف';
              final temperature = data['temperature'];
              final humidity = data['humidity'];
              final soilMoisture = data['soil_moisture'];
              final pumpStatus =
                  data['pump_status'] == true ? 'تشغيل' : 'إيقاف';

              if ((temperature != null && !seenTemperatures.add(temperature)) ||
                  ((temperature == null || temperature == 0) &&
                      (humidity == null || humidity == 0) &&
                      (soilMoisture == null || soilMoisture == 0))) {
                return const SizedBox.shrink();
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '📅 الوقت: $time',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.teal,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const Divider(height: 20, color: Colors.grey),
                      if (temperature != null && temperature > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.thermostat, color: Colors.orange),
                            Expanded(
                              child: Text(
                                'درجة الحرارة: ${temperature.toStringAsFixed(1)} °م',
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      if (humidity != null && humidity > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.water_drop, color: Colors.blue),
                            Expanded(
                              child: Text(
                                'الرطوبة: ${humidity.toStringAsFixed(1)} %',
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      if (soilMoisture != null && soilMoisture > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.grass, color: Colors.green),
                            Expanded(
                              child: Text(
                                'رطوبة التربة: $soilMoisture',
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.power_settings_new,
                              color: Colors.red),
                          Expanded(
                            child: Text(
                              'حالة المضخة: $pumpStatus',
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
