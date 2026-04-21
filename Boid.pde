class Boid {
  PVector pos;    // Posición
  PVector vel;     // Velocidad
  PVector acc;     // Aceleración
  float maxSpeed;  // Velocidad máxima
  float maxForce;   // Fuerza máxima de giro

  Boid(PVector startPos) {
    pos = startPos.copy();
    vel = PVector.random3D(); 
    vel.mult(random(1, 2));   
    acc = new PVector(0, 0, 0); 
    maxSpeed = 3.0;
    maxForce = 0.05;
  }
  
  void applyForce(PVector force) {
    acc.add(force);
  }
  
  // Núcleo de comportamiento grupal (Heurísticas)
  void aplicarComportamiento(ArrayList<Boid> boids, PVector destinoActual, PVector liderActual, PVector depredador, boolean hayDepredador, PVector[] obstaculosFijos) {
    
    PVector fuerzaDestino = buscar(destinoActual);
    PVector fuerzaSeparacion = separar(boids);
    PVector fuerzaCohesion = juntar(boids);
    PVector fuerzaLider = buscar(liderActual);
    
    PVector fuerzaHuida = new PVector(0, 0, 0);
    if (hayDepredador) {
      fuerzaHuida = huir(depredador);
    }
    
    PVector fuerzaObstaculos = esquivar(obstaculosFijos);
    
    // Pesos de las fuerzas (Prioridades)
    fuerzaDestino.mult(1.0);    
    fuerzaSeparacion.mult(1.5); 
    fuerzaCohesion.mult(1.0);   
    fuerzaLider.mult(1.2); 
    fuerzaHuida.mult(5.0); // Prioridad máxima para huir
    fuerzaObstaculos.mult(3.0); // Prioridad alta para evitar obstáculos
    
    applyForce(fuerzaDestino);
    applyForce(fuerzaSeparacion);
    applyForce(fuerzaCohesion);
    applyForce(fuerzaLider);
    applyForce(fuerzaHuida);
    applyForce(fuerzaObstaculos);
  }

  //Ir al destino
  PVector buscar(PVector target) {
    PVector desired = PVector.sub(target, pos); 
    desired.normalize();
    desired.mult(maxSpeed);
    
    PVector steer = PVector.sub(desired, vel);
    steer.limit(maxForce);
    return steer;
  }
  
  // Huir del depredador
  PVector huir(PVector target) {
    PVector desired = PVector.sub(pos, target); 
    float d = desired.mag();
    
    if (d < 150) { // Solo huyen si están cerca
      desired.normalize();
      desired.mult(maxSpeed);
      
      PVector steer = PVector.sub(desired, vel);
      steer.limit(maxForce * 2); // Giro más rápido al huir
      return steer;
    }
    return new PVector(0, 0, 0); 
  }

  // Evitar choques con los compañeros
  PVector separar(ArrayList<Boid> boids) {
    float distanciaDeseada = 35.0f; 
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    
    for (Boid otro : boids) {
      float d = PVector.dist(pos, otro.pos);
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

  // Mantenerse cerca del grupo
  PVector juntar(ArrayList<Boid> boids) {
    float distanciaVecino = 100.0f; 
    PVector suma = new PVector(0, 0, 0);
    int count = 0;
    
    for (Boid otro : boids) {
      float d = PVector.dist(pos, otro.pos);
      if ((d > 0) && (d < distanciaVecino)) {
        suma.add(otro.pos); 
        count++;
      }
    }
    if (count > 0) {
      suma.div(count); 
      return buscar(suma); 
    }
    return new PVector(0, 0, 0);
  }

  // Evitar obstáculos fijos
  PVector esquivar(PVector[] obstaculos) {
    float distanciaSegura = 60.0; 
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    
    for (PVector obs : obstaculos) {
      float d = PVector.dist(pos, obs);
      if (d > 0 && d < distanciaSegura) {
        PVector alejar = PVector.sub(pos, obs);
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
      steer.limit(maxForce * 1.5); 
    }
    return steer;
  }

  void update() {
    vel.add(acc);        
    vel.limit(maxSpeed); 
    pos.add(vel);        
    acc.mult(0);       // Resetear la aceleración a 0 en cada frame
    
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
  
  // Limitar los bordes del espacio
  void checkEdges() {
    if (pos.x > width) pos.x = 0;
    if (pos.x < 0) pos.x = width;
    if (pos.y > height) pos.y = 0;
    if (pos.y < 0) pos.y = height;
    if (pos.z > 300) pos.z = -300;
    if (pos.z < -300) pos.z = 300;
  }
}
