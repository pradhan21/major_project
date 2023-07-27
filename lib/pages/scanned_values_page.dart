import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart';

class ScannedValuesPage extends StatelessWidget {
  final List<OcrText> scannedValues;

  ScannedValuesPage({required this.scannedValues});

  @override
  Widget build(BuildContext context) {
    // Implement the UI to display the scanned bill details
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanned Bill Details'),
      ),
      body: ListView.builder(
        itemCount: scannedValues.length,
        itemBuilder: (context, index) {
          final scannedValue = scannedValues[index];
          return ListTile(
            title: Text(scannedValue.value),
          );
        },
      ),
    );
  }
}
