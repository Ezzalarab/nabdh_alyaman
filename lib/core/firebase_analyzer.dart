import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseAnalyzer {
  static const List<String> _collections = [
    'donors',
    'centers',
    'notifications',
    'search_logs',
    'updating',
    'users_per_day',
    'global_app_data',
  ];

  /// يقوم بجلب عينة من كل مجموعة وتحليل الحقول الموجودة فيها
  static Future<void> analyzeFirestoreStructure() async {
    if (kDebugMode) {
      print('=========================================');
      print('🚀 بدء تحليل هيكل بيانات Firebase Firestore');
      print('=========================================');
    }

    final firestore = FirebaseFirestore.instance;

    for (String collectionName in _collections) {
      try {
        final querySnapshot = await firestore.collection(collectionName).limit(1).get();

        if (querySnapshot.docs.isEmpty) {
          if (kDebugMode) {
            print('📁 المجموعة: [$collectionName] -> (لا توجد بيانات حالياً)');
          }
          continue;
        }

        final doc = querySnapshot.docs.first;
        final data = doc.data();

        if (kDebugMode) {
          print('📁 المجموعة: [$collectionName]');
          print('   📄 مُعرِّف الوثيقة: ${doc.id}');
          print('   🛠️ الحقول والأنواع:');
          
          data.forEach((key, value) {
            String type = value.runtimeType.toString();
            if (value is Timestamp) {
              type = 'Timestamp (Date)';
            } else if (value is Map) {
              type = 'Map (Nested Object)';
            } else if (value is List) {
              type = 'List (Array)';
            }
            print('     - $key: $type');
          });
          print('-----------------------------------------');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ خطأ أثناء تحليل المجموعة [$collectionName]: $e');
        }
      }
    }

    if (kDebugMode) {
      print('✅ انتهى التحليل.');
      print('=========================================');
    }
  }
}
