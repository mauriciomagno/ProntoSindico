import 'package:prontosindico/domain/entities/resident.dart';

class ResidentsState {
  final bool isLoading;
  final List<Resident> residents;
  final String? error;

  const ResidentsState({
    this.isLoading = false,
    this.residents = const [],
    this.error,
  });

  ResidentsState copyWith({
    bool? isLoading,
    List<Resident>? residents,
    String? error,
  }) {
    return ResidentsState(
      isLoading: isLoading ?? this.isLoading,
      residents: residents ?? this.residents,
      error: error ?? this.error,
    );
  }
}
