import 'app_strings.dart';

class SpanishStrings implements AppStrings {
  const SpanishStrings();

  // Common
  @override String get connected => 'CONECTADO';
  @override String get disconnected => 'DESCONECTADO';
  @override String get cancel => 'Cancelar';
  @override String get accept => 'Aceptar';
  @override String get save => 'Guardar';
  @override String get back => 'Atrás';
  @override String get search => 'Buscar';
  @override String get loading => 'Cargando...';

  // Navigation
  @override String get navHistory => 'Historial';
  @override String get navAdapter => 'Adaptador';
  @override String get navSettings => 'Ajustes';
  @override String get navHome => 'Inicio';
  @override String get navDiagnostics => 'Diagnóstico';
  @override String get navLiveData => 'En Vivo';

  // Home Screen
  @override String get vehicleDisconnectedTitle => 'Vehículo Desconectado';
  @override String get vehicleDisconnectedSubtitle => 'Sin comunicación con puerto OBD-II';
  @override String get vehicleStandbyProtocol => 'OBD-II (En espera)';
  @override String get vehicleVinNotDetected => 'VIN: No detectado';
  @override String get connectionRequiredTitle => 'VEHÍCULO DESCONECTADO';
  @override String get connectionRequiredSubtitleMock => 'Toca conectar para enlazar el simulador e iniciar telemetría.';
  @override String get connectionRequiredSubtitleReal => 'Enlaza tu adaptador OBD-II Bluetooth para leer datos reales.';
  @override String get btnConnectObd => 'CONECTAR A DISPOSITIVO OBD';
  @override String get btnSimulateTelemetry => 'SIMULAR TELEMETRÍA';
  @override String get activeIssuesTitle => 'CÓDIGOS DE FALLA ACTIVOS';
  @override String get noActiveIssues => 'Ninguno';
  @override String get liveTelemetryTitle => 'TELEMETRÍA EN DIRECTO';
  @override String get fullScreen => 'PANTALLA COMPLETA';
  @override String get rpmMotor => 'RPM MOTOR';
  @override String get speedKmH => 'VELOCIDAD';
  @override String get coolant => 'REFRIGERANTE';
  @override String get battery => 'BATERÍA';
  @override String get btnScanVehicle => 'ESCANEAR VEHÍCULO';
  @override String get btnTelemetryDashboard => 'TABLERO DE TELEMETRÍA';
  @override String get btnDisconnectVehicle => 'DESCONECTAR VEHÍCULO';

  // Connection Screen
  @override String get connectionScreenTitle => 'ENLACE OBD-II / BLE';
  @override String get adapterLinked => 'ADAPTADOR VINCULADO';
  @override String get searchingDevices => 'BUSCANDO DISPOSITIVOS...';
  @override String get linkActiveStable => 'Comunicación CAN 11/500 kbps activa y estable (Latencia: 14ms)';
  @override String get ensureAdapterPlugged => 'Asegúrate de que el adaptador esté enchufado al puerto OBD del auto.';
  @override String get quickConnectAuto => 'CONEXIÓN AUTOMÁTICA';
  @override String get searchingObdSnack => 'Buscando dispositivos OBD...';
  @override String get connectedSuccessSnack => 'Conectado exitosamente';
  @override String get availableDevices => 'DISPOSITIVOS DISPONIBLES';
  @override String get detectedProtocols => 'FUNCIONES DEL ESCÁNER';
  @override String get detectedProtocolsSubtitle => 'Capacidades de diagnóstico disponibles con este adaptador';
  @override String get mode03Read => 'Leer Fallas de Motor';
  @override String get mode04Clear => 'Borrar Check Engine';
  @override String get mode01Telemetry => 'Sensores en Tiempo Real';
  @override String get mode09Vin => 'Detectar VIN / Auto';
  @override String get mode02FreezeFrame => 'Foto de Falla (Freeze Frame)';
  @override String get ecuCoding => 'Reprogramación ECU';
  @override String get workshopAdaptations => 'Ajustes de Taller Pro';

  // Diagnostics Screen
  @override String get diagnosticsTitle => 'DIAGNÓSTICO OBD-II';
  @override String get systemDiagnostic => 'DIAGNÓSTICO DEL SISTEMA';
  @override String get scanVehicleDescription => 'Escaneo completo de módulos ECU, transmisión, frenos y tren motriz.';
  @override String get startFullScan => 'INICIAR ESCANEO COMPLETO';
  @override String get clearingDtc => 'Borrando códigos DTC...';
  @override String get clearDtcCodes => 'BORRAR CÓDIGOS DE FALLA';
  @override String get scanningProgress => 'Escaneando módulos de control...';
  @override String get issuesFound => 'fallas detectadas';
  @override String get clearDtcConfirmTitle => '¿Borrar códigos de falla?';
  @override String get clearDtcConfirmDesc => 'Esto apagará la luz Check Engine (MIL) y restablecerá los monitores de emisiones.';
  @override String get clearSuccessSnack => 'Códigos DTC borrados de la ECU correctamente';

  // Live Data Screen
  @override String get telemetryTitle => 'TELEMETRÍA EN VIVO';
  @override String get tachometer => 'TACÓMETRO';
  @override String get speedGauge => 'VELOCIDAD';
  @override String get realTimeRpmCurve => 'CURVA DE RPM EN TIEMPO REAL';
  @override String get engineParametersPids => 'PARÁMETROS DEL MOTOR (PIDs)';
  @override String get coolantTempSensor => 'TEMPERATURA REFRIGERANTE';
  @override String get engineLoadSensor => 'CARGA DE MOTOR (LOAD)';
  @override String get throttlePosSensor => 'POSICIÓN ACELERADOR';
  @override String get alternatorVoltSensor => 'VOLTAJE ALTERNADOR';
  @override String get intakeAirSensor => 'AIRE DE ADMISIÓN (IAT)';
  @override String get massAirFlowSensor => 'FLUJO DE MASA (MAF)';
  @override String get turboBoostSensor => 'PRESIÓN TURBO';
  @override String get boostActive => 'BOOST ACTIVO';
  @override String get statusNormal => 'NORMAL';
  @override String get statusHigh => 'ALTA';
  @override String get statusOptimal => 'ÓPTIMO';
  @override String get statusLow => 'BAJO';

  // Settings Screen
  @override String get settingsTitle => 'CONFIGURACIÓN';
  @override String get vehicleProfile => 'Perfil activo: Piloto Principal';
  @override String get systemPreferences => 'PREFERENCIAS DEL SISTEMA';
  @override String get languageOption => 'Idioma de la Aplicación';
  @override String get languageOptionSubtitle => 'Detección automática del sistema o selección manual';
  @override String get metricUnits => 'Unidades Métricas';
  @override String get metricUnitsSubtitle => 'km/h, °C, bar, kPa';
  @override String get mockMode => 'Modo Simulador (Mock OBD)';
  @override String get mockModeSubtitle => 'Genera telemetría y fallas realistas para pruebas';
  @override String get fastPolling => 'Muestreo de Alta Frecuencia';
  @override String get fastPollingSubtitle => 'Actualización rápida de PIDs a 10 Hz';
  @override String get hardwareCommunication => 'HARDWARE Y COMUNICACIÓN';
  @override String get savedAdapters => 'Adaptadores OBD Guardados';
  @override String get diagnosticProtocol => 'Protocolo de Diagnóstico';
  @override String get information => 'INFORMACIÓN';
  @override String get aboutCarbyte => 'Acerca de CARBYTE';
  @override String get termsPrivacy => 'Términos y Privacidad';
  @override String get selectLanguageTitle => 'Seleccionar Idioma';

  // Onboarding
  @override String get onboardingTitle1 => 'Ubica el Puerto OBD2';
  @override String get onboardingDesc1 => 'Es un conector trapezoidal de 16 pines que comunica con la computadora central (ECU) del auto.';
  @override String get onboardingTip1 => 'Ubicación común: Debajo del volante, cerca a la palanca del capó o fusiblera.';
  @override String get onboardingTitle2 => 'Enchufa el Escáner';
  @override String get onboardingDesc2 => 'Presiona el adaptador firmemente hasta el fondo. Observarás que se enciende su luz LED.';
  @override String get onboardingTip2 => 'Si el LED no enciende, asegúrate de empujarlo con firmeza en el zócalo.';
  @override String get onboardingTitle3 => 'Pon el Auto en Contacto (ON)';
  @override String get onboardingDesc3 => 'Gira la llave a posición ON o presiona el botón START sin tocar el pedal de freno.';
  @override String get onboardingTip3 => 'Importante: Las luces del tablero deben prenderse para alimentar la computadora.';
  @override String get onboardingTitle4 => 'Empareja por Bluetooth';
  @override String get onboardingDesc4 => 'CARBYTE detectará tu escáner automáticamente para transmitir telemetría y diagnósticos en tiempo real.';
  @override String get onboardingTip4 => 'Asegúrate de que el Bluetooth de tu teléfono esté activo.';
  @override String get getStartedBtn => 'COMENZAR AHORA';
  @override String get skipBtn => 'OMITIR';
  @override String get nextBtn => 'CONTINUAR';
  @override String get connectScannerNow => 'CONECTAR ESCÁNER AHORA';
  @override String get exploreAppFirst => 'Explorar la app primero';
  @override String get stepText => 'PASO';

  // Additional Localized Badges and Strings
  @override String get healthBadge => 'SALUD';
  @override String get liveStreamBadge => 'EN VIVO';
  @override String get recommendedBadge => 'RECOMENDADO';
  @override String get connectedToDeviceSnack => 'Conectado exitosamente con';
  @override String get connectionErrorSnack => 'Error al conectar con';
  @override String get noDeviceFoundSnack => 'No se detectó ningún escáner OBD Bluetooth cercano. Verifica que esté conectado y en ON.';
  @override String get unknownDevice => 'Dispositivo Desconocido';
  @override String get termsPrivacySubtitle => 'Seguridad, privacidad y descargo legal';
  @override String get aboutSubtitle => 'Versión 1.0.0 (Fase 2)';
  @override String get onboardingBadge1 => 'PUERTO OBD-II 16-PIN';
  @override String get onboardingBadge2 => 'ENLACE DE HARDWARE';
  @override String get onboardingBadge3 => 'CONTACTO / ECU EN ON';
  @override String get onboardingBadge4 => 'TELEMETRÍA BLE';
  @override String get onboardingDlc => 'CONECTOR DE DIAGNÓSTICO (DLC)';
  @override String get onboardingPwrLed => 'LED DE ALIMENTACIÓN (12V)';
  @override String get onboardingIgnitionOn => 'CONTACTO EN ON / BUS 12V';
  @override String get onboardingReadyToPair => 'LISTO PARA ENLAZAR';
  @override String get termsTitle => 'Términos y Privacidad';
  @override String get termsSection1Title => 'Conducción Segura y Distracciones';
  @override String get termsSection1Desc => 'Nunca manipules CARBYTE mientras conduces. Configura tu escáner y la telemetría antes de iniciar la marcha o con el vehículo detenido de forma segura en un lugar permitido.';
  @override String get termsSection2Title => 'Puerto OBD-II y Compatibilidad';
  @override String get termsSection2Desc => 'CARBYTE interactúa con la ECU mediante protocolos OBD-II estándar (ISO 15765-4, SAE J1850, ISO 9141). No nos hacemos responsables por fallos o consumos de batería ocasionados por adaptadores BLE defectuosos de terceros.';
  @override String get termsSection3Title => 'Privacidad de Datos Vehiculares';
  @override String get termsSection3Desc => 'Tus datos de telemetría (VIN, velocidades, códigos de falla DTC y rendimiento) se procesan 100% de manera local en tu teléfono. No vendemos ni compartimos tu información con compañías de seguros ni terceros.';
  @override String get termsSection4Title => 'Diagnósticos y Reparaciones';
  @override String get termsSection4Desc => 'Los códigos de falla (DTC) y sugerencias de diagnóstico son exclusivamente informativos. Siempre valida los resultados con un técnico automotriz certificado antes de reemplazar componentes mecánicos.';
  @override String get understoodBtn => 'ENTENDIDO';

  // History Management
  @override String get clearHistoryTooltip => 'Borrar historial';
  @override String get clearHistoryConfirmTitle => '¿Borrar Historial?';
  @override String get clearHistoryConfirmDesc => '¿Estás seguro de que deseas eliminar todos los reportes de diagnóstico? Esta acción no se puede deshacer.';
  @override String get clearHistoryBtn => 'BORRAR HISTORIAL';
  @override String get emptyHistoryTitle => 'Sin Historial de Diagnósticos';
  @override String get emptyHistoryDesc => 'Los escaneos que realices a tu vehículo se guardarán aquí automáticamente para su consulta.';
  @override String get historyStatusResolved => 'Resuelto';
  @override String get historyStatusAttention => 'Atención Requerida';
  @override String get historyStatusHealthy => 'Saludable';
  @override String get historyClearedSnack => 'Historial de diagnósticos eliminado con éxito.';
  @override String get historyRecordDeletedSnack => 'Registro eliminado.';

  // PDF Export & Diagnostics
  @override String get exportPdfReportBtn => 'EXPORTAR REPORTE COMPLETO A PDF';
  @override String get exportPdfTooltip => 'Exportar reporte en PDF';
  @override String get generatingPdfSnack => 'Generando reporte formal en PDF...';
  @override String get smogCheckTitle => 'TEST DE EMISIONES';
  @override String get smogCheckPassed => 'APROBADO';
  @override String get smogCheckFailed => 'NO LISTO';
  @override String get smogCheckSubtitle => 'Monitores de emisión de gases y preparación técnico-mecánica';
  @override String get dtcProbableCausesTitle => 'Causas Más Probables';
  @override String get dtcSymptomsTitle => 'Síntomas Comunes';
  @override String get dtcRecommendedActionTitle => 'Acción Sugerida de Reparación';
}
