/// BLE connection lifecycle for industrial devices.
enum BleConnectionState { disconnected, connecting, connected }

/// BLE device model consumed by DeviceCard / DeviceDetailPanel.
/// Pure Dart entity — no Flutter imports.
class BleDevice {
  final String name;
  final String mac;
  final String model;
  final String family;
  final String hardware;
  final BleConnectionState connectionState;
  final String modifiedBy;
  final double voltage;
  final double temperature;
  final bool authorized;
  final bool licenseExpired;

  const BleDevice({
    required this.name,
    required this.mac,
    required this.model,
    required this.family,
    required this.hardware,
    required this.connectionState,
    required this.modifiedBy,
    required this.voltage,
    required this.temperature,
    required this.authorized,
    required this.licenseExpired,
  });
}