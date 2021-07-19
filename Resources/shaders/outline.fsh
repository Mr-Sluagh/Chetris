varying vec2 v_texCoord;
varying vec4 v_fragmentColor;

uniform float u_meter;
uniform float u_radius;
uniform float u_offset;

uniform sampler2D u_texture;

void main() {

    vec3 BLACK = vec3(0.0);
    vec3 WHITE = vec3(1.0);
    float radius = u_radius;
    float offset = u_offset;
    float meter = radius * u_meter;
    vec4 accum = vec4(0.0);

    vec2 center = vec2(v_texCoord.x, v_texCoord.y),
    bl = vec2(v_texCoord.x - radius, v_texCoord.y - radius),
    br = vec2(v_texCoord.x + radius, v_texCoord.y - radius),
    tr = vec2(v_texCoord.x + radius, v_texCoord.y + radius),
    tl = vec2(v_texCoord.x - radius, v_texCoord.y + radius);
    vec4 normal = texture2D(u_texture, center);

    float horizontal = mod(offset + center.x, meter) / meter;
    float vertical = mod(offset + center.y, meter) / meter;
    float average = (horizontal + vertical) / 2.0;
    vec3 outlineColor = vec3(average);

    accum += texture2D(u_texture, bl),
    accum += texture2D(u_texture, br),
    accum += texture2D(u_texture, tr),
    accum += texture2D(u_texture, tl);

    float isOutline = ceil(0.2 * float(normal.a > 0.0) * ( //if pixel is not transparent
    float(4.0 > accum.a) + //and nearby pixels are transparent
    float(0.0 >= v_texCoord.x - radius) + //or pixel is on edge
    float(0.0 >= v_texCoord.y - radius) +
    float(v_texCoord.x + radius >= 1.0) +
    float(v_texCoord.y + radius >= 1.0)
    ));
    normal.rgb = (outlineColor * isOutline) + (normal.rgb * step(isOutline, 0.0));

    gl_FragColor = v_fragmentColor * normal;
}

