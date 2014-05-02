
 //simple sketch for nunchuck-over-arduino and GLSL
 //ctrl+shit+R to run fullscreen
 //press X for calibrating
import processing.serial.*; // importation de la librairie de communication serie

Serial maConnection; // Crée un objet de communication série
Controls ct;

PShader shader;
float resfact;
float zoomLvl = 0.;

//pour shader program
float mousex = 0.; 
float mousey = 0.;
float centrex = 0.;
float centrey = 0.;

void setup() {
  size(displayWidth, displayHeight, P2D);
  resfact = min(width,height);
  noStroke();
  
  ct = new Controls();
  
    String NomDuPort = Serial.list()[0]; // récupère la première interface serie trouvée
    println("connection a "+NomDuPort);
    maConnection = new Serial(this, NomDuPort, 9600); // création de la connexion série
    
  shader = loadShader("sfractal.glsl");
  
  shader.set("resolution", float(width), float(height));
  shader.set("time", 0.);
    
}

void draw() {
  
  if(frameCount == 100) ct.calibrate(); //besoin d'un délai
  if(frameCount == 200) println(mousex,mousey);
  //mise à jour uniforms
  shader.set("time", millis() / 1000.0);

  ct.update();
  
  shader.set("mouse", mousex,mousey);
  shader.set("centre", centrex,centrey);
  shader.set("zoom", pow(4., -zoomLvl));
  
  shader(shader);
  rect(0, 0, width, height); 
 
}

void serialEvent (Serial port) { // si des données arrivent par la connexion série
      try{
        ct.getValues(port);     
      } catch(Exception e){
        //éventuelle gestion d'erreur
      }
}

class Controls{
  float input_x,input_y; // valeurs finale joystick
  int joyX,joyY; //valeurs avant mapping
  //int pjoyX,pjoyY; //valeurs précédentes pour smoothing
  float accelX,accelY,accelZ;
  boolean boutonZ,boutonC;

  int ZERO_joyX = 0;
  int ZERO_joyY = 0; 
  
 Controls(){
  joyX = 0;
  joyY = 0;
  input_x = input_y = 0;
 }
 void update(){ //appelé à cahque frame
  if(keyPressed){
     if(key=='x'){ //press X for calibrating
       calibrate();
     } 
   }
   
  input_x = float(joyX-ZERO_joyX);if(abs(input_x)<3) input_x=0;
  input_y = float(joyY-ZERO_joyY);if(abs(input_y)<3) input_y=0;
  
  input_x = map(input_x,-100,100,-0.01,0.01); //sensibilité ici
  input_y = map(input_y,-100,100,-0.01,0.01);
  
  if(boutonC){ //bouton pressé
      zoomLvl = 0;
      //...
  }
  
  if(boutonZ){
   zoomer();
  }
  
  if(!boutonZ && !boutonC){
    mousex += ct.input_x;
    mousey += ct.input_y;
    
    mousex = constrain(mousex,-1,1);
    mousey = constrain(mousey,-1,1);
  }
 } //fin update 
 void calibrate(){ //appelé au début, ou press X
   ZERO_joyX = joyX;
   ZERO_joyY = joyY; 
   mousex = 0;
   mousey = 0;
 }
 void zoomer(){
  
   zoomLvl += 15*input_y;
   zoomLvl = constrain(zoomLvl,0,10);
  
  }
 void getValues(Serial port){ //appelé automatiquement
   String retour=port.readStringUntil('\n'); // lit la donnée jusqu'à la fin de ligne
        if (retour != null) { //si le retour n'est pas vide
              /*pjoyX = joyX;
              pjoyY = joyY;*/
              String[] val = split(retour,"OO");
              joyX = int(val[0]);
              joyY = int(val[1]); //inverser ou non
              accelX = float(val[2]);
              accelY = float(val[3]);
              accelZ = float(val[4]);
              boutonZ = boolean(int(val[5]));
              boutonC = boolean(int(val[6]));  
         }
  }
} //fin classe
