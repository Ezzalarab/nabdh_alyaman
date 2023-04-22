// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoChecker implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;
  NetworkInfoChecker({
    required this.connectionChecker,
  });
  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
