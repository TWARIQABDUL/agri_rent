import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/equipment_model.dart';

abstract class EquipmentRemoteDataSource {
  Future<List<EquipmentModel>> getEquipment({String? category});
}

@LazySingleton(as: EquipmentRemoteDataSource)
class EquipmentRemoteDataSourceImpl implements EquipmentRemoteDataSource {
  final FirebaseFirestore firestore;

  EquipmentRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<EquipmentModel>> getEquipment({String? category}) async {
    Query query = firestore.collection('equipment');

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => EquipmentModel.fromFirestore(doc))
        .toList();
  }
}
