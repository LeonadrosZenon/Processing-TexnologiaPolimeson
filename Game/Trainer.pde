

public class Trainer extends MovableCharacter {
  
  private int[] moves;
  private int curMove;
  private int leg;
  private String name;
  int milliseconds = 0;
  boolean timerStarted = false;
  int r = 0;
  
  public Trainer(int tileX, int tileY, int[] moves) {
    super(tileX, tileY, 1); 
    r = (int) random(25) + 1;
    if(r < 10){
      name = "trainer0" + r;
    }else{
      name = "trainer" + r;
    }
    
    loadSprites();
    
    this.moves = moves;
    curMove = 0;
    
    leg = 1;
  }
  
  @Override
  public void draw(PGraphics canvas) { 
    canvas.image(this.sprites[curSprite],mapPixelX + pixelX, mapPixelY + pixelY); 
  }
  
  @Override
  public void update() {
    super.update();
    
    if(!isMoving) {
      if(moves[curMove] == CHARACTER_UP) {
        moveUp();
        timerStarted = false;
        curMove++;
      } else if(moves[curMove] == CHARACTER_RIGHT) {
        moveRight();
        timerStarted = false;
        curMove++;
      } else if(moves[curMove] == CHARACTER_DOWN) {
        moveDown();
        timerStarted = false;
        curMove++;
      } else if(moves[curMove] == CHARACTER_LEFT) {
        moveLeft();
        timerStarted = false;
        curMove++;
      }else if(millis() > milliseconds + 2000 || !timerStarted){
        if(moves[curMove] == ROTATE_UP){
          rotateUp();
          milliseconds = millis();
          timerStarted = true;
          curMove++;
        } else if(moves[curMove] == ROTATE_DOWN){
          rotateDown();
          milliseconds = millis();
          timerStarted = true;
          curMove++;
        } else if(moves[curMove] == ROTATE_LEFT){
          rotateLeft();
          milliseconds = millis();
          timerStarted = true;
          curMove++;
        } else if(moves[curMove] == ROTATE_RIGHT){
          rotateRight();
          milliseconds = millis();
          timerStarted = true;
          curMove++;
        }        
      }
      
      if(curMove >= moves.length) {
        curMove = 0;
      }      
    }
    
    
    if(pixelX % tileSize == 0 && pixelY % tileSize == 0) {
      leg = (leg == 1) ? 2 : 1;
    } else if ((pixelX % tileSize <= tileSize/2 && pixelX % tileSize != 0)|| (pixelY % tileSize <= tileSize/2 && pixelY % tileSize != 0)) {
       curSprite = facing * 3 + leg; 
    } else {
      curSprite = facing * 3;
    }
    
  }
  
  @Override
  protected void loadSprites() {
    
    sprites = new PImage[12];
    sprites[0] = loadImage("sprites/trainers/" + name + "/images/" + name + "_up0.png");
    sprites[1] = loadImage("sprites/trainers/" + name + "/images/" + name + "_up1.png");
    sprites[2] = loadImage("sprites/trainers/" + name + "/images/" + name + "_up2.png");
    
    sprites[3] = loadImage("sprites/trainers/" + name + "/images/" + name + "_right0.png");
    sprites[4] = loadImage("sprites/trainers/" + name + "/images/" + name + "_right1.png");
    sprites[5] = loadImage("sprites/trainers/" + name + "/images/" + name + "_right2.png");
    
    sprites[6] = loadImage("sprites/trainers/" + name + "/images/" + name + "_down0.png");
    sprites[7] = loadImage("sprites/trainers/" + name + "/images/" + name + "_down1.png");
    sprites[8] = loadImage("sprites/trainers/" + name + "/images/" + name + "_down2.png");
    
    sprites[9] = loadImage("sprites/trainers/" + name + "/images/" + name + "_left0.png");
    sprites[10] = loadImage("sprites/trainers/" + name + "/images/" + name + "_left1.png");
    sprites[11] = loadImage("sprites/trainers/" + name + "/images/" + name + "_left2.png");
    
    
    
  }
  
  public boolean lineOfSight(int playerX, int playerY){
    if(facing == CHARACTER_UP) {
      for(int i = 0; i < 5; i++){
        if(tileX == playerX && tileY - i == playerY){
          return true;
        }
      }  
    } else if(facing == CHARACTER_RIGHT) {
      for(int i = 0; i < 5; i++){
        if(tileX + i == playerX && tileY == playerY){
          return true;
        }
      }
    } else if(facing == CHARACTER_DOWN) {
      for(int i = 0; i < 5; i++){
        if(tileX == playerX && tileY + i == playerY){
          return true;
        }
      }
    } else if(facing == CHARACTER_LEFT) {
      for(int i = 0; i < 5; i++){
        if(tileX - i == playerX && tileY == playerY){
          return true;
        }
      }
    }
    return false;
  }
}
