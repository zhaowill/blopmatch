blopmatching: blop-matching for Stata
==========================================

blopmatching estimates treatment effects from observational data by blop-matching.
blop-matching imputes the missing potential outcome for each subject by using an weighted average
of the outcomes of all the subjects that receive the other treatment level.
The vector of weights for each subject is determined by solving a Bi-Level Optimization Problem (BLOP).


Installation
############

Within Stata, type::

  net from "https://rawgit.com/igutierrezm/blopmatching/master"


Usage
############

::

   blopmatching [if] [in] , outcome(varname) treatment(varname) controls(varlist) [options]

where the ``outcome()`` must contain the outcome variable, ``treatment()`` must contain the treatment variable, and ``varlist`` must contain the covariates. Type:: 

   help blopmatching

for aditional details and examples.

References
##########

 Diaz, J., Rau, T., and J. Rivera (2015). A Matching Estimator Based on a Bilevel Optimization Problem.
  *Review of Economics & Statistics* 97(4): 803-812.
