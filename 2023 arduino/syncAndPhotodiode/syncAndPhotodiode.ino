int photodiodePin = 0;    
int syncPin = 0;

int photodiodeVal;
int syncVal;
                     




void setup()

{

  Serial.begin(250000);          //  setup serial

}



void loop()

{

  photodiodeVal = analogRead(photodiodePin);    // read the input pin
  syncVal = digitalRead(syncPin);

  Serial.print(photodiodeVal);
  Serial.print("\t");
  Serial.println(syncVal);

}
