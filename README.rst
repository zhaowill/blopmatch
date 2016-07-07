blopmatching.ado - BLOP matching for Stata
==========================================

blopmatching estimates treatment effects from observational data by BLOP matching.
BLOP matching imputes the missing potential outcome for each subject by using an weighted average
of the outcomes of all the subjects that receive the other treatment level.
The vector of weights for each subject is determined by solving a Bi-Level Optimization Problem (BLOP),
hence the name of the method.


* Matching against almost any data type with a first-match policy
* Deep matching within data types and matrices
* Variable binding within matches


Installation
============

Within Stata, do::

  net from "https://rawgit.com/igutierrezm/blopmatching/master"


Usage
=====
