import processing.serial.*; //imports serial library to communicate with Arduino
import cc.arduino.*; //imports all of the arduino library

Arduino arduino; //initializes a variable named "arduino"
int analogPin1 = 1; //pin for pot-player 1
int analogPin2 = 2; //pin for pot-player 2
int pushButton = 9; //pin 9 for push button
int buttonState = 0; //state of the push button

int ballSize = 13; //This determines how big the pong is

//This determines how big the game screen is
int ScreenHeight = 500;
int ScreenWidth = 1000;

//player one paddle position 
int xPlayer1 = 2 * ballSize;
int yPlayer1 = ScreenHeight / 2;
//player two paddle position
int xPlayer2 = ScreenWidth - 4 * ballSize;
int yPlayer2 = yPlayer1;

//variables that keep track of player scores
int scorePlayer1 = 0;
int scorePlayer2 = 0;

//paddle dimentions
int paddleHeight = 5 * ballSize;
int paddleWidth = 2 * ballSize;

//this variable determines the middle
int middle = ScreenWidth/2 - 13;

//ball position
float xBall = middle;
float yBall = ScreenHeight/2;

float xBallMouv = randomXBallMouv();
float yBallMouv = randomYBallMouv();

//how fast the ball moves
int ballSpeed = 10;

PFont rosesAreFF0000; //uses font rosesAreFF0000

boolean start = false; //the game doesn't start right away

void setup()
{
  surface.setSize(ScreenWidth,ScreenHeight);// equivalent to size();
  rosesAreFF0000 = createFont("RosesareFF0000.ttf", paddleHeight); // parameters are name and size of the font
  textFont(rosesAreFF0000); //makes it so that the font is used in all subsequent calls to text() function
  arduino = new Arduino(this, Arduino.list()[0], 57600); //This refers to the index in the list of available usb connections
  arduino.pinMode(pushButton, Arduino.INPUT); //sets the push button pin as input
  stroke(255); //changes the color of the highlights
}

void draw()
{
    drawField(); //calls function that draws the stage
    playersMovements(); //calls function that deals with ball behaviour 
  //game starts if button is pressed
  if (start == true){
    ballMouvements();
  }
  else if (start == false) {
    xBall = middle;
    yBall = ScreenHeight/2;
  }
  //This decides which player won the match
  if (scorePlayer1 >= 5){
    background(0);
    text("Player 1 won!!!", middle - 4 * paddleHeight - paddleHeight / 2, ScreenHeight/2);
    start = false;
  }
  if (scorePlayer2 >= 5){
    background(0);
    text("Player 2 won!!!", middle - 4 * paddleHeight - paddleHeight / 2, ScreenHeight/2);
    start = false;
  }
  if (arduino.digitalRead(pushButton) == Arduino.HIGH) {
    if (buttonState == 0) {
      scorePlayer1 = 0;
      scorePlayer2 = 0;
      start = false;
      buttonState++;
    }
    else {
      start = true;
      buttonState--;
    }
  }
}

void playersMovements()
{ 
  yPlayer1 = int ((ScreenHeight - 2 * ballSize) * arduino.analogRead(analogPin1) / 1023); //1023 max value returned by analogRead);
  yPlayer2 = int ((ScreenHeight - 2 * ballSize) * (arduino.analogRead(analogPin2) - 47) / 936); // Because potentiometer...
  verifications(); //checks everything is in the right place
  rect(xPlayer1, yPlayer1, paddleWidth, paddleHeight); //size and location of player 1
  rect(xPlayer2, yPlayer2, paddleWidth, paddleHeight); //size and location of player 2
}

void ballMouvements()
{
  rect(xBall, yBall, ballSize, ballSize); //position and size of the ball
  xBall += xBallMouv * ballSpeed;//defines the horizontal ball speed
  yBall += yBallMouv * ballSpeed;//defines the Vertical ball speed
  ballOutBound(); //counts up player points if won?
  ballCollision(); //reaction to ball hitting pattles 
  
}

void drawField()
{
 background(0,100,0); //background color
 
 for (int i = ballSize; i < ScreenHeight; i = i + ballSize)
 {
   fill(150);
   rect(middle, i, ballSize, ballSize); //draws square line in the middle
 }
 fill(255);
 rect (0,0, ScreenWidth + 5, ballSize); // draws top line
 rect (0, ScreenHeight - ballSize, ScreenWidth + 5, ballSize); // draws bottom line
 
 text(scorePlayer1, middle - paddleHeight , ballSize * 30 / 4); //display the score for player 1
 text(scorePlayer2, middle + paddleHeight - 2 * ballSize, ballSize * 30 / 4); //display the score for player 2
 
}
// random horizontal ball movement
float randomXBallMouv(){
  float tmp = 0;
  while (tmp > -0.25f && tmp < 0.25f || tmp > 0.65 || tmp < -0.65)
    tmp = random(3) - 1;
  return tmp;
}
// random vertical ball movement 
float randomYBallMouv(){
  float tmp = 0;
  while (tmp > -0.2f && tmp < 021f)
    tmp = random(3) - 1;
  return tmp;
}

//counter for balls
void ballOutBound()
{
  if (xBall < 0 ){
    scorePlayer2++;
    resetBall();
  }
  else if (xBall + ballSize > ScreenWidth){
    scorePlayer1++;
    resetBall();
  }
}

void resetBall(){
    xBall = middle;
    yBall = ScreenHeight/2;

    xBallMouv = randomXBallMouv();
    yBallMouv = randomYBallMouv();
    
    ballSpeed = 10;
}

void ballCollision()
{
  if (collisionBallPlayer1() || collisionBallPlayer2())
    {
      xBallMouv = -xBallMouv;
      ballSpeed += 3;
    }
    if (collisionBallUpperWall() || collisionBallDownWall())
    {
      yBallMouv = -yBallMouv;
    }
    while (collisionBallPlayer1()){
    if (xBall < xPlayer1 + paddleWidth)
      xBall += 1;
    if (xBall + ballSize > xPlayer1)
      xBall += 1;
  }
  while (collisionBallPlayer2()){
    if (xBall < xPlayer2 + paddleWidth)
      xBall -= 1;
    if (xBall + ballSize > xPlayer2)
      xBall -= 1;
  }
  while (collisionBallUpperWall()){
    if (yBall < yPlayer2 + paddleHeight)
      yBall += 1;
    if (yBall + ballSize > yPlayer2)
      yBall += 1;
  }
  while (collisionBallDownWall()){
    if (yBall < yPlayer2 + paddleHeight)
      yBall -= 1;
    if (yBall + ballSize > yPlayer2)
      yBall -= 1;
  }
}

boolean collisionBallUpperWall(){
   return (yBall < ballSize);
}

boolean collisionBallDownWall(){
  return (yBall + ballSize > ScreenHeight - ballSize);
}

boolean collisionBallPlayer1(){
  return !(xBall > xPlayer1 + paddleWidth || xBall + ballSize < xPlayer1 ||
           yBall > yPlayer1 + paddleHeight || yBall + ballSize < yPlayer1);
}

boolean collisionBallPlayer2(){
  return !(xBall > xPlayer2 + paddleWidth || xBall + ballSize < xPlayer2 ||
           yBall > yPlayer2 + paddleHeight || yBall + ballSize < yPlayer2);
}

//ensures everything is verified to be in the right place
void verifications()
{
  int minBound = ballSize;
  int maxBound = ScreenHeight - paddleHeight - ballSize;
  if (yPlayer1 < minBound)
  {
    yPlayer1 = minBound;
  }
  if (yPlayer1 > maxBound)
  {
    yPlayer1 = maxBound;
  }
  if (yPlayer2 < minBound)
  {
    yPlayer2 = minBound;
  }
  if (yPlayer2 > maxBound)
  {
    yPlayer2 = maxBound;
  }
}
