import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:putatanapk/services/admin_services.dart';
import 'package:putatanapk/services/firebase_services.dart';
import 'package:putatanapk/ui/screens/admin/my_services/offered_services.dart';
import 'package:putatanapk/ui/widgets/buttons/custom_button.dart';
import 'package:putatanapk/ui/widgets/input_fields/custom_text_field.dart';
import 'package:putatanapk/ui/widgets/modals/custom_modal_information.dart';

class AddHotline extends StatefulWidget {
  const AddHotline({super.key});

  @override
  State<AddHotline> createState() => _AddHotlineState();
}

class _AddHotlineState extends State<AddHotline> {
  // CONTROLLERS
  final _contactNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _imageURLController = TextEditingController();

  // FORM KEY DECLARATION
  final formKey = GlobalKey<FormState>();

  // VARIABLE DECLARATIONS
  PlatformFile? selectedImage;
  String? imageURL;
  String? oldImage;

  // FOCUS NODE DECLARATION
  final _contactNameFocusNode = FocusNode();
  final _contactNumberFocusNode = FocusNode();

  // DISPOSE
  @override
  void dispose() {
    _contactNameController.dispose();
    _contactNumberController.dispose();
    _contactNameFocusNode.dispose();
    _contactNumberFocusNode.dispose();
    _imageURLController.dispose();
    super.dispose();
  }

  // FRONT VIEW IMAGE
  void handleImageSelection() async {
    final selected = await ProviderServices.selectImage();
    if (selected != null) {
      setState(() {
        selectedImage = selected;
      });
    }
  }

  // METHOD THAT WILL CREATE SERVICE
  void handleCreateService() async {
    await FirebaseService.createContact(
      context: context,
      formKey: formKey,
      contactName: _contactNameController.text,
      contactNumber: _contactNumberController.text,
      contactImage: selectedImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        if (_) {
          return;
        }
        showConfirmationModal(
          context,
          'You are about to discard this listing.',
          'Discard',
          const MyServices(),
        );
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
                'You are about to discard this listing.',
                'Discard',
                const MyServices(),
              );
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 25,
            ),
          ),
          centerTitle: true,
          title: const Text(
            "Service Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3C3C40),
            ),
          ),
        ),
        body: ListView(
          children: <Widget>[
            // FORM
            Form(
              key: formKey,
              child: Container(
                width: MediaQuery.of(context).size.width,
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

                    // TEXT FIELD: CONTACT NAME
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
                      hintText: "Enter Contact name",
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

                    // TEXT FIELD: CONTACT NUMBER
                    CustomTextField(
                      controller: _contactNumberController,
                      currentFocusNode: _contactNumberFocusNode,
                      nextFocusNode: null,
                      keyBoardType: TextInputType.number,
                      inputFormatters: null,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Contact number is required";
                        }
                        return null;
                      },
                      hintText: "Enter Contact number",
                      minLines: 1,
                      maxLines: 1,
                      isPassword: false,
                    ),

                    // SIZED BOX: SPACING
                    const SizedBox(height: 10),

                    // LABEL: DISPLAY PHOTO
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
                          // Set color for enabled state
                          width: 1.5, // Set width for enabled state
                        ),
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 125),
                      ),
                      onPressed: () {
                        if (selectedImage == null) {
                          handleImageSelection();
                        }
                      },
                      child: selectedImage != null
                          ? Stack(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(selectedImage!.path!),
                                    // Use the path of the selected image
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
                      onPressed: handleCreateService,
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
        ),
      ),
    );
  }
}
