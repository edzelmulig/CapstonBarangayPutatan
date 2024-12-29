import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:putatanapk/ui/screens/client/transaction_card.dart';
import 'package:putatanapk/ui/widgets/loading_indicator/custom_loading_indicator_v2.dart';
import 'package:putatanapk/ui/widgets/snackbar/custom_snackbar.dart';

class ClientTransactions extends StatefulWidget {
  const ClientTransactions({super.key});

  @override
  State<ClientTransactions> createState() => _ClientTransactionsState();
}

class _ClientTransactionsState extends State<ClientTransactions> {
  // Variable to store the list of transactions
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    // Fetch the transactions when the widget is initialized
    getTransactions();
  }

  // Method to fetch transactions from Firestore
  Future<void> getTransactions() async {
    try {
      // Get the current user's UID
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        // Handle case when the user is not logged in
        if (context.mounted) {
          showFloatingSnackBar(
            context,
            "User not logged in.",
            const Color(0xFFe91b4f),
          );
        }
        return;
      }

      // Fetch the transactions from Firestore for the current user
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId) // Use the current user's UID here
          .collection('my_transactions')
          .get();

      // Convert the fetched data into a list of maps
      List<Map<String, dynamic>> fetchedTransactions = snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      // Debug print the fetched transactions
      debugPrint("Fetched Transactions: $fetchedTransactions");

      // Update the state with the fetched transactions
      setState(() {
        transactions = fetchedTransactions;
      });
    } catch (e) {
      // Handle error (for example, show an error message)
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "Error fetching transactions: ${e.toString()}",
          const Color(0xFFe91b4f),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF002091),
        centerTitle: true,
        title: const Text(
          "My Transactions",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Colors.white,
          ),
        ),
      ),
      body: transactions.isEmpty
          ? const Center(
              child:
                  CustomLoadingIndicator()) // Show a loading indicator while fetching data
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                var transaction = transactions[index];

                // Print the transaction data here to debug
                debugPrint("Transaction $index: $transaction");

                // Ensure the required fields exist before passing them to the TransactionCard
                return ClientTransactionCard(
                  imageURL:
                      transaction['imageURL'] ?? 'lib/ui/assets/no_image.jpeg',
                  // Default image URL if not found
                  serviceName: transaction['serviceName'] ?? 'No Service Name',
                  status: transaction['status'] ?? 'No Status',
                  dateOfTransaction: transaction['dateOfTransaction'],
                  price: transaction['price'],
                );
              },
            ),
    );
  }
}
