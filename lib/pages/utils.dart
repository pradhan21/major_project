import 'models.dart';

class OCRUtils {
  static BillDetails extractBillDetails(String ocrResult) {
    // Implement your logic to extract relevant bill details from the OCR result
    // This may involve parsing the text or using regular expressions
    // Return the extracted details as a BillDetails object
    // Example:
    return BillDetails(
      totalAmount: '29.99',
      items: ['Item 1', 'Item 2', 'Item 3'],
    );
  }
}
