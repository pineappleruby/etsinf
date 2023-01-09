### 1.2. Cálculo de Pi

El programa `mpi_pi.c` aproxima el valor de pi con el método de los rectángulos que vimos en la primera práctica. El intervalo [0, 1] se descompone en n subintervalos. Cada proceso realiza el cáclulo asociado a n/p rectángulos y lo guardan en la variable `mypi`:

```c
for (i = myid + 1; i <= n; i += numprocs) {...}
```

Tras ello, todos los procesos mandan el valor de su `mypi` (incluido el 0) a la variable `pi` del proceso 0:

```c
MPI_Reduce(&mypi, &pi, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);
```

> Tengo que mirar para qué sirven el argumento `1`. De hecho estaría guay apuntarme para qué sirven todos los argumentos para estudiar para el exámen.

#### Ejercicio 3

**Modifica el programa, sustituyendo la llamada a la función MPI_Reduce por un fragmento de código que sea equivalente pero utilice solo comunicaciones punto a punto (MPI_Send y MPI_Recv). Para ello, lo más sencillo es hacer que todos los procesos envíen su suma parcial (mypi) al proceso 0, el cual se encargará de recibir cada valor y acumularlo sobre la variable pi.**

Primero, debemos añadir 2 variables:

* **`int s`**:
* **`MPI_Status status`**:

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

> Para que sirve la *tag* en `MPI_Send()` y `MPI_Recv()`?

### 
