import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:putatanapk/ui/screens/admin/hotlines/card/client_hotline_card.dart';
import 'package:putatanapk/ui/widgets/loading_indicator/custom_loading_indicator_v2.dart';
import 'package:putatanapk/ui/widgets/static_widget/no_service_available.dart';

class ClientEmergency extends StatefulWidget {
  const ClientEmergency({super.key});

  @override
  State<ClientEmergency> createState() => _ClientEmergencyState();
}

class _ClientEmergencyState extends State<ClientEmergency> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: const Text(
          "Emergency Hotlines",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("admin_accounts")
            .doc("emergency_hotlines")
            .collection('contact')
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
                crossAxisCount: 1, // NUMBER OF COLUMNS
                crossAxisSpacing: 10, // HORIZONTAL SPACE BETWEEN CARDS
                mainAxisSpacing: 5, // VERTICAL SPACE BETWEEN CARDS
                childAspectRatio: 4, // ASPECT RATIO OF EACH CARD
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var contactInfo = snapshot.data!.docs[index];

                return ClientHotlineCard(hotlineInfo: contactInfo);
              },
            );
          }
        },
      ),
    );
  }
}
