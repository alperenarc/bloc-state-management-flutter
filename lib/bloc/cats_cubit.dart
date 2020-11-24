import 'package:bloc_state_management/bloc/cats_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cats_state.dart';

class CatsCubit extends Cubit<CatsState> {
  final CatsRepository _catsRepository;

  CatsCubit(this._catsRepository) : super(CatsInitial());

  Future<void> getCats() async {
    try {
      emit(CatsLoading());
      await Future.delayed(Duration(milliseconds: 500));
      final response = await _catsRepository.getCats();
      emit(CatsCompleted(response));
    } on NetworkError catch (e) {
      emit(CatsError(e.statusCode));
    }
  }
}
