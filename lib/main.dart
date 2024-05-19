import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; 

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
   
    Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      setState(() {
        _progress += 0.01;
        if (_progress >= 1.0) {
          timer.cancel();
        
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
    backgroundColor: const Color.fromRGBO(207, 152, 23, 1), 
    appBar: AppBar(
      title: const Text(
        'Minesweeper',
        style: TextStyle(
          color: Color.fromRGBO(255, 255, 255, 1),
          fontSize: 25,
          fontWeight: FontWeight.bold
        ),),
      centerTitle: true,
      backgroundColor: const Color.fromRGBO(207, 152, 23, 1), 
    ),
    body: Column(
      children: [
        Expanded(
          child: Center(
            child: Image.asset(
              'assets/miner-removebg-preview.png', 
              width: 350, 
              height: 350, 
            ),
          ),
        ),
        
       SizedBox(
  height: 20.0, 
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: LinearProgressIndicator(
      backgroundColor: const Color.fromRGBO(81, 60, 9, 1), 
      valueColor: const AlwaysStoppedAnimation<Color>(Color.fromRGBO(255, 255, 255, 1)), 
      value: _progress, 
    ),
  ),
),
        Padding(
          padding: const EdgeInsets.all(8.0),
          
          child: Text(
            
            '${(_progress * 100).toStringAsFixed(0)}%', 
            style: const TextStyle(
              color:Color.fromRGBO(255, 255, 255, 1), 
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
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(207, 152, 23, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(207, 152, 23, 1),
        title: const Text('Main Menu',
         style: TextStyle(
          color: Color.fromRGBO(255, 255, 255, 1),
          fontSize: 25,
          fontWeight: FontWeight.bold
        ),),
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
                  MaterialPageRoute(builder: (context) => const DifficultySelectionScreen()),
                );
              },
              child: Image.asset(
                'assets/play-removebg-preview (1).png',
                width: 300, 
                height: 70, 
              ),
            ),
            TextButton(
              onPressed: () {
               
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const OptionsDialog();
                  },
                );
              },
              child: Image.asset(
                'assets/options-removebg-preview (1).png',
                width: 300, 
                height: 70, 
              ),
            ),
            TextButton(
              onPressed: () {
                
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirmation"),
                      content: const Text("Are you sure you want to quit?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); 
                          },
                          child: const Text("No"),
                        ),
                        TextButton(
                          onPressed: () {
                           
                            SystemNavigator.pop(); 
                          },
                          child: const Text("Yes")  
                        ),
                      ],
                    );
                  },
                );
              },
              child: Image.asset(
                'assets/quit-removebg-preview (1).png',
                width: 300, 
                height: 70, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//---------------------------------------------------------------------------------------------------------------------------------
class OptionsDialog extends StatefulWidget {
  const OptionsDialog({Key? key}) : super(key: key);

  @override
  _OptionsDialogState createState() => _OptionsDialogState();
}

class _OptionsDialogState extends State<OptionsDialog> {
  bool _isMuted = false;
  double _volumeLevel = 0.5; 
  double _previousVolume = 0.5; 

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Options"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sound Settings:"),
          ListTile(
            title: Text("Mute"),
            onTap: () {
              setState(() {
                _isMuted = !_isMuted;
                if (_isMuted) {
                  _previousVolume = _volumeLevel; 
                  _volumeLevel = 0.0; 
                } else {
                  _volumeLevel = _previousVolume; 
                }
                _setVolume(_volumeLevel);
              });
            },
            trailing: _isMuted ? const Icon(Icons.volume_off) : const Icon(Icons.volume_up),
          ),
          Slider(
            value: _volumeLevel,
            min: 0.0,
            max: 1.0,
            onChanged: (value) {
              setState(() {
                _volumeLevel = value;
                if (!_isMuted) {
                  _previousVolume = _volumeLevel; 
                }
                _setVolume(_volumeLevel);
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
        
            _saveChanges();
            Navigator.of(context).pop();
          },
          child: const Text("Close"),
        ),
      ],
    );
  }

  
  void _saveChanges() {
   
    print("Volume Level: $_volumeLevel");
    print("Muted: $_isMuted");
  }

  void _setVolume(double volume) {
    const MethodChannel('flutter_volume_controller')
        .invokeMethod('setVolume', {'volume': volume})
        .catchError((error) {
      print("Error setting volume: $error");
    });
  }
}

//----------------------------------------------------------------------------------------------------------------------



class DifficultySelectionScreen extends StatelessWidget {
  const DifficultySelectionScreen({super.key});

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromRGBO(207, 152, 23, 1),
    appBar: AppBar(
      backgroundColor: const Color.fromRGBO(207, 152, 23, 1),
      title: const Text(
        'Choose Difficulty',
       style: TextStyle(
          color: Color.fromRGBO(255, 255, 255, 1),
          fontSize: 25,
          fontWeight: FontWeight.bold
        ),),
      leading: IconButton(
        icon: Image.asset(
          'assets/back-removebg-preview.png', 
          width: 50, 
          height: 50, 
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
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
              'assets/easy-removebg-preview.png', 
               width: 420, 
              height: 60,
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
              'assets/medium-removebg-preview.png', 
              width: 420, 
              height: 60, 
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
              'assets/hard-removebg-preview.png', 
              width: 420, 
              height: 60, 
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
//---------------------------------------------------------------------------------------------------
void toggleRevealBombs() {
  setState(() {
    // Toggle the allRevealed state
    allRevealed = !allRevealed;
    // Iterate through all rows
    for (int i = 0; i < rows; i++) {
      // Iterate through all columns
      for (int j = 0; j < cols; j++) {
        // Only reveal the cell if it contains a mine
        if (hasMine[i][j]) {
          revealed[i][j] = allRevealed;
        }
      }
    }
  });
}
  Widget buildGrid() {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.all(30.0), 
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
            margin: const EdgeInsets.all(0.5), 
            decoration: BoxDecoration(
              border: Border.all(color: const Color.fromRGBO(74, 38, 24, 1)),
              color: revealed[row][col]
                  ? const Color.fromARGB(255, 150, 82, 5)
                  : allRevealed
                      ? const Color.fromRGBO(2, 102, 50, 0.9)
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
    backgroundColor: const Color.fromRGBO(207, 152, 23, 1), 
    appBar: AppBar(
      backgroundColor: const Color.fromRGBO(207, 152, 23, 1),
      title: const Text(''),
      leading: IconButton(
        icon: Image.asset(
          
          'assets/back-removebg-preview.png', 
          width: 50.0, 
          height: 50.0, 
        ),
        
        onPressed: () {
          Navigator.pop(context);
        },
      ),
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
                    'assets/timer.png', 
                    width: 40.0, 
                    height: 40.0, 
                  ),
                  const SizedBox(width: 5.0),
                  Text(
                    getFormattedTime(secondsElapsed),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20.0), 
              Row(
                children: [
                  Image.asset(
                    'assets/bomb-icon-2.png', 
                    width: 40.0, 
                    height: 40.0, 
                  ),
                  const SizedBox(width: 5.0),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      '$minesLeft',
                      key: ValueKey<int>(minesLeft),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
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
          onPressed: toggleRevealBombs,
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
