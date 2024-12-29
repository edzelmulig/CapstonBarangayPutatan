import 'package:flutter/material.dart';
import 'package:putatanapk/navigation/navigation_utils.dart';
import 'package:putatanapk/ui/screens/admin/hotlines/hotlines_available.dart';
import 'package:putatanapk/ui/screens/admin/my_services/offered_services.dart';
import 'package:putatanapk/ui/screens/admin/my_transactions/view_all_transactions.dart';
import 'package:putatanapk/ui/widgets/buttons/custom_button_with_numbers.dart';
import 'package:putatanapk/ui/widgets/images/custom_icon.dart';

// DASHBOARD HEADER CLASS
class AdminDashboardHeader extends StatefulWidget {
  final int numberOfAppointments;
  final int numberOfServices;

  const AdminDashboardHeader({
    super.key,
    required this.numberOfAppointments,
    required this.numberOfServices,
  });

  @override
  State<AdminDashboardHeader> createState() => _AdminDashboardHeaderState();
}

class _AdminDashboardHeaderState extends State<AdminDashboardHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              margin: const EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  // NEW APPOINTMENTS AND MY SERVICES
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      // APPOINTMENT BUTTON
                      CustomButtonWithNumber(
                        // NAVIGATE TO MY SERVICES SCREEN
                        numberOfServices: 0,
                        buttonText: "Transactions",
                        onPressed: () {
                          navigateWithSlideFromRight(
                            context,
                            const ViewAllTransactions(),
                            1.0,
                            0.0,
                          );
                        },
                      ),

                      // SIZED BOX: SPACING
                      const SizedBox(width: 10),

                      // SERVICES BUTTON
                      CustomButtonWithNumber(
                        numberOfServices: widget.numberOfServices,
                        buttonText: "Services",
                        onPressed: () {
                          // NAVIGATE TO MY SERVICES SCREEN
                          navigateWithSlideFromRight(
                            context,
                            const MyServices(),
                            1.0,
                            0.0,
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  InkWell(
                    onTap: () {
                      navigateWithSlideFromRight(
                        context,
                        const MyContacts(),
                        1.0,
                        0.0,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 55,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        // Center the content inside the container
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          // Make the row as small as its content
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                // White background for the icon
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(6),
                              // Add some padding around the icon
                              child: const CustomIcon(
                                imagePath: 'lib/ui/assets/emergency_icon.png',
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Add spacing between the icon and text
                            const Text(
                              'Emergency Hotlines',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
