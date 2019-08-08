//manipulate these variables
int lifespan = 200; //maximum lifespan of particles
int populationSize = 500; //number of particles in population
float mutation = 0.01; //decimal percent mutation of genes
float tenacity = 0.4; //magnitude of force applied to particle movement

//internal parameters
int generation = 0; //current generation
Population population;
PVector start, target; 
Obstacle[] obstacles; 

Obstacle o;
void setup() {
  size(600, 600);

  start= new PVector(width/2, height*0.75); //indicate spawning position of particles
  target = new PVector(width/2, height*0.1, 25); //indicate target position of particles
  obstacles = createObstacles(); //create the obstacles defined in the create obstacles method

  population = new Population(start, target, obstacles, lifespan, populationSize, tenacity, mutation); //create new population
}

void draw() {
  background(27);
  drawTarget();  //draw the target
  drawObstacles(); //draw obstacles

  if (population.alive()) { //if population is alive
    population.drawPopulation(); //draw particles on screen
    population.simulate(); //simulate movement, check obstacles and target
  } else {
    population.crossover(); //perform selection of parents and crossover genes to form child
    population.mutation();  //randomly choose genes to mutate, frequency based on mutation percentage
    generation++;           // add to generation counter
  }

  displayText(); //display stats on the screen
}


void drawTarget() { //draw target on the screen
  ellipseMode(CENTER);
  fill(255, 0, 0);
  ellipse(target.x, target.y, target.z, target.z);
}

Obstacle[] createObstacles() { //create the following array of defined obstacles
  Obstacle[] obstacles = {
    new Obstacle(floor(width*0.3), 200, floor(width*0.4), 20), 
  };
  return obstacles;
}

void drawObstacles() { //draw the array of obstacles
  for (int i = 0; i < obstacles.length; i++) {
    obstacles[i].drawObstacle();
  }
}

void displayText() {
  String text ="";
  text+="Population: "+ populationSize+"\n";
  text+="Generation: "+ generation+"\n";
  text+="Lifespan: "+ lifespan+"\n";
  text+="Mutation: " + mutation*100+"%\n";
  text+="Tenacity: "+ tenacity+"\n";

  fill(200);
  text(text, 10, 20);
}

void mousePressed(){
  init();
}

void init(){
   start= new PVector(width/2, height*0.75); //indicate spawning position of particles
  target = new PVector(width/2, height*0.1, 25); //indicate target position of particles
  obstacles = createObstacles(); //create the obstacles defined in the create obstacles method

  population = new Population(start, target, obstacles, lifespan, populationSize, tenacity, mutation); //create new population
}
