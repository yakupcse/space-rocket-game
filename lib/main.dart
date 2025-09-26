import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Güzel Mobil Oyun',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double playerX = 100;
  double playerY = 300;
  int score = 0;
  int level = 1;
  bool gameRunning = true;
  Timer? gameTimer;
  List<Enemy> enemies = [];
  
  // Yön tuşları için değişkenler
  bool isMovingUp = false;
  bool isMovingDown = false;
  bool isMovingLeft = false;
  bool isMovingRight = false;
  double playerSpeed = 5.0;
  
  // Oyun hızı değişkenleri
  double enemySpeed = 3.0;
  double enemySpawnRate = 3.0; // Yüzde olarak
  
  // Level bildirimi için
  bool showLevelUp = false;
  Timer? levelUpTimer;
  
  // Ödüller için
  List<PowerUp> powerUps = [];
  double powerUpSpawnRate = 1.0; // Yüzde olarak
  int powerUpScore = 0; // Ödül skoru
  
  @override
  void initState() {
    super.initState();
    startGame();
  }
  
  void startGame() {
    gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!gameRunning) return;
      
      if (mounted) {
        setState(() {
          // Oyuncu hareketi (yön tuşları)
          if (isMovingUp && playerY > 0) {
            playerY -= playerSpeed;
          }
          if (isMovingDown && playerY < MediaQuery.of(context).size.height - 50) {
            playerY += playerSpeed;
          }
          if (isMovingLeft && playerX > 0) {
            playerX -= playerSpeed;
          }
          if (isMovingRight && playerX < MediaQuery.of(context).size.width - 50) {
            playerX += playerSpeed;
          }
        
          // Düşmanları hareket ettir
          for (var enemy in enemies) {
            enemy.update(0.05); // 50ms = 0.05 saniye
          }
          
          // Ödülleri hareket ettir
          for (var powerUp in powerUps) {
            powerUp.update(0.05);
          }
          
          // Ekran dışına çıkan düşmanları sil
          enemies.removeWhere((enemy) => enemy.x < -50);
          
          // Ekran dışına çıkan ödülleri sil
          powerUps.removeWhere((powerUp) => powerUp.x < -50);
          
          // Yeni düşman ekle (rastgele) - tüm ekran yüksekliğinde
          if (math.Random().nextInt(100) < enemySpawnRate) {
            enemies.add(Enemy(
              x: MediaQuery.of(context).size.width,
              y: math.Random().nextDouble() * MediaQuery.of(context).size.height,
            ));
          }
          
          // Yeni ödül ekle (rastgele)
          if (math.Random().nextInt(100) < powerUpSpawnRate) {
            powerUps.add(PowerUp(
              x: MediaQuery.of(context).size.width,
              y: math.Random().nextDouble() * MediaQuery.of(context).size.height,
            ));
          }
          
          // Çarpışma kontrolü - Düşmanlar
          for (var enemy in enemies) {
            if ((playerX - enemy.x).abs() < 40 && (playerY - enemy.y).abs() < 40) {
              gameRunning = false;
              showGameOverDialog();
              return;
            }
          }
          
          // Çarpışma kontrolü - Ödüller
          for (var powerUp in powerUps.toList()) {
            if ((playerX - powerUp.x).abs() < 35 && (playerY - powerUp.y).abs() < 35) {
              // Ödülü yakala
              powerUps.remove(powerUp);
              collectPowerUp(powerUp.type);
            }
          }
          
          // Skor artır
          score += 1;
          
          // Level kontrolü - her 500 skorda level artır
          int newLevel = (score ~/ 500) + 1;
          if (newLevel > level) {
            level = newLevel;
            increaseLevel();
          }
        });
      }
    });
  }
  
  void increaseLevel() {
    // Düşman hızını artır
    enemySpeed += 0.5;
    
    // Düşman spawn oranını artır
    enemySpawnRate += 0.5;
    
    // Maksimum sınırlar
    if (enemySpeed > 8.0) enemySpeed = 8.0;
    if (enemySpawnRate > 8.0) enemySpawnRate = 8.0;
    
    // Level artışı bildirimi göster
    showLevelUpNotification();
  }
  
  void showLevelUpNotification() {
    // Level up bildirimini göster
    setState(() {
      showLevelUp = true;
    });
    
    // 3 saniye sonra bildirimi gizle
    levelUpTimer?.cancel();
    levelUpTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showLevelUp = false;
        });
      }
    });
  }
  
  void collectPowerUp(int type) {
    switch (type) {
      case 0: // Skor bonusu
        powerUpScore += 100;
        break;
      case 1: // Hız artışı
        playerSpeed = (playerSpeed + 1).clamp(5.0, 10.0);
        break;
      case 2: // Geçici invincibility
        // Gelecekte eklenebilir
        break;
      case 3: // Ekstra can
        // Gelecekte eklenebilir
        break;
    }
  }
  
  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Oyun Bitti!'),
        content: Text('Skorunuz: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              restartGame();
            },
            child: const Text('Tekrar Oyna'),
          ),
        ],
      ),
    );
  }
  
  void restartGame() {
    setState(() {
      playerX = 100;
      playerY = 300;
      score = 0;
      level = 1;
      gameRunning = true;
      enemies.clear();
      powerUps.clear();
      powerUpScore = 0;
      isMovingUp = false;
      isMovingDown = false;
      isMovingLeft = false;
      isMovingRight = false;
      
      // Hızları sıfırla
      enemySpeed = 3.0;
      enemySpawnRate = 3.0;
      playerSpeed = 5.0;
    });
    startGame();
  }
  
  void movePlayer(TapDownDetails details) {
    if (!gameRunning) return;
    
    setState(() {
      playerX = details.localPosition.dx - 25;
      playerY = details.localPosition.dy - 25;
      
      // Ekran sınırları
      if (playerX < 0) playerX = 0;
      if (playerX > MediaQuery.of(context).size.width - 50) {
        playerX = MediaQuery.of(context).size.width - 50;
      }
      if (playerY < 0) playerY = 0;
      if (playerY > MediaQuery.of(context).size.height - 50) {
        playerY = MediaQuery.of(context).size.height - 50;
      }
    });
  }
  
  // Düşman tipine göre renkler
  List<Color> _getEnemyColors(int movementType) {
    switch (movementType) {
      case 0: // Düz hareket - Koyu Gri Bomba
        return [
          const Color(0xFF424242),
          const Color(0xFF303030),
          const Color(0xFF212121),
        ];
      case 1: // Dalga hareketi - Patlama Turuncu
        return [
          const Color(0xFFFF6F00),
          const Color(0xFFE65100),
          const Color(0xFFBF360C),
        ];
      case 2: // Zigzag hareketi - Elektrik Mavi
        return [
          const Color(0xFF2196F3),
          const Color(0xFF1976D2),
          const Color(0xFF0D47A1),
        ];
      case 3: // Spiral hareketi - Radyoaktif Yeşil
        return [
          const Color(0xFF4CAF50),
          const Color(0xFF2E7D32),
          const Color(0xFF1B5E20),
        ];
      default:
        return [
          const Color(0xFF424242),
          const Color(0xFF303030),
          const Color(0xFF212121),
        ];
    }
  }
  
  // Düşman tipine göre gölge rengi
  Color _getEnemyShadowColor(int movementType) {
    switch (movementType) {
      case 0: return Colors.grey.withOpacity(0.8); // Koyu gri bomba
      case 1: return Colors.orange.withOpacity(0.8); // Patlama turuncu
      case 2: return Colors.blue.withOpacity(0.8); // Elektrik mavi
      case 3: return Colors.green.withOpacity(0.8); // Radyoaktif yeşil
      default: return Colors.grey.withOpacity(0.8);
    }
  }
  
  // Düşman tipine göre ikon
  IconData _getEnemyIcon(int movementType) {
    switch (movementType) {
      case 0: return Icons.dangerous; // Düz hareket - Bomba
      case 1: return Icons.local_fire_department; // Dalga hareketi - Patlama
      case 2: return Icons.flash_on; // Zigzag hareketi - Şimşek
      case 3: return Icons.bug_report; // Spiral hareketi - Radyoaktif
      default: return Icons.dangerous;
    }
  }
  
  // Ödül tipine göre renkler
  List<Color> _getPowerUpColors(int type) {
    switch (type) {
      case 0: // Skor bonusu - Altın
        return [
          const Color(0xFFFFD700),
          const Color(0xFFFFA500),
          const Color(0xFFFF8C00),
        ];
      case 1: // Hız artışı - Mavi
        return [
          const Color(0xFF00BFFF),
          const Color(0xFF1E90FF),
          const Color(0xFF0000FF),
        ];
      case 2: // Invincibility - Mor
        return [
          const Color(0xFF9370DB),
          const Color(0xFF8A2BE2),
          const Color(0xFF4B0082),
        ];
      case 3: // Ekstra can - Yeşil
        return [
          const Color(0xFF32CD32),
          const Color(0xFF00FF00),
          const Color(0xFF008000),
        ];
      default:
        return [
          const Color(0xFFFFD700),
          const Color(0xFFFFA500),
          const Color(0xFFFF8C00),
        ];
    }
  }
  
  // Ödül tipine göre gölge rengi
  Color _getPowerUpShadowColor(int type) {
    switch (type) {
      case 0: return Colors.orange.withOpacity(0.8);
      case 1: return Colors.blue.withOpacity(0.8);
      case 2: return Colors.purple.withOpacity(0.8);
      case 3: return Colors.green.withOpacity(0.8);
      default: return Colors.orange.withOpacity(0.8);
    }
  }
  
  // Ödül tipine göre ikon
  IconData _getPowerUpIcon(int type) {
    switch (type) {
      case 0: return Icons.star; // Skor bonusu
      case 1: return Icons.speed; // Hız artışı
      case 2: return Icons.shield; // Invincibility
      case 3: return Icons.favorite; // Ekstra can
      default: return Icons.star;
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    levelUpTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              switch (event.logicalKey) {
                case LogicalKeyboardKey.arrowUp:
                  setState(() => isMovingUp = true);
                  return KeyEventResult.handled;
                case LogicalKeyboardKey.arrowDown:
                  setState(() => isMovingDown = true);
                  return KeyEventResult.handled;
                case LogicalKeyboardKey.arrowLeft:
                  setState(() => isMovingLeft = true);
                  return KeyEventResult.handled;
                case LogicalKeyboardKey.arrowRight:
                  setState(() => isMovingRight = true);
                  return KeyEventResult.handled;
              }
            } else if (event is KeyUpEvent) {
              switch (event.logicalKey) {
                case LogicalKeyboardKey.arrowUp:
                  setState(() => isMovingUp = false);
                  return KeyEventResult.handled;
                case LogicalKeyboardKey.arrowDown:
                  setState(() => isMovingDown = false);
                  return KeyEventResult.handled;
                case LogicalKeyboardKey.arrowLeft:
                  setState(() => isMovingLeft = false);
                  return KeyEventResult.handled;
                case LogicalKeyboardKey.arrowRight:
                  setState(() => isMovingRight = false);
                  return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: GestureDetector(
            onTapDown: movePlayer,
            child: Stack(
              children: [
                // Skor ve Level
                Positioned(
                  top: 50,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.cyan, width: 2),
                        ),
                        child: Text(
                          'SKOR: ${score + powerUpScore}',
                          style: const TextStyle(
                            color: Colors.cyan,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange, width: 2),
                        ),
                        child: Text(
                          'LEVEL: $level',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Kontrol talimatları
                Positioned(
                  top: 50,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.orange, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'KONTROLLER',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Yön Tuşları',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'veya Dokunma',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Oyuncu
                Positioned(
                  left: playerX,
                  top: playerY,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF00E5FF),
                          Color(0xFF0091EA),
                          Color(0xFF01579B),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.rocket_launch,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                
                // Ödüller
                ...powerUps.map((powerUp) => Positioned(
                  left: powerUp.x,
                  top: powerUp.y,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _getPowerUpColors(powerUp.type),
                      ),
                      borderRadius: BorderRadius.circular(17.5),
                      boxShadow: [
                        BoxShadow(
                          color: _getPowerUpShadowColor(powerUp.type),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _getPowerUpIcon(powerUp.type),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                )),
                
                // Düşmanlar
                ...enemies.map((enemy) => Positioned(
                  left: enemy.x,
                  top: enemy.y,
                  child: Container(
                    width: 40,
                    height: 50, // Bomba şekli için daha uzun
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: _getEnemyColors(enemy.movementType),
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _getEnemyShadowColor(enemy.movementType),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getEnemyIcon(enemy.movementType),
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                
                // Level up bildirimi
                if (showLevelUp)
                  Positioned(
                    top: 150,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF4CAF50),
                              Color(0xFF2E7D32),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.green, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'LEVEL $level!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.trending_up,
                              color: Colors.yellow,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                
                // Oyun durduğunda overlay
                if (!gameRunning)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.red.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red, width: 3),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.gamepad,
                                  color: Colors.red,
                                  size: 60,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'OYUN BİTTİ!',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Skorunuz: $score',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Ulaştığınız Level: $level',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    restartGame();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: const Text(
                                    'TEKRAR OYNA',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PowerUp {
  double x;
  double y;
  late double speed;
  late int type; // Ödül tipi (0: skor, 1: hız, 2: invincibility, 3: can)
  
  PowerUp({required this.x, required this.y}) {
    speed = 2.0 + (math.Random().nextDouble() * 2.0); // 2-4 arası hız
    type = math.Random().nextInt(4); // 0-3 arası rastgele tip
  }
  
  void update(double dt) {
    x -= speed;
  }
}

class Enemy {
  double x;
  double y;
  late double baseY; // Başlangıç Y pozisyonu
  late double speed;
  late double amplitude; // Dalgalanma genliği
  late double frequency; // Dalgalanma sıklığı
  late double time; // Zaman sayacı
  late int movementType; // Hareket tipi (0: düz, 1: dalga, 2: zigzag, 3: spiral)
  
  Enemy({required this.x, required this.y}) {
    baseY = y;
    speed = 2.0 + (math.Random().nextDouble() * 3.0); // 2-5 arası hız
    amplitude = 50.0 + (math.Random().nextDouble() * 80.0); // 50-130 arası genlik
    frequency = 0.01 + (math.Random().nextDouble() * 0.04); // 0.01-0.05 arası sıklık
    time = 0.0;
    movementType = math.Random().nextInt(4); // 0-3 arası rastgele tip
  }
  
  void update(double dt) {
    time += dt;
    x -= speed;
    
    // Hareket tipine göre Y pozisyonunu güncelle
    switch (movementType) {
      case 0: // Düz hareket
        // Y pozisyonu değişmez
        break;
        
      case 1: // Dalga hareketi
        y = baseY + (math.sin(time * frequency * 80) * amplitude * 0.8);
        break;
        
      case 2: // Zigzag hareketi
        y = baseY + (math.sin(time * frequency * 120) * amplitude * 0.6);
        break;
        
      case 3: // Spiral hareketi
        y = baseY + (math.sin(time * frequency * 100) * amplitude * 0.4) + 
            (math.cos(time * frequency * 80) * amplitude * 0.2);
        break;
    }
    
    // Ekran sınırları içinde kalmasını sağla
    if (y < 0) y = 0;
    if (y > 600) y = 600; // Varsayılan ekran yüksekliği
  }
}