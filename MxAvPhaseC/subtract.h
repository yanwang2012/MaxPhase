#include "gslhdf5_io.h"
#include <gsl/gsl_vector.h>
#include <stdio.h>
#include <string.h>
/*! \file
\brief Header file for function  subtraction().
*/
struct estSrcParams{
    double alpha;
    double delta;
    double omega;
    double phi0;
    double Amp;
    double iota;
    double thetaN;
    gsl_vector * psrPhase;
};

struct estSrcParams * file2Srcparam(char *);
struct estSrcParams * srcp_alloc(size_t);
void printParam(struct estSrcParams *);
void srcpara_free(struct estSrcParams *);
double timingResiduals(struct estSrcParams *, struct fitFuncParams *);
double * FullResiduals(double, double, double, double, double, double, double, double, double, double, double, double *);