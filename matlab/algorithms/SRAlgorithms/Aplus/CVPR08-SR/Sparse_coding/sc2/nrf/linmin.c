#include "nrutil.h"
#define TOL 2.0e-4

void linmin(p,xi,n,fret,f1dim)
float (*f1dim)(),*fret,p[],xi[];
int n;
{
	float brent();
	void mnbrak();
	int j;
	float xx,xmin,fx,fb,fa,bx,ax;

	ax=0.0;
	xx=1.0;
	mnbrak(&ax,&xx,&bx,&fa,&fx,&fb,f1dim);
	*fret=brent(ax,xx,bx,f1dim,TOL,&xmin);
	for (j=1;j<=n;j++) {
		xi[j] *= xmin;
		p[j] += xi[j];
	}
}
#undef TOL
/* (C) Copr. 1986-92 Numerical Recipes Software 6=Mn.Y". */
