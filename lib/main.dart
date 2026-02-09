import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: LuckyNumbersGame()));
}

class LuckyNumbersGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    // Aquí usamos nuestro "molde" para crear dos fichas distintas
    
    // Ficha 1: Número 7
    add(Ficha(numero: 7, x: 100, y: 200));

    // Ficha 2: Número 12
    add(Ficha(numero: 12, x: 250, y: 200));
  }
}

// --- ESTE ES EL MOLDE (CLASE) DE TUS FICHAS ---
class Ficha extends PositionComponent {
  final int numero;

  // Constructor: Pide el número y la posición al crearse
  Ficha({required this.numero, double x = 0, double y = 0}) {
    position = Vector2(x, y);
    size = Vector2(100, 100); // Tamaño cuadrado de 100x100
  }

  @override
  Future<void> onLoad() async {
    // 1. Dibujamos el fondo (Un cuadrado color trébol/oro)
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.orange, 
    ));

    // 2. Dibujamos el número encima
    add(TextComponent(
      text: '$numero', // Convierte el número a texto
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 50,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: size / 2, // Lo ponemos en el centro del cuadrado
      anchor: Anchor.center, // Alineación central
    ));
  }
}