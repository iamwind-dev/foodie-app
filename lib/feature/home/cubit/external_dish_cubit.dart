import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/external_dish.dart';
import '../../../core/repositories/external_repository.dart';

abstract class ExternalDishState {}

class ExternalDishInitial extends ExternalDishState {}

class ExternalDishLoading extends ExternalDishState {}

class ExternalDishLoaded extends ExternalDishState {
  final List<ExternalDish> dishes;
  ExternalDishLoaded(this.dishes);
}

class ExternalDishError extends ExternalDishState {
  final String message;
  ExternalDishError(this.message);
}

class ExternalDishCubit extends Cubit<ExternalDishState> {
  final ExternalRepository _repo;
  ExternalDishCubit({ExternalRepository? repo})
      : _repo = repo ?? ExternalRepository(),
        super(ExternalDishInitial());

  Future<void> load() async {
    emit(ExternalDishLoading());
    try {
      final items = await _repo.getFeaturedDishes();
      emit(ExternalDishLoaded(items));
    } catch (e) {
      emit(ExternalDishError(e.toString()));
    }
  }
}

