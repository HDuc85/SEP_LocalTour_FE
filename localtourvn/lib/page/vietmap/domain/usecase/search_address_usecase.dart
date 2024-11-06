import 'package:dartz/dartz.dart';

import '../../core/failures/failure.dart';
import '../../core/use_case.dart';
import '../../data/models/vietmap_autocomplete_model.dart';
import '../../data/repository/vietmap_api_repository.dart';

class SearchAddressUseCase
    extends UseCase<List<VietmapAutocompleteModel>, String> {
  final VietmapApiRepository repository;

  SearchAddressUseCase(this.repository);
  @override
  Future<Either<Failure, List<VietmapAutocompleteModel>>> call(String params) {
    return repository.searchLocation(params);
  }
}
