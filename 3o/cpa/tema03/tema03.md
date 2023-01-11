# Tema 3 - Paso de Mensajes. Diseño Avanzado de Algoritmos Paralelos

## Modelo de Paso de Mensajes

### Modelo de Paso de Mensajes

* Las tareas manejan su **espacio de memoria privado**.
* Se **intercambian datos** a través de **mensajes**.
* La comunicación suele requerir operaciones coordinadas **(envío y recepción)**.
* **Prograciación laboriosa** / control total de la paralelización.

### Creación de Procesos

Un programa paralelo se compone de diferentes procesos.

* Normalmente **un proceso por procesador**.
* Cada uno tiene un **identificador**.

La creación de procesos puede ser:

* **Estática**: al inicio del programa
  * Línea de comandos **(mpiexec)**.
  * Existen durante toda la ejecución.
* **Dinámica**: durante la ejecución
  * Primitiva **`spawn()`**

### Comunicadores

> Volver a leer (pag.3)

### Operaciones básicas de Envío/Recepción

> Hacer los apuntes (pag.4)

### Ejemplo: Suma de Vectores

> Volver a leer (pag.4)

### Envío con Sincronización

> Hacer los apuntes (pag.5)

### Modalidades de Envío/Recepción

Envío **con buffer** / Envío **síncrono**

* Con buffer:
  * Un buffer almacena la copia temporal del mensaje.
  * El `send` finaliza cuando el mensaje se ha copiado.
* Envío síncrono:
  * El `send` no finaliza hasta que se inicia el `recv` correspondiente y se hace la transferencia.

Operaciones **bloqueantes** / Operaciones **no bloqueantes**

* Bloqueante:
  * Al finalizar el `send`, es seguro modificar la variable que se ha enviado.
  * Al finalizar el `recv`, se garantiza que la variable contiene el valor recibido.
* No bloqueante:
  * El proceso simplemente inicia la operación y, mientras esta hace las transferencias, el proceso sigue ejecutando el resto de sus sentencias.

> Comprobar que la explicación de "no bloqueante" está bien

### Finalización de la Operación

En las operaciones no bloqueantes tenemos que tener en cuenta cuales son las dependencias entre sentencias. Por ejemplo, si vamos a enviar el dato de una variable `x` pero luego queremos modíficarlo, tenemos que comprobar de alguna forma que la transferencia ha finalizado. Por eso las funciones `send()` y `recv` no bloqueantes nos dan un número de operación `req`.

Primitivas:

* **`wait(req)`**: El proceso se bloquea hasta que ha terminado la operación.
* **`test(req)`**: Indica si la operación ha finalizado o no.
* **`waitany()`** y **`waitall()`**: Cuando hay varias operaciones pendientes.

### Selección de Mensajes

> Hacer los apuntes (pag.6)

### Problema: Interbloqueo

> Hacer los apuntes (pag.7)

### Problema: Serialización

> Hacer los apuntes (pag.7)

### Comunicación Colectiva

> Hacer los apuntes (pag.8)

### Comunicación Colectiva: Tipos

> Hacer los apuntes (pag.8)

## Esquemas Algorítmicos (II)

### Paralelismo de Datos / Particionado de Datos

> Hacer los apuntes (pag.9)

> Apuntar los costes que hay en el segundo apartado en una sección glosario o algo así

### Caso 1: Producto Matriz-Vector

> Volver a leer (pag.10)

### Caso 2: Búsqueda Lineal

> Volver a leer (pag.10,11)

### Caso 3: Suma de Elementos de un Vector

```
var v,s,n,p,vloc,sl

suma(v,s,n,p) {
  distribuir(v,vloc,n,p)
  sumalocal(vloc,sl,n,p)
  reducir(sl,s,p)
}

distribuir(v,vloc,n,p) {
  for(int i=0; i++; i < p) {
    k = n/p
    if (i==0) {
      for(int j=1; j++; j < p) {
        enviar(v[j*k:(j+1)*k-1],j)
      }
    }
  }
}
```

> Volver a leer (pag.11)

> Intuyo que [x:y] es un rango

### Esquemas en Árbol

> Volver a leer (pag.12)

### Paralelismo de Tareas

> Volver a leer (pag.12)

### Maestro-Trabajadores

> Volver a leer (pag.13)

## Evaluación de Prestaciones (II)

### Tiempo de Ejecución Paralelo

**Definición**: Tiempo que tarda un algoritmo paralelo con $p$ procesadores desde que empieza el primero hasta que acaba el último.

Se descompone en: tiempo **aritmético** y de **comunicaciones**

$
t(n,p)=t_a(n,p)+t_c(n,p)
$

* **$t_a$** corresponde a todos los tiempos de cálculo:
  * Todos los procesadores calculan concurrentemente.
  * Es como mínimo igual al máximo aritmético.
* **$t_c$** corresponde a tiempos asociados a transferencia de datos:
  * En memoria distribuida: $t_c =$ tiempo de envío de mensajes
  * En memoria compartida: $t_c =$ tiempo de sincronización

> No entiendo qué es la $n$

> Volver a leer (pag.14)

### Modelado del Tiempo de Comunicación

Suponiendo paso de mensajes $P_0$ y $P_1$ en nodos distintos con conexión directa, el tiempo necesario para enviar un mensaje de $n$ bytes es: $t_s + t_w\times n$

* **$t_s$**: Tiempo de **establecimiento** de la comunicación.
* **$w$**: Ancho de banda (máximo número de bytes por seg).
* **$t_w=\frac{1}{w}$**: Tiempo de envío de 1 byte.

Recomendaciones:

* Agrupar varios mensajes en uno solo ($n$ grande, un único $t_s$).
* Evitar demasiadas comunicaciones simultáneas.

### Ejemplo: Producto Matriz-Vector(1)

> Volver a leer (pag.15)

### Ejemplo: Producto Matriz-Vector(2)

> Volver a leer (pag.16)

### Ejemplo: Producto Matriz-Vector(3)

> Volver a leer (pag.16)

### Parámetros Relativos

Los parámetros relativos sirven para comparar un algoritmo paralelo con otro. Normalmente se aplican en el análisis experimental, aunque el **speedup** y la **eficiencia** se pueden obtener en el análisis teórico.

#### Speedup

#### Eficiencia

#### Casos posibles

> Hacer los apuntes (pag.17,18)

## Esquemas de Asignación
