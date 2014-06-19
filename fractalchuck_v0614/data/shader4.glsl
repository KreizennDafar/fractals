#define PROCESSING_COLOR_SHADER
#ifdef GL_ES
precision mediump float;
#endif
uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

//JULIO NUÑEZ - ITMAZ - simple perlin noise
//http://glsl.heroku.com/e#12593.0
//mod sheldonCM

float rand( float x, float y ){return fract( sin( x + y*0.0083 )*130000.0 );}
vec2 rotate(vec2 p, float a){
	return vec2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a)); //R*P
}
float interpolar(vec2 cord, float L){
   	float XcordEntreL= cord.x/L;
        float YcordEntreL= cord.y/L;
    
	float XcordEnt=floor(XcordEntreL);
        float YcordEnt=floor(YcordEntreL);

	float XcordFra=fract(XcordEntreL);
        float YcordFra=fract(YcordEntreL);
	
	float l1 = rand(XcordEnt, YcordEnt);
	float l2 = rand(XcordEnt+1.0, YcordEnt);
	float l3 = rand(XcordEnt, YcordEnt+1.0);
	float l4 = rand(XcordEnt+1.0, YcordEnt+1.0);
	
	float inter1 = (XcordFra*(l2-l1))+l1;
	float inter2 = (XcordFra*(l4-l3))+l3;
	float interT = (YcordFra*(inter2 -inter1))+inter1;
    return interT;
}

#define N 10
void main(void)
{	
	float color = 0.0;
	float a;
	vec2 pos = 2.*gl_FragCoord.xy-resolution;
	pos = rotate (pos,50.*mouse.x);
	for ( int i = 0; i < N; i++ ){
		float p = fract(float(i) / float(N) - mouse.y );
		a = p * (1.0-p);
		color +=  a*(interpolar(pos, resolution.y/pow(2.0, p*float(N)))-.5);
	}
	color += .5;
	
	gl_FragColor = vec4(1.,1.0,1.0,1.0)*color;
	
}
