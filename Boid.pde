class Boid {
  PVector pos;      // Vector de posición (x, y, z)
  PVector vel;      // Vector de velocidad (x, y, z)
  PVector acc;      // Vector de aceleración (x, y, z)
  float maxSpeed;   // Velocidad máxima permitida
  float maxForce;   // Nuevo: Fuerza máxima de giro

  Boid(PVector startPos) {
    pos = startPos.copy();
    vel = PVector.random3D(); // Dirección de vuelo 3D aleatoria inicial
    vel.mult(random(1, 2));   // Magnitud de la velocidad inicial
    acc = new PVector(0, 0, 0); // Aceleración inicial a 0
    maxSpeed = 3.0;
    maxForce = 0.05;
  }
  
  void applyForce(PVector force) {
    acc.add(force);
  }
  
 // NÚCLEO DE INTELIGENCIA ARTIFICIAL
    void aplicarComportamiento(ArrayList<Boid> boids, PVector destinoActual, PVector liderActual, PVector depredador, boolean hayDepredador) {
    //Calcular las 3 fuerzas heurísticas
    PVector fuerzaDestino = buscar(destinoActual);
    PVector fuerzaSeparacion = separar(boids);
    PVector fuerzaCohesion = juntar(boids);
    //Seguir al líder
    PVector fuerzaLider = buscar(liderActual);
    // Huir del depredador
    PVector fuerzaHuida = new PVector(0, 0, 0);
    if (hayDepredador) {
      fuerzaHuida = huir(depredador);
    }
    
    // Darles peso/importancia relativa
    fuerzaDestino.mult(1.0);    // Fuerza para ir al destino
    fuerzaSeparacion.mult(1.5); // Queremos que evitar choques sea prioritario
    fuerzaCohesion.mult(1.0);   // Fuerza para mantenerse en grupo
    fuerzaLider.mult(1.2); // El líder tiene una influencia fuerte
    fuerzaHuida.mult(5.0); // ¡Prioridad máxima para sobrevivir!
    
    // Aplicar las fuerzas al cuerpo
    applyForce(fuerzaDestino);
    applyForce(fuerzaSeparacion);
    applyForce(fuerzaCohesion);
    applyForce(fuerzaLider);
    applyForce(fuerzaHuida);
  }

  //1：Ir al destino
  PVector buscar(PVector target) {
    PVector desired = PVector.sub(target, pos); // Vector hacia el objetivo (Algebra: Destino - Posición actual)
    desired.normalize();
    desired.mult(maxSpeed);
    
    // Fuerza de giro = Velocidad Deseada - Velocidad Actual
    PVector steer = PVector.sub(desired, vel);
    steer.limit(maxForce);
    return steer;
  }
  
  // Álgebra para huir
  PVector huir(PVector target) {
    // Álgebra: Vector desde el target HACIA la posición actual
    PVector desired = PVector.sub(pos, target); 
    float d = desired.mag();
    
    // Solo huyen si el depredador está cerca (Radio de pánico = 150)
    if (d < 150) { 
      desired.normalize();
      desired.mult(maxSpeed);
      
      PVector steer = PVector.sub(desired, vel);
      steer.limit(maxForce * 2); // Pueden girar más rápido al huir
      return steer;
    }
    return new PVector(0, 0, 0); // Si está lejos, no sienten miedo
  }

  //2: Evitar choques con vecinos
  PVector separar(ArrayList<Boid> boids) {
    float distanciaDeseada = 35.0f; // Distancia mínima segura
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    
    for (Boid otro : boids) {
      float d = PVector.dist(pos, otro.pos);
      // Si está demasiado cerca y no es él mismo
      if ((d > 0) && (d < distanciaDeseada)) {
        PVector alejar = PVector.sub(pos, otro.pos);
        alejar.normalize();
        alejar.div(d);
        steer.add(alejar);
        count++;
      }
    }
    if (count > 0) {
      steer.div((float)count);
      steer.normalize();
      steer.mult(maxSpeed);
      steer.sub(vel);
      steer.limit(maxForce);
    }
    return steer;
  }

  //3: Mantenerse cerca del grupo
  PVector juntar(ArrayList<Boid> boids) {
    float distanciaVecino = 100.0f; // Rango de visión para buscar vecinos
    PVector suma = new PVector(0, 0, 0);
    int count = 0;
    
    for (Boid otro : boids) {
      float d = PVector.dist(pos, otro.pos);
      if ((d > 0) && (d < distanciaVecino)) {
        suma.add(otro.pos); // Sumar posiciones de los vecinos
        count++;
      }
    }
    if (count > 0) {
      suma.div(count); // Calcular el centro de masa
      return buscar(suma); // Ir hacia ese centro usando la función de buscar destino
    }
    return new PVector(0, 0, 0);
  }

  void update() {
    vel.add(acc);        
    vel.limit(maxSpeed); 
    pos.add(vel);        
    acc.mult(0);         
    
    checkEdges();        
  }

  void display() {
    pushMatrix(); 
    translate(pos.x, pos.y, pos.z); 
    
    noStroke();
    fill(200, 220, 255);
    box(15); 
    
    popMatrix(); 
  }
  
  void checkEdges() {
    if (pos.x > width) pos.x = 0;
    if (pos.x < 0) pos.x = width;
    if (pos.y > height) pos.y = 0;
    if (pos.y < 0) pos.y = height;
    if (pos.z > 300) pos.z = -300;
    if (pos.z < -300) pos.z = 300;
  }
}
