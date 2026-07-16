import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/customer_experience_models.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/CSE_repo/customer_experience_repository.dart';
import 'customer_experience_state.dart';
import 'customer_experience_event.dart';








class CustomerExperienceBloc
    extends Bloc<CustomerExperienceEvent, CustomerExperienceState> {
  final CustomerExperienceRepository repo;

  CustomerExperienceBloc({required this.repo})
      : super(const CustomerExperienceInitial()) {
    on<SubmitCustomerExperience>(_onSubmit);
    on<ResetCustomerExperience>((event, emit) => emit(const CustomerExperienceInitial()));
  }

  Future<void> _onSubmit(
    SubmitCustomerExperience event,
    Emitter<CustomerExperienceState> emit,
  ) async {
    emit(const CustomerExperienceLoading());
    try {
      await repo.submit(event.request);
      emit(const CustomerExperienceSuccess());
    } catch (e) {
      emit(CustomerExperienceError(
        ApiErrorHandler.message(e),
      ));
    }
  }
}
