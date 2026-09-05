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
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 150,
      width: widget.cwidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Active Fee Policy", style: TextStyle(fontSize: 12)),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: const BorderRadius.all(Radius.circular(4))
                ),
                  child: const Text("2024/2025", style: TextStyle(color: Colors.deepPurple, fontSize: 10),)
              )
            ],
          ),
          const SizedBox(height: 4),
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Attached To", style: TextStyle(fontSize: 12)),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: const BorderRadius.all(Radius.circular(4))
                ),
                  child: const Text("120 Students", style: TextStyle(color: Colors.green, fontSize: 10),)
              )
            ],
          ),
          const SizedBox(height: 4),
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Current Base Fee", style: TextStyle(fontSize: 12)),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: const BorderRadius.all(Radius.circular(4))
                ),
                  child: const Text("GHC 120", style: TextStyle(fontSize: 10),)
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("View Type", style: TextStyle(fontSize: 12)),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  //color: Colors.orange.shade100,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: const Border(
                      bottom: BorderSide(color: Colors.black26),
                      top: BorderSide(color: Colors.black26),
                      right: BorderSide(color: Colors.black26),
                      left: BorderSide(color: Colors.black26),
                  )
                ),
                  child: const Text("Year Group", style: TextStyle(fontSize: 10),)
              )
            ],
          ),
        ],
      ),
    );
  }
}
