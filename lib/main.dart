import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:assets_audio_player/assets_audio_player.dart';

void main() {
  runApp(const MinesweeperApp());
}

class MinesweeperApp extends StatelessWidget {
  const MinesweeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterSweeper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    // Simulate loading time with a delay
    Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      setState(() {
        _progress += 0.01;
        if (_progress >= 1.0) {
          timer.cancel();
          // Navigate to next screen after loading
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainMenuScreen()),
          );
        }
      });
    });
  }

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromRGBO(81, 60, 9, 1), // Set the background color of the scaffold
    appBar: AppBar(
      title: const Text(
        'Minesweeper',
        style: TextStyle(
          color: Color.fromRGBO(255, 255, 255, 1),
          fontSize: 30,
        ),),
      centerTitle: true,
      backgroundColor: const Color.fromRGBO(81, 60, 9, 1), // Set the background color of the scaffold
    ),
    body: Column(
      children: [
        Expanded(
          child: Center(
            child: Image.asset(
              'assets/miner-removebg-preview.png', // Replace 'assets/minesweeper_logo.png' with the path to your image asset
              width: 350, // Adjust the width of the image as needed
              height: 350, // Adjust the height of the image as needed
            ),
          ),
        ),
        
       SizedBox(
  height: 20.0, // Adjust the height of the progress bar
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.0), // Add left and right padding
    child: LinearProgressIndicator(
      backgroundColor: const Color.fromRGBO(81, 60, 9, 1), // Set the background color of the progress bar
      valueColor: const AlwaysStoppedAnimation<Color>(Color.fromRGBO(255, 255, 255, 1)), // Set the value color of the progress bar to black
      value: _progress, // Set the value of the progress bar
    ),
  ),
),
        Padding(
          padding: const EdgeInsets.all(8.0),
          
          child: Text(
            
            '${(_progress * 100).toStringAsFixed(0)}%', // Display the progress percentage
            style: const TextStyle(
              color:Color.fromRGBO(255, 255, 255, 1), // Set the text color to yellow
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    ),
  );
}


}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DifficultySelectionScreen()),
                );
              },
              child: const Text('Play'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to settings screen
              },
              child: const Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class DifficultySelectionScreen extends StatelessWidget {
  const DifficultySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Difficulty'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MinesweeperScreen(
                      rows: 4,
                      cols: 4,
                      totalMines: 4,
                    ),
                  ),
                );
              },
               child: Image.asset(
                'assets/easy-removebg-preview.png', // Path to the image for Medium
                 width: 420, // Adjust width as needed
                height: 60,// Adjust height as needed
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MinesweeperScreen(
                      rows: 6,
                      cols: 6,
                      totalMines: 10,
                    ),
                  ),
                );
              },
               child: Image.asset(
                'assets/medium-removebg-preview.png', // Path to the image for Medium
                width: 420, // Adjust width as needed
                height: 60, // Adjust height as needed
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MinesweeperScreen(
                      rows: 10,
                      cols: 10,
                      totalMines: 20,
                    ),
                  ),
                );
              },
                child: Image.asset(
                'assets/hard-removebg-preview.png', // Path to the image for Medium
                width: 420, // Adjust width as needed
                height: 60, // Adjust height as needed
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MinesweeperScreen extends StatefulWidget {
  final int rows;
  final int cols;
  final int totalMines;

  const MinesweeperScreen({super.key, 
    required this.rows,
    required this.cols,
    required this.totalMines,
  });

  @override
  _MinesweeperScreenState createState() => _MinesweeperScreenState();
}

class _MinesweeperScreenState extends State<MinesweeperScreen> {
  late int rows;
  late int cols;
  late int totalMines;
  late List<List<bool>> revealed;
  late List<List<bool>> hasMine;
  bool gameover = false;
  bool allRevealed = false;
  int minesLeft = 0;
  late DateTime startTime;
  late Timer _timer;
  late int secondsElapsed;
  late AssetsAudioPlayer _tilePressPlayer;
  late AssetsAudioPlayer _bombPlayer;

  @override
  void initState() {
    super.initState();
    rows = widget.rows;
    cols = widget.cols;
    totalMines = widget.totalMines;
    minesLeft = totalMines;
    initializeGame();
    startTimer();
    _initializeSounds();
  }

  void _initializeSounds() {
    _tilePressPlayer = AssetsAudioPlayer();
    _bombPlayer = AssetsAudioPlayer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _tilePressPlayer.dispose();
    _bombPlayer.dispose();
    super.dispose();
  }

  void initializeGame() {
    revealed = List.generate(rows, (i) => List.filled(cols, false));
    hasMine = List.generate(rows, (i) => List.filled(cols, false));

    // Randomly place mines
    Random random = Random();
    int minesPlaced = 0;
    while (minesPlaced < totalMines) {
      int row = random.nextInt(rows);
      int col = random.nextInt(cols);
      if (!hasMine[row][col]) {
        hasMine[row][col] = true;
        minesPlaced++;
      }
    }

    startTime = DateTime.now();
    secondsElapsed = 0;
  }

  //-------------------------------------------------------------------------win dialog

  void showGameOverDialog(String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  gameover = false;
                  allRevealed = false;
                  initializeGame();
                  startTimer();
                });
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void revealTile(int row, int col) {
    if (revealed[row][col] || gameover) return;
    setState(() {
      revealed[row][col] = true;
      if (hasMine[row][col]) {
        gameover = true;
        revealAllMines();
        showGameOverDialog('Game Over - You hit a mine!');
        _timer.cancel();
        _bombPlayer.open(Audio('assets/bomb1.wav'));
        return;
      }
      int revealedSafeTiles = 0;
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          if (!hasMine[i][j] && revealed[i][j]) {
            revealedSafeTiles++;
          }
        }
      }
      if (revealedSafeTiles == (rows * cols) - totalMines) {
        gameover = true;
        showGameOverDialog('Congratulations! You won!');
      }
      int adjacentMines = 0;
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          int r = row + dr;
          int c = col + dc;
          if (r >= 0 && r < rows && c >= 0 && c < cols) {
            if (hasMine[r][c]) {
              adjacentMines++;
            }
          }
        }
      }
      if (adjacentMines == 0) {
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            int r = row + dr;
            int c = col + dc;
            if (r >= 0 && r < rows && c >= 0 && c < cols) {
              revealTile(r, c);
            }
          }
        }
      }
      _tilePressPlayer.open(Audio('assets/safe1.wav'));
    });
  }

  void revealAllMines() {
    setState(() {
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          if (hasMine[i][j]) {
            revealed[i][j] = true;
          }
        }
      }
    });
  }

  void toggleRevealAll() {
    setState(() {
      allRevealed = !allRevealed;
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          revealed[i][j] = allRevealed;
        }
      }
    });
  }

  Widget buildGrid() {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.all(30.0), // Adjust the padding as needed
    child: GridView.builder(
      shrinkWrap: true,
      itemCount: rows * cols,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
      ),
      itemBuilder: (BuildContext context, int index) {
        int row = index ~/ cols;
        int col = index % cols;
        return GestureDetector(
          onTap: () => revealTile(row, col),
          child: Container(
            margin: const EdgeInsets.all(0.5), // Add margin to each tile
            decoration: BoxDecoration(
              border: Border.all(color: const Color.fromRGBO(74, 38, 24, 1)),
              color: revealed[row][col]
                  ? const Color.fromARGB(255, 150, 82, 5)
                  : allRevealed
                      ? const Color.fromARGB(255, 21, 0, 202)
                      : const Color.fromRGBO(2, 102, 50, 1),
            ),
            child: Center(
              child: revealed[row][col]
                  ? hasMine[row][col]
                      ? AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 500),
                          child: Image.asset(
                            'assets/bomb-icon-2.png',
                            width: 36,
                            height: 36,
                          ),
                        )
                      : Text(
                          getNeighborMines(row, col).toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: getTextColor(getNeighborMines(row, col)),
                          ),
                        )
                  : null,
            ),
          ),
        );
      },
    ),
  );
}


  int getNeighborMines(int row, int col) {
    int count = 0;
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        int r = row + dr;
        int c = col + dc;
        if (r >= 0 && r < rows && c >= 0 && c < cols) {
          if (hasMine[r][c]) {
            count++;
          }
        }
      }
    }
    return count;
  }

  Color getTextColor(int numMines) {
    switch (numMines) {
      case 1:
        return Colors.white;
      case 2:
        return Colors.white;
      case 3:
        return Colors.white;
      case 4:
        return Colors.white;
      case 5:
        return Colors.white;
      case 6:
        return Colors.white;
      case 7:
        return Colors.black;
      case 8:
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  String getFormattedTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      var currentTime = DateTime.now();
      setState(() {
        secondsElapsed = currentTime.difference(startTime).inSeconds;
      });
    });
    startTime = DateTime.now().subtract(Duration(seconds: secondsElapsed));
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('BOMBA'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: [
                  Image.asset(
                    'assets/timer.png', // Replace with your timer icon asset path
                    width: 30.0, // Adjust width as needed
                    height: 30.0, // Adjust height as needed
                  ),
                  const SizedBox(width: 5.0),
                  Text(
                    getFormattedTime(secondsElapsed),
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20.0), // Adjust spacing between timer and dangerous icon
              Row(
                children: [
                  Image.asset(
                    'assets/bomb-icon-2.png', // Replace with your dangerous icon asset path
                    width: 30.0, // Adjust width as needed
                    height: 30.0, // Adjust height as needed
                  ),
                  const SizedBox(width: 5.0),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      '$minesLeft',
                      key: ValueKey<int>(minesLeft),
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(allRevealed ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleRevealAll,
          tooltip: allRevealed ? 'Hide All' : 'Reveal All',
        ),
      ],
    ),
    body: AbsorbPointer(
      absorbing: gameover,
      child: Center(
        child: buildGrid(),
      ),
    ),
  );
}

}
