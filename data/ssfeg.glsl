#define PROCESSING_COLOR_SHADER
#define NMAX 25

uniform vec2 resolution;
uniform float time;
uniform vec2 mouse;
uniform vec2 centre;
uniform float zoom;

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
float sfractal(vec2 pos){ //fractale simple, répéter des "trucs"
//chaque entrée de l'uniform mouse règle le contrôle de la fractale ^_^
	float c = 0.;//1. pour formule *=
	float dm = length(mouse);
//répéter une formule et une transformation du plan
	for(int i=0;i<NMAX;i++){
	
//1: c = f(p) ou f(p,j)
//on y met ce qu'on veut !
		//c += cos(10.*pos.x)*cos(8.*pos.y);
		c += 0.5+0.5*cos(15.*pos.x)*cos(15.*pos.y); //offset ??
		//step(0.5,0.5+0.5*cos(15.*pos.x)*cos(15.*pos.y))
		//0.2/length(pos-m)
		//c+=pos.x;
		//abs(20.*m.x*p.x*p.y)
		//c += cos(float(i)*(20.*length(pos)+5.*atan(pos.y,pos.x)));
		//c += ronds(pos); //
		//dot(mod(pos,m.x/1.)-m.x/2.,mod(pos,m.x/1.)-m.x/2.) //7
		//c += sin(sin(5.*pos.x+0.1*time)+sin(4.*pos.y+0.2*time)+time);
		//c += sin(sin(20.*pos.x+0.1*time)+mouse.x*sin(15.*pos.y+time)+time);
		
//2: p=f(p) ou p = f(p,j)

		pos = 2.*dm*rotate(pos,10.1*mouse.x);
		
	}
	//return c;
	return c/float(NMAX);
}

void main(void) {
 //centrer la texture, de -1 à 1 sur la plus petite longueur de l'écran
  vec2 p = (2.0*gl_FragCoord.xy - resolution) / min(resolution.x,resolution.y);
 //transformation éventuelle du plan
 //p = p*p;
 //p = 1/p;
 //p.x = pow(p,mouse.x);p.y = pow(p.y,mouse.x);
 
 //zoom
  p = p*zoom+centre; //multiplié par puissance négative plus rapidec que divisé par puissance positive -> go MAD
 //définir un gradient en fonction de la position
  //float c = mandel(p);
  float c = sfractal(p);
  //couleur variant au cours du temps
  vec3 color = 0.5+0.5*vec3(cos(0.7*time),sin(0.8*time+1.),cos(0.5*time));
  //couleur finale
  gl_FragColor=vec4(hsv2rgb(vec3(c,0.84,0.88)),1.0);
  //gl_FragColor=vec4(mix(vec3(0.55,0.45,0.92),vec3(0.72,0.85,0.95),c),1.0);
  //gl_FragColor=vec4(color*vec3(c),1.0);
}
