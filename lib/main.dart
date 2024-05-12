import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

void main() {
  runApp(MinesweeperApp());
}

class MinesweeperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterSweeper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    // Simulate loading time with a delay
    Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
      setState(() {
        _progress += 0.01;
        if (_progress >= 1.0) {
          timer.cancel();
          // Navigate to next screen after loading
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainMenuScreen()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minesweeper'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Minesweeper',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: 10.0, // Adjust the height of the progress bar
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              value: _progress,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${(_progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ],
      ),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Menu'),
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
                  MaterialPageRoute(builder: (context) => DifficultySelectionScreen()),
                );
              },
              child: Text('Play'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to settings screen
              },
              child: Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class DifficultySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Difficulty'),
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
                  MaterialPageRoute(
                    builder: (context) => MinesweeperScreen(
                      rows: 4,
                      cols: 4,
                      totalMines: 4,
                    ),
                  ),
                );
              },
              child: Text('Easy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MinesweeperScreen(
                      rows: 6,
                      cols: 6,
                      totalMines: 10,
                    ),
                  ),
                );
              },
              child: Text('Medium'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MinesweeperScreen(
                      rows: 10,
                      cols: 10,
                      totalMines: 20,
                    ),
                  ),
                );
              },
              child: Text('Hard'),
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

  MinesweeperScreen({
    required this.rows,
    required this.cols,
    required this.totalMines,
  });

  @override
  _MinesweeperScreenState createState() => _MinesweeperScreenState();
}

class _MinesweeperScreenState extends State<MinesweeperScreen> {
  // Remaining code for MinesweeperScreen
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
              child: Text('Play Again'),
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
    return GridView.builder(
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
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: revealed[row][col]
                  ? Colors.grey[200]
                  : allRevealed
                      ? Colors.grey[200]
                      : Colors.white,
            ),
            child: Center(
              child: revealed[row][col]
                  ? hasMine[row][col]
                      ? AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(milliseconds: 500),
                          child: Icon(Icons.dangerous),
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
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.orange;
      case 6:
        return Colors.teal;
      case 7:
        return Colors.yellow;
      case 8:
        return Colors.grey;
      default:
        return Colors.black;
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
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
        title: Text('FlutterSweeper'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.timer,
                  size: 20.0,
                ),
                SizedBox(width: 4.0),
                Text(
                  getFormattedTime(secondsElapsed),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.dangerous,
                  size: 20.0,
                ),
                SizedBox(width: 4.0),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: Text(
                    '$minesLeft',
                    key: ValueKey<int>(minesLeft),
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
