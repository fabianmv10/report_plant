import 'package:connectivity_plus/connectivity_plus.dart';

/// Interfaz para verificar conectividad de red
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

/// Implementación de NetworkInfo usando connectivity_plus
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final ConnectivityResult result = await connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile ||
           result == ConnectivityResult.wifi ||
           result == ConnectivityResult.ethernet;
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map((ConnectivityResult result) {
      return result == ConnectivityResult.mobile ||
             result == ConnectivityResult.wifi ||
             result == ConnectivityResult.ethernet;
    });
  }
}
