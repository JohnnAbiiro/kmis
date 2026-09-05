import 'package:flutter/material.dart';
import 'chart1.dart';

class GaugeContainer extends StatelessWidget {
  final double cwidth;
  final double reader;
  final double totalval;
  const GaugeContainer({super.key, required this.cwidth, required this.reader, required this.totalval});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: cwidth,
      height: 250,
      decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('School Finance Information', style: TextStyle(fontSize: 18, color: colors.primary)),
            SizedBox(height: 30),
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xFF047cff).withOpacity(0.1),
                        borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                  value: 30,
                                  backgroundColor: Color(0xFF047cff).withOpacity(0.2),
                                  color: Color(0xFF047cff),
                                  strokeWidth: 6,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text("20,000", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.onSurface)),
                              Text("Total Expected Fees", style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant))
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xFF00b478).withOpacity(0.1),
                        borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                  value: 13000/20000,
                                  backgroundColor: Color(0xFF00b478).withOpacity(0.2),
                                  color: Color(0xFF00b478),
                                  strokeWidth: 6,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text("13,000", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.onSurface),),
                              Text("Total Fees Received", style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),)
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  color: Color(0xFFe42557).withOpacity(0.1),
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator(
                            value: 7000/20000,
                            backgroundColor: Color(0xFFe42557).withOpacity(0.2),
                            color: Color(0xFFe42557),
                            strokeWidth: 7,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("7,000", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                        Text("Outstanding balances", style: TextStyle(fontSize: 12),)
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

