import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(BLEScanner());
}

class BLEScanner extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Scanner Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Page(title: 'BLE Scanner'),
    );
  }
}

class Page extends StatefulWidget {
  Page({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  PageState createState() => PageState();
}

class PageState extends State<Page> {
  //List to store scanResults all scan results
  List<ScanResult> scanResults = [];
  FlutterBlue scanObject = FlutterBlue.instance;
  //sorts by rssi in ascending order, and updates the state.
  void _sort() {
    setState(() {
      scanResults.sort((a, b)=> b.rssi.compareTo(a.rssi));
    });
  }
  void _scan(){
      //disconnect all devices when doing a new scan to avoid stray connections
      if(scanResults != []){
        for(ScanResult s in scanResults){
          s.device.disconnect();
        }
      }

      //clear previous entries to repopulate
      scanResults.clear();
      //scan all surrounding ble devices
      scanObject.scan(allowDuplicates: false, timeout: Duration(seconds: 6)).listen((results) {
        //update state as we append to scanResults
        setState(() {
          scanResults.add(results);
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: GestureDetector(
          onTap:() {showHelpDialog(context);},
            child: Icon(
              Icons.help,
            )
        )
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[

            for (ScanResult s in scanResults) Padding( // dynamically displays information stored in scanResults
              padding: const EdgeInsets.all(4.0),
              child: Container(
                child: ListTile(
                    title: Text(s.device.name.toString(),textScaleFactor: 1.25,), //name
                    trailing: Text(s.rssi.toString()), // rssi
                    subtitle: Text(s.device.id.toString() + "   connectable: " + s.advertisementData.connectable.toString()), //mac + connectable
                    onTap: () {
                      s.device.connect();
                      showConnectedDialog(context, s.advertisementData.connectable);
                    }),
                color: Colors.red[200],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton( //buttons to sort and scan
            onPressed: _sort,
            tooltip: 'Sort',
            child: Icon(Icons.sort),

          ),
          FloatingActionButton(
            onPressed: _scan,
            tooltip: 'Scan/Refresh Page',
            child: Icon(Icons.bluetooth),

          ),
        ]
      ),

    );
  }
}

//alert dialog to show connection
showConnectedDialog(BuildContext context, bool connectable) {
  String s;
  if(connectable){ s = "Device Connected"; }
  else{ s = "Device not connectable"; }
  // set up the button
  Widget ok = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    }
  );

  AlertDialog alert = AlertDialog(
    title: Text(s),
    actions: [
      ok,
    ],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showHelpDialog(BuildContext context) {
  Widget ok = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      }
  );
  AlertDialog alert = AlertDialog(
    title: Text("Help Dialog"),
    content: Text("Press the BLE button to scan for devices, the sort button to sort the devices by RSSI, and "
        "the devices to connect to them(if they are connectable). Pressing the BLE button again will disconnect"
        " all devices and start a new scan"),
    actions: [
      ok,
    ],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}








