import 'package:flutter/material.dart';

class DonerCardDetails extends StatelessWidget {
  final String donerName;
  final String donerCity;
  final String donerPhone;
  const DonerCardDetails({
    Key? key,
    required this.donerName,
    required this.donerCity,
    required this.donerPhone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Wrap(
        // crossAxisAlignment: CrossAxisAlignment.start,
        runSpacing: 5,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              children: [
                const Text("الاسم  : ",
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
                Text(
                  donerName,
                  style: const TextStyle(fontWeight: FontWeight.normal),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              children: [
                const Text("المنطقة  : ",
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
                Text(donerCity),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
