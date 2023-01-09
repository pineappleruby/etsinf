### 1.2. Cálculo de Pi

El programa `mpi_pi.c` aproxima el valor de pi con el método de los rectángulos que vimos en la primera práctica. El intervalo [0, 1] se descompone en n subintervalos. Cada proceso realiza el cáclulo asociado a n/p rectángulos y lo guardan en la variable `mypi`:

```c
for (i = myid + 1; i <= n; i += numprocs) {...}
```

Tras ello, todos los procesos mandan el valor de su `mypi` (incluido el 0) a la variable `pi` del proceso 0:

```c
MPI_Reduce(&mypi, &pi, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);
```

> [Q] Tengo que mirar para qué sirven el argumento `1`. De hecho estaría guay apuntarme para qué sirven todos los argumentos para estudiar para el exámen.

#### Ejercicio 3

**Modifica el programa, sustituyendo la llamada a la función MPI_Reduce por un fragmento de código que sea equivalente pero utilice solo comunicaciones punto a punto (MPI_Send y MPI_Recv). Para ello, lo más sencillo es hacer que todos los procesos envíen su suma parcial (mypi) al proceso 0, el cual se encargará de recibir cada valor y acumularlo sobre la variable pi.**

Primero, debemos añadir 2 variables:

* **`int s`**: Buffer del proceso 0 para guardar las variables `pi` que recibe tras los cáclulos.
* **`MPI_Status status`**: Hay que declarar una variable status para poder usar la función `MPI_Recv()`.

Y la variable `mypi` ya no la vamos a usar. En su lugar, haremos la suma sobre la variable `pi` de cada proceso.

Luego, eliminamos la función `MPI_Reduce()` y la sustituimos por:

```c
if(myid == 0) {
  for(i=1; i<numprocs; i++){
    MPI_Recv(&s, 1, MPI_DOUBLE, i, 0, MPI_COMM_WORLD, &status);
    pi += s;
  }
} else {
  MPI_Send(&pi, 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
}
```

Este código hace que todos los procesos menos el 0 manden el valor de su `pi` a 0. Este último, recibe por orden (del 1 a numprocs) estos valores, los almacena en el buffer `s` y los suma a su variable `pi`.

> [Q] Para que sirve la *tag* en `MPI_Send()` y `MPI_Recv()`?

### 1.3 El programa *ping-pong*

Una forma muy común de obtener los parámentros de la red es hacer un programa tipo *ping-pong*. Esto consiste en un programa con 2 procesos. El primero manda un mensaje al segundo, que lo devuelve inmediatamente, y mide los tiempos.

#### Ejercicio 4

**Completa el programa ping-pong.c para que haga lo que se explica en el párrafo anterior, teniendo en cuenta lo siguiente:**

* El programa tiene como argumento el tamaño del mensaje, n (en bytes).
* Usa la función MPI_Wtime() para medir tiempos. Se usa exactamente igual que la función de OpenMP omp_get_wtime().
* Para que los tiempos medidos sean significativos, el programa debe repetir la operación cierto número de veces (NREPS) y mostrar el tiempo medio.
* Utiliza las primitivas estándar para envío y recepción de mensajes: MPI_Send y MPI_Recv, indicando MPI_BYTE como tipo de los datos a enviar/recibir.

Primero, declaramos 3 variables nuevas:

* **`int i`**: Contador para las repeticiones.
* **`double f1`** **`double f2`**: Variables para medir tiempos.

---

Cosas interesantes a destacar:

* En la "función ping-pong", en el los argumentos de "status" de la función `MPI_Recv()` se pone `MPI_STATUS_IGNORE`. Entiendo que esto se hace para que no se compruebe el mensaje y se devuelva rápidamente.

#### Ejercicio 5

**¿Por qué se envían dos mensajes en cada iteración del bucle? ¿se podría eliminar el mensaje de respuesta de P1 a P0?**

Se podrían enviar NREPS+1 mensajes, que tras recibir el primero empiece el contador y que tras recibir el último se pare. Así la media seria: tiempo/NREPS.

#### Ejercicio 6

**En cada iteración, el proceso P0 tiene que hacer un envío y una recepción. ¿Podría utilizar para ello la función MPI_Sendrecv_replace? ¿Y el proceso P1?**

Yo diría que sí. En cada uno y en los dos a la vez.

## 2. Fractales de Newton

