# pcic-fcar251
Fundamentos del Computo de Alto Rendimiento

# Algoritmos de divide y vencerás

- Face de dividir datos
- Face de pegado de resultados

Árbol de divisiones: Asignar nodos y procesadores 1 a 1 no es recomendable, ya que crece muy rápido el número de nodos. Los nodos intermedios corresponden a la face de pegado de datos, por lo que las hojas son las únicas con trabaja. Por lo que, es mejor agrupar nodos por la derecha o izquierda.

Con esto también se disminuyen el número de mensajes.


