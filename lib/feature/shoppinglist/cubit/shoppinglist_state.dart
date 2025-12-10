import 'package:equatable/equatable.dart';

abstract class ShoppingListState extends Equatable {
  const ShoppingListState();

  @override
  List<Object?> get props => [];
}

class ShoppingListInitial extends ShoppingListState {}

class ShoppingListLoading extends ShoppingListState {}

class ShoppingListLoaded extends ShoppingListState {
  final List<ShoppingItem> items;
  final String currentCategory;

  const ShoppingListLoaded({
    required this.items,
    this.currentCategory = 'Meat & Seafood',
  });

  @override
  List<Object?> get props => [items, currentCategory];

  ShoppingListLoaded copyWith({
    List<ShoppingItem>? items,
    String? currentCategory,
  }) {
    return ShoppingListLoaded(
      items: items ?? this.items,
      currentCategory: currentCategory ?? this.currentCategory,
    );
  }
}

class ShoppingListError extends ShoppingListState {
  final String message;

  const ShoppingListError(this.message);

  @override
  List<Object?> get props => [message];
}

class ShoppingItem {
  final String id;
  final String name;
  final bool isChecked;
  final String category;
  final int quantity;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.isChecked,
    required this.category,
    this.quantity = 1,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    bool? isChecked,
    String? category,
    int? quantity,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
    );
  }
}
