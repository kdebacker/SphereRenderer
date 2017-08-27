#include "renderer.h"

cl_float3 f4(float x, float y, float z, float w) {
	return (cl_float4) { x, y, z, w };
}

int main(int argc, char **argv) {

	int num_spheres = 0;
	sphere spheres[MAX_SPHERES] = { 0 };

	// spheres
	spheres[0] = create_sphere(f4(0.0, -10004, -20, 0), f4(0.20, 0.20, 0.20, 0), f4(0, 0, 0, 0), 10000, 0, 0.0);
	spheres[1] = create_sphere(f4(0.0, 0, -20, 0), f4(1.00, 0.32, 0.36, 0), f4(0, 0, 0, 0), 4, 1, 0.5);
	spheres[2] = create_sphere(f4(5.0, -1, -15, 0), f4(0.90, 0.76, 0.46, 0), f4(0, 0, 0, 0), 2, 1, 0.0);
	spheres[3] = create_sphere(f4(5.0, 0, -25, 0), f4(0.65, 0.77, 0.97, 0), f4(0, 0, 0, 0), 3, 1, 0.0);
	spheres[4] = create_sphere(f4(-5.5, 0, -15, 0), f4(0.90, 0.90, 0.90, 0), f4(0, 0, 0, 0), 3, 1, 0.0);

	//// light
	spheres[5] = create_sphere(f4(0.0, 20, -30, 0), f4(0.00, 0.00, 0.00, 0), f4(3, 3, 3, 0), 3, 0, 0.0);

	num_spheres = 6;

	render(num_spheres, spheres);

	return 0;
}