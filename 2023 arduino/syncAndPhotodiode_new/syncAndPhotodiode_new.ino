//#include <Event.h>
//#include <Timer.h>

#define photodiodePin 0        // PhotoDiode pin - analogue
#define syncPin 1             // digital pin of sync

/*
int photodiodePin = 0;    
int syncPin = 0;
*/

int photodiodeVal;
int syncVal;

void setup()

{
  pinMode(photodiodePin, INPUT);   // PhotoDiode
  pinMode(syncPin, INPUT);   // digital pin of sync
  
  Serial.begin(250000);          //  setup serial
  delay(500);
}



void loop()

{

  photodiodeVal = analogRead(photodiodePin);    // read the input pin
  syncVal = digitalRead(syncPin);

  Serial.println(photodiodeVal);
  //Serial.print("\t");
  //Serial.println(syncVal);

  //delay(0);
}
