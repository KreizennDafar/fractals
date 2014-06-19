
 //sketch for nunchuck-over-arduino and GLSL
 //ctrl+shit+R to run fullscreen
 //press X for calibrating
import processing.serial.*; // importation de la librairie de communication serie

Serial maConnection; // Crée un objet de communication série
Controls ct;

PShader[] shaders;
float resfact;
float zoomLvl = 0.;
float sensibilite = 5; //le plus grand le plus sensible

//pour shader program
float mousex = 0.; 
float mousey = 0.5;
float centrex = 0.;
float centrey = 0.;

int currentshader = 0;int nbshaders = 6;
float current_time = 0;
float previoustime = 0;
float previouschangetime = 0;
float tdelta;

void setup() {
  size(displayWidth, displayHeight, P2D);
  resfact = min(width,height);
  noStroke();
  
  ct = new Controls();
  
    String NomDuPort = Serial.list()[0]; // récupère la première interface serie trouvée
    println("connection a "+NomDuPort);
    maConnection = new Serial(this, NomDuPort, 9600);
  
  shaders = new PShader[nbshaders];  
  shaders[0] = loadShader("shader1.glsl");
  shaders[1] = loadShader("shader2.glsl");
  shaders[2] = loadShader("shader3.glsl");
  shaders[3] = loadShader("shader4.glsl");
  shaders[4] = loadShader("shader5.glsl");
  shaders[5] = loadShader("shader6.glsl");
  
  for(int i=0;i<nbshaders;i++){
    shaders[i].set("resolution", float(width), float(height));
    shaders[i].set("time", 0.);
  }
}

void draw() {
  
  if(frameCount == 63) ct.calibrate(); //besoin d'un délai
  //if(frameCount == 100) println(mousex,mousey);
  //if(frameCount%30 ==0) println(tdelta);
  
  //mise à jour hotloge
  previoustime = current_time;
  current_time = millis() / 1000.0;
  tdelta = current_time - previoustime;
  
  //uniforms et controles
  shaders[currentshader].set("time",current_time );
  
  ct.update();
  
  shaders[currentshader].set("mouse", mousex,mousey);
  if(currentshader<=3){
    shaders[currentshader].set("centre", centrex,centrey);
    shaders[currentshader].set("zoom", pow(4., -zoomLvl));
  }
  
  shader(shaders[currentshader]);
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
  
  input_x = 50*tdelta*sensibilite*map(input_x,-100,100,-0.001,0.001);
  input_y = 50*tdelta*sensibilite*map(input_y,-100,100,-0.001,0.001);
  
  if(boutonC){ //bouton pressé
      zoomLvl = 0;
      mousex = 0;
      mousey = 0.5;
      if(previouschangetime<current_time-0.5){
        currentshader = currentshader<nbshaders-1?currentshader+1:0;
        previouschangetime = current_time;
      }
  }
  
  if(boutonZ){
   zoomer();
  }
  
  if(!boutonZ && !boutonC){
    mousex += ct.input_x;
    mousey += ct.input_y;
    
    //mousex = constrain(mousex,-1,1);
    //mousey = constrain(mousey,-1,1);
  }
 } //fin update 
 void calibrate(){ //appelé au début, ou press X
   ZERO_joyX = joyX;
   ZERO_joyY = joyY; 
   mousex = 0;
   mousey = 0.5;
 }
 void zoomer(){
  
   zoomLvl += 10*input_y;
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

