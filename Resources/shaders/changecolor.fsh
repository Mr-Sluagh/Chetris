#ifdef GL_ES
precision mediump float;
#endif

varying vec2 v_texCoord;
varying vec4 v_fragmentColor;

uniform float u_delta;
uniform float u_progress;
uniform float u_opacity;
uniform vec3 u_from;
uniform vec3 u_to;

uniform sampler2D u_texture;

void main(void) {

    float opacity = u_opacity / 255.0f;
    vec4 source = texture2D(u_texture, v_texCoord);
    vec4 to = vec4(u_to.r / 255.0, u_to.g / 255.0, u_to.b / 255.0, opacity);
    vec3 from = vec3(u_from.r / 255.0, u_from.g / 255.0, u_from.b / 255.0);
    //vec3 by = to - from;
    //vec3 inc = by * u_delta;
    if(source.rgb == from && source.a != 0.0) gl_FragColor = v_fragmentColor * to;
    else gl_FragColor = v_fragmentColor * source;
    //gl_FragColor.a = 0.0;//v_fragmentColor.a * float(source.a != 0.0);
}