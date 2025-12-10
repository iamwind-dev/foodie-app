class ExternalDish {
  final String id;
  final String name;
  final String image;
  final List<String> categories;

  ExternalDish({
    required this.id,
    required this.name,
    required this.image,
    required this.categories,
  });

  factory ExternalDish.fromJson(Map<String, dynamic> json) {
    final danhMuc = json['danh_muc'];
    final cats = <String>[];
    if (danhMuc is List) {
      for (final c in danhMuc) {
        final t = c is Map ? c['ten_danh_muc_mon_an']?.toString() : null;
        if (t != null && t.isNotEmpty) cats.add(t);
      }
    }
    return ExternalDish(
      id: json['ma_mon_an']?.toString() ?? '',
      name: json['ten_mon_an']?.toString() ?? '',
      image: json['hinh_anh']?.toString() ?? '',
      categories: cats,
    );
  }
}

