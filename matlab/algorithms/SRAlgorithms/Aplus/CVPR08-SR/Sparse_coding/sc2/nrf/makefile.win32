CC= gcc
CFLAGS=	-O -I.

OPTOBJS=	frprmn.o linmin.o brent.o mnbrak.o nrutil.o impure.o getreent.o 

.c.o:
	${CC} ${CFLAGS} -c $*.c

libnrfopt.a:  clean  $(OPTOBJS)
	ar cr libnrfopt.a $(OPTOBJS)

clean:
	rm -rf *.o *.a
