ArrayList<Boid> flock; 

boolean vientoActivo = false;
boolean friccionActiva = false;
float magnitudViento = 0.1;   
float coefFriccion = 0.05;    

// El destino al que deben volar
PVector destino;

// Variables para el Líder y su curva Bezier
PVector posLider;
float tLider = 0;
// Regla 5 - Variables para el Depredador
PVector posDepredador;
boolean depredadorActivo = false;

void setup() {
  size(800, 600, P3D); 
  flock = new ArrayList<Boid>();
  
  for (int i = 0; i < 20; i++) {
    PVector startPos = new PVector(random(width), random(height), random(-300, 300));
    flock.add(new Boid(startPos));
  }
  
  // Inicializar el destino en el centro
  destino = new PVector(width/2, height/2, 0);
  
  posDepredador = new PVector(0, 0, 0);
}

void draw() {
  background(20, 50, 100); 
  lights(); 
  
  //Calcular la posición del Líder usando una curva Bezier 3D
  tLider += 0.003; // Velocidad de movimiento en la curva
  if (tLider > 1.0) tLider = 0; // Reiniciar el ciclo
  
  // Puntos de control Bezier (x1, cx1, cx2, x2)
  float lx = bezierPoint(100, 700, 100, 700, tLider);
  float ly = bezierPoint(100, 100, 500, 500, tLider);
  float lz = bezierPoint(-200, 200, 200, -200, tLider);
  posLider = new PVector(lx, ly, lz);
  
  //Dibujar al Líder (Cubo Amarillo
  pushMatrix();
  translate(posLider.x, posLider.y, posLider.z);
  fill(255, 255, 0); // Color Amarillo
  box(25); // El líder es un poco más grande
  popMatrix();
  
  // Dibujar el destino como una esfera roja
  pushMatrix();
  translate(destino.x, destino.y, destino.z);
  noStroke();
  fill(255, 50, 50);
  sphere(10);
  popMatrix();
  
  // Si mantenemos pulsado el botón DERECHO del ratón, aparece el depredador
  if (mousePressed && mouseButton == RIGHT) {
    depredadorActivo = true;
    posDepredador.x = mouseX;
    posDepredador.y = mouseY;
    
    // Dibujar el Depredador (Esfera Negra grande
    pushMatrix();
    translate(posDepredador.x, posDepredador.y, posDepredador.z);
    fill(0); // Color Negro
    sphere(25);
    popMatrix();
  } else {
    depredadorActivo = false; // Si soltamos, desaparece
  }
  
  dibujarUI();
  
  for (Boid b : flock) {
    if (vientoActivo) b.applyForce(new PVector(magnitudViento, 0, 0));
    if (friccionActiva) {
      PVector friccion = b.vel.copy();
      friccion.normalize();
      friccion.mult(-1 * coefFriccion);
      b.applyForce(friccion);
    }
    
    // Nuevo: Aplicar las reglas de inteligencia grupal
    b.aplicarComportamiento(flock, destino, posLider, posDepredador, depredadorActivo);
    
    b.update();
    b.display();
  }
}

// Mover el destino con el ratón
void mouseDragged() {
  destino.x = mouseX;
  destino.y = mouseY;
}

void keyPressed() {
  if (key == 'v' || key == 'V') vientoActivo = !vientoActivo; 
  if (key == 'f' || key == 'F') friccionActiva = !friccionActiva; 
  if (key == '+') magnitudViento += 0.05; 
  if (key == '-') magnitudViento = max(0, magnitudViento - 0.05); 
}

void dibujarUI() {
  hint(DISABLE_DEPTH_TEST); 
  fill(255);
  textSize(16);
  text("Controles Teclado:", 20, 30);
  text("[V] Viento: " + (vientoActivo ? "ON" : "OFF"), 20, 55);
  text("[F] Friccion: " + (friccionActiva ? "ON" : "OFF"), 20, 80);
  text("Usa el RATON (Arrastrar) para mover el Destino Rojo", 20, 105);
  hint(ENABLE_DEPTH_TEST); 
}
