ArrayList<Boid> flock; 

boolean vientoActivo = false;
boolean friccionActiva = false;
float magnitudViento = 0.1;   
float coefFriccion = 0.05;    

PVector destino;
PVector posLider;
float tLider = 0;

PVector posDepredador;
boolean depredadorActivo = false;

// Variables para la cámara, la ruta y los obstáculos
boolean vistaIsometrica = true;  
boolean curvaBezier = true;      
PVector[] obstaculos;            

void setup() {
  size(800, 600, P3D); 
  flock = new ArrayList<Boid>();
  
  // Inicializar 20 criaturas (Boids)
  for (int i = 0; i < 20; i++) {
    PVector startPos = new PVector(random(width), random(height), random(-300, 300));
    flock.add(new Boid(startPos));
  }
  
  destino = new PVector(width/2, height/2, 0);
  posDepredador = new PVector(0, 0, 0);
  
  // Inicializar los 4 obstáculos fijos
  obstaculos = new PVector[4];
  obstaculos[0] = new PVector(200, 200, 0);
  obstaculos[1] = new PVector(600, 200, 0);
  obstaculos[2] = new PVector(200, 400, 0);
  obstaculos[3] = new PVector(600, 400, 0);
}

void draw() {
  background(20, 50, 100); 
  
  // Configuración de la cámara (Isométrica o Ortográfica)
  if (vistaIsometrica) {
    ortho(-width/2, width/2, -height/2, height/2, -1000, 1000);
    camera(width/2 + 400, height/2 + 400, 400, width/2, height/2, 0, 0, 1, 0);
  } else {
    ortho(-width/2, width/2, -height/2, height/2, -1000, 1000);
    camera(width/2, height/2, 800, width/2, height/2, 0, 0, 1, 0);
  }
  
  lights(); 
  
  // Dibujar los 4 obstáculos
  for (int i = 0; i < 4; i++) {
    pushMatrix();
    translate(obstaculos[i].x, obstaculos[i].y, obstaculos[i].z);
    fill(0, 200, 100); 
    box(30, 30, 200); 
    popMatrix();
  }
  
  // Calcular la trayectoria del líder (Bezier vs Interpolación Lineal)
  tLider += 0.003; 
  if (tLider > 1.0) tLider = 0; 
  float tPingPong = (tLider < 0.5) ? (tLider * 2) : (1.0 - (tLider - 0.5) * 2);

  if (curvaBezier) {
    posLider = new PVector(
      bezierPoint(100, 700, 100, 700, tLider),
      bezierPoint(100, 100, 500, 500, tLider),
      bezierPoint(-200, 200, 200, -200, tLider)
    );
  } else {
    posLider = new PVector(
      lerp(100, 700, tPingPong),
      lerp(100, 500, tPingPong),
      lerp(-200, 200, tPingPong)
    );
  }
  
  // Dibujar al Líder (Cubo Amarillo)
  pushMatrix();
  translate(posLider.x, posLider.y, posLider.z);
  fill(255, 255, 0); 
  box(25); 
  popMatrix();
  
  // Dibujar el destino (Esfera Roja)
  pushMatrix();
  translate(destino.x, destino.y, destino.z);
  noStroke();
  fill(255, 50, 50);
  sphere(10);
  popMatrix();
  
  // Lógica del depredador (Clic derecho)
  if (mousePressed && mouseButton == RIGHT) {
    depredadorActivo = true;
    posDepredador.x = mouseX;
    posDepredador.y = mouseY;
    
    pushMatrix();
    translate(posDepredador.x, posDepredador.y, posDepredador.z);
    fill(0); 
    sphere(25);
    popMatrix();
  } else {
    depredadorActivo = false; 
  }
  
  dibujarUI();
  
  // Actualizar todos los Boids
  for (Boid b : flock) {
    if (vientoActivo) b.applyForce(new PVector(magnitudViento, 0, 0));
    if (friccionActiva) {
      PVector friccion = b.vel.copy();
      friccion.normalize();
      friccion.mult(-1 * coefFriccion);
      b.applyForce(friccion);
    }
    
    // Aplicar los comportamientos grupales
    b.aplicarComportamiento(flock, destino, posLider, posDepredador, depredadorActivo, obstaculos);
    
    b.update();
    b.display();
  }
}

// Mover el destino arrastrando el ratón
void mouseDragged() {
  destino.x = mouseX;
  destino.y = mouseY;
}

// Controles de teclado
void keyPressed() {
  if (key == 'v' || key == 'V') vientoActivo = !vientoActivo; 
  if (key == 'f' || key == 'F') friccionActiva = !friccionActiva; 
  if (key == '+') magnitudViento += 0.05; 
  if (key == '-') magnitudViento = max(0, magnitudViento - 0.05); 
  if (key == 'c' || key == 'C') vistaIsometrica = !vistaIsometrica; 
  if (key == 'l' || key == 'L') curvaBezier = !curvaBezier; 
}

// Dibujar la interfaz de usuario en 2D
void dibujarUI() {
  camera(); 
  perspective(); 
  hint(DISABLE_DEPTH_TEST); 
  noLights(); 
  
  fill(255);
  textSize(14);
  text("Controles Teclado:", 20, 30);
  text("[V] Viento: " + (vientoActivo ? "ON" : "OFF"), 20, 50);
  text("[F] Friccion: " + (friccionActiva ? "ON" : "OFF"), 20, 70);
  text("[C] Camara: " + (vistaIsometrica ? "Isometrica" : "Top Ortografica"), 20, 90);
  text("[L] Lider Ruta: " + (curvaBezier ? "Bezier" : "Interpolacion"), 20, 110);
  text("Usa Click DERECHO para Depredador | Arrastrar IZQ para Mover Rojo", 20, 130);
  
  hint(ENABLE_DEPTH_TEST); 
}
