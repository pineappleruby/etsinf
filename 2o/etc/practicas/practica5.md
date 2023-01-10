# Práctica 5 - Aritmética entera: Multiplicación y división

## Codificación de un formato horario y su inicialización

#### ¿Qué valor del reloj representa la palabra de bits `0x0017080A`?

Los bits que no son relevantes para la codificación que nos concierne los podemos ignorar (Bits relevantes marcados en negrita).

0000 0000 000**1 0111** 00**00 1000** 00**00 1010**

23:08:10

---

#### ¿Qué valor del reloj representa la palabra de bits `0xF397C84A`?

Los bits que no son relevantes para la codificación que nos concierne los podemos ignorar (Bits relevantes marcados en negrita).

1111 0011 100**1 0111** 11**00 1000** 01**00 1010**

23:08:10

---

#### Indique tres codificaciones distintas de la variable reloj para el valor horario 16:32:28

Se puede codificar la misma hora con distintos valores cambiando los "bits NO relevantes". (Bits relevantes marcados en negrita).

0000 0000 000**1 0000** 00**10 0000** 00**10 0000** (0x00102020)

0000 0000 000**1 0000** 00**10 0000** 01**10 0000** (0x00102060)

0000 0000 000**1 0000** 00**10 0000** 11**10 0000** (0x001020E0)

---

#### Cargue el fichero reloj.s y ejecútelo en el simulador. Tal y como está, el resultado mostrado
en la consola debe ser el siguiente:

> Pag. 3 Img. 1

---

#### ¿Por qué se ha impreso la hora 00:00:00?

Porque el valor de la variable reloj es una word toda a ceros.

---

#### Implemente la subrutina `inicializa_reloj`.

*Ejercicio guardado en **reloj1.s***

```r
########################################################## 
# Subrutina que inicializa el reloj
# Entrada:  $a0 con la dirección de la variable reloj
#           $a1 con la hora en formato HH:MM:SS
##########################################################

inicializa_reloj:
				sw $a1, 0($a0)
				jr $ra
```

---

#### Implemente la subrutina `inicializa_reloj_alt`.

*Ejercicio guardado en **reloj2.s***

```r
########################################################## 
# Subrutina que inicializa el reloj
# Entrada: $a0 con la dirección de la variable reloj
# 		   $a1 con las horas en formato HH
# 		   $a2 con los minutos en formato MM
# 		   $a3 con los segundos en formato SS
##########################################################

inicializa_reloj_alt:
				add $t0, $t0, $a1
				sll $t0, $t0, 8
				add $t0, $t0, $a2
				sll $t0, $t0, 8
				add $t0, $t0, $a3
				sw $t0, 0($a0)
				jr $ra
```

---

#### Implemente el código de las subrutinas `inicializa_reloj_hh`, `inicializa_reloj_mm` e `inicializa_reloj_ss`.

*Ejercicio guardado en **reloj3.s***

```r
########################################################## 
# Subrutinas que inicializan las horas/minutos/segundos 
# del reloj.
# Entrada: $a0 con la dirección de la variable reloj
# 		   $a1 con la hora en formato HH o MM o SS
##########################################################

inicializa_reloj_ss:
				sw $a1, 3($a0)
				jr $ra
				
inicializa_reloj_mm:
				sw $a1, 2($a0)
				jr $ra
				
inicializa_reloj_hh:
				sw $a1, 1($a0)
				jr $ra
```

---

#### En principio, un único valor de reloj HH:MM:SS puede codificarse de diferentes maneras según los valores que asignemos a los bits que no entran a formar parte de la codificación de los campos HH, MM y SS. Ahora queremos obligar a que todas las horas se representen de una única manera haciendo que los bits del reloj que no están definidos sean siempre cero. Por ejemplo, la hora 02:03:12 solamente se codifica como 0x0002030C, mientras que otras combinaciones como 0x6502030C, 0x89E203CC o 0xFFC2038C no están permitidas. ¿Cómo será ahora la subrutina ``inicializa_reloj`` para cumplir con esta condición?

Lo que queremos conseguir aquí es comprobar que `$a1` cumpla el formato propuesto y no tenga ningún bit fuera de lugar. Para ello, guardaremos en `$t0` los bits que permitimos que `$a1` tenga a 1. Al hacer el `or`, todos los bits que esten fuera de este rango quedarán reflejados en `$t1`.

> Ejemplo:
>
>`$t0` = 0011  
>`$a1` = 1001  
>`$t1` = 1011  

Por tanto, al hacer la comprobación con `bne`, si nota que los dos registros son distintos, es decir, si `$a1` no tiene el formato deseado, no guardará la hora en la variable `reloj`.

*Ejercicio guardado en **reloj4.s**:*

```r
########################################################## 
# Subrutina que inicializa el reloj
# Entrada: $a0 con la dirección de la variable reloj
# 		   $a1 con la hora en formato HH:MM:SS
##########################################################

inicializa_reloj:
				li $t0 0x001F3F3F
                # $t0 = 0000 0000 0001 1111
                #       0011 1111 0011 1111
				or $t1, $t0, $a1
				bne $t1, $t0, formato_incorrecto
				sw $a1, 0($a0)
formato_incorrecto:
				jr $ra
```

---

#### La siguiente subrutina opera sobre una variable reloj cuya dirección se pasa como argumento en el registro $a0 y con un valor X que se pasa en el byte menos significativo de $a1. Explique razonadamente qué efecto produce la ejecución de la subrutina.

```r
subrutina: 
                lw $t0, 0($a0)
                li $t1, 0x00FFFF00
                and $t0, $t0, $t1
                or $t1, $t0, $a1
                sw $t1, 0($a0)
                jr $ra
```

La subrutina actualiza los segundos de la variable `reloj` manteniendo las horas y los minutos. Cada instrucción hace lo siguiente:

A tener en cuenta: `0($a0)` = `reloj`

* **`lw $t0, 0($a0)`**: `$t0` = `reloj`
* **`li $t1, 0x00FFFF00`**: `$t1` = 0000 0000 1111 1111 1111 1111 0000 0000
* **`and $t0, $t0, $t1`**: `$t0` = horas y minutos de `reloj`
* **`or $t1, $t0, $a1`**: `$t1` = horas y minutos de `$t0` + segundos de `$a1`
* **`sw $t1, 0($a0)`**: `reloj` = `$t1`

---

## La multiplicación y la división de enteros y su coste temporal

> Leer

## La operación de multiplicación: conversión de HH:MM:SS a segundos

#### Para leer de memoria por separado cada uno de los campos del reloj (HH, MM y SS) se puede
usar una instrucción de lectura de byte. Razone si hay que utilizar lb (load byte) o lbu (load byte
unsigned).

> Preguntar al profe

#### Implemente la subrutina `devuelve_reloj_en_s`.

```r
        ########################################################## 
        # Subrutina que pasa el formato HH:MM:SS a segundos
        # Entrada: $a0 con la dirección de la variable reloj
				# Salida: %v0 con los segundos resultantes
        ########################################################## 
                
devuelve_reloj_
en_s:
				li $v0, 0
				
				lbu $v0, 3($a0)
				
				lbu $t0, 2($a0)
				li $t1, 60
				mult $t0, $t1
				mflo $t0
				addu $v0, $v0, $t0
				
				lbu $t0, 1($a0)
				li $t1, 3600
				mult $t0, $t1
				mflo $t0
				addu $v0, $v0, $t0
				
				jr $ra
```

#### ¿Qué tipo de instrucciones de suma han de utilizarse en la subrutina, add o addu?

> Pregunta al profe

#### ¿Cuántas instrucciones de multiplicación se ejecutan en la subrutina devuelve_reloj_en_s?

2

#### ¿Cuántas instrucciones de movimiento de información entre los registros del banco de enteros y
los registros hi y lo se ejecutan en la subrutina diseñada?

2

