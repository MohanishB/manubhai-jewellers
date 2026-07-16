// solitaire/presentation/widgets/step3_models.dart
class PricingRowVm {
  final String label;
  final String value;

  PricingRowVm({required this.label, required this.value});
}

//=======================================//
//=======================================//
//=======================================/

// class ComparisonVm {
//   final String title;
//   final String weight;
//   final String amount;

//   // optional extra fields for selected solitaire
//   final String? lotNumber;
//   final String? shape;
//   final String? color;
//   final String? clarity;
//   final String? cut;
//   final String? cert;
//   final String? certNo;

//   ComparisonVm({
//     required this.title,
//     required this.weight,
//     required this.amount,
//     this.lotNumber,
//     this.shape,
//     this.color,
//     this.clarity,
//     this.cut,
//     this.cert,
//     this.certNo,
//   });
// }

//=======================================//
//=======================================//
//=======================================//

class ComparisonVm {
  final String title;
  final String? lotNumber;
  final String weight;
  final String amount;
  final String? shape;
  final String? color;
  final String? clarity;
  final String? cut;
  final String? cert;
  final String? certNo;
  final bool showAmount;

  const ComparisonVm({
    required this.title,
    this.lotNumber,
    required this.weight,
    required this.amount,
    this.shape,
    this.color,
    this.clarity,
    this.cut,
    this.cert,
    this.certNo,
    this.showAmount = true,
  });
}