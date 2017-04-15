********************************************************************************
* BLOPmatching - Prueba del programa usando datos simulados:
********************************************************************************

cls
clear all
set more off
set matadebug off
cd "D:\Users\ivang\Google Drive\Tesis"

* Programas Auxiliares
* run blopmatching.ado
* run blop.mata
* run lpsolver.mata  
* run blopmatching.mata 
* Eventualmente, el usuario podrá instalar todo de la manera usual.
quietly : net from "https://rawgit.com/igutierrezm/blopmatching/master"
noisily : net describe blopmatching
net get blopmatching

* Datos de Lalonde
use "lalonde.dta", clear
egen stdre75 = std(re75)
local y re78
local x age education black hispanic married nodegree stdre75
local w treat

* Estimacion del ATE via diferencia de medias
ttest `y', by(`w')

* Estimacion del ATE via NN Matching
teffects nnmatch (`y' `x') (`w'), ate metric(euclidean) nneighbor( 1)
teffects nnmatch (`y' `x') (`w'), ate metric(euclidean) nneighbor( 4)
teffects nnmatch (`y' `x') (`w'), ate metric(euclidean) nneighbor(16)
teffects nnmatch (`y' `x') (`w'), ate metric(euclidean) nneighbor(64)

* Estimacion del ATE via BLOP-Matching
blopmatching, outcome(`y') treatment(`w') covariates(`x') dcvar

* Ayuda del programa
help BLOPmatching
