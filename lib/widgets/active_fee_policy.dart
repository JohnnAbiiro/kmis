import 'package:flutter/material.dart';

class ActiveFeePolicy extends StatefulWidget {
  final double cwidth;
  const ActiveFeePolicy({super.key, required this.cwidth});

  @override
  State<ActiveFeePolicy> createState() => _ActiveFeePolicyState();
}

class _ActiveFeePolicyState extends State<ActiveFeePolicy> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: widget.cwidth,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Active Fee Policy", style: TextStyle(fontSize: 12)),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.all(Radius.circular(4))
                ),
                  child: Text("2024/2025", style: TextStyle(color: Colors.deepPurple, fontSize: 10),)
              )
            ],
          ),
          SizedBox(height: 4),
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Attached To", style: TextStyle(fontSize: 12)),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.all(Radius.circular(4))
                ),
                  child: Text("120 Students", style: TextStyle(color: Colors.green, fontSize: 10),)
              )
            ],
          ),
          SizedBox(height: 4),
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Current Base Fee", style: TextStyle(fontSize: 12)),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.all(Radius.circular(4))
                ),
                  child: Text("GHC 120", style: TextStyle(color: Colors.orange, fontSize: 10),)
              )
            ],
          ),
          SizedBox(height: 8),
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("View Type", style: TextStyle(fontSize: 12)),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  //color: Colors.orange.shade100,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  border: Border(
                      bottom: BorderSide(color: Colors.black26),
                      top: BorderSide(color: Colors.black26),
                      right: BorderSide(color: Colors.black26),
                      left: BorderSide(color: Colors.black26),
                  )
                ),
                  child: Text("Year Group", style: TextStyle(color: Colors.orange, fontSize: 10),)
              )
            ],
          ),
        ],
      ),
    );
  }
}
