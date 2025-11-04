import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../network/network_info.dart';
import '../utils/logger.dart';

/// Banner que muestra el estado de conectividad
/// Se muestra automáticamente cuando no hay conexión
class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  final NetworkInfo networkInfo;

  const ConnectivityBanner({
    super.key,
    required this.child,
    required this.networkInfo,
  });

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _isConnected = true;
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _listenToConnectivityChanges();
  }

  Future<void> _checkInitialConnection() async {
    final isConnected = await widget.networkInfo.isConnected;
    setState(() {
      _isConnected = isConnected;
      _showBanner = !isConnected;
    });
  }

  void _listenToConnectivityChanges() {
    widget.networkInfo.onConnectivityChanged.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
      });

      if (!isConnected && !_showBanner) {
        // Perdió conexión
        setState(() => _showBanner = true);
        logger.warning('Conexión perdida');
      } else if (isConnected && _showBanner) {
        // Recuperó conexión
        logger.info('Conexión recuperada');
        _showReconnectedSnackBar();

        // Ocultar banner después de un momento
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _showBanner = false);
          }
        });
      }
    });
  }

  void _showReconnectedSnackBar() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Conexión restaurada'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _showBanner ? 40 : 0,
          child: _showBanner
              ? Container(
                  width: double.infinity,
                  color: _isConnected ? Colors.green : Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        _isConnected
                            ? Icons.cloud_done
                            : Icons.cloud_off,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isConnected
                              ? 'Conexión restaurada'
                              : 'Sin conexión - Modo offline',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
