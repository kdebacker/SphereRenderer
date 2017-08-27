#pragma once

typedef struct sphere_t {
	cl_float4	center;
	cl_float4	surface_color;
	cl_float4	emission_color;
	cl_float	radius;
	cl_float	reflection;
	cl_float	transparency;
	cl_float	padding;
} sphere;

extern sphere create_sphere(cl_float4 center, cl_float4 surface_color, cl_float4 emission_color, cl_float radius, cl_float reflection, cl_float transparency);
