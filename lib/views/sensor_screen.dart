import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  double _gyroX = 0.0;
  double _gyroY = 0.0;
  double _gyroZ = 0.0;
  
  double _accelX = 0.0;
  double _accelY = 0.0;
  double _accelZ = 0.0;
  
  int _stepCount = 0;
  String _pedometerStatus = 'Initializing...';
  
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<StepCount>? _stepCountSubscription;
  
  @override
  void initState() {
    super.initState();
    _initSensors();
  }
  
  Future<void> _initSensors() async {
    await _requestPermissions();
    
    _gyroscopeSubscription = gyroscopeEventStream().listen(
      (GyroscopeEvent event) {
        setState(() {
          _gyroX = event.x;
          _gyroY = event.y;
          _gyroZ = event.z;
        });
      },
      onError: (error) {
        // Gyroscope error
      },
    );
    
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        setState(() {
          _accelX = event.x;
          _accelY = event.y;
          _accelZ = event.z;
        });
      },
      onError: (error) {
        // Accelerometer error
      },
    );
    
    _initPedometer();
  }
  
  Future<void> _requestPermissions() async {
    try {
      final status = await Permission.activityRecognition.status;

      
      if (status.isDenied) {
        final result = await Permission.activityRecognition.request();

        
        if (result.isGranted) {
          setState(() {
            _pedometerStatus = 'Permission granted';
          });
        } else {
          setState(() {
            _pedometerStatus = 'Permission denied';
          });
        }
      } else if (status.isGranted) {
        setState(() {
          _pedometerStatus = 'Permission granted';
        });
      }
    } catch (e) {

      setState(() {
        _pedometerStatus = 'Permission error';
      });
    }
  }
  
  void _initPedometer() {

    
    _stepCountSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) {

        setState(() {
          _stepCount = event.steps;
          _pedometerStatus = 'Tracking - ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';
        });
      },
      onError: (error) {

        setState(() {
          _pedometerStatus = 'Not available on this device';
        });
      },
      onDone: () {

        setState(() {
          _pedometerStatus = 'Stream ended';
        });
      },
    );
    
    Future.delayed(const Duration(seconds: 3), () {
      if (_pedometerStatus == 'Initializing...' || _pedometerStatus == 'Permission granted') {
        setState(() {
          _pedometerStatus = 'Waiting for steps... (Walk to test)';
        });
      }
    });
  }
  
  @override
  void dispose() {
    _gyroscopeSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _stepCountSubscription?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Sensor Data'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Real-time Mobile Sensors',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Data updates continuously',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade50,
                      Colors.white,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_walk, size: 32, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Step Count',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _stepCount.toString(),
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const Text(
                      'steps today',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.blue.shade800),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _pedometerStatus,
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildSensorCard(
              title: '🔄 Gyroscope',
              icon: Icons.screen_rotation,
              color: Colors.purple,
              children: [
                _buildDataRow('X-axis', _gyroX.toStringAsFixed(4), Icons.swap_horiz),
                _buildDataRow('Y-axis', _gyroY.toStringAsFixed(4), Icons.swap_vert),
                _buildDataRow('Z-axis', _gyroZ.toStringAsFixed(4), Icons.rotate_90_degrees_ccw),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildSensorCard(
              title: '📱 Accelerometer',
              icon: Icons.vibration,
              color: Colors.orange,
              children: [
                _buildDataRow('X-axis', _accelX.toStringAsFixed(4), Icons.swap_horiz),
                _buildDataRow('Y-axis', _accelY.toStringAsFixed(4), Icons.swap_vert),
                _buildDataRow('Z-axis', _accelZ.toStringAsFixed(4), Icons.rotate_90_degrees_ccw),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSensorCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDataRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}
