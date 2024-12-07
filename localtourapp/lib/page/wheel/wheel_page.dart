import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/HomePage/placeCard.dart';
import 'package:localtourapp/models/Tag/tag_model.dart';
import 'package:localtourapp/services/location_Service.dart';
import 'package:localtourapp/services/place_service.dart';
import 'package:localtourapp/services/tag_service.dart';

import '../../constants/getListApi.dart';
import '../detail_page/detail_page.dart';
import '../search_page/tags_modal.dart';

class WheelPage extends StatefulWidget {
  const WheelPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WheelPageState();
}

class _WheelPageState extends State<WheelPage> {
  final PlaceService _placeService = PlaceService();
  final LocationService _locationService = LocationService();
  final TagService _tagService = TagService();
  List<PlaceCardModel> _listPlaceCard = [];
  StreamController<int> controller = StreamController<int>();
  late Position _currentPosition;
  bool isLoading = true;
  String _languageCode = 'vi';
  final List<String> _listColorItems = [
    '3a86ff',
    '8338ec',
    'ff006e',
    'fb5607',
    'ffbe0b'
  ];
  int index = 0;
  List<TagModel> _listTags = [];
  List<int> selectedTags = [1019];
  int selectIndex = 2;
  bool isFirst = true;

  @override
  void initState() {
    super.initState();
    fetchInit();
  }

  Future<void> fetchInit() async {
    Position? position = await _locationService.getCurrentPosition();
    double long = position != null ? position.longitude : 106.8096761;
    double lat = position != null ? position.latitude : 10.8411123;

    if (position != null) {
      _currentPosition = position;
    } else {
      _currentPosition = Position(
          longitude: long,
          latitude: lat,
          timestamp: DateTime.timestamp(),
          accuracy: 1,
          altitude: 1,
          altitudeAccuracy: 1,
          heading: 1,
          headingAccuracy: 1,
          speed: 1,
          speedAccuracy: 1);
    }
    final fetchedListPlace = await _placeService.getListPlace(
        lat, long, SortBy.distance, SortOrder.asc, [], '', 1, 20);
    // final fetchedListPlace = await _placeService.getListPlace(lat, long, SortBy.distance,SortOrder.asc,[1019],'',1,20);

    setState(() {
      _listPlaceCard = fetchedListPlace;
      isLoading = false;
    });

    var languageCode =
        await SecureStorageHelper().readValue(AppConfig.language);

    if (languageCode != null) {
      setState(() {
        _languageCode = languageCode;
      });
    }

    var listTag = await _tagService.getTopTagPlace(10);
    if (listTag.isNotEmpty) {
      setState(() {
        _listTags = listTag;
      });
    }
  }

  void _generateCardInfoList() async {
    final fetchedListPlace = await _placeService.getListPlace(
        _currentPosition.latitude,
        _currentPosition.longitude,
        SortBy.distance,
        SortOrder.asc,
        selectedTags,
        '',
        1,
        20);
    setState(() {
      _listPlaceCard = fetchedListPlace;
    });
  }

  Color getRandomColor() {
    final randomIndex = index % _listColorItems.length;
    index++;
    final colorHex = _listColorItems[randomIndex];
    return Color(int.parse('0xFF$colorHex'));
  }

  void _spinWheel() {
    int selected = Random().nextInt(_listPlaceCard.length);
    controller.add(selected);
    selectIndex = selected;
  }

  void _showResultDialog(int index) {
    if (isFirst) {
      isFirst = false;
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.yellowAccent.shade100,
          title: Text(_languageCode == 'vi'
              ? 'Thần linh chọn cho ta!'
              : "God chooses for us!"),
          content: Text(
            _listPlaceCard[index].placeName,
            style: const TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 35),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetailPage(placeId: _listPlaceCard[index].placeId),
                  ),
                );
              },
              child: Text(_languageCode == 'vi'
                  ? 'Tới trang chi tiết'
                  : 'Go to detail'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _listPlaceCard.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: Text(_languageCode == 'vi' ? 'Xóa' : 'Delete'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text(
              _languageCode == 'vi' ? "Hôm nay ăn gì?" : "What to eat today?"),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(
                      width: 150,
                      child: OutlinedButton(
                        onPressed: () {
                          showTagsModal(
                            context: context,
                            selectedTags: selectedTags,
                            listTags: _listTags,
                            onSelectedTagsChanged: (updatedTags) {
                              setState(() {
                                selectedTags = updatedTags;
                                _generateCardInfoList();
                              });
                            },
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFD6B588)),
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _languageCode == 'vi' ? "Thể loại" : 'Type',
                              style: const TextStyle(color: Colors.black),
                            ),
                            const Icon(Icons.arrow_forward,
                                color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 400,
                      width: 400,
                      child: FortuneWheel(
                        selected: controller.stream,
                        physics: CircularPanPhysics(
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeOut,
                        ),
                        onFling: _spinWheel,
                        onAnimationStart: () {},
                        onAnimationEnd: () {
                          _showResultDialog(selectIndex);
                        },
                        indicators: const <FortuneIndicator>[
                          FortuneIndicator(
                            alignment: Alignment.topCenter,
                            child: TriangleIndicator(
                              color: Colors.green,
                              width: 30.0,
                              height: 40.0,
                              elevation: 1.2,
                            ),
                          ),
                        ],
                        items: _listPlaceCard
                            .map((item) => FortuneItem(
                                onLongPress: _spinWheel,
                                style: FortuneItemStyle(
                                  color: getRandomColor(),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                        width: 50,
                                        child: Text(
                                          item.placeName,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: item.placeId % 2 == 1
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 8),
                                        )),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    ClipOval(
                                      child: Image.network(
                                        item.photoDisplayUrl,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit
                                            .cover, // Đảm bảo ảnh phủ đầy khu vực
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    )
                                  ],
                                )))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _spinWheel,
                      child: Text(_languageCode == 'vi' ? 'Xoay' : 'Spin'),
                    ),
                  ],
                ),
              ));
  }
}
