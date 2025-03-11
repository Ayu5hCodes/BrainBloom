import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  List<String> icons = [
    '🍎', '🍌', '🍒', '🍉', '🍇',
    '🍓', '🍍', '🥝', '🥥', '🥕',
    '🍎', '🍌', '🍒', '🍉', '🍇',
    '🍓', '🍍', '🥝', '🥥', '🥕',
    '🌵', '🌻', '🌲', '🌴', '🌼',
    '🌵', '🌻', '🌲', '🌴', '🌼'
  ];
  
  List<bool> revealed = [];
  int? firstSelected;
  int moves = 0;
  int pairsFound = 0;
  int totalPairs = 12;
  int stars = 3;
  late Timer _timer;
  int timeLeft = 60;

  @override
  void initState() {
    super.initState();
    icons.shuffle(Random());
    revealed = List.generate(icons.length, (index) => false);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        _timer.cancel();
        _showGameEndDialog("Time's Up! You Failed 😔");
      }
    });
  }

  void checkForMatch(int index) {
    setState(() {
      moves++;
      revealed[index] = true;

      if (firstSelected == null) {
        firstSelected = index;
      } else {
        if (icons[firstSelected!] == icons[index]) {
          pairsFound++;
        } else {
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              revealed[firstSelected!] = false;
              revealed[index] = false;
            });
          });
        }
        firstSelected = null;
      }

      if (pairsFound == totalPairs) {
        _timer.cancel();
        if (moves <= 20) {
          stars = 3;
        } else if (moves <= 30) {
          stars = 2;
        } else {
          stars = 1;
        }

        _showGameEndDialog("You Win! 🌟 Stars: $stars");
      }
    });
  }

  void _showGameEndDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(message),
        content: Text('Moves: $moves\nStars Earned: $stars'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Game')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text('Moves: $moves | Time Left: $timeLeft sec', 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: icons.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  if (!revealed[index] && firstSelected != index) {
                    checkForMatch(index);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: revealed[index] ? Colors.white : Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      revealed[index] ? icons[index] : '',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
