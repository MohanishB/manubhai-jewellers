import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_search_model.dart';

String _cleanText(dynamic value) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty || text.toLowerCase() == 'null') return '';
  return text;
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  return double.tryParse(value.toString().replaceAll(',', '')) ?? 0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  return int.tryParse(value.toString()) ?? 0;
}

class SimilarBucket extends Equatable {
  final int id;
  final String name;
  final String description;
  final String lob;
  final String category;
  final bool isOther;

  const SimilarBucket({
    required this.id,
    required this.name,
    this.description = '',
    this.lob = '',
    this.category = '',
    this.isOther = false,
  });

  factory SimilarBucket.fromJson(Map<String, dynamic> json) {
    return SimilarBucket(
      id: _toInt(json['id']),
      name: _cleanText(json['name']),
      description: _cleanText(json['description']),
      lob: _cleanText(json['lob']),
      category: _cleanText(json['category']),
      isOther: false,
    );
  }

  factory SimilarBucket.fromSeeAlsoTarget(Map<String, dynamic> json) {
    return SimilarBucket(
      id: _toInt(json['id']),
      name: _cleanText(json['name']),
      description: _cleanText(json['description']),
      lob: _cleanText(json['lob']),
      category: _cleanText(json['category']),
      isOther: true,
    );
  }

  String get optionKey => isOther ? 'other_$id' : 'bucket_$id';

  String get displayName {
    if (!isOther) return name;
    final parts = <String>[
      'Other',
      name,
      if (lob.trim().isNotEmpty) lob,
      if (category.trim().isNotEmpty) category,
    ];
    return parts.join(' - ');
  }

  @override
  List<Object?> get props => [id, name, description, lob, category, isOther];
}

class SimilarBucketSource extends Equatable {
  final String lob;
  final String category;
  final bool isFallback;

  const SimilarBucketSource({
    required this.lob,
    required this.category,
    required this.isFallback,
  });

  factory SimilarBucketSource.fromJson(Map<String, dynamic> json) {
    return SimilarBucketSource(
      lob: _cleanText(json['lob']),
      category: _cleanText(json['category']),
      isFallback: json['is_fallback'] == true || '${json['is_fallback']}'.toLowerCase() == 'true',
    );
  }

  @override
  List<Object?> get props => [lob, category, isFallback];
}

class SimilarLookupResponse extends Equatable {
  final String stockCode;
  final String imageUrl;
  final List<SimilarBucket> matchedBuckets;
  final List<SimilarBucket> allBuckets;
  final SimilarBucketSource? bucketSource;

  const SimilarLookupResponse({
    required this.stockCode,
    required this.imageUrl,
    required this.matchedBuckets,
    required this.allBuckets,
    this.bucketSource,
  });

  /// Correct source for bucket selection is matched_buckets.
  /// all_buckets is retained only for backwards-compatible parsing.
  List<SimilarBucket> get buckets =>
      matchedBuckets.isNotEmpty ? matchedBuckets : allBuckets;

  factory SimilarLookupResponse.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] ?? {});
    final item = Map<String, dynamic>.from(data['item'] ?? {});
    final bucketSourceJson = data['bucket_source'];

    return SimilarLookupResponse(
      stockCode: _cleanText(item['stock_code']),
      imageUrl: _cleanText(item['image_url']),
      matchedBuckets: (data['matched_buckets'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => SimilarBucket.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      allBuckets: (data['all_buckets'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => SimilarBucket.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      bucketSource: bucketSourceJson is Map
          ? SimilarBucketSource.fromJson(Map<String, dynamic>.from(bucketSourceJson))
          : null,
    );
  }

  @override
  List<Object?> get props => [
        stockCode,
        imageUrl,
        matchedBuckets,
        allBuckets,
        bucketSource,
      ];
}

class SimilarFilterOption extends Equatable {
  final String column;
  final String label;
  final String kind;
  final int seq;
  final List<String> values;
  final String minValue;
  final String maxValue;

  const SimilarFilterOption({
    required this.column,
    required this.label,
    required this.kind,
    required this.seq,
    required this.values,
    this.minValue = '',
    this.maxValue = '',
  });

  factory SimilarFilterOption.fromJson(Map<String, dynamic> json) {
    final range = json['range'] is Map
        ? Map<String, dynamic>.from(json['range'] as Map)
        : const <String, dynamic>{};

    return SimilarFilterOption(
      column: _cleanText(json['column'] ?? json['column_name']),
      label: _cleanText(json['label'] ?? json['column'] ?? json['column_name']),
      kind: _cleanText(json['kind']).isEmpty ? 'discrete' : _cleanText(json['kind']),
      seq: _toInt(json['seq'] ?? json['sequence']),
      values: (json['values'] as List<dynamic>? ?? [])
          .map(_cleanText)
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList()
        ..sort(),
      minValue: _cleanText(
        json['min'] ??
            json['min_value'] ??
            json['minimum'] ??
            json['from'] ??
            range['min'] ??
            range['min_value'],
      ),
      maxValue: _cleanText(
        json['max'] ??
            json['max_value'] ??
            json['maximum'] ??
            json['to'] ??
            range['max'] ??
            range['max_value'],
      ),
    );
  }

  bool get isNumeric => kind.toLowerCase().trim() == 'numeric';

  SimilarFilterOption copyWithValues(List<String> newValues) {
    return SimilarFilterOption(
      column: column,
      label: label,
      kind: kind,
      seq: seq,
      values: newValues.toSet().where((e) => e.trim().isNotEmpty).toList()..sort(),
      minValue: minValue,
      maxValue: maxValue,
    );
  }

  @override
  List<Object?> get props => [column, label, kind, seq, values, minValue, maxValue];
}

class BucketSimilarPiece extends Equatable {
  final String stockCode;
  final String imageUrl;
  final String weight;
  final String metalWeight;
  final String sellingPrice;
  final String itemStatus;
  final Map<String, String> attributes;
  final Map<String, dynamic> raw;

  const BucketSimilarPiece({
    required this.stockCode,
    required this.imageUrl,
    required this.weight,
    required this.metalWeight,
    required this.sellingPrice,
    required this.itemStatus,
    required this.attributes,
    required this.raw,
  });

  factory BucketSimilarPiece.fromJson(Map<String, dynamic> json) {
    final attributes = <String, String>{};
    final attributesJson = json['attributes'];

    if (attributesJson is Map) {
      attributesJson.forEach((key, value) {
        final label = _cleanText(key);
        final text = _cleanText(value);
        if (label.isNotEmpty && text.isNotEmpty) {
          attributes[label] = text;
        }
      });
    }

    return BucketSimilarPiece(
      stockCode: _cleanText(json['stock_code']),
      imageUrl: _cleanText(json['image_url']),
      weight: _cleanText(json['weight']),
      metalWeight: _cleanText(json['metal_weight']),
      sellingPrice: _cleanText(json['selling_price']),
      itemStatus: _cleanText(json['item_status']),
      attributes: attributes,
      raw: Map<String, dynamic>.from(json),
    );
  }

  ProductPiecePopupData toPopupData() {
    return ProductPiecePopupData(
      stockCode: stockCode,
      imageUrl: imageUrl,
      weight: weight,
      metalWeight: metalWeight,
      sellingPrice: sellingPrice,
      itemStatus: itemStatus,
      attributes: attributes,
    );
  }

  @override
  List<Object?> get props => [
        stockCode,
        imageUrl,
        weight,
        metalWeight,
        sellingPrice,
        itemStatus,
        attributes,
        raw,
      ];
}

class BucketSimilarResultItem extends Equatable {
  final String setNo;
  final String thumbCode;
  final String thumbUrl;
  final bool isSet;
  final int pieceCount;
  final String groupOfPieces;
  final double combinedNetWt;
  final double combinedGrossWt;
  final double combinedPrice;
  final List<BucketSimilarPiece> pieces;
  final Map<String, String> attributes;
  final Map<String, dynamic> raw;

  const BucketSimilarResultItem({
    required this.setNo,
    required this.thumbCode,
    required this.thumbUrl,
    required this.isSet,
    required this.pieceCount,
    required this.groupOfPieces,
    required this.combinedNetWt,
    required this.combinedGrossWt,
    required this.combinedPrice,
    required this.pieces,
    required this.attributes,
    required this.raw,
  });

  factory BucketSimilarResultItem.fromJson(Map<String, dynamic> json) {
    final pieces = (json['pieces'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => BucketSimilarPiece.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final attributes = <String, String>{};
    final attributesJson = json['attributes'];
    if (attributesJson is Map) {
      attributesJson.forEach((key, value) {
        final label = _cleanText(key);
        final text = _cleanText(value);
        if (label.isNotEmpty && text.isNotEmpty) {
          attributes[label] = text;
        }
      });
    }

    return BucketSimilarResultItem(
      setNo: _cleanText(json['set_no']),
      thumbCode: _cleanText(json['thumb_code'] ?? json['stock_code'] ?? json['set_no']),
      thumbUrl: _cleanText(json['thumb_url']),
      isSet: json['is_set'] == true || '${json['is_set']}'.toLowerCase() == 'true',
      pieceCount: _toInt(json['piece_count'] ?? pieces.length),
      groupOfPieces: _cleanText(json['group_of_pieces']),
      combinedNetWt: _toDouble(json['combined_net_wt']),
      combinedGrossWt: _toDouble(json['combined_gross_wt']),
      combinedPrice: _toDouble(json['combined_price']),
      pieces: pieces,
      attributes: attributes,
      raw: Map<String, dynamic>.from(json),
    );
  }

  ProductModel toProductModel() {
    final popupPieces = pieces.map((e) => e.toPopupData()).toList();

    return ProductModel(
      stockId: setNo,
      stockCode: thumbCode.isNotEmpty ? thumbCode : setNo,
      image: thumbUrl,
      price: combinedPrice.toStringAsFixed(0),
      weight: _formatNumber(combinedGrossWt),
      displayPrice: '₹${combinedPrice.toStringAsFixed(0)}',
      imagePopupData: [],
      piecePopupData: popupPieces,
    );
  }

  static String _formatNumber(double value) {
    final text = value.toStringAsFixed(2);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  List<String> valuesForColumn(String column) {
    final key = column.trim();
    final values = <String>[];

    void addValue(dynamic value) {
      final text = _cleanText(value);
      if (text.isNotEmpty) values.add(text);
    }

    addValue(raw[key]);

    final itemAttributes = raw['attributes'];
    if (itemAttributes is Map) {
      addValue(itemAttributes[key]);
      final normalizedKey = _normalizeKey(key);
      itemAttributes.forEach((attrKey, attrValue) {
        if (_normalizeKey(attrKey) == normalizedKey) addValue(attrValue);
      });
    }

    switch (key) {
      case 'selling_price':
      case 'price':
      case 'rrp':
        addValue(raw['combined_price']);
        break;
      case 'weight':
      case 'gross_weight':
        addValue(raw['combined_gross_wt']);
        break;
      case 'metal_weight':
      case 'net_weight':
        addValue(raw['combined_net_wt']);
        break;
      case 'stock_code':
        addValue(raw['thumb_code']);
        addValue(raw['set_no']);
        break;
    }

    for (final piece in pieces) {
      addValue(piece.raw[key]);

      final pieceAttributes = piece.raw['attributes'];
      if (pieceAttributes is Map) {
        addValue(pieceAttributes[key]);
        final normalizedKey = _normalizeKey(key);
        pieceAttributes.forEach((attrKey, attrValue) {
          if (_normalizeKey(attrKey) == normalizedKey) addValue(attrValue);
        });
      }

      switch (key) {
        case 'selling_price':
        case 'price':
        case 'rrp':
          addValue(piece.raw['selling_price']);
          break;
        case 'stock_code':
          addValue(piece.raw['stock_code']);
          break;
      }
    }

    return values.toSet().toList();
  }

  static String _normalizeKey(dynamic key) {
    return key
        .toString()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  String valueForColumn(String column) {
    final values = valuesForColumn(column);
    return values.isEmpty ? '' : values.first;
  }

  double? numericValueForColumn(String column) {
    for (final value in valuesForColumn(column)) {
      final parsed = double.tryParse(value.replaceAll(',', ''));
      if (parsed != null) return parsed;
    }
    return null;
  }

  bool matchesFilters(Map<String, Set<String>> filters) {
    for (final entry in filters.entries) {
      if (entry.value.isEmpty) continue;

      final key = entry.key;
      if (key.endsWith('__min') || key.endsWith('__max')) {
        final column = key.replaceAll('__min', '').replaceAll('__max', '');
        final target = numericValueForColumn(column);
        if (target == null) return false;

        final filterValue = double.tryParse(entry.value.first.replaceAll(',', ''));
        if (filterValue == null) continue;

        if (key.endsWith('__min') && target < filterValue) return false;
        if (key.endsWith('__max') && target > filterValue) return false;
        continue;
      }

      final itemValues = valuesForColumn(key).map((e) => e.trim()).toSet();
      final selectedValues = entry.value.map((e) => e.trim()).toSet();

      if (itemValues.isNotEmpty) {
        if (itemValues.intersection(selectedValues).isEmpty) return false;
        continue;
      }

      final rawText = raw.toString().toLowerCase();
      final foundInRaw = selectedValues.any(
        (value) => rawText.contains(value.toLowerCase()),
      );
      if (!foundInRaw) return false;
    }
    return true;
  }

  @override
  List<Object?> get props => [
        setNo,
        thumbCode,
        thumbUrl,
        isSet,
        pieceCount,
        groupOfPieces,
        combinedNetWt,
        combinedGrossWt,
        combinedPrice,
        pieces,
        attributes,
        raw,
      ];
}

class SimilarSeeAlsoBucket extends Equatable {
  final int linkId;
  final SimilarBucket targetBucket;
  final int totalCount;
  final List<BucketSimilarResultItem> items;
  final List<SimilarFilterOption> filterOptions;

  const SimilarSeeAlsoBucket({
    required this.linkId,
    required this.targetBucket,
    required this.totalCount,
    required this.items,
    required this.filterOptions,
  });

  factory SimilarSeeAlsoBucket.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => BucketSimilarResultItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final filterOptions = _parseFilterOptions(json)
        .map((e) {
          if (e.isNumeric || e.values.isNotEmpty) return e;
          return e.copyWithValues(BucketSimilarResultsResponse.valuesForColumn(items, e.column));
        })
        .where((e) => e.isNumeric || e.values.isNotEmpty)
        .toList()
      ..sort((a, b) => a.seq.compareTo(b.seq));

    return SimilarSeeAlsoBucket(
      linkId: _toInt(json['link_id']),
      targetBucket: SimilarBucket.fromSeeAlsoTarget(
        Map<String, dynamic>.from(json['target_bucket'] ?? {}),
      ),
      totalCount: _toInt(json['total_count']),
      items: items,
      filterOptions: filterOptions,
    );
  }

  @override
  List<Object?> get props => [linkId, targetBucket, totalCount, items, filterOptions];
}

class BucketSimilarResultsResponse extends Equatable {
  final SimilarBucket bucket;
  final SimilarBucketSource? bucketSource;
  final List<BucketSimilarResultItem> items;
  final List<SimilarSeeAlsoBucket> seeAlso;
  final List<SimilarFilterOption> filterOptions;
  final int totalItems;

  const BucketSimilarResultsResponse({
    required this.bucket,
    required this.items,
    required this.seeAlso,
    required this.filterOptions,
    required this.totalItems,
    this.bucketSource,
  });

  factory BucketSimilarResultsResponse.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] ?? {});
    final items = (data['items'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => BucketSimilarResultItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final seeAlso = (data['see_also'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => SimilarSeeAlsoBucket.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final filterOptions = _parseFilterOptions(data)
        .map((e) {
          if (e.isNumeric || e.values.isNotEmpty) return e;
          return e.copyWithValues(valuesForColumn(items, e.column));
        })
        .where((e) => e.isNumeric || e.values.isNotEmpty)
        .toList()
      ..sort((a, b) => a.seq.compareTo(b.seq));

    final bucketSourceJson = data['bucket_source'];

    return BucketSimilarResultsResponse(
      bucket: SimilarBucket.fromJson(Map<String, dynamic>.from(data['bucket'] ?? {})),
      bucketSource: bucketSourceJson is Map
          ? SimilarBucketSource.fromJson(Map<String, dynamic>.from(bucketSourceJson))
          : null,
      items: items,
      seeAlso: seeAlso,
      filterOptions: filterOptions,
      totalItems: _toInt(data['total_items'] ?? items.length),
    );
  }

  static List<String> valuesForColumn(
    List<BucketSimilarResultItem> items,
    String column,
  ) {
    final values = <String>{};
    for (final item in items) {
      for (final value in item.valuesForColumn(column)) {
        final text = value.trim();
        if (text.isNotEmpty && text.toLowerCase() != 'null') values.add(text);
      }
    }
    return values.toList()..sort();
  }

  @override
  List<Object?> get props => [bucket, bucketSource, items, seeAlso, filterOptions, totalItems];
}

List<SimilarFilterOption> _parseFilterOptions(Map<String, dynamic> json) {
  final dynamic filterJson = json['filter_options'] ??
      json['filters'] ??
      json['available_filters'] ??
      json['sequence'] ??
      <dynamic>[];

  if (filterJson is! List) return const [];

  return filterJson
      .whereType<Map>()
      .map((e) => SimilarFilterOption.fromJson(Map<String, dynamic>.from(e)))
      .where((e) => e.column.trim().isNotEmpty)
      .toList();
}
