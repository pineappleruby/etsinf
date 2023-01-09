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
