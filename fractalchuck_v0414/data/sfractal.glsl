#define PROCESSING_COLOR_SHADER
#define NMAX 20 //3-12-42

uniform vec2 resolution;
uniform float time;
uniform vec2 mouse;
uniform vec2 centre;
uniform float zoom;

//fonctions usuelles
#define PIx2over3 2.09439510239319
#define PI 3.14159265358979
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
vec2 cmult(vec2 z){ //multiplication complexe
	return vec2(z.x*z.x-z.y*z.y, 2.*z.x*z.y);
}
vec2 rotate(vec2 p, float a){
	return vec2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a)); //R*P
}
float ronds(vec2 p) {
	p = mod(p * 15.0, 2.0) - 1.0;
	return 1.-dot(p,p);
}
float mandel(vec2 p){
	vec2 z = vec2(0.,0.);
	for(int i  = 0; i< NMAX; i++){
		z = cmult(z)+p;
	}
	return length(z);
	
}
float sfractal(vec2 pos){ //repeating simple stuff
//fractale simple, répéter des "trucs"
//l'uniform mouse se diffuse dans la définition du gradient et/ou de la transformation itérée
	float c = 0.;//initialiser à 0. pour += , à 1. pour *=
	float dm = length(mouse);
//répéter une formule et une transformation du plan
	for(int i=0;i<NMAX;i++){
	
//1: c = f(p) ou f(p,m)
//on y met ce qu'on veut !

		//quadrillage smooth
		//c += 0.5+0.5*10.*mouse.y*cos(15.*pos.x)*cos(15.*pos.y);
		
		//quadrillage step
		//c += step(0.5,0.5+0.5*cos(15.*pos.x)*cos(15.*pos.y));
		
		//quadrillage fin
		c += abs(0.02/(mod(8.*pos.x,2.)-1.))+abs(0.02/(mod(8.*pos.y,2.)-1.));
		
		//2 lignes
		//c += abs(0.01/(pos.x-0.5))+abs(0.01/(pos.x+0.5));
		
		//double-triple blobs
		//c += 0.2/length(pos-mouse)+0.2/length(-pos-mouse);
		c += 0.2/length(pos-mouse)+0.2/length(rotate(pos,PIx2over3)-mouse)+0.2/length(rotate(pos,-PIx2over3)-mouse);
	
		//spirale 3 branches (diminuer NMAX)
		//c += cos((1.618*length(pos)+3.*atan(pos.y,pos.x)));

		//ronds
		//c += ronds(pos);
		
		//autres ronds
		//c += abs(0.01/(length(pos-vec2(0.2,0.1))-0.5));
		
		//double foyer radiant (diminuer NMAX)
		//c += max(0.,cos(36.*atan(pos.y,pos.x-0.5)))*max(0.,cos(36.*atan(pos.y,pos.x+0.5)));
	
//2: p=f(p) ou p = f(p,m)
	//formules de transformation du plan
		//pos = 2.*dm*rotate(pos,10.1*mouse.x);
		pos = 2.*mouse.y*rotate(pos,4.2*mouse.x);
	}
	//return c;
	return c/float(NMAX); //correction
}

const vec3 color1 = vec3(0.0,0.0,0.0);
const vec3 color2 = vec3(0.96,0.95,0.05);

void main(void) {
 //centrer la texture, de -1 à 1 sur la plus petite longueur de l'écran
  vec2 p = (2.0*gl_FragCoord.xy - resolution) / min(resolution.x,resolution.y);
 //transformation préalable du plan (facultatif)
	//p = p*p;
	//p = 1/p;
	//p.x = pow(p,mouse.x);p.y = pow(p.y,mouse.x);
	//p.y = 1./p.y;
	//p.x = 1./length(p);
 
 //zoom
  p = p*zoom+centre; //multiplié par puissance négative plus rapidec que divisé par puissance positive -> go MAD
  
 //définir un gradient en fonction de la position
  //float c = mandel(p);
  float c = sfractal(p);
  
  //couleur variant au cours du temps
  vec3 color_var = 0.5+0.5*vec3(cos(0.42*time),sin(0.555*time+1.),cos(0.5*time));
  
  
  vec3 color_final; //couleur finale au choix
  //color_final = c;
  //color_final = c*color_var;
  //color_final = fract(c)*color_var;
  //color_final = hsv2rgb(vec3(c,0.84,0.88));
  //color_final = mix(mix(color1,color2,smoothstep(0.,0.5,c)),color1,c);
  color_final = color_var*mix(vec3(0.4,0.2,0.0),vec3(0.99,0.61,0.95),c);
  //vec3 color_final =
  
  gl_FragColor=vec4(color_final,1.0);
}
