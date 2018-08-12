import java.util.*;

int screen = 0;
ArrayList<Ball> ballArray = new ArrayList<Ball>();


final int ballSpeed = 5;
final int ballCount = 1000;
final int mutation = 10;
final int tickRate = 144;
final int genInstInc = 2;
int instructionCount = tickRate;


int ballOriginY, ballOriginX, finX1, finY1, finXL, finYL, topFitness;
int generation = 1;
int counter = instructionCount + 1;

boolean simFinished = false;
// Genetics ----------------------------------------------

class Ball {
  boolean finished = false;
  int x,y;
  int instructionCounter = 0;
  ArrayList<Integer> instructions = new ArrayList<Integer>();
  Ball (int x, int y, ArrayList<Integer> instructions) {
    this.x = x;
    this.y = y;
    this.instructions = instructions;
  }

  void move() {
      int inst = instructions.get(instructionCounter);

      switch (inst) {
        case 1: if (0 <= y - ballSpeed) y -= ballSpeed; break;
        case 2: if (x + ballSpeed <= width) x += ballSpeed; break;
        case 3: if (y + ballSpeed <= height) y += ballSpeed; break;
        case 4: if (0 <= x - ballSpeed) x -= ballSpeed; break;
      }

      instructionCounter++;
      
      if (x > finX1 && y > 0 && x < width && y < finYL) {
        simFinished = true;
        this.finished = true;
      }
    }

  Ball mutate(int percent) {
    ArrayList<Integer> is = new ArrayList<Integer>(instructions);

    for (int i = 0; i < is.size(); i++) {
      if (random(100) < percent) {
        is.set(i, (int) random(4) + 1);
      }
    }

    if (generation % genInstInc == 0) {
      is.addAll(randomInstructions(tickRate / 2));
    }

    return new Ball(ballOriginX, ballOriginY, is);
  }

  //Max hypotenuse distance - Distance to top right corner 
  int getFitness() {
    return ((int) sqrt(sq(width) + sq(height))) - ((int) (sqrt(sq(abs(x - width)) + sq(y))));
  }
  
  String toString() {
    return this.instructions.toString();
  }

}

Ball crossover(Ball b1, Ball b2) {
  ArrayList inst1, inst2, sub1, sub2, output = new ArrayList<Integer>(); 
  
  inst1 = b1.instructions;
  inst2 = b2.instructions;

  int p = inst1.size() / 2;

  sub1 = new ArrayList<Integer>(inst1.subList(0, p));
  sub2 = new ArrayList<Integer>(inst2.subList(p, inst2.size()));

  output.addAll(sub1);
  output.addAll(sub2);
  
  return new Ball(ballOriginX, ballOriginY, output);
}

ArrayList<Integer> randomInstructions(int length) {
  ArrayList<Integer> i = new ArrayList<Integer>();

  for (int y = 0; y < length; y++) {
    i.add(new Integer((int) random(4) + 1));
  }

  return i;
}

//Sort ball array and then pick the top 4 for pairing
ArrayList<Ball> topFourBalls(ArrayList<Ball> bs) {
  Collections.sort(bs, new Comparator<Ball>() {
    @Override
    public int compare(Ball lhs, Ball rhs) {
      return lhs.getFitness() < rhs.getFitness() ? -1 : (lhs.getFitness() > rhs.getFitness()) ? 1 : 0;
    }
  });

  ArrayList<Ball> b = new ArrayList<Ball>(bs.subList(bs.size() - 5, bs.size() - 1));
  
  topFitness = b.get(3).getFitness();
  
  return b;
}

//Generate a new generation based off the top 4 in the previous generation
ArrayList<Ball> getNewGeneration(ArrayList<Ball> bs, int count) {
  bs = topFourBalls(bs);
  
  ArrayList<Ball> ballArray = new ArrayList<Ball>();
  Ball base1, base2;

  //Get 2 pairs and cross them over to get 2 balls with both characteristics
  base1 = crossover(bs.get(0), bs.get(1));
  base2 = crossover(bs.get(2), bs.get(3));


  for (int i = 0; i < count; i++) {
    ballArray.add(base1.mutate(mutation));
    ballArray.add(base2.mutate(mutation));
  }

  return ballArray;
}

// Game --------------------------------------------------
void setup() {  
  size(700, 700);
  ballOriginX = width / 2;
  ballOriginY = height - 50;
  finX1 = 8 * width/9;
  finY1 = 0;
  finXL = width/9;
  finYL = height/9;
  
  frameRate(tickRate);

  for (int i = 0; i < ballCount; i++) {
    ballArray.add(new Ball(ballOriginX, ballOriginY, randomInstructions(instructionCount)));
  }
  
}

void draw() {
  if (screen == 0) {
    initScreen();
  } else if (screen == 1) {
    gameScreen();
  }
}

// Screens ------------------------------------------------

void initScreen() {
  background(0);
  textAlign(CENTER);
  
  fill(255);
  text("Click to begin", height/2, width/2);
}

void gameScreen() {
  if (counter <= 1) {
    counter = instructionCount + 1;
    ballArray = getNewGeneration(ballArray, ballCount);
    generation += 1;
    if (generation % genInstInc == 0) {
      instructionCount += tickRate / 2;
    }
  }

  
  background(255);
  textAlign(LEFT);
  fill(0);
  if (generation > 1) {
    text("Top fitness from last generation: " + topFitness, 10, height - 80);
  }
  text("Instructions left: " + (instructionCount - ballArray.get(0).instructionCounter), 10, height - 60);
  text("Instruction Count: " + instructionCount, 10, height -40);
  text("Generation: " + generation, 10, height - 20);
  

  fill(200,50,50);

  //end zone
  fill(color(40,200,40));
  rect(finX1, finY1, finXL, finYL);
  
  if (!simFinished) {
    counter--;
  }
  

  fill(50,200,50);
  line(width/2, 0, width/2, height);
  
  for (int i = 0; i < ballArray.size(); i++) {   
  //Draw and then move each ball
    if (ballArray.get(i).finished || !simFinished) {
      drawBall(ballArray.get(i));
    }
  
    if (!simFinished) {
      ballArray.get(i).move();
    }
  }
}


void drawBall(Ball b) {
  fill(200,50,50);
  ellipse(b.x, b.y, 10, 10);
}

public void mousePressed() {
  if (screen == 0) {
    startGame();
  }
}

void startGame() {
  screen = 1;
}
