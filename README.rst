.. |br| raw:: html
   <br />

blopmatching - BLOP matching for Stata
==========================================

blopmatching estimates treatment effects from observational data by BLOP matching.
BLOP matching imputes the missing potential outcome for each subject by using an weighted average
of the outcomes of all the subjects that receive the other treatment level.
The vector of weights for each subject is determined by solving a Bi-Level Optimization Problem (BLOP),              
see Díaz, Rau and Rivera (2015) for details.


Installation
############

Within Stata, type::

  net from "https://rawgit.com/igutierrezm/blopmatching/master"

after installation, type::

  help blopmatching


Syntax
############

:: 

   blopmatching [if] [in] , outcome(varname) treatment(varname) controls(varlist) [options]

type::

  help blopmatching

for details

References 
==========

 Diaz, J., Rau, T., and J. Rivera (2015). A Matching Estimator Based on a Bilevel Optimization Problem.                
  *Review of Economics & Statistics* 97(4): 803-812.

