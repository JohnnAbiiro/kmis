import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ksoftsms/controller/loginprovider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../components/receiptpdf.dart';
import '../controller/myprovider.dart';
import '../controller/routes.dart';

class SchoolReceipt extends StatefulWidget {
  const SchoolReceipt({super.key});

  @override
  State<SchoolReceipt> createState() => _SchoolReceiptState();
}

class _SchoolReceiptState extends State<SchoolReceipt> {
  String receiptnumber="";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      final provider = Provider.of<Myprovider>(context, listen: false);
       provider.getdata();
       provider.myreceipt();
    });

    
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<Myprovider>(
      builder: (BuildContext context,  val,  child) {
        print("Receipt: ${val.receiptrecords}");
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back,color: Colors.white,),
              onPressed: () {
                context.go(Routes.feepayment);
              },
            ),
            title:  Text(" School Receipt",style: TextStyle(color: Colors.white),),
            backgroundColor: Color(0xFF00496d),
          ),
          backgroundColor: Color(0xFFf3f4ff),
          body: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 800),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              color: Color(0xFF00496d),
                              child: const Center(
                                child: Text(
                                  "Logo",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: const [
                                Text(
                                  "BOLGA, UPPER EAST",
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  "INFO@KOLOGSOFT.COM",
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  "WWW.KOLOGSOFT.COM",
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  "+233 553 354 349",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 30,
                          color: Color(0xFF00496d),
                        ),
                        const SizedBox(height: 60),
                         Center(
                          child: Text(
                            "${val.currentschool.toString().toUpperCase()} SCHOOL FEES RECEIPT",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00496d)
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:  [
                            Text.rich(
                              TextSpan(
                                text: "Date: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                children: [
                                  TextSpan(
                                    text: val.today,
                                    style: TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: "Receipt No.: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                children: [
                                  TextSpan(
                                    text: val.receiptno,
                                    style: TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 40, color: Color(0xFF00496d),),

                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 Text.rich(
                                  TextSpan(
                                    text: "Received From:\n",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                        text: val.receiptName,
                                        style: TextStyle(fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                 Text.rich(
                                  TextSpan(
                                    text: "Payment Type: ",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                        text: val.receiptpaymentmethod,
                                        style: TextStyle(fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                 Text.rich(
                                  TextSpan(
                                    text: "Payment for: ",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                        text: val.receiptnote,
                                        style: TextStyle(fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 20),
                        Table(
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(color: Colors.grey.shade200),
                              children: const [
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Description",
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Amount (GHC)",
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                            // tableRow("School Fee (First Term 2025)", "2,500.00"),
                            // tableRow("Library Fee", "150.00"),
                            // tableRow("Sports Fee", "50.00"),

                            ...val.receiptrecords.entries.map((entry) {
                              print(entry);
                              final feeName = entry.key;
                              final feeAmount = val.numberFormat.format(entry.value);

                              return tableRow(
                                feeName,
                                feeAmount.toString(), // format as 2 decimal places
                              );
                            }).toList(),

                            TableRow(
                              decoration: BoxDecoration(color: Colors.grey.shade100),
                              children:  [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Total",
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(val.numberFormat.format(val.receiptTotal),
                                      textAlign: TextAlign.right,
                                      style: TextStyle(fontWeight: FontWeight.bold,)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                 Text.rich(
                                  TextSpan(
                                    text: "Payment Date: ",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                        text:val.receiptdate ,
                                        style: TextStyle(fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Thank you for your payment. For any further inquiries, please contact us at info@kologsoft.com or call 0553354349.",
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final printer = SchoolReceiptPrinter(
                              schoolName: val.currentschool,
                              schoolAddress: "BOLGA, UPPER EAST",
                              schoolEmail: "info@kologsoft.com",
                              schoolWebsite: "www.kologsoft.com",
                              schoolPhone: "+233 553 354 349",
                              logoAssetPath: "assets/logo.png", // must exist in pubspec.yaml

                              date: val.today,
                              receiptNo:val.receiptno,
                              receivedFrom: val.receiptName,
                              paymentType: val.receiptpaymentmethod,
                              paymentFor: val.receiptnote,
                              paymentDate: val.receiptdate,
                              records: val.receiptrecords,
                              total: val.numberFormat.format(val.receiptTotal),
                            );

                            // Generate PDF
                            final pdfBytes = await printer.generatePdf(
                              PdfPageFormat.a4,
                              "School Receipt",
                            );

                            // Open print/share preview
                            await Printing.layoutPdf(
                              onLayout: (PdfPageFormat format) async => pdfBytes,
                            );
                          },
                          child: const Text("Print Receipt"),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ),
          ),
        );
      },
    );
  }

  TableRow tableRow(String description, String amount) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(description),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(amount, textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
