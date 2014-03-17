
 //simple sketch for nunchuck-over-arduino and GLSL
 //press X for calibrating
import processing.serial.*; // importation de la librairie de communication serie

Serial maConnection; // Crée un objet de communication série
int joyX,joyY;
int pjoyX,pjoyY; //previous values for smoothing
float accelX,accelY,accelZ;
boolean boutonZ,boutonC;

int ZERO_joyX = 0;
int ZERO_joyY = 0;

PShader shader;
float resfact;
float zoomLvl = 0.;

float mousexr = 0.; //coordonnées rectifiées
float mouseyr = 0.;
float mousexs = 0.; //adapté au zoom
float mouseys = 0.;
float centrex = 0.; //centre
float centrey = 0.;

void setup() {
  size(displayWidth, displayHeight, P2D);
  resfact = min(width,height);
  noStroke();
  
    String NomDuPort = Serial.list()[0]; // récupère la première interface serie trouvée
    println("connection a "+NomDuPort);
    maConnection = new Serial(this, NomDuPort, 9600); // création de la connexion série
    
  shader = loadShader("ssfeg.glsl");
  //shader = loadShader("simple_Mandelbrot.glsl");
  //shader = loadShader("example3.glsl");
  
  shader.set("resolution", float(width), float(height));
  shader.set("time", 0.);  
}

void draw() {
  //mise à jour uniforms
  shader.set("time", millis() / 1000.0);
  //controles
  if(keyPressed){
     if(key=='x'){ //press X for calibrating
      ZERO_joyX = joyX;//input_x;
      ZERO_joyY = joyY;
     } 

    }
  
  float in_x = float(joyX-ZERO_joyX);if(abs(in_x)<3) in_x=0;
  float in_y = float(joyY-ZERO_joyY);if(abs(in_y)<3) in_y=0;
  
  in_x = map(in_x,-100,100,-1,1);
  in_y = map(in_y,-100,100,-1,1);
  
  //commenter si zoom non défini
  /*mousexs = in_x*pow(4.,-zoomLvl)+centrex;
  mouseys = in_y*pow(4.,-zoomLvl)+centrey;*/
  
  //décommenter idem
  shader.set("mouse", in_x,in_y);
  
  /*mousexr = (mouseX*2.-width) / resfact;
  mouseyr = -(mouseY*2.-height) / resfact;
  mousexs = mousexr*pow(4.,-zoomLvl)+centrex;
  mouseys = mouseyr*pow(4.,-zoomLvl)+centrey;*/
  //shader.set("mouse", mousexs,mouseys);
  
  if(boutonC){ //bouton pressé
    zoomer(true);  
  }else{ //bouton relâché
    
  }
  if(boutonZ){
    zoomer(false); 
  }

  //commenter uniforms non nécessaires
  shader.set("centre", centrex,centrey);
  shader.set("zoom", pow(4., -zoomLvl));
  
  shader(shader);
  rect(0, 0, width, height); 
 
}
void zoomer(boolean test){
  
  if(test){
    if(zoomLvl <10.){
      zoomLvl += 0.04;
      /*centrex += 0.07*(mousexs-centrex);
      centrey += 0.07*(mouseys-centrey);*/
    }else{
     zoomLvl = 10.;
    } 
  }else{
    if(zoomLvl >-0.5){
      zoomLvl -= 0.07;
      /*centrex += 0.07*(mousexs-centrex);
      centrey += 0.07*(mouseys-centrey);*/
    }else{
     zoomLvl = -0.5;
    }   
  }
  
}
void serialEvent (Serial port) { // si des données arrivent par la connexion série
      try{
          String retour=port.readStringUntil('\n'); // lit la donnée jusqu'à la fin de ligne
          if (retour != null) { //si le retour n'est pas vide
              pjoyX = joyX;
              pjoyY = joyY;
              String[] tab_retour = split(retour,"OO");
              joyX = int(tab_retour[0]);
              joyY = -int(tab_retour[1]);
              accelX = float(tab_retour[2]);
              accelY = float(tab_retour[3]);
              accelZ = float(tab_retour[4]);
              boutonZ = boolean(int(tab_retour[5]));
              boutonC = boolean(int(tab_retour[6]));      
          }
      } catch(Exception e){
        //éventuelle gestion d'erreur
      }
}
