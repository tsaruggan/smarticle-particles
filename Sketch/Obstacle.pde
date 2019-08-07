class Obstacle {
  int x, y, w, h;
  int R, G, B;

  Obstacle(int x, int y,int w, int h) {
    this.x = x; //x pos
    this.y = y; //y pos
    this.w = w; //width
    this.h = h; //height
    this.R = ceil(random(100,255)); //color
    this.G = ceil(random(100,255));
    this.B = ceil(random(100,255));
  }
  
  void drawObstacle(){
    fill(R,G,B, 50);
    noStroke();
    rect(x, y, w, h);
  }
}
