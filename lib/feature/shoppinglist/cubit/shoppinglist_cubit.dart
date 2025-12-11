import 'package:flutter_bloc/flutter_bloc.dart';
import 'shoppinglist_state.dart';

class ShoppingListCubit extends Cubit<ShoppingListState> {
  ShoppingListCubit() : super(ShoppingListInitial());

  Future<void> loadShoppingList() async {
    emit(ShoppingListLoading());

    // Mock data - giống như trong ảnh
    final items = [
      ShoppingItem(
        id: '1',
        name: 'Potatoes',
        isChecked: false,
        category: 'Meat & Seafood',
        quantity: 2,
      ),
      ShoppingItem(
        id: '2',
        name: 'Steak',
        isChecked: true,
        category: 'Meat & Seafood',
        quantity: 1,
      ),
      ShoppingItem(
        id: '3',
        name: 'Tomatoes',
        isChecked: true,
        category: 'Vegetables',
        quantity: 1,
      ),
      ShoppingItem(
        id: '4',
        name: 'Sausages',
        isChecked: true,
        category: 'Meat & Seafood',
        quantity: 2,
      ),
    ];

    emit(ShoppingListLoaded(items: items));
  }

  void toggleItem(String itemId) {
    if (state is ShoppingListLoaded) {
      final currentState = state as ShoppingListLoaded;
      final updatedItems = currentState.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(isChecked: !item.isChecked);
        }
        return item;
      }).toList();

      emit(currentState.copyWith(items: updatedItems));
    }
  }

  void addItem(String name, String category) {
    if (state is ShoppingListLoaded) {
      final currentState = state as ShoppingListLoaded;
      final newItem = ShoppingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        isChecked: false,
        category: category,
      );

      final updatedItems = [...currentState.items, newItem];
      emit(currentState.copyWith(items: updatedItems));
    }
  }

  void deleteItem(String itemId) {
    if (state is ShoppingListLoaded) {
      final currentState = state as ShoppingListLoaded;
      final updatedItems = currentState.items
          .where((item) => item.id != itemId)
          .toList();

      emit(currentState.copyWith(items: updatedItems));
    }
  }

  void changeCategory(String category) {
    if (state is ShoppingListLoaded) {
      final currentState = state as ShoppingListLoaded;
      emit(currentState.copyWith(currentCategory: category));
    }
  }

  void increaseQuantity(String itemId) {
    if (state is ShoppingListLoaded) {
      final currentState = state as ShoppingListLoaded;
      final updatedItems = currentState.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(quantity: item.quantity + 1);
        }
        return item;
      }).toList();

      emit(currentState.copyWith(items: updatedItems));
    }
  }

  void decreaseQuantity(String itemId) {
    if (state is ShoppingListLoaded) {
      final currentState = state as ShoppingListLoaded;
      final updatedItems = currentState.items.map((item) {
        if (item.id == itemId && item.quantity > 1) {
          return item.copyWith(quantity: item.quantity - 1);
        }
        return item;
      }).toList();

      emit(currentState.copyWith(items: updatedItems));
    }
  }
}
