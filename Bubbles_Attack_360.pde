// VIDEO JUEGO "BUBBLES ATTACK 360°"

// ==== Importar librería sonido ====
import ddf.minim.*;

// ==== Constantes del Juego ====
int tripleShotDuration = 10000; // Duración bonus "3S".
int fiveShootsDuration = 10000; // Duración bonus "5S".
int blinkDuration = 5000;       // Duración parpadeo cuando el jugador es alcanzado.
int lifeBonusPoints = 25;       // Puntos otorgados si las 3 vidas están intactas.

// ==== Arrays para Objetos del Juego ====
ArrayList<Enemy> enemies;           // Lista enemigos.
ArrayList<Projectile> projectiles;  // Lista proyectiles.
ArrayList<Star> stars;              // Lista estrellas para el fondo.
ArrayList<Bonus> bonuses;           // Lista bonus.
ArrayList<Explosion> explosions;    // Lista explosiones de enemigos.

// ==== Estados del Juego ====
String gameState = "start";     // Estado inicial del juego ("start", "instructions", "credits", "game")
boolean gameOver = false;       // Indicador fin del juego.
boolean paused = false;         // Indicador pausa.

// ==== Jugador ====
Player player;                  // Jugador.
int score = 0;                  // Puntuación jugador.
int lives = 3;                  // Vidas jugador.
boolean isBlinking = false;     // Indicador parpadeo nave cuando el jugador es alcanzado.
int blinkStartTime = 0;         // Tiempo de inicio del parpadeo nave.

// ==== Temporizadores ====
int nextBonusFrame = 0;         // Frame en el que se generará el próximo bonus.
int nextLifeBonusFrame = 0;     // Frame en el que se generará el próximo bonus 1UP.
int gameOverTime = 0;           // Tiempo en que ocurrió el Game Over.
int tripleShotStartTime = 0;    // Tiempo de inicio del bonus "3S".
int fiveShootsStartTime = 0;    // Tiempo de inicio del bonus "5S".

// ==== Estados de Bonus ====
boolean tripleShotActive = false; // Indicador bonus "3S" activo.
boolean fiveShootsActive = false; // Indicador bonus "5S" activo.

// ==== Manejo de Sonido ====
Minim minim;                    // Objeto para inicializar sonidos
AudioPlayer shootSound;         // Sonido disparo simple.
AudioPlayer tripleShotSound;    // Sonido 3 disparos.
AudioPlayer fiveShootSound;     // Sonido 5 disparos.
AudioPlayer oneUpSound;         // Sonido obtención bonus "1UP".
AudioPlayer emergencySound;     // Sonido colisión nave con enemigo.
AudioPlayer gameOverSound;      // Sonido game over.
AudioPlayer soundtrack;         // Música de fondo.
AudioPlayer explosionSound;     // Sonido alcance enemigo.



// ==== SETUP ====
void setup() {
  // Configuración ventana juego.
  size(800, 600); // Tamaño canvas.
  frameRate(60);  // Tasa de frames/segundo.

  // Inicialización de objetos principales.
  player = new Player(width / 2, height / 2);  // Posiciona al jugador en el centro del canvas.
  enemies = new ArrayList<Enemy>();            // Lista vacía de enemigos.
  projectiles = new ArrayList<Projectile>();   // Lista vacía de proyectiles.
  stars = new ArrayList<Star>();               // Lista vacía de estrellas de fondo.
  explosions = new ArrayList<Explosion>();     // Lista vacía de explosiones.
  bonuses = new ArrayList<Bonus>();            // Lista vacía de bonus.

  // Configuración bonus "1UP"
  nextLifeBonusFrame = frameCount + int(random(60 * 60 * 1, 60 * 60 * 2)); // Primera aparición bonus "1UP" entre 1 y 2 minutos despues de inicio.

  // Inicialización de sonidos.
  minim = new Minim(this); // Inicializar Minim para manejar sonidos

  // Cargar sonidos desde carpeta "data".
  shootSound = minim.loadFile("1_Shoot.wav");        // Sonido disparo simple.
  tripleShotSound = minim.loadFile("3_Shoot.wav");   // Sonido 3 disparos.
  fiveShootSound = minim.loadFile("5_Shoot.wav");    // Sonido 5 disparos.
  oneUpSound = minim.loadFile("1_Up.wav");           // Sonido obtención bonus "1UP".
  emergencySound = minim.loadFile("Emergency.wav");  // Sonido colisión nave con enemigo.
  gameOverSound = minim.loadFile("Game_Over.wav");   // Sonido game over.
  soundtrack = minim.loadFile("Soundtrack.wav");     // Música de fondo.
  explosionSound = minim.loadFile("Explosion.wav");  // Sonido alcance enemigo.

  // Ajuste volumen.
  emergencySound.setGain(-6.0); // Reduce volumen sonido de emergencia.
  soundtrack.setGain(-8.0);     // Reduce volumen música de fondo.

  // Inicialización fondo de estrellas.
  for (int i = 0; i < 100; i++) {
    stars.add(new Star()); // Genera 100 estrellas aleatorias.
  }
}


// ==== DRAW ====
void draw() {
  background(30); // Fondo negro para todas las pantallas

  // ==== PANTALLA DE INICIO ====
  if (gameState.equals("start")) {
    // Fondo animado estrellas
    for (Star star : stars) {
      star.update();
      star.display();
    }

    // Animación del título principal
    float titleSize = 50 + 10 * sin(frameCount * 0.05); // Variación tamaño.
    fill(lerpColor(color(255, 0, 255), color(0, 255, 255), 0.5 + 0.5 * sin(frameCount * 0.05))); // Cambio colores.
    textAlign(CENTER, CENTER);
    textSize(titleSize);
    text("Bubbles Attack 360°", width / 2, height / 3); // Título del juego

    // Subtítulos opciones.
    fill(255);
    textSize(20);
    text("Press 'Enter' to start the game", width / 2, height / 2);
    text("Press 'I' to see instructions", width / 2, height / 2 + 40);
    text("Press 'C' to see credits", width / 2, height / 2 + 80);

    return;
  }

  // ==== PANTALLA DE INSTRUCCIONES ====
  else if (gameState.equals("instructions")) {
    // Fondo animado estrellas
    for (Star star : stars) {
      star.update();
      star.display();
    }

    // Título sección.
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(30);
    text("Instructions", width / 2, height / 4);

    // Controles jugador
    textSize(20);
    text("Move the ship: ↑ ↓ ← → (Arrow keys)", width / 2, height / 2 - 80);
    text("Shoot: Click towards the mouse pointer", width / 2, height / 2 - 50);

    // Información bonus.
    fill(255);
    text("BONUS:", width / 2, height / 2 - 20);

    fill(0, 255, 0); // Verde para "3S"
    text("3S => Triple Shoots", width / 2, height / 2 + 10);

    fill(0, 255, 255); // Cian para "5S"
    text("5S => Five Shoots", width / 2, height / 2 + 40);

    fill(255, 255, 0); // Amarillo para "1UP"
    text("1UP => Extra Life", width / 2, height / 2 + 70);

    // Texto volver atrás.
    fill(255);
    textSize(20);
    text("Press 'B' to go back", width / 2, height / 2 + 130);

    return;
  }

  // ==== PANTALLA DE CRÉDITOS ====
  else if (gameState.equals("credits")) {
    // Fondo animado estrellas
    for (Star star : stars) {
      star.update();
      star.display();
    }

    // Título y créditos
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(30);
    text("Credits", width / 2, height / 4);
    textSize(20);
    text("Developed by 'JOSE CARMONA'.", width / 2, height / 2 - 90);
    text("Inspired by 'GEOMETRY WARS':", width / 2, height / 2 - 60);

    // Link Wikipedia.
    fill(0, 255, 255); // Cian enlaces
    text("https://en.wikipedia.org/wiki/Geometry_Wars", width / 2, height / 2 - 30);

    fill(255);
    text("Sounds used in this project are from:", width / 2, height / 2);

    // Link Zapsplat.
    fill(0, 255, 255); // Cian enlaces
    text("https://www.zapsplat.com", width / 2, height / 2 + 30);

    fill(255);
    text("Licence:", width / 2, height / 2 + 60);

    // Link licencia de uso Zapsplat.
    fill(0, 255, 255); // Cian enlaces
    text("https://www.zapsplat.com/license-type/standard-license/", width / 2, height / 2 + 90);

    fill(255);
    text("Soundtrack created with GarageBand (Apple):", width / 2, height / 2 + 120);

    // Link licencia de uso GarageBand (Apple).
    fill(0, 255, 255); // Cian enlaces
    text("https://support.apple.com/es-es/102034?utm_source=chatgpt.com", width / 2, height / 2 + 150);

    // Texto volver atrás.
    fill(255);
    text("Press 'B' to go back", width / 2, height / 2 + 210);

    return;
  }

  // ==== PANTALLA DE PAUSA ====
  if (paused) {
    // Fondo oscuro y texto de pausa
    background(30);
    fill(255);
    textSize(30);
    textAlign(CENTER);
    text("Paused", width / 2, height / 2);
    return;
  }

  // ==== ANIMACIÓN ESTRELLAS ====
  for (Star star : stars) {
    star.update();
    star.display();
  }

  // ==== JUEGO EN CURSO ====
  if (!gameOver) {
    // ==== DIBUJAR JUGADOR ====
    player.update();

    // Mostrar jugador con parpadeo si está activo.
    if (isBlinking) {
      if ((millis() - blinkStartTime) % 500 < 250) {
        player.display(); // Mostrar jugador cada 250ms (parpadeo).
      }
      if (millis() - blinkStartTime > blinkDuration) {
        isBlinking = false; // Desactiva parpadeo después duración establecida.
      }
    } else {
      player.display(); // Mostrar jugador normal.
    }

    // ==== DIBUJAR PROYECTILES ====
    for (int i = projectiles.size() - 1; i >= 0; i--) {
      Projectile p = projectiles.get(i);
      p.update();
      p.display();

      // Elimina proyectiles fuera de pantalla.
      if (p.isOffScreen()) {
        projectiles.remove(i);
      }
    }

    // ==== DIBUJAR EXPLOSIONES ====
    for (int i = explosions.size() - 1; i >= 0; i--) {
      Explosion ex = explosions.get(i);
      ex.update();
      ex.display();
      if (ex.isFinished()) {
        explosions.remove(i); // Elimina explosión cuando termina.
      }
    }

    // ==== DIBUJAR BONUS ====
    for (int i = bonuses.size() - 1; i >= 0; i--) {
      Bonus b = bonuses.get(i);
      b.update();
      b.display();

      // Colisión jugador-bonus.
      if (dist(b.x, b.y, player.x, player.y) < player.size / 2 + 15) {
        bonuses.remove(i); // Elimina bonus recogido por jugador.

        // Activa efecto según bonus.
        if (b.type.equals("3S")) {
          tripleShotActive = true;
          tripleShotStartTime = millis();
        } else if (b.type.equals("5S")) {
          fiveShootsActive = true;
          fiveShootsStartTime = millis();
        } else if (b.type.equals("1UP")) {
          if (lives < 3) {
            lives++; // Añade vida si hay menos de 3
          } else {
            score += lifeBonusPoints; // Añade puntos si el jugador ya tiene 3 vidas.
          }
          oneUpSound.rewind(); // Reproduce sonido 1UP.
          oneUpSound.play();
        }
      }

      // Desactiva efectos bonus tras duración establecida.
      if (tripleShotActive && millis() - tripleShotStartTime > tripleShotDuration) {
        tripleShotActive = false;
      }
      if (fiveShootsActive && millis() - fiveShootsStartTime > fiveShootsDuration) {
        fiveShootsActive = false;
      }

      // Genera bonus "1UP" en intervalos.
      if (frameCount >= nextLifeBonusFrame) {
        bonuses.add(new Bonus("1UP"));
        nextLifeBonusFrame = frameCount + int(random(60 * 30, 60 * 60)); // Próximo bonus entre 30-60 segundos
      }

      // Elimina bonus fuera de la pantalla.
      if (b.isOffScreen()) {
        bonuses.remove(i);
      }
    }

    // ==== DIBUJAR ENEMIGOS ====
    for (int i = enemies.size() - 1; i >= 0; i--) {
      Enemy e = enemies.get(i);
      e.update();
      e.display();

      // Colisión proyectil-enemigo.
      for (int j = projectiles.size() - 1; j >= 0; j--) {
        Projectile p = projectiles.get(j);
        if (dist(e.x, e.y, p.x, p.y) < e.size / 2) {
          // Crea explosión y reproducir sonido.
          explosions.add(new Explosion(e.x, e.y));
          explosionSound.rewind();
          explosionSound.play();

          enemies.remove(i); // Elimina enemigo.
          projectiles.remove(j); // Elimina proyectil.
          score++; // Suma puntuación.
          break;
        }
      }

      // Colisión enemigo-jugador.
      if (!isBlinking && dist(e.x, e.y, player.x, player.y) < player.size / 2 + e.size / 2 + 10) {
        lives--; // Reduce vidas.
        enemies.remove(i); // Elimina enemigo.
        isBlinking = true; // Activa parpadeo.
        blinkStartTime = millis();

        if (lives <= 0) {
          // Fin del juego si no hay vidas.
          gameOverSound.rewind(); // Reproduce sonido game over.
          gameOverSound.play();
          soundtrack.pause();
          gameOver = true;
          gameOverTime = millis();
        } else {
          emergencySound.rewind(); // Reproduce sonido emergencia si todavía quedan vidas.
          emergencySound.play();
        }
      }

      // Elimina enemigos fuera de la pantalla.
      if (e.isOffScreen()) {
        enemies.remove(i);
      }
    }

    // Generar nuevos enemigos.
    if (frameCount % 60 == 0) {
      enemies.add(new Enemy());
    }

    // Generar bonus random.
    if (frameCount >= nextBonusFrame) {
      String type = random(1) > 0.5 ? "3S" : "5S";
      bonuses.add(new Bonus(type));
      nextBonusFrame = frameCount + int(random(1500, 1800)); // Entre 25-30 segundos
    }

    // ==== DIBUJAR PUNTUACIÓN Y VIDAS(NAVES) ====
    fill(255);
    textSize(20);
    textAlign(LEFT, TOP);
    text("Score: " + score, 30, 30);

    // Iconos de vidas.
    for (int i = 0; i < lives; i++) {
      float iconSize = 20;
      float x = width - (i + 1) * (iconSize + 10);
      float y = 20;
      pushMatrix();
      translate(x + iconSize / 2, y + iconSize / 2);
      fill(0, 255, 0);
      noStroke();

      rect(-iconSize / 2, -iconSize / 2, iconSize / 4, iconSize); // Columna izquierda
      rect(iconSize / 4, -iconSize / 2, iconSize / 4, iconSize);  // Columna derecha
      arc(0, iconSize / 2, iconSize, iconSize, PI, TWO_PI);       // Curva inferior
      popMatrix();
    }
  }

  // ==== PANTALLA DE FIN DE JUEGO ====
  else {
    fill(255);
    textSize(30);
    textAlign(CENTER);
    text("Game Over!", width / 2, height / 2 - 20);
    text("Final Score: " + score, width / 2, height / 2 + 20);
    text("Click to Restart", width / 2, height / 2 + 60);
  }
}


// ==== FUNCIONES DE TECLAS Y MOUSE ====

// === Función manejo teclas presionadas ===
void keyPressed() {
  // Manejo pantalla de inicio.
  if (gameState.equals("start")) {
    if (key == ENTER) {
      gameState = "game"; // Inicia juego.
      soundtrack.loop();  // Iniciar música de fondo al entrar al juego.
    } else if (key == 'i' || key == 'I') {
      gameState = "instructions"; // Muestra instrucciones.
    } else if (key == 'c' || key == 'C') {
      gameState = "credits"; // Muestra créditos.
    }
  }
  // Manejo pantallas instrucciones y créditos.
  else if (gameState.equals("instructions") || gameState.equals("credits")) {
    if (key == 'b' || key == 'B') {
      gameState = "start"; // Regresa a la pantalla de inicio.
    }
  }
  // Manejo pantalla juego.
  else if (gameState.equals("game")) {
    if (key == 'p' || key == 'P') {
      paused = !paused; // Pausar/Reanudar juego.
    }
    // Manejo movimiento nave al pulsar.
    if (keyCode == UP) player.moveUp = true;
    if (keyCode == DOWN) player.moveDown = true;
    if (keyCode == LEFT) player.moveLeft = true;
    if (keyCode == RIGHT) player.moveRight = true;
  }
}

// === Función manejo teclas liberadas ===
void keyReleased() {
  // Detiene movimiento nave al dejar de pulsar.
  if (keyCode == UP) player.moveUp = false;
  if (keyCode == DOWN) player.moveDown = false;
  if (keyCode == LEFT) player.moveLeft = false;
  if (keyCode == RIGHT) player.moveRight = false;
}


// === Función manejo clics mouse ===
void mousePressed() {
  // Ignora clics si el juego está en pausa.
  if (paused) {
    return;
  }

  // Manejo pantalla créditos.
  if (gameState.equals("credits")) {
    // Detecta clic en los enlaces
    detectLinkClick(
      "https://en.wikipedia.org/wiki/Geometry_Wars",
      width / 2, height / 2 - 30
      );
    detectLinkClick(
      "https://www.zapsplat.com",
      width / 2, height / 2 + 30
      );
    detectLinkClick(
      "https://www.zapsplat.com/license-type/standard-license/",
      width / 2, height / 2 + 90
      );
    detectLinkClick(
      "https://support.apple.com/es-es/102034?utm_source=chatgpt.com",
      width / 2, height / 2 + 150
      );
  }

  // Manejo estado de juego.
  if (gameState.equals("game") && !gameOver) {
    handleProjectileShoot(); // Manejar disparos.
  }
  // Manejo tras fin del juego.
  else if (gameState.equals("game") && gameOver) {
    handleGameOverReset(); // Reinicia juego tras Game Over.
  }
}

// === Función manejo clics en enlaces ===
void detectLinkClick(String url, float x, float y) {
  float linkWidth = textWidth(url);
  float linkHeight = 20; // Altura aproximada del texto.
  if (mouseX > x - linkWidth / 2 && mouseX < x + linkWidth / 2 &&
    mouseY > y - linkHeight / 2 && mouseY < y + linkHeight / 2) {
    link(url);
  }
}

// === Función  manejo disparos nave ===
void handleProjectileShoot() {
  // Determina qué sonido reproducir.
  if (fiveShootsActive && millis() - fiveShootsStartTime <= fiveShootsDuration) {
    fiveShootSound.rewind();
    fiveShootSound.play();
  } else if (tripleShotActive && millis() - tripleShotStartTime <= tripleShotDuration) {
    tripleShotSound.rewind();
    tripleShotSound.play();
  } else {
    shootSound.rewind();
    shootSound.play();
  }

  // Disparo proyectil simple.
  float shootAngle = atan2(mouseY - player.y, mouseX - player.x);
  projectiles.add(new Projectile(player.x, player.y, shootAngle));

  // Disparo proyectiles adicionales para "3S".
  if (tripleShotActive && millis() - tripleShotStartTime <= tripleShotDuration) {
    float offsetAngle = PI / 6;
    projectiles.add(new Projectile(player.x, player.y, shootAngle + offsetAngle));
    projectiles.add(new Projectile(player.x, player.y, shootAngle - offsetAngle));
  }

  // Disparar proyectiles adicionales para "5S".
  if (fiveShootsActive && millis() - fiveShootsStartTime <= fiveShootsDuration) {
    float offsetAngle = PI / 6;
    projectiles.add(new Projectile(player.x, player.y, shootAngle + offsetAngle));
    projectiles.add(new Projectile(player.x, player.y, shootAngle - offsetAngle));
    projectiles.add(new Projectile(player.x, player.y, shootAngle + 2 * offsetAngle));
    projectiles.add(new Projectile(player.x, player.y, shootAngle - 2 * offsetAngle));
  }
}

// === Función reinicio juego tras Game Over ===
void handleGameOverReset() {
  // Espera 5 segundos antes de reiniciar.
  if (millis() - gameOverTime >= 5000) {
    // Reinicia variables del juego.
    score = 0;
    lives = 3;
    gameOver = false;
    player = new Player(width / 2, height / 2);
    enemies.clear();
    projectiles.clear();
    bonuses.clear();
    textAlign(LEFT, TOP);

    // Reanuda música de fondo.
    soundtrack.rewind();
    soundtrack.loop();
  }
}

// === CLASES ===

// Clase jugador.
class Player {
  float x, y;      // Posición del jugador
  float size = 20; // Tamaño del jugador
  float speed = 5; // Velocidad de movimiento
  float angle = 0; // Ángulo de rotación
  boolean moveUp, moveDown, moveLeft, moveRight; // Indicadores de movimiento

  // Determina posición inicial jugador.
  Player(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void update() {
    // Actualiza posición nave basándose en las variables de movimiento.
    if (moveUp && y > size / 2) y -= speed; // Arriba
    if (moveDown && y < height - size / 2) y += speed; // Abajo
    if (moveLeft && x > size / 2) x -= speed; // Izquierda
    if (moveRight && x < width - size / 2) x += speed; // Derecha

    // Calcula ángulo hacia donde apunta nave basándose en posición del mouse.
    angle = atan2(mouseY - y, mouseX - x) + PI / 2;
  }

  // Dibuja nave.
  void display() {
    pushMatrix();     // Guardar estado de transformación.
    translate(x, y);  // Mover al centro del jugador.
    rotate(angle);    // Rotar según el ángulo calculado.
    fill(0, 255, 0);  // Color del jugador.
    noStroke();

    // Dibujar la nave en forma de "U"
    float halfSize = size / 2;
    float quarterSize = size / 4;
    rect(-halfSize, -halfSize, quarterSize, size);   // Columna izquierda.
    rect(quarterSize, -halfSize, quarterSize, size); // Columna derecha.
    arc(0, size / 2, size, size, PI, TWO_PI);        // Curva inferior.

    popMatrix(); // Restaurar estado de transformación.
  }
}

// Clase enemigos.
class Enemy {
  float x, y; // Posición enemigo.
  float size = random(10, 30); // Tamaño aleatorio enemigo.
  float speedX, speedY; // Velocidad movimiento.

  Enemy() {
    // Generar enemigo fuera del canvas aleatoriamente.
    int side = int(random(4)); // Elege un lado al azar.
    switch (side) {
    case 0:
      y = -size;
      x = random(width);
      break; // Arriba.
    case 1:
      x = width + size;
      y = random(height);
      break; // Derecha.
    case 2:
      y = height + size;
      x = random(width);
      break; // Abajo.
    case 3:
      x = -size;
      y = random(height);
      break; // Izquierda.
    }
    // Velocidad enemigo aleatoria.
    speedX = random(-3, 3);
    speedY = random(-3, 3);
    if (side == 0) speedY = abs(speedY);  // Desde arriba, moverse hacia abajo.
    if (side == 1) speedX = -abs(speedX); // Desde la derecha, moverse hacia la izquierda.
    if (side == 2) speedY = -abs(speedY); // Desde abajo, moverse hacia arriba.
    if (side == 3) speedX = abs(speedX);  // Desde la izquierda, moverse hacia la derecha.
  }


  // Actualiza posición enemigo en cada frame sumándole su velocidad.
  void update() {
    x += speedX;
    y += speedY;
  }

  // Dibuja enemigo.
  void display() {
    fill(255, 0, 0); // Color enemigo.
    ellipse(x, y, size, size);
  }

  // Verifica si enemigo ha salido del canvas.
  boolean isOffScreen() {
    return x < -size || x > width + size || y < -size || y > height + size;
  }
}

// Clase proyectiles.
class Projectile {
  float x, y;       // Posición proyectil.
  float speed = 10; // Velocidad proyectil.
  float angle;      // Dirección proyectil.
  float size = 5;   // Tamaño proyectil.

  // Constructor
  Projectile(float x, float y, float angle) {
    this.x = x; // Inicializa posición horizontal del proyectil en coordenada "x" recibida como parámetro.
    this.y = y; // Inicializa posición vertical del proyectil en coordenada "y" recibida como parámetro.
    this.angle = angle; // Define dirección del proyectil.
  }

  // Actualiza posición proyectil.
  void update() {
    x += cos(angle) * speed; // Mueve proyectil en "x" según ángulo y velocidad.
    y += sin(angle) * speed; // Mueve proyectil en "y" según ángulo y velocidad.
  }

  // Dibuja proyectil.
  void display() {
    fill(255, 255, 0); // Color amarillo
    ellipse(x, y, size, size); // Dibuja proyectil círculo.
  }

  // Verifica si proyectil ha salido del canvas
  boolean isOffScreen() {
    return x < 0 || x > width || y < 0 || y > height;
  }
}

// Clase bonus.
class Bonus {
  float x, y;      // Posición bonus.
  float size = 20; // Tamaño bonus.
  float speed;     // Velocidad bonus.
  String type;     // Tipo de bonus ("3S", "5S", "1UP").

  // Constructor
  Bonus(String type) {
    this.type = type;  // Asigna tipo de bonus recibido como parámetro de instancia.
    x = random(width); // Posición horizontal aleatoria.
    y = -size;         // Posición fuera del canvas, en parte superior.
    speed = type.equals("1UP") ? 5 : 3; // Velocidad según tipo de bonus.
  }

  // Actualiza posición del bonus.
  void update() {
    y += speed; // Incrementa posición vertical según velocidad.
  }

  // Dibuja bonus.
  void display() {
    textAlign(CENTER, CENTER);
    textSize(size);
    if (type.equals("1UP")) {
      fill(255, 253, 111); // Amarillo para "1UP"
      text("1UP", x, y);
    } else {
      fill(0, 255, 255); // Cian para "3S" y "5S"
      text(type, x, y);
    }
  }

  // Verifica si bonus ha salido del canvas
  boolean isOffScreen() {
    return y > height + size;
  }
}

// Clase explosion.
class Explosion {
  float x, y;         // Posición explosión.
  float size = 10;    // Tamaño inicial.
  int startTime;      // Tiempo inicial.
  int duration = 500; // Duración explosión.

  // Constructor.
  Explosion(float x, float y) {
    this.x = x; // Asigna coordenada horizontal donde ocurre explosión.
    this.y = y; // Asigna coordenada vertical donde ocurre explosión.
    this.startTime = millis(); // Registra momento en que explosión comienza.
  }

  void update() {
    size += 5; // Incrementar tamaño explosión.
  }

  void display() {
    noFill(); // Explosión no tiene relleno, solo contorno.
    stroke(255, 0, 0); // Rojo
    strokeWeight(0.7); // Grosor del contorno.
    ellipse(x, y, size, size); // Dibuja círculo centrado.
  }

  // Verifica si explosión ha durado más tiempo que su duracion.
  boolean isFinished() {
    return millis() - startTime > duration;
  }
}

// Clase estrellas.
class Star {
  float x, y, size, speed;

  Star() {
    x = random(width);      // Posición inicial horizontal aleatoria.
    y = random(height);     // Posición inicial vertical aleatoria.
    size = random(1, 3);    // Tamaño aleatorio.
    speed = random(0.5, 2); // Velocidad vertical aleatoria.
  }

  void update() {
    y += speed; // Incrementa posición vertical simulando que se mueve hacia abajo.
    if (y > height) {  // Comprueba si estrella ha salido por la parte inferior del canvas.
      y = 0; // Si estrella sale del canvas, se reinicia su posición vertical al inicio del canvas.
      x = random(width);  // Nueva posición horizontal aleatoria.
    }
  }

  // Dibuja esterella
  void display() {
    fill(255);
    noStroke();
    ellipse(x, y, size, size);
  }
}
