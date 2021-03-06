import processing.sound.*;

private PImage map;
private PImage mapOver;
private PImage exclamation;
private PGraphics canvas;

private PImage logo;
private PImage logoBig;
private PImage bulbasaur;
private PImage charmander;
private PImage squirtle;

private SoundFile caughtSound;
private SoundFile mainTheme;
private SoundFile bump;

public static int CHARACTER_UP = 0;
public static int CHARACTER_RIGHT = 1;
public static int CHARACTER_DOWN = 2;
public static int CHARACTER_LEFT = 3;
public static int ROTATE_UP = 4;
public static int ROTATE_RIGHT = 5;
public static int ROTATE_DOWN = 6;
public static int ROTATE_LEFT = 7;

private boolean upPressed = false;
private boolean rightPressed = false;
private boolean downPressed = false;
private boolean leftPressed = false;

public static int tileSize = 32;
public static int canvasTileWidth = 17;
public static int canvasTileHeight = 13;

private float AR = (float) canvasTileWidth / canvasTileHeight;

public static int middleTileX = canvasTileWidth/2;
public static int middleTileY = canvasTileHeight/2;

public static Table mapMovement;

public int mapPixelX;
public int mapPixelY;

private Player pokemon;

private ArrayList<Trainer> trainers = new ArrayList<Trainer>();

private Light light;

private boolean caught = false;
private boolean restart = false;
private boolean bumped = false;

private int gameState = 0;

private int startTime;
private float time;


void settings() {
  size(tileSize*canvasTileWidth, tileSize*canvasTileHeight, P2D);
}

void setup() {
  surface.setResizable(true);
  canvas = createGraphics(tileSize*canvasTileWidth, tileSize*canvasTileHeight, P2D);
  background(1);
  
  map = loadImage("map.png");
  mapOver = loadImage("map_over.png");
  exclamation = loadImage("sprites/exclamation.png");
  
  logo = loadImage("sprites/logo.png");
  logoBig = loadImage("sprites/logo_big.png");
  bulbasaur = loadImage("sprites/bulbasaur.png");
  charmander = loadImage("sprites/charmander.png");
  squirtle = loadImage("sprites/squirtle.png");
  
  caughtSound = new SoundFile(this, "caught.wav");
  mainTheme = new SoundFile(this, "mainTheme.wav");
  bump = new SoundFile(this, "bump.wav");
  
  mapMovement = loadTable("map.csv");
  
  initTrainers();
  light = new Light(5, trainers);
  
  
  mainTheme.loop();
}

void draw() {
  
  if(gameState == 0) {
    drawStartMenu();
  } else if(gameState == 1) {
    drawGame();
    if(pokemon.getTileX() == 12 && pokemon.getTileY() == 57) {
      gameState = 2; 
    }
  } else if(gameState == 2) {
    drawEndMenu();
  }
   
   //<>//
  if((float) width / height > AR) {
    image(canvas, (width/2) - (height * AR/2), 0, height * AR, height);
  } else {
    image(canvas, 0, (height/2) - (width / AR / 2) , width, width / AR);
  } 
}

void startGame(String pokemonName) {
  
  if((int) random(10) == 0) {
    pokemonName = pokemonName + "_shiny";
  }
  
  pokemon = new Player(83, 60, pokemonName);
  
  upPressed = false;
  rightPressed = false;
  downPressed = false;
  leftPressed = false;
  
  //preload map
  canvas.beginDraw();
  canvas.image(map, 0, 0);
  canvas.image(mapOver, 0, 0);
  canvas.endDraw();
  
  gameState = 1;
  startTime = millis();
  
}

void drawGame() {
  
  if(upPressed) {
    pokemon.moveUp();
    if(pokemon.facing == CHARACTER_UP && !pokemon.canWalkOnTile(pokemon.getTileX(), pokemon.getTileY() - 1) && !bumped) {
      bump.play();
      bumped = true;
    }
  } else if(downPressed) {
    pokemon.moveDown();
    if(pokemon.facing == CHARACTER_DOWN && !pokemon.canWalkOnTile(pokemon.getTileX(), pokemon.getTileY() + 1) && !bumped) {
      bump.play();
      bumped = true;
    }
  } else if(rightPressed) {
    pokemon.moveRight();
    if(pokemon.facing == CHARACTER_RIGHT && !pokemon.canWalkOnTile(pokemon.getTileX() + 1, pokemon.getTileY()) && !bumped) {
      bump.play();
      bumped = true;
    }
  } else if(leftPressed) {
    pokemon.moveLeft();
    if(pokemon.facing == CHARACTER_LEFT && !pokemon.canWalkOnTile(pokemon.getTileX() - 1, pokemon.getTileY()) && !bumped) {
      bump.play();
      bumped = true;
    }
  }
  
  if(restart){
    caughtSound.play();
    delay(1000);
    
    upPressed = false;
    rightPressed = false;
    downPressed = false;
    leftPressed = false;
    
    pokemon.teleport(83, 60);
    restart = false;  
    startTime = millis();
  }
  
  pokemon.update();
  light.update();
  
  canvas.beginDraw();
    
  drawMap();
  pokemon.draw(canvas);
  
  for(Trainer t : trainers) {
    t.update();
    t.draw(canvas);
    caught = t.lineOfSight(pokemon.getTileX(), pokemon.getTileY());
    if(caught){
      drawExclamation(t.getPixelX(), t.getPixelY() - tileSize);
      restart = true;
      caught = false;
    }
  }
  
  drawMapOver();
  light.draw(canvas);
  canvas.text(pokemon.getTileX() + ", " + pokemon.getTileY(), 10, 10);
  
  time = ((float) millis() - startTime) / 1000;
  canvas.text(time, 10, 40);
  
  canvas.endDraw();  
}

void drawStartMenu() {
  canvas.beginDraw();
  canvas.textSize(12);
  canvas.background(4, 0 , 10);
  
  canvas.image(logo, 0, 0);
  
  canvas.text("You are a pokemon left alone in a dark cave and you must find the way \nout. But be caraful, "+
              "because there are many trainers; And they will catch \nyou if they see you, so you must avoid them. \n" + 
              "Choose what pokemon you want to be to start the game", 110, 40);
             
  canvas.text("1: Bulbasaur", 60, 150);
  canvas.image(bulbasaur, 65, 160);
  
  canvas.text("2: Charmander", 240, 150);
  canvas.image(charmander, 245, 160);
  
  canvas.text("3: Squritle", 420, 150);
  canvas.image(squirtle, 425, 160);
              
  
  canvas.text("How to play: \nPick the pokemon you want to play with by pressing the '1', '2' or '3' buttons. \n" +
                "In game use the arrow keys to navigate. Avoid the line of sight of the trainers or else \nyou will jump at the start position. " + 
                " At any time you can press the BACKSPACE \nbutton to jump to the start menu. \nGood luck!", 20, 300);  
  
  
  canvas.endDraw();
  
}

void drawEndMenu() {
  canvas.beginDraw();
  canvas.background(4, 0 , 10);
  canvas.textSize(25);
  canvas.text("Congratulations!!", 160, 30);
  
  
  canvas.textSize(12);
  canvas.text("You beat the game with time: " + time + " seconds", 100, 100);
  canvas.text("Press any key to jump to start menu", 100, 125);
  canvas.image(logoBig, 130, 130);
  
  canvas.endDraw();
  
}

void keyPressed() {
  if(gameState == 0) {
    switch(key) {
      case '1':
        startGame("bulbasaur");
        break;
      case '2':
        startGame("charmander");
        break;
      case '3':
        startGame("squirtle");
        break;     
    }
  } else if(gameState == 1) {
    if(key == CODED) {
      if(keyCode == UP) {
        upPressed = true;
        bumped = false;
      } else if(keyCode == RIGHT) {
        rightPressed = true;
        bumped = false;
      } else if(keyCode == DOWN) {
        downPressed = true;
        bumped = false;
      } else if(keyCode == LEFT) {
        leftPressed = true;
        bumped = false;
      } 
    } else if(key == BACKSPACE) {
      gameState = 0;
    }
  } else if(gameState == 2) {
    gameState = 0;
  }
}

void keyReleased() {
  if(gameState == 1) {
    if(key == CODED) {
      if(keyCode == UP) {
        upPressed = false;
      } else if(keyCode == RIGHT) {
        rightPressed = false;
      } else if(keyCode == DOWN) {
        downPressed = false;
      } else if(keyCode == LEFT) {
        leftPressed = false;
      }
    } 
  } 
}


void drawMap() {
  mapPixelX = -pokemon.getPixelX() + (middleTileX * tileSize);
  mapPixelY = -pokemon.getPixelY() + (middleTileY * tileSize);
  canvas.image(map, mapPixelX, mapPixelY); 
}

void drawMapOver() {
   canvas.image(mapOver, mapPixelX, mapPixelY);
}

void drawExclamation(int pixelX, int pixelY) {
  canvas.image(exclamation, pixelX + mapPixelX, pixelY + mapPixelY);
  
}

void initTrainers() {
  Trainer t;
  int[] moves;
  moves= new int[8];
  moves[0] = CHARACTER_UP;
  moves[1] = CHARACTER_LEFT;
  moves[2] = CHARACTER_LEFT;
  moves[3] = CHARACTER_LEFT;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_RIGHT;
  moves[6] = CHARACTER_RIGHT;
  moves[7] = CHARACTER_RIGHT;
  t = new Trainer(110, 70, moves);
  trainers.add(t);
  
  moves = new int[4];
  moves[0] = ROTATE_UP;
  moves[1] = ROTATE_RIGHT;
  moves[2] = ROTATE_DOWN;
  moves[3] = ROTATE_RIGHT;
  t = new Trainer(101, 60, moves);
  trainers.add(t);
  
  moves = new int[4];
  moves[0] = ROTATE_UP;
  moves[1] = ROTATE_LEFT;
  moves[2] = ROTATE_DOWN;
  moves[3] = ROTATE_LEFT;
  t = new Trainer(102, 63, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_RIGHT;
  moves[1] = ROTATE_DOWN;
  t = new Trainer(101, 53, moves);
  trainers.add(t);
  
  moves = new int[5];
  moves[0] = ROTATE_UP;
  moves[1] = ROTATE_RIGHT;
  moves[2] = ROTATE_UP;
  moves[3] = ROTATE_UP;
  moves[4] = ROTATE_LEFT;
  t = new Trainer(108, 54, moves);
  trainers.add(t);
  
  moves = new int[8];
  moves[0] = CHARACTER_RIGHT;
  moves[1] = CHARACTER_RIGHT;
  moves[2] = CHARACTER_DOWN;
  moves[3] = CHARACTER_DOWN;
  moves[4] = CHARACTER_LEFT;
  moves[5] = CHARACTER_LEFT;
  moves[6] = CHARACTER_UP;
  moves[7] = CHARACTER_UP;
  t = new Trainer(114, 56, moves);
  trainers.add(t);
  
  moves = new int[8];
  moves[0] = CHARACTER_UP;
  moves[1] = CHARACTER_UP;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_RIGHT;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  t = new Trainer(117, 66, moves);
  trainers.add(t);
  
  moves = new int[8];
  moves[0] = CHARACTER_RIGHT;
  moves[1] = CHARACTER_RIGHT;
  moves[2] = CHARACTER_DOWN;
  moves[3] = CHARACTER_DOWN;
  moves[4] = CHARACTER_LEFT;
  moves[5] = CHARACTER_LEFT;
  moves[6] = CHARACTER_UP;
  moves[7] = CHARACTER_UP;
  t = new Trainer(114, 64, moves);
  trainers.add(t);
  
  moves = new int[10];
  moves[0] = CHARACTER_RIGHT;
  moves[1] = CHARACTER_RIGHT;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_DOWN;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_LEFT;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  moves[8] = CHARACTER_UP;
  moves[9] = CHARACTER_UP;
  t = new Trainer(125, 55, moves);
  trainers.add(t);
  
  moves = new int[16];
  moves[0] = CHARACTER_DOWN;
  moves[1] = CHARACTER_DOWN;
  moves[2] = CHARACTER_DOWN;
  moves[3] = ROTATE_RIGHT;
  moves[4] = CHARACTER_RIGHT;
  moves[5] = CHARACTER_RIGHT;
  moves[6] = CHARACTER_RIGHT;
  moves[7] = ROTATE_UP;
  moves[8] = CHARACTER_UP;
  moves[9] = CHARACTER_UP;
  moves[10] = CHARACTER_UP;
  moves[11] = ROTATE_LEFT;
  moves[12] = CHARACTER_LEFT;
  moves[13] = CHARACTER_LEFT;
  moves[14] = CHARACTER_LEFT;
  moves[15] = ROTATE_DOWN;
  t = new Trainer(120, 57, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_RIGHT;
  moves[1] = ROTATE_UP;
  t = new Trainer(115, 71, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_LEFT;
  moves[1] = ROTATE_DOWN;
  t = new Trainer(130, 51, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_LEFT;
  moves[1] = ROTATE_UP;
  t = new Trainer(137, 55, moves);
  trainers.add(t);
  
  moves = new int[18];
  moves[0] = CHARACTER_DOWN;
  moves[1] = CHARACTER_RIGHT;
  moves[2] = CHARACTER_DOWN;
  moves[3] = CHARACTER_RIGHT;
  moves[4] = CHARACTER_RIGHT;
  moves[5] = CHARACTER_UP;
  moves[6] = CHARACTER_RIGHT;
  moves[7] = CHARACTER_UP;
  moves[8] = CHARACTER_UP;
  moves[9] = CHARACTER_LEFT;
  moves[10] = CHARACTER_UP;
  moves[11] = CHARACTER_LEFT;
  moves[12] = CHARACTER_LEFT;
  moves[13] = CHARACTER_LEFT;
  moves[14] = CHARACTER_LEFT;
  moves[15] = CHARACTER_DOWN;
  moves[16] = CHARACTER_DOWN;
  moves[17] = CHARACTER_RIGHT;
  t = new Trainer(134, 66, moves);
  trainers.add(t);
  
  moves = new int[4];
  moves[0] = ROTATE_UP;
  moves[1] = ROTATE_LEFT;
  moves[2] = ROTATE_DOWN;
  moves[3] = ROTATE_RIGHT;
  t = new Trainer(148, 66, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_DOWN;
  moves[1] = ROTATE_RIGHT;
  t = new Trainer(156, 64, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_UP;
  moves[1] = ROTATE_RIGHT;
  t = new Trainer(158, 70, moves);
  trainers.add(t);
  
  moves = new int[1];
  moves[0] = ROTATE_LEFT;
  t = new Trainer(165, 67, moves);
  trainers.add(t);
  
  moves = new int[12];
  moves[0] = CHARACTER_UP;
  moves[1] = CHARACTER_UP;
  moves[2] = CHARACTER_UP;
  moves[3] = CHARACTER_LEFT;
  moves[4] = CHARACTER_LEFT;
  moves[5] = CHARACTER_LEFT;
  moves[6] = CHARACTER_DOWN;
  moves[7] = CHARACTER_DOWN;
  moves[8] = CHARACTER_DOWN;
  moves[9] = CHARACTER_RIGHT;
  moves[10] = CHARACTER_RIGHT;
  moves[11] = CHARACTER_RIGHT;
  t = new Trainer(161, 79, moves);
  trainers.add(t);
  
  moves = new int[24];
  moves[0] = CHARACTER_UP;
  moves[1] = CHARACTER_UP;
  moves[2] = CHARACTER_UP;
  moves[3] = CHARACTER_UP;
  moves[4] = CHARACTER_UP;
  moves[5] = CHARACTER_UP;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  moves[8] = CHARACTER_LEFT;
  moves[9] = CHARACTER_LEFT;
  moves[10] = CHARACTER_LEFT;
  moves[11] = CHARACTER_LEFT;
  moves[12] = CHARACTER_DOWN;
  moves[13] = CHARACTER_DOWN;
  moves[14] = CHARACTER_DOWN;
  moves[15] = CHARACTER_DOWN;
  moves[16] = CHARACTER_DOWN;
  moves[17] = CHARACTER_DOWN;
  moves[18] = CHARACTER_RIGHT;
  moves[19] = CHARACTER_RIGHT;
  moves[20] = CHARACTER_RIGHT;
  moves[21] = CHARACTER_RIGHT;
  moves[22] = CHARACTER_RIGHT;
  moves[23] = CHARACTER_RIGHT;
  t = new Trainer(163, 93, moves);
  trainers.add(t);
  
  moves = new int[24];
  moves[0] = CHARACTER_DOWN;
  moves[1] = CHARACTER_DOWN;
  moves[2] = CHARACTER_DOWN;
  moves[3] = CHARACTER_DOWN;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_RIGHT;
  moves[7] = CHARACTER_RIGHT;
  moves[8] = CHARACTER_RIGHT;
  moves[9] = CHARACTER_RIGHT;
  moves[10] = CHARACTER_RIGHT;
  moves[11] = CHARACTER_RIGHT;
  moves[12] = CHARACTER_UP;
  moves[13] = CHARACTER_UP;
  moves[14] = CHARACTER_UP;
  moves[15] = CHARACTER_UP;
  moves[16] = CHARACTER_UP;
  moves[17] = CHARACTER_UP;
  moves[18] = CHARACTER_LEFT;
  moves[19] = CHARACTER_LEFT;
  moves[20] = CHARACTER_LEFT;
  moves[21] = CHARACTER_LEFT;
  moves[22] = CHARACTER_LEFT;
  moves[23] = CHARACTER_LEFT;
  t = new Trainer(157, 87, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_DOWN;
  moves[1] = ROTATE_LEFT;
  t = new Trainer(152, 76, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_DOWN;
  moves[1] = ROTATE_RIGHT;
  t = new Trainer(146, 74, moves);
  trainers.add(t);
  
  moves = new int[4];
  moves[0] = CHARACTER_RIGHT;
  moves[1] = CHARACTER_RIGHT;
  moves[2] = CHARACTER_LEFT;
  moves[3] = CHARACTER_LEFT;
  t = new Trainer(147, 78, moves);
  trainers.add(t);
  
  moves = new int[16];
  moves[0] = CHARACTER_RIGHT;
  moves[1] = CHARACTER_RIGHT;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_RIGHT;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_DOWN;
  moves[7] = CHARACTER_DOWN;
  moves[8] = CHARACTER_LEFT;
  moves[9] = CHARACTER_LEFT;
  moves[10] = CHARACTER_LEFT;
  moves[11] = CHARACTER_LEFT;
  moves[12] = CHARACTER_UP;
  moves[13] = CHARACTER_UP;
  moves[14] = CHARACTER_UP;
  moves[15] = CHARACTER_UP;
  t = new Trainer(146, 88, moves);
  trainers.add(t);
  
  moves = new int[16];
  moves[0] = CHARACTER_DOWN;
  moves[1] = CHARACTER_DOWN;
  moves[2] = CHARACTER_DOWN;
  moves[3] = CHARACTER_DOWN;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_DOWN;
  moves[7] = CHARACTER_DOWN;
  moves[8] = CHARACTER_UP;
  moves[9] = CHARACTER_UP;
  moves[10] = CHARACTER_UP;
  moves[11] = CHARACTER_UP;
  moves[12] = CHARACTER_UP;
  moves[13] = CHARACTER_UP;
  moves[14] = CHARACTER_UP;
  moves[15] = CHARACTER_UP;
  t = new Trainer(134, 86, moves);
  trainers.add(t);
  
  moves = new int[16];
  moves[0] = CHARACTER_DOWN;
  moves[1] = CHARACTER_DOWN;
  moves[2] = CHARACTER_DOWN;
  moves[3] = CHARACTER_DOWN;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_DOWN;
  moves[7] = CHARACTER_DOWN;
  moves[8] = CHARACTER_UP;
  moves[9] = CHARACTER_UP;
  moves[10] = CHARACTER_UP;
  moves[11] = CHARACTER_UP;
  moves[12] = CHARACTER_UP;
  moves[13] = CHARACTER_UP;
  moves[14] = CHARACTER_UP;
  moves[15] = CHARACTER_UP;
  t = new Trainer(138, 86, moves);
  trainers.add(t);
  
  moves = new int[12];
  moves[0] = CHARACTER_RIGHT;
  moves[1] = CHARACTER_RIGHT;
  moves[2] = CHARACTER_DOWN;
  moves[3] = CHARACTER_DOWN;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  moves[8] = CHARACTER_UP;
  moves[9] = CHARACTER_UP;
  moves[10] = CHARACTER_UP;
  moves[11] = CHARACTER_UP;
  t = new Trainer(135, 100, moves);
  trainers.add(t);
  
  moves = new int[4];
  moves[0] = ROTATE_RIGHT;
  moves[1] = ROTATE_DOWN;
  moves[2] = ROTATE_LEFT;
  moves[3] = ROTATE_UP;
  t = new Trainer(154, 102, moves);
  trainers.add(t);
  
  moves = new int[12];
  moves[0] = ROTATE_RIGHT;
  moves[1] = ROTATE_DOWN;
  moves[2] = ROTATE_LEFT;
  moves[3] = ROTATE_UP;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = ROTATE_RIGHT;
  moves[7] = ROTATE_DOWN;
  moves[8] = ROTATE_LEFT;
  moves[9] = ROTATE_UP;
  moves[10] = CHARACTER_UP;
  moves[11] = CHARACTER_UP;
  t = new Trainer(148, 100, moves);
  trainers.add(t);
  
  moves = new int[16];
  moves[0] = CHARACTER_DOWN;
  moves[1] = CHARACTER_DOWN;
  moves[2] = CHARACTER_DOWN;
  moves[3] = CHARACTER_DOWN;
  moves[4] = CHARACTER_LEFT;
  moves[5] = CHARACTER_LEFT;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  moves[8] = CHARACTER_UP;
  moves[9] = CHARACTER_UP;
  moves[10] = CHARACTER_UP;
  moves[11] = CHARACTER_UP;
  moves[12] = CHARACTER_RIGHT;
  moves[13] = CHARACTER_RIGHT;
  moves[14] = CHARACTER_RIGHT;
  moves[15] = CHARACTER_RIGHT;
  t = new Trainer(114, 100, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_DOWN;
  moves[1] = ROTATE_LEFT;
  t = new Trainer(128, 88, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_UP;
  moves[1] = ROTATE_LEFT;
  t = new Trainer(124, 91, moves);
  trainers.add(t);
  
  moves = new int[4];
  moves[0] = ROTATE_RIGHT;
  moves[1] = ROTATE_DOWN;
  moves[2] = ROTATE_LEFT;
  moves[3] = ROTATE_UP;
  t = new Trainer(118, 90, moves);
  trainers.add(t);
  
  moves = new int[12];
  moves[0] = CHARACTER_DOWN;
  moves[1] = CHARACTER_DOWN;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_RIGHT;
  moves[4] = CHARACTER_RIGHT;
  moves[5] = CHARACTER_RIGHT;
  moves[6] = CHARACTER_UP;
  moves[7] = CHARACTER_UP;
  moves[8] = CHARACTER_LEFT;
  moves[9] = CHARACTER_LEFT;
  moves[10] = CHARACTER_LEFT;
  moves[11] = CHARACTER_LEFT;
  t = new Trainer(109, 87, moves);
  trainers.add(t);
  
  moves = new int[4];
  moves[0] = ROTATE_DOWN;
  moves[1] = ROTATE_LEFT;
  moves[2] = ROTATE_UP;
  moves[3] = ROTATE_LEFT;
  t = new Trainer(98, 89, moves);
  trainers.add(t);
  
  moves = new int[18];
  moves[0] = CHARACTER_RIGHT;
  moves[1] = CHARACTER_RIGHT;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_DOWN;
  moves[4] = CHARACTER_RIGHT;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_RIGHT;
  moves[7] = CHARACTER_DOWN;
  moves[8] = CHARACTER_DOWN;
  moves[9] = CHARACTER_LEFT;
  moves[10] = CHARACTER_LEFT;
  moves[11] = CHARACTER_LEFT;
  moves[12] = CHARACTER_UP;
  moves[13] = CHARACTER_LEFT;
  moves[14] = CHARACTER_UP;
  moves[15] = CHARACTER_LEFT;
  moves[16] = CHARACTER_UP;
  moves[17] = CHARACTER_UP;
  t = new Trainer(85, 88, moves);
  trainers.add(t);
  
  moves = new int[8];
  moves[0] = CHARACTER_UP;
  moves[1] = CHARACTER_UP;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_RIGHT;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  t = new Trainer(99, 103, moves);
  trainers.add(t);
  
  moves = new int[20];
  moves[0] = CHARACTER_RIGHT;
  moves[1] = CHARACTER_RIGHT;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_DOWN;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_RIGHT;
  moves[6] = CHARACTER_RIGHT;
  moves[7] = CHARACTER_RIGHT;
  moves[8] = CHARACTER_UP;
  moves[9] = CHARACTER_UP;
  moves[10] = CHARACTER_LEFT;
  moves[11] = CHARACTER_LEFT;
  moves[12] = CHARACTER_LEFT;
  moves[13] = CHARACTER_DOWN;
  moves[14] = CHARACTER_DOWN;
  moves[15] = CHARACTER_LEFT;
  moves[16] = CHARACTER_LEFT;
  moves[17] = CHARACTER_LEFT;
  moves[18] = CHARACTER_UP;
  moves[19] = CHARACTER_UP;
  t = new Trainer(73, 90, moves);
  trainers.add(t);
  
  moves = new int[8];
  moves[0] = CHARACTER_UP;
  moves[1] = CHARACTER_UP;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_RIGHT;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  t = new Trainer(63, 103,moves);
  trainers.add(t);
  
  moves = new int[8];
  moves[0] = CHARACTER_UP;
  moves[1] = CHARACTER_UP;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_RIGHT;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  t = new Trainer(61, 81, moves);
  trainers.add(t);
  
  moves = new int[8];
  moves[0] = CHARACTER_UP;
  moves[1] = CHARACTER_UP;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_RIGHT;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  t = new Trainer(65, 81,moves);
  trainers.add(t);
  
  moves = new int[8];
  moves[0] = CHARACTER_UP;
  moves[1] = CHARACTER_UP;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_RIGHT;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  t = new Trainer(65, 77, moves);
  trainers.add(t);
  
  moves = new int[8];
  moves[0] = CHARACTER_UP;
  moves[1] = CHARACTER_UP;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_RIGHT;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  t = new Trainer(61, 77,moves);
  trainers.add(t);
  
  moves = new int[12];
  moves[0] = CHARACTER_RIGHT;
  moves[1] = CHARACTER_RIGHT;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_DOWN;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  moves[8] = CHARACTER_LEFT;
  moves[9] = CHARACTER_UP;
  moves[10] = CHARACTER_UP;
  moves[11] = CHARACTER_UP;
  t = new Trainer(62, 64,moves);
  trainers.add(t);
  
  moves = new int[4];
  moves[0] = ROTATE_DOWN;
  moves[1] = ROTATE_LEFT;
  moves[2] = ROTATE_UP;
  moves[3] = ROTATE_LEFT;
  t = new Trainer(51, 66, moves);
  trainers.add(t);
  
  moves = new int[3];
  moves[0] = ROTATE_LEFT;
  moves[1] = ROTATE_UP;
  moves[2] = ROTATE_LEFT;
  t = new Trainer(162, 58,moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_RIGHT;
  moves[1] = ROTATE_DOWN;
  t = new Trainer(158, 50,moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_RIGHT;
  moves[1] = ROTATE_UP;
  t = new Trainer(156, 56,moves);
  trainers.add(t);
  
  moves = new int[4];
  moves[0] = ROTATE_DOWN;
  moves[1] = ROTATE_LEFT;
  moves[2] = ROTATE_UP;
  moves[3] = ROTATE_RIGHT;
  t = new Trainer(160, 36,moves);
  trainers.add(t);
  
  moves = new int[3];
  moves[0] = ROTATE_LEFT;
  moves[1] = ROTATE_UP;
  moves[2] = ROTATE_LEFT;
  t = new Trainer(163, 33,moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_LEFT;
  moves[1] = ROTATE_DOWN;
  t = new Trainer(162, 26,moves);
  trainers.add(t);
  
  moves = new int[4];
  moves[0] = ROTATE_DOWN;
  moves[1] = ROTATE_LEFT;
  moves[2] = ROTATE_UP;
  moves[3] = ROTATE_RIGHT;
  t = new Trainer(156, 30,moves);
  trainers.add(t);
  
  moves = new int[32];
  moves[0] = CHARACTER_DOWN;
  moves[1] = CHARACTER_DOWN;
  moves[2] = CHARACTER_DOWN;
  moves[3] = CHARACTER_DOWN;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  moves[8] = CHARACTER_LEFT;
  moves[9] = CHARACTER_LEFT;
  moves[10] = CHARACTER_UP;
  moves[11] = CHARACTER_UP;
  moves[12] = CHARACTER_UP;
  moves[13] = CHARACTER_UP;
  moves[14] = CHARACTER_UP;
  moves[15] = CHARACTER_UP;
  moves[16] = CHARACTER_DOWN;
  moves[17] = CHARACTER_DOWN;
  moves[18] = CHARACTER_DOWN;
  moves[19] = CHARACTER_DOWN;
  moves[20] = CHARACTER_DOWN;
  moves[21] = CHARACTER_DOWN;
  moves[22] = CHARACTER_RIGHT;
  moves[23] = CHARACTER_RIGHT;
  moves[24] = CHARACTER_RIGHT;
  moves[25] = CHARACTER_RIGHT;
  moves[26] = CHARACTER_UP;
  moves[27] = CHARACTER_UP;
  moves[28] = CHARACTER_UP;
  moves[29] = CHARACTER_UP;
  moves[30] = CHARACTER_UP;
  moves[31] = CHARACTER_UP;
  t = new Trainer(150, 26,moves);
  trainers.add(t);
  
  moves = new int[3];
  moves[0] = ROTATE_LEFT;
  moves[1] = ROTATE_UP;
  moves[2] = ROTATE_LEFT;
  t = new Trainer(128, 32, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_LEFT;
  moves[1] = ROTATE_DOWN;
  t = new Trainer(126, 26, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_RIGHT;
  moves[1] = ROTATE_DOWN;
  t = new Trainer(122, 26, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_RIGHT;
  moves[1] = ROTATE_UP;
  t = new Trainer(120, 32, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_RIGHT;
  moves[1] = ROTATE_UP;
  t = new Trainer(102, 28, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_LEFT;
  moves[1] = ROTATE_UP;
  t = new Trainer(98, 28, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_LEFT;
  moves[1] = ROTATE_DOWN;
  t = new Trainer(98, 32, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_RIGHT;
  moves[1] = ROTATE_DOWN;
  t = new Trainer(102, 32, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_RIGHT;
  moves[1] = ROTATE_UP;
  t = new Trainer(89, 29, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_RIGHT;
  moves[1] = ROTATE_DOWN;
  t = new Trainer(90, 32, moves);
  trainers.add(t);
  
  moves = new int[4];
  moves[0] = ROTATE_LEFT;
  moves[1] = ROTATE_UP;
  moves[2] = ROTATE_LEFT;
  moves[3] = ROTATE_DOWN;
  t = new Trainer(86, 30, moves);
  trainers.add(t);
  
  moves = new int[3];
  moves[0] = ROTATE_UP;
  moves[1] = ROTATE_UP;
  moves[2] = ROTATE_LEFT;
  t = new Trainer(78, 34, moves);
  trainers.add(t);
  
  moves = new int[3];
  moves[0] = ROTATE_RIGHT;
  moves[1] = ROTATE_UP;
  moves[2] = ROTATE_RIGHT;
  t = new Trainer(74, 34, moves);
  trainers.add(t);
  
  moves = new int[4];
  moves[0] = ROTATE_LEFT;
  moves[1] = ROTATE_UP;
  moves[2] = ROTATE_RIGHT;
  moves[3] = ROTATE_DOWN;
  t = new Trainer(72, 30, moves);
  trainers.add(t);
  
  moves = new int[8];
  moves[0] = CHARACTER_UP;
  moves[1] = CHARACTER_UP;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_RIGHT;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  t = new Trainer(63, 31, moves);
  trainers.add(t);
  
  moves = new int[8];
  moves[0] = CHARACTER_RIGHT;
  moves[1] = CHARACTER_RIGHT;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_RIGHT;
  moves[4] = CHARACTER_LEFT;
  moves[5] = CHARACTER_LEFT;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  t = new Trainer(84, 42, moves);
  trainers.add(t);
  
  moves = new int[8];
  moves[0] = CHARACTER_RIGHT;
  moves[1] = CHARACTER_RIGHT;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_RIGHT;
  moves[4] = CHARACTER_LEFT;
  moves[5] = CHARACTER_LEFT;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  t = new Trainer(84, 43, moves);
  trainers.add(t);
  
  moves = new int[24];
  moves[0] = CHARACTER_RIGHT;
  moves[1] = CHARACTER_RIGHT;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_RIGHT;
  moves[4] = CHARACTER_RIGHT;
  moves[5] = CHARACTER_RIGHT;
  moves[6] = CHARACTER_DOWN;
  moves[7] = CHARACTER_DOWN;
  moves[8] = CHARACTER_DOWN;
  moves[9] = CHARACTER_DOWN;
  moves[10] = CHARACTER_DOWN;
  moves[11] = CHARACTER_DOWN;
  moves[12] = CHARACTER_LEFT;
  moves[13] = CHARACTER_LEFT;
  moves[14] = CHARACTER_LEFT;
  moves[15] = CHARACTER_LEFT;
  moves[16] = CHARACTER_LEFT;
  moves[17] = CHARACTER_LEFT;
  moves[18] = CHARACTER_UP;
  moves[19] = CHARACTER_UP;
  moves[20] = CHARACTER_UP;
  moves[21] = CHARACTER_UP;
  moves[22] = CHARACTER_UP;
  moves[23] = CHARACTER_UP;
  t = new Trainer(61, 39, moves);
  trainers.add(t);
  
  moves = new int[8];
  moves[0] = CHARACTER_UP;
  moves[1] = CHARACTER_UP;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_RIGHT;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  t = new Trainer(61, 53, moves);
  trainers.add(t);
  
  moves = new int[8];
  moves[0] = CHARACTER_UP;
  moves[1] = CHARACTER_UP;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_RIGHT;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  t = new Trainer(65, 53, moves);
  trainers.add(t);
  
  moves = new int[8];
  moves[0] = CHARACTER_UP;
  moves[1] = CHARACTER_UP;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_RIGHT;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  t = new Trainer(65, 57, moves);
  trainers.add(t);
  
  moves = new int[8];
  moves[0] = CHARACTER_UP;
  moves[1] = CHARACTER_UP;
  moves[2] = CHARACTER_RIGHT;
  moves[3] = CHARACTER_RIGHT;
  moves[4] = CHARACTER_DOWN;
  moves[5] = CHARACTER_DOWN;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  t = new Trainer(61, 57, moves);
  trainers.add(t);
  
  moves = new int[4];
  moves[0] = ROTATE_UP;
  moves[1] = ROTATE_LEFT;
  moves[2] = ROTATE_DOWN;
  moves[3] = ROTATE_LEFT;
  t = new Trainer(43, 64, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_DOWN;
  moves[1] = ROTATE_LEFT;
  t = new Trainer(43, 58, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_UP;
  moves[1] = ROTATE_LEFT;
  t = new Trainer(43, 73, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_DOWN;
  moves[1] = ROTATE_RIGHT;
  t = new Trainer(11, 58, moves);
  trainers.add(t);
  
  moves = new int[2];
  moves[0] = ROTATE_UP;
  moves[1] = ROTATE_RIGHT;
  t = new Trainer(11, 73, moves);
  trainers.add(t);
  
  moves = new int[23];
  moves[0] = CHARACTER_LEFT;
  moves[1] = CHARACTER_LEFT;
  moves[2] = CHARACTER_LEFT;
  moves[3] = CHARACTER_LEFT;
  moves[4] = CHARACTER_LEFT;
  moves[5] = CHARACTER_LEFT;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  moves[8] = CHARACTER_LEFT;
  moves[9] = CHARACTER_LEFT;
  moves[10] = ROTATE_LEFT;
  moves[11] = ROTATE_UP;
  moves[12] = ROTATE_RIGHT;
  moves[13] = CHARACTER_RIGHT;
  moves[14] = CHARACTER_RIGHT;
  moves[15] = CHARACTER_RIGHT;
  moves[16] = CHARACTER_RIGHT;
  moves[17] = CHARACTER_RIGHT;
  moves[18] = CHARACTER_RIGHT;
  moves[19] = CHARACTER_RIGHT;
  moves[20] = CHARACTER_RIGHT;
  moves[21] = CHARACTER_RIGHT;
  moves[22] = CHARACTER_RIGHT;
  t = new Trainer(42, 71, moves);
  trainers.add(t);
  
  moves = new int[23];
  moves[0] = CHARACTER_LEFT;
  moves[1] = CHARACTER_LEFT;
  moves[2] = CHARACTER_LEFT;
  moves[3] = CHARACTER_LEFT;
  moves[4] = CHARACTER_LEFT;
  moves[5] = CHARACTER_LEFT;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  moves[8] = CHARACTER_LEFT;
  moves[9] = CHARACTER_LEFT;
  moves[10] = ROTATE_LEFT;
  moves[11] = ROTATE_UP;
  moves[12] = ROTATE_RIGHT;
  moves[13] = CHARACTER_RIGHT;
  moves[14] = CHARACTER_RIGHT;
  moves[15] = CHARACTER_RIGHT;
  moves[16] = CHARACTER_RIGHT;
  moves[17] = CHARACTER_RIGHT;
  moves[18] = CHARACTER_RIGHT;
  moves[19] = CHARACTER_RIGHT;
  moves[20] = CHARACTER_RIGHT;
  moves[21] = CHARACTER_RIGHT;
  moves[22] = CHARACTER_RIGHT;
  t = new Trainer(42, 60, moves);
  trainers.add(t);
  
  moves = new int[20];
  moves[0] = CHARACTER_LEFT;
  moves[1] = CHARACTER_LEFT;
  moves[2] = CHARACTER_LEFT;
  moves[3] = CHARACTER_LEFT;
  moves[4] = CHARACTER_LEFT;
  moves[5] = CHARACTER_LEFT;
  moves[6] = CHARACTER_LEFT;
  moves[7] = CHARACTER_LEFT;
  moves[8] = CHARACTER_LEFT;
  moves[9] = CHARACTER_LEFT;
  moves[10] = CHARACTER_RIGHT;
  moves[11] = CHARACTER_RIGHT;
  moves[12] = CHARACTER_RIGHT;
  moves[13] = CHARACTER_RIGHT;
  moves[14] = CHARACTER_RIGHT;
  moves[15] = CHARACTER_RIGHT;
  moves[16] = CHARACTER_RIGHT;
  moves[17] = CHARACTER_RIGHT;
  moves[18] = CHARACTER_RIGHT;
  moves[19] = CHARACTER_RIGHT;
  t = new Trainer(37, 65, moves);
  trainers.add(t);
  t = new Trainer(37, 66, moves);
  trainers.add(t);
  t = new Trainer(37, 67, moves);
  trainers.add(t);
  
  moves = new int[4];
  moves[0] = ROTATE_UP;
  moves[1] = ROTATE_RIGHT;
  moves[2] = ROTATE_DOWN;
  moves[3] = ROTATE_LEFT;
  t = new Trainer(32, 62, moves);
  trainers.add(t);
  
  moves = new int[4];
  moves[1] = ROTATE_RIGHT;
  moves[2] = ROTATE_DOWN;
  moves[3] = ROTATE_LEFT;
  moves[0] = ROTATE_UP;
  t = new Trainer(21, 60, moves);
  trainers.add(t);
}
