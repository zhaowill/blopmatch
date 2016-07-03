//******************************************************************************
//	blopmatching:
//******************************************************************************
//
//	PROPOSITO:
//		Estimacion del ATE y ATET (junto a sus varianzas) via blop matching.
//
//	ARGUMENTOS:
//	 	Yvar		string scalar	Variable de respuesta.
//		Xvar		string scalar	Variables de control.
//	 	Wvar1		string scalar	Identificador de los tratados.
//	 	Wvar2		string scalar	Identificador de los controles.
//		otol		real   scalar	Tolerancia (test de optimalidad).
//		btol		real   scalar	Tolerancia (test de acotamiento).
//      imax        real   scalar   No. maximo de iteraciones (simplex).
//
//	RESULTADOS:
//		Nada en mata, pero genera en Stata lo siguiente:
//	 	r(b)		real   matrix	Vector con el ATE y el ATT estimados.
//		r(V)		real   matrix	Varianza de dichos estimadores.
//	 	r(N0)		real   scalar	No de observaciones (total).
//	 	r(N1)		real   scalar	No de observaciones (tratados).
//		r(N2)		real   scalar	No de observaciones (controles).
//		r(Eff)		real   scalar	Razon de exito del solver lineal.
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

capture mata mata drop blopmatching()
version 13
mata:
void blopmatching(string scalar Yvar        , ///
				  string scalar Xvar        , ///
		          string scalar Wvar1       , ///
			      string scalar Wvar2       , ///
			      real   scalar otol 	    , ///
			      real   scalar btol 	    , ///
				  real   scalar imax          ///
			      )
// ok!.
{

//******************************************************************************
// Parte 2. Representacion matricial de (Y,X,W), segun grupo:
//******************************************************************************

// 2.A. Respuestas:
Y    = J(2, 1, NULL)
Y[1] = & st_data( ., Yvar, Wvar1)
Y[2] = & st_data( ., Yvar, Wvar2)

// 2.B. Covariables:
X    = J(2, 1, NULL)
X[1] = &(st_data( ., Xvar, Wvar1)')
X[2] = &(st_data( ., Xvar, Wvar2)')
// ok!.
// display("blopmatching: 2 ok")

//******************************************************************************
// Parte 3. Dimensiones relevantes del problema:
//******************************************************************************

N    = J(2,1,0)   	    // No. de observaciones, segun grupo de control.
K    = rows(*X[1])	    // No. de covariables.
N[1] = rows(*Y[1])	    // Grupo No. 1: Tratados.
N[2] = rows(*Y[2])	    // Grupo No. 2: Controles.
Nmax = max(N)           // El maximo entre N[1] y N[2]
N0   = N[1] + N[2]      // El largo de la muestra completa.
// ok!.
// display("blopmatching: 3 ok")

//******************************************************************************
// Parte 4. lambda's optimos, segun grupo (g) e individuo (i):
//******************************************************************************

// 4.A. Inicializacion:
l0 = J(2, Nmax, NULL)   // lambda's (valores).
B0 = J(2, Nmax, NULL)   // lambda's (ubicacion).
z0 = J(2, Nmax, NULL)   // Funcion objetivo (util para debuggear).
f0 = 0                  // Eficacia (acumulada) del solver lineal.

// 4.B. Actualizacion:
for (g=1;g<=2;g++) {
	h = 3 - g
	for (i=1;i<=N[g];i++) {

		// 4.B.1. Inicializacion de la solucion:
		l0[g,i] = &J(K+1,1,.)
		B0[g,i] = &J(K+1,1,.)
		z0[g,i] = &.

		// 4.B.2. Actualizacion de la solucion:
		blop((*X[g])[.,i] , ///
			 (*X[h])      , ///
			 (*l0[g,i])   , ///
			 (*B0[g,i])   , ///
			 (*z0[g,i])   , ///
			 (f0)         , ///
			 (otol)       , ///
			 (btol)       , ///
			 (imax)         ///
			 )
	}
}
// ok!.
// display("blopmatching: 4 ok")

//******************************************************************************
// Parte 5. Respuestas "imputadas" a partir del grupo contrario:
//******************************************************************************

// 5.A. Inicializacion:
Yb = J(2, 1, NULL)

// 5.B. Actualizacion:
for (g=1;g<=2;g++) {
	h     = 3 - g
	Yb[g] = &J(N[g], 1, .)
	for (i=1;i<=N[g];i++) {
		(*Yb[g])[i] = cross( *l0[g,i] , (*Y[h])[*B0[g,i]] )
	}
}
// ok!.
// display("blopmatching: 5 ok")

//******************************************************************************
// Parte 6. ATE y ATET estimados:
//******************************************************************************

ATE = sum(*Y[1] - *Yb[1])/N0 - sum(*Y[2] - *Yb[2])/N0
ATT = sum(*Y[1] - *Yb[1])/N[1]
b   = (ATE\ATT)
// ok!
// display("blopmatching: 6 ok")

//******************************************************************************
// Parte 7. c's optimos, segun grupo (g), individuo (i) y valor de alpha (a):
//******************************************************************************

// 7.A. Inicializacion:
c = J(2, 2, NULL)

// 7.B. Actualizacion:
for (a=1;a<=2;a++) {
	for (g=1;g<=2;g++) {
		h      = 3 - g
		c[a,g] = &J(N[g], 1, 0)
		for (i=1;i<=N[g];i++) {
			for (j=1;j<=N[h];j++) {
				row = selectindex(*B0[h,j] :== i)
				if (sizeof(row) == 1) {
					(*c[a,g])[i] = (*c[a,g])[i] + ((*l0[h,j])[row])^(a)
				}
			}
		}
	}
}
// ok!

//******************************************************************************
// Parte 8. phi's optimos, segun grupo (g) e individuo (i):
//******************************************************************************

// 8.A. Inicializacion:
// Innecesaria (podemos usar el output de la parte IV)

// 8.B. Actualizacion:
for (g=1;g<=2;g++) {
	cols = J(N[g],1,1)
	for (i=1;i<=N[g];i++) {
		cols[i] = 0
		blop((*X[g])[.,i]                 , ///
			 (*X[g])[.,selectindex(cols)] , ///
			 (*l0[g,i])                   , ///
			 (*B0[g,i])                   , ///
			 (*z0[g,i])                   , ///
			 (f0)                         , ///
			 (otol)                       , ///
			 (btol)                       , ///
			 (imax)                         ///
			 )
		cols[i] = 1
	}
}
// ok!

//******************************************************************************
// Parte 9. Respuestas "imputadas" a partir del grupo propio:
//******************************************************************************

// 9.A. Inicializacion:
Yt = J(2, 1, NULL)
// 9.B. Actualizacion:
for (g=1;g<=2;g++) {
	Yt[g] = &J(N[g], 1, .)
	ID    = 2 :: N[g]
	for (i=1;i<=N[g];i++) {
		(*Yt[g])[i] = cross( *l0[g,i] , (*Y[g])[ID[*B0[g,i]]] )
		if (i < N[g]) {
			ID[i] = i
		}
	}
}
// ok!

//******************************************************************************
// Parte 10. Varianza condicional, segun grupo (g) e individuo (i):
//******************************************************************************

// 10.A. Inicializacion:
s2 = J(2, 1, NULL)

// 10.B. Actualizacion:
for (g=1;g<=2;g++) {
	s2[g] = &J(N[g], 1, .)
	for (i=1;i<=N[g];i++) {
		s2i         = (*Y[g])[i] - (*Yt[g])[i]
		s2i         = s2i^2
		s2i         = s2i / (1 + norm(*l0[g,i])^2)
		(*s2[g])[i] = s2i
	}

}
// ok!

//******************************************************************************
// Parte 11. Varianza marginal:
//******************************************************************************

// 11.A. Varianza del ATE:
V11 = 0
for(g=1;g<=2;g++) {
	one = J(N[g],1,1)
	V11 = V11 + sum( (*Y[g] - *Yb[g]):^2 )
	V11 = V11 + cross( (*c[1,g]+one):^(2) , *s2[g] )
	V11 = V11 - cross( (*c[2,g]+one)      , *s2[g] )
}
V11 = (V11/N0   - ATE^2)/N0

// 11.B. Varianza del ATT:
V22 = 0
V22 = V22 + sum( (*Y[1] - *Yb[1]):^2 )
V22 = V22 + cross( (*c[1,2]):^(2)     , *s2[2] )
V22 = V22 - cross( (*c[2,2])          , *s2[2] )
V22 = (V22/N[1] - ATT^2)/N[1]

// 11.C. Varianza conjunta:
V = (V11 , 0 \ 0 , V22)
// ok!

//******************************************************************************
// Parte 12. Eficacia global del solver lineal (razon de exito):
//******************************************************************************
Reff = f0/(4*N0)

//******************************************************************************
// Parte 13. Resultados:
//******************************************************************************

st_rclear()
st_eclear()
st_matrix("r(b)", b)
st_matrix("r(V)", V)
st_numscalar( "r(N0)",   N0)
st_numscalar( "r(N1)", N[1])
st_numscalar( "r(N2)", N[2])
st_numscalar("r(Eff)", Reff)
// ok!

}
end
