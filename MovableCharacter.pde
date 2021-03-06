public class MovableCharacter {
  
  protected int tileX;
  protected int tileY;

  protected int pixelX;
  protected int pixelY;

  protected int vel;

  protected boolean isMoving;

  protected int facing;
  protected int moving;
  
  protected PImage[] sprites;
  protected int curSprite;
  
  public MovableCharacter(int tileX, int tileY, int vel) {
    this.tileX = tileX;
    this.tileY = tileY;

    this.pixelX = tileX * tileSize;
    this.pixelY = tileY * tileSize;

    this.vel = vel;

    this.facing = CHARACTER_DOWN;
    this.moving = CHARACTER_DOWN;
    this.isMoving = false;
    
    curSprite = facing * 3;
    
  }
  
  public boolean canWalkOnTile(int x, int y) {
    return (mapMovement.getInt(y, x) == 0 )? false : true ;
  }
  
  public void stopMoving() {
    isMoving = false;
  }
  
  public void teleport(int tileX, int tileY) {
    setTileX(tileX);
    setTileY(tileY);
    stopMoving(); 
    facing = CHARACTER_DOWN;
    curSprite = facing * 3;
  }

  public void moveUp() {
    if(!isMoving && canWalkOnTile(tileX, tileY - 1)) {
      facing = CHARACTER_UP;
      moving = CHARACTER_UP;
      curSprite = facing * 3;
      isMoving = true;
    }
  }
  
  public void moveDown() {
    if(!isMoving && canWalkOnTile(tileX, tileY + 1)) {
      facing = CHARACTER_DOWN;
      moving = CHARACTER_DOWN;
      curSprite = facing * 3;
      isMoving = true;
    }
  }

  public void moveLeft() {
    if(!isMoving && canWalkOnTile(tileX - 1, tileY)) {
      facing = CHARACTER_LEFT;
      moving = CHARACTER_LEFT;
      curSprite = facing * 3;
      isMoving = true;
    }
  }

  public void moveRight() {
    if(!isMoving && canWalkOnTile(tileX + 1, tileY)) {
      facing = CHARACTER_RIGHT;
      moving = CHARACTER_RIGHT;
      curSprite = facing * 3;
      isMoving = true;
    }
  }
  
  public void rotateUp(){
    if(!isMoving){
      moving = -1;
      facing = CHARACTER_UP;
      curSprite = facing * 3;
      isMoving = false;
    }
  }
  public void rotateDown(){
    if(!isMoving){
      moving = -1;
      facing = CHARACTER_DOWN;
      curSprite = facing * 3;
      isMoving = false;
    }
  }
  public void rotateLeft(){
    if(!isMoving){
      moving = -1;
      facing = CHARACTER_LEFT;
      curSprite = facing * 3;
      isMoving = false;
    }
  }
  public void rotateRight(){
    if(!isMoving){
      moving = -1;
      facing = CHARACTER_RIGHT;
      curSprite = facing * 3;
      isMoving = false;
    }
  }
  
  public void draw(PGraphics canvas){}
  
  public void update(){
    
    if(isMoving) {
      if(moving == CHARACTER_UP) {
        pixelY -= vel;
        if(pixelY % tileSize == 0) {
          tileY = pixelY / tileSize;
          stopMoving();
          curSprite = facing * 3;
         }
      } else if(moving == CHARACTER_RIGHT) {
        pixelX += vel;
        if(pixelX % tileSize == 0) {
          tileX = pixelX / tileSize;
          stopMoving();
          curSprite = facing * 3;
         }
      } else if(moving == CHARACTER_DOWN) {
        pixelY += vel;
        if(pixelY % tileSize == 0) {
          tileY = pixelY / tileSize;
          stopMoving();
          curSprite = facing * 3;
        }
      } else if(moving == CHARACTER_LEFT) {
        pixelX -= vel;
        if(pixelX % tileSize == 0) {
          tileX = pixelX / tileSize;
          stopMoving();
          curSprite = facing * 3;
        }
      }
    }
    
  }
  
  protected void loadSprites(){}
  
  public int getTileX() {
    return this.tileX;
  }
  
  public int getTileY() {
    return this.tileY;    
  }

  public int getPixelX() {
    return this.pixelX;
  }

  public int getPixelY() {
    return this.pixelY;
  }
   
  public void setTileX(int tileX) {
    this.tileX = tileX;
    pixelX = tileX * 32;
  }

  public void setTileY(int tileY){
    this.tileY = tileY;
    pixelY = tileY * 32;
  }
  
  public void setPixelX(int pixelX) {
    this.pixelX = pixelX;
  }
  
  public void setPixelY(int pixelY) {
    this.pixelY = pixelY;
  }
}
