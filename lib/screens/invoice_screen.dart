// lib/screens/invoice_screen.dart

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoiceScreen extends StatelessWidget {
  final Map<String, dynamic> order; // Single aggregated order

  const InvoiceScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (order.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Invoice'),
          backgroundColor: Colors.green,
        ),
        body: const Center(child: Text('No orders available for the invoice.')),
      );
    }

    final transactionCode = order['transaction_code'] ?? 'N/A';
    final shippingCost = double.tryParse(order['order_info']?['shipping']?.toString() ?? '0') ?? 0.0;
    final total = double.tryParse(order['order_info']?['total']?.toString() ?? '0') ?? 0.0;
    final items = order['items'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "IGROW Invoice",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Universiti Teknologi Malaysia\nSkudai, Johor, Malaysia",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey[400], thickness: 1),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Transaction ID: $transactionCode", style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            const Text("Items", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 8),

            // Loop through each item to display product details
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index] as Map<String, dynamic>;
                  final productName = item['productName'] ?? 'Unknown Product';
                  final productQty = item['productqty'] ?? 0;
                  final productPrice = double.tryParse(item['productPrice']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00';

                  // Debugging prints
                  debugPrint("Item $index: productName = $productName, productQty = $productQty, productPrice = $productPrice");

                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text("Qty: $productQty"),
                            ],
                          ),
                          Text(
                            "RM$productPrice",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),
            Divider(color: Colors.grey[400], thickness: 1),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text("Shipping: RM${shippingCost.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text("Total Price: RM${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back to the previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, // Background color for the Back button
                  ),
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _createPdf(context, transactionCode, shippingCost, total, items); // Pass items to PDF generation function
                  },
                  child: const Text('Save Invoice'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to create and print/save PDF
  void _createPdf(BuildContext context, String transactionCode, double shippingCost, double total, List<dynamic> items) async {
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Generating PDF'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Please wait while the invoice is being generated...'),
          ],
        ),
      ),
    );

    final pdf = pw.Document();

    // Add a page to the PDF document
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("IGROW Invoice", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text("Universiti Teknologi Malaysia", style: pw.TextStyle(fontSize: 16)),
              pw.Text("Skudai, Johor, Malaysia", style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text("Transaction ID: $transactionCode", style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text("Items", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
              pw.SizedBox(height: 10),

              // Loop through each item to display product details
              pw.Table.fromTextArray(
                headers: ['Product Name', 'Quantity', 'Price'],
                data: items.map((item) {
                  final productName = item['productName'] ?? 'Unknown Product';
                  final productQty = item['productqty'] ?? 0;
                  final productPrice = double.tryParse(item['productPrice']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00';
                  return [productName, productQty.toString(), "RM$productPrice"];
                }).toList(),
              ),

              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text("Shipping: RM${shippingCost.toStringAsFixed(2)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text("Total Price: RM${total.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    // Print the PDF and close the loading dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );

    // Dismiss the loading dialog
    Navigator.of(context).pop();
  }
}
