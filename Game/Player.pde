public class Player extends MovableCharacter {
  
  private String name;
    
  public Player(int tileX, int tileY, String name) {
    super(tileX, tileY, 2);
    
    this.name = name;
    
    loadSprites();
    
  }

  @Override
  public void draw(PGraphics canvas) {
    canvas.image(this.sprites[curSprite], middleTileX * tileSize, middleTileY * tileSize);
    
  }

  @Override
  public void update() {
    
    super.update();
          
    if (pixelY % tileSize ==  8 ) {
      curSprite++;
    } else if (pixelY % tileSize == 24) {      
       curSprite++;
    } else if (pixelX % tileSize == 8 ) {
      curSprite++;
    } else if (pixelX % tileSize == 24) {  
      curSprite++;
    }
    
    
  }
  


  @Override
  protected void loadSprites() {
    
    sprites = new PImage[12];
    sprites[0] = loadImage("sprites/pokemon/" + name + "/" + name + "_up0.png");
    sprites[1] = loadImage("sprites/pokemon/" + name + "/" + name + "_up1.png");
    sprites[2] = loadImage("sprites/pokemon/" + name + "/" + name + "_up2.png");
    
    sprites[3] = loadImage("sprites/pokemon/" + name + "/" + name + "_right0.png");
    sprites[4] = loadImage("sprites/pokemon/" + name + "/" + name + "_right1.png");
    sprites[5] = loadImage("sprites/pokemon/" + name + "/" + name + "_right2.png");
    
    sprites[6] = loadImage("sprites/pokemon/" + name + "/" + name + "_down0.png");
    sprites[7] = loadImage("sprites/pokemon/" + name + "/" + name + "_down1.png");
    sprites[8] = loadImage("sprites/pokemon/" + name + "/" + name + "_down2.png");
    
    sprites[9] = loadImage("sprites/pokemon/" + name + "/" + name + "_left0.png");
    sprites[10] = loadImage("sprites/pokemon/" + name + "/" + name + "_left1.png");
    sprites[11] = loadImage("sprites/pokemon/" + name + "/" + name + "_left2.png");
    
    
  }
  
}
