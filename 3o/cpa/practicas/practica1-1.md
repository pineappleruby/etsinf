# Computación Paralela - Práctica 1

Primero vamos a crear una carpeta en el disco W donde guardaremos las prácticas. La ruta será `W/cpa/prac1` y conviene que sea corta ya que la teclearemos a menudo.

# Sesión 1 - Integración numérica

Primero debemos compilar el archivo integral.c con el siguiente comando en el terminal:

```
$ gcc -Wall -o integral integral.c -lm
```

* **-o integral** le da el nombre de "integral" al fichero ejecutable

* **-lm** compila con la librería matemática. Es útil para códigos que usen funciones como *sin*, *cos*, *pow*, *exp*...

* **-Wall** muestra los warings

Ahora veamos el funcionamiento del programa. Para ejecutar el ejecutable de integral, debemos situarnos en la carpeta que lo contiene y teclear en el terminal:

```
$ ./integral 1
```

Con el "1" estamos eligiendo qué versión del algoritmo queremos utilizar. Adicionalmente podemos elegir el número de rectángulos (por defecto 100000) de la siguiente manera.

```
$ ./integral 1 500000
```

## 1.1 Paralelización de la primera variante

Vamos a copiar el código de **integral.c** y guardarlo en otro archivo llamado **pintegral**. En este código vamos a hacer que con la librería OpenMP (<omp.h>) se nos muestren el número de hilos activos del programa:

```c
...
#include <omp.h>
...
int main(int argc, char *argv[]) {
    ...
    #pragma omp parallel
    {
        int id = omp_get_thread_num();
        if (id == 0)
            printf("Número de hilos: %d\n", omp_get_num_threads());
    }
    ...
}
```

Para compilar el programa debemos añadir la opción `-fopenmp` de la siguiente forma:

```
$ gcc -fopenmp -Wall -o pintegral pintegral.c -lm
```

Por último, lo ejecutaremos con 4 hilos de la siguiente forma:

```
OMP_NUM_THREADS=4 ./pintegral 1
```

Esté código funciona de la siguiente manera:

1. `#pragma omp parallel` creo que hace que todos los hilos de tipo OpenMP ejecuten concurrentemente el código entre {}

2. Se imprime por pantalla la función `omp_get_num_threads()`, que devuelve el número de hilos activos en la sección paralela.

3. La estructura del `if` está para que el mensaje no se repita tantas veces como hilos haya. La función `omp_get_thread_num()` devuelve el número asociado a cada hilo que está ejecutando la sección paralela. Sólo podrá entrar al `if` e imprimir el mensaje el hilo que tenga 0 como ese número, es decir, el primer hilo.

Ahora vamos a paralelizar la primera variante del cálculo de la integral (`calcula_integral1()`). Para ello vamos a modificar el código de la función para que pase de estar así:

```c
double calcula_integral1(double a, double b, int n) {
    double h, s=0, result;
    int i;

    h=(b-a)/n;

    for (i=0; i<n; i++) {
        s+=f(a+h*(i+0.5));
    }

    result = h*s;
    return result;
}
```

A estar así:

```c
double calcula_integral1(double a, double b, int n) {
    double h, s=0, result;
    int i;

    h=(b-a)/n;

#pragma omp parallel for reduction(+:s)
    for (i=0; i<n; i++) {
        s+=f(a+h*(i+0.5));
    }

    result = h*s;
    return result;
}
```

La inclusión de `#pragma omp parallel for` hace que el bucle for se ejecute en paralelo con los hilos OpenMP. La parte de `reduction(+:s)` hace que los hilos tengan "s" como variable privada pero al final se devuelva una suma de todos los distintos resultados.

Para finalizar, compilamos y ejecutamos el código para comprobar que el resultado de **pintegral.c** es igual al de **integral.c**:

```
$ gcc -fopenmp -Wall -o pintegral pintegral.c -lm
```

```
OMP_NUM_THREADS=4 ./pintegral 1
```

## 1.2 Paralelización de la segunda variable

El código para paralelizar la segunda variante del cálculo de la integral (`calcula_integral2`) debe pasar de estar así:

```c
double calcula_integral2(double a, double b, int n) {
    double x, h, s=0, result;
    int i;

    h=(b-a)/n;

    for (i=0; i<n; i++) {
        x=a;
        x+=h*(i+0.5);

        s+=f(x);
    

    result = h*s;
    return result;
}
```

A estar así:

```c
double calcula_integral2(double a, double b, int n) {
    double x, h, s=0, result;
    int i;

    h=(b-a)/n;

#pragma omp parallel for reduction(+:s) private(x)
    for (i=0; i<n; i++) {
        x=a;
        x+=h*(i+0.5);

        s+=f(x);
    

    result = h*s;
    return result;
}
```

Como podemos observar, la parte de `#pragma omp parallel for reduction(+:s)` es igual a la primera versión. La diferencia entre las dos versiones es que en esta segunda, se utiliza una variable auxiliar "x". Esta variable se utiliza para calcular el resultado de "s", pero debe ser de uso exclusivo para cada uno de los hilos. Por tanto, usamos `private(x)` para denotar esto.

## 1.3 Ejecución del cluster (exclusivo UPV)

Vamos a utilizar el clúster de kahan para ejecutar nuestro código en él. Para ello lo primero que necesitamos hacer es conectarnos al nodo front-end mediante ssh:

```
$ ssh -l rroymar@alumno.upv.es kahan.dsic.upv.es
```

Es posible que nos salga un mensaje sobre la autenticidad del host 'kahan.dsic.upv.es' y nos pida nuestra contraseña.

Ahora mismo nos encontramos en el directorio home de kahan. Este tiene un disco W que corresponde al nuestro de la UPV. Vamos a comprobar que los archivos que hemos trabajado en esta práctica siguen ahí:

```
$ ls W/cpa/prac1
```

Kahan no es capaz de ejecutar los archivos contenidos en el disco W. Por tanto, debemos crear una carpeta en el home de kahan, situarnos en ella, compilar "pintegral.c" del disco W y almacenar el ejecutable dentro de la carpeta que acabamos de crear:

```
$ mkdir prac1
$ cd prac1
$ gcc -Wall -fopenmp -o pintegral ~/W/cpa/prac1/pintegral.c -lm
```

El carácter "~" indica el directorio home.

Podemos ejecutar el programa pintegral desde el nódo font-end aunque no es recomendable. Lo hacemos con el mismo comando que antes:

```
$ OMP_NUM_THREADS=4 ./pintegral 1
```

La ejecución de trabajos en el cluster debe hacerse mediante el sistema de colas SLURM. Para ello crearemos un ficheo de trabajo con el nombre "jobopenmp.sh" con el siguiente aspecto:

```
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --time=5:00
#SBATCH --partition=cpa

OMP_NUM_THREADS=3 ./pintegral 1
```

El archivo debe estar guardado en la carpeta `W/cpa/prac1`

La última línea sabemos lo que hace pero las precedidas por `#SBATCH` tienen los siguientes significados:

* **#SBATCH --partition=cpa**: El trabajo utilizará la cola (partición) llamada cpa

* **#SBATCH --nodes=1**: Usará un solo nodo del cluster (con sus 64 cores)

* **#SBATCH --time=5:00**: Tendrá un máximo de 5 minutos para su ejecución

A continuación debemos lanzar el trabajo al sistema de colas. Situandonos en el directorio `~/prac1` de kahan, escribimos el siguiente comando:

```
$ sbatch ~/W/cpa/prac1/jobopenmp.sh
```

Una vez lanzado, el sistema de colas nos devolverá el número de nuestro trabajo (en mi caso es 8769):

```
$ sbatch ~/W/cpa/prac1/jobopenmp.sh
Submitted batch job 8769
```

Si hay otros trabajos siendo ejecutados en ese momento, podemos consultar el estado de las colas con la orden squeue:

```
$ squeue
    JOBID   PARTITION   NAME        USER    ST  TIME    NODES   NODELIST(REASON)
    8769    cpa         jobopenmp   login   R   0:01    1       kahan01
```

También podemos cancelarlos con la orden scancel:

```
$ scancel 8769
```

Cuando acabe la ejecución, veremos que nos ha creado un archivo en `~/prac1` con el nombre `slurm-8769.out`. Al ejecutar el código no se nos mostrará la salida por terminal, sino que se nos guardará en este archivo. Para verlo podemos ejecutar una orden cat:

```
$ cat slurm-8769.out
Valor de la integral = 1.000000000041
Numero de hilos activos: 3
```

O también podemos copiarlo en nuestro disco W y leerlo con un editor de textos:

```
$ cp slurm-8769.out ~/W/cpa/prac1
```

## 1.4 Toma de tiempos

Podemos medir el tiempo de ejecución del programa para compararlo con su versión secuencial. Para ello, vamos a modificar el código de la siguiente forma:

```c
int main(int argc, char *argv[]) {
    double t1, t2;
    ...
    t1 = omp_get_wtime();

    switch (variante) {
        case 1:
            result = calcula_integral1(a,b,n);
            break;
        case 2:
            result = calcula_integral2(a,b,n);
            break;
        default:
            fprintf(stderr, "Numero de variante incorrecto\n");
            return 1;
    }

    t2 = omp_get_wtime();

    printf("Tiempo: %fs\n", t2 - t1);
    ...
}
```

Este código se guardará un instante de tiempo cuando comience y otro termine el cálculo de la integral (cualquiera de los dos). Luego los restará y mostrará por pantalla la diferencia.

Para comprobar las mejora que nos proporciona la ejecución secuencial, ejecutaremos el el cluster de kahan el programa con 500 millones de rectangulos. Primero lo haremos con 1 hilo (secuencial) y luego con 16 hilos (paralelo):

**jobsecuencial.sh**

```
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --time=5:00
#SBATCH --partition=cpa

OMP_NUM_THREADS=1 ./pintegral 1 500000000
```

**jobparalelo.sh**

```
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --time=5:00
#SBATCH --partition=cpa

OMP_NUM_THREADS=16 ./pintegral 1 500000000
```

En mi caso, la diferencia de tiempos ha sido de **9.511423 segundos**
