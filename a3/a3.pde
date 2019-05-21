/**************************************************************
* File: a3.pde
* Group: Leigh West, Michael Turnbull, Lukas Dimitrios
* Date: 
* Course: COSC101 - Software Development Studio 1
* Desc: asteroid is a ...
* ...
* Usage: Make sure to run in the processing environment and press play etc...
* Notes: If any third party items are use they need to be credited (don't use anything with copyright - unless you have permission)
* ...
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
float shotSpeed = 4;

// game related variables
boolean sUP = false, sDOWN = false, sRIGHT = false, sLEFT = false;
int score = 0;
boolean alive = true;


void setup() {
  size(800,600);
  stroke(255);
  noFill();
  
  // initialise pvectors 
  shipLocation = new PVector(width/2, height/2); // ship starts in the middle of the window
  shipVelocity = new PVector(0, 0);   // ship starts stationary
  shipAcceleration = new PVector(0,0); // and with no acceleration
  
  for (int i=0; i<numAsteroids; i++) {
    createAsteroid("large");
  }
  
  ship = createShip();
  thrust = createThrust();
}

void draw(){
  background(0);
  
  // TODO:
  // checking to see if you are still alive
  // report if game over or won
  // draw score
  
  moveShip();
  drawShip(sUP);  // sUP is passed so that drawShip() knows when to draw the thrust
  collisionDetection();
  drawShots();
  drawAsteroids();
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

  // TODO: write keepOnScreen as an extension to the PVector class if possible
  shipLocation = keepOnScreen(shipLocation);
}

// -- asteroid related functions -- //

void createAsteroid(String smallMediumOrLarge){
  // when starting position is not specified, run the function with a
  // random starting position
  createAsteroid(smallMediumOrLarge, random(width), random(height));
}

void createAsteroid(String smallMediumOrLarge, float x, float y) {
  // creates an asteroid of the desired size (small, medium or large) in the specified coordinates
  int size = 0;

  switch (smallMediumOrLarge) {
    case "large": 
      size = 30;
      break;
    case "medium":
      size = 20;
      break;
    case "small":
      size = 10;
      break;
  }

  asteroidLocation.add(new PVector(x, y));
  // set a random direction, and set the speed
  asteroidVelocity.add(PVector.random2D().setMag(asteroidSpeed));
  asteroidShape.add(generateAsteroidShape(size, numSides));
  asteroidSize.append(size);
}

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

void drawAsteroids() {
  // check to see if asteroid is not already destroyed
  // otherwise draw at location 
  // initial direction and location should be randomised
  // also make sure the asteroid has not moved outside of the window

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
  if (index == 0 && asteroidLocation.size() == 1 && asteroidSize.get(index) == 10) {
    // remove the asteroid and level up 
    asteroidLocation.remove(index);
    asteroidVelocity.remove(index);
    asteroidShape.remove(index);
    asteroidSize.remove(index);

    levelUp();
    return;

  } else {
    // Break the asteroid into two smaller asteroids
    // If it's already the smallest sized asteroid, remove it
    // Come up with a breaking up animation

    // The position that the two new asteroids will be created
    float newX = asteroidLocation.get(index).x;
    float newY = asteroidLocation.get(index).y;
    int size = asteroidSize.get(index);
       
    asteroidLocation.remove(index);
    asteroidVelocity.remove(index);
    asteroidShape.remove(index);
    asteroidSize.remove(index);
    
    if (size == 30) {
      createAsteroid("medium", newX, newY);
      createAsteroid("medium", newX, newY);
    } else if (size == 20) {
      createAsteroid("small", newX, newY);
      createAsteroid("small", newX, newY);
    }
  }
}

//
// -- game related functions -- //
//

void levelUp() {
  // Reset asteroids
  // Increase number of asteroids
  // Increase asteroid speed
  // Increase score
  
  numAsteroids += 1;
  asteroidSpeed += 0.5;
  for (int i=0; i<numAsteroids; i++) {
    createAsteroid("large");
  }
  
}

PVector keepOnScreen(PVector coord){
  // Takes a PVector parameter (like the coords of the ship or an asteroid).
  // Tests to see if any of the coordinates have reached a screen boundary
  // and if they have, changes the coordinates to be on the other side of the 
  // window.

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

      gameOver();
    }
  }

  // check if shots have collided with asteroids
  for (int i = 0; i < asteroidLocation.size(); i++) {
    for (int j = 0; j < shotLocations.size(); j++) {

      // Lukus wrote this - I don't know how it works but it seems to work really well
      if (pow(shotLocations.get(j).x - asteroidLocation.get(i).x, 2) + 
          pow(shotLocations.get(j).y - asteroidLocation.get(i).y, 2) <= 
          pow(3 + asteroidSize.get(i), 2)) {

        breakAsteroid(i);
        shotLocations.remove(j);
        shotVelocitys.remove(j);
        
        // breaking out of the loop after shots have been removed from the ArrayList  stops
        // the program crashing by trying to test against a value that's no longer there
        // It took two days to work this out
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

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      sUP=true;
    }
    if (keyCode == DOWN) {
      sDOWN=true;
      breakAsteroid(int(random(0, asteroidLocation.size()-1)));
    } 
    if (keyCode == RIGHT) {
      sRIGHT=true;
    }
    if (keyCode == LEFT) {
      sLEFT=true;
    }
  }
  if (key == ' ') {  //fire a shot
    
    // initial shot direction is based on ship's heading
    PVector newShot = new PVector(cos(shipHeading), sin(shipHeading));

    // set the speed of the shot
    newShot.setMag(shotSpeed);
    
    // add the new shot to the PVector ArrayLists
    shotLocations.add(new PVector(shipLocation.x, shipLocation.y));
    shotVelocitys.add(newShot);
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

void gameOver() {
  
  
}



// Left down here as a template
/**************************************************************
* Function: myFunction()

* Parameters: None ( could be integer(x), integer(y) or String(myStr))

* Returns: Void ( again this could return a String or integer/float type )

* Desc: Each funciton should have appropriate documentation. 
        This is designed to benefit both the marker and your team mates.
        So it is better to keep it up to date, same with usage in the header comment

***************************************************************/