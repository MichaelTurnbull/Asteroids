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

void createAsteroid(String smallMediumOrLarge, int index){
  // when starting position is not specified, run the function with a
  // random starting position
  createAsteroid(smallMediumOrLarge, index, random(width), random(height));
}

void createAsteroid(String smallMediumOrLarge, int index, float x, float y) {
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

  asteroidLocation[index] = new PVector(x, y);
  asteroidDirection[index] = PVector.random2D();
  asteroidShape[index] = generateAsteroidShape(size, numSides);
  asteroidSize[index] = size;
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

void breakAsteroid(int index){
  // Breaks up the asteroid at which is at 'index' in the asteroid arrays

    if (index == 0 && asteroidLocation.length == 1) { // if it's the last asteroid
    // Reset asteroids
    // Increase asteroid speed
    // Increase score
    return;
  } else {
    // Break the asteroid into two smaller asteroids
    // If it's already the smallest sized asteroid, remove it
    // Come up with a breaking up animation

    // The position two new asteroids will be created
    float newX = asteroidLocation[index].x;
    float newY = asteroidLocation[index].y;
    
    // This block determines the size for the new asteroid arrays
    // If the asteroid is medium or large, it will split into two smaller
    // asteroids, so the size of the arrays will need to increase by 1.
    // If the asteroid is small, then it will be removed so the size of 
    // the arrays is reduced by 1.
    int newNumAsteroids = numAsteroids;
    if (asteroidSize[index] == 30 || asteroidSize[index] == 20) {
      newNumAsteroids += 1;
    } else {
      newNumAsteroids -= 1;
    }
    
    // temporary arrays to store the asteroids
    PVector[] tempLocation = new PVector[newNumAsteroids];
    PVector[] tempDirection = new PVector[newNumAsteroids];
    PShape[] tempShape = new PShape[newNumAsteroids];
    int[] tempSize = new int[newNumAsteroids];
    
    int ii = 0;
    if (asteroidSize[index] == 30) { // the ones that split
      for (int i=0; ii<newNumAsteroids-2; i++) {  // -2 because the last two are about to be created
        if (i == index) {i++;}
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
    
      createAsteroid("medium", ii, newX, newY);
      ii++;
      createAsteroid("medium", ii, newX, newY); 
    } else if (asteroidSize[index] == 20) { // the ones that split
      for (int i=0; ii<newNumAsteroids-2; i++) {  // -2 because the last two are about to be created
        if (i == index) {i++;}
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
      for (int i=0; ii<newNumAsteroids; i++) {
        // loop over the asteroids and add them to the new temporary arrays
        // skipping the asteroid to be removed
        if (i == index) {i++;}  // skip the asteroid to be removed
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
   
   for (int i=0; i < shotLocations.size(); i++) {
     shotLocations.get(i).add(shotVelocitys.get(i));
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
  for (int i = 0; i < numAsteroids; i++) { //check if ship as collided with asteroid
    //println("asteroidLocation[" + i + "]:", asteroidLocation[i]);
    if (pow(shipLocation.x - asteroidLocation[i].x, 2) + 
        pow(shipLocation.y - asteroidLocation[i].y, 2) <= 
        pow(10 + asteroidSize[i], 2)) {
      gameOver();
    }
  }

  for (int i = 0; i < numAsteroids; i++) { //check if shotLocations have collided with asteroid
    for (int j = 0; j < shotLocations.size(); j++) {
      //println("asteroidLocation[" + i + "]:", asteroidLocation[i]);
      if (pow(shotLocations.get(j).x - asteroidLocation[i].x, 2) + 
          pow(shotLocations.get(j).y - asteroidLocation[i].y, 2) <= 
          pow(3 + asteroidSize[i], 2)) {

      //if((abs(shotLocations.get(j).x - asteroidLocation[i].x)<45) && (abs(shotLocations.get(j).y - asteroidLocation[i].y)<45)){  
        breakAsteroid(i);
        shotLocations.remove(j);
        shotVelocitys.remove(j);
      }
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
      breakAsteroid(int(random(0, numAsteroids-1)));
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