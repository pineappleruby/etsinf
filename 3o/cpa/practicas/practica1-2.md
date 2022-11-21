> Falta explicar los últimos 4 códigos y toda la vaina del último punto

# Computación Paralela - Práctica 2

# Sesión 2 - Procesamiento de Imágenes

> Quizá sería interesante comentar qué es un benchmark ya que vamos a trabajar con uno. Así como curiosidad, tampoco profundizando mucho.

## 2.1 Descripción del problema

Básicamente tenemos que aplicarle blur a una imagen (dejarla borrosa). Esto se hace cogiendo el valor de un pixel y sustituyendolo por la media de sus pixeles vecinos. Como pixeles vecinos entendemos aquellos que distan del nuestro un cierto radio. El filtrado se entiende mejor en la siguiente imagen:

> "Figura 6" del PDF de la Práctica 1

El valor del pixel desde que partimos se multiplica por cuatro. Luego los pixeles de los lados se multiplican por dos. Por ultimo se multiplican por uno los de las esquinas. Finalmente, todo se divide entre la suma de las multiplicaciones (4+2+2+2+2+1+1+1+1) y se aplica el resultado final al pixel de la nueva imagen. Este proceso se hace para todos y cada uno de los píxeles de la imágen.

## 2.2 Versión secuencial

> He escrito `NUM_PASOS 1` y `DIST_RADIO 5` para que concuerde con el resultado de la "Figura 9" del PDF de la Práctica 1.

La implementación en C de este algoritmo se encuentra en el archivo `imagenes.c`. No necesitamos comprender detalladamente el funcionamiento, pero nos conviene saber a grande rasgos qué hace el programa. Primero veamos como es el formato de las imágenes .ppm que vamos a utilizar:

```
P3                      <- Cadena constante que indica el formato (ppm, color RGB)
512 512                 <- Dimensiones de la imagen (filas y columnas)
255                     <- Mayor nivel de intensidad de RGB
224 137 125 225 135 ... <- 512x512x3 valores. Resolución de la imagen por RGB
```

Las imágenes en formato .ppm son básicamente archivos de texto que diferentes programas pueden interpretar (ej: infraview o display).

Ahora veamos el bucle principal del procesamiento de imagenes de nuestro programa:

```c
int Filtro(int pasos, int radio, struct pixel **ppsImagenOrg, struct pixel **ppsImagenDst, int n, int m) {
    ...
    for (p = 0; p < pasos; p++) {
        for (i = 0; i < n; i++) {
            for (j = 0; j < m; j++) {
                resultado.r = 0;
                resultado.g = 0;
                resultado.b = 0;
                tot = 0;
                for (k = max(0, i - radio); k <= min(n - 1, i + radio); k++) {
                    for (l = max(0, j - radio); l <= min(m - 1, j + radio); l++) {
                        v = ppdBloque[k - i + radio][l - j + radio];
                        resultado.r += ppsImagenOrg[k][l].r * v;
                        resultado.g += ppsImagenOrg[k][l].g * v;
                        resultado.b += ppsImagenOrg[k][l].b * v;
                        tot += v;
                    }   
                }
                resultado.r /= tot;
                resultado.g /= tot;
                resultado.b /= tot;
                ppsImagenDst[i][j].r = resultado.r;
                ppsImagenDst[i][j].g = resultado.g;
                ppsImagenDst[i][j].b = resultado.b;
            }
        }
        if (p+1 < pasos)
            memcpy(ppsImagenOrg[0], ppsImagenDst[0], n * m * sizeof(struct pixel));
    }
}
```

Tenemos 5 bucles en este código que se pueden dividir en 3 categorías:

1. Los dos últimos bucles se encargan de los píxeles vecinos de cada píxel seleccionado. El primero se encarga de la altura y el segundo de la anchura.

2. Los dos siguientes bucles pasan por todos y cada uno de los píxeles de la imagen. El primero se enarga de la anchura y el segundo de la altura.

3. El proceso que se le va a hacer a la imagen se puede hacer varias veces. El primer bucle repite el proceso tantas veces como `NUM_PASOS` tenga nuestro programa.

El funcionamiento del programa por tanto es el siguiente:

1. Leerá el contenido de un fichero de imagen cuyo nombre está especificado en `IMAGEN_ENTRADA`.

2. Aplicará el filtrado tantas veces como `NUM_PASOS` usando el radio `VAL_RADIO`.

3. Y escribirá el resultado en el fichero `IMAGEN_SALIDA`.

Vamos compilar el programa y a ejecutarlos para comprobar su funcionamiento:

```
~/W/cpa/prac1$ gcc -Wall -o imagenes imagenes.c -lm
~/W/cpa/prac1$ ./imagenes
Abierta una imagen de n:512
```

> "Figura 9" del PDF de la Práctica 1

Veremos que se ha creado una imágen con el nombre `lenna-fil.ppm`. Vamos a hacer una copia con el nombre `ref.ppm`. Este archivo nos servirá de referencia para compararlo más adelante con programas que vamos a desarrollar.

---

A continuación vamos a preparar el código para las versiones paralelas del siguiente punto.

Vamos a modificar el programa para que nos muestre tanto los hilos con los que se está ejecutando como el tiempo de ejecuciónd de la función que hace el filtrado:

```c
#include <omp.h>
...
int main(int argc, char *argv[]) {
    ...
    rc = Filtro(NUM_PASOS, DIST_RADIO, ImgOrg, ImgDst, n, m);
    if (rc) { printf("Error al aplicar el filtro\n"); return 2; }

    rc = escribe_ppm(IMAGEN_SALIDA, ImgDst, n, m);
    if (rc) { printf("Error al escribir la imagen\n"); return 3; }

    #pragma omp parallel
    {
        int id = omp_get_thread_num();
        if (id == 0)
            printf("Número de hilos: %d\n", omp_get_num_threads());
    }
    ...
}
```

```c
#include <omp.h>
...
int main(int argc, char *argv[]) {
    double t1, t2;
    ...
    t1 = omp_get_wtime();
    
    rc = Filtro(NUM_PASOS, DIST_RADIO, ImgOrg, ImgDst, n, m);
    if (rc) { printf("Error al aplicar el filtro\n"); return 2; }

    rc = escribe_ppm(IMAGEN_SALIDA, ImgDst, n, m);
    if (rc) { printf("Error al escribir la imagen\n"); return 3; }

    t2 = omp_get_wtime();

    #pragma omp parallel
    {
        int id = omp_get_thread_num();
        if (id == 0)
            printf("Número de hilos: %d\n", omp_get_num_threads());
    }

    printf("Tiempo: %fs\n", t2 - t1);
    ...
}
```

Por último vamos a conectarnos al cluster kahan, movernos sal directorio `~/prac1` y compilar el programa.

```
$ ssh -l login@alumno.upv.es kahan.dsic.upv.es
$ cd prac1
$ gcc -fopenmp -Wall -o imagenes ~/W/cpa/prac1/imagenes.c -lm
```

Además vamos a copiar todos los archivos con extensión `.ppm` desde el directorio `~/W/cpa/prac1/` hasta el directorio `~/prac1/`.

```
$ cp ~/W/cpa/prac1/*.ppm ~/prac1/
```

Por último vamos a crear un archivo con el nombre `imagenesV0.sh` en `~/W/cpa/prac1/`:

```
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --time=5:00
#SBATCH --partition=cpa

echo Imagenes: Versión Secuencial
echo ----------------------------
echo
OMP_NUM_THREADS=1 ./imagenes
```

Y vamos a lanzarlo con sbatch desde el cluster:

```
$ sbatch ~/W/cpa/prac1/imagenesV0.sh
```

Este tiempo nos servirá para el ejercicio del siguiente apartado

> Esta última parte que he metido entre dos líneas prodría ser un mini punto adicional, ya que es una preparación para la versión paralela.

---

## 2.3 Implementación paralela

Existen diferentes aproximaciónes para la implementación paralela y depende del bucle que elijamos paralelizar. El trabajo va a consistir en: analizar si cada bucle se puede paralelizar o no, qué variables deben ser compartidas o privadas, y probar la eficiencia de cada una de las versiones. Para ello debemos seguir los siguientes pasos:

1. Decidir si el bucle se puede paralelizar. Debemos comprobar que no hayan dependencias entre las distintas iteraciones y, en caso de haberlas, si se pueden solucionar con alguna clausula de OpenMP (como el sumatorio de reduction).

2. Escribir las directivas para paralelizar el bucle y decidir qué variables son privadas o compartidas.

3. Ejecutar el programa modificado en el cluster

4. Comprobar si el fichero generado (lenna-fil.ppm) es exáctamente igual que el que tenemos como referencia (ref.ppm). Para ello debemos ejecutar la siguiente orden: (si son iguales no muestra ningún mensaje)

```
$ cmp lenna-fil.ppm ref.ppm
```

Para realizar el trabajo tenemos una serie de orientaciones:

1. Es conveniente empezar a paralelizar desde el bucle más interno, ya que tenemos en cuenta menos variables

2. La clausula reduction no se puede usar para variable de tipo struct. Hay un truquito pero ara veré si se usa o no.

3. Algunas versiones paralelas son correctas pero lentísimas, por eso se recomienda empezar con 2 hilos.

Empecemos a analizar el código de las distintas versiones

### Versión 1

```c
#include <omp.h>
...
int Filtro(int pasos, int radio, struct pixel **ppsImagenOrg, struct pixel **ppsImagenDst, int n, int m) {
    int r, g, b;
    ...
    // Bucle 5
    for (p = 0; p < pasos; p++) {
        // Bucle 4
        for (i = 0; i < n; i++) {
            // Bucle 3
            for (j = 0; j < m; j++) {
                r = 0;
                g = 0;
                b = 0;
                tot = 0;
                // Bucle 2
                for (k = max(0, i - radio); k <= min(n - 1, i + radio); k++) {
                    // Bucle 1
                    #pragma omp parallel for private(l, v) reduction(+:r, g, b, tot)
                    for (l = max(0, j - radio); l <= min(m - 1, j + radio); l++) {
                        v = ppdBloque[k - i + radio][l - j + radio];
                        r += ppsImagenOrg[k][l].r * v;
                        g += ppsImagenOrg[k][l].g * v;
                        b += ppsImagenOrg[k][l].b * v;
                        tot += v;
                    }
                }
                r /= tot;
                g /= tot;
                b /= tot;
                ppsImagenDst[i][j].r = r;
                ppsImagenDst[i][j].g = g;
                ppsImagenDst[i][j].b = b;
            }
        }
        if (p+1 < pasos)
            memcpy(ppsImagenOrg[0], ppsImagenDst[0], n * m * sizeof(struct pixel));
    }
    ...
}
```

### Versión 2

```c
#include <omp.h>
...
int Filtro(int pasos, int radio, struct pixel **ppsImagenOrg, struct pixel **ppsImagenDst, int n, int m) {
    int r, g, b;
    ...
    // Bucle 5
    for (p = 0; p < pasos; p++) {
        // Bucle 4
        for (i = 0; i < n; i++) {
            // Bucle 3
            for (j = 0; j < m; j++) {
                r = 0;
                g = 0;
                b = 0;
                tot = 0;
                // Bucle 2
                #pragma omp parallel for private(l, v) reduction(+:r, g, b, tot)
                for (k = max(0, i - radio); k <= min(n - 1, i + radio); k++) {
                    // Bucle 1
                    for (l = max(0, j - radio); l <= min(m - 1, j + radio); l++) {
                        v = ppdBloque[k - i + radio][l - j + radio];
                        r += ppsImagenOrg[k][l].r * v;
                        g += ppsImagenOrg[k][l].g * v;
                        b += ppsImagenOrg[k][l].b * v;
                        tot += v;
                    }
                }
                r /= tot;
                g /= tot;
                b /= tot;
                ppsImagenDst[i][j].r = r;
                ppsImagenDst[i][j].g = g;
                ppsImagenDst[i][j].b = b;
            }
        }
        if (p+1 < pasos)
            memcpy(ppsImagenOrg[0], ppsImagenDst[0], n * m * sizeof(struct pixel));
    }
    ...
}
```

### Versión 3

```c
#include <omp.h>
...
int Filtro(int pasos, int radio, struct pixel **ppsImagenOrg, struct pixel **ppsImagenDst, int n, int m) {
    struct { int r, g, b; } resultado;
    ...
    // Bucle 5
    for (p = 0; p < pasos; p++) {
        // Bucle 4
        for (i = 0; i < n; i++) {
            // Bucle 3
            #pragma omp parallel for private(j, k, l, v, tot, resultado)
            for (j = 0; j < m; j++) {
                resultado.r = 0;
                resultado.g = 0;
                resultado.b = 0;
                tot = 0;
                // Bucle 2
                for (k = max(0, i - radio); k <= min(n - 1, i + radio); k++) {
                    // Bucle 1
                    for (l = max(0, j - radio); l <= min(m - 1, j + radio); l++) {
                        v = ppdBloque[k - i + radio][l - j + radio];
                        resultado.r += ppsImagenOrg[k][l].r * v;
                        resultado.g += ppsImagenOrg[k][l].g * v;
                        resultado.b += ppsImagenOrg[k][l].b * v;
                        tot += v;
                    }   
                }
                resultado.r /= tot;
                resultado.g /= tot;
                resultado.b /= tot;
                ppsImagenDst[i][j].r = resultado.r;
                ppsImagenDst[i][j].g = resultado.g;
                ppsImagenDst[i][j].b = resultado.b;
            }
        }
        if (p+1 < pasos)
            memcpy(ppsImagenOrg[0], ppsImagenDst[0], n * m * sizeof(struct pixel));
    }
}
```

### Versión 4

```c
#include <omp.h>
...
int Filtro(int pasos, int radio, struct pixel **ppsImagenOrg, struct pixel **ppsImagenDst, int n, int m) {
    struct { int r, g, b; } resultado;
    ...
    // Bucle 5
    for (p = 0; p < pasos; p++) {
        // Bucle 4
        #pragma omp parallel for private(i, j, k, l, v, tot, resultado)
        for (i = 0; i < n; i++) {
            // Bucle 3
            for (j = 0; j < m; j++) {
                resultado.r = 0;
                resultado.g = 0;
                resultado.b = 0;
                tot = 0;
                // Bucle 2
                for (k = max(0, i - radio); k <= min(n - 1, i + radio); k++) {
                    // Bucle 1
                    for (l = max(0, j - radio); l <= min(m - 1, j + radio); l++) {
                        v = ppdBloque[k - i + radio][l - j + radio];
                        resultado.r += ppsImagenOrg[k][l].r * v;
                        resultado.g += ppsImagenOrg[k][l].g * v;
                        resultado.b += ppsImagenOrg[k][l].b * v;
                        tot += v;
                    }   
                }
                resultado.r /= tot;
                resultado.g /= tot;
                resultado.b /= tot;
                ppsImagenDst[i][j].r = resultado.r;
                ppsImagenDst[i][j].g = resultado.g;
                ppsImagenDst[i][j].b = resultado.b;
            }
        }
        if (p+1 < pasos)
            memcpy(ppsImagenOrg[0], ppsImagenDst[0], n * m * sizeof(struct pixel));
    }
}
```

### Versión 5
Para hacer el paso siguiente del filtrado hay que tener la información del paso anterior. Por tanto, el quinto bucle no se puede paralelizar.

### Tiempo de las distintas versiones:

|          | Versión 0 | Versión 1 | Versión 2 | Versión 3 | Versión 4 |
| -------- | --------- | --------- | --------- | --------- | --------- |
| 1 hilo   | 0.458899s |           |           |           |           |
| 2 hilos  |           | 6.827265s | 1.008046s | 0.342422s | 0.358536s |
| 8 hilos  |           | 27.28138s | 2.623487s | 0.250312s | 0.233427s |
| 32 hilos |           | 77.81666s | 7.168158s | 0.208640s | 0.233872s |
