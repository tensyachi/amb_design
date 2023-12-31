// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, curly_braces_in_flow_control_structures

import 'dart:convert';

import 'package:emergenshare_amb/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

class Patient_Info extends StatefulWidget {
  const Patient_Info({super.key});

  @override
  State<Patient_Info> createState() => _Patient_InfoState();
}

class _Patient_InfoState extends State<Patient_Info>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      //do remove data
      firestore.collection("AMB").doc(carCode + patientName).delete().then(
          (doc) {
        print("Deleted");
      }, onError: (e) => displayToast("Error: " + e, true));
    }
  }

  // 위 세 함수는 중간에 끌 시(절대로 백그라운드가 아님, 그것마저도 꺼질때) DB 지워주는거임

  // 이름 나이
  TextEditingController patientName = TextEditingController();
  TextEditingController patientAge = TextEditingController();

  //KTAS 토글버튼
  var sliderValue = 1.0;
  List<bool> KTAS = [true, false, false, false, false];

  Color kc(double num) {
    switch (num) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.red;
      case 3:
        return Color.fromARGB(181, 255, 226, 59);
      case 4:
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  bool gen = false;
  String sex = "여성";

  //환자 정보 글
  TextEditingController patientInfo = TextEditingController();

  //혈액형
  final _bloodType = [
    "Rh+A",
    "Rh-A",
    "Rh+B",
    "Rh-B",
    "Rh+AB",
    "Rh-AB",
    "Rh+O",
    "Rh-O",
    "Rare",
    "???"
  ];
  var bloodTypeSelected = "???";

  // 태그 모음
  final _tags = [
    "화상",
    "동상",
    "외상",
    "수술 필요",
    "신경 마비",
    "파상풍 우려",
    "심장",
    "뇌손상",
    "절단",
    "관통",
    "무의식",
    "빈혈",
    "쇼크",
    "두통",
    "오한",
    "맹장염",
    "골절",
    "심한 출혈",
    "교통사고",
    "저체온증",
    "저혈압",
  ];
  final List<bool> chips = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  int chipnum = 0;
  Widget _buildChips() {
    List<Widget> symchip = [];

    for (int i = 0; i < _tags.length; i++) {
      FilterChip filterChip = FilterChip(
        selected: chips[i],
        label: Text(_tags[i],
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
        shadowColor: Colors.teal,
        backgroundColor: Colors.black26,
        selectedColor: Colors.blue,
        onSelected: (bool selected) {
          setState(() {
            if (selected == false) {
              chips[i] = selected;
              ftag.remove(_tags[i]);
              chipnum--;
            } else if (chipnum >= 3) {
              Fluttertoast.showToast(msg: '현재는 3개 이상 선택할 수 없습니다.');
            } else {
              chips[i] = selected;
              ftag.add(_tags[i]);
              chipnum++;
            }
          });
        },
      );

      symchip.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 10), child: filterChip));
    }

    return Wrap(children: symchip);
  }

  List<String> ftag = [];

  String tags1 = "???";
  String tags2 = "???";
  String tags3 = "???";

  String? DBCAR;

  void displayToast(String message, bool isBad) {
    if (isBad) {
      Fluttertoast.showToast(
          msg: message,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.redAccent,
          fontSize: 20,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG);
    } else {
      Fluttertoast.showToast(
          msg: message,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.greenAccent,
          fontSize: 20,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG);
    }
  }

  //KTAS 팝업
  Future<dynamic> _showKTAS(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('KTAS란?'),
        content: Text(
          "증상 중심 환자 분류 도구를 의미합니다.\n\n" +
              "1단계: 심정지 등 생명 위험 \n" +
              "2단계: 뇌출혈 등 생명 위협 가능성 \n" +
              "3단계: 호흡곤란 등 심각한 위협 가능성 \n" +
              "4단계: 착란 등 환자에 따라 2시간 내 치료 \n" +
              "5단계: 상처 소독 등 긴급하지 않은 상황 \n\n",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(), child: Text('확인')),
        ],
      ),
    );
  }

  Future<dynamic> _showTextPop(BuildContext context, String text) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('정보'),
        content: Text(
          text,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(), child: Text('확인')),
        ],
      ),
    );
  }

  Future<dynamic> _showPopDB(BuildContext context, String text, car, location) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('정보'),
        content: Text(
          text,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed("/HL", arguments: {
                  "name": patientName.text,
                  "car": car,
                });
              },
              child: Text('확인')),
        ],
      ),
    );
  }

  // DB 전송
  void _sendDB(car, location, name, ktas, info, blood, tag1, tag2, tag3, age,
      sex) async {
    firestore.collection('AMB').doc('$car' + '$name').set({
      'CAR': car,
      'LOCATION': location,
      'NAME': name,
      "AGE": age,
      'KTAS': ktas,
      'INFO': info,
      'BLOOD': blood,
      'TAG1': tag1,
      'TAG2': tag2,
      'TAG3': tag3,
      'RESERVED': false,
      'RESERVED_HOSPITAL_CODE': 0,
      'sex': sex
    });
  }

  void _checkDB(car, location) async {
    var res = await firestore
        .collection('AMB')
        .where("CAR", isEqualTo: int.parse(car))
        .where("NAME", isEqualTo: patientName.text)
        .get();

    try {
      print(res.docs[0].data()["INFO"]);
      firestore.collection("AMB").doc(res.docs[0].id).delete().then(
            (doc) => print("Document deleted"),
            onError: (e) => print("Error updating document $e"),
          );

      displayToast("초기화를 완료했습니다. 이제 등록해주세요", true);
      return;
    } on RangeError catch (e) {
      print(e);
      displayToast("저장되었습니다.", false);
      return;
    }
  }

  var carCode;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> _args = ModalRoute.of(context)?.settings.arguments
        as Map<String, dynamic>; //매개변수 = 즉 번호랑 위치 받아온거
    //print(_args);
    carCode = _args["car"];
    var location = _args["location"];

    // 시작 시 기본으로 db 조회하고 존재 시 삭제
    //_checkDB(carCode, location);

    //displayToast(res, true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("환자 정보"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("환자 정보를 입력해주세요!    ",
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                  LiteRollingSwitch(
                      width: 90,
                      value: gen,
                      textOn: '남성',
                      textOff: '여성',
                      colorOn: Colors.blue,
                      colorOff: Colors.red,
                      iconOn: Icons.male,
                      iconOff: Icons.female,
                      onDoubleTap: () {},
                      onTap: () {},
                      onSwipe: () {},
                      onChanged: (value) {
                        setState(() {
                          gen = value;
                        });
                        if (gen) {
                          sex = "남성";
                        } else {
                          sex = "여성";
                        }
                      }),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 50,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.bottom,
                      controller: patientName,
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(10)),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          label: Text("이름"),
                          hintText: '이름'),
                      inputFormatters: [LengthLimitingTextInputFormatter(4)],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 80,
                    height: 50,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3)
                      ],
                      controller: patientAge,
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                      decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(10)),
                          label: Text(
                            "나이",
                          ),
                          alignLabelWithHint: true),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  DropdownMenu(
                    width: 117,
                    label: Text('혈액형'),
                    initialSelection: _bloodType[0],
                    dropdownMenuEntries: _bloodType
                        .map<DropdownMenuEntry<String>>((String value) {
                      return DropdownMenuEntry<String>(
                          value: value, label: value);
                    }).toList(),
                    onSelected: (blood) {
                      setState(() {
                        bloodTypeSelected = blood!;
                      });
                    },
                    textStyle: TextStyle(fontWeight: FontWeight.w600),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "환자 예상 KTAS 단계",
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      Container(
                        height: 20,
                        width: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey),
                        child: FloatingActionButton(
                          child: Icon(
                            Icons.question_mark_rounded,
                            size: 15,
                          ),
                          onPressed: () {
                            _showKTAS(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                  height: 40,
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 1),
                        )
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40)),
                  child: ToggleButtons(
                    renderBorder: false,
                    splashColor: Colors.transparent,
                    textStyle:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    borderRadius: BorderRadius.circular(40),
                    fillColor: kc(sliderValue),
                    selectedColor: Colors.white,
                    isSelected: KTAS,
                    onPressed: (int index) {
                      setState(() {
                        for (int bi = 0; bi < KTAS.length; bi++) {
                          KTAS[bi] = bi == index;
                        }
                      });
                      sliderValue = double.parse((index + 1).toString());
                    },
                    children: [
                      Container(
                          width: 70,
                          alignment: Alignment.center,
                          child: Text('1')),
                      Container(
                        height: 30,
                        width: 70,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(color: Colors.black, width: 2),
                                right:
                                    BorderSide(color: Colors.black, width: 2))),
                        child: Text('2'),
                      ),
                      Container(
                          width: 70,
                          alignment: Alignment.center,
                          child: Text('3')),
                      Container(
                        height: 30,
                        width: 70,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border(
                                left:
                                    BorderSide(color: Colors.black, width: 2.3),
                                right:
                                    BorderSide(color: Colors.black, width: 2))),
                        child: Text('4'),
                      ),
                      Container(
                          width: 70,
                          alignment: Alignment.center,
                          child: Text('5')),
                    ],
                  )),
              SizedBox(
                height: 5,
              ),
              Text(
                "환자 상태정보",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                  width: 400,
                  height: 135,
                  child: Container(
                      height: 135,
                      child: TextField(
                          maxLength: 150,
                          controller: patientInfo,
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          textAlign: TextAlign.start,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(150),
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          )))),
              SizedBox(
                height: 8,
              ),
              Text(
                "환자의 증상을 알려주세요.",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black, width: 3)),
                          height: 295,
                          child: _buildChips()))
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _checkDB(carCode, location);
              },
              child: Text("등록 전 저장하기"),
            ),
            ElevatedButton(
              child: Text("등록하기"),
              onPressed: () {
                try {
                  tags1 = ftag[0];
                  tags2 = ftag[1];
                  tags3 = ftag[2];

                  var id = _sendDB(
                      carCode,
                      location,
                      patientName.text,
                      sliderValue,
                      patientInfo.text,
                      bloodTypeSelected,
                      tags1,
                      tags2,
                      tags3,
                      patientAge.text,
                      sex);

                  _showPopDB(context, "등록이 완료되었습니다.", carCode, location);
                } catch (e) {
                  _showTextPop(context, "문제가 발생했습니다. \n" + e.toString());
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
