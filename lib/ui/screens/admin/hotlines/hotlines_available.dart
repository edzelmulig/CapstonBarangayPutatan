import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:putatanapk/navigation/navigation_utils.dart';
import 'package:putatanapk/services/firebase_services.dart';
import 'package:putatanapk/ui/screens/admin/hotlines/add_hotline.dart';
import 'package:putatanapk/ui/screens/admin/hotlines/card/hotline_card.dart';
import 'package:putatanapk/ui/screens/admin/hotlines/update_hotline.dart';
import 'package:putatanapk/ui/screens/admin/my_services/add_service.dart';
import 'package:putatanapk/ui/widgets/app_bar/custom_app_bar.dart';
import 'package:putatanapk/ui/widgets/buttons/custom_floating_action_button.dart';
import 'package:putatanapk/ui/widgets/loading_indicator/custom_loading_indicator_v2.dart';
import 'package:putatanapk/ui/widgets/modals/custom_modals.dart';
import 'package:putatanapk/ui/widgets/static_widget/no_service_available.dart';

class MyContacts extends StatefulWidget {
  const MyContacts({super.key});

  @override
  State<MyContacts> createState() => _MyContactsState();
}

class _MyContactsState extends State<MyContacts> {


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
              titleText: "My Contacts",
              onLeadingPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }),
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
                  mainAxisSpacing: 10, // VERTICAL SPACE BETWEEN CARDS
                  childAspectRatio: 3, // ASPECT RATIO OF EACH CARD
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var contactInfo = snapshot.data!.docs[index];

                  return HotlineCard(
                    hotlineInfo: contactInfo,
                    onUpdate: () {
                      // UPDATE THE DATA OF SERVICE
                      String contactID = contactInfo.id;
                      navigateWithSlideFromRight(
                        context,
                        EditHotline(
                          contactID: contactID,
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
                            (contactID) =>
                            FirebaseService.deleteContact(context, contactID),
                        contactInfo.id,
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
          textLabel: "Add Contact Hotline",
          onPressed: () {
            navigateWithSlideFromRight(
              context,
              const AddHotline(),
              0.0,
              1.0,
            );
          },
        ),
      ),
    );
  }
}