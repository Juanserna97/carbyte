enum AppLanguage {
  auto,
  es,
  en;

  String get displayName {
    switch (this) {
      case AppLanguage.auto:
        return 'Automático (Dispositivo)';
      case AppLanguage.es:
        return 'Español';
      case AppLanguage.en:
        return 'English';
    }
  }

  String displayNameIn(AppLanguage current) {
    switch (this) {
      case AppLanguage.auto:
        return current == AppLanguage.en ? 'Automatic (Device)' : 'Automático (Dispositivo)';
      case AppLanguage.es:
        return 'Español';
      case AppLanguage.en:
        return 'English';
    }
  }
}
