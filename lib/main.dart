import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:text_recognition/adHelper/ad_helper.dart';
import 'package:text_recognition/widgets/text_area_widget.dart';
import 'package:translator/translator.dart';

import 'api/firebase_ml_api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Text Recognition',
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: MainPage(),
      );
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  File? image;
  String text = '';
  final FlutterTts flutterTts = FlutterTts();
  var translator = GoogleTranslator();

  var translatedPhrase = '';

  final myBanner = BannerAd(
    adUnitId: AdHelper.bannerAdUnitId,
    size: AdSize.banner,
    request: AdRequest(),
    listener: AdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (Ad ad) => print('Ad loaded.'),
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        print('Ad failed to load: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) => print('Ad opened.'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) => print('Ad closed.'),
      // Called when an ad is in the process of leaving the application.
      onApplicationExit: (Ad ad) => print('Left application.'),
    ),
  );

  @override
  void initState() {
    myBanner.load();
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: Duration(milliseconds: 260),
    // );

    super.initState();
  }

  Future pickImage() async {
    final file = await ImagePicker().getImage(source: ImageSource.gallery);
    setImage(File(file!.path));
  }

  void setImage(File? newImage) {
    setState(() {
      image = newImage!;
    });
  }

  Widget buildImage() => Container(
        child: image != null
            ? Image.file(image!)
            : Icon(Icons.photo, size: 100, color: Colors.black),
      );

  Future scanText() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Center(
          child: CircularPercentIndicator(
            radius: 60.0,
            lineWidth: 5.0,
            percent: 1.0,
            center: Text('100%'),
            progressColor: Colors.indigo,
          ),
        ),
      ),
    );

    final text = await FirebaseMLApi.recogniseText(image!);
    setText(text);

    Navigator.of(context).pop();
  }

  void setText(String newText) {
    setState(() {
      text = newText;
    });
  }

  void copyToClipboard() {
    if (text.trim() != '') {
      FlutterClipboard.copy(text);
    }
  }

  Future _speak({String? text}) async {
    print(await flutterTts.getLanguages);
    await flutterTts.setLanguage('en-IN');
    await flutterTts.setPitch(1);
    await flutterTts.speak(text!);
  }

  Future _speakBangla({String? text}) async {
    print(await flutterTts.getLanguages);
    await flutterTts.setLanguage('bn-BD');
    await flutterTts.setPitch(1);
    await flutterTts.speak(text!);
  }

  void clear() {
    setImage(null);
    setText('');
    translatedPhrase = '';
    _speak(text: '');
    _speakBangla(text: '');
  }

  @override
  void dispose() {
    myBanner.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Text Recognition'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              print('height------ ${constraints.maxHeight}');
              if (constraints.maxHeight > 600) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: myBanner.size.height.toDouble(),
                        width: myBanner.size.width.toDouble(),
                        child: AdWidget(
                          ad: myBanner,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        height: 200,
                        child: buildImage(),
                      ),
                      SizedBox(height: 5),
                      TextAreaWidget(
                        text: text,
                        onClickedCopy: copyToClipboard,
                        onSpeak: () => _speak(text: text),
                      ),
                      // SizedBox(
                      //   height: 5,
                      // ),
                      // Row(
                      //   children: [
                      //     Card(
                      //       child: Container(
                      //         height: 150,
                      //         width: 307,
                      //         alignment: Alignment.center,
                      //         color: Colors.white54,
                      //         child: SingleChildScrollView(
                      //           child: SelectableText(
                      //             translatedPhrase.isEmpty
                      //                 ? "Tap Translate Button after scan"
                      //                 : translatedPhrase,
                      //             textAlign: TextAlign.center,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(
                      //       width: 10,
                      //     ),
                      // Column(
                      //   children: [
                      //     IconButton(
                      //         icon: Icon(Icons.copy, size: 15),
                      //         onPressed: () {
                      //           Clipboard.setData(
                      //               ClipboardData(text: translatedPhrase));
                      //         }),
                      //     IconButton(
                      //       icon: Icon(Icons.volume_up),
                      //       onPressed: () =>
                      //           _speakBangla(text: translatedPhrase),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  Container(
                    height: myBanner.size.height.toDouble(),
                    width: myBanner.size.width.toDouble(),
                    child: AdWidget(
                      ad: myBanner,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    height: 200,
                    child: buildImage(),
                  ),
                  SizedBox(height: 5),
                  TextAreaWidget(
                    text: text,
                    onClickedCopy: copyToClipboard,
                    onSpeak: () => _speak(text: text),
                  ),
                  // SizedBox(
                  //   height: 5,
                  // ),
                  // Row(
                  //   children: [
                  //     Card(
                  //       child: Container(
                  //         height: 150,
                  //         width: 307,
                  //         alignment: Alignment.center,
                  //         color: Colors.white54,
                  //         child: SingleChildScrollView(
                  //           child: SelectableText(
                  //             translatedPhrase.isEmpty
                  //                 ? "Tap Translate Button after scan"
                  //                 : translatedPhrase,
                  //             textAlign: TextAlign.center,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       width: 10,
                  //     ),
                  // Column(
                  //   children: [
                  //     IconButton(
                  //         icon: Icon(Icons.copy, size: 15),
                  //         onPressed: () {
                  //           Clipboard.setData(
                  //               ClipboardData(text: translatedPhrase));
                  //         }),
                  //     IconButton(
                  //       icon: Icon(Icons.volume_up),
                  //       onPressed: () =>
                  //           _speakBangla(text: translatedPhrase),
                  //     ),
                  //   ],
                  // ),
                  // ],
                  // ),
                ],
              );
            },
          ),
        ),
        floatingActionButton: SpeedDial(
          marginEnd: 18,
          marginBottom: 20,
          icon: Icons.menu,
          backgroundColor: Colors.indigo,
          children: [
            SpeedDialChild(
              labelBackgroundColor: Colors.white,
              child: Icon(Icons.image),
              label: 'Pick Image',
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              onTap: () {
                pickImage();
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.scanner),
              labelBackgroundColor: Colors.white,
              label: 'Scan For Text',
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              onTap: () {
                scanText();
              },
            ),
          ],
        ),
        // floatingActionButton: FloatingActionBubble(
        // backGroundColor: Colors.blue,
        // items: <Bubble>[
        // Bubble(
        //   title: 'Pick Image',
        //   iconColor: Colors.white,
        //   bubbleColor: Colors.indigo,
        //   icon: Icons.image,
        //   titleStyle: TextStyle(fontSize: 16, color: Colors.white),
        //   onPress: () {
        //     pickImage();
        // _animationController.reverse();
        //   },
        // ),
        // Bubble(
        //   title: 'Scan For Text',
        //   iconColor: Colors.white,
        //   bubbleColor: Colors.indigo,
        //   icon: Icons.scanner,
        //   titleStyle: TextStyle(fontSize: 16, color: Colors.white),
        //   onPress: () {
        //     scanText();
        //     _animationController.reverse();
        //   },
        // ),
        // Bubble(
        //   title: "Translate",
        //   iconColor: Colors.white,
        //   bubbleColor: Colors.indigo,
        //   icon: Icons.scanner,
        //   titleStyle: TextStyle(fontSize: 16, color: Colors.white),
        //   onPress: () {
        //     setState(() {
        //       translator.translate(text, from: "en", to: "bn").then((t) {
        //         setState(() {
        //           translatedPhrase = t.toString();
        //         });
        //       });
        //     });
        //     _animationController.reverse();
        //   },
        // ),
        // Bubble(
        //   title: 'Clear',
        //   iconColor: Colors.white,
        //   bubbleColor: Colors.indigo,
        //   icon: Icons.clear,
        //   titleStyle: TextStyle(fontSize: 16, color: Colors.white),
        //   onPress: () {
        //     clear();
        //     _animationController.reverse();
        //   },
        // ),
        // ],
        // animation: _animation,
        // onPress: _animationController.isCompleted
        //     ? _animationController.reverse
        //     : _animationController.forward,
        // iconColor: Colors.indigo,
        // animatedIconData: AnimatedIcons.add_event,
        // icon: AnimatedIcons.add_event,
        // ),
      );
}
