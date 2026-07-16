class FilterOptionsResponse {
  final int errorCode;
  final String errorMsg;
  final int successCode;
  final FilterOptions filterOptions;

  FilterOptionsResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.successCode,
    required this.filterOptions,
  });

  factory FilterOptionsResponse.fromJson(Map<String, dynamic> json) {
    return FilterOptionsResponse(
      errorCode: int.tryParse((json['error_code'] ?? '0').toString()) ?? 0,
      errorMsg: (json['error_msg'] ?? '').toString(),
      successCode: int.tryParse((json['success_code'] ?? '0').toString()) ?? 0,
      filterOptions: FilterOptions.fromJson(
        Map<String, dynamic>.from(json['filter_options'] ?? {}),
      ),
    );
  }
}

class FilterOptions {
  final List<String> colors;
  final List<String> clarity;
  final List<String> cuts;
  final List<String> certificates;
  final int totalAvailable;
  final String shape;

  FilterOptions({
    required this.colors,
    required this.clarity,
    required this.cuts,
    required this.certificates,
    required this.totalAvailable,
    required this.shape,
  });

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    List<String> _asStringList(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return <String>[];
    }

    return FilterOptions(
      colors: _asStringList(json['colors']),
      clarity: _asStringList(json['clarity']),
      cuts: _asStringList(json['cuts']),
      certificates: _asStringList(json['certificates']),
      totalAvailable: int.tryParse((json['total_available'] ?? '0').toString()) ?? 0,
      shape: (json['shape'] ?? 'Round').toString(),
    );
  }
}


class FilterShapesResponse {
  final int errorCode;
  final String errorMsg;
  final int successCode;
  final List<String> shapes;
  final int totalShapes;
  final FilterOptions filterOptions;

  FilterShapesResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.successCode,
    required this.shapes,
    required this.totalShapes,
    required this.filterOptions,
  });

  factory FilterShapesResponse.fromJson(Map<String, dynamic> json) {
    List<String> asStringList(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return <String>[];
    }

    return FilterShapesResponse(
      errorCode: int.tryParse((json['error_code'] ?? '0').toString()) ?? 0,
      errorMsg: (json['error_msg'] ?? '').toString(),
      successCode: int.tryParse((json['success_code'] ?? '0').toString()) ?? 0,
      shapes: asStringList(json['shapes']),
      totalShapes: int.tryParse((json['total_shapes'] ?? '0').toString()) ?? 0,
      filterOptions: FilterOptions.fromJson(
        Map<String, dynamic>.from(json['filter_options'] ?? {}),
      ),
    );
  }
}
