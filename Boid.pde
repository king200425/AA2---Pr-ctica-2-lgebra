class Boid {
  PVector pos;      // Vector de posición (x, y, z)
  PVector vel;      // Vector de velocidad (x, y, z)
  PVector acc;      // Vector de aceleración (x, y, z)
  float maxSpeed;   // Velocidad máxima permitida

  Boid(PVector startPos) {
    pos = startPos.copy();
    vel = PVector.random3D(); // Dirección de vuelo 3D aleatoria inicial
    vel.mult(random(1, 2));   // Magnitud de la velocidad inicial
    acc = new PVector(0, 0, 0); // Aceleración inicial a 0
    maxSpeed = 3.0;
  }
  
  // Mecanismo algebraico central: Segunda ley de Newton (F = M*A)
  // Asumiendo que la masa (M) es 1, entonces la aceleración (A) es igual a la fuerza (F)
  void applyForce(PVector force) {
    acc.add(force);
  }

  void update() {
    vel.add(acc);        // La velocidad se actualiza sumando la aceleración
    vel.limit(maxSpeed); // Limitar la velocidad máxima para evitar movimientos caóticos
    pos.add(vel);        // La posición se actualiza sumando la velocidad
    acc.mult(0);         // ¡MUY IMPORTANTE! Resetear la aceleración a 0 en cada frame
    
    checkEdges();        // Comprobar los bordes del entorno 3D
  }

  void display() {
    pushMatrix(); // Guardar el sistema de coordenadas actual
    
    // Mover el origen de coordenadas a la posición actual del Boid
    translate(pos.x, pos.y, pos.z); 
    
    noStroke();
    fill(200, 220, 255);
    box(15); // Dibujar un cubo 3D de 15x15x15 para representar la criatura
    
    popMatrix(); // Restaurar el sistema de coordenadas original
  }
  
  // Comprobar si el Boid sale de los límites de la pantalla y reubicarlo (efecto Pac-Man)
  void checkEdges() {
    if (pos.x > width) pos.x = 0;
    if (pos.x < 0) pos.x = width;
    if (pos.y > height) pos.y = 0;
    if (pos.y < 0) pos.y = height;
    if (pos.z > 300) pos.z = -300;
    if (pos.z < -300) pos.z = 300;
  }
}
