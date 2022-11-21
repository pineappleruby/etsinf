;; Práctica hecha por Rubén Royo Marco 48413510

(defglobal ?*nod-gen* = 0)
(defglobal ?*prof* = 10)

(deffacts grid
	(limites 8 5)
	(agujero 1 3)
	(agujero 1 5)
	(agujero 2 1)
	(agujero 4 3)
	(agujero 4 5)
	(agujero 6 1)
	(agujero 7 5)
	(agujero 8 1)
	(agujero 8 3)
	(problema robot 2 3 latas l 3 1 l 3 3 l 6 4 nivel 0)
)


;; Inicio, éxito y fallo

(deffunction inicio ()
	(reset)
	(printout t "Profundidad Máxima:=" )
	(bind ?*prof* (read))
	(printout t "Tipo de Busqueda:" crlf
		"1.- Anchura" crlf
		"2.- Profundidad" crlf )
	(bind ?a (read))
	(if (= ?a 1)
		then (set-strategy breadth)
		else (set-strategy depth))
	(printout t "Ejecuta run para poner en marcha el programa" crlf)
)

(defrule objetivo
	(declare (salience 10))
	?f<-(problema robot $?a latas nivel ?nivel)
=>
	(printout t "SOLUCION ENCONTRADA EN EL NIVEL " ?nivel crlf)
	(printout t "NUMERO DE NODOS EXPANDIDOS O REGLAS DISPARADAS " ?*nod-gen* crlf)
	(printout t "HECHO OBJETIVO " ?f crlf)
	(halt)
)

(defrule no_solucion
	(declare (salience -10))
	?f<-(problema $?a nivel ?nivel)
=>
	(printout t "SOLUCION NO ENCONTRADA" crlf)
	(printout t "NUMERO DE NODOS EXPANDIDOS O REGLAS DISPARADAS " ?*nod-gen* crlf)
	(halt)
)


;; Mover robot

(defrule derecha
	?f<-(problema robot ?x ?y latas $?z nivel ?nivel)
	(limites ?lx ?ly)
	(test (<> ?x ?lx))
	(not (agujero =(+ ?x 1) ?y))
	(test (not (member$ (create$ l(+ ?x 1) ?y) $?z)))
	(test (< ?nivel ?*prof*))
=>
	(bind ?*nod-gen* (+ ?*nod-gen* 1))
	(assert (problema robot (+ ?x 1) ?y latas $?z nivel (+ ?nivel 1)))
)

(defrule izquierda
	?f<-(problema robot ?x ?y latas $?z nivel ?nivel)
	(test (<> ?x 1))
	(not (agujero =(- ?x 1) ?y))
	(test (not (member$ (create$ l(- ?x 1) ?y) $?z)))
	(test (< ?nivel ?*prof*))
=>
	(bind ?*nod-gen* (+ ?*nod-gen* 1))
	(assert (problema robot (- ?x 1) ?y latas $?z nivel (+ ?nivel 1)))
)

(defrule abajo
	?f<-(problema robot ?x ?y latas $?z nivel ?nivel)
	(test (<> ?y 1))
	(not (agujero ?x =(- ?y 1)))
	(test (not (member$ (create$ l ?x (- ?y 1)) $?z)))
	(test (< ?nivel ?*prof*))
=>
	(bind ?*nod-gen* (+ ?*nod-gen* 1))
	(assert (problema robot ?x (- ?y 1) latas $?z nivel (+ ?nivel 1)))
)

(defrule arriba
	?f<-(problema robot ?x ?y latas $?z nivel ?nivel)
	(limites ?lx ?ly)
	(test (<> ?y ?ly))
	(not (agujero ?x =(+ ?y 1)))
	(test (not (member$ (create$ l ?x (+ ?y 1)) $?z)))
	(test (< ?nivel ?*prof*))
=>
	(bind ?*nod-gen* (+ ?*nod-gen* 1))
	(assert (problema robot ?x (+ ?y 1) latas $?z nivel (+ ?nivel 1)))
)


;; Mover latas

(defrule lata_derecha
	?f<-(problema robot ?x ?y latas $?z l ?lax ?lay $?w nivel ?nivel)
	(limites ?lx ?ly)
	(test (<> ?lax ?lx))
	(not (agujero =(+ ?lax 1) ?lay))
	(test (not (member$ (create$ l (+ ?x 2) ?y) $?z)))
	(test (not (member$ (create$ l (+ ?x 2) ?y) $?w)))
	(test (and (= (- ?lax 1) ?x) (= ?lay ?y)))
	(test (< ?nivel ?*prof*))
=>
	(bind ?*nod-gen* (+ ?*nod-gen* 1))
	(assert (problema robot (+ ?x 1) ?y latas $?z l (+ ?lax 1) ?lay $?w nivel (+ ?nivel 1)))
)

(defrule lata_izquierda
	?f<-(problema robot ?x ?y latas $?z l ?lax ?lay $?w nivel ?nivel)
	(test (<> ?lay 1))
	(not (agujero =(- ?lax 1) ?lay))
	(test (not (member$ (create$ l (- ?x 2) ?y) $?z)))
	(test (not (member$ (create$ l (- ?x 2) ?y) $?w)))
	(test (and (= (+ ?lax 1) ?x) (= ?lay ?y)))
	(test (< ?nivel ?*prof*))
=>
	(bind ?*nod-gen* (+ ?*nod-gen* 1))
	(assert (problema robot (- ?x 1) ?y latas $?z l (- ?lax 1) ?lay $?w nivel (+ ?nivel 1)))
)

(defrule lata_abajo
	?f<-(problema robot ?x ?y latas $?z l ?lax ?lay $?w nivel ?nivel)
	(test (<> ?lay 1))
	(not (agujero ?lax =(- ?lay 1)))
	(test (not (member$ (create$ l ?x (- ?y 2)) $?z)))
	(test (not (member$ (create$ l ?x (- ?y 2)) $?w)))
	(test (and (= ?lax ?x) (= ?lay (- ?y 1))))
	(test (< ?nivel ?*prof*))
=>
	(bind ?*nod-gen* (+ ?*nod-gen* 1))
	(assert (problema robot ?x (- ?y 1) latas $?z l ?lax (- ?lay 1) $?w nivel (+ ?nivel 1)))
)

(defrule lata_arriba
	?f<-(problema robot ?x ?y latas $?z l ?lax ?lay $?w nivel ?nivel)
	(limites ?lx ?ly)
	(test (<> ?lay ?ly))
	(not (agujero ?lax =(+ ?lay 1)))
	(test (not (member$ (create$ l ?x (+ ?y 2)) $?z)))
	(test (not (member$ (create$ l ?x (+ ?y 2)) $?w)))
	(test (and (= ?lax ?x) (= ?lay (+ ?y 1))))
	(test (< ?nivel ?*prof*))
=>
	(bind ?*nod-gen* (+ ?*nod-gen* 1))
	(assert (problema robot ?x (+ ?y 1) latas $?z l ?lax (+ ?lay 1) $?w nivel (+ ?nivel 1)))
)


;; Triturar latas

(defrule agujero_derecha
	(declare (salience 5))
	?f<-(problema robot ?x ?y latas $?z l ?lax ?lay $?w nivel ?nivel)
	(limites ?lx ?ly)
	(test (<> ?lax ?lx))
	(agujero =(+ ?x 2) ?y)
	(test (and (= ?lax (+ ?x 1)) (= ?lay ?y)))
	(test (< ?nivel ?*prof*))
=>
	(bind ?*nod-gen* (+ ?*nod-gen* 1))
	(assert (problema robot (+ ?x 1) ?y latas $?z $?w nivel (+ ?nivel 1)))
)

(defrule agujero_izquierda
	(declare (salience 5))
	?f<-(problema robot ?x ?y latas $?z l ?lax ?lay $?w nivel ?nivel)
	(test (<> ?lax 1))
	(agujero =(- ?x 2) ?y)
	(test (and (= ?lax (- ?x 1)) (= ?lay ?y)))
	(test (< ?nivel ?*prof*))
=>
	(bind ?*nod-gen* (+ ?*nod-gen* 1))
	(assert (problema robot (- ?x 1) ?y latas $?z $?w nivel (+ ?nivel 1)))
)

(defrule agujero_abajo
	(declare (salience 5))
	?f<-(problema robot ?x ?y latas $?z l ?lax ?lay $?w nivel ?nivel)
	(test (<> ?lay 1))
	(agujero ?x =(- ?y 2))
	(test (and (= ?lax ?x) (= ?lay (- ?y 1))))
	(test (< ?nivel ?*prof*))
=>
	(bind ?*nod-gen* (+ ?*nod-gen* 1))
	(assert (problema robot ?x (- ?y 1) latas $?z $?w nivel (+ ?nivel 1)))
)

(defrule agujero_arriba
	(declare (salience 5))
	?f<-(problema robot ?x ?y latas $?z l ?lax ?lay $?w nivel ?nivel)
	(limites ?lx ?ly)
	(test (<> ?lay ?ly))
	(agujero ?x =(+ ?y 2))
	(test (and (= ?lax ?x) (= ?lay (+ ?y 1))))
	(test (< ?nivel ?*prof*))
=>
	(bind ?*nod-gen* (+ ?*nod-gen* 1))
	(assert (problema robot ?x (+ ?y 1) latas $?z $?w nivel (+ ?nivel 1)))
)
