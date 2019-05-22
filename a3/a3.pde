/**************************************************************
* File: a3.pde
* Group: Leigh West, Michael Turnbull, Lukas Dimitrios
* Date: 
* Course: COSC101 - Software Development Studio 1
* Desc: This is a remake of the game Asteroids
* Usage: Open this file in the processing environment and press play
* Notes: Font used is Hyperspace by Neale Davidson from
         https://www.dafont.com/hyperspace.font and is used under
         the shareware/font licence
**************************************************************/

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

// game related variables
boolean sUP = false, sDOWN = false, sRIGHT = false, sLEFT = false;
boolean alive = true;
PFont font;
int score = 0;
float buffer = 100;  // buffer around ship that asteroids cannot be created in


void setup() {
  size(800,700);
  stroke(255);
  noFill();
  font = loadFont("Hyperspace-25.vlw");
  textFont(font, 25);
  
  // initialise pvectors 
  shipLocation = new PVector(width/2, height/2); // starts at center screen
  shipVelocity = new PVector(0, 0);   // ship starts stationary
  shipAcceleration = new PVector(0,0); // and with no acceleration
  
  for (int i=0; i<numAsteroids; i++) {
    createAsteroid(large);
  }
  
  ship = createShip();
  thrust = createThrust();
}

void draw(){
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
  drawScore();
}

//
// -- ship related functions -- //
//

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

void moveShip() {
  // move ship based on boolean values that are set by key input
  // this makes for smoother ship movement

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

void createAsteroid(int size){
  // when starting position is not specified, run the function with a
  // random starting position - the starting position should not be within
  // a square shaped buffer around the ship
  
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

void createAsteroid(int size, float x, float y) {
  // creates either a small, medium, or large asteroid at position (x, y)
  // and adds its details to the ArrayLists that store them.
  // the initial direction is random and the speed is based on what level of
  // the game you're on. shape is generated randomly by generateAsteroidShape()

  asteroidLocation.add(new PVector(x, y));
  asteroidVelocity.add(PVector.random2D().setMag(asteroidSpeed));
  asteroidShape.add(generateAsteroidShape(size, numSides));
  asteroidSize.append(size);
}

PShape generateAsteroidShape(float radius, int numPoints) {
  // generates a random asteroid shape by first dividing a circle with an
  // arbitrary number of equally spaced radials. for each radial, pick a
  // point along it that is a random number equal to +/- half the radius of
  // the circle. calculate the coordinates of each of those points and then
  // draw lines between them.

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

void drawAsteroids() {
  // update the position of each asteroid based on it's velocity
  // keep the asteroid on the screen
  // draw each asteroid

   for (int i = 0; i < asteroidLocation.size(); i++) {
     asteroidLocation.get(i).add(asteroidVelocity.get(i));
     asteroidLocation.set(i, keepOnScreen(asteroidLocation.get(i)));
     
     pushMatrix();
     translate(asteroidLocation.get(i).x, asteroidLocation.get(i).y);
     shape(asteroidShape.get(i));
     popMatrix();
   }
}

void breakAsteroid(int index){
  // Breaks up the asteroid at which is at 'index' in the asteroid arrays

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
    // TODO: Come up with a breaking up animation

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

void levelUp() {
  // increase number of asteroids
  // increase asteroid speed
  // increase score
  // draw new asteroids
  
  numAsteroids += 1;
  asteroidSpeed += 0.5;
  score += 100;
  
  for (int i=0; i<numAsteroids; i++) {
    createAsteroid(large);
  }
  
}

PVector keepOnScreen(PVector coord){
  // Takes a PVector parameter (like the coords of the ship or an asteroid).
  // Tests to see if any of the coordinates have reached a screen boundary
  // and if they have, changes the coordinates to be on the other side of the 
  // window. Returns the new coordinates as a PVector.

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

void collisionDetection() {
  
  // check if ship has collided with asteroids
  for (int i = 0; i < asteroidLocation.size(); i++) {
    if (pow(shipLocation.x - asteroidLocation.get(i).x, 2) + 
        pow(shipLocation.y - asteroidLocation.get(i).y, 2) <= 
        pow(10 + asteroidSize.get(i), 2)) {
          
          alive = false;
    }
  }

  // check if shots have collided with asteroids
  for (int i = 0; i < asteroidLocation.size(); i++) {
    for (int j = 0; j < shotLocations.size(); j++) {

      // Lukus wrote this - I don't know understand it but it works really well
      if (pow(shotLocations.get(j).x - asteroidLocation.get(i).x, 2) + 
          pow(shotLocations.get(j).y - asteroidLocation.get(i).y, 2) <= 
          pow(3 + asteroidSize.get(i), 2)) {

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

void drawScore() {
  text(str(score), 20, 40);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      sUP=true;
    }
    if (keyCode == DOWN) {
      sDOWN=true;
      breakAsteroid(int(random(0, asteroidLocation.size()-1)));  // for testing
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
    }  
  }
}

void keyReleased() {
  
  // Remove the ships acceleration
  shipAcceleration = new PVector(0,0);
  
  if (key == CODED) {
    if (keyCode == UP) {
      sUP=false;
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

void drawGameOver() {
  // ship breaks apart
  // some sort of message on the screen
  // display final score
  // ENTER to play again?
  //   if so, reset everything and start again
  
  push();
  textAlign(CENTER);
  text("GAME OVER", width/2, height/2);
  pop();
}


