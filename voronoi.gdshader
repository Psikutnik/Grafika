shader_type canvas_item;

uniform vec2 resolution = vec2(1152.0 , 648.0);
uniform vec3 color_a: source_color = vec3(0.04);
uniform vec3 color_b: source_color = vec3(0.5);
uniform vec3 color_c: source_color = vec3(0.69);
uniform vec3 color_d: source_color = vec3(0.0, 0.12, 0.28);

vec2 N22(vec2 p) {
	vec3 a = fract(p.xyx * vec3(123.34, 234.34, 365.65));
	a += dot(a, a + 34.34);
	return fract(vec2(a.x * a.y, a.y * a.z));
}

vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d)
{
	return a +b * cos(2.0 * PI * (c*t + d));
}

void fragment() {
	float time = TIME;
	vec2 uv = UV - 0.5;
	uv.x *= resolution.x / resolution.y;
	float radius = length(uv);
	float fisheye_strength = 0.3; // Zmieniaj wartość dla mocniejszego/słabszego efektu
	if (radius > 0.0) {
		float new_radius = pow(radius, 1.0 - fisheye_strength);
		uv = uv / radius * new_radius;
	    }
	uv *= 6.0;
	float min_dist = 100.0;
	vec2 grid_coords = floor(uv);
	vec2 grid_uv = fract(uv);
	for (float y = -1.0; y <= 1.0; y++)
		for (float x = -1.0; x <= 1.0; x++) {
			vec2 offset = vec2(x, y);
			vec2 n = N22(offset + grid_coords);
			vec2 p = offset + sin(n * time) * 0.3;
			float d = length(grid_uv - p);
			if (d < min_dist) {
				min_dist = d;
			}
		}
	vec3 col = palette(min_dist - 10.0, color_a, color_b, color_c, color_d);
	COLOR = vec4(col, 0.8);
}
