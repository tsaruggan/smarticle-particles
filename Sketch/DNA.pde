class DNA {
  public PVector[] genes;


  DNA(int lifespan, float maxForce) {
    genes = generateRandomGenes(lifespan, tenacity);
  }

  DNA(PVector[] genes) {
    this.genes = genes;
  }

  private PVector[] generateRandomGenes(int lifespan, float tenacity) {
    PVector[] newGenes = new PVector[lifespan];

    for (int index = 0; index < lifespan; index++) {
      newGenes[index] = PVector.random2D();
      newGenes[index].setMag(tenacity);
    }
    
    return newGenes;
  }
}
