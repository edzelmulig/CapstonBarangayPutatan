import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:putatanapk/ui/widgets/buttons/custom_button.dart';

class ClientServiceCard extends StatelessWidget {
  final dynamic service;
  final VoidCallback onPressed;

  const ClientServiceCard({
    super.key,
    required this.service,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    var imageURL = service['imageURL'] as String?;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7.0),
      ),
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  top: 10,
                  right: 10,
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: imageURL != null && imageURL.isNotEmpty
                        ? FadeInImage(
                            fit: BoxFit.cover,
                            placeholder:
                                const AssetImage("lib/ui/assets/no_image.jpeg"),
                            image: NetworkImage(imageURL),
                            imageErrorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'lib/ui/assets/no_image.jpeg',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            "lib/ui/assets/no_image.jpeg",
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              ListTile(
                title: AutoSizeText(
                  service['serviceName'] ?? 'N/A',
                  style: const TextStyle(
                    color: Color(0xFF222227),
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  minFontSize: 12,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: AutoSizeText(
                    "₱${NumberFormat("#,##0", "en_PH").format(service['price'])}.00",
                    style: const TextStyle(
                      color: Color(0xFF222227),
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    minFontSize: 13,
                  ),
                ),
              ),
              // BUTTON
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05),
                child: CustomButton(
                    buttonLabel: "Request",
                    onPressed: onPressed,
                    buttonColor: Colors.blue,
                    buttonHeight: 35,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    fontColor: Colors.white,
                    borderRadius: 5,),
              )
            ],
          ),
          if (service['isForBorrow'] == true)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  "For Barrow",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (service['discount'] != 0)
            Positioned(
              top: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.8),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 3),
                  child: Text(
                    '${service['discount']}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
