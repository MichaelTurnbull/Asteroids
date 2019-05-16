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
PVector shipLocation;
PVector shipVelocity;
PVector shipAcceleration;
float maxSpeed = 5;
float turnRate = 0.1;
float accelerationRate = 0.1;
float shipHeading = radians(270); // ship starts facing up

// asteroid related variables
int numAsteroids = 10;
int numSides = 12;
PVector[] asteroidLocation = new PVector[numAsteroids];
PVector[] asteroidDirection = new PVector[numAsteroids];
PShape[] asteroidShape = new PShape[numAsteroids];
int[] asteroidSize = new int[numAsteroids];

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
  size(800,800);
  
  // initialise pvectors 
  shipLocation = new PVector(width/2, height/2); // ship starts in the middle of the window
  shipVelocity = new PVector(0, 0);   // ship starts stationary
  shipAcceleration = new PVector(0,0); // and with no acceleration
  
  for (int i=0; i<numAsteroids; i++) {
    createAsteroid("large", i);
  }
  
  ship = createShip();
  
}

void draw(){
  background(255);
  
  // TODO:
  // checking to see if you are still alive
  // report if game over or won
  // draw score
  
  moveShip();
  drawShip();
  collisionDetection();
  drawShots();
  drawAsteroids();
  

}

PShape createShip(){
  PShape newShip;

  newShip = createShape();
  noFill();
  
  newShip.beginShape();
  newShip.vertex(10,0);
  newShip.vertex(-10,-7);
  newShip.vertex(-5,0);
  newShip.vertex(-10,7);
  newShip.endShape(CLOSE);
  
  return newShip;
}

void createAsteroid(String smallMediumOrLarge, int i){
  // when starting position is not specified, run the function with a
  // random starting position
  createAsteroid(smallMediumOrLarge, i, random(width), random(height));
}

void createAsteroid(String smallMediumOrLarge, int i, float x, float y) {
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

  asteroidLocation[i] = new PVector(x, y);
  asteroidDirection[i] = PVector.random2D();
  asteroidShape[i] = generateAsteroidShape(size, numSides);
  asteroidSize[i] = size;
}

PShape generateAsteroidShape(float radius, int numPoints) {
  float angle = TWO_PI / numPoints;
  PShape asteroid = createShape();
  noFill();
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

void testAsteroidBreak(int beenHit){

  if (beenHit == 0 && asteroidLocation.length == 1) { // hit the last asteroid
    // Reset asteroids
    // Increase Asteroid Speed
    // Increase Score
    return;
  }

  float newX = asteroidLocation[beenHit].x;
  float newY = asteroidLocation[beenHit].y;
  
  int newNumAsteroids = numAsteroids;
  if (asteroidSize[beenHit] == 30 || asteroidSize[beenHit] == 20) {
    newNumAsteroids += 1;
  } else {
    newNumAsteroids -= 1;
  }
  
  PVector[] tempLocation = new PVector[newNumAsteroids];
  PVector[] tempDirection = new PVector[newNumAsteroids];
  PShape[] tempShape = new PShape[newNumAsteroids];
  int[] tempSize = new int[newNumAsteroids];
  
  int ii = 0;
  if (asteroidSize[beenHit] == 30 || asteroidSize[beenHit] == 20) { // the ones that split
    for (int i=0; i<numAsteroids; i++) {
      if (i == beenHit) {i++;}
      tempLocation[ii] = asteroidLocation[i];
      tempDirection[ii] = asteroidDirection[i];
      tempShape[ii] = asteroidShape[i];
      tempSize[ii] = asteroidSize[i];
      ii++;
    }
    asteroidLocation = tempLocation;
    asteroidDirection = tempDirection;
    asteroidShape = tempShape;
    asteroidSize = tempSize;
  
    createAsteroid("small", ii, newX, newY);
    ii++;
    createAsteroid("small", ii, newX, newY); 
  } else {  // is a small asteroid - remove it from the arrays
    for (int i=0; i<=newNumAsteroids; i++) {
      if (i == beenHit) {i++;}
      tempLocation[ii] = asteroidLocation[i];
      tempDirection[ii] = asteroidDirection[i];
      tempShape[ii] = asteroidShape[i];
      tempSize[ii] = asteroidSize[i];
      ii++;
    }
    asteroidLocation = tempLocation;
    asteroidDirection = tempDirection;
    asteroidShape = tempShape;
    asteroidSize = tempSize;
  }

  numAsteroids = asteroidLocation.length;
  
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

PVector keepOnScreen(PVector coord){
/**************************************************************
* Function: keepOnScreen()

* Parameters: a PVector

* Returns: the PVector that has been corrected to stay on the screen)

* Desc: Takes a PVector parameter (like the coords of the ship or an asteroid).
        Tests to see if any of the coordinated have reached a screen boundary
        and if they have, changes the coordinates to be on the other side of the 
        window.
***************************************************************/

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

void drawShip() {
  pushMatrix();
  translate(shipLocation.x, shipLocation.y);
  rotate(shipHeading);
  shape(ship);
  popMatrix();
}

void drawShots() {
   // update the position of the shot
   // and then draw it
   // note although the shotLocations disappear from the screen they are in memory forever
   // we should probably delete them after a period of time
   for (int i=0; i < shotLocations.size(); i++) {
     shotLocations.get(i).add(shotVelocitys.get(i));
     circle(shotLocations.get(i).x, shotLocations.get(i).y, 3);
   }
}

void drawAsteroids() {
  //check to see if asteroid is not already destroyed
  //otherwise draw at location 
  //initial direction and location should be randomised
  //also make sure the asteroid has not moved outside of the window

   for (int i = 0; i < numAsteroids; i++) {
     asteroidLocation[i].add(asteroidDirection[i]);
     asteroidLocation[i] = keepOnScreen(asteroidLocation[i]);
     
     pushMatrix();
     translate(asteroidLocation[i].x, asteroidLocation[i].y);
     shape(asteroidShape[i]);
     popMatrix();
   }
}

void collisionDetection() {
  //check if shotLocations have collided with asteroid
  //check if ship as collided with asteroid
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      sUP=true;
    }
    if (keyCode == DOWN) {
      sDOWN=true;
      testAsteroidBreak(0);
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



// Left down here as a template
/**************************************************************
* Function: myFunction()

* Parameters: None ( could be integer(x), integer(y) or String(myStr))

* Returns: Void ( again this could return a String or integer/float type )

* Desc: Each funciton should have appropriate documentation. 
        This is designed to benefit both the marker and your team mates.
        So it is better to keep it up to date, same with usage in the header comment

***************************************************************/
