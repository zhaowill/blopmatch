{smcl}
{* *! version 1.0.0 19jun2015}{...}
{vieweralsosee "[R] help" "help help "}{...}
{viewerjumpto "Syntax" "blopmatching##syntax"}{...}
{viewerjumpto "Description" "blopmatching##description"}{...}
{viewerjumpto "Remarks" "blopmatching##remarks"}{...}
{viewerjumpto "Options Details" "blopmatching##options"}{...}
{viewerjumpto "Examples" "blopmatching##examples"}{...}
{viewerjumpto "Notes" "blopmatching##notes"}{...}
{viewerjumpto "Authors" "blopmatching##authors"}{...}
{viewerjumpto "References" "blopmatching##references"}{...}

{title:Title}

{phang}
{bf:blopmatching} {hline 2} Treatment effects estimation by blop matching.


{marker syntax}{...}
{title:Syntax}

{phang}
{cmdab:blopmatching}
{ifin}
{cmd:, }
outcome({it:varname})
treatment({it:varname})
controls({it:varlist})
[{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr: Required Arguments}
{synoptline}
{syntab:Variables}
{synopt :{opt outcome}  }Outcome  {space 1} variable.   {p_end}
{synopt :{opt treatment}}Treatment          variable.   {p_end}
{synopt :{opt controls} }Control  {space 1} variable(s).{p_end}
{synoptline}

{synoptset 20 tabbed}{...}
{synopthdr: Optional Arguments}
{synoptline}
{syntab:Treatment Levels}
{synopt:{opt ttlevel}}Specify the treatment level for the {space 2}treated subjects, default is 1. {p_end}
{synopt:{opt utlevel}}Specify the treatment level for the        untreated subjects, default is 0. {p_end}
{syntab:Reporting}
{synopt:{opt level}}Set confidence level, default is 95.      {p_end}
{synopt:{opt dcvar}}Display names of control variables. {p_end}
{syntab:LP solver}
{synopt:{opt otol}}Solver tolerance (optimality{space 1} test), default is 1e-8. {p_end}
{synopt:{opt btol}}Solver tolerance (boundedness         test), default is 1e-8. {p_end}
{synopt:{opt btol}}Maximum number of iterations{space 6}      , default is 1e+3. {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:by} is allowed; see {manhelp by D}.{p_end}


{marker description}{...}
{title:Description}

{pstd}{bf:blopmatching} estimates treatment effects from observational data by blop matching.
blop matching imputes the missing potential outcome for each subject by using an weighted
average of the outcomes of all the subjects that receive the other treatment level.
The vector of weights for each subject is determined by solving a Bi-Level Optimization Problem (blop).

{pstd}{space 2}- In the 1st optimization problem, the program finds a set of weights such
that the weighted sum of the observations [note 1] has exactly the same covariate values as the unit to be {p_end}
{pstd}{space 3} matched, when possible, or otherwise their distance is minimized.{p_end}
{pstd}{space 2}- In the 2nd optimization problem, the program implements a
refinement criterion that looks for the weights that minimizes a weighted sum of distances [note 2].

{pstd}Once the weights are determined, 2 treatment effects are calculated:

{pstd}{space 2}- The ATE [note 3] is computed by taking the average of the difference
between the observed and imputed potential outcomes for each subject.{p_end}
{pstd}{space 2}- The ATT [note 4] is computed by taking the average
of the difference between the observed and imputed potential outcomes for each
subject in the treatment group.

{pstd}See {help blopmatching##DRR2015:Rivera et al.(2015)} for more details.

{marker remarks}{...}
{title:Remarks}

{marker options}{...}
{title:Options}

{dlgtab: Treatment}
{phang}
{opt ttlevel}{space 4} Specify the treatment level for the {space 2}treated subjects, default is 1.  {p_end}
{p 4 4 2}
{opt utlevel}{space 4} Specify the treatment level for the        untreated subjects, default is 0. {p_end}

{dlgtab: Reporting}
{phang}
{opt level}{space 6} Set confidence level. See {helpb estimation options:[R] estimation options}.  {p_end}
{p 4 4 2}
{opt dcvariables} Specifies that the matching variables be displayed. {p_end}

{dlgtab: LP Solver}
{phang}
{opt otol}{space 7} Let (P) be a standard LP problem and let c be the current reduced cost.
                    It is well known that if c > 0 the current solution is optimal. {p_end}
{space 5}           However, this rule is impractical due to round-off errors. otol relax this condition.
{p 4 4 2}
{opt btol}{space 7} Let (P) be a standard LP problem and let d be the current pivot column.
                    It is well known that if d < 0 the problem is unbounded. {p_end}
{space 5}           However, this rule is impractical due to round-off errors. btol relax this condition.
{phang}


{marker examples}{...}
{title:Example}

{pstd}Load Lalonde (1986) dataset {p_end}
{phang2}{cmd:. use "lalonde.dta", clear}  {p_end}

{pstd}Load Standardize re75 {p_end}
{phang2}{cmd:. egen stdre75 = std(re75)}  {p_end}

{pstd}Estimate the average treatment effect of {it:treat} on {it:re78} using {it:age education black hispanic married nodegree stdre75} as control variables: {p_end}
{phang2}{cmd:. blopmatching, outcome(re78) treatment(treat) controls(age education black hispanic married nodegree stdre75)} {p_end}


{marker notes}{...}
{title:Notes}


{phang}[1] The weights are meant to be positives and sum one, so weighted sums are in fact convex combinations. {p_end}
{phang}[2] It can be shown that each of this 2 problems can be rewritten as a LP. Unfortunately, mata still doesn't have an official LP solver,{p_end}
{phang}{space 3} so we created our own LP solver from scratch. This solver, lpsolver.mata, is an inefficient (but reliable) implementation of the revised simplex algorithm {p_end}
{phang}{space 3} (see {help blopmatching##FMW2007:Ferris et al.(2007)} for more details). {p_end}
{phang}[3] ATE means {it: average treatment effect}. {p_end}
{phang}[4] ATT means {it: average treatment effect on the treated}.

{marker authors}{...}
{title:Authors}

{phang}Juan Diaz  {space 3}, Universidad de Chile.{p_end}
{phang}Tomas Rau  {space 3}, Pontificia Universidad Catolica de Chile. {p_end}
{phang}Jorge Rivera{space 1}, Universidad de Chile.

{marker references}{...}
{title:References}

{marker DRR2015}{...}
{phang}
Díaz, J., Rau, T., and J. Rivera (2015). A Matching Estimator Based on a Bilevel Optimization Problem. {it:Review of Economics & Statistics} 97(4): 803-812.

{marker FMW2007}{...}
{phang}
Ferris, M., Mangasarian, O. and S. Wright (2007). Linear Programming with MATLAB.{it: MPS-SIAM Series on Optimization}.
