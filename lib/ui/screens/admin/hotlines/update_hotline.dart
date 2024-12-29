import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:putatanapk/services/admin_services.dart';
import 'package:putatanapk/services/firebase_services.dart';
import 'package:putatanapk/ui/screens/admin/hotlines/hotlines_available.dart';
import 'package:putatanapk/ui/widgets/buttons/custom_button.dart';
import 'package:putatanapk/ui/widgets/input_fields/custom_text_field.dart';
import 'package:putatanapk/ui/widgets/modals/custom_modal_information.dart';

class EditHotline extends StatefulWidget {
  final String contactID;

  const EditHotline({
    required this.contactID,
    super.key,
  });

  @override
  State<EditHotline> createState() => _EditHotlineState();
}

class _EditHotlineState extends State<EditHotline> {
  final _contactNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _contactImageController = TextEditingController();

  final _contactNameFocusNode = FocusNode();
  final _contactNumberFocusNode = FocusNode();

  PlatformFile? selectedImage;
  String? imageURL;
  String? oldImageURL;
  bool isLoading = true;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getContacts();
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactNumberController.dispose();
    _contactImageController.dispose();
    _contactNameFocusNode.dispose();
    _contactNumberFocusNode.dispose();
    super.dispose();
  }

  void getContacts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await FirebaseService.getContacts(widget.contactID);
      setState(() {
        _contactNameController.text = data['contactName']?.toString() ?? '';
        _contactNumberController.text = data['contactNumber']?.toString() ?? '';
        imageURL = data['contactImage'];
        oldImageURL = imageURL;

        _contactImageController.text = data['contactImage'];
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching contact: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleImageSelection() async {
    final selected = await ProviderServices.selectImage();
    if (selected != null) {
      setState(() {
        selectedImage = selected;
      });
    }
  }



  void handleUpdateContact() async {
    await FirebaseService.updateContact(
        context: context,
        formKey: formKey,
        contactID: widget.contactID,
        contactName: _contactNameController.text,
        contactNumber: _contactNumberController.text,
        oldContactImageURL: oldImageURL,
        contactImage: selectedImage,
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showConfirmationModal(
          context,
          'You are about to discard this listing.',
          'Discard',
          const MyContacts(),
        );
        return false;
      },
      child: Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF5F5F5),
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                showConfirmationModal(
                  context,
                  'You are about to discard this update.',
                  'Discard',
                  const MyContacts(),
                );
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 25,
              ),
            ),
            centerTitle: true,
            title: const Text(
              "Update information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3C3C40),
              ),
            ),
          ),
          body: isLoading
              ? Center(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              width: 60,
              height: 60,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: [Color(0xFF002091)],
              ),
            ),
          )
              : ListView(
            children: <Widget>[
              Form(
                key: formKey,
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // SIZED BOX: SPACING
                      const SizedBox(height: 10),

                      // LABEL: CONTACT NAME
                      const Text(
                        "Contact Name",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF242424),
                        ),
                      ),

                      // SIZED BOX: SPACING
                      const SizedBox(height: 2),

                      // TEXT FIELD: SERVICE NAME
                      CustomTextField(
                        controller: _contactNameController,
                        currentFocusNode: _contactNameFocusNode,
                        nextFocusNode: _contactNumberFocusNode,
                        keyBoardType: null,
                        inputFormatters: null,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Contact name is required";
                          }
                          return null;
                        },
                        hintText: "Enter contact name",
                        minLines: 1,
                        maxLines: 1,
                        isPassword: false,
                      ),

                      const SizedBox(height: 10),
                      // LABEL: CONTACT NUMBER
                      const Text(
                        "Contact Number",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF242424),
                        ),
                      ),

                      // SIZED BOX: SPACING
                      const SizedBox(height: 2),

                      // TEXT FIELD: SERVICE NAME
                      CustomTextField(
                        controller: _contactNumberController,
                        currentFocusNode: _contactNumberFocusNode,
                        nextFocusNode: null,
                        keyBoardType: null,
                        inputFormatters: null,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Service name is required";
                          }
                          return null;
                        },
                        hintText: "Enter service name",
                        minLines: 1,
                        maxLines: 1,
                        isPassword: false,
                      ),

                      const SizedBox(height: 10),

                      // LABEL: CONTACT IMAGE
                      const Text(
                        "Contact Image",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF242424),
                        ),
                      ),

                      // SIZED BOX: SPACING
                      const SizedBox(height: 2),
                      // UPLOAD IMAGE CONTAINER
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFBDBDC7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: const BorderSide(
                            color: Color(0xFFBDBDC7),
                            width: 1.5,
                          ),
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 125),
                        ),
                        onPressed: handleImageSelection,
                        child: selectedImage != null
                            ? Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius:
                              BorderRadius.circular(10),
                              child: Image.file(
                                File(selectedImage!.path!),
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 11,
                              top: 10,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedImage = null;
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(5),
                                    child: const Icon(
                                      Icons.clear_rounded,
                                      color: Color(0xFFF5F5F5),
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                            : imageURL != null
                            ? ClipRRect(
                          borderRadius:
                          BorderRadius.circular(10),
                          child: Image.network(
                            imageURL!,
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                            : const Center(
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.add_a_photo_rounded,
                                color: Colors.grey,
                              ),
                              Text(
                                "Select Image",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // SIZED BOX: SPACING
                      const SizedBox(height: 20),

                      // BUTTON: SAVE PHONE NUMBER
                      CustomButton(
                        buttonLabel: "Publish",
                        onPressed: handleUpdateContact,
                        buttonHeight: 55,
                        buttonColor: const Color(0xFF002091),
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        fontColor: Colors.white,
                        borderRadius: 10,
                      ),

                      // SIZED BOX: SPACING
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
