// ---------- States ----------
abstract class CustomerExperienceState {
  const CustomerExperienceState();
}

class CustomerExperienceInitial extends CustomerExperienceState {
  const CustomerExperienceInitial();
}

class CustomerExperienceLoading extends CustomerExperienceState {
  const CustomerExperienceLoading();
}

class CustomerExperienceSuccess extends CustomerExperienceState {
  const CustomerExperienceSuccess();
}

class CustomerExperienceError extends CustomerExperienceState {
  final String message;
  const CustomerExperienceError(this.message);
}