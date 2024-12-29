import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard

class ClientHotlineCard extends StatelessWidget {
  // PARAMETERS NEEDED
  final dynamic hotlineInfo;

  // CONSTRUCTORS FOR CREATING NEW INSTANCE/OBJECT
  const ClientHotlineCard({
    super.key,
    required this.hotlineInfo,
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
              margin: const EdgeInsets.only(left: 15, right: 20),
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

            GestureDetector(
              onTap: () {
                // Copy the contact number to clipboard
                Clipboard.setData(
                        ClipboardData(text: hotlineInfo['contactNumber']))
                    .then((_) {
                  // Show a snack bar confirming the copy action
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                        content: Text("Contact number copied to clipboard!")),
                  );
                });
              },
              child: const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(
                    Icons.copy_outlined,
                    size: 30,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
