let canvas;
let max_width = 650;

let lifespan = 200;
let populationSize = 500;
let mutation = 0.01;
let tenacity = 0.4;

let generation;
let population;
let start;
let target;

let obstacles = new Array(0);
let temp_new_obstacle = new Array(4);

let lifespanSlider;
let populationSizeSlider;
let mutationSlider;
let tenacitySlider; 
let resetButton;
let clearObstaclesButton;

function setup() {
    let width = min(max_width, windowWidth);
    canvas = createCanvas(width, width);
    canvas.parent(document.getElementById('sketch_canvas'));
    createDOMElements();

    init();
}

function windowResized() {
    let width = min(max_width, windowWidth);
    canvas = resizeCanvas(width, width);
}

function draw() {
    background(27);

    drawTarget();  //draw the target
    drawObstacles(); //draw obstacles
    displayText();

    if (population.alive()) { //if population is alive
        population.drawPopulation(); //draw particles on screen
        population.simulate(); //simulate movement, check obstacles and target
    } else {
        population.crossover(); //perform selection of parents and crossover genes to form child
        population.mutation();  //randomly choose genes to mutate, frequency based on mutation percentage
        generation++;           // add to generation counter
    }

    if (mouseIsPressed && mouseButton == LEFT && temp_new_obstacle[0] != null) {
        drawTemporaryObstacle(); //if right dragged then draw temporary rectangle for new obstacle with live mouse x and y
    }

    listenDOMChanges();
}

function init() {
    generation = 0;
    start = createVector(width / 2, height * 0.75); //indicate spawning position of particles
    target = createVector(width / 2, height * 0.1, 40); //indicate target position of particles
    population = new Population(start, target, populationSize, lifespan, tenacity, mutation); //create new population
    population.setObstacles(obstacles);
}

function mousePressed(event) {
    if (mouseButton == LEFT && event.target.localName == "canvas") { //if right mousepressed then initialize x1 and y1 of rectangle
        temp_new_obstacle[0] = mouseX;
        temp_new_obstacle[1] = mouseY;
    } else if (mouseButton == LEFT && event.target.localName != "canvas"){
        temp_new_obstacle[0] = null;
        temp_new_obstacle[1] = null;
    }
}


function mouseReleased(event) {
    if (mouseButton == LEFT && event.target.localName == "canvas" && temp_new_obstacle[0] != null) { //if right mouse released create shape with x2 and y2 of mouse and push obstacle to array
        temp_new_obstacle[2] = mouseX;
        temp_new_obstacle[3] = mouseY;
        let obstacle = new Obstacle(temp_new_obstacle[0], temp_new_obstacle[1], temp_new_obstacle[2], temp_new_obstacle[3]);
        obstacles.push(obstacle);
        population.setObstacles(obstacles);
    }
}

function drawTemporaryObstacle() {
    stroke(5);
    fill(255, 60);
    rect(temp_new_obstacle[0], temp_new_obstacle[1], mouseX - temp_new_obstacle[0], mouseY - temp_new_obstacle[1]);
}


function drawTarget() { //draw target on the screen
    ellipseMode(CENTER);
    fill(255, 0, 0);
    stroke(1);
    ellipse(target.x, target.y, target.z, target.z);
}


function drawObstacles() { //draw the array of obstacles
    for (let i = 0; i < obstacles.length; i++) {
        obstacles[i].drawObstacle();
    }
}

function createDOMElements() {
    let buttons = document.getElementById('sketch_canvas');
    let sliders = document.getElementById('sketch_canvas');

    resetButton = createButton('Reset');
    resetButton.id('sim_button');
    resetButton.parent(buttons);

    clearObstaclesButton = createButton('Clear Obstacles');
    clearObstaclesButton.id('sim_button');
    clearObstaclesButton.parent(buttons);

    let lifespanP = createP("Lifespan:");
    lifespanP.id("slider_label");
    lifespanSlider = createSlider(10, 500, lifespan, 1);
    lifespanP.parent(sliders);
    lifespanSlider.parent(sliders);

    let populationSizeP = createP("Population Size:");
    populationSizeP.id("slider_label");
    populationSizeSlider = createSlider(50, 1000, populationSize, 1); 
    populationSizeP.parent(sliders);
    populationSizeSlider.parent(sliders);

    let mutationP = createP("Mutation:");
    mutationP.id("slider_label");
    let mut_val = log(mutation / 0.01) / (1/20) + 20;
    mutationSlider = createSlider(1, 100, mut_val, 0.1);
    mutationP.parent(sliders);
    mutationSlider.parent(sliders);

    let tenacityP = createP("Tenacity:");
    tenacityP.id("slider_label");
    tenacitySlider = createSlider(1, 10, tenacity * 10, 0.1);
    tenacityP.parent(sliders);
    tenacitySlider.parent(sliders);
}

function listenDOMChanges() {
    lifespanSlider.changed(() => updateParameter("lifespan"));
    populationSizeSlider.changed(() => updateParameter("populationSize"));
    mutationSlider.changed(() => updateParameter("mutation"));
    tenacitySlider.changed(() => updateParameter("tenacity"));
    resetButton.mousePressed(() => updateParameter("reset"));
    clearObstaclesButton.mousePressed(() => updateParameter("clear"));
}

function updateParameter(param){
    if (param == "lifespan"){
        lifespan = lifespanSlider.value();
    } else if (param == "populationSize") {
        populationSize = populationSizeSlider.value();
    } else if (param == "mutation") {
        let mut_val = constrain(0.01 * exp(1 / 20 * (mutationSlider.value() - 20)), 0.004, 0.5);
        mutation = mut_val;
    } else if (param == "tenacity") {
        tenacity = tenacitySlider.value() / 10;
    } else if (param == "clear") {
        obstacles = [];
        population.setObstacles(obstacles);
        return;
    } 
    init();
}

function displayText() {
    fill(255);
    text('Generation: ' + generation , 15, 25);
    text('Lifespan: ' + lifespan , 15, 40);
    text('Population Size: ' + populationSize , 15, 55);
    text('Mutation: ' + nf(round(100 * mutation, 2), 0, 2)+ '%' , 15, 70);
    text('Tenacity: ' + nf(tenacity * 10, 0 , 1), 15, 85);
}

class DNA {
    constructor(genes, lifespan, tenacity) {
        this.genes = genes;
        if (!this.genes) {
            this.genes = this.generateRandomGenes(lifespan, tenacity);
        }
    }

    generateRandomGenes(lifespan, tenacity) {
        let newGenes = new Array(lifespan);
        for (let i = 0; i < lifespan; i++) {
            let gene = p5.Vector.random2D();
            gene.setMag(tenacity);
            newGenes.push(gene);
        }
        return newGenes;
    }
}

class Particle {
    constructor(start, target, genes, lifespan, tenacity, obstacles) {
        this.pos = start.copy();
        this.target = target.copy();
        this.obstacles = obstacles;
        this.DNA = new DNA(genes, lifespan, tenacity);
        this.vel = createVector(0, 0);
        this.acc = createVector(0, 0);
        this.age = 0;
        this.lifespan = lifespan;
        this.alive = true;
        this.success = false;
        this.radius = 3;
    }

    drawParticle() {
        if (this.alive) { //if alive fill white
            fill(255, 60);
        } else if (this.success) { //if fill green 
            fill(0, 200, 0);
        } else { //if failed fill red
            fill(200, 0, 0);
        }
        noStroke();
        ellipseMode(CENTER);
        ellipse(this.pos.x, this.pos.y, this.radius * 2, this.radius * 2); //draw particle as circle
    }

    simulate() {
        if (this.age >= this.lifespan) {
            this.die();
        }
        if (this.alive) {
            this.move();
            this.checkEdges();
            this.checkTarget();
            this.checkObstacles();
            this.age = this.age + 1;
        }
    }

    move() {
        if (this.age < this, lifespan && this.alive) {
            this.acc.add(this.DNA.genes[this.age]); //make acceleration inherit to gene
            this.vel.add(this.acc); //increased velocity by acceleration
            this.pos.add(this.vel); //increased position by velocity
            this.acc.mult(0); //restore acceleration back to zero
        }
    }

    checkEdges() {
        if (this.pos.x > width - this.radius || this.pos.x < 0 + this.radius || this.pos.y > height - this.radius || this.pos.y < 0 + this.radius) {
            this.die();
        }
    }

    checkTarget() {
        if (dist(this.pos.x, this.pos.y, this.target.x, this.target.y) <= this.target.z / 2) {
            this.success = true;
            this.die();
        }
    }

    setObstacles(obstacles) {
        this.obstacles = obstacles;
    }

    checkObstacles() {
        if (this.obstacles != null) {
            for (let i = 0; i < this.obstacles.length; i++) {
                let w = this.obstacles[i].w;
                let h = this.obstacles[i].h;
                let x = this.obstacles[i].x;
                let y = this.obstacles[i].y;
                let t1 = this.pos.x >= (x + this.radius);
                let t2 = this.pos.x <= ((x + w) - this.radius);
                let t3 = this.pos.y >= (y - this.radius);
                let t4 = this.pos.y <= ((y + h) + this.radius);
                if (t1 && t2 && t3 && t4) {
                    this.die();
                }
            }
        }
    }

    die() {
        this.alive = false;
        this.fitness = this.evaluateFitness();
    }

    evaluateFitness() {
        let d = 1 / dist(this.pos.x, this.pos.y, this.target.x, this.target.y); //equal to 1 over distance to target
        let max = 1 / dist(0, 0, width, height); //maximum diagonal of bounds of screen 
        let g = map(d, 0, max, 0, 1); //map 1/distance from 0 to 1 based on max bounds of screen 

        let h;
        if (this.success) {
            h = this.lifespan / this.age; //score based on how fast reached the target
            return ceil(pow(10, g) * pow(10, h));
        } else {
            h = 1;
            return ceil(pow(10, g));
        }
    }
}

class Population {
    constructor(start, target, populationSize, lifespan, tenacity, mutation) {
        this.populationSize = populationSize;
        this.population = new Array(populationSize);
        this.tempPopulation = new Array(populationSize);
        this.start = start;
        this.target = target;
        this.lifespan = lifespan;
        this._mutation = mutation;
        this.tenacity = tenacity;
        for (let index = 0; index < populationSize; index++) { //initialize particle arrays
            this.population[index] = new Particle(start, target, lifespan, tenacity, obstacles);
            this.tempPopulation[index] = new Particle(start, target, lifespan, tenacity, obstacles);
        }
    }

    drawPopulation() { //draw particles
        for (let index = 0; index < this.populationSize; index++) {
            this.population[index].drawParticle();
        }
    }

    simulate() { //simulate movement and checking for each particle
        for (let index = 0; index < this.populationSize; index++) {
            this.population[index].simulate();
        }
    }

    selection(population) { //select a parent based on probabilty weighted on fitness
        let index = 0;
        let sum = this.getFitnessSum(population); //calculate sum of fitnesses
        let r = floor(random(sum)); //choose a random number from the sum

        while (r > 0) {
            r = r - population[index].fitness;
            index++;
        }
        if (index != 0) {
            index--;
        }
        return population[index];
    }

    getFitnessSum(population) { //add up all the fitness scored
        let sum = 0;
        for (let s = 0; s < population.length; s++) {
            sum += population[s].fitness;
        }
        return sum;
    }

    crossover() {
        for (let index = 0; index < this.population.length; index++) {
            let parent1 = this.selection(this.population); //choose 2 parents
            let parent2 = this.selection(this.population);

            let genes = new Array(this.lifespan); //create a temporary array of Vectors
            let mid = floor(random(genes.length));  //randomize a midpoint

            for (let i = 0; i < genes.length; i++) { //for genes above the midppint pass parent 1 genes
                if (i >= mid) {
                    genes[i] = parent1.DNA.genes[i];
                } else { //for genes below the midpoint pass parent 2 genes
                    genes[i] = parent2.DNA.genes[i];
                }
            }
            let child = new Particle(start, target, genes, lifespan, null, null); //create new child using genes 
            this.tempPopulation[index] = child; //pass the child to temporary population
        }
        this.population = this.tempPopulation; //copy temporary population to actual population
        this.setObstacles(this.obstacles);
    }

    mutation() {
        for (let index = 0; index < this.population.length; index++) {
            for (let current = 0; current < this.population[index].DNA.genes.length; current++) {
                if (random(1) < this._mutation) { //if random number below mutation percent then randomize that gene
                    let newGene = p5.Vector.random2D(); //random 2d vector
                    newGene.setMag(this.tenacity); //set magnitude of vector
                    this.population[index].DNA.genes[current] = newGene.copy(); //copy gene to spot in existing gene
                }
            }
        }
    }

    alive() { //check if population is alive
        for (let index = 0; index < this.populationSize; index++) {
            if (this.population[index].alive) {
                return true;
            }
        }
        return false;
    }

    setObstacles(obstacles) { //set the obstacles array to each particles
        for (let index = 0; index < this.populationSize; index++) {
            this.obstacles = obstacles;
            this.population[index].setObstacles(obstacles);
        }
    }
}

class Obstacle {
    constructor(x1, y1, x2, y2) {
        //width and height is equal to absolute value of difference in x (width) and y (height)
        this.w = abs(x2 - x1);
        this.h = abs(y2 - y1);

        let fx = max(x1, x2); //furthest x
        let fy = max(y1, y2); //furthest y
        this.x = fx - this.w; //top left x
        this.y = fy - this.h; //top left y

        this.R = ceil(random(100, 255)); //color
        this.G = ceil(random(100, 255));
        this.B = ceil(random(100, 255));
    }

    drawObstacle() { //draw the obstacles
        fill(this.R, this.G, this.B);
        noStroke();
        rect(this.x, this.y, this.w, this.h);
    }
}

