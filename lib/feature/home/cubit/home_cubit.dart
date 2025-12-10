import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import '../../../core/repositories/external_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ExternalRepository _externalRepository;
  static HomeLoaded? _cached;

  HomeCubit({ExternalRepository? externalRepository})
      : _externalRepository = externalRepository ?? ExternalRepository(),
        super(HomeInitial());

  Future<void> loadHomeData() async {
    if (_cached != null) {
      emit(_cached!);
      return;
    }

    emit(HomeLoading());
    
    try {
      // Fetch featured dishes from external API
      final dishes = await _externalRepository.getFeaturedDishes();
      // Shuffle to show random picks
      final shuffled = List.of(dishes)..shuffle(Random());

      // Map to Recipe model (limit to 8 for display)
      final recipes = shuffled.take(8).map((d) => Recipe(
        id: d.id,
        name: d.name,
        imageUrl: d.image,
      )).toList();
      
      // Keep placeholder for other sections
      final countries = [
        Country(
          id: '1',
          name: 'Việt Nam',
          imageUrl: 'assets/img/home_country_1.png',
        ),
        Country(
          id: '2',
          name: 'Hàn Quốc',
          imageUrl: 'assets/img/home_country_2.png',
        ),
        Country(
          id: '3',
          name: 'Ý',
          imageUrl: 'assets/img/home_country_3.png',
        ),
      ];
      
      final suggestions = (recipes.length > 3
              ? (List.of(recipes)..shuffle(Random()))
              : recipes)
          .take(3)
          .toList();
      
      final loaded = HomeLoaded(
        recipes: recipes,
        countries: countries,
        suggestions: suggestions,
      );
      _cached = loaded;
      emit(loaded);
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  void search(String query) {
    // Implement search functionality
  }

  void generateRecipe() {
    // Implement recipe generation
  }
}
