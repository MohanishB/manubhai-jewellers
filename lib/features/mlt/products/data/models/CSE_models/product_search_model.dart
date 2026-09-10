// features/products/data/models/product_search_model.dart

class FreezedProductStatus {
  final bool freezed;
  final bool byOwn;
  final bool byOther;
  final String cseName;

  const FreezedProductStatus({
    this.freezed = false,
    this.byOwn = false,
    this.byOther = false,
    this.cseName = '',
  });

  factory FreezedProductStatus.fromJson(dynamic json) {
    if (json is! Map) return const FreezedProductStatus();

    bool flag(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value == 1;
      final text = '${value ?? ''}'.trim().toLowerCase();
      return text == '1' || text == 'true' || text == 'yes';
    }

    final freezed = flag(json['freezed']);
    final byOwn = freezed && flag(json['by_own']);
    // `by_own` is the authoritative ownership flag. If it is 1, never let
    // `by_other` override the UI even if a malformed payload contains both.
    final byOther = freezed && !byOwn && flag(json['by_other']);

    return FreezedProductStatus(
      freezed: freezed,
      byOwn: byOwn,
      byOther: byOther,
      cseName: '${json['cse_name'] ?? ''}'.trim(),
    );
  }
}

class ProductModel {
  final String stockId;
  final String stockCode;
  final String image;
  final String price;
  final String weight;
  final String displayPrice;
  final FreezedProductStatus freezedProduct;

  /// Whether the API requests the product thumbnail to be zoomed.
  final bool zoomImage;

  /// Scale supplied by the API when [zoomImage] is true.
  /// Defaults to 1.0 when zooming is disabled or the value is invalid.
  final double zoomLevel;

  /// Existing popup label/value data used by older screens.
  final List<ImagePopupData> imagePopupData;

  /// Piece-level popup data used by Bucket Similar Products.
  /// Empty for older API responses/screens.
  final List<ProductPiecePopupData> piecePopupData;

  ProductModel({
    required this.stockId,
    required this.stockCode,
    required this.image,
    required this.price,
    required this.weight,
    required this.displayPrice,
    this.freezedProduct = const FreezedProductStatus(),
    this.zoomImage = false,
    this.zoomLevel = 1.0,
    required this.imagePopupData,
    this.piecePopupData = const [],
  });

  ProductModel copyWith({FreezedProductStatus? freezedProduct}) {
    return ProductModel(
      stockId: stockId,
      stockCode: stockCode,
      image: image,
      price: price,
      weight: weight,
      displayPrice: displayPrice,
      freezedProduct: freezedProduct ?? this.freezedProduct,
      zoomImage: zoomImage,
      zoomLevel: zoomLevel,
      imagePopupData: imagePopupData,
      piecePopupData: piecePopupData,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      stockId: '${json['stock_id'] ?? ''}',
      stockCode: '${json['stock_code'] ?? ''}',
      image: '${json['product_image'] ?? ''}',
      price: '${json['selling_price'] ?? ''}',
      weight: '${json['weight'] ?? ''}',
      displayPrice: '${json['display_price'] ?? ''}',
      freezedProduct: FreezedProductStatus.fromJson(json['freezed_product']),
      zoomImage: '${json['zoom_image'] ?? ''}'.trim().toLowerCase() == 'yes',
      zoomLevel: _resolvedZoomLevel(json),
      imagePopupData: (json['image_popup_data'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => ImagePopupData.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      piecePopupData: (json['piece_popup_data'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => ProductPiecePopupData.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  static double _resolvedZoomLevel(Map<String, dynamic> json) {
    final parsed = double.tryParse('${json['zoom_level'] ?? ''}'.trim());
    return parsed != null && parsed > 0 ? parsed : 1.0;
  }
}

class ImagePopupData {
  final String label;
  final String value;

  const ImagePopupData({
    required this.label,
    required this.value,
  });

  factory ImagePopupData.fromJson(Map<String, dynamic> json) {
    return ImagePopupData(
      label: '${json['label'] ?? ''}',
      value: '${json['value'] ?? ''}',
    );
  }
}

class ProductPiecePopupData {
  final String stockCode;
  final String imageUrl;
  final String weight;
  final String metalWeight;
  final String sellingPrice;
  final String itemStatus;
  final bool zoomImage;
  final double zoomLevel;
  final Map<String, String> attributes;

  const ProductPiecePopupData({
    required this.stockCode,
    required this.imageUrl,
    required this.weight,
    required this.metalWeight,
    required this.sellingPrice,
    required this.itemStatus,
    this.zoomImage = false,
    this.zoomLevel = 1.0,
    this.attributes = const {},
  });

  factory ProductPiecePopupData.fromJson(Map<String, dynamic> json) {
    final attributesJson = json['attributes'];
    final attributes = <String, String>{};

    if (attributesJson is Map) {
      attributesJson.forEach((key, value) {
        final label = key.toString().trim();
        final text = value?.toString().trim() ?? '';
        if (label.isNotEmpty && text.isNotEmpty && text.toLowerCase() != 'null') {
          attributes[label] = text;
        }
      });
    }

    return ProductPiecePopupData(
      stockCode: '${json['stock_code'] ?? ''}',
      imageUrl: '${json['image_url'] ?? ''}',
      weight: '${json['weight'] ?? ''}',
      metalWeight: '${json['metal_weight'] ?? ''}',
      sellingPrice: '${json['selling_price'] ?? ''}',
      itemStatus: '${json['item_status'] ?? ''}',
      zoomImage: '${json['zoom_image'] ?? ''}'.trim().toLowerCase() == 'yes',
      zoomLevel: _resolvedZoomLevel(json),
      attributes: attributes,
    );
  }

  static double _resolvedZoomLevel(Map<String, dynamic> json) {
    final parsed = double.tryParse('${json['zoom_level'] ?? ''}'.trim());
    return parsed != null && parsed > 0 ? parsed : 1.0;
  }

  List<ImagePopupData> get displayRows {
    final rows = <ImagePopupData>[];

    void add(String label, String value) {
      final text = value.trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        rows.add(ImagePopupData(label: label, value: text));
      }
    }

    add('Stock Code', stockCode);
    add('Gross Weight', weight);
    add('Weight', metalWeight);
    add('Selling Price', sellingPrice);
    add('Item Status', itemStatus);

    for (final entry in attributes.entries) {
      if (rows.any((row) => row.label.toLowerCase() == entry.key.toLowerCase())) {
        continue;
      }
      add(entry.key, entry.value);
    }

    return rows;
  }
}

class ProductSearchResponse {
  final int loadCount;
  final int maxSafeCount;
  final int totalFound;
  final List<ProductModel> products;
  final Map<String, dynamic> postParams;

  ProductSearchResponse({
    required this.loadCount,
    required this.maxSafeCount,
    required this.totalFound,
    required this.products,
    required this.postParams,
  });

  factory ProductSearchResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['product_list'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return ProductSearchResponse(
      loadCount: int.tryParse('${json['load_product_count']}') ?? 0,
      maxSafeCount: int.tryParse('${json['max_safe_order_count']}') ?? 0,
      totalFound: int.tryParse('${json['total_product_found']}') ?? 0,
      postParams: Map<String, dynamic>.from(json['post_params'] ?? {}),
      products: list,
    );
  }
}
