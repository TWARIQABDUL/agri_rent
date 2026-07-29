import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/equipment_categories.dart';
import '../../domain/entities/equipment.dart';
import '../models/equipment_model.dart';

abstract class EquipmentRemoteDataSource {
  Future<List<EquipmentModel>> getEquipment({String? category});
}

@LazySingleton(as: EquipmentRemoteDataSource)
class EquipmentRemoteDataSourceImpl implements EquipmentRemoteDataSource {
  final FirebaseFirestore firestore;

  EquipmentRemoteDataSourceImpl(this.firestore);

  /// Browse only ever shows listings an owner has left on the market. Both
  /// filters are equality checks, which Firestore serves from the single-field
  /// indexes it maintains automatically.
  @override
  Future<List<EquipmentModel>> getEquipment({String? category}) async {
    Query query = firestore
        .collection('equipment')
        .where('status', isEqualTo: EquipmentStatus.available);

    if (category != null && category != EquipmentCategory.anyValue) {
      query = query.where('category', isEqualTo: category);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => EquipmentModel.fromFirestore(doc))
        .toList();
  }
}
