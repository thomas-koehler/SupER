MEX = mex 
NRFDIR = ./nrf

all: cgf_sc.c
	make -C nrf -f makefile.linux 
	$(MEX) -I$(NRFDIR) -L$(NRFDIR) -lnrfopt cgf_sc.c -o cgf_sc2
