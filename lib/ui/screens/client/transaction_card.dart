import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClientTransactionCard extends StatelessWidget {
  final String imageURL;
  final String serviceName;
  final String status;
  final Timestamp dateOfTransaction;
  final double price;
  final String? serviceId;
  final double? numberOfStocksBorrowed;
  final DateTime? startDate;
  final DateTime? endDate;

  const ClientTransactionCard({
    Key? key,
    required this.imageURL,
    required this.serviceName,
    required this.status,
    required this.dateOfTransaction,
    required this.price,
    this.serviceId,
    this.numberOfStocksBorrowed,
    this.startDate,
    this.endDate,
  }) : super(key: key);

  // Method to format Timestamp into a readable date
  String formatTransactionDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate(); // Convert Timestamp to DateTime
    return DateFormat('MMM dd, yyyy')
        .format(date); // Format the date to "MMM dd, yyyy"
  }

  @override
  Widget build(BuildContext context) {
    // Change the status to "pending" if price is not 0.0, else use the original status
    String localStatus = price != 0.0 ? 'pending' : status;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF002091).withOpacity(0.1),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                // Image section
                Container(
                  width: 60, // Fixed width for the image
                  height: 60, // Fixed height for the image
                  margin: const EdgeInsets.only(left: 15, right: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    // Border radius for image
                    image: DecorationImage(
                      image: imageURL.isNotEmpty
                          ? NetworkImage(imageURL)
                          : const AssetImage("lib/ui/assets/no_image.jpeg")
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Text and Status section
                Expanded(
                  // This will allow the text and status to take up remaining space
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AutoSizeText(
                        serviceName,
                        style: const TextStyle(
                          color: Color(0xFF222227),
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        minFontSize: 15,
                      ),
                      Row(
                        children: <Widget>[
                          // Status Container
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 1.0, horizontal: 7.0),
                            decoration: BoxDecoration(
                              color: localStatus == "pending"
                                  ? Colors.orange
                                      .withOpacity(0.8) // Pending status color
                                  : (localStatus == "returned"
                                      ? Colors.green.withOpacity(
                                          0.8) // Returned status color
                                      : Colors.red.withOpacity(0.8)),
                              // Default (e.g., unreturned) status color
                              borderRadius: BorderRadius.circular(
                                  3), // Rounded corners for status
                            ),
                            child: Text(
                              localStatus,
                              style: const TextStyle(
                                color: Colors.white, // White text for contrast
                                fontSize: 12.0,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Date section (aligned to the right)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Text(
                              formatTransactionDate(dateOfTransaction),
                              // Formatted date
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
