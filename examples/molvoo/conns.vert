#version 450

layout(location = 0) out vec3 outColour;
layout(location = 1) out vec3 outCentre;
layout(location = 2) out float outRadius;
layout(location = 3) out vec3 outRayDir;
layout(location = 4) out vec3 outRayStart;

layout (push_constant) uniform Uniform {
  mat4 worldToPerspective;
  mat4 modelToWorld;
  mat4 cameraToWorld;
} u;

out gl_PerVertex {
  vec4 gl_Position;
  float gl_PointSize;
};

struct Atom {
  vec3 pos;
  float radius;
  vec3 colour;
  float mass;
  vec3 prevPos;
  int pad;
  vec3 acc;
  int connections[5];
};

struct Connection {
  uint from;
  uint to;
  float naturalLength;
  float springConstant;
};

layout(std430, binding=0) buffer Atoms {
  Atom atoms[];
} a;

layout(std430, binding=3) buffer Connections {
  Connection conns[];
} c;

// 1   4 5
// 0 2   3
const vec2 verts[] = {
  {-1.0, -1.0}, {-1.0,  1.0}, { 1.0, -1.0},
  { 1.0, -1.0}, {-1.0,  1.0}, { 1.0,  1.0},
};

void main() {
  Connection conn = c.conns[gl_VertexIndex / 6];
  Atom a1 = a.atoms[conn.from];
  Atom a2 = a.atoms[conn.to];
  vec3 a1pos = (u.modelToWorld * vec4(a1.pos, 1)).xyz;
  vec3 a2pos = (u.modelToWorld * vec4(a2.pos, 1)).xyz;
  float minr = min(a1.radius, a2.radius);
  vec2 vpos = verts[gl_VertexIndex % 6];
  float lerpx = vpos.x * 0.5 + 0.5;
  vec3 pos = mix(a1pos, a2pos, lerpx);
  vec3 perp = normalize(cross(u.cameraToWorld[2].xyz, a1pos - a2pos));
  vec3 worldPos = pos + perp * (vpos.y * minr);
  vec3 cameraPos = u.cameraToWorld[3].xyz;
  gl_Position = u.worldToPerspective * vec4(worldPos, 1.0);
  outColour = a1.colour;
  //outCentre = worldCentre - cameraPos;
  //outRadius = a1.radius;
  //outRayDir = normalize(worldPos - cameraPos);
  //outRayStart = cameraPos;
}