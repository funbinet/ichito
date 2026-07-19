/// Complete AppSettings entity model for all app configurations.
/// 
/// This model represents all user-configurable settings across all 9 sections:
/// 1. Profile (managed separately)
/// 2. Appearance (Theme)
/// 3. Language & Format (Localization)
/// 4. Security (App Lock)
/// 5. Preferences (User Preferences)
/// 6. Business (Business Configuration)
/// 7. Storage (managed by services)
/// 8. Advanced (Performance & Debug)
/// 9. Help & About (no settings)
class AppSettings {
  // ─── Appearance Settings ────────────────────────────────────────
  final String themeMode; // 'amoledDark', 'dark', 'light', 'system'
  final int? accentColor; // Color value as int
  final String cornerStyle; // 'rounded', 'sharp', 'pill', etc.
  final String fontFamily; // 'Roboto', 'Poppins', etc.
  final double fontSize; // 12.0 - 24.0
  final bool enableShadows;
  final double shadowIntensity; // 0.0 - 1.0
  final int? gradientId; // ID of selected gradient (null = no gradient)

  // ─── Language & Format Settings ─────────────────────────────────
  final String language; // 'english', 'sheng'
  final String measurementUnit; // 'cm', 'inches'
  final String currency; // 'KES', 'USD', 'EUR', 'GBP', 'TZS', 'UGX'
  final String dateFormat; // 'DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'

  // ─── Security Settings ──────────────────────────────────────────
  final bool appLockEnabled;
  final String lockType; // 'pin', 'biometric'
  final String? appPin; // Hashed/encrypted PIN
  final bool biometricEnabled;
  final int autoLockMinutes; // 0=immediately, -1=never, 5=default
  final bool encryptionEnabled;

  // ─── Preferences Settings ───────────────────────────────────────
  final String defaultView; // 'grid', 'list'
  final int gridDensity; // 4, 8, 16, 32 items per row
  final bool autoSaveNotes;
  final int autoSaveIntervalSeconds; // 1, 3, 5, 10
  final bool hapticFeedbackEnabled;
  final bool confirmDeletions;
  final bool showOrderNumberOnCards;
  final String defaultCustomerSort; // 'name', 'orders', 'spent', 'recent'
  final String defaultOrderSort; // 'date', 'due', 'amount', 'status'
  final String defaultNoteSort; // 'newest', 'oldest', 'title'

  // ─── Business Settings ──────────────────────────────────────────
  final String businessName;
  final String businessLocation;
  final String businessPhone;
  final String businessEmail;
  final double defaultLaborCost; // In the selected currency
  final double taxRate; // 0.0 - 100.0, 0 = disabled
  final String orderPrefix; // 'ICHITO', or custom

  // ─── Advanced Settings ──────────────────────────────────────────
  final bool performanceMode; // Disables animations on older devices
  final bool debugLoggingEnabled;

  // ─── System / Derived Settings ──────────────────────────────────
  final bool onboardingComplete;
  final List<String> measurementSchema; // Custom measurement fields

  const AppSettings({
    // Appearance
    this.themeMode = 'amoledDark',
    this.accentColor,
    this.cornerStyle = 'rounded',
    this.fontFamily = 'Roboto',
    this.fontSize = 16.0,
    this.enableShadows = true,
    this.shadowIntensity = 0.15,
    this.gradientId,

    // Language & Format
    this.language = 'english',
    this.measurementUnit = 'cm',
    this.currency = 'KES',
    this.dateFormat = 'DD/MM/YYYY',

    // Security
    this.appLockEnabled = false,
    this.lockType = 'pin',
    this.appPin,
    this.biometricEnabled = false,
    this.autoLockMinutes = 5,
    this.encryptionEnabled = false,

    // Preferences
    this.defaultView = 'grid',
    this.gridDensity = 8,
    this.autoSaveNotes = true,
    this.autoSaveIntervalSeconds = 3,
    this.hapticFeedbackEnabled = true,
    this.confirmDeletions = true,
    this.showOrderNumberOnCards = true,
    this.defaultCustomerSort = 'name',
    this.defaultOrderSort = 'date',
    this.defaultNoteSort = 'newest',

    // Business
    this.businessName = '',
    this.businessLocation = '',
    this.businessPhone = '',
    this.businessEmail = '',
    this.defaultLaborCost = 1500.0,
    this.taxRate = 0.0,
    this.orderPrefix = 'ICHITO',

    // Advanced
    this.performanceMode = false,
    this.debugLoggingEnabled = false,

    // System
    this.onboardingComplete = false,
    this.measurementSchema = const [],
  });

  /// Creates a copy with modified fields.
  AppSettings copyWith({
    String? themeMode,
    int? accentColor,
    String? cornerStyle,
    String? fontFamily,
    double? fontSize,
    bool? enableShadows,
    double? shadowIntensity,
    int? gradientId,
    String? language,
    String? measurementUnit,
    String? currency,
    String? dateFormat,
    bool? appLockEnabled,
    String? lockType,
    String? appPin,
    bool? biometricEnabled,
    int? autoLockMinutes,
    bool? encryptionEnabled,
    String? defaultView,
    int? gridDensity,
    bool? autoSaveNotes,
    int? autoSaveIntervalSeconds,
    bool? hapticFeedbackEnabled,
    bool? confirmDeletions,
    bool? showOrderNumberOnCards,
    String? defaultCustomerSort,
    String? defaultOrderSort,
    String? defaultNoteSort,
    String? businessName,
    String? businessLocation,
    String? businessPhone,
    String? businessEmail,
    double? defaultLaborCost,
    double? taxRate,
    String? orderPrefix,
    bool? performanceMode,
    bool? debugLoggingEnabled,
    bool? onboardingComplete,
    List<String>? measurementSchema,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      cornerStyle: cornerStyle ?? this.cornerStyle,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      enableShadows: enableShadows ?? this.enableShadows,
      shadowIntensity: shadowIntensity ?? this.shadowIntensity,
      gradientId: gradientId ?? this.gradientId,
      language: language ?? this.language,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      lockType: lockType ?? this.lockType,
      appPin: appPin ?? this.appPin,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      encryptionEnabled: encryptionEnabled ?? this.encryptionEnabled,
      defaultView: defaultView ?? this.defaultView,
      gridDensity: gridDensity ?? this.gridDensity,
      autoSaveNotes: autoSaveNotes ?? this.autoSaveNotes,
      autoSaveIntervalSeconds: autoSaveIntervalSeconds ?? this.autoSaveIntervalSeconds,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      confirmDeletions: confirmDeletions ?? this.confirmDeletions,
      showOrderNumberOnCards: showOrderNumberOnCards ?? this.showOrderNumberOnCards,
      defaultCustomerSort: defaultCustomerSort ?? this.defaultCustomerSort,
      defaultOrderSort: defaultOrderSort ?? this.defaultOrderSort,
      defaultNoteSort: defaultNoteSort ?? this.defaultNoteSort,
      businessName: businessName ?? this.businessName,
      businessLocation: businessLocation ?? this.businessLocation,
      businessPhone: businessPhone ?? this.businessPhone,
      businessEmail: businessEmail ?? this.businessEmail,
      defaultLaborCost: defaultLaborCost ?? this.defaultLaborCost,
      taxRate: taxRate ?? this.taxRate,
      orderPrefix: orderPrefix ?? this.orderPrefix,
      performanceMode: performanceMode ?? this.performanceMode,
      debugLoggingEnabled: debugLoggingEnabled ?? this.debugLoggingEnabled,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      measurementSchema: measurementSchema ?? this.measurementSchema,
    );
  }

  @override
  String toString() => 'AppSettings('
      'themeMode=$themeMode, accentColor=$accentColor, cornerStyle=$cornerStyle, '
      'fontFamily=$fontFamily, fontSize=$fontSize, enableShadows=$enableShadows, '
      'shadowIntensity=$shadowIntensity, language=$language, '
      'measurementUnit=$measurementUnit, currency=$currency, dateFormat=$dateFormat, '
      'appLockEnabled=$appLockEnabled, biometricEnabled=$biometricEnabled, '
      'autoLockMinutes=$autoLockMinutes, defaultView=$defaultView, '
      'gridDensity=$gridDensity, hapticFeedbackEnabled=$hapticFeedbackEnabled, '
      'businessName=$businessName, businessLocation=$businessLocation, '
      'orderPrefix=$orderPrefix, performanceMode=$performanceMode'
      ')';
}
