/*
Author: Marius Drulea
http://www.cv.utcluj.ro/optical-flow.html

References
M. Drulea and S. Nedevschi, "Total variation regularization of 
local-global optical flow," in Intelligent Transportation Systems (ITSC), 
2011 14th International IEEE Conference on, 2011, pp. 318-323.

Copyright (C) 2011 Technical University of Cluj-Napoca

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/*

The file "applyBilateralFilterToDataTerms.cpp" should be recompiled if the following error occurs:
??? Undefined function or method
'applyBilateralFilterToDataTerms' for input arguments of type 'double'.

To compile this file use the "mex" function. Enter the following line into the Matlab's command prompt:
mex applyBilateralFilterToDataTerms.cpp

*/


#include "mex.h"

#define _USE_MATH_DEFINES
#include <math.h>

double* build2DGaussianKernel(int wSize, double sigma);
void applyBilateralFilterToDataTerms
	(
		double* wIxIx, double* wIxIy, double* wIyIy, double* wIxr0, double* wIyr0,
		double* Ikey,
		double* IxIx, double* IxIy, double* IyIy, double* Ixr0, double* Iyr0, 
		int width, int height, 
		int wSize, double sigma_d, double sigma_r
	);


/* the gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    if(nrhs != 9) 
    mexErrMsgTxt("Eleven inputs required.");
    if(nlhs != 5) 
    mexErrMsgTxt("Five output required.");
        
    //get the inputs
    /*  create a pointer to the input matrix data */
    double* Ikey = (double*) mxGetPr(prhs[0]);
    double* IxIx = (double*) mxGetPr(prhs[1]);
    double* IxIy = (double*) mxGetPr(prhs[2]);
    double* IyIy = (double*) mxGetPr(prhs[3]);
    double* Ixr0 = (double*) mxGetPr(prhs[4]);
    double* Iyr0 = (double*) mxGetPr(prhs[5]);
    int wSize = (int) mxGetScalar(prhs[6]);
    double sigma_d = (double) mxGetScalar(prhs[7]);
    double sigma_r = (double) mxGetScalar(prhs[8]);
    
    
    /*  get the dimensions of the matrix input data */
    int height = (int) mxGetN(prhs[0]);
    int width = (int) mxGetM(prhs[0]);    
    
    /*  set the output pointer to the output matrix */
    plhs[0] = mxCreateDoubleMatrix(width, height, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(width, height, mxREAL);
    plhs[2] = mxCreateDoubleMatrix(width, height, mxREAL);
    plhs[3] = mxCreateDoubleMatrix(width, height, mxREAL);
    plhs[4] = mxCreateDoubleMatrix(width, height, mxREAL);

    /*  create a C pointer to a copy of the output matrix */    
    double* wIxIx = (double*) mxGetPr(plhs[0]);
    double* wIxIy = (double*) mxGetPr(plhs[1]);
    double* wIyIy = (double*) mxGetPr(plhs[2]);
    double* wIxr0 = (double*) mxGetPr(plhs[3]);
    double* wIyr0 = (double*) mxGetPr(plhs[4]);
    
    /*  call the C subroutine */
    applyBilateralFilterToDataTerms
	(
		wIxIx, wIxIy, wIyIy, wIxr0, wIyr0,
		Ikey,
		IxIx, IxIy, IyIy, Ixr0, Iyr0, 
		width, height, 
		wSize, sigma_d, sigma_r
	);    
}

/*
 Applies the bilateral filter to the data terms of the residual error.
 The input data should be in [0, 1];
 */
void applyBilateralFilterToDataTerms
	(
		double* wIxIx, double* wIxIy, double* wIyIy, double* wIxr0, double* wIyr0,
		double* Ikey,
		double* IxIx, double* IxIy, double* IyIy, double* Ixr0, double* Iyr0, 
		int width, int height, 
		int wSize, double sigma_d, double sigma_r
	)
{
	//precompute the gaussian   
    double* gaussianKernel = build2DGaussianKernel(wSize, sigma_d);
    
    double squared_sigma_r =  sigma_r * sigma_r;	
    double fraction = 2 * M_PI * squared_sigma_r;
    
    int wr = (wSize - 1)/2;
    
    for (int j = 0; j < height; j++)
    {        
        for (int i = 0; i < width; i++)
        {       
            int cInd = j*width + i;
            double Ikey_j_i = Ikey[cInd];
            
            double sumIxIx = 0, sumIxIy = 0, sumIyIy = 0, sumIxr0 = 0, sumIyr0 = 0;
            double sumWeights = 0;
            //the filtering kernel based on the gaussian and the intensity based gaussian 
            //computes and applies the filtering kernel
            for (int y = -wr; y <= wr; y++)
            {                                   
                int indY = j + y;
                //use replicate option at boundaries
                if (indY < 0) indY = 0;
                if (indY >= height) indY = height - 1;
                
                for (int x = -wr; x <= wr; x++)
                {
                    int indX = i + x;
                    //use replicate option at boundaries                    
                    if (indX < 0) indX = 0;
                    if (indX >= width) indX = width - 1;
                    
					//the kernel is super-imposed over the original image
					//the kernel position in the original image
					int cInd_y_x = indY * width + indX;					
					//the corresponding data in the original image; 
                    double Ikey_y_x = Ikey[cInd_y_x];
                    
					/*computes the combined factor*/
                    double exponent = - (Ikey_y_x - Ikey_j_i)*(Ikey_y_x - Ikey_j_i);
                    exponent/=2*squared_sigma_r;
					//gaussian intensity factor
                    double intensityFactor = exp(exponent)/fraction; 
                    
					//combined factor                    
                    double combinedFactor = gaussianKernel[(y+wr)*wSize + x + wr] * intensityFactor; 
                    
					//computes the sum of the weights in order to normalize the result
					sumWeights += combinedFactor;
                    
					/*apply the current combined factor to the current position*/
                    sumIxIx += combinedFactor * IxIx[cInd_y_x];
					sumIxIy += combinedFactor * IxIy[cInd_y_x];
					sumIyIy += combinedFactor * IyIy[cInd_y_x];
					sumIxr0 += combinedFactor * Ixr0[cInd_y_x];
					sumIyr0 += combinedFactor * Iyr0[cInd_y_x];
                }
            }
            
			//normalize and store the results
            wIxIx[cInd] = sumIxIx/sumWeights;
			wIxIy[cInd] = sumIxIy/sumWeights;
			wIyIy[cInd] = sumIyIy/sumWeights;
			wIxr0[cInd] = sumIxr0/sumWeights;
			wIyr0[cInd] = sumIyr0/sumWeights;
        }
    }
    
    //release the aditional memory
    delete[] gaussianKernel;    
}

double* build2DGaussianKernel(int wSize, double sigma)
{	
    double* gaussianKernel = new double[wSize * wSize];

	//gaussian kernel initialization	
	double squared_sigma =  sigma * sigma;	
	double fraction = 2 * M_PI * squared_sigma;

	int x0 = wSize/2 , y0 = wSize/2; // (x0, y0) are the coordinates of the kernel's center
	for (int x = 0; x < wSize; x++)
	{
		for (int y = 0; y < wSize; y++)
		{
			double exponent = (0 - (x - x0) * (x - x0)- (y - y0)*(y-y0));
			exponent/=2*squared_sigma;
			gaussianKernel[x*wSize + y] = exp(exponent)/fraction; 
		}
	}

	return gaussianKernel;
}