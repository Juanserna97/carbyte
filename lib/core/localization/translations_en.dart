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
  @override String get detectedProtocols => 'SCANNER CAPABILITIES';
  @override String get detectedProtocolsSubtitle => 'Diagnostic features supported by this adapter';
  @override String get mode03Read => 'Read Engine Faults';
  @override String get mode04Clear => 'Clear Check Engine';
  @override String get mode01Telemetry => 'Live Engine Sensors';
  @override String get mode09Vin => 'Detect VIN / Vehicle';
  @override String get mode02FreezeFrame => 'Fault Snapshot (Freeze Frame)';
  @override String get ecuCoding => 'ECU Tuning / Coding';
  @override String get workshopAdaptations => 'Pro Workshop Resets';

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

  // Onboarding
  @override String get onboardingTitle1 => 'Locate the OBD2 Port';
  @override String get onboardingDesc1 => 'A 16-pin trapezoidal diagnostic socket that connects directly to the vehicle\'s ECU.';
  @override String get onboardingTip1 => 'Common spot: Under the steering column, near hood release or fuse panel.';
  @override String get onboardingTitle2 => 'Plug in the Scanner';
  @override String get onboardingDesc2 => 'Press the adapter firmly into the port. A power LED will illuminate.';
  @override String get onboardingTip2 => 'If no LED turns on, ensure the plug is seated all the way into the socket.';
  @override String get onboardingTitle3 => 'Turn Ignition ON';
  @override String get onboardingDesc3 => 'Switch key to ON position or press START without depressing the brake pedal.';
  @override String get onboardingTip3 => 'Dashboard gauge lights must be active so the ECU can communicate.';
  @override String get onboardingTitle4 => 'Pair via Bluetooth';
  @override String get onboardingDesc4 => 'CARBYTE scans and connects automatically to begin live telemetry and diagnostics.';
  @override String get onboardingTip4 => 'Ensure your phone\'s Bluetooth is enabled.';
  @override String get getStartedBtn => 'GET STARTED';
  @override String get skipBtn => 'SKIP';
  @override String get nextBtn => 'CONTINUE';
  @override String get connectScannerNow => 'CONNECT SCANNER NOW';
  @override String get exploreAppFirst => 'Explore app first';
  @override String get stepText => 'STEP';

  // Additional Localized Badges and Strings
  @override String get healthBadge => 'HEALTH';
  @override String get liveStreamBadge => 'LIVE STREAM';
  @override String get recommendedBadge => 'RECOMMENDED';
  @override String get connectedToDeviceSnack => 'Successfully connected to';
  @override String get connectionErrorSnack => 'Failed to connect to';
  @override String get noDeviceFoundSnack => 'No nearby Bluetooth OBD scanner detected. Ensure it is plugged in with ignition ON.';
  @override String get unknownDevice => 'Unknown Device';
  @override String get termsPrivacySubtitle => 'Safety, privacy & legal disclaimer';
  @override String get aboutSubtitle => 'Version 1.0.0 (Phase 2)';
  @override String get onboardingBadge1 => 'OBD-II PORT 16-PIN';
  @override String get onboardingBadge2 => 'HARDWARE LINK';
  @override String get onboardingBadge3 => 'IGNITION / ECU ON';
  @override String get onboardingBadge4 => 'BLE TELEMETRY';
  @override String get onboardingDlc => 'DATA LINK CONNECTOR (DLC)';
  @override String get onboardingPwrLed => 'POWER LED ACTIVE (12V)';
  @override String get onboardingIgnitionOn => 'IGNITION ON / 12V BUS';
  @override String get onboardingReadyToPair => 'READY TO PAIR';
  @override String get termsTitle => 'Terms & Privacy';
  @override String get termsSection1Title => 'Safe Driving & Distractions';
  @override String get termsSection1Desc => 'Never interact with CARBYTE while driving. Configure your scanner and telemetry before starting your trip or while parked safely in an authorized area.';
  @override String get termsSection2Title => 'OBD-II Port & Hardware Compatibility';
  @override String get termsSection2Desc => 'CARBYTE interfaces with your ECU via standard OBD-II protocols (ISO 15765-4, SAE J1850, ISO 9141). We are not liable for vehicle battery drainage or issues caused by third-party ELM327 adapters.';
  @override String get termsSection3Title => 'Vehicle Data Privacy';
  @override String get termsSection3Desc => 'Your telemetry and vehicle data (VIN, speed, DTC fault codes, and engine readings) are processed 100% locally on your device. We do not sell or share your data with insurance companies or third parties.';
  @override String get termsSection4Title => 'Diagnostics & Mechanical Repairs';
  @override String get termsSection4Desc => 'Diagnostic trouble codes (DTC) and suggestions are provided for informational purposes only. Always consult a certified automotive technician before replacing vehicle components.';
  @override String get understoodBtn => 'UNDERSTOOD';

  // History Management
  @override String get clearHistoryTooltip => 'Clear history';
  @override String get clearHistoryConfirmTitle => 'Clear History?';
  @override String get clearHistoryConfirmDesc => 'Are you sure you want to delete all diagnostic scan records? This action cannot be undone.';
  @override String get clearHistoryBtn => 'CLEAR HISTORY';
  @override String get emptyHistoryTitle => 'No Diagnostic History';
  @override String get emptyHistoryDesc => 'Diagnostic scans performed on your vehicle will appear here automatically.';
  @override String get historyStatusResolved => 'Resolved';
  @override String get historyStatusAttention => 'Attention Required';
  @override String get historyStatusHealthy => 'Healthy';
  @override String get historyClearedSnack => 'Diagnostic history cleared successfully.';
  @override String get historyRecordDeletedSnack => 'Record deleted.';

  // PDF Export & Diagnostics
  @override String get exportPdfReportBtn => 'EXPORT FULL REPORT TO PDF';
  @override String get exportPdfTooltip => 'Export report to PDF';
  @override String get generatingPdfSnack => 'Generating formal PDF report...';
  @override String get smogCheckTitle => 'EMISSIONS TEST';
  @override String get smogCheckPassed => 'PASSED';
  @override String get smogCheckFailed => 'NOT READY';
  @override String get smogCheckSubtitle => 'ECU emissions and mechanical inspection monitors';
  @override String get dtcProbableCausesTitle => 'Probable Causes';
  @override String get dtcSymptomsTitle => 'Common Symptoms';
  @override String get dtcRecommendedActionTitle => 'Suggested Repair Action';

  // DTC Statuses & Filter
  @override String get dtcStatusConfirmed => 'CONFIRMED (MIL)';
  @override String get dtcStatusPending => 'PENDING';
  @override String get dtcStatusPermanent => 'PERMANENT';
  @override String get dtcFilterAll => 'ALL';
  @override String get dtcFilterConfirmed => 'CONFIRMED';
  @override String get dtcFilterPending => 'PENDING';
  @override String get dtcFilterPermanent => 'PERMANENT';

  // Expanded Sensors
  @override String get stftSensor => 'Short Term Fuel Trim (STFT)';
  @override String get ltftSensor => 'Long Term Fuel Trim (LTFT)';
  @override String get timingAdvanceSensor => 'Timing Advance';
  @override String get fuelLevelSensor => 'Fuel Level';
  @override String get baroPressureSensor => 'Barometric Pressure';

  // Sensor Categories
  @override String get allSensorsTab => 'All';
  @override String get engineTab => 'Engine & Performance';
  @override String get intakeTab => 'Intake & Temperature';
  @override String get fuelElectricTab => 'Fuel & Battery';

  // Vehicle Connection & Status
  @override String get connectedVehicle => 'Connected Vehicle';
  @override String get activeObdLink => 'ECU Link Stable • Live Monitoring';
  @override String get readingVin => 'Reading VIN...';
  @override String get decodingVin => 'Decoding VIN...';
  @override String get linkingObdBus => 'Synchronizing CAN bus...';

  // Scan Modules
  @override String get moduleEngine => 'Engine (PCM / ECM)';
  @override String get moduleTransmission => 'Transmission (TCM)';
  @override String get moduleBrakes => 'Anti-Lock Brakes (ABS / ESP)';
  @override String get moduleAirbag => 'Airbags & Restraints (SRS)';
  @override String get moduleBody => 'Body Control Module (BCM)';
  @override String get moduleExhaust => 'Exhaust & Catalyst Sensors';

  // Emissions Monitors
  @override String get monitorMisfire => 'Misfire Detection';
  @override String get monitorMisfireDesc => 'Monitors erratic cylinder combustion';
  @override String get monitorFuelSystem => 'Fuel System';
  @override String get monitorFuelSystemDesc => 'Air/Fuel ratio feedback and closed-loop control';
  @override String get monitorCcm => 'Comprehensive Components (CCM)';
  @override String get monitorCcmDesc => 'Monitors vital analog sensors and electronic actuators';
  @override String get monitorCatalyst => 'Catalytic Converter';
  @override String get monitorCatalystDesc => 'Efficiency in reducing NOx and CO exhaust emissions';
  @override String get monitorEvap => 'Evaporative System (EVAP)';
  @override String get monitorEvapDesc => 'Fuel tank vapor containment and purge operation';
  @override String get monitorO2Sensor => 'Oxygen Sensors (O2)';
  @override String get monitorO2SensorDesc => 'Upstream and downstream lambda sensor switching speed';
  @override String get monitorO2Heater => 'Oxygen Sensor Heater';
  @override String get monitorO2HeaterDesc => 'Heater circuit to achieve proper operating temperature';
  @override String get monitorEgr => 'EGR / VVT System';
  @override String get monitorEgrDesc => 'Exhaust gas recirculation and variable valve timing';
  @override String get statusReady => 'Ready / Passed';
  @override String get statusPendingMonitor => 'Incomplete';
  @override String get verified => 'VERIFIED';
  @override String get viewDetails => 'View Details';
  @override String get hideDetails => 'Hide';
  @override String get monitorsReadySuffix => 'Monitors Ready';
}
