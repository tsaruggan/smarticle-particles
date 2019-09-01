import controlP5.*;

//manipulate these variables
public int lifespan = 200; //maximum lifespan of particles
public int populationSize = 500; //number of particles in population
public float mutation = 0.01; //decimal percent mutation of genes
public float tenacity = 0.4; //magnitude of force applied to particle movement

//internal parameters
int generation = 1; //current generation
Population population;
PVector start, target; 

ArrayList <Obstacle> obstacles = new ArrayList(); //for containing created obstacles
int[] new_obstacle = new int[4]; //holding x1, y1, x2, y2 of a new obstacles

//control p5 elements
ControlP5 cp5;
Numberbox[] variables = new Numberbox[4];
Button button, clear;
Textlabel lbl_gen;
boolean edit =false; //check if user is editing parameters

void setup() {
  size(960, 540);

  createControlP5elements();

  start= new PVector(width/2, height*0.75); //indicate spawning position of particles
  target = new PVector(width/2, height*0.1, 25); //indicate target position of particles

  population = new Population(start, target, lifespan, populationSize, tenacity, mutation); //create new population
}

void draw() {
  background(27);
  drawTarget();  //draw the target
  drawObstacles(); //draw obstacles

  if (!edit) { //if user is not editing 
    if (population.alive()) { //if population is alive
      population.drawPopulation(); //draw particles on screen
      population.simulate(); //simulate movement, check obstacles and target
      displayText(); //display gen count on the screen
    } else {
      population.crossover(); //perform selection of parents and crossover genes to form child
      population.mutation();  //randomly choose genes to mutate, frequency based on mutation percentage
      generation++;           // add to generation counter
    }
  }
}

void mousePressed() {
  if (mouseButton == RIGHT) { //if right mousepressed then initialize x1 and y1 of rectangle
    new_obstacle[0] = mouseX;
    new_obstacle[1] = mouseY;
  }
}

void mouseDragged() {
  if (mouseButton == RIGHT) { //if right dragged then draw temporary rectangle for new obstacle with live mouse x and y
    stroke(5);
    fill(255, 25);
    rect(new_obstacle[0], new_obstacle[1], mouseX-new_obstacle[0], mouseY-new_obstacle[1]);
  }
}

void mouseReleased() {
  if (mouseButton == RIGHT) { //if right mouse released create shape with x2 and y2 of mouse and push obstacle to arraylist
    new_obstacle[2] = mouseX;
    new_obstacle[3] = mouseY;
    Obstacle obstacle = new Obstacle(new_obstacle[0], new_obstacle[1], new_obstacle[2], new_obstacle[3]);
    this.obstacles.add(obstacle);
    population.setObstacles(this.obstacles);
  }
}


void drawTarget() { //draw target on the screen
  ellipseMode(CENTER);
  fill(255, 0, 0);
  stroke(1);
  ellipse(target.x, target.y, target.z, target.z);
}


void drawObstacles() { //draw the array of obstacles
  for (int i = 0; i < obstacles.size(); i++) {
    obstacles.get(i).drawObstacle();
  }
}

void displayText() { //displays the generation counter
  lbl_gen.setText("GENERATION: "+ generation);
}


void init() {
  start= new PVector(width/2, height*0.75); //indicate spawning position of particles
  target = new PVector(width/2, height*0.1, 25); //indicate target position of particles
  //obstacles = createObstacles(); //create the obstacles defined in the create obstacles method

  population = new Population(start, target, lifespan, populationSize, tenacity, mutation); //create new population
  population.setObstacles(obstacles);
  generation = 1;
}

void button() { //if the edit button is pushed
  if (edit) { //if currently editing
    button.setLabel("EDIT").setColorBackground(color(100));

    for (int i =0; i < variables.length; i++) {//lock the sliders and change coolor to gray
      variables[i].lock();
      variables[i].setColorBackground(color(100));
      init(); //reset components
    }
  } else { //if currently in play
    button.setLabel("PLAY").setColorBackground(color(150, 0, 0)); 
    for (int i =0; i < variables.length; i++) { //unlcok the sliders and change color to red
      variables[i].unlock();
      variables[i].setColorBackground(color(150, 0, 0));
    }
  }
  edit = !edit; //switch boolean
}

void clear() { //clear the obstacles
  obstacles.clear();
  population.setObstacles(obstacles);
}

void createControlP5elements() { //creates the control p5 element sliders, buttons and labels
  cp5 = new ControlP5(this);

  button = cp5.addButton("button")
    .setPosition(10, 120)
    .setSize(45, 12)
    .setLabel("EDIT")
    .setColorBackground(color(100))
    ;

  clear = cp5.addButton("clear")
    .setPosition(65, 120)
    .setSize(45, 12)
    .setLabel("CLEAR")
    .setColorBackground(color(50))
    ;

  variables[0] = cp5.addNumberbox("lifespan")
    .setPosition(10, 20)
    .setSize(100, 6)
    .setRange(10, 1000)
    .setMultiplier(1) // set the sensitifity of the numberbox
    .setDirection(Controller.HORIZONTAL) // change the control direction to left/right
    .setValue(lifespan)
    .setColorBackground(color(100))
    .lock()
    ;

  variables[1] = cp5.addNumberbox("populationSize")
    .setPosition(10, 45)
    .setSize(100, 6)
    .setRange(2, 1000)
    .setMultiplier(1) // set the sensitifity of the numberbox
    .setDirection(Controller.HORIZONTAL) // change the control direction to left/right
    .setValue(populationSize)
    .setCaptionLabel("Population Size")
    .setColorBackground(color(100))
    .lock()
    ;

  variables[2] = cp5.addNumberbox("mutation")
    .setPosition(10, 70)
    .setSize(100, 6)
    .setRange(0, 1)
    .setMultiplier(0.001) // set the sensitifity of the numberbox
    .setDirection(Controller.HORIZONTAL) // change the control direction to left/right
    .setValue(mutation)
    .setDecimalPrecision(3)
    .setColorBackground(color(100))
    .lock()
    ;

  variables[3] = cp5.addNumberbox("tenacity")
    .setPosition(10, 95)
    .setSize(100, 6)
    .setRange(0, 3)
    .setMultiplier(0.1) // set the sensitifity of the numberbox
    .setDirection(Controller.HORIZONTAL) // change the control direction to left/right
    .setValue(tenacity)
    .setColorBackground(color(100))
    .lock()
    ;

  lbl_gen = cp5.addTextlabel("generation")
    .setPosition(10, 5)
    ;
}
