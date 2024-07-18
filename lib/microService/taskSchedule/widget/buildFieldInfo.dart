import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildFieldInfo(String label, Widget Tip) {
  return Container(
    width: double.infinity,
    color: Colors.lightBlueAccent,
    alignment: Alignment.center,
    // padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              '$label: ',
              style: GoogleFonts.aldrich(
                color: Color(0xFF2e282a),
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: DefaultTextStyle(
                style: TextStyle(fontSize: 9.sp),
                child: Tip,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
