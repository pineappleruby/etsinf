# Aritmética entera: sumas, restas y desplazamientos

## Multiplicación mediante sumas y desplazamientos

#### Escriba el código necesario para multiplicar el contenido del registro $a0 por la constante 36 ydevolver el resultado en el registro $v0 utilizando sumas y desplazamientos.

36 = 100100 = 2^5 + 2^2

```r
sll $v0, $a0, 5 # $v0 = $a0*2^5
sll $t0, $a0, 2 # $t0 = $a0*2^2
addu $v0, $v0, $t0 # $v0 = $a0*(2 3 + 2 2)
```
