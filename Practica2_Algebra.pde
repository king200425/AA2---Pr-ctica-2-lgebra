ArrayList<Boid> flock; // Lista de todas las criaturas (rebaño/banco de peces)

void setup() {
  size(800, 600, P3D); // Requisito: inicializar el motor de renderizado 3D
  
  flock = new ArrayList<Boid>();
  
  // Requisito: instanciar al menos 20 criaturas
  for (int i = 0; i < 20; i++) {
    // Generar posición inicial aleatoria en el espacio 3D (X, Y, Z)
    PVector startPos = new PVector(random(width), random(height), random(-300, 300));
    flock.add(new Boid(startPos));
  }
}

void draw() {
  background(20, 50, 100); // Color de fondo (simulando el fondo del océano)
  lights(); // Activar luces 3D para dar volumen a los objetos
  
  // Recorrer la lista, actualizar y dibujar cada criatura
  for (Boid b : flock) {
    b.update();
    b.display();
  }
}
