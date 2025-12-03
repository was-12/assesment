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
  // Gyroscope data
  double _gyroX = 0.0;
  double _gyroY = 0.0;
  double _gyroZ = 0.0;
  
  // Accelerometer data (additional sensor)
  double _accelX = 0.0;
  double _accelY = 0.0;
  double _accelZ = 0.0;
  
  // Pedometer data
  int _stepCount = 0;
  String _pedometerStatus = 'Initializing...';
  
  // Stream subscriptions
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<StepCount>? _stepCountSubscription;
  
  @override
  void initState() {
    super.initState();
    _initSensors();
  }
  
  Future<void> _initSensors() async {
    // Request activity recognition permission for pedometer
    await _requestPermissions();
    
    // Initialize gyroscope
    _gyroscopeSubscription = gyroscopeEventStream().listen(
      (GyroscopeEvent event) {
        setState(() {
          _gyroX = event.x;
          _gyroY = event.y;
          _gyroZ = event.z;
        });
      },
      onError: (error) {
        print('Gyroscope error: $error');
      },
    );
    
    // Initialize accelerometer
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        setState(() {
          _accelX = event.x;
          _accelY = event.y;
          _accelZ = event.z;
        });
      },
      onError: (error) {
        print('Accelerometer error: $error');
      },
    );
    
    // Initialize pedometer
    _initPedometer();
  }
  
  Future<void> _requestPermissions() async {
    try {
      final status = await Permission.activityRecognition.status;
      print('Activity recognition permission status: $status');
      
      if (status.isDenied) {
        final result = await Permission.activityRecognition.request();
        print('Permission request result: $result');
        
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
      print('Permission error: $e');
      setState(() {
        _pedometerStatus = 'Permission error';
      });
    }
  }
  
  void _initPedometer() {
    print('Initializing pedometer...');
    
    _stepCountSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        print('Step count received: ${event.steps}');
        setState(() {
          _stepCount = event.steps;
          _pedometerStatus = 'Tracking - ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';
        });
      },
      onError: (error) {
        print('Pedometer error: $error');
        setState(() {
          _pedometerStatus = 'Not available on this device';
        });
      },
      onDone: () {
        print('Pedometer stream done');
        setState(() {
          _pedometerStatus = 'Stream ended';
        });
      },
    );
    
    // Set a timeout to check if pedometer started
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
            // Header
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
            
            // Pedometer Card
            _buildSensorCard(
              title: '🚶 Pedometer',
              icon: Icons.directions_walk,
              color: Colors.blue,
              children: [
                _buildDataRow('Step Count', _stepCount.toString(), Icons.trending_up),
                const Divider(),
                _buildDataRow('Status', _pedometerStatus, Icons.info_outline),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Gyroscope Card
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
            
            // Accelerometer Card
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
            
            const SizedBox(height: 24),
            
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Sensor Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoText('• Gyroscope measures rotation rate'),
                  _buildInfoText('• Accelerometer measures device acceleration'),
                  _buildInfoText('• Pedometer counts steps using motion sensors'),
                  _buildInfoText('• All data updates in real-time'),
                  const SizedBox(height: 8),
                  Text(
                    'Note: Sensors work best on physical mobile devices',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
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
