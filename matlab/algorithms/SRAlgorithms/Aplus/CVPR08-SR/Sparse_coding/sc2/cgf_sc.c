/*
 * cgf.c:	conj. grad. routine for finding optimal s - fast!
 */
#include <stdio.h>
#include <math.h>
#include "mex.h"

#define sgn(x) (x>0 ? 1 : (x<0 ? -1 : 0))


extern void cgf(double *Sout, double *nits, double *nf, double *ng, double *Sin, double *X, int npats, double tol, int maxiter, int numflag);

/* Input & Output Arguments */

#define	A_IN		prhs[0]	/* basis matrix */
#define	X_IN		prhs[1]	/* data vectors */
#define	S_IN		prhs[2]	/* initial guess for S */
#define	SPARSITY_IN		prhs[3]	/* initial guess for S */
#define	LAMBDA_IN	prhs[4]	/* precision */
#define BETA_IN		prhs[5]	/* prior steepness */
#define SIGMA_IN        prhs[6] /* scaling parameter for prior */
#define	TOL_IN		prhs[7]	/* tolerance */
#define MAXITER_IN      prhs[8] /* maximum iterations for dfrpmin */
#define	OUTFLAG_IN	prhs[9]	/* output flag */
#define	NUMFLAG_IN	prhs[10]	/* pattern number output flag */
#define EPSILON_IN	prhs[11]	/* huber function epsilon */

#define	S_OUT           plhs[0]	/* basis coeffs for each data vector */
#define NITS_OUT        plhs[1] /* total iterations done by cg */
#define NF_OUT          plhs[2] /* total P(s|x,A) calcs */
#define NG_OUT          plhs[3] /* total d/ds P(s|x,A) calcs */

/* Define indexing macros for matricies */

/* L = dimension of input vectors
 * M = number of basis functions
 */

#define A_(i,j)		A[(i) + (j)*L]	/* A is L x M */
#define X_(i,n)		X[(i) + (n)*L]	/* X is L x npats */

#define Sout_(i,n)	Sout[(i) + (n)*M]	/* S is M x npats */
#define Sin_(i,n)	Sin[(i) + (n)*M]	/* S is M x npats */

#define AtA_(i,j)	AtA[(i) + (j)*M]	/* AtA is M x M */

/* Globals for using with frprmin */

static double *A;               /* basis matrix */
static int L;                   /* data dimension */
static int M;                   /* number of basis vectors */
static double lambda;           /* 1/noise_var */
static double beta;             /* prior steepness */
static double sigma;            /* prior scaling */
static double k1, k2, k3;       /* precomputed constants for f1dim */

static double *x;               /* current data vector being fitted */
static double *s0;              /* init coefficient vector (1:M) */
static double *d;               /* search dir. coefficient vector (1:M) */
static int outflag;             /* print search progress */

static double *AtA;             /* Only compute A'*A once (1:M,1:M) */
static double *Atx;             /* A*x (1:M) */

static int fcount, gcount;

#define SP_LOG			0
#define SP_HUBER_L1		1
#define SP_EPS_L1		2
static int g_sparsity_func;
static double g_epsilon;	/* use global variable for huber function epsilon */

static void init_global_arrays()
{
    int i, j, k;
    double *Ai, *Aj, sum;

    x = (double *) malloc(L * sizeof(double));
    s0 = (double *) malloc(M * sizeof(double));
    d = (double *) malloc(M * sizeof(double));
    AtA = (double *) malloc(M * M * sizeof(double));
    Atx = (double *) malloc(M * sizeof(double));

    /* Calc  A'*A */
    for (i = 0; i < M; i++) {
        Ai = A + i * L;
        for (j = 0; j < M; j++) {
            Aj = A + j * L;
            sum = 0.0;
            for (k = 0; k < L; k++) {
                sum += Ai[k] * Aj[k];
            }
            AtA_(i, j) = sum;
        }
    }
}

static void free_global_arrays()
{

    free((double *) x);
    free((double *) s0);
    free((double *) d);
    free((double *) AtA);
    free((double *) Atx);
}



float init_f1dim(s1, d1)
float *s1, *d1;
{
    register int i, j;
    register double As, Ag, sum;
    register float fval;
    extern double sparse();

    for (i = 0; i < M; i++) {
        s0[i] = s1[i + 1];
        d[i] = d1[i + 1];
    }
    k1 = k2 = k3 = 0;
    for (i = 0; i < L; i++) {
        As = Ag = 0;
        for (j = 0; j < M; j++) {
            As += A_(i, j) * s0[j];
            Ag += A_(i, j) * d[j];
        }
        k1 += As * (As - 2 * x[i]);
        k2 += Ag * (As - x[i]);
        k3 += Ag * Ag;
    }
    k1 *= 0.5 * lambda;
    k2 *= lambda;
    k3 *= 0.5 * lambda;

    fval = k1;

    sum = 0;
    for (i = 0; i < M; i++)
        sum += sparse(s0[i] / sigma);
    fval += beta * sum;

    fcount++;

    return (fval);
}

float f1dim(alpha)
float alpha;
{
    int i;
    double sum;
    float fval;
    extern double sparse();

    fval = k1 + (k2 + k3 * alpha) * alpha;

    sum = 0;
    for (i = 0; i < M; i++) {
        sum += sparse((s0[i] + alpha * d[i]) / sigma);
    }
    fval += beta * sum;

    fcount++;

    return (fval);
}


/*
 * Gradient evaluation used by conj grad descent
 */
void dfunc(p, grad)
float *p, *grad;
{
    register int i, j;
    register double sum, *cptr, bos = beta / sigma;
    register float *p1;
    extern double sparse_prime();

    p1 = &p[1];

    for (i = 0; i < M; i++) {
        cptr = AtA + i * M;
        sum = 0;
        for (j = 0; j < M; j++) {
            sum += p1[j] * *cptr++;
        }
        grad[i + 1] = lambda * (sum - Atx[i]) + bos * sparse_prime((double) p1[i] / sigma);
    }
    gcount++;
}

double sparse(x)
double x;
{
	if (g_sparsity_func== SP_LOG) {
	    return (log(1.0 + x * x));
	} else if (g_sparsity_func== SP_HUBER_L1) {
		/* retval(idx_in)  = 1/(2*eps).*x(idx_in).^2;
		retval(idx_out) = 1/2.*(2.*abs(x(idx_out))-eps); */
		if (fabs(x) < g_epsilon)
			return x*x/(2.0*g_epsilon); /*1.0/(2.0*g_epsilon)* x*x;*/
		else
			return (2*abs(x)-g_epsilon)/2.0; /*1.0/2.0* (2*abs(x)-g_epsilon);*/
	} else if (g_sparsity_func== SP_EPS_L1) {
	    return (sqrt(x * x + g_epsilon));
	}
	
	fprintf(stderr, "Error: sparsity function is not properly specified!\n");
	exit(-1);
}

double sparse_prime(x)
double x;
{
	if (g_sparsity_func== SP_LOG) {
		return (2 * x / (1.0 + x * x));
	} else if (g_sparsity_func== SP_HUBER_L1) {
		/* retval(idx_in)  = 1/(2*eps).* 2.0.*x(idx_in);
		retval(idx_out) = 1/2.* 2.*sign(x(idx_out)); */
		if (fabs(x) < g_epsilon)
			return x/ g_epsilon; /*1.0/(2.0*g_epsilon)* 2.0*x;*/
		else 
			return sgn(x);
	} else if (g_sparsity_func== SP_EPS_L1) {
	    return x/sqrt(x * x + g_epsilon);
	}
	
	fprintf(stderr, "Error: sparsity function is not properly specified!\n");
	exit(-2);
    
}

void iter_do()
{
}


#include <nrutil.h>
extern int ITMAX;

void cgf(double *Sout, double *nits, double *nf, double *ng, double *Sin, double *X, int npats, double tol, int maxiter, int numflag)
{
    double sum;
    float fret;
    int niter, l, m, n;
    float *p;

    *nits = *nf = *ng = 0.0;
    ITMAX = 10;

    init_global_arrays();
    p = vector(1, M);

    for (n = 0; n < npats; n++) {
        if (numflag) {
            fprintf(stderr, "\r%d", n + 1);
            fflush(stderr);
        }

        for (l = 0; l < L; l++) {
            x[l] = X_(l, n);
        }

        for (m = 0; m < M; m++) {

            /* precompute Atx for this pattern */
            sum = 0.0;
            for (l = 0; l < L; l++) {
                sum += A_(l, m) * x[l];
            }
            Atx[m] = sum;

            /* copy initial guess */
            p[m + 1] = Sin_(m, n);
        }

        fcount = gcount = 0;

        frprmn(p, M, (float) tol, &niter, &fret, init_f1dim, f1dim, dfunc);

        *nits += (double) niter;
        *nf += (double) fcount;
        *ng += (double) gcount;

        if (outflag) {
            fprintf(stdout, "\nfret=%f  niters=%d  fcount=%d  gcount=%d\n", fret, niter, fcount, gcount);
            fflush(stdout);
        }

        /* copy back solution */
        for (m = 0; m < M; m++) {
            Sout_(m, n) = p[m + 1];
        }
    }

    free_global_arrays();
    free_vector(p, 1, n);
}


void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    double *Sout, nits = 0, nf = 0, ng = 0, *Sin;
    double *X, tol;
    int maxiter, npats, numflag, i;

    /* Check for proper number of arguments */

    if (nrhs < 7) {
        mexErrMsgTxt("cgf requires 6 input arguments.");
    } else if (nlhs < 1) {
        mexErrMsgTxt("cgf requires 1 output argument.");
    }

    /* Assign pointers to the various parameters */

    A = mxGetPr(A_IN);
    X = mxGetPr(X_IN);
    Sin = mxGetPr(S_IN);
	g_sparsity_func = mxGetScalar(SPARSITY_IN);
    lambda = mxGetScalar(LAMBDA_IN);
    beta = mxGetScalar(BETA_IN);
    sigma = mxGetScalar(SIGMA_IN);
	
	/*fprintf(stderr,"--------------\n"); 
	fprintf(stderr,"g_sparsity_func = %d\n", g_sparsity_func); 
	fprintf(stderr,"lambda = %f\n", lambda); 
	fprintf(stderr,"beta = %f\n", beta); 
	fprintf(stderr,"sigma = %f\n", sigma);
	*/


    if (nrhs < 8) {
        tol = 0.1;
    } else {
        tol = mxGetScalar(TOL_IN);
    }

    if (nrhs < 9) {
        maxiter = 100;
    } else {
        maxiter = (int) mxGetScalar(MAXITER_IN);
    }

    if (nrhs < 10) {
        outflag = 0;
    } else {
        outflag = (int) mxGetScalar(OUTFLAG_IN);
    }

    if (nrhs < 11) {
        numflag = 0;
    } else {
        numflag = (int) mxGetScalar(NUMFLAG_IN);
    }

	/* This is only for sparsity type = SP_HUBER_L1, SP_EPS_L1 */
    if (nrhs < 12) {
        g_epsilon = 0.5;
    } else {
        g_epsilon = mxGetScalar(EPSILON_IN);
    }
	

    L = (int) mxGetM(A_IN);
    M = (int) mxGetN(A_IN);
    npats = (int) mxGetN(X_IN);

    /* Create a matrix for the return argument */

    S_OUT = mxCreateDoubleMatrix(M, npats, mxREAL);
    Sout = mxGetPr(S_OUT);

    if (nlhs > 1) {
        NITS_OUT = mxCreateDoubleMatrix(1, 1, mxREAL);
    }
    if (nlhs > 2) {
        NF_OUT = mxCreateDoubleMatrix(1, 1, mxREAL);
    }
    if (nlhs > 3) {
        NG_OUT = mxCreateDoubleMatrix(1, 1, mxREAL);
    }

    /* Do the actual computations in a subroutine */

    cgf(Sout, &nits, &nf, &ng, Sin, X, npats, tol, maxiter, numflag);

    if (nlhs > 1) {
        *(mxGetPr(NITS_OUT)) = nits;
    }
    if (nlhs > 2) {
        *(mxGetPr(NF_OUT)) = nf;
    }
    if (nlhs > 3) {
        *(mxGetPr(NG_OUT)) = ng;
    }
}

#undef A_
#undef X_
#undef Sout_
#undef Sin_
#undef AtA_
