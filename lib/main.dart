import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(GameWidget(game: LuckyNumbersGame()));
}

// ---------------------------------------------------------------------------
// 1. CLASE PRINCIPAL DEL JUEGO
// ---------------------------------------------------------------------------
class LuckyNumbersGame extends FlameGame {
  // VARIABLES GLOBALES
  int numeroActual = 0;
  late TextComponent textoHUD;
  
  // NUEVO: Bandera para controlar si el juego terminó
  bool finDelJuego = false;
  
  List<List<int>> matrizTablero = List.generate(4, (i) => List.filled(4, 0));

  @override
  Future<void> onLoad() async {
    generarNuevoNumero();

    textoHUD = TextComponent(
      text: 'Tu número: $numeroActual',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 30, color: Colors.white),
      ),
      position: Vector2(20, 50),
    );
    add(textoHUD);

    add(Tablero(x: 20, y: 120));
  }

  void generarNuevoNumero() {
    // Si el juego terminó, no generamos más números
    if (finDelJuego) return;

    numeroActual = Random().nextInt(20) + 1;
    
    try {
      textoHUD.text = 'Tu número: $numeroActual';
    } catch (e) {
      // Ignorar
    }
  }

  bool esMovimientoValido(int fila, int columna, int valor) {
    // REGLA 1: FILAS
    for (int c = 0; c < 4; c++) {
      int vecino = matrizTablero[fila][c];
      if (vecino != 0) {
        if (c < columna && vecino >= valor) return false;
        if (c > columna && vecino <= valor) return false;
      }
    }

    // REGLA 2: COLUMNAS
    for (int f = 0; f < 4; f++) {
      int vecino = matrizTablero[f][columna];
      if (vecino != 0) {
        if (f < fila && vecino >= valor) return false;
        if (f > fila && vecino <= valor) return false;
      }
    }
    return true;
  }

  void verificarVictoria() {
    bool tableroLleno = true;

    for (var fila in matrizTablero) {
      if (fila.contains(0)) {
        tableroLleno = false;
        break;
      }
    }

    if (tableroLleno) {
      print("¡GANASTE!");
      
      // NUEVO: Marcamos que el juego terminó, PERO NO PAUSAMOS EL MOTOR
      // Así permitimos que se dibuje la última ficha.
      finDelJuego = true;

      // Cambiamos el texto de arriba también
      textoHUD.text = "¡JUEGO TERMINADO!";
      
      add(TextComponent(
        text: '¡GANASTE!',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 60,
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 10, color: Colors.black, offset: Offset(4, 4))],
          ),
        ),
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
        priority: 100,
      ));
    }
  }
}

// ---------------------------------------------------------------------------
// 2. EL TABLERO
// ---------------------------------------------------------------------------
class Tablero extends PositionComponent {
  Tablero({double x = 0, double y = 0}) {
    position = Vector2(x, y);
  }

  @override
  Future<void> onLoad() async {
    double tamano = 80.0;
    double margen = 10.0;

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        add(Casilla(
          fila: i,
          columna: j,
          x: j * (tamano + margen),
          y: i * (tamano + margen),
          size: tamano,
        ));
      }
    }
  }
}

// ---------------------------------------------------------------------------
// 3. LA CASILLA
// ---------------------------------------------------------------------------
class Casilla extends PositionComponent with TapCallbacks, HasGameRef<LuckyNumbersGame> {
  final int fila;
  final int columna;

  Casilla({
    required this.fila, 
    required this.columna, 
    required double x, 
    required double y, 
    required double size
  }) {
    position = Vector2(x, y);
    this.size = Vector2(size, size);
  }

  @override
  Future<void> onLoad() async {
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.blueGrey.withOpacity(0.3),
    ));
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    // NUEVO: Si el juego ya terminó, prohibido hacer clic
    if (gameRef.finDelJuego) return;

    int numeroAColocar = gameRef.numeroActual;
    bool esLegal = gameRef.esMovimientoValido(fila, columna, numeroAColocar);

    if (esLegal) {
      // Borrar ficha anterior si existe
      children.whereType<Ficha>().forEach((ficha) {
        ficha.removeFromParent();
      });

      // Poner nueva ficha
      add(Ficha(valor: numeroAColocar)..position = size / 2);
      
      // Actualizar datos
      gameRef.matrizTablero[fila][columna] = numeroAColocar;
      
      print("Ficha colocada: $numeroAColocar en [$fila,$columna]");

      // IMPORTANTE: Primero verificamos si ganó.
      // Si gana, 'finDelJuego' se vuelve true.
      gameRef.verificarVictoria();

      // Si NO ganó, generamos el siguiente número.
      if (!gameRef.finDelJuego) {
        gameRef.generarNuevoNumero();
      }

    } else {
      print("¡MOVIMIENTO ILEGAL!");
    }
  }
}

// ---------------------------------------------------------------------------
// 4. LA FICHA
// ---------------------------------------------------------------------------
class Ficha extends PositionComponent {
  final int valor;

  Ficha({required this.valor}) {
    size = Vector2(70, 70);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    add(CircleComponent(
      radius: size.x / 2,
      paint: Paint()..color = Colors.amber,
    ));

    add(TextComponent(
      text: '$valor',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 35,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: size / 2,
      anchor: Anchor.center,
    ));
  }
}