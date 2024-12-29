import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:putatanapk/navigation/navigation_utils.dart';
import 'package:putatanapk/services/firebase_services.dart';
import 'package:putatanapk/ui/screens/admin/my_services/add_service.dart';
import 'package:putatanapk/ui/screens/admin/my_services/card/service_card.dart';
import 'package:putatanapk/ui/widgets/app_bar/custom_app_bar.dart';
import 'package:putatanapk/ui/widgets/buttons/custom_floating_action_button.dart';
import 'package:putatanapk/ui/widgets/loading_indicator/custom_loading_indicator_v2.dart';
import 'package:putatanapk/ui/widgets/modals/custom_modals.dart';
import 'package:putatanapk/ui/widgets/static_widget/no_service_available.dart';

import 'update_service.dart';

class MyServices extends StatefulWidget {
  const MyServices({super.key});

  @override
  State<MyServices> createState() => _MyServicesState();
}

class _MyServicesState extends State<MyServices> {


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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(AppBar().preferredSize.height),
          child: CustomAppBar(
              backgroundColor: const Color(0xFFF5F5F5),
              titleText: "My Services",
              onLeadingPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
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

                  return ServiceCard(
                    service: service,
                    onUpdate: () {
                      // UPDATE THE DATA OF SERVICE
                      String serviceID = service.id;
                      navigateWithSlideFromRight(
                        context,
                        UpdateService(
                          receiveServiceID: serviceID,
                        ),
                        0.0,
                        1.0,
                      );
                    },
                    onDelete: () async {
                      showDeleteWarning(
                        context,
                        'Are you sure you want to delete this service?',
                        'Delete',
                            (docID) =>
                            FirebaseService.deleteService(context, docID),
                        service.id,
                      );
                    },
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: CustomFloatingActionButton(
          color: const Color(0xFF002091),
          textLabel: "Add service",
          onPressed: () {
            navigateWithSlideFromRight(
              context,
              const AddService(),
              0.0,
              1.0,
            );
          },
        ),
      ),
    );
  }
}