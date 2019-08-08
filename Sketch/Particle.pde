class Particle {
  public DNA dna; //containing genes
  PVector pos = new PVector(0,0,0), vel= new PVector(0,0,0), acc= new PVector(0,0,0), target= new PVector(0,0,0), screen= new PVector(0,0,0); 
  int age, lifespan, fitness;
  boolean alive, success;
  Obstacle[] obstacles;

  //animations
  float radius = 2.5;

  public Particle(PVector start, PVector target, Obstacle[] obstacles, int lifespan, float tenacity) {
    this.dna = new DNA(lifespan, tenacity);

    this.pos = start.copy(); //current cartesian position 2D
    this.target = target.copy(); //position of target on screen 2D
    this.obstacles = obstacles;

    this.vel = new PVector(0, 0); //current velocity  2D
    this.acc = new PVector(0, 0); //current acceleration 2D 

    this.age = 0; //initial age
    this.lifespan = lifespan; //maximum age 

    this.alive = true; //particle is alive
    this.success = false; //particle has not reached target
  }

  public Particle(PVector start, PVector target, Obstacle[] obstacles, PVector[] genes, int lifespan) {
    this.dna = new DNA(genes);

    this.pos = start.copy(); //current cartesian position 2D
    this.target = target.copy(); //position of target on screen 2D
    this.obstacles = obstacles;

    this.vel = new PVector(0, 0); //current velocity  2D
    this.acc = new PVector(0, 0); //current acceleration 2D 

    this.age = 0; //initial age
    this.lifespan = lifespan; //maximum age 

    this.alive = true; //particle is alive
    this.success = false; //particle has not reached target
  }

  public void drawParticle() {
    if (alive) { //if alive fill white
      fill(255, 50);
    } else if (success) { //if fill green 
      fill(0, 200, 0);
    } else { //if failed fill red
      fill(200, 0, 0);
    }
    noStroke();
    ellipseMode(CENTER);
    ellipse(pos.x, pos.y, radius*2, radius*2); //draw particle as circle
  }

  public void simulate() {
    if (age >= lifespan) { //ensure has not reached maximum age
      die();
    }

    if (alive) {
      move();
      checkEdges();
      checkTarget();
      checkObstacles();
      age++; //increase age
    }
  }

  public void move() {
    if (age< lifespan && alive) {
      acc.add(dna.genes[age]); //make acceleration inherit to gene
      vel.add(acc); //increased velocity by acceleration
      pos.add(vel); //increased position by velocity
      acc.mult(0); //restore acceleration back to zero
    }
  }

  public void checkEdges() { //check if particle has hit the bounds of screen
    if (pos.x > width-radius || pos.x < 0+radius || pos.y > height-radius || pos.y < 0+radius) { 
      die();
    }
  }

  public void checkTarget() { //check if particle has successfully hit the target
    if (dist(pos.x, pos.y, target.x, target.y)<=target.z/2) {
      success = true; 
      die();
    }
  }

  public void checkObstacles() { //check if particle has hit obstacle
    for (int i = 0; i < obstacles.length; i++) {
      int w = obstacles[i].w;
      int h = obstacles[i].h;
      int x = obstacles[i].x;
      int y = obstacles[i].y;
      boolean t1 = pos.x > x + radius;
      boolean t2 = pos.x < (x+w) - radius;
      boolean t3 = pos.y > y - radius;
      boolean t4 = pos.y < (y+h) + radius;
      if (t1 && t2 && t3 && t4) {         
        die();
      }
    }
  }

  public void die() {
    alive = false; //particle is no longer alive 
    fitness = evaluateFitness(); //eveluate the fitness of current position of particle
  }

  public int evaluateFitness() { //fitness function based on how close and fast particle has reached target
    float d= 1/dist(pos.x, pos.y, target.x, target.y); //equal to 1 over distance to target
    float max = 1/dist(0, 0, width, height); //maximum diagonal of bounds of screen 
    float g = map(d, 0, max, 0, 1); //map 1/distance from 0 to 1 based on max bounds of screen 

    float  h;
    if (success) {
      h = lifespan/age; //score based on how fast reached the target
      return ceil(pow(10, g) * pow(10, h));
    } else {
      h = 1;
      return ceil(pow(10, g));
    }
  }
}
