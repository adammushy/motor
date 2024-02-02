// import 'package:flutter_blue/flutter_blue.dart';

// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// BluetoothDevice? device; // Initialize this with your selected Bluetooth device

// Future<void> sendCommand(String command) async {
//   if (device == null) {
//     // Device not connected, handle accordingly
//     return;
//   }

//   try {
//     await device!.writeCharacteristic(s
//       yourCharacteristicUUID, // Replace with your actual characteristic UUID
//       command.codeUnits,
//       type: CharacteristicWriteType.withResponse,
//     );
//   } catch (e) {
//     // Handle errors
//   }
// }

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('System Dashboard'),
      ),
      // backgroundColor: Colors.amber,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(""), // Replace with your image asset path
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dashboard Widgets
            DashboardWidget(),
      
            SizedBox(height: 20),
      
            // System Control Buttons
            // SystemControlButtons(),
      
            // SizedBox(height: 20),
      
            // // Log Button
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => LogScreen()),
            //     );
            //   },
            //   child: Text('View System Log'),
            // ),
          ],
        ),
      ),
    );
  }
}

// class DashboardWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Replace these values with your actual data
//     int tankLevel = 75;
//     double systemTemperature = 28.5;
//     int bottlesFilled = 150;

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           'Tank Level: $tankLevel%',
//           style: TextStyle(fontSize: 20),
//         ),
//         Text(
//           'System Temperature: $systemTemperature°C',
//           style: TextStyle(fontSize: 20),
//         ),
//         Text(
//           'Containers Filled: $bottlesFilled',
//           style: TextStyle(fontSize: 20),
//         ),
//       ],
//     );
//   }
// }
class DashboardWidget extends StatefulWidget {
  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('data')
          .doc('motordata')
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          Map<String, dynamic>? data =
              snapshot.data?.data() as Map<String, dynamic>?;

          if (data == null) {
            return Center(
              child: Text('No data available'),
            );
          }

          // double tankLevel = data['filltimer'] ?? 0;
          double systemTemperature = data['temperature'] ?? 0;
          double bottlesFilled = data['bottles'] ?? 0;

          return Column(
            children: [
              _buildDataCard(
                  'Containers Filled', '$bottlesFilled', Icons.local_drink),
              _buildDataCard(
                  'Motor Speed', '$systemTemperature RPM', Icons.speed),
              Row(
                children: [],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildDataCard(String title, String value, IconData icon) {
    return Card(
      elevation: 10,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              icon,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(fontSize: 28),
            ),
          ],
        ),
      ),
    );
  }
}

class SystemControlButtons extends StatefulWidget {
  @override
  State<SystemControlButtons> createState() => _SystemControlButtonsState();
}

class _SystemControlButtonsState extends State<SystemControlButtons> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void updateFirebase(String button) {
    _firestore.collection('controls').doc('arduino_controls').set({
      button: true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            // Function to start the system
            // Add your logic here
            updateFirebase('stop');
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.green, // Set the button color
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(
                  Icons.play_circle_outline, // Play icon
                  size: 50,
                ),
                SizedBox(height: 10),
                Text('Start System'),
              ],
            ),
          ),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            // Function to stop the system
            // Add your logic here
            // _showStopReasonDialog(context);
            updateFirebase('stop');
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.red, // Set the button color
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(
                  Icons.stop_circle_outlined, // Stop icon
                  size: 50,
                ),
                SizedBox(height: 10),
                Text('Stop System'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Function to show the stop reason dialog
  void _showStopReasonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Stop Reason'),
          content: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _logSystemStop("Normal Stop");
                },
                child: Text('Normal Stop'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _logSystemStop("Overheat Issue");
                },
                child: Text('Overheat Issue'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to log the system stop
  void _logSystemStop(String stopReason) {
    // Implement your system stop logging logic here
    print('System stopped: $stopReason at ${DateTime.now()}');
  }
}

class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this list with your actual log data
    List<String> logData = [
      'System stopped: Normal Stop at 2023-11-01 12:30:45',
      'System stopped: Overheat Issue at 2023-11-02 15:20:30',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('System Log'),
      ),
      body: ListView.builder(
        itemCount: logData.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(logData[index]),
          );
        },
      ),
    );
  }
}
