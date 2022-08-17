# ¡Llegó el previaje!

**La Secretaría de Turismo planea lanzar una nueva edición de previaje, el programa que reintegra al turista parte de sus costos para fomentar que se mueva por el país. La anterior edición fue gestionada utilizando un programa en C escrito en una enorme sala por una cantidad infinita de monos [^1], pero esta vuelta decidieron probar suerte con Prolog.**

La forma de funcionamiento del programa es que las personas cargan facturas en el sistema, indicando a qué ciudad corresponde y la información necesaria para validar esa transacción. En caso de que esté ok, a esa persona se le devuelve parte del dinero gastado en su cuenta bancaria.

Se conocen los comercios adheridos en cada destino que entran en el programa.

```
comercioAdherido(iguazu, grandHotelIguazu).
comercioAdherido(iguazu, gargantaDelDiabloTour).
comercioAdherido(bariloche, aerolineas).
```

También, se conoce de cada persona las facturas que presentó y el monto máximo reconocido para una habitacion de hotel:
```
%factura(Persona, DetalleFactura).
%Detalles de facturas posibles:
% hotel(ComercioAdherido, ImportePagado)
% excursion(ComercioAdherido, ImportePagadoTotal, CantidadPersonas)
% vuelo(NroVuelo,NombreCompleto)

factura(estanislao, hotel(grandHotelIguazu, 2000)).
factura(antonieta, excursion(gargantaDelDiabloTour, 5000, 4)).
factura(antonieta, vuelo(1515, antonietaPerez)).

valorMaximoHotel(5000).
```

Y los vuelos que efectivamente se hicieron:
```
%registroVuelo(NroVuelo,Destino,ComercioAdherido,Pasajeros,Precio)
registroVuelo(1515, iguazu, aerolineas, [estanislaoGarcia, antonietaPerez, danielIto], 10000).
```

El dinero que se le devuelve a una persona se calcula sumando la devolución correspondiente a cada una de las facturas válidas (que no sean truchas), más un adicional de $1000 por cada ciudad diferente en la que se alojó (con factura válida). Hay una penalidad de $15000 si entre todas las facturas presentadas hay alguna que sea trucha. Además, el monto máximo a devolver es de $100000.

De las facturas válidas se devuelve:
* En caso de hoteles: un 50% del monto pagado
* En caso de vuelos: un 30% del monto, excepto que el destino sea Buenos Aires en cuyo caso no se devuelve nada.
* En caso de excursiones: un 80% del monto por persona (dividir por la cantidad de personas que participó).
Aquellas facturas que son para un comercio que no está adherido al programa se consideran truchas. También son truchas las facturas de hotel por un monto superior al precio por habitación máximo establecido. Si una factura corresponde a un vuelo en el que no hay una persona con su nombre completo en el registro del vuelo, se considera trucha. 

### Se desea saber

1. El monto a devolver a cada persona que presentó facturas.  
2. Qué destinos son sólo de trabajo. Son aquellos destinos que si bien tuvieron vuelos hacia ellos, no tuvieron ningún turista que se alojen allí o tienen un único hotel adherido.
3. Saber quiénes son estafadores, que son aquellas personas que sólo presentaron facturas truchas o facturas de monto 0.
4. Inventar un nuevo tipo de comercio adherido no trivial pero que no implique escribir mucho código nuevo, y que todo siga funcionando correctamente. Explicar el concepto que nos permite hacer eso sin reescribir otros predicados.
5. Agregar algunos hechos de ejemplo.

[^1]: [https://es.wikipedia.org/wiki/Teorema_del_mono_infinito](https://es.wikipedia.org/wiki/Teorema_del_mono_infinito)

