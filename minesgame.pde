import java.util.concurrent.ThreadLocalRandom;
import processing.sound.*;
SoundFile gemsound;
SoundFile bombsound;
//defining stuff
int[][] board = new int [5][5];
int mineX, mineY;
float cashout = 0;
int minesClicked = 0;
float betAmount = 0;
float balance = 1000;
int mineAmount = 1;
float multiplier =1;
float lastCashout;
double unroundedCashout;
boolean started = false;
boolean cashoutPopup = false;
boolean lost = false;
int time = millis();
int scale=0;
PImage gem;
PImage bomb;
int[][] gemScales = new int[5][5];

//button variables
int betButtonX = 100;
int betButtonY = 650;
int betButtonHeight = 40;
int betButtonWidth = 80;

int cashButtonX = 200;
int cashButtonY = 650;
int cashButtonHeight = 40;
int cashButtonWidth = 80;


//image icons



void setup() {
  size(700, 700);
  gem = loadImage("gem.png");
  bomb =loadImage("bomb.png");
  gemsound = new SoundFile(this, "gemsound.mp3");
  bombsound = new SoundFile(this, "bombsound.mp3");
  imageMode(CENTER);
  //intializing gems scale for animations
  for (int i = 0; i < gemScales.length; i++) {
    for (int j = 0; j < gemScales[i].length; j++) {
      gemScales[i][j] = 0; // set to 0
    }
  }
}

void draw() {
  background(128, 128, 128);
  textSize(20);
  fill(255);

  //cashout and balance text

  textAlign(CORNER);
  text(("Balance:" + balance), 400, 650);
  text(("Cashout:" + cashout), 400, 670);



  //bet button
  if (started == false) {
    fill(0, 255, 0);
  } else {
    fill(211, 211, 211);
  }
  textAlign(CORNER);
  rect(betButtonX, betButtonY, betButtonWidth, betButtonHeight);
  fill(0);
  text("Place Bet", betButtonX, betButtonY+20);
  //cashout button
  if (started == true) {
    fill(0, 255, 0);
  } else {
    fill(211, 211, 211);
  }
  rect(cashButtonX, cashButtonY, cashButtonWidth, cashButtonHeight);
  fill(0);
  text("Cashout", cashButtonX, cashButtonY+20);

  //bet amount
  text("Bet Amount", betButtonX, betButtonY-40);
  text(betAmount, betButtonX, betButtonY-20);

  //plus sign
  //x is between 180-205
  //y is between 605-630
  rect(betButtonX+90, betButtonY-35, 5, 15);
  rect(betButtonX+85, betButtonY-30, 15, 5);

  //minus sign

  //x between 60-80
  rect(betButtonX-35, betButtonY-30, 15, 5);


  //game board creation
  for (int i=0; i<board.length; i++) {
    for (int j=0; j<board[i].length; j++) {
      if (board[i][j] == 1) {//mine space
        fill(54, 69, 79);
        rect(50+100*i, 50+100*j, 100, 100);
        image(bomb, 100+100*i, 100+100*j);
      } else if (board[i][j] == 2) {//mine
        fill(54, 69, 79); // safe space
        rect(50+100*i, 50+100*j, 100, 100);
        if (gemScales[i][j] < 64) {
          image(gem, 100 + 100 * i, 100 + 100 * j, gemScales[i][j], gemScales[i][j]);
          gemScales[i][j] += 4; // Increase the scale
        } else {
          image(gem, 100 + 100 * i, 100 + 100 * j); // Draw gem at full size
        }
      } else {
        fill(169, 169, 169);
        rect(50+100*i, 50+100*j, 100, 100);
      }
    }
  }

  //win popup
  if (cashoutPopup == true) {
    fill(255);
    int rectX = width/2 - 150;
    int rectY = height/2 - 50;
    rect(rectX, rectY, 300, 100);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(30);
    text("You Cashed Out $" + lastCashout, width/2, height/2);
  }

  //lose popup
  if (balance<10 && cashoutPopup != true && started!=true ) {
    fill(255);
    int rectX = width/2 - 150;
    int rectY = height/2 - 50;
    rect(rectX, rectY, 300, 100);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(40);
    text("You Lose!", width/2, height/2);
  }
}


void mousePressed() {
  int x = (mouseX-50)/100;
  int y = (mouseY-50)/100;

  //bet adjustment
  if (started == false) {
    if (mouseX>=180 && mouseX<=205 && mouseY<=630 && mouseY>=605 && betAmount<=balance-10) {
      betAmount+=10;
    }
    if (mouseX>=60 && mouseX<=80 && mouseY<=630 && mouseY>=605 && betAmount>0) {
      betAmount-=10;
    }
  } else {
  }

  //placing bet
  if (started==false) {
    if (((betButtonX + betButtonWidth) >= mouseX)  && (mouseX>=betButtonX) && ((betButtonY + betButtonHeight)>=mouseY) && (mouseY>=betButtonY) && betAmount <=balance) {
      print("clicked");
      cashoutPopup = false;
      balance-=betAmount;
      started =true;
      //reset the board
      for (int i = 0; i < board.length; i++) {
        for (int j = 0; j < board[i].length; j++) {
          board[i][j] = 0;
        }
      }

      //mine position
      mineX = ThreadLocalRandom.current().nextInt(0, 5);
      mineY = ThreadLocalRandom.current().nextInt(0, 5);
    }
  } else {
  }




  //game is being played
  if (started == true) {
    //cashing out
    if (((cashButtonX + cashButtonWidth) >= mouseX)  && (mouseX>=cashButtonX) && ((cashButtonY + cashButtonHeight)>=mouseY) && (mouseY>=cashButtonY)) {
      lastCashout = cashout;
      cashoutPopup = true;
      balance+= Math.round(cashout * 100.0) / 100.0;
      started = false;
      multiplier = 1;
      cashout = 0;
      minesClicked = 0;
    }
    if (mouseX<=550 && mouseY<550) {
      //hitting a mine
      if (x == mineX && y == mineY ) {
        bombsound.play();
        board[x][y] = 1; // Mine
        minesClicked = 0;
        multiplier = 1;
        cashout = 0;
        started = false;

        //hitting gems
      } else if (board[x][y]!=2) {
        gemScales[x][y]=0; //set animation scale to zero
        gemsound.play(); // play sound
        board[x][y] = 2; // Safe box
        minesClicked = minesClicked+1; //increased mines clicked
        //calculating multipliers

        if (mineAmount == 1 && minesClicked <=11) {
          multiplier = multiplier*1.05;
          unroundedCashout = betAmount * multiplier;
          cashout = Math.round(unroundedCashout * 100.0) / 100.0;
        } else if (mineAmount == 1 && minesClicked >11 && minesClicked <=20) {
          multiplier = multiplier*1.1;
          unroundedCashout = betAmount * multiplier;
          cashout = Math.round(unroundedCashout * 100.0) / 100.0;
        } else if (mineAmount == 1 && minesClicked >20 && minesClicked<24) {
          multiplier = multiplier*1.45;
          unroundedCashout = betAmount * multiplier;
          cashout = Math.round(unroundedCashout * 100.0) / 100.0;
        }
        //all safe spots are clicked
        else if (mineAmount == 1 && minesClicked==24) {
          multiplier = multiplier*2;
          unroundedCashout = betAmount * multiplier;
          cashout = Math.round(unroundedCashout * 100.0) / 100.0;
          balance+=cashout;
          started = false;
          multiplier = 1;
          cashout = 0;
          minesClicked = 0;
        }
      } else {
      }
    } else {
    }
  }
}
