import 'package:flutter_bloc/flutter_bloc.dart';

class FarmerNavigationCubit extends Cubit<int> {
  FarmerNavigationCubit() : super(0);

  void select(int index) {
    if (index < 0 || index > 4 || index == state) return;
    emit(index);
  }
}
