import 'dart:io';

import 'package:dropbox_client/dropbox_client.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_controller.dart';
// import 'package:percent_indicator/percent_indicator.dart';
import 'package:photo_lab/src/helpers/toast.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:photo_lab/src/widgets/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/helpers.dart';
import '../../../models/user.dart';

class DropboxUploadScreen extends StatefulWidget {
  final int bookingId;
  final int photographerId;

  const DropboxUploadScreen(
      {Key? key, required this.bookingId, required this.photographerId})
      : super(key: key);

  @override
  State<DropboxUploadScreen> createState() => _DropboxUploadScreenState();
}

class _DropboxUploadScreenState extends State<DropboxUploadScreen>
    with WidgetsBindingObserver {
  String? accessToken;
  String? credentials;
  bool showInstruction = false;
  bool isFileSelected = false;
  File? selectedFile;
  bool isUploading = false;
  double progress = 0;
  // bool isLoading = false;
  // bool isBookingUpdatedSuccessfully = false;

  int step = 0;

  //late SharedPreferences prefs;

  Future initDropbox() async {
    debugLog('init dropbox');
    // init dropbox client. (call only once!)
    // prefs = await SharedPreferences.getInstance();
    await Dropbox.init(kDropboxClientId, kDropboxAppKey, kDropboxSecret);
    /*accessToken = prefs.getString('dropboxAccessToken');
    credentials = prefs.getString('dropboxCredentials');
    debugLog('token: $accessToken');
    debugLog('creds: $credentials');*/
    await checkAuthorized(false);
    setState(() {});
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<bool> checkAuthorized(bool authorize) async {
    final creds = await Dropbox.getCredentials();
    if (creds != null) {
      debugLog('creds not null');
      if (credentials == null || creds.isEmpty) {
        credentials = creds;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('dropboxCredentials', credentials!);
        setState(() {});
      }
      listFolder('');
      return true;
    }
    debugLog('creds is null');

    final token = await Dropbox.getAccessToken();
    debugLog('token : $token');
    if (token != null) {
      debugLog('token not null');
      if (accessToken == null || accessToken!.isEmpty) {
        accessToken = token;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('dropboxAccessToken', accessToken!);
        setState(() {});
      }
      listFolder('');
      return true;
    }
    debugLog('both are null');
    if (authorize) {
      if (credentials != null && credentials!.isNotEmpty) {
        await Dropbox.authorizeWithCredentials(credentials!);
        final creds = await Dropbox.getCredentials();
        if (creds != null) {
          debugLog('authorizeWithCredentials!');
          return true;
        }
      }
      if (accessToken != null && accessToken!.isNotEmpty) {
        await Dropbox.authorizeWithAccessToken(accessToken!);
        final token = await Dropbox.getAccessToken();
        if (token != null) {
          debugLog('authorizeWithAccessToken!');
          return true;
        }
      } else {
        await Dropbox.authorize();
        debugLog('authorize!');
      }
    }
    return false;
  }

  Future authorize() async {
    debugLog('before auth');
    await Dropbox.authorize();
    String? token = await Dropbox.getAccessToken();
    debugLog('after authorize: $token');
  }

  Future pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'rar', 'tar', 'tar.gz', 'jpg', 'png']);

    if (result != null) {
      String? selectedPath = result.files.single.path;
      if (selectedPath == null) {
        return;
      }
      File file = File(selectedPath);
      debugLog('file: ${file.path}');
      selectedFile = file;
      setState(() {
        isFileSelected = true;
      });
    }
  }

  Future authorizePKCE() async {
    await Dropbox.authorizePKCE();
  }

  Future unlinkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('dropboxAccessToken');

    setState(() {
      accessToken = null;
    });
    await Dropbox.unlink();
  }

  Future unlinkCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('dropboxCredentials');

    setState(() {
      credentials = null;
    });
    await Dropbox.unlink();
  }

  Future authorizeWithAccessToken() async {
    await Dropbox.authorizeWithAccessToken(accessToken!);
  }

  Future authorizeWithCredentials() async {
    await Dropbox.authorizeWithCredentials(credentials!);
  }

  Future getAccountName() async {
    if (await checkAuthorized(true)) {
      final user = await Dropbox.getAccountName();
      debugLog('user = $user');
    }
  }

  Future listFolder(path) async {
    debugLog('list folder');
    /*if (await checkAuthorized(false)) {
      final result = await Dropbox.listFolder(path);
      setState(() {
        debugLog(result);
        */ /* list.clear();
        list.addAll(result); */ /*
      });
    }*/

    try {
      var result = await Dropbox.listFolder(path);
      debugLog(result.toString());
      //result = {};
      //List<dynamic> json = jsonDecode(result);
      // List<dynamic> json = result;
      //throw Exception('Expired');
    } catch (e, s) {
      //debugLog('unable to parse listfolder response');
      debugLog(s);
      /* prefs.remove("dropboxAccessToken");
      prefs.remove("dropboxCredentials"); */
      unlinkToken();
      unlinkCredentials();
    }
  }

  Future uploadTest() async {
    if (await checkAuthorized(true)) {
      //var tempDir = await getTemporaryDirectory();
      //var filepath = '${tempDir.path}/test_upload.txt';
      //File(filepath).writeAsStringSync('contents.. from ${Platform.isIOS ? 'iOS' : 'Android'}\n');
      if (selectedFile == null) {
        return;
      }
      String filePath = selectedFile!.path;
      String fileName =
          filePath.substring(filePath.lastIndexOf('/', filePath.length) + 1);
      debugLog('local file path: $filePath');
      debugLog('local file name: $fileName');
      setState(() {
        isUploading = true;
      });
      final result =
          await Dropbox.upload(filePath, '/$fileName', (uploaded, total) {
        debugLog('progress: ($uploaded / $total)');
        progress = uploaded / total * 100;
        debugLog('progress: $progress');
        setState(() {
          progress = progress.roundToDouble();
        });
      });
      debugLog('result:$result');
      setState(() {
        photorapherController.isLoading = true;
        photorapherController.isBookingUpdatedSuccessfully = false;
      });
      String? link = await Dropbox.getTemporaryLink('/$fileName');
      debugLog('link:$link');
      if (link != null) {
        dropboxlinkcont.text = link;
        setState(() {
          photorapherController.isLoading = false;
          isUploading = false;
        });
        //changeBookingStatus(widget.bookingId.toString(), 'completed', link);
      }
    }
  }

  Future downloadTest() async {
    if (await checkAuthorized(true)) {
      var tempDir = await getTemporaryDirectory();
      var filepath = '${tempDir.path}/test_download.zip'; // for iOS only!!
      debugLog(filepath);

      final result = await Dropbox.download('/file_in_dropbox.zip', filepath,
          (downloaded, total) {
        debugLog('progress $downloaded / $total');
      });

      debugLog(result);
      debugLog(File(filepath).statSync());
    }
  }

  Future<String?> getTemporaryLink(path) async {
    final result = await Dropbox.getTemporaryLink(path);
    return result;
  }

  User? loggedInUser;
  late PhotorapherController photorapherController;
  @override
  void initState() {
    super.initState();
    photorapherController =
        Provider.of<PhotorapherController>(context, listen: false);
    SessionHelper.getUser().then((loggedInUser) {
      if (loggedInUser != null) {
        setState(() {
          this.loggedInUser = loggedInUser;
        });
      }
    });
    initDropbox();
  }

  bool firstChecked = false;
  bool secondChecked = false;
  bool thirdChecked = false;
  var dropboxlinkcont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          // titleSpacing: 0,
          // leadingWidth: 50,
          iconTheme: Theme.of(context).iconTheme,
          elevation: 0,
          toolbarHeight: 60,
        ),
        body: Consumer<PhotorapherController>(
            builder: (context, photographercontroller, _) {
          return Padding(
            padding: const EdgeInsets.all(kScreenPadding),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Complete Service",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  10.SpaceY,
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Check the following boxses to complete the service",
                      style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
                    ),
                  ),
                  buildCheckBoxTile(
                      "I went to the avenue on time", firstChecked, () {
                    setState(() {
                      firstChecked = !firstChecked;
                    });
                  }),
                  buildCheckBoxTile(
                      "I stayed until my work is done", secondChecked, () {
                    setState(() {
                      secondChecked = !secondChecked;
                    });
                  }),
                  buildCheckBoxTile(
                      "I submit all the raw and edited images and photos to the client",
                      thirdChecked, () {
                    setState(() {
                      thirdChecked = !thirdChecked;
                    });
                  }),
                  SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    height: progress == 100 && !isUploading ? 0 : 60,
                  ),
                  ...isUploading
                      ? [
                          Center(
                            child: FractionallySizedBox(
                              widthFactor: 0.6,
                              child: CircularPercentIndicator(
                                radius: 60.0,
                                lineWidth: 5.0,
                                percent: progress / 100,
                                center: Text("$progress%"),
                                progressColor: Colors.green,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ...progress == 100 ? [] : []
                        ]
                      : [],
                  ...isFileSelected
                      ? [
                          ...progress == 100
                              ? [
                                  ...photographercontroller.isLoading
                                      ? [
                                          Spacer(),
                                          const Center(
                                              child: CircularProgressIndicator(
                                            color: AppColors.orange,
                                          )),
                                          Spacer(),
                                        ]
                                      : [
                                          ...photographercontroller
                                                  .isBookingUpdatedSuccessfully
                                              ? [
                                                  Spacer(),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom:
                                                                kDefaultSpace *
                                                                    2),
                                                    child: Center(
                                                      child: const Text(
                                                        'Thank You!\nYour delivery has been sent to client.',
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                  GradientButton(
                                                      text: 'OK',
                                                      onPress: () {
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      }),
                                                ]
                                              : [
                                                  Visibility(
                                                    visible: !isUploading,
                                                    child: PrimaryTextField1(
                                                      "Dropbox Link",
                                                      labelText:
                                                          "Uploaded file link",
                                                      suffixIcon: null,
                                                      prefixIcon: SizedBox(
                                                          height: 6,
                                                          child: Image.asset(
                                                              ImageAsset
                                                                  .dropboxicon)),
                                                      lines: 2,
                                                      controller:
                                                          dropboxlinkcont,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      onChange: (value) {
                                                        setState(() {
                                                          debugLog(
                                                              "dropboxlink${dropboxlinkcont.text}");
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Visibility(
                                                    visible: !isUploading,
                                                    child: GradientButton(
                                                        text:
                                                            'Complete Service',
                                                        onPress: () {
                                                          if (firstChecked ==
                                                                  false ||
                                                              secondChecked ==
                                                                  false ||
                                                              thirdChecked ==
                                                                  false) {
                                                            Toasty.error(
                                                                "Check all boxes to complete service");
                                                          } else {
                                                            photographercontroller
                                                                .changeBookingStatus(
                                                                    context,
                                                                    widget
                                                                        .bookingId
                                                                        .toString(),
                                                                    "completed",
                                                                    dropboxlinkcont
                                                                        .text,
                                                                    loggedInUser!
                                                                        .id,
                                                                    widget
                                                                        .photographerId);

                                                            // changeBookingStatus(
                                                            //     widget.bookingId
                                                            //         .toString(),
                                                            //     "completed",
                                                            //     dropboxlinkcont
                                                            //         .text);
                                                          }
                                                        }),
                                                  ),
                                                ]
                                        ]
                                ]
                              : [
                                  Spacer(),
                                  Visibility(
                                    visible: !isUploading,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GradientButton(
                                          text: 'Upload to dropbox',
                                          onPress: uploadTest,
                                        ),
                                        const SizedBox(height: 2),
                                        TextButton(
                                          onPressed: pickFile,
                                          child: const Text(
                                              'or tap here to choose another file'),
                                        ),
                                      ],
                                    ),
                                  )
                                ]
                        ]
                      : [
                          ...accessToken == null && credentials == null
                              ? [
                                  Spacer(),
                                  GradientButton(
                                    text: 'Connect Dropbox',
                                    onPress: authorize,
                                  ),
                                  Container(
                                    margin:
                                        const EdgeInsets.all(kScreenPadding),
                                    child: const Text(
                                        'If you don\'t have a Dropbox account then go to dropbox.com to create an account and then come back here to connect',
                                        textAlign: TextAlign.center),
                                  ),
                                ]
                              : [
                                  Spacer(),
                                  GradientButton(
                                    text: 'Pick file to upload',
                                    onPress: pickFile,
                                  ),
                                  Container(
                                    margin:
                                        const EdgeInsets.all(kScreenPadding),
                                    child: const Text(
                                        'Create a zip file containing the pictures of your assignment and upload here',
                                        textAlign: TextAlign.center),
                                  ),
                                ],
                        ]
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //do your stuff
      checkAuthorized(false);
    }
  }

  Widget buildCheckBoxTile(String title, bool checked, Function() onChanged) {
    return CheckboxListTile(
      title: Text(
        title,
        style: MyTextStyle.semiBoldBlack.copyWith(fontSize: 15),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      value: checked,
      onChanged: (value) => onChanged(),
      activeColor: Colors.transparent,
      checkColor: Colors.black,
      tileColor: checked ? Colors.white : Colors.transparent,
      checkboxShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
        side: BorderSide(
            color: AppColors.cardBackgroundColor,
            width: 1), // Border color (black here)
      ),
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
    );
  }
}

//ye primarytextfield mn edit krdena
//usr is liye nhi kya cz apny is screen ko copy krna tha

class PrimaryTextField1 extends StatelessWidget {
  final String hintText;
  final String? labelText;
  final bool hideText;
  final IconData? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType keyboardType;
  final int lines;
  final String? initialValue;
  final TextEditingController? controller;
  final void Function(String value)? onChange;
  final String? Function(String? value)? validator;
  final void Function()? onTap;
  final void Function()? suffixIconOnTap;
  final bool readOnly;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  const PrimaryTextField1(this.hintText,
      {this.hideText = false,
      this.labelText,
      this.prefixIcon,
      this.suffixIcon,
      this.lines = 1,
      this.onChange,
      this.validator,
      this.initialValue,
      this.textCapitalization = TextCapitalization.sentences,
      this.controller,
      this.readOnly = false,
      this.onTap,
      this.suffixIconOnTap,
      this.keyboardType = TextInputType.text,
      this.inputFormatters,
      this.focusNode,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: kDefaultSpace * 0.8,
        bottom: kDefaultSpace * 0.8,
      ),
      child: TextFormField(
        initialValue: initialValue,
        textCapitalization: keyboardType == TextInputType.emailAddress
            ? TextCapitalization.none
            : textCapitalization,
        style: MyTextStyle.mediumBlack.copyWith(fontSize: 16),
        controller: controller,
        obscureText: hideText,
        keyboardType: keyboardType,
        minLines: lines,
        maxLines: lines,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        focusNode: focusNode,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          // fillColor: kInputBackgroundColor,
          hintText: hintText,
          labelStyle: MyTextStyle.medium07Black.copyWith(fontSize: 16),
          hintStyle: MyTextStyle.medium07Black.copyWith(fontSize: 14),
          labelText: labelText,
          // filled: true,

          suffixIcon: suffixIcon == null
              ? null
              : InkWell(
                  onTap: suffixIconOnTap,
                  child: Icon(suffixIcon,
                      color: AppColors.black.withOpacity(0.5))),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(5.0),
            child: prefixIcon,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kInputBorderRadius),
            borderSide: BorderSide(
              //strokeAlign: StrokeAlign.center,
              width: 1,
              // color: kInputBackgroundColor.withOpacity(0.9),
            ),
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kInputBorderRadius),
              borderSide: BorderSide(width: 1, color: AppColors.lightGrey)),
        ),
        onChanged: onChange,
      ),
    );
  }
}
