capture program drop blopmatch
program define blopmatch, eclass byable(recall)
version 13.0
syntax [if] [in],           ///
	outcome(varname)        ///
	treatment(varname)      ///
	covariates(varlist)     ///
	[                       ///
		ttlevel(real    1)  ///
		utlevel(real    0)  ///
		level  (real   95)  ///
		otol   (real 1e-8)  ///
		btol   (real 1e-8)  ///
		imax   (real 1e+3)  ///
		dcvar               ///
	]

* 1. Temporal objects
tempvar touse Wvar1 Wvar2
tempname b V

* 2. Relevant varlists
local Yvar `outcome'
local Xvar `covariates'
local Wvar `treatment'

* 3. Treatment levels check
quietly: levelsof `treatment', local(levels)
foreach level of local levels {
	if !inlist("`level'", "`ttlevel'", "`utlevel'") {
		display as error "Error: treatment has not the correct levels"
		exit
	}
}

* 4. Sample partition, according to Wvar
mark `touse' `if' `in'
markout `touse' `Yvar' `Wvar' `Xvar'
generate `Wvar1' = `touse' * (`Wvar' == `ttlevel')
generate `Wvar2' = `touse' * (`Wvar' == `utlevel')

* 5. BLOP-Matching (point and variance estimation)
mata: blopmatching(  ///
	"`Yvar'",        ///
	"`Xvar'",        ///
	"`Wvar1'",       ///
	"`Wvar2'",       ///
	`otol',          ///
	`btol',          ///
	`imax'           ///
)

* 6. Output re-allocation (facilitates formatting)
local   N0  = r(N0)                // No. of observations (total)
local   N1  = r(N1)	               // No. of observations (treated)
local   N2  = r(N2)                // No. of observations (untreated)
local   Eff = r(Eff)               // LP solver diagnostic
matrix `b'  = r(b)'                // Point estimators (ATE and ATT)
matrix `V'  = r(V)                 // Variance estimators (ATE and ATT)
matrix colnames `b' = "ATE" "ATT"  // Labels
matrix colnames `V' = "ATE" "ATT"  // Labels
matrix rownames `V' = "ATE" "ATT"  // Labels

* 7. Printed results
display as text ""
display as res  "Treatment-Effects Estimation"      as text  _column(47)
display as text "Method                   : Blop Matching"   _column(47)
display as text "LP Solution Method       : Revised Simplex" _column(47)        "No of   treated units = " %8.0f  `N1'
display as text "1st Step Norm            : Norm-1"          _column(47)        "No of untreated units = " %8.0f  `N2'
display as text "2nd Step Distance Metric : Euclidean Norm"  _column(47)        "Solver efficacy       = " %8.0f `Eff'
ereturn post `b' `V', esample(`touse')
ereturn display, level(`level')
if ("`dcvar'" == "") {
	display as text "Outcome            : `Yvar'"
	display as text "Treatment          : `Wvar'"
	display as text "Level of treated   : `ttlevel'"
	display as text "Level of untreated : `utlevel'"
}
else {
	display as text "Outcome            : `Yvar'"
	display as text "Treatment          : `Wvar'"
	display as text "Covariates         : `Xvar'"
	display as text "Level of treated   : `ttlevel'"
	display as text "Level of untreated : `utlevel'"
}

* 8. Saved results (`b' and `V' are saved by default)
ereturn scalar N0  =  `N0'
ereturn scalar N1  =  `N1'
ereturn scalar N2  =  `N2'
ereturn scalar Eff = `Eff'

end
