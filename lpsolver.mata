//******************************************************************************
//	lpsolver:
//******************************************************************************
//
//	PROPOSITO:
//		Resolver el PPL
//		(P)		min_{x} p'*x
//				s.a.  A*x == b
//			 	        x >= 0
//		con el Metodo Simplex Revisado.
//
//	ARGUMENTOS:
//	 	p           real matrix		El vector  p en (P).
//		A           real matrix   	La matriz  A en (P).
//	 	b      	    real matrix		El vector  b en (P).
//	 	xB     		real matrix		Un vector arbitrario.
//	 	B0    	    real matrix		Listado basico factible inicial.
//	 	z0	     	real scalar		Un escalar arbitrario.
//	 	f0	     	real scalar		Un escalar arbitrario.
//		otol		real scalar     Tol (test de optimalidad).
//		btol		real scalar     Tol (test de acotamiento).
//		imax		real scalar     No. maximo de iteraciones (simplex).
//
//	RESULTADOS:
//		Nada, pero realiza las siguientes actualizaciones:
//	 	xB      	Bloque basico de la SBF en el optimo (valores).
//	 	B0     		Bloque basico de la SBF en el optimo (ubicaciones).
//	 	z0	     	Valor de la funcion objetivo en el optimo.
//	 	f0	     	f0 + 1 por cada exito del solver.

//
//	AUTORES:
//		Juan Diaz    (Universidad de Chile)
//		Tomas Rau    (Pontificia Universidad Catolica de Chile)
//		Jorge Rivera (Universidad de Chile)
//
//	VERSION:
//		1.0.
//
// 	REFERENCIAS
//	[1]	Ferris, M., Mangasarian, O. & S. Wright. 2007. Linear Programming
//		with MATLAB. MPS-SIAM Series on Optimization.


//******************************************************************************
// Parte I. Sintaxis del programa:
//******************************************************************************

capture mata mata drop lpsolver()
version 13
mata:
void lpsolver(real matrix p     , ///
			  real matrix A     , ///
			  real matrix b     , ///
			  real matrix xB    , ///
			  real matrix B0    , ///
			  real scalar z0    , ///
			  real scalar f0    , ///
			  real scalar otol	, ///
			  real scalar btol	, ///
			  real scalar imax    ///
			  )
{

// *****************************************************************************
// Parte II. Calculos Preliminares:
// *****************************************************************************

// 1. Dimensiones del Problema:
m = rows(A)   // No de Restricciones.
n = cols(A)   // No de Variables.

// 2. Complemento de B0 (N0):
N0     = 1::n
N0[B0] = J(m,1,0)
N0     = select(N0, N0 :!= 0)

// 3. Factorizacion LU de A[.,B0]:
L    = J(m,m,0)
U    = J(m,m,0)
perm = J(m,1,0)
lud(A[.,B0],L,U,perm)

// *****************************************************************************
// Parte III. Actualizacion de la base factible hasta llegar a un veredicto:
// *****************************************************************************

for (iter=1; iter<=imax; iter++) {
	// 1. Factorizacion LU de A_{B}:
	lud(A[.,B0],L,U,perm) // [Vea la Nota No 1].

	// 2. Calculo de h := A_{B}^{-1}b
	h = lusolve(U,lusolve(L,b[invorder(perm)]))

	// 3. Calculo de u y c', donde ...
	u = lusolve(L',lusolve(U',p[B0]))  // u = (A_{B}')^{-1}p_{B} (paso 1).
	u = u[perm]                        // u = (A_{B}')^{-1}p_{B} (paso 2).
	ctr = p[N0]'-u'*A[.,N0]            // c' = p_{N}' - u_{N}'A_{.N}.

	// 4. Test de Optimalidad:
	if (all(ctr :> -otol) == 1) {
		xB = h
		B0 = B0
		z0 = u'*b
		f0 = f0 + 1
		return
	}

	// 5. Eleccion de la variable entrante (Random Edge):
	cneg = selectindex(ctr :<= -otol)
	//s    = cneg[ceil(cols(cneg)*runiform(1,1))]   // (Random Edge)
	s    = cneg[1]   // Bland rule.

	// 6. Calculo del pivote:
	d = lusolve(U,lusolve(L,A[invorder(perm),N0[s]]))

	// 7. Test de Acotamiento:
	if (all(d :< btol) == 1) {
		xB = J(m,1,.)
		B0 = J(m,1,.)
		return
	}

	// 8. Eleccion de la variable saliente (Bland):
	blocking = selectindex(d :>= btol)
	minindex(h[blocking]:/d[blocking], 1, index_r, w)
	r = blocking[index_r[1]]

	// 9. Actualizacion de los listados B0 y N0:
	swap  = B0[r]
	B0[r] = N0[s]
	N0[s] = swap

}

}
end

// *****************************************************************************
// Notas:
// *****************************************************************************
//
// Nota 1:
// Q: Por que la Descomposicion LU difiere de la que aparece en el texto guia?
// A: Esto es porque, a diferencia de MATLAB, la descomposicion LU ejecutada
//    por mata es de la forma A = PLU, donde P es una matriz de permutacion,
//    L es una matriz trianqular inferior y U es una matriz trianqular superior.
