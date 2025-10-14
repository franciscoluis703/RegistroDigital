import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

/// Servicio de Anuncios con Google AdMob
/// Gestiona la carga y visualización de anuncios
class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  // ============================================
  // IDs DE ANUNCIOS - ACTUALIZAR CON TUS IDs REALES
  // ============================================

  // IDs de prueba (usar durante desarrollo)
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // IDs reales de producción - REEMPLAZAR con tus IDs de AdMob
  // TODO: Actualizar estos IDs después de crear las unidades de anuncios en AdMob
  static const String _prodBannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/BANNER_ID';
  static const String _prodInterstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/INTERSTITIAL_ID';
  static const String _prodRewardedAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/REWARDED_ID';

  // Usar IDs de prueba en debug, IDs reales en producción
  static String get bannerAdUnitId => kDebugMode ? _testBannerAdUnitId : _prodBannerAdUnitId;
  static String get interstitialAdUnitId => kDebugMode ? _testInterstitialAdUnitId : _prodInterstitialAdUnitId;
  static String get rewardedAdUnitId => kDebugMode ? _testRewardedAdUnitId : _prodRewardedAdUnitId;

  // ============================================
  // ESTADO DE ANUNCIOS
  // ============================================

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;

  int _interstitialAdCounter = 0;
  static const int _interstitialAdFrequency = 5; // Mostrar cada 5 acciones

  // ============================================
  // INICIALIZACIÓN
  // ============================================

  /// Inicializar AdMob
  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      debugPrint('✅ AdMob inicializado correctamente');

      // Precargar anuncio intersticial
      AdsService().loadInterstitialAd();
    } catch (e) {
      debugPrint('❌ Error al inicializar AdMob: $e');
    }
  }

  // ============================================
  // BANNER ADS
  // ============================================

  /// Crear y cargar anuncio banner
  BannerAd createBannerAd({
    AdSize size = AdSize.banner,
    Function()? onAdLoaded,
    Function(Ad, LoadAdError)? onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Banner ad loaded');
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Banner ad failed to load: $error');
          ad.dispose();
          onAdFailedToLoad?.call(ad, error);
        },
        onAdOpened: (ad) => debugPrint('Banner ad opened'),
        onAdClosed: (ad) => debugPrint('Banner ad closed'),
      ),
    )..load();
  }

  /// Crear banner adaptable (mejor para diferentes tamaños de pantalla)
  Future<BannerAd?> createAdaptiveBannerAd({
    required double width,
    Function()? onAdLoaded,
    Function(Ad, LoadAdError)? onAdFailedToLoad,
  }) async {
    final AdSize? size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width.truncate(),
    );

    if (size == null) {
      debugPrint('❌ No se pudo obtener el tamaño adaptable del banner');
      return null;
    }

    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Adaptive banner ad loaded');
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Adaptive banner ad failed to load: $error');
          ad.dispose();
          onAdFailedToLoad?.call(ad, error);
        },
      ),
    )..load();
  }

  // ============================================
  // INTERSTITIAL ADS
  // ============================================

  /// Cargar anuncio intersticial
  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          debugPrint('✅ Interstitial ad loaded');

          // Configurar callbacks
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('Interstitial ad showed full screen content');
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('Interstitial ad dismissed');
              ad.dispose();
              _isInterstitialAdLoaded = false;
              // Precargar el siguiente
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('❌ Interstitial ad failed to show: $error');
              ad.dispose();
              _isInterstitialAdLoaded = false;
              // Intentar cargar otro
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded = false;
          debugPrint('❌ Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  /// Mostrar anuncio intersticial
  Future<void> showInterstitialAd({bool force = false}) async {
    if (!force) {
      // Incrementar contador
      _interstitialAdCounter++;

      // Solo mostrar cada X acciones
      if (_interstitialAdCounter % _interstitialAdFrequency != 0) {
        return;
      }
    }

    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      await _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      debugPrint('⏳ Interstitial ad not ready yet, loading...');
      loadInterstitialAd();
    }
  }

  /// Resetear contador de interstitial (útil al cambiar de sección)
  void resetInterstitialCounter() {
    _interstitialAdCounter = 0;
  }

  // ============================================
  // REWARDED ADS
  // ============================================

  /// Cargar anuncio con recompensa
  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          debugPrint('✅ Rewarded ad loaded');

          // Configurar callbacks
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('Rewarded ad showed full screen content');
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('Rewarded ad dismissed');
              ad.dispose();
              _isRewardedAdLoaded = false;
              // Precargar el siguiente
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('❌ Rewarded ad failed to show: $error');
              ad.dispose();
              _isRewardedAdLoaded = false;
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          debugPrint('❌ Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  /// Mostrar anuncio con recompensa
  Future<bool> showRewardedAd() async {
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      bool rewardEarned = false;

      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('✅ User earned reward: ${reward.amount} ${reward.type}');
          rewardEarned = true;
        },
      );

      _rewardedAd = null;
      return rewardEarned;
    } else {
      debugPrint('⏳ Rewarded ad not ready yet, loading...');
      loadRewardedAd();
      return false;
    }
  }

  /// Verificar si hay anuncio con recompensa disponible
  bool get isRewardedAdReady => _isRewardedAdLoaded && _rewardedAd != null;

  // ============================================
  // UTILIDADES
  // ============================================

  /// Limpiar recursos
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
    _isInterstitialAdLoaded = false;
    _isRewardedAdLoaded = false;
  }

  /// Obtener frecuencia de interstitials
  int get interstitialFrequency => _interstitialAdFrequency;
}
