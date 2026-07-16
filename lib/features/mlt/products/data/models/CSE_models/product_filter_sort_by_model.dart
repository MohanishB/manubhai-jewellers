class ProductSortByModel {
  final String labelDisplay; // e.g. "Price low to high"
  final String postName;     // e.g. "sort_by"
  final String value;        // e.g. "price_low_high"

  ProductSortByModel({
    required this.labelDisplay,
    required this.postName,
    required this.value,
  });

  factory ProductSortByModel.fromJson(Map<String, dynamic> json) {
    return ProductSortByModel(
      labelDisplay: (json['label_display'] ?? '').toString(),
      postName: (json['post_name'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'label_display': labelDisplay,
        'post_name': postName,
        'value': value,
      };
}
