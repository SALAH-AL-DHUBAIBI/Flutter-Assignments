import 'dart:math';

import 'package:bmi/modules/bmi_Result/bmi_Result.dart';
import 'package:flutter/material.dart';

class BMI extends StatefulWidget {
  BMI({super.key});

  @override
  State<BMI> createState() => _BMIState();
}

class _BMIState extends State<BMI> {
  bool isMale = true;
  double h = 120;
  int age = 20;
  int weight = 40;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "Bmi_Calculate",
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isMale = true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: isMale ? Colors.blue[400] : Colors.grey[400],
                        ),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(
                              image: AssetImage('images/mars_5069124.png'),
                              width: 75.0,
                              height: 75.0,
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              "MALE",
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isMale = false;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: !isMale ? Colors.blue[400] : Colors.grey[400],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(
                              image: AssetImage('images/venus_5069114.png'),
                              width: 75.0,
                              height: 75.0,
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              "FEMALE",
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w900,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey[400],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "HEIGHT",
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "${h.round()}",
                          style: TextStyle(
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "CM",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: h,
                      max: 220.0,
                      min: 80.0,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          h = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "WEIGHT",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 22.0,
                            ),
                          ),
                          Text(
                            "${weight}",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 30.0,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FloatingActionButton(
                                onPressed: () {
                                  setState(() {
                                    --weight;
                                  });
                                },
                                heroTag: 'weight-',
                                mini: true,
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.remove, color: Colors.white),
                              ),
                              FloatingActionButton(
                                onPressed: () {
                                  setState(() {
                                    ++weight;
                                  });
                                },
                                heroTag: 'weight+',
                                mini: true,
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.add, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "AGE",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 22.0,
                            ),
                          ),
                          Text(
                            "${age}",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 30.0,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FloatingActionButton(
                                onPressed: () {
                                  setState(() {
                                    --age;
                                  });
                                },
                                heroTag: 'Age-',
                                mini: true,
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.remove, color: Colors.white),
                              ),
                              FloatingActionButton(
                                onPressed: () {
                                  setState(() {
                                    ++age;
                                  });
                                },
                                heroTag: 'Age+',
                                mini: true,
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.add, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 50.0,
            color: Colors.blue,
            child: MaterialButton(
              onPressed: () {
                double result = weight / pow(h / 100, 2);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BMI_Result(
                        age: age,
                        ismale: isMale,
                        result: result.round(),
                      ),
                    ),
                );
              },
              child: Text(
                "Calculator",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
