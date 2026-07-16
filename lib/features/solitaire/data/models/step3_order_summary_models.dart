// class Step3OrderSummaryResponse {
//   final int errorCode;
//   final int successCode;
//   final String errorMsg;
//   final Step3OrderSummaryVm? orderSummary;
//   final bool isSavedOrder;

//   const Step3OrderSummaryResponse({
//     required this.errorCode,
//     required this.successCode,
//     required this.errorMsg,
//     required this.orderSummary,
//     required this.isSavedOrder,
//   });

//   factory Step3OrderSummaryResponse.fromJson(Map<String, dynamic> json) {
//     return Step3OrderSummaryResponse(
//       errorCode: int.tryParse((json['error_code'] ?? 0).toString()) ?? 0,
//       successCode: int.tryParse((json['success_code'] ?? 0).toString()) ?? 0,
//       errorMsg: (json['error_msg'] ?? '').toString(),
//       orderSummary: json['order_summary'] == null
//           ? null
//           : Step3OrderSummaryVm.fromJson(
//               Map<String, dynamic>.from(json['order_summary']),
//             ),
//       isSavedOrder: json['is_saved_order'] == true,
//     );
//   }
// }

// class Step3OrderSummaryVm {
//   final CustomerDetailsVm customerDetails;
//   final OriginalProductVm originalProduct;
//   final SelectedDiamondVm selectedDiamond;
//   final PriceCalculationVm priceCalculation;
//   final SolitaireComparisonVm solitaireComparison;

//   const Step3OrderSummaryVm({
//     required this.customerDetails,
//     required this.originalProduct,
//     required this.selectedDiamond,
//     required this.priceCalculation,
//     required this.solitaireComparison,
//   });

//   factory Step3OrderSummaryVm.fromJson(Map<String, dynamic> j) {
//     return Step3OrderSummaryVm(
//       customerDetails: CustomerDetailsVm.fromJson(
//         Map<String, dynamic>.from(j['customer_details'] ?? {}),
//       ),
//       originalProduct: OriginalProductVm.fromJson(
//         Map<String, dynamic>.from(j['original_product'] ?? {}),
//       ),
//       selectedDiamond: SelectedDiamondVm.fromJson(
//         Map<String, dynamic>.from(j['selected_diamond'] ?? {}),
//       ),
//       priceCalculation: PriceCalculationVm.fromJson(
//         Map<String, dynamic>.from(j['price_calculation'] ?? {}),
//       ),
//       solitaireComparison: SolitaireComparisonVm.fromJson(
//         Map<String, dynamic>.from(j['solitaire_comparison'] ?? {}),
//       ),
//     );
//   }
// }

// class CustomerDetailsVm {
//   final String name;
//   final String phone;
//   final String email;

//   const CustomerDetailsVm({
//     required this.name,
//     required this.phone,
//     required this.email,
//   });

//   factory CustomerDetailsVm.fromJson(Map<String, dynamic> j) {
//     return CustomerDetailsVm(
//       name: (j['name'] ?? '').toString(),
//       phone: (j['phone'] ?? '').toString(),
//       email: (j['email'] ?? '').toString(),
//     );
//   }
// }

// class OriginalProductVm {
//   final String stockCode;
//   final String stockImage;
//   final String grossWt;
//   final String netWt;
//   final String labourAmount;
//   final String metalAmount;
//   final String diamondWt;
//   final String diamondAmount;
//   final String solitaireWt;
//   final String solitaireAmount;
//   final String totalAmount;

//   const OriginalProductVm({
//     required this.stockCode,
//     required this.stockImage,
//     required this.grossWt,
//     required this.netWt,
//     required this.labourAmount,
//     required this.metalAmount,
//     required this.diamondWt,
//     required this.diamondAmount,
//     required this.solitaireWt,
//     required this.solitaireAmount,
//     required this.totalAmount,
//   });

//   factory OriginalProductVm.fromJson(Map<String, dynamic> j) {
//     return OriginalProductVm(
//       stockCode: (j['stock_code'] ?? '').toString(),
//       stockImage: (j['stock_image'] ?? '').toString(),
//       grossWt: (j['gross_wt'] ?? '').toString(),
//       netWt: (j['net_wt'] ?? '').toString(),
//       labourAmount: (j['labour_amount'] ?? '').toString(),
//       metalAmount: (j['metal_amount'] ?? '').toString(),
//       diamondWt: (j['diamond_wt'] ?? '').toString(),
//       diamondAmount: (j['diamond_amount'] ?? '').toString(),
//       solitaireWt: (j['solitaire_wt'] ?? '').toString(),
//       solitaireAmount: (j['solitaire_amount'] ?? '').toString(),
//       totalAmount: (j['total_amount'] ?? '').toString(),
//     );
//   }
// }

// class SelectedDiamondVm {
//   final String id;
//   final String lotNumber;
//   final String shape;
//   final String carat;
//   final String carats;
//   final String color;
//   final String clarity;
//   final String cut;
//   final String polish;
//   final String symmetry;
//   final String fluorescence;
//   final String cert;
//   final String certNo;
//   final String priceDollar;
//   final String priceInr;
//   final String measurement;
//   final String totalDepth;
//   final String tables;

//   const SelectedDiamondVm({
//     required this.id,
//     required this.lotNumber,
//     required this.shape,
//     required this.carat,
//     required this.carats,
//     required this.color,
//     required this.clarity,
//     required this.cut,
//     required this.polish,
//     required this.symmetry,
//     required this.fluorescence,
//     required this.cert,
//     required this.certNo,
//     required this.priceDollar,
//     required this.priceInr,
//     required this.measurement,
//     required this.totalDepth,
//     required this.tables,
//   });

//   factory SelectedDiamondVm.fromJson(Map<String, dynamic> j) {
//     return SelectedDiamondVm(
//       id: (j['id'] ?? '').toString(),
//       lotNumber: (j['lot_number'] ?? '').toString(),
//       shape: (j['shape'] ?? '').toString(),
//       carat: (j['carat'] ?? '').toString(),
//       carats: (j['carats'] ?? '').toString(),
//       color: (j['color'] ?? '').toString(),
//       clarity: (j['clarity'] ?? '').toString(),
//       cut: (j['cut'] ?? '').toString(),
//       polish: (j['polish'] ?? '').toString(),
//       symmetry: (j['symmetry'] ?? '').toString(),
//       fluorescence: (j['fluorescence'] ?? '').toString(),
//       cert: (j['cert'] ?? '').toString(),
//       certNo: (j['cert_no'] ?? '').toString(),
//       priceDollar: (j['price_dollar'] ?? '').toString(),
//       priceInr: (j['price_inr'] ?? '').toString(),
//       measurement: (j['measurement'] ?? '').toString(),
//       totalDepth: (j['total_depth'] ?? '').toString(),
//       tables: (j['tables'] ?? '').toString(),
//     );
//   }
// }

// class PriceCalculationVm {
//   final String originalSolitaireWt;
//   final String originalSolitaireAmount;
//   final String originalTotalAmount;
//   final String selectedDiamondWt;
//   final String selectedDiamondPrice;
//   final String weightDifference;
//   final String priceDifference;
//   final String priceDifferenceSign;
//   final String finalTotalAmount;

//   final List<KaratOptionVm> karatOptions;
//   final bool goldRatesAvailable;
//   final String currentKarat;
//   final String netWeight;
//   final String labourAmount;
//   final String diamondAmount;
//   final FinalPricingBreakdownVm finalPricingBreakdown;

//   const PriceCalculationVm({
//     required this.originalSolitaireWt,
//     required this.originalSolitaireAmount,
//     required this.originalTotalAmount,
//     required this.selectedDiamondWt,
//     required this.selectedDiamondPrice,
//     required this.weightDifference,
//     required this.priceDifference,
//     required this.priceDifferenceSign,
//     required this.finalTotalAmount,
//     required this.karatOptions,
//     required this.goldRatesAvailable,
//     required this.currentKarat,
//     required this.netWeight,
//     required this.labourAmount,
//     required this.diamondAmount,
//     required this.finalPricingBreakdown,
//   });

//   factory PriceCalculationVm.fromJson(Map<String, dynamic> j) {
//     return PriceCalculationVm(
//       originalSolitaireWt: (j['original_solitaire_wt'] ?? '').toString(),
//       originalSolitaireAmount: (j['original_solitaire_amount'] ?? '').toString(),
//       originalTotalAmount: (j['original_total_amount'] ?? '').toString(),
//       selectedDiamondWt: (j['selected_diamond_wt'] ?? '').toString(),
//       selectedDiamondPrice: (j['selected_diamond_price'] ?? '').toString(),
//       weightDifference: (j['weight_difference'] ?? '').toString(),
//       priceDifference: (j['price_difference'] ?? '').toString(),
//       priceDifferenceSign: (j['price_difference_sign'] ?? '').toString(),
//       finalTotalAmount: (j['final_total_amount'] ?? '').toString(),
//       karatOptions: (j['karat_options'] as List<dynamic>? ?? [])
//           .map((e) => KaratOptionVm.fromJson(Map<String, dynamic>.from(e)))
//           .toList(),
//       goldRatesAvailable: j['gold_rates_available'] == true,
//       currentKarat: (j['current_karat'] ?? '').toString(),
//       netWeight: (j['net_weight'] ?? '').toString(),
//       labourAmount: (j['labour_amount'] ?? '').toString(),
//       diamondAmount: (j['diamond_amount'] ?? '').toString(),
//       finalPricingBreakdown: FinalPricingBreakdownVm.fromJson(
//         Map<String, dynamic>.from(j['final_pricing_breakdown'] ?? {}),
//       ),
//     );
//   }
// }

// class KaratOptionVm {
//   final String karat;
//   final String goldRate;
//   final String netWeight;
//   final String goldCost;
//   final String smallDiamonds;
//   final String perCaratPrice;
//   final String solitaireWeight;
//   final String solitaireCost;
//   final String labour;
//   final String finalPrice;

//   const KaratOptionVm({
//     required this.karat,
//     required this.goldRate,
//     required this.netWeight,
//     required this.goldCost,
//     required this.smallDiamonds,
//     required this.perCaratPrice,
//     required this.solitaireWeight,
//     required this.solitaireCost,
//     required this.labour,
//     required this.finalPrice,
//   });

//   factory KaratOptionVm.fromJson(Map<String, dynamic> j) {
//     return KaratOptionVm(
//       karat: (j['karat'] ?? '').toString(),
//       goldRate: (j['gold_rate'] ?? '').toString(),
//       netWeight: (j['net_weight'] ?? '').toString(),
//       goldCost: (j['gold_cost'] ?? '').toString(),
//       smallDiamonds: (j['small_diamonds'] ?? '').toString(),
//       perCaratPrice: (j['per_carat_price'] ?? '').toString(),
//       solitaireWeight: (j['solitaire_weight'] ?? '').toString(),
//       solitaireCost: (j['solitaire_cost'] ?? '').toString(),
//       labour: (j['labour'] ?? '').toString(),
//       finalPrice: (j['final_price'] ?? '').toString(),
//     );
//   }
// }

// class FinalPricingBreakdownVm {
//   final String originalTotal;
//   final String originalSolitaire;
//   final String newSolitaire;
//   final String priceDifference;
//   final String priceDifferenceSign;

//   const FinalPricingBreakdownVm({
//     required this.originalTotal,
//     required this.originalSolitaire,
//     required this.newSolitaire,
//     required this.priceDifference,
//     required this.priceDifferenceSign,
//   });

//   factory FinalPricingBreakdownVm.fromJson(Map<String, dynamic> j) {
//     return FinalPricingBreakdownVm(
//       originalTotal: (j['original_total'] ?? '').toString(),
//       originalSolitaire: (j['original_solitaire'] ?? '').toString(),
//       newSolitaire: (j['new_solitaire'] ?? '').toString(),
//       priceDifference: (j['price_difference'] ?? '').toString(),
//       priceDifferenceSign: (j['price_difference_sign'] ?? '').toString(),
//     );
//   }
// }

// class SolitaireComparisonVm {
//   final ComparisonBeforeVm before;
//   final ComparisonAfterVm after;

//   const SolitaireComparisonVm({
//     required this.before,
//     required this.after,
//   });

//   factory SolitaireComparisonVm.fromJson(Map<String, dynamic> j) {
//     return SolitaireComparisonVm(
//       before: ComparisonBeforeVm.fromJson(
//         Map<String, dynamic>.from(j['before'] ?? {}),
//       ),
//       after: ComparisonAfterVm.fromJson(
//         Map<String, dynamic>.from(j['after'] ?? {}),
//       ),
//     );
//   }
// }

// class ComparisonBeforeVm {
//   final String weight;
//   final String amount;

//   const ComparisonBeforeVm({
//     required this.weight,
//     required this.amount,
//   });

//   factory ComparisonBeforeVm.fromJson(Map<String, dynamic> j) {
//     return ComparisonBeforeVm(
//       weight: (j['weight'] ?? '').toString(),
//       amount: (j['amount'] ?? '').toString(),
//     );
//   }
// }

// class ComparisonAfterVm {
//   final String weight;
//   final String amount;
//   final String lotNumber;
//   final String color;
//   final String clarity;
//   final String cut;
//   final String cert;

//   const ComparisonAfterVm({
//     required this.weight,
//     required this.amount,
//     required this.lotNumber,
//     required this.color,
//     required this.clarity,
//     required this.cut,
//     required this.cert,
//   });

//   factory ComparisonAfterVm.fromJson(Map<String, dynamic> j) {
//     return ComparisonAfterVm(
//       weight: (j['weight'] ?? '').toString(),
//       amount: (j['amount'] ?? '').toString(),
//       lotNumber: (j['lot_number'] ?? '').toString(),
//       color: (j['color'] ?? '').toString(),
//       clarity: (j['clarity'] ?? '').toString(),
//       cut: (j['cut'] ?? '').toString(),
//       cert: (j['cert'] ?? '').toString(),
//     );
//   }
// }

//=========================================//
//=========================================//
//=========================================//


class Step3OrderSummaryResponse {
  final int errorCode;
  final int successCode;
  final String errorMsg;
  final Step3OrderSummaryVm? orderSummary;
  final bool isSavedOrder;

  const Step3OrderSummaryResponse({
    required this.errorCode,
    required this.successCode,
    required this.errorMsg,
    required this.orderSummary,
    required this.isSavedOrder,
  });

  factory Step3OrderSummaryResponse.fromJson(Map<String, dynamic> json) {
    return Step3OrderSummaryResponse(
      errorCode: int.tryParse((json['error_code'] ?? 0).toString()) ?? 0,
      successCode: int.tryParse((json['success_code'] ?? 0).toString()) ?? 0,
      errorMsg: (json['error_msg'] ?? '').toString(),
      orderSummary: json['order_summary'] == null
          ? null
          : Step3OrderSummaryVm.fromJson(
              Map<String, dynamic>.from(json['order_summary']),
            ),
      isSavedOrder: json['is_saved_order'] == true,
    );
  }
}

class Step3OrderSummaryVm {
  final CustomerDetailsVm customerDetails;
  final OriginalProductVm originalProduct;
  final SelectedDiamondVm selectedDiamond;
  final PriceCalculationVm priceCalculation;
  final SolitaireComparisonVm solitaireComparison;
  final OrderInfoVm? orderInfo;

  const Step3OrderSummaryVm({
    required this.customerDetails,
    required this.originalProduct,
    required this.selectedDiamond,
    required this.priceCalculation,
    required this.solitaireComparison,
    this.orderInfo,
  });

  factory Step3OrderSummaryVm.fromJson(Map<String, dynamic> j) {
    return Step3OrderSummaryVm(
      customerDetails: CustomerDetailsVm.fromJson(
        Map<String, dynamic>.from(j['customer_details'] ?? {}),
      ),
      originalProduct: OriginalProductVm.fromJson(
        Map<String, dynamic>.from(j['original_product'] ?? {}),
      ),
      selectedDiamond: SelectedDiamondVm.fromJson(
        Map<String, dynamic>.from(j['selected_diamond'] ?? {}),
      ),
      priceCalculation: PriceCalculationVm.fromJson(
        Map<String, dynamic>.from(j['price_calculation'] ?? {}),
      ),
      solitaireComparison: SolitaireComparisonVm.fromJson(
        Map<String, dynamic>.from(j['solitaire_comparison'] ?? {}),
      ),
      orderInfo: j['order_info'] == null
          ? null
          : OrderInfoVm.fromJson(
              Map<String, dynamic>.from(j['order_info']),
            ),
    );
  }
}

class CustomerDetailsVm {
  final String name;
  final String phone;
  final String email;

  const CustomerDetailsVm({
    required this.name,
    required this.phone,
    required this.email,
  });

  factory CustomerDetailsVm.fromJson(Map<String, dynamic> j) {
    return CustomerDetailsVm(
      name: (j['name'] ?? '').toString(),
      phone: (j['phone'] ?? '').toString(),
      email: (j['email'] ?? '').toString(),
    );
  }
}

class OriginalProductVm {
  final String stockCode;
  final String stockImage;
  final String grossWt;
  final String netWt;
  final String labourAmount;
  final String metalAmount;
  final String diamondWt;
  final String diamondAmount;
  final String solitaireWt;
  final String solitaireAmount;
  final String totalAmount;

  const OriginalProductVm({
    required this.stockCode,
    required this.stockImage,
    required this.grossWt,
    required this.netWt,
    required this.labourAmount,
    required this.metalAmount,
    required this.diamondWt,
    required this.diamondAmount,
    required this.solitaireWt,
    required this.solitaireAmount,
    required this.totalAmount,
  });

  factory OriginalProductVm.fromJson(Map<String, dynamic> j) {
    return OriginalProductVm(
      stockCode: (j['stock_code'] ?? '').toString(),
      stockImage: (j['stock_image'] ?? '').toString(),
      grossWt: (j['gross_wt'] ?? '').toString(),
      netWt: (j['net_wt'] ?? '').toString(),
      labourAmount: (j['labour_amount'] ?? '').toString(),
      metalAmount: (j['metal_amount'] ?? '').toString(),
      diamondWt: (j['diamond_wt'] ?? '').toString(),
      diamondAmount: (j['diamond_amount'] ?? '').toString(),
      solitaireWt: (j['solitaire_wt'] ?? '').toString(),
      solitaireAmount: (j['solitaire_amount'] ?? '').toString(),
      totalAmount: (j['total_amount'] ?? '').toString(),
    );
  }
}

class SelectedDiamondVm {
  final String id;
  final String lotNumber;
  final String shape;
  final String carat;
  final String carats;
  final String color;
  final String clarity;
  final String cut;
  final String polish;
  final String symmetry;
  final String fluorescence;
  final String cert;
  final String certNo;
  final String priceDollar;
  final String priceInr;
  final String measurement;
  final String totalDepth;
  final String tables;
  final String valueInr;

  const SelectedDiamondVm({
    required this.id,
    required this.lotNumber,
    required this.shape,
    required this.carat,
    required this.carats,
    required this.color,
    required this.clarity,
    required this.cut,
    required this.polish,
    required this.symmetry,
    required this.fluorescence,
    required this.cert,
    required this.certNo,
    required this.priceDollar,
    required this.priceInr,
    required this.measurement,
    required this.totalDepth,
    required this.tables,
    required this.valueInr,
  });

  factory SelectedDiamondVm.fromJson(Map<String, dynamic> j) {
    return SelectedDiamondVm(
      id: (j['id'] ?? '').toString(),
      lotNumber: (j['lot_number'] ?? '').toString(),
      shape: (j['shape'] ?? '').toString(),
      carat: (j['carat'] ?? '').toString(),
      carats: (j['carats'] ?? '').toString(),
      color: (j['color'] ?? '').toString(),
      clarity: (j['clarity'] ?? '').toString(),
      cut: (j['cut'] ?? '').toString(),
      polish: (j['polish'] ?? '').toString(),
      symmetry: (j['symmetry'] ?? '').toString(),
      fluorescence: (j['fluorescence'] ?? '').toString(),
      cert: (j['cert'] ?? '').toString(),
      certNo: (j['cert_no'] ?? '').toString(),
      priceDollar: (j['price_dollar'] ?? '').toString(),
      priceInr: (j['price_inr'] ?? '').toString(),
      measurement: (j['measurement'] ?? '').toString(),
      totalDepth: (j['total_depth'] ?? '').toString(),
      tables: (j['tables'] ?? '').toString(),
      valueInr: (j['value_inr'] ?? '').toString(),
    );
  }
}

class PriceCalculationVm {
  final String originalSolitaireWt;
  final String originalSolitaireAmount;
  final String originalTotalAmount;
  final String selectedDiamondWt;
  final String selectedDiamondPrice;
  final String weightDifference;
  final String priceDifference;
  final String priceDifferenceSign;
  final String finalTotalAmount;

  final List<KaratOptionVm> karatOptions;
  final bool goldRatesAvailable;
  final String currentKarat;
  final String selectedKarat;
  final String netWeight;
  final String labourAmount;
  final String diamondAmount;
  final String goldRatePerGram;
  final String goldCost;
  final String finalPriceWithKarat;
  final FinalPricingBreakdownVm finalPricingBreakdown;

  const PriceCalculationVm({
    required this.originalSolitaireWt,
    required this.originalSolitaireAmount,
    required this.originalTotalAmount,
    required this.selectedDiamondWt,
    required this.selectedDiamondPrice,
    required this.weightDifference,
    required this.priceDifference,
    required this.priceDifferenceSign,
    required this.finalTotalAmount,
    required this.karatOptions,
    required this.goldRatesAvailable,
    required this.currentKarat,
    required this.selectedKarat,
    required this.netWeight,
    required this.labourAmount,
    required this.diamondAmount,
    required this.goldRatePerGram,
    required this.goldCost,
    required this.finalPriceWithKarat,
    required this.finalPricingBreakdown,
  });

  factory PriceCalculationVm.fromJson(Map<String, dynamic> j) {
    return PriceCalculationVm(
      originalSolitaireWt: (j['original_solitaire_wt'] ?? '').toString(),
      originalSolitaireAmount: (j['original_solitaire_amount'] ?? '').toString(),
      originalTotalAmount: (j['original_total_amount'] ?? '').toString(),
      selectedDiamondWt: (j['selected_diamond_wt'] ?? '').toString(),
      selectedDiamondPrice: (j['selected_diamond_price'] ?? '').toString(),
      weightDifference: (j['weight_difference'] ?? '').toString(),
      priceDifference: (j['price_difference'] ?? '').toString(),
      priceDifferenceSign: (j['price_difference_sign'] ?? '').toString(),
      finalTotalAmount: (j['final_total_amount'] ?? '').toString(),
      karatOptions: (j['karat_options'] as List<dynamic>? ?? [])
          .map((e) => KaratOptionVm.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      goldRatesAvailable: j['gold_rates_available'] == true,
      currentKarat: (j['current_karat'] ?? '').toString(),
      selectedKarat: (j['selected_karat'] ?? '').toString(),
      netWeight: (j['net_weight'] ?? '').toString(),
      labourAmount: (j['labour_amount'] ?? '').toString(),
      diamondAmount: (j['diamond_amount'] ?? '').toString(),
      goldRatePerGram: (j['gold_rate_per_gram'] ?? '').toString(),
      goldCost: (j['gold_cost'] ?? '').toString(),
      finalPriceWithKarat: (j['final_price_with_karat'] ?? '').toString(),
      finalPricingBreakdown: FinalPricingBreakdownVm.fromJson(
        Map<String, dynamic>.from(j['final_pricing_breakdown'] ?? {}),
      ),
    );
  }
}

class KaratOptionVm {
  final String karat;
  final String goldRate;
  final String netWeight;
  final String goldCost;
  final String smallDiamonds;
  final String perCaratPrice;
  final String solitaireWeight;
  final String solitaireCost;
  final String labour;
  final String finalPrice;

  const KaratOptionVm({
    required this.karat,
    required this.goldRate,
    required this.netWeight,
    required this.goldCost,
    required this.smallDiamonds,
    required this.perCaratPrice,
    required this.solitaireWeight,
    required this.solitaireCost,
    required this.labour,
    required this.finalPrice,
  });

  factory KaratOptionVm.fromJson(Map<String, dynamic> j) {
    return KaratOptionVm(
      karat: (j['karat'] ?? '').toString(),
      goldRate: (j['gold_rate'] ?? '').toString(),
      netWeight: (j['net_weight'] ?? '').toString(),
      goldCost: (j['gold_cost'] ?? '').toString(),
      smallDiamonds: (j['small_diamonds'] ?? '').toString(),
      perCaratPrice: (j['per_carat_price'] ?? '').toString(),
      solitaireWeight: (j['solitaire_weight'] ?? '').toString(),
      solitaireCost: (j['solitaire_cost'] ?? '').toString(),
      labour: (j['labour'] ?? '').toString(),
      finalPrice: (j['final_price'] ?? '').toString(),
    );
  }
}

class FinalPricingBreakdownVm {
  final String originalTotal;
  final String originalSolitaire;
  final String newSolitaire;
  final String priceDifference;
  final String priceDifferenceSign;

  const FinalPricingBreakdownVm({
    required this.originalTotal,
    required this.originalSolitaire,
    required this.newSolitaire,
    required this.priceDifference,
    required this.priceDifferenceSign,
  });

  factory FinalPricingBreakdownVm.fromJson(Map<String, dynamic> j) {
    return FinalPricingBreakdownVm(
      originalTotal: (j['original_total'] ?? '').toString(),
      originalSolitaire: (j['original_solitaire'] ?? '').toString(),
      newSolitaire: (j['new_solitaire'] ?? '').toString(),
      priceDifference: (j['price_difference'] ?? '').toString(),
      priceDifferenceSign: (j['price_difference_sign'] ?? '').toString(),
    );
  }
}

class SolitaireComparisonVm {
  final ComparisonBeforeVm before;
  final ComparisonAfterVm after;

  const SolitaireComparisonVm({
    required this.before,
    required this.after,
  });

  factory SolitaireComparisonVm.fromJson(Map<String, dynamic> j) {
    return SolitaireComparisonVm(
      before: ComparisonBeforeVm.fromJson(
        Map<String, dynamic>.from(j['before'] ?? {}),
      ),
      after: ComparisonAfterVm.fromJson(
        Map<String, dynamic>.from(j['after'] ?? {}),
      ),
    );
  }
}

class ComparisonBeforeVm {
  final String weight;
  final String amount;

  const ComparisonBeforeVm({
    required this.weight,
    required this.amount,
  });

  factory ComparisonBeforeVm.fromJson(Map<String, dynamic> j) {
    return ComparisonBeforeVm(
      weight: (j['weight'] ?? '').toString(),
      amount: (j['amount'] ?? '').toString(),
    );
  }
}

class ComparisonAfterVm {
  final String weight;
  final String amount;
  final String lotNumber;
  final String color;
  final String clarity;
  final String cut;
  final String cert;

  const ComparisonAfterVm({
    required this.weight,
    required this.amount,
    required this.lotNumber,
    required this.color,
    required this.clarity,
    required this.cut,
    required this.cert,
  });

  factory ComparisonAfterVm.fromJson(Map<String, dynamic> j) {
    return ComparisonAfterVm(
      weight: (j['weight'] ?? '').toString(),
      amount: (j['amount'] ?? '').toString(),
      lotNumber: (j['lot_number'] ?? '').toString(),
      color: (j['color'] ?? '').toString(),
      clarity: (j['clarity'] ?? '').toString(),
      cut: (j['cut'] ?? '').toString(),
      cert: (j['cert'] ?? '').toString(),
    );
  }
}

class OrderInfoVm {
  final String orderId;
  final String orderUniqueId;
  final String orderDate;
  final String orderStatus;

  const OrderInfoVm({
    required this.orderId,
    required this.orderUniqueId,
    required this.orderDate,
    required this.orderStatus,
  });

  factory OrderInfoVm.fromJson(Map<String, dynamic> j) {
    return OrderInfoVm(
      orderId: (j['order_id'] ?? '').toString(),
      orderUniqueId: (j['order_unique_id'] ?? '').toString(),
      orderDate: (j['order_date'] ?? '').toString(),
      orderStatus: (j['order_status'] ?? '').toString(),
    );
  }
}