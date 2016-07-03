//******************************************************************************
// blop:
//******************************************************************************
//
//	PROPOSITO:
//		Solucion al blop que da nombre al blop-Mathching.
//
//	ARGUMENTOS:
//	 	x0          real matrix		El vector  x0 en (P1).
//		X           real matrix		La matriz  X  en (P1).
//	 	l0      	real matrix		Un vector arbitrario.
//	 	B0     		real matrix		Un vector arbitrario.
//	 	z0	     	real scalar		Un escalar arbitrario.
//	 	f0	     	real scalar		Un escalar arbitrario.
//		otol		real scalar		Tol. (test de optimalidad).
//		btol		real scalar		Tol. (test de acotamiento).
//      imax        real scalar		No. maximo de iteraciones (simplex).
//
//	RESULTADOS:
//		Nada, pero realiza las siguientes acutalizaciones:
//	 	l0      	Bloque basico de la SBF en el optimo (valores).
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
// 	REFERENCIAS:
//	[1]	Diaz, J., Rau, T. y J. Rivera. 2015. A Matching Estimator Based on a
//		Bi-level Optimization Problem. Review of Economics and Statistics
//		(fortcoming).


//******************************************************************************
// Parte 1. Sintaxis del programa:
//******************************************************************************

capture mata mata drop blop()
version 13
mata:
void blop(real matrix x0   	, ///
		  real matrix X    	, ///
		  real matrix l0   	, ///
		  real matrix B0   	, ///
		  real scalar z0  	, ///
		  real scalar f0  	, ///
		  real scalar otol	, ///
		  real scalar btol	, ///
		  real scalar imax	  ///
		  )
{
//******************************************************************************
// Parte 2. Dimensiones Relevantes para el programa:
//******************************************************************************

K = rows(X)	                          // No de covariables.
N = cols(X)	                          // No de observaciones.
// display("blop: 2 ok")

//******************************************************************************
// Parte 3. 1era Etapa del Algoritmo:
//******************************************************************************

// 3.A. Calculos Preliminares:
muID = 0+1 :: 1*K                     // Indices de B0 relativos a mu (inic)
nuID = K+1 :: 2*K                     // Indices de B0 relativos a nu (inic)
cri  = x0 - X[.,N] :>  0              // Criterio de entrada a B0 para mu/nu.
muID = muID[selectindex(cri :== 1)]   // Si cri[i]> 0, mu[i] es basico.
nuID = nuID[selectindex(cri :== 0)]   // Si cri[i]<=0, nu[i] es basico.
if (sum(cri) == 0) muID  = J(0,1,.)   // Necesario si muID esta vacio.
if (sum(cri) == K) nuID  = J(0,1,.)   // Necesario si nuID esta vacio.
// display("blop: 3a ok")

// 3.B. Especificacion del problema:
p   = (J(2*K,1,1) \ J(N,1,0))
A   = (I(K) , -I(K) , X \ J(1,2*K,0) , J(1,N,1))
b   = (x0 \ 1)
l0  = J(K+1,1,.)
B0  = (muID \ nuID \ N+2*K)
z0  = .
// display("blop: 3b ok")

// 3.C. Solucion del problema:
lpsolver(p     , ///
		 A     , ///
		 b     , ///
		 l0    , ///
		 B0    , ///
		 z0    , ///
		 f0    , ///
		 otol  , ///
		 btol  , ///
		 imax    ///
		 )
// display("blop: 3c ok")

//******************************************************************************
// Parte 4. 2nda Etapa del Algoritmo:
//******************************************************************************

// 4.A. Especificacion del problema [vea la Nota No 1]:

// 4.A.1. El vector p:
p = J(N,1,0)
for (j=1; j<=N; j++) {
	p[j] = norm(x0 - X[.,j])^2
}
// 4.A.2. La matriz A:
A   = (X \ J(1,N,1))
// 4.A.3. El vector Px0 (la proyeccion):
II  = (I(K) , -I(K))
Px0 = x0 - II[.,select(B0, B0:<=2*K)]*l0[selectindex(B0:<=2*K)]
// 4.A.4. El vector b:
b   = (Px0 \ 1)
// 4.A.5. El vector B0:
// 4.A.5.1. Inicializacion:
B0  = select(B0, B0 :> 2*K)
Q   = rows(B0)
B0  = B0 - J(Q,1,2*K)
// 4.A.5.2. Extension de B0 [vea la Nota No2]:
if ((Q < K+1) & (K+1 < N)) {
	// Complemento de B0, B0c:
	B0c     = 1 :: N
	B0c[B0] = J(Q,1,0)
	B0c     = select(B0c, B0c :!= 0)
	// Metodo 1 (simple pero poco robusto):
	if (rank(A[., (B0 \ B0c[(1 :: K+1 - Q)]) ]) == K+1) {
		B0 = (B0 \ B0c[(1 :: K+1 - Q)])
	}
	// Metodo 2 (robusto pero ineficiente):
	else {
		col = 1
		rk0 = rank(A[.,B0])
		while (rk0 < K + 1) {
			rk1 = rank(A[.,(B0 \ B0c[col])])
			if (rk1 > rk0) {
				B0 = (B0 \ B0c[col])
				rk0 = rk1
			}
			col++
		}
	}
}
// display("blop: 4a ok")

// 4.B. Solucion del problema:

if (N <= K+1) {
	l0 = qrsolve(A[.,B0],b)
}
else {
	lpsolver(p     , ///
			 A     , ///
			 b     , ///
			 l0    , ///
			 B0    , ///
			 z0    , ///
			 f0    , ///
			 otol  , ///
			 btol  , ///
			 imax    ///
			 )
}
// display("blop: 4b ok")
}
end

// *****************************************************************************
// Notas/Comentarios:
// *****************************************************************************
//
// Nota No. 1:
// Q1: Por que debemos formar las matrices p,A,b,B0?
// A1: Esto se debe a que nuestro solver lineal solo resuelve problemas
//     en forma estandar. Esto es:
//	   (P)		min_{x} p'*x
//				s.a.  A*x == b
//			 	        x >= 0
//     dada una base inicial factible A[.,B0] (vea Simplex.mata).
// Q2: Por que debemos formar el vector l0?
// A2: Para reemplazarlo por el valor optimo al utilizar la funcion Simplex.
//
// Nota No. 2:
// Q1: Por que es necesario actualizar B0?
// A1: Esto se debe a que Q puede ser mucho menor que K+1.
//   - Luego, si deseamos que A[.,B0] sea una base, debemos "completar" B0
//     con otros K+1-Q indices.
//   - Normalmente, cualesquiera servirian (este es el metodo 1).
//   - Sin embargo, si el metodo 1 falla en generar un A[.,B0] invertible,
//     tendremos que ir ampliando B0 UN termino a la vez, hasta que A[.B0]
//     alcance la invertibilidad deseada (este es el metodo 2).
