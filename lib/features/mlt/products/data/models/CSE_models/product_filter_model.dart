// class ProductFilterModel {
//   final String labelDisplay;
//   final Map<String, dynamic> postName;
//   final String fieldType;
//   final List<String> values;

//   ProductFilterModel({
//     required this.labelDisplay,
//     required this.postName,
//     required this.fieldType,
//     required this.values,
//   });

//   factory ProductFilterModel.fromJson(Map<String, dynamic> json) {
//     return ProductFilterModel(
//       labelDisplay: json['label_display'] ?? '',
//       postName: Map<String, dynamic>.from(json['post_name'] ?? {}),
//       fieldType: json['field_type'] ?? '',
//       values: (json['values'] is List)
//           ? List<String>.from(json['values'])
//           : <String>[],
//     );
//   }
// }

//============================================//

class ProductFilterModel {
  final String labelDisplay;
  final Map<String, dynamic> postName;
  final String fieldType;
  final List<String> values;

  /// New field: whether the filter is mandatory (1 = true, 0 = false)
  final bool mandatory;

  ProductFilterModel({
    required this.labelDisplay,
    required this.postName,
    required this.fieldType,
    required this.values,
    required this.mandatory,
  });

  factory ProductFilterModel.fromJson(Map<String, dynamic> json) {
    return ProductFilterModel(
      labelDisplay: json['label_display'] ?? '',
      postName: Map<String, dynamic>.from(json['post_name'] ?? {}),
      fieldType: json['field_type'] ?? '',
      values: (json['values'] is List)
          ? List<String>.from(json['values'])
          : <String>[],
      mandatory: (json['mandatory']?.toString() ?? '0') == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label_display': labelDisplay,
      'post_name': postName,
      'field_type': fieldType,
      'values': values,
      'mandatory': mandatory ? '1' : '0',
    };
  }
}
