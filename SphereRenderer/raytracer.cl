typedef struct sphere_t {
	float4	center;
	float4	surface_color;
	float4	emission_color;
	float	radius;
	float	reflection;
	float	transparency;
	float	padding;
} sphere;

float3 trace(int num_spheres, __global sphere *spheres, float3 origin, float3 direction, int depth);
bool intersect(sphere s, float3 origin, float3 direction, float *t0, float *t1);

float my_mix(float a, float b, float mix);

__kernel void raytracer(__private int num_spheres, __global sphere *spheres, __write_only image2d_t output)
{
	const int2 pos = (int2)(get_global_id(0), get_global_id(1));
	const float3 origin = (float3)(0.f, 0.f, 0.f);

	const float invWidth = 1.f / (float)get_image_width(output);
	const float invHeight = 1.f / (float)get_image_height(output);
	const float fov = 30.f;
	const float aspectratio = (float)get_image_width(output) / (float)get_image_height(output);
	const float angle = (float)tan(M_PI * 0.5f * fov / 180.f);

	float xx = (2 * ((pos.x + 0.5f) * invWidth) - 1.f) * angle * aspectratio;
	float yy = (1 - 2 * ((pos.y + 0.5f) * invHeight)) * angle;

	const float3 direction = (float3)(xx, yy, -1.f);

	float3 color = trace(num_spheres, spheres, origin, fast_normalize(direction), 0);
	write_imagef(output, pos, (float4)(color.x, color.y, color.z, 1.0f));
}

float3 trace(int num_spheres, __global sphere *spheres, float3 origin, float3 direction, int depth)
{
	float tnear = INFINITY;
	int s = -1;

	for (int i = 0; i < num_spheres; i++) {
		float t0 = MAXFLOAT, t1 = MAXFLOAT;
		if (intersect(spheres[i], origin, direction, &t0, &t1)) {
			if (t0 < 0.f)
				t0 = t1;

			if (t0 < tnear) {
				tnear = t0;
				s = i;
			}
		}
	}

	if (s == -1) {
		return (float3)(2.f, 2.f, 2.f);
	}

	float3 surface_color = (float3)(0.f, 0.f, 0.f);
	float3 phit = origin + (direction * tnear);
	float3 nhit = phit - spheres[s].center.xyz;
	nhit = fast_normalize(nhit);

	float bias = 1e-4f;
	bool inside = false;
	if (dot(direction, nhit) > 0.f) {
		nhit = -nhit;
		inside = true;
	}

	if (((spheres[s].transparency > 0.f) || (spheres[s].reflection > 0.f)) && depth < 6) {
		float facingratio = dot(-direction, nhit);
		float fresneleffect = my_mix((float)pow(1.f - facingratio, 3.f), 1.f, 0.1f);
		float3 refldir = direction - (nhit * (2.f * dot(direction, nhit)));
		refldir = fast_normalize(refldir);
		float3 reflection = trace(num_spheres, spheres, phit + (nhit * bias), refldir, depth + 1);
		float3 refraction = (float3)(0.f, 0.f, 0.f);
		if (spheres[s].transparency) {
			float ior = 1.1f;
			float eta = (inside) ? ior : 1.f / ior;
			float cosi = dot(-nhit, direction);
			float k = 1.f - eta * eta * (1.f - cosi * cosi);
			float3 refrdir = (direction * eta) + (nhit * (eta * cosi - (float)sqrt(k)));
			refraction = trace(num_spheres, spheres, phit - (nhit * bias), refrdir, depth + 1);
		}
		surface_color = ((reflection * fresneleffect) + ((refraction * (1.f - fresneleffect)) * spheres[s].transparency)) * spheres[s].surface_color.xyz;
	}
	else {
		for (int i = 0; i < num_spheres; i++) {
			if (spheres[i].emission_color.x > 0.f) {
				float3 transmission = (float3)(1.f, 1.f, 1.f);
				float3 light_direction = spheres[i].center.xyz - phit;
				light_direction = fast_normalize(light_direction);
				for (int j = 0; j < num_spheres; j++) {
					if (i != j) {
						float t0, t1;
						if (intersect(spheres[j], phit + (nhit * bias), light_direction, &t0, &t1)) {
							transmission = (float3)(0.f, 0.f, 0.f);
							break;
						}
					}
				}
				surface_color = surface_color + ((spheres[s].surface_color.xyz * transmission) * (spheres[i].emission_color.xyz * max(0.f, dot(nhit, light_direction))));
			}
		}
	}

	return surface_color + spheres[s].emission_color.xyz;
}

bool intersect(sphere s, float3 origin, float3 direction, float *t0, float *t1)
{
	float3 l = s.center.xyz - origin;
	float tca = dot(l, direction);

	if (tca < 0.f) {
		return false;
	}

	float d2 = dot(l, l) - (tca * tca);

	if (d2 >(s.radius * s.radius)) {
		return false;
	}

	float thc = (float)sqrt((s.radius * s.radius) - d2);
	*t0 = tca - thc;
	*t1 = tca + thc;

	return true;
}

float my_mix(float a, float b, float mix)
{
	return (b * mix) + (a * (1.f - mix));
}
