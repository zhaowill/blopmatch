//******************************************************************************
// blopmatching.ado:
//******************************************************************************
//
//	PROPOSITO:
//		Estimacion de efectos de tratamiento via blop matching.
//
//	SINTAXIS:
//		blopmatching [if] [in],
//			outcome  (varname)
//			controls (varlist)
//			treatment(varname)
//			[options]
//
//	ARGUMENTOS:
//		outcome		  Variable  de respuesta.
//		treatment	  Variable  de tratamiento (1 : si / 0 : no).
//		controls	  Variables de control.
//
//	OPCIONES:
//      ttlevel       Especifica el nivel de los tratados  (default =    1).
//      utlevel       Especifica el nivel de los controles (default =    0).
//      level         Fija el nivel de los IC (default = 95).
//		otol		  Tol. del solver, test de optimalidad (default = 1e-8).
//		btol		  Tol. del solver, test de acotamiento (default = 1e-8).
//      imax          No. maximo de iteraciones            (default = 1e+3).
//      dcvar         Muestra los nombres de las covariables.

//
//	RESULTADOS:
//		blopmatching guarda los siguientes resultados en e():
//		e(b)	      Vector con el ATE y el ATET estimados.
//		e(V)		  Varianza de dichos estimadores.
//		e(N0)		  No de observaciones (total).
//		e(N1)		  No de observaciones (tratados).
//		e(N2)		  No de observaciones (controles).
//		e(Eff)		  Razon de exito del solver lineal.
//
//	AUTORES:
//		Juan Dsaz    (Universidad de Chile)
//		Tomas Rau    (Pontificia Universidad Catalica de Chile)
//		Jorge Rivera (Universidad de Chile)
//
//	VERSION:
//		1.0.
//
//	REFERENCIAS:
//	[1]	Diaz, J., Rau, T. y J. Rivera. 2015. A Matching Estimator Based on a
//		Bi-level Optimization Problem. Review of Economics and Statistics
//		(fortcoming).


//******************************************************************************
// Parte 1. Sintaxis del programa:
//******************************************************************************

capture program drop blopmatching
program define blopmatching, eclass byable(recall)
version 13.0
syntax [if] [in],       ///
	outcome  (varname)  ///
	controls (varlist)  ///
	treatment(varname)  ///
	[                   ///
	ttlevel(real    1)  ///
	utlevel(real    0)  ///
	level  (real   95)  ///
	otol   (real 1e-8)  ///
	btol   (real 1e-8)  ///
	imax   (real 1e+3)  ///
	dcvar               ///
	]

//******************************************************************************
// Parte 2. Preparacion de los datos:
//******************************************************************************

// 2.A. Variables Temporales del programa:
tempvar touse Wvar1 Wvar2

// 2.B. Re-etiquetacion de las variables (facilita la (mi) lectura):
local Yvar `outcome'
local Xvar `controls'
local Wvar `treatment'

// 2.C. Verificacion de los niveles del tratamiento:
quietly: levelsof `treatment', local(levels)
foreach l of local levels {
	if ("`l'" != "`ttlevel'") & ("`l'" != "`utlevel'") {
		display as error "Error: Treatment has not the correct levels"
		exit
	}
}

// 2.D. Identificacion de la muestra "efectiva" (una dummy: touse)
mark    `touse' `if'   `in'
markout `touse' `Yvar' `Wvar' `Xvar'

// 2.E. Identificacion de los grupos "efectivos" de tratamiento:
generate `Wvar1' = `touse'*(`Wvar' == `ttlevel')
generate `Wvar2' = `touse'*(`Wvar' == `utlevel')

//******************************************************************************
// Parte 3. Estimacion de ATE y ATT, en conjunto con sus varianzas:
//******************************************************************************

mata: blopmatching("`Yvar'"      , ///
				   "`Xvar'"      , ///
		           "`Wvar1'"     , ///
			       "`Wvar2'"     , ///
			       `otol'  		 , ///
			       `btol'   	 , ///
				   `imax'          ///
				   )

//******************************************************************************
// Parte 4. Conversion de los Resultados:
//******************************************************************************

// 4.A. Conversion del output con el fin de que sea mas facil de formatear:
tempname b V
local   N0  = r(N0)   // No de observaciones (total)
local   N1  = r(N1)	  // No de observaciones (tratados)
local   N2  = r(N2)   // No de observaciones (controles)
local   Eff = r(Eff)  // Razon de exito del solver lineal.
matrix `b'  = r(b)'   // ATE y ATET estimados.
matrix `V'  = r(V)    // Varianza de dichos estimadores.

// 4.B. Etiquetas para las filas y columnas de las matrices b y V:
matrix colnames `b' = "ATE" "ATT"   // Etiquetas - columnas de b.
matrix colnames `V' = "ATE" "ATT"   // Etiquetas - columnas de V.
matrix rownames `V' = "ATE" "ATT"   // Etiquetas - filas    de V.


//******************************************************************************
// Parte 5. Presentacion de los Resultados:
//******************************************************************************

// 5.A. Tabla General:
display as text ""
display as res  "Treatment-Effects Estimation"      as text  _column(47)
display as text "Method                   : blop matching"   _column(47)
display as text "LP Solution Method       : Revised Simplex" _column(47) ///
	"No of   treated Units = " %8.0f `N1'
display as text "1st Step Norm            : 1"               _column(47) ///
	"No of untreated Units = " %8.0f `N2'
display as text "2nd Step Distance Metric : Euclidean Norm"  _column(47) ///
	"Solver Efficacy       = " %8.0f `Eff'
ereturn post `b' `V', esample(`touse') // Obs: Tambien guarda b y V en e().
ereturn display, level(`level')
display as text "Outcome   variable : `Yvar'"
display as text "Treatment variable : `Wvar'"
display as text "Level of   treated : `ttlevel'"
display as text "Level of untreated : `utlevel'"
if "`dcvar'" != "" {
	display as text "Control  variables : `Xvar'"
}

// 5.B. Expansion de e() con los resultados secundarios:
ereturn scalar N0  = `N0'
ereturn scalar N1  = `N1'
ereturn scalar N2  = `N2'
ereturn scalar Eff = `Eff'

end
