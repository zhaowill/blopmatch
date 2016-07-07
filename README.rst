# blopmatching.ado - BLOP matching using Stata
Treatment Effects estimation using BLOP matching

blopmatching.ado - BLOP matching for Stata
================================================

blopmatching estimates treatment effects from observational data by blop matching.  blop matching imputes the missing potential outcome for each subject by using an weighted average
    of the outcomes of all the subjects that receive the other treatment level.  The vector of weights for each subject is determined by solving a Bi-Level Optimization Problem (blop).


* Matching against almost any data type with a first-match policy
* Deep matching within data types and matrices
* Variable binding within matches


Installation
============

Use the Julia package manager.  Within Julia, do::

  Pkg.add("Match")


Usage
