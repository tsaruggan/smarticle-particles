class DNA { //dn object containing the acceleration vectors
  public PVector[] genes;

  DNA(int lifespan, float tenacity) { //create a genes based on given tenacity
    genes = generateRandomGenes(lifespan, tenacity);
  }

  DNA(PVector[] genes) { //create a new genes object by simply passing a PVector[]
    this.genes = genes;
  }

  private PVector[] generateRandomGenes(int lifespan, float tenacity) { //randomize genes to max of given tenacity 
    PVector[] newGenes = new PVector[lifespan];

    for (int index = 0; index < lifespan; index++) {
      newGenes[index] = PVector.random2D();
      newGenes[index].setMag(tenacity);
    }
    
    return newGenes;
  }
}
