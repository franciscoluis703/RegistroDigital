import 'package:flutter/foundation.dart';

/// Servicio de Anuncios - STUB para Web
/// AdMob no está disponible en plataforma web
/// Este archivo solo se usa cuando se compila para web
class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  /// Inicializar AdMob (no-op en web)
  static Future<void> initialize() async {
    debugPrint('ℹ️ AdMob no disponible en web - usando stub');
    // No hacer nada en web
    return;
  }

  /// Crear banner (no-op en web)
  dynamic createBannerAd({
    dynamic size,
    Function()? onAdLoaded,
    Function(dynamic, dynamic)? onAdFailedToLoad,
  }) {
    debugPrint('ℹ️ createBannerAd llamado en web - no soportado');
    return null;
  }

  /// Crear banner adaptable (no-op en web)
  Future<dynamic> createAdaptiveBannerAd({
    required double width,
    Function()? onAdLoaded,
    Function(dynamic, dynamic)? onAdFailedToLoad,
  }) async {
    debugPrint('ℹ️ createAdaptiveBannerAd llamado en web - no soportado');
    return null;
  }

  /// Cargar intersticial (no-op en web)
  Future<void> loadInterstitialAd() async {
    // No hacer nada en web
    return;
  }

  /// Mostrar intersticial (no-op en web)
  Future<void> showInterstitialAd({bool force = false}) async {
    // No hacer nada en web
    return;
  }

  /// Resetear contador (no-op en web)
  void resetInterstitialCounter() {
    // No hacer nada en web
  }

  /// Cargar rewarded (no-op en web)
  Future<void> loadRewardedAd() async {
    // No hacer nada en web
    return;
  }

  /// Mostrar rewarded (no-op en web)
  Future<bool> showRewardedAd() async {
    return false;
  }

  /// Verificar si está listo (siempre false en web)
  bool get isRewardedAdReady => false;

  /// Limpiar recursos (no-op en web)
  void dispose() {
    // No hacer nada en web
  }

  /// Frecuencia de interstitials
  int get interstitialFrequency => 5;
}
