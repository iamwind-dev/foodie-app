import 'package:json_annotation/json_annotation.dart';

part 'recipe_model.g.dart';

@JsonSerializable()
class RecipeModel {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final int? prepTime;
  final int? cookTime;
  final int? servings;
  final String? difficulty;
  final String? category;
  final String? country;
  final List<String>? tags;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  RecipeModel({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.ingredients,
    required this.instructions,
    this.prepTime,
    this.cookTime,
    this.servings,
    this.difficulty,
    this.category,
    this.country,
    this.tags,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory RecipeModel.fromJson(Map<String, dynamic> json) => 
      _$RecipeModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$RecipeModelToJson(this);
}
