import 'app_strings.dart';

class EnglishStrings implements AppStrings {
  const EnglishStrings();

  // Common
  @override String get connected => 'CONNECTED';
  @override String get disconnected => 'DISCONNECTED';
  @override String get cancel => 'Cancel';
  @override String get accept => 'Accept';
  @override String get save => 'Save';
  @override String get back => 'Back';
  @override String get search => 'Search';
  @override String get loading => 'Loading...';

  // Navigation
  @override String get navHistory => 'History';
  @override String get navAdapter => 'Adapter';
  @override String get navSettings => 'Settings';
  @override String get navHome => 'Home';
  @override String get navDiagnostics => 'Diagnostics';
  @override String get navLiveData => 'Live Data';

  // Home Screen
  @override String get vehicleDisconnectedTitle => 'Vehicle Disconnected';
  @override String get vehicleDisconnectedSubtitle => 'No communication with OBD-II port';
  @override String get vehicleStandbyProtocol => 'OBD-II (Standby)';
  @override String get vehicleVinNotDetected => 'VIN: Not detected';
  @override String get connectionRequiredTitle => 'VEHICLE DISCONNECTED';
  @override String get connectionRequiredSubtitleMock => 'Tap connect to link simulator and start streaming telemetry.';
  @override String get connectionRequiredSubtitleReal => 'Link your Bluetooth OBD-II adapter to read live vehicle data.';
  @override String get btnConnectObd => 'CONNECT OBD DEVICE';
  @override String get btnSimulateTelemetry => 'SIMULATE TELEMETRY';
  @override String get activeIssuesTitle => 'ACTIVE FAULT CODES';
  @override String get noActiveIssues => 'None';
  @override String get liveTelemetryTitle => 'LIVE TELEMETRY';
  @override String get fullScreen => 'FULL SCREEN';
  @override String get rpmMotor => 'ENGINE RPM';
  @override String get speedKmH => 'SPEED';
  @override String get coolant => 'COOLANT';
  @override String get battery => 'BATTERY';
  @override String get btnScanVehicle => 'SCAN VEHICLE';
  @override String get btnTelemetryDashboard => 'TELEMETRY DASHBOARD';
  @override String get btnDisconnectVehicle => 'DISCONNECT VEHICLE';

  // Connection Screen
  @override String get connectionScreenTitle => 'OBD-II / BLE LINK';
  @override String get adapterLinked => 'ADAPTER LINKED';
  @override String get searchingDevices => 'SEARCHING FOR DEVICES...';
  @override String get linkActiveStable => 'CAN 11/500 kbps communication active and stable (Latency: 14ms)';
  @override String get ensureAdapterPlugged => 'Ensure the OBD adapter is firmly plugged into the car port.';
  @override String get quickConnectAuto => 'AUTO CONNECT';
  @override String get searchingObdSnack => 'Scanning for nearby OBD devices...';
  @override String get connectedSuccessSnack => 'Successfully connected';
  @override String get availableDevices => 'AVAILABLE DEVICES';
  @override String get detectedProtocols => 'DETECTED PROTOCOL CAPABILITIES';
  @override String get mode03Read => 'DTC Reading (Mode 03)';
  @override String get mode04Clear => 'DTC Clearing (Mode 04)';
  @override String get mode01Telemetry => 'PID Telemetry (Mode 01)';
  @override String get mode09Vin => 'VIN Reading (Mode 09)';
  @override String get mode02FreezeFrame => 'Freeze Frame (Mode 02)';
  @override String get ecuCoding => 'ECU Coding';
  @override String get workshopAdaptations => 'Workshop Adaptations';

  // Diagnostics Screen
  @override String get diagnosticsTitle => 'OBD-II DIAGNOSTICS';
  @override String get systemDiagnostic => 'SYSTEM DIAGNOSTICS';
  @override String get scanVehicleDescription => 'Full scan of ECU modules, transmission, ABS brakes, and powertrain.';
  @override String get startFullScan => 'START FULL SCAN';
  @override String get clearingDtc => 'Clearing fault codes...';
  @override String get clearDtcCodes => 'CLEAR FAULT CODES';
  @override String get scanningProgress => 'Scanning control modules...';
  @override String get issuesFound => 'issues detected';
  @override String get clearDtcConfirmTitle => 'Clear fault codes?';
  @override String get clearDtcConfirmDesc => 'This will turn off the Check Engine Light (MIL) and reset emission monitors.';
  @override String get clearSuccessSnack => 'DTC codes cleared from ECU successfully';

  // Live Data Screen
  @override String get telemetryTitle => 'LIVE TELEMETRY';
  @override String get tachometer => 'TACHOMETER';
  @override String get speedGauge => 'SPEED';
  @override String get realTimeRpmCurve => 'REAL-TIME RPM CURVE';
  @override String get engineParametersPids => 'ENGINE PARAMETERS (PIDs)';
  @override String get coolantTempSensor => 'COOLANT TEMP';
  @override String get engineLoadSensor => 'ENGINE LOAD';
  @override String get throttlePosSensor => 'THROTTLE POSITION';
  @override String get alternatorVoltSensor => 'ALTERNATOR VOLTAGE';
  @override String get intakeAirSensor => 'INTAKE AIR (IAT)';
  @override String get massAirFlowSensor => 'MASS AIR FLOW (MAF)';
  @override String get turboBoostSensor => 'TURBO BOOST';
  @override String get boostActive => 'BOOST ACTIVE';
  @override String get statusNormal => 'NORMAL';
  @override String get statusHigh => 'HIGH';
  @override String get statusOptimal => 'OPTIMAL';
  @override String get statusLow => 'LOW';

  // Settings Screen
  @override String get settingsTitle => 'SETTINGS';
  @override String get vehicleProfile => 'Active Profile: Primary Driver';
  @override String get systemPreferences => 'SYSTEM PREFERENCES';
  @override String get languageOption => 'Application Language';
  @override String get languageOptionSubtitle => 'Automatic device language or manual selection';
  @override String get metricUnits => 'Metric Units';
  @override String get metricUnitsSubtitle => 'km/h, °C, bar, kPa';
  @override String get mockMode => 'Simulator Mode (Mock OBD)';
  @override String get mockModeSubtitle => 'Simulates realistic telemetry and DTCs for testing';
  @override String get fastPolling => 'High-Frequency Polling';
  @override String get fastPollingSubtitle => 'Rapid 10 Hz PID refresh rate';
  @override String get hardwareCommunication => 'HARDWARE & COMMUNICATION';
  @override String get savedAdapters => 'Saved OBD Adapters';
  @override String get diagnosticProtocol => 'Diagnostic Protocol';
  @override String get information => 'INFORMATION';
  @override String get aboutCarbyte => 'About CARBYTE';
  @override String get termsPrivacy => 'Terms & Privacy';
  @override String get selectLanguageTitle => 'Select Language';
}
