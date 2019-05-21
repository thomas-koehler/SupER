/* 
 * frprmn.c:	modified frprmn for efficient line minimization
 */
#include <math.h>
#include "nrutil.h"

#define EPS 1.0e-10
#define FREEALL free_vector(xi,1,n);free_vector(h,1,n);free_vector(g,1,n);

int ITMAX;

void frprmn(p,n,ftol,iter,fret,init_f1dim,f1dim,dfunc)
float (*init_f1dim)(),(*f1dim)(),*fret,ftol,p[];
int *iter,n;
void (*dfunc)();
{
	void linmin();
	int j,its;
	float gg,gam,fp,dgg;
	float *g,*h,*xi;

	g=vector(1,n);
	h=vector(1,n);
	xi=vector(1,n);
	(*dfunc)(p,xi);
	for (j=1;j<=n;j++) {
		g[j] = -xi[j];
		xi[j]=h[j]=g[j];
	}
	for (its=1;its<=ITMAX;its++) {
		*iter=its;
		fp=(*init_f1dim)(p,xi);
		linmin(p,xi,n,fret,f1dim);
		if (2.0*fabs(*fret-fp) <= ftol*(fabs(*fret)+fabs(fp)+EPS)) {
			FREEALL
			return;
		}
		(*dfunc)(p,xi);
		dgg=gg=0.0;
		for (j=1;j<=n;j++) {
			gg += g[j]*g[j];
			dgg += (xi[j]+g[j])*xi[j];
		}
		if (gg == 0.0) {
			FREEALL
			return;
		}
		gam=dgg/gg;
		for (j=1;j<=n;j++) {
			g[j] = -xi[j];
			xi[j]=h[j]=g[j]+gam*h[j];
		}
	}
/*	nrerror("Too many iterations in frprmn"); */
	FREEALL
	return;
}

#undef EPS
#undef FREEALL
/* (C) Copr. 1986-92 Numerical Recipes Software 6=Mn.Y". */
