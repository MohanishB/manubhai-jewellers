import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/customer_experience_models.dart';

abstract class CustomerExperienceEvent {
  const CustomerExperienceEvent();
}

class SubmitCustomerExperience extends CustomerExperienceEvent {
  final CustomerExperienceRequest request;
  const SubmitCustomerExperience(this.request);
}

class ResetCustomerExperience extends CustomerExperienceEvent {
  const ResetCustomerExperience();
}