
#define encoderPinOUT 2
#define encoderPinOUT_1 3

long wait_time;

/////////////////////////////////
void setup() {
  // put your setup code here, to run once:
  pinMode(encoderPinOUT, OUTPUT);  // pin 2 for sync pulse
  pinMode(encoderPinOUT_1, OUTPUT);  // pin 3 for sync pulse
  
  randomSeed(analogRead(0));
  
  //Serial.begin(9600);
  //Serial.setTimeout(5);

  delay(500);
  
}



/////////////////////////////////
void loop() {
  // put your main code here, to run repeatedly:

  digitalWrite(encoderPinOUT, HIGH);
  digitalWrite(encoderPinOUT_1, HIGH);
  delay(500);
  
  digitalWrite(encoderPinOUT, LOW);
  digitalWrite(encoderPinOUT_1, LOW);
  wait_time = random(1000,3500);
  
  //Serial.println(wait_time);
  
  delay(wait_time);
  
}
