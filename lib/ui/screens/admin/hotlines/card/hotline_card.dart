import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard

class HotlineCard extends StatelessWidget {
  // PARAMETERS NEEDED
  final dynamic hotlineInfo;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  // CONSTRUCTORS FOR CREATING NEW INSTANCE/OBJECT
  const HotlineCard({
    super.key,
    required this.hotlineInfo,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    var imageURL = hotlineInfo['contactImage'] as String?;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Contact Image (smaller size) with fixed margin and size
            Container(
              width: 55,
              // Fixed width for the image
              height: 60,
              // Fixed height for the image
              margin: const EdgeInsets.only(right: 10),
              // Fixed margin to the right
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
              ),
              child: imageURL != null && imageURL.isNotEmpty
                  ? FadeInImage(
                      fit: BoxFit.fill,
                      placeholder:
                          const AssetImage("lib/ui/assets/no_image.jpeg"),
                      image: NetworkImage(imageURL),
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "lib/ui/assets/no_image.jpeg",
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : const FadeInImage(
                      fit: BoxFit.cover,
                      placeholder: AssetImage("lib/ui/assets/no_image.jpeg"),
                      image: AssetImage("lib/ui/assets/no_image.jpeg"),
                    ),
            ),

            // Spacing between image and text
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    hotlineInfo['contactName'] ?? 'N/A',
                    style: const TextStyle(
                      color: Color(0xFF222227),
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    minFontSize: 18,
                  ),
                  GestureDetector(
                    onTap: () {
                      // Copy the contact number to clipboard
                      Clipboard.setData(
                              ClipboardData(text: hotlineInfo['contactNumber']))
                          .then((_) {
                        // Show a snack bar confirming the copy action
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Contact number copied to clipboard!")),
                        );
                      });
                    },
                    child: AutoSizeText(
                      hotlineInfo['contactNumber'] ?? 'N/A',
                      style: const TextStyle(
                        color: Color(0xFF222227),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      minFontSize: 17,
                    ),
                  ),

                  // Action Buttons (Update and Delete)

                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Update Button
                SizedBox(
                  width: 100, // Ensures the buttons have the same width
                  child: ElevatedButton(
                    onPressed: onUpdate,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      side: const BorderSide(
                        color: Color(0xFF222227),
                        width: 1.5,
                      ),
                      minimumSize: const Size(35, 35),
                    ),
                    child: const Text(
                      "Update",
                      style: TextStyle(
                        color: Color(0xFF222227),
                      ),
                    ),
                  ),
                ), // Space between buttons

                // Delete Button
                SizedBox(
                  width: 100, // Same width as Update button
                  child: ElevatedButton(
                    onPressed: onDelete,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: const Color(0xFF222227),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      minimumSize:
                      const Size(35, 35), // Adjusted for icon button
                    ),
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
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
