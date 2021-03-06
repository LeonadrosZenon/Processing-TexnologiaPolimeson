public class Light {
  
  private ArrayList<Trainer> trainers;
  
  private PGraphics dark;
  private PGraphics mask;
  
  private int size;
  
  public Light(int size, ArrayList<Trainer> trainers) {
    this.trainers = trainers;
    this.size = size;
    
    dark = createGraphics(tileSize*canvasTileWidth, tileSize*canvasTileHeight);
    dark.beginDraw();
    dark.background(0);
    dark.endDraw();
    
    mask = createGraphics(tileSize*canvasTileWidth, tileSize*canvasTileHeight);
    mask.beginDraw();
    mask.background(255);
    mask.noStroke();
    mask.fill(0);
    mask.ellipse(middleTileX * tileSize + tileSize/2, middleTileY * tileSize + tileSize/2, size*tileSize, size*tileSize);
    mask.endDraw();
  }
  
  public void update() {
    mask = createGraphics(tileSize*canvasTileWidth, tileSize*canvasTileHeight);
    mask.beginDraw();
    mask.background(255);
    mask.noStroke();
    mask.fill(0);
    mask.ellipse(middleTileX * tileSize + tileSize/2, middleTileY * tileSize + tileSize/2, size*tileSize, size*tileSize);
    mask.endDraw();
    
    for(MovableCharacter trainer : trainers) {
      mask.beginDraw();
      mask.noStroke();
      mask.fill(0);
      mask.ellipse(mapPixelX + trainer.getPixelX() + tileSize/2, mapPixelY + trainer.getPixelY() + tileSize/2, size*tileSize, size*tileSize);
      mask.endDraw(); 
    }  
    dark.mask(mask);  
  }
  
  public void draw(PGraphics canvas) {
    canvas.image(dark, 0, 0);
  } 
}
