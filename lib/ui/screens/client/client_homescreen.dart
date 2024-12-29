import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:putatanapk/navigation/navigation_utils.dart';
import 'package:putatanapk/ui/screens/admin/my_services/card/client_service_card.dart';
import 'package:putatanapk/ui/screens/client/request_service_screen.dart';
import 'package:putatanapk/ui/widgets/loading_indicator/custom_loading_indicator_v2.dart';
import 'package:putatanapk/ui/widgets/static_widget/no_service_available.dart';

class ClientHomescreen extends StatefulWidget {
  const ClientHomescreen({super.key});

  @override
  State<ClientHomescreen> createState() => _ClientHomescreenState();
}

class _ClientHomescreenState extends State<ClientHomescreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        if (_) {
          return;
        }
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          title: const Text(
            "Available Services",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
              color: Colors.white,
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc("S8MzJ63zKrXni5rcrXSJ5pyoqvQ2")
              .collection('my_services')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // DISPLAY CUSTOM LOADING INDICATOR
              return const CustomLoadingIndicator();
            }
            // IF FETCHING DATA HAS ERROR EXECUTE THIS
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // CHECK IF THERE IS AVAILABLE SERVICES
            if (snapshot.data?.docs.isEmpty ?? true) {
              // DISPLAY THERE IS NO AVAILABLE SERVICES
              return const NoServiceAvailable();
            } else {
              // DISPLAY AVAILABLE SERVICES: AS GRIDVIEW
              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // NUMBER OF COLUMNS
                  crossAxisSpacing: 5, // HORIZONTAL SPACE BETWEEN CARDS
                  mainAxisSpacing: 5, // VERTICAL SPACE BETWEEN CARDS
                  childAspectRatio: 0.75, // ASPECT RATIO OF EACH CARD
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var service = snapshot.data!.docs[index];

                  return ClientServiceCard(
                    service: service,
                    onPressed: () {
                      // UPDATE THE DATA OF SERVICE
                      String serviceID = service.id;
                      navigateWithSlideFromRight(
                        context,
                        RequestServiceScreen(
                          receiveServiceID: serviceID,
                        ),
                        0.0,
                        1.0,
                      );
                      debugPrint("==== $serviceID");
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
