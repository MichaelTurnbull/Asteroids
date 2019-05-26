/**************************************************************
* File: a3.pde
* Group: Leigh West, Michael Turnbull, Lukas Dimitrios
* Date: 26 MAY 19
* Course: COSC101 - Software Development Studio 1
* Desc: This is a remake of the game Asteroids
* Usage: Open this file in the processing environment and press play
* Notes: The Minim library needs to be installed before running. Install
         by going to Sketch --> Import Library --> Add Library. Search for
         minim in the filter field and then click install on the bottom 
         right corner

         Sounds used come from 
         http://www.classicgaming.cc/classics/asteroids/sounds

         Font used is Hyperspace by Neale Davidson from
         https://www.dafont.com/hyperspace.font and is used under
         the shareware/font licence
**************************************************************/
import ddf.minim.*;

// ship related variables
PShape ship;
PShape thrust;
PVector shipLocation;
PVector shipVelocity;
PVector shipAcceleration;
float maxSpeed = 5;
float turnRate = 0.1;
float accelerationRate = 0.1;
float shipHeading = radians(270); // ship starts facing up

// asteroid related variables
int numAsteroids = 5;
int numSides = 12;
int small = 10;
int medium = 20;
int large = 30;
float asteroidSpeed = 1;
ArrayList<PVector> asteroidLocation = new ArrayList<PVector>();
ArrayList<PVector> asteroidVelocity = new ArrayList<PVector>();
ArrayList<PShape> asteroidShape = new ArrayList<PShape>();
IntList asteroidSize = new IntList();

// shot related variables
// ArrayLists are used to make it easy to add and remove shots without 
// recreating the array each time
ArrayList<PVector> shotLocations = new ArrayList<PVector>();
ArrayList<PVector> shotVelocitys = new ArrayList<PVector>();
float shotSpeed = 5;

// debris related variables, adjusting debrisCount changes the number of debris
// particles spawned and adjusting debrisAge changes the lifespan of the debris
ArrayList<PVector> debrisLocations = new ArrayList<PVector>();
ArrayList<PVector> debrisVelocitys = new ArrayList<PVector>();
IntList debrisAges = new IntList();
float debrisSpeed = 3;
int debrisCount = 4;
int debrisAge = 50;

// game related variables
boolean sUP = false, sDOWN = false, sRIGHT = false, sLEFT = false;
boolean alive = true;
PFont font;
int score = 0;
float buffer = 100;  // buffer around ship that asteroids cannot be created in

// sound related variables
Minim minim;
AudioPlayer themeSong;
AudioPlayer thrustSound;
AudioSample asteroidExplosion;
AudioPlayer shipExplosion;
AudioSample missile;

void setup() {
  size(800,700);
  stroke(255);
  noFill();
  font = loadFont("Hyperspace-25.vlw");
  textFont(font, 25);
  
  // initialise pvectors 
  shipLocation = new PVector(width/2, height/2); // starts at center screen
  shipVelocity = new PVector(0, 0);   // ship starts stationary
  
  for (int i=0; i<numAsteroids; i++) {
    createAsteroid(large);
  }
  
  ship = createShip();
  thrust = createThrust();

  minim = new Minim(this);
  themeSong = minim.loadFile("background.mp3");
  thrustSound = minim.loadFile("thrust.mp3");
  missile = minim.loadSample("fire.wav");
  asteroidExplosion = minim.loadSample("bangSmall.wav");
  shipExplosion = minim.loadFile("bangLarge.wav");
  themeSong.play();
  themeSong.loop();
}

void draw() {
  background(0);
  
  if (!alive) {  // if dead
    drawGameOver();
  } else {
    moveShip();
    drawShip(sUP);  // sUP is passed so that drawShip() knows to draw thrust
  }
  collisionDetection();
  drawShots();
  drawAsteroids();
  drawDebris();
  drawScore();
}

//
// -- ship related functions -- //
//

/**************************************************************
* Function: createShip()
* Parameters: none
* Returns: a PShape representing a ship
* Desc: Creates a PShape object from a series of vertexes that form the shape 
        of a ship
***************************************************************/
PShape createShip(){
  PShape newShip;

  newShip = createShape();
  
  newShip.beginShape();
  newShip.vertex(10,0);
  newShip.vertex(-10,-7);
  newShip.vertex(-5,0);
  newShip.vertex(-10,7);
  newShip.endShape(CLOSE);
  
  return newShip;
}

/**************************************************************
* Function: createThrust()
* Parameters: none
* Returns: a PShape representing the thrust coming out the back of a ship
* Desc: Creates a PShape object from a series of vertexes that form the shape 
        of the ships thrust. It is a separate PShape so that it can be drawn
        or not drawn depending on whether the ship is 'thrustuing'
***************************************************************/
PShape createThrust() {
  PShape newThrust;
  
  newThrust = createShape();
  
  newThrust.beginShape();
  newThrust.vertex(-9, 2);
  newThrust.vertex(-14, 0);
  newThrust.vertex(-9, -2);
  newThrust.endShape();
  
  return newThrust;
}

/**************************************************************
* Function: drawShip()
* Parameters: boolean thrustOn
* Returns: void
* Desc: Uses pushMatrix() and popMatrix() so that the translate() function's 
        effects are localised to this funtion.
        Uses translate() to move Processing's reference to where we want to
        position the ship
        Rotates the reference by the amount specified in shipHeading
        Draws the ship PShape (and optionally the thrust PShape) at the
        coordinates specified in the shipLocation PVector.
***************************************************************/
void drawShip(boolean thrustOn) {
  pushMatrix();
  translate(shipLocation.x, shipLocation.y);
  rotate(shipHeading);
  shape(ship);
  if (thrustOn) {
    shape(thrust);
  }
  popMatrix();
}

/**************************************************************
* Function: moveShip()
* Parameters: none
* Returns: void
* Desc: Calculates changes to acceleration and heading based on which keys are
        being pressed. Boolean variables representing the keys being held in
        are used to make for smoother ship movement than directly using
        keyPressed() and keyReleased() events.
        Velocity is calculated by adding acceleration to itself and then limited
        by the global variable maxSpeed.
        shipLocation is then updated based on the velocity calculated
        Finally shipLocation is passed into the function keepOnScreen to ensure
        it doesn't fly off the screen
***************************************************************/
void moveShip() {

  if(sUP){
    shipAcceleration = new PVector(cos(shipHeading), sin(shipHeading)); // accel direction
    shipAcceleration.setMag(accelerationRate); // acceleration magnitude
    shipVelocity.add(shipAcceleration);
    shipVelocity.limit(maxSpeed);
  }
  if(sDOWN){

  }
  if(sRIGHT){
    shipHeading += turnRate;
  }
  if(sLEFT){
    shipHeading -= turnRate;
  }
  
  shipLocation.add(shipVelocity);
  shipLocation = keepOnScreen(shipLocation);
}

// -- asteroid related functions -- //

/**************************************************************
* Function: createAsteroid()
* Parameters: int size
* Returns: void
* Desc: This is an overloaded version of the createAsteroid() function for
        when the function is called without the starting position specified.
        This function calculates some random values that are not within a
        buffer (default 100px) of the ship and are inside the window. It then
        and calls the createAsteroid() function with those position values.
***************************************************************/
void createAsteroid(int size){
  
  float randomX = random(width);
  float randomY = random(height);
  
  while (abs(randomX-shipLocation.x) < buffer) {
    randomX = random(width);
  }
  while (abs(randomY-shipLocation.y) < buffer) {
    randomY = random(height);
  }
  
  createAsteroid(size, randomX, randomY);
}

/**************************************************************
* Function: createAsteroid()
* Parameters: int size, float x, float y
* Returns: void
* Desc: Creates either a small, medium or large asteroid at position (x, y)
        and adds its details to the ArrayLists that store them.
        the initial direction is random and the speed is based on what level
        of the game you're on. shape is generated randomly by
        generateAsteroidShape()
***************************************************************/
void createAsteroid(int size, float x, float y) {

  asteroidLocation.add(new PVector(x, y));
  asteroidVelocity.add(PVector.random2D().setMag(asteroidSpeed));
  asteroidShape.add(generateAsteroidShape(size, numSides));
  asteroidSize.append(size);
}

/**************************************************************
* Function: generateAsteroidShape()
* Parameters: float radius, int numPoints
* Returns: a new randomly generated asteroid PShape
* Desc: Generates a random asteroid shape by first dividing a circle with an
        arbitrary number of equally spaced radials. For each radial, pick a
        point along it that is a random number equal to +/- half the radius of
        the circle. Calculate the coordinates of each of those points and then
        draw lines between them.
***************************************************************/
PShape generateAsteroidShape(float radius, int numPoints) {

  float angle = TWO_PI / numPoints;
  PShape asteroid = createShape();
  asteroid.beginShape();
  for (float i = 0; i < TWO_PI; i += angle) {
    float randomRadius = radius + random(-0.5*radius, 0.5*radius);
    float sx = cos(i) * randomRadius;
    float sy = sin(i) * randomRadius;
    asteroid.vertex(sx, sy);
  }
  asteroid.endShape(CLOSE);
  return asteroid;
}

/**************************************************************
* Function: drawAsteroids()
* Parameters: none
* Returns: void
* Desc: Update the position of each asteroid based on it's velocity
        Keep the asteroid on the screen with keepOnScreen()
        Draw each asteroid
***************************************************************/
void drawAsteroids() {

   for (int i = 0; i < asteroidLocation.size(); i++) {
     asteroidLocation.get(i).add(asteroidVelocity.get(i));
     asteroidLocation.set(i, keepOnScreen(asteroidLocation.get(i)));
     
     pushMatrix();
     translate(asteroidLocation.get(i).x, asteroidLocation.get(i).y);
     shape(asteroidShape.get(i));
     popMatrix();
   }
}

/**************************************************************
* Function: breakAsteroid()
* Parameters: int index
* Returns: void
* Desc: Breaks up the asteroid at which is at 'index' in the asteroid arrays.
        Either creates two smaller asteroids in its place or removes it
        altogether if it was already the smallest asteroid.
        Draws debris where the asteroid was.
        If it was the final asteroid then run the levelUp() function
***************************************************************/
void breakAsteroid(int index){

  // create the debris for the explosion effect
  // has to be placed before the removal of the asteroid from the arrays
  // otherwise the debris is in the wrong spot
    for (int i = 1; i <= debrisCount; i++) {
      PVector newDebris = new PVector(random(-90, 90), random(-90, 90));
      newDebris.setMag(debrisSpeed);
      debrisLocations.add(new PVector(asteroidLocation.get(index).x, asteroidLocation.get(index).y));
      debrisVelocitys.add(newDebris);
      debrisAges.append(1);
    }
    
  // if it's the last asteroid
  if (index == 0 && 
      asteroidLocation.size() == 1 && 
      asteroidSize.get(index) == 10) {

    asteroidLocation.remove(index);
    asteroidVelocity.remove(index);
    asteroidShape.remove(index);
    asteroidSize.remove(index);

    levelUp();
    return;
  } else {
    // Break the asteroid into two smaller asteroids
    // If it's already the smallest sized asteroid, remove it

    // The position that the two new asteroids will be created
    float newX = asteroidLocation.get(index).x;
    float newY = asteroidLocation.get(index).y;
    int size = asteroidSize.get(index);
    
    // remove the old asteroid
    asteroidLocation.remove(index);
    asteroidVelocity.remove(index);
    asteroidShape.remove(index);
    asteroidSize.remove(index);
    
    // create the new asteroids (if not the smallest size already)
    if (size == 30) {
      createAsteroid(medium, newX, newY);
      createAsteroid(medium, newX, newY);
    } else if (size == 20) {
      createAsteroid(small, newX, newY);
      createAsteroid(small, newX, newY);
    }
  }
}

//
// -- game related functions -- //
//

/**************************************************************
* Function: levelUp()
* Parameters: none
* Returns: void
* Desc: Increase number of asteroids
        Increase asteroid speed
        Increase score
        Draw new asteroids
***************************************************************/
void levelUp() {

  numAsteroids += 1;
  asteroidSpeed += 0.5;
  score += 100;
  
  for (int i=0; i<numAsteroids; i++) {
    createAsteroid(large);
  }
}

/**************************************************************
* Function: keepOnScreen()
* Parameters: a PVector
* Returns: the PVector that has been corrected to stay on the screen)
* Desc: Takes a PVector parameter (like the coords of the ship or an asteroid).
        Tests to see if any of the coordinated have reached a screen boundary
        and if they have, changes the coordinates to be on the other side of the 
        window.
***************************************************************/
PVector keepOnScreen(PVector coord){

  if (coord.y > height) {
    coord.y = 0;
  }
  if (coord.y < 0) {
    coord.y = height;
  }
  if (coord.x > width) {
    coord.x = 0;
  } 
  if (coord.x < 0) {
    coord.x = width;
  }
  
  return coord;
}

/**************************************************************
* Function: collisionDetection()
* Parameters: none
* Returns: void
* Desc: Detects if the ship has collided with an asteroid and kills the ship
        if it does.
        Detects if shots collide with asteroids and calls breakAsteroid() if
        they do. Also removes the shot from the shot arrays.
***************************************************************/
void collisionDetection() {
  
  // check if ship has collided with asteroids
  for (int i = 0; i < asteroidLocation.size(); i++) {
    if (pow(shipLocation.x - asteroidLocation.get(i).x, 2) + 
        pow(shipLocation.y - asteroidLocation.get(i).y, 2) <= 
        pow(10 + asteroidSize.get(i), 2)) {
          
          alive = false;
          thrustSound.pause();
          shipExplosion.play();     
    }
  }

  // check if shots have collided with asteroids
  for (int i = 0; i < asteroidLocation.size(); i++) {
    for (int j = 0; j < shotLocations.size(); j++) {

      // Lukus wrote this - I don't know understand it but it works really well
      if (pow(shotLocations.get(j).x - asteroidLocation.get(i).x, 2) + 
          pow(shotLocations.get(j).y - asteroidLocation.get(i).y, 2) <= 
          pow(3 + asteroidSize.get(i), 2)) {

        asteroidExplosion.trigger();

        breakAsteroid(i);
        shotLocations.remove(j);
        shotVelocitys.remove(j);
        score += 10;
        
        // breaking out of the loop after shots have been removed from the 
        // ArrayList  stops the program crashing by trying to test against a
        // value that's no longer there. It took two days to work this out
        break;
      }
    }
  }
}

/**************************************************************
* Function: drawShots()
* Parameters: none
* Returns: void
* Desc: For each shot in the shot arrays, the position is updated based on its
        velocity then draws the shots. If the shots leave the screen, they are
        removed from the arrays.
***************************************************************/
void drawShots() {
   // update the position of the shots
   for (int i=0; i < shotLocations.size(); i++) {
     shotLocations.get(i).add(shotVelocitys.get(i));
     
     // draw the shot
     circle(shotLocations.get(i).x, shotLocations.get(i).y, 3);
     
     // once the shots have moved off the screen, delete them
     if (shotLocations.get(i).x < 0 ||
         shotLocations.get(i).x > width ||
         shotLocations.get(i).y < 0 ||
         shotLocations.get(i).y > height) {
           
           shotLocations.remove(i);
           shotVelocitys.remove(i);
     }    
   }
}

/**************************************************************
* Function: drawDebris()
* Parameters: none
* Returns: void
* Desc: Draws debris based on the details in the debrisLocations, 
        debrisVelocities, and debrisAges arrays. Debris are drawn as a circle.
***************************************************************/
void drawDebris() {
  for (int i=0; i < debrisLocations.size(); i++) {
    debrisAges.add(i, 1);
    debrisLocations.get(i).add(debrisVelocitys.get(i));

    circle(debrisLocations.get(i).x, debrisLocations.get(i).y, 2);

    if (int(debrisAges.get(i)) > debrisAge) {
      debrisLocations.remove(i);
      debrisVelocitys.remove(i);
      debrisAges.remove(i);
    }
  }
}

/**************************************************************
* Function: drawScore()
* Parameters: none
* Returns: void
* Desc: Draws the current score to the upper left corner of the screen.
***************************************************************/
void drawScore() {
  text(str(score), 20, 40);
}

/**************************************************************
* Function: keyPressed()
* Parameters: none
* Returns: void
* Desc: Built in Processing event handler for key presses. Assigns boolean
        variables to true if that key is currently pressed it. Those booleans
        are then used to manage ship movement.
        Spacebar triggers firing a shot from the ship's position.
        The press ENTER to restart is also handled here.
***************************************************************/
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      sUP=true;
      if (alive) {  // stops being able to trigger the sounds when dead
        thrustSound.play();
      }
    }
    if (keyCode == DOWN) {
      sDOWN=true;
    } 
    if (keyCode == RIGHT) {
      sRIGHT=true;
    }
    if (keyCode == LEFT) {
      sLEFT=true;
    }
  }

  if (key == ' ') {
    //fire a shot
    
    // don't fire whilst dead
    if (alive) {
      // initial shot direction is based on ship's heading
      PVector newShot = new PVector(cos(shipHeading), sin(shipHeading));

      // set the speed of the shot
      newShot.setMag(shotSpeed);
      
      // add the new shot to the PVector ArrayLists
      shotLocations.add(new PVector(shipLocation.x, shipLocation.y));
      shotVelocitys.add(newShot);

      // play missile sound
      missile.trigger();
    }
  
  }
  if (key == ENTER && !alive){
    gameRestart();
  }  
}

/**************************************************************
* Function: keyReleased()
* Parameters: none
* Returns: void
* Desc: Built in Processing event handler for key releases. 
***************************************************************/
void keyReleased() {
  
  if (key == CODED) {
    if (keyCode == UP) {
      sUP=false;
      thrustSound.pause();

      // Remove the ships acceleration
      shipAcceleration = new PVector(0,0);
    }
    if (keyCode == DOWN) {
      sDOWN=false;
    } 
    if (keyCode == RIGHT) {
      sRIGHT=false;
    }
    if (keyCode == LEFT) {
      sLEFT=false;
    }
  }
}

/**************************************************************
* Function: drawGameOver()
* Parameters: none
* Returns: void
* Desc: Called when the ship has collided with an asteroid. Displays the
        game over message.
***************************************************************/
void drawGameOver() {

  push();
  textAlign(CENTER);
  text("GAME OVER", width/2, height/2);
  text("Press ENTER to restart", width/2, height/2+50);
  pop();
}

/**************************************************************
* Function: gameRestart()
* Parameters: none
* Returns: void
* Desc: Clears all the arrays that hold game data, resets the score and
        recreates the asteroids and ship.
***************************************************************/
void gameRestart() {
  alive = true;
  // initialise pvectors 
  shipLocation = new PVector(width/2, height/2); // starts at center screen
  shipVelocity = new PVector(0, 0);   // ship starts stationary
  shipAcceleration = new PVector(0,0); // and with no acceleration
  
  asteroidLocation.clear();
  asteroidVelocity.clear();
  asteroidShape.clear();
  asteroidSize.clear();
  shotLocations.clear();
  shotVelocitys.clear();
  
  score = 0;
  numAsteroids = 5;
  asteroidSpeed = 1;

  for (int i=0; i<numAsteroids; i++) {
    createAsteroid(large);
  }
   
  ship = createShip();
  thrust = createThrust();
  shipExplosion.rewind();
}