#ifdef GL_ES
precision mediump float;
#endif

varying vec2 v_texCoord;
varying vec4 v_fragmentColor;

uniform vec4 u_black;
uniform vec4 u_white;

uniform sampler2D u_texture;

void main(void) {

    vec4 source = texture2D(u_texture, v_texCoord);
    //vec4 to = vec4(u_to.r / 255.0, u_to.g / 255.0, u_to.b / 255.0, opacity);
    //vec3 from = vec3(u_from.r / 255.0, u_from.g / 255.0, u_from.b / 255.0);
    //vec3 by = to - from;
    //vec3 inc = by * u_delta;
    if(source.rgb == vec3(0) && source.a != 0.0) gl_FragColor = v_fragmentColor * u_black;
    else if(source.rgb == vec3(1) && source.a != 0.0) gl_FragColor = v_fragmentColor * u_white;
    else gl_FragColor = v_fragmentColor * source;
    //gl_FragColor.a = 0.0;//v_fragmentColor.a * float(source.a != 0.0);
}