class Obstacle {
  int x, y, w, h;
  int R, G, B;

  Obstacle(int x1, int y1, int x2, int y2) {
    //width and height is equal to absolute value of difference in x (width) and y (height)
    this.w = abs(x2-x1);
    this.h = abs(y2-y1);
    
    int fx = max(x1, x2); //furthest x
    int fy = max(y1, y2); //furthest y
    this.x = fx - w; //top left x
    this.y = fy - h; //top left y

    this.R = ceil(random(100, 255)); //color
    this.G = ceil(random(100, 255));
    this.B = ceil(random(100, 255));
  }

  void drawObstacle() { //draw the obstacles
    fill(R, G, B, 50);
    noStroke();
    rect(x, y, w, h);
  }
}
