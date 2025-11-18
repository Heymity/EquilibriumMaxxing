#include <math.h>
#include <stdio.h>

#define PI 3.1415926

#define STEPS 3200
#define G 9.81
#define L 0.3

#define FIXED_POINT_BITS 4

int main() {
	for (int step = 0; step < 4096; step++) {
		float angleRad = 2*PI*(step % STEPS)/STEPS;
		float a = -cos(angleRad)*G/L;

		unsigned long fixedPoint = ((long)(a * (1 << FIXED_POINT_BITS))) << 22;
		fixedPoint *= 0x0000000000801A36;

		fixedPoint >>= 32;	

		//printf("%d 16'sh%08X //%10d %f \n",step, (unsigned int) fixedPoint, (unsigned int) fixedPoint, a);	
		printf("%08X\n",(unsigned int) fixedPoint);	
	}
}
