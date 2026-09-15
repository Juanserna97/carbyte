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
  @override String get detectedProtocols => 'CAPACIDADES DEL PROTOCOLO DETECTADO';
  @override String get mode03Read => 'Lectura DTC (Mode 03)';
  @override String get mode04Clear => 'Borrado DTC (Mode 04)';
  @override String get mode01Telemetry => 'Telemetría PIDs (Mode 01)';
  @override String get mode09Vin => 'Lectura VIN (Mode 09)';
  @override String get mode02FreezeFrame => 'Freeze Frame (Mode 02)';
  @override String get ecuCoding => 'ECU Coding';
  @override String get workshopAdaptations => 'Adaptaciones de Taller';

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
}
