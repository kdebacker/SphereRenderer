#include "renderer.h";

sphere create_sphere(cl_float4 center, cl_float4 surface_color, cl_float4 emission_color, cl_float radius, cl_float reflection, cl_float transparency) {
	sphere s = { 0 };

	s.center = center;
	s.surface_color = surface_color;
	s.emission_color = emission_color;
	s.radius = radius;
	s.reflection = reflection;
	s.transparency = transparency;

	return s;
}
