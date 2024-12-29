import 'package:flutter/material.dart';

// MODAL BOTTOM FOR ACTION CONFIRMATION
void showConfirmationModal(
    BuildContext context,
    String textReminder,
    String textAction,
    Widget destinationScreen,
    ) {
  showModalBottomSheet(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(10),
      ),
    ),
    context: context,
    isDismissible: true,
    backgroundColor: Colors.white,
    elevation: 0,
    builder: (context) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 5),
              child: Center(
                child: Text(
                  textReminder,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF868686),
                  ),
                ),

              ),
            ),
            const Divider(
              color: Color(0xFFF7F5F5),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE7E7E9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  textAction,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFe91b4f),
                  ),
                ),

              ),
            ),
            Container(
              height: 10,
              color: const Color(0xFFF5F5F5),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE7E7E9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF3C3C40),
                  ),
                ),

              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      );
    },
  );
}