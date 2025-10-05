



import '../../domain/repositories/connectivity_repository.dart';

ConnectivityRepository get connectivityRepository =>
    ConnectivityRepositoryImpl();

class ConnectivityRepositoryImpl implements ConnectivityRepository{
  @override
  Future<bool> get hasInternet {
    return Future.value(true);
  }
}