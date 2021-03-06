********************************************************************************
* BLOPmatching - Prueba del programa usando datos simulados:
********************************************************************************

cls
clear all
set more off
set matadebug off
cd "C:\Users\ivang\Documents\GitHub\blopmatching"

* Programas Auxiliares
* run blopmatching.ado
* run blop.mata
* run lpsolver.mata  
* run blopmatching.mata 
* Eventualmente, el usuario podrá instalar todo de la manera usual.
net from "https://rawgit.com/igutierrezm/blopmatching/master"
net install blopmatching, replace
net get blopmatching

* Datos de Lalonde
use "lalonde.dta", clear
egen std_re75 = std(re75)
local y re78
local x age education black hispanic married nodegree std_re75
local w treat

* Estimacion del ATE via diferencia de medias
ttest `y', by(`w')

* Estimacion del ATE via NN Matching
teffects nnmatch (`y' `x') (`w'), ate metric(euclidean) nneighbor(01)
teffects nnmatch (`y' `x') (`w'), ate metric(euclidean) nneighbor(04)
teffects nnmatch (`y' `x') (`w'), ate metric(euclidean) nneighbor(16)
teffects nnmatch (`y' `x') (`w'), ate metric(euclidean) nneighbor(64)

// * Estimacion del ATE via BLOP-Matching
// blopmatching, outcome(`y') treatment(`w') covariates(`x') dcvar
//
// * Ayuda del programa
// help BLOPmatching
