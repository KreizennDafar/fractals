#define PROCESSING_COLOR_SHADER
#define NMAX 75

uniform vec2 resolution;
uniform float time;
uniform vec2 joystick;
uniform vec2 centre;
uniform float zoom;

vec2 cmult(vec2 z){
	return vec2(z.x*z.x-z.y*z.y, 2.*z.x*z.y);
}
float mandel(vec2 p){
	vec2 z = vec2(0.,0.);
	for(int i  = 0; i< NMAX; i++){
		z = cmult(z)+p;
	}
	return length(z);
	
}
void main(void) {
  vec2 p = (2.0*gl_FragCoord.xy - resolution) / min(resolution.x,resolution.y);
  p *= 1.33;
  p = p*zoom+centre;
  float c = mandel(p);
  //float dm = length(joystick);
  vec3 color = 0.5+0.5*vec3(cos(time),sin(time+1.),cos(0.8*time));
  gl_FragColor=vec4(color*vec3(c),1.0);
}
