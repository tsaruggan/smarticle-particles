class Population {
  Particle[] population, tempPopulation;
  int populationSize, lifespan; 
  PVector start, target;
  float mutation, tenacity;
  Obstacle[] obstacles;

  Population(PVector start, PVector target, Obstacle[] obstacles, int lifespan, int populationSize, float tenacity, float mutation) {
    this.populationSize = populationSize;
    this.lifespan = lifespan;
    this.population = new Particle[populationSize];
    this.tempPopulation = new Particle[populationSize];
    this.start = start;
    this.target = target; 
    this.obstacles = obstacles;
    this.mutation = mutation;
    this.tenacity = tenacity;

    for (int index = 0; index < populationSize; index++) { //initialize particle arrays
      population[index] = new Particle(start, target, obstacles, lifespan, tenacity);
      tempPopulation[index] = new Particle(start, target, obstacles, lifespan, tenacity);
    }
  }

  public void drawPopulation() { //draw particles
    for (int index = 0; index < populationSize; index++) {
      population[index].drawParticle();
    }
  }

  public void simulate() { //simulate movement and checking for each particle
    for (int index = 0; index < populationSize; index++) {
      population[index].simulate();
    }
  }

  private Particle selection(Particle[] population) { //select a parent based on probabilty weighted on fitness
    int index = 0;
    int sum = getFitnessSum(population); //calculate sum of fitnesses
    int r = floor(random(sum)); //choose a random number from the sum

    while (r > 0) {
      r = r -  population[index].fitness;
      index++;
    }
    if (index!=0) {
      index--;
    }
    return population[index];
  }

  private int getFitnessSum(Particle[] population) { //add up all the fitness scored
    int sum = 0;
    for (int s = 0; s < population.length; s++) {
      sum+=population[s].fitness;
    }
    return sum;
  }

  public void crossover() {
    for (int index = 0; index < population.length; index++) {
      Particle parent1 = selection(population); //choose 2 parents
      Particle parent2 = selection(population);

      PVector[] genes = new PVector[lifespan]; //create a temporary array of PVectors
      int mid = (int) floor(random(genes.length));  //randomize a midpoint

      for (int i = 0; i < genes.length; i++) { //for genes above the midppint pass parent 1 genes
        if (i >= mid) {
          genes[i] = parent1.dna.genes[i];
        } else { //for genes below the midpoint pass parent 2 genes
          genes[i] = parent2.dna.genes[i];
        }
      }
      Particle child = new Particle(start, target, obstacles, genes, lifespan); //create new child using genes 
      tempPopulation[index] = child; //pass the child to temporary population
    }

    population = tempPopulation; //copy temporary population to actual population
  }

  public void mutation() {
    for (int index =0; index < population.length; index++) {
      for (int current =0; current < population[index].dna.genes.length; current++) {
        if (random(1) < mutation) { //if random number below mutation percent then randomize that gene
          PVector newGene = PVector.random2D(); //random 2d vector
          newGene.setMag(tenacity); //set magnitude of vector
          population[index].dna.genes[current] = newGene.copy(); //copy gene to spot in existing gene
        }
      }
    }
  }

  public boolean alive() { //check if population is alive
    for (int index = 0; index < populationSize; index++) {
      if (population[index].alive) {
        return true;
      }
    }
    return false;
  }
}
