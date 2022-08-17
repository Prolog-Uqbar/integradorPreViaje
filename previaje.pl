comercioAdherido(iguazu, grandHotelIguazu).
comercioAdherido(bariloche, grandHotelBariloche).
comercioAdherido(iguazu, gargantaDelDiabloTour).
comercioAdherido(bariloche, aerolineas).
comercioAdherido(iguazu, aerolineas).

valorMaximoHotel(5000).

%factura(Persona, DetalleFactura).
%Detalles de facturas posibles:
% hotel(ComercioAdherido, ImportePagado)
% excursion(ComercioAdherido, ImportePagadoTotal, CantidadPersonas)
% vuelo(NroVuelo,NombreCompleto)

factura(estanislao, hotel(grandHotelIguazu, 2000)).
factura(antonieta, hotel(grandHotelIguazu, 2000)).
factura(estanislao, hotel(grandHotelBariloche, 200)).
factura(estanislao, hotel(grandHotelIguazu, 2000)).
factura(antonieta, excursion(gargantaDelDiabloTour, 5000, 4)).
factura(antonieta, vuelo(1515, antonietaPerez)).

persona(Persona):-
    factura(Persona, _).


%registroVuelo(NroVuelo,Destino,ComercioAdherido,Pasajeros,Precio)
registroVuelo(1515, iguazu, aerolineas, [estanislaoGarcia, antonietaPerez, danielIto], 10000).

/* 1)
El dinero que se le devuelve a una persona se calcula sumando la devolución correspondiente a cada una de las facturas válidas (que no sean truchas), más un adicional de $1000 por cada ciudad diferente en la que se alojó (con factura válida). 
Hay una penalidad de $15000 si entre todas las facturas presentadas hay alguna que sea trucha. 
Además, el monto máximo a devolver es de $100000.
*/
devolucionPersona(Persona, MontoADevolver):-
    persona(Persona),
    devolucionFacturas(Persona, DevolucionTotal),
    adicionalCiudadesDiferentes(Persona, ImporteCiudades),
    penalizacionFacturaTrucha(Persona, Penalidad),
    MontoTotal is DevolucionTotal + ImporteCiudades - Penalidad,
    redondeo(MontoTotal, MontoADevolver).

devolucionFacturas(Persona, Total):-
    findall(Monto, devolucionFactura(Persona,Monto),Montos),
    sum_list(Montos, Total).

devolucionFactura(Persona,MontoADevolver):-
    factura(Persona, DetalleFactura), 
    not(facturaTrucha(DetalleFactura)), 
    porcentajeDevolucion(DetalleFactura, Porcentaje),
    monto(DetalleFactura,Importe),
    MontoADevolver is Importe * Porcentaje.

porcentajeDevolucion(hotel(_, _), 0.5).
porcentajeDevolucion(excursion(_, _, _), 0.80).
porcentajeDevolucion(vuelo(NroVuelo, _), 0.3):-
    registroVuelo(NroVuelo, Destino, _, _, _),
    Destino \= buenosAires.
porcentajeDevolucion(vuelo(NroVuelo, _), 0):-
    registroVuelo(NroVuelo, buenosAires, _, _, _).

monto(hotel(_, Importe), Importe).
monto(vuelo(NroVuelo, _), Importe):-
    registroVuelo(NroVuelo, _, _, _, Importe).
monto(excursion(_, ImportePagadoTotal, CantidadPersonas), Importe):-
    Importe is ImportePagadoTotal / CantidadPersonas.





adicionalCiudadesDiferentes(Persona, Importe):-
    setof(Ciudad, seAlojoEn(Persona, Ciudad), Ciudades),
%   findall(Ciudad, distinct(seAlojoEn(Persona, Ciudad)), Ciudades),
    length(Ciudades, CantCiudadesDiferentes),
    Importe is CantCiudadesDiferentes * 1000.

seAlojoEn(Persona, Ciudad):-
    factura(Persona, hotel(ComercioAdherido, _)),
    comercioAdherido(Ciudad, ComercioAdherido).

penalizacionFacturaTrucha(Persona, 15000):-
    tieneFacturaTrucha(Persona).
penalizacionFacturaTrucha(Persona, 0):-
    not(tieneFacturaTrucha(Persona)).

tieneFacturaTrucha(Persona):-
    factura(Persona,DetalleFactura),
    facturaTrucha(DetalleFactura).

redondeo(Monto, Monto):-Monto < 100000.
redondeo(Monto, 100000):-Monto >= 100000.

%devolucion(DetalleFactura, MontoADevolver).

% Aquellas facturas que son para un comercio que no está adherido al programa se consideran truchas. 

comercio(hotel(Comercio, _), Comercio).
comercio(excursion(Comercio, _, _), Comercio).
comercio(vuelo(NroVuelo, _), Comercio):-
    registroVuelo(NroVuelo, _, Comercio, _, _).

facturaTrucha(DetalleFactura):-
    comercio(DetalleFactura, Comercio),
    not(comercioAdherido(_, Comercio)).

% También son truchas las facturas de hotel por un monto superior al precio por habitación máximo establecido.

facturaTrucha(hotel(_, ImportePagado)):-
    valorMaximoHotel(ValorMaximoHotel),
    ImportePagado > ValorMaximoHotel.

% Si una factura corresponde a un vuelo 
% en el que no hay una persona con su nombre completo en el registro del vuelo, se considera trucha. 

facturaTrucha(vuelo(NroVuelo, NombreCompleto)):-
    registroVuelo(NroVuelo, _, _, Pasajeros, _),
    not(member(NombreCompleto, Pasajeros)).


% 2) Qué destinos son sólo de trabajo. 
% Son aquellos destinos que si bien tuvieron vuelos hacia ellos, no tuvieron ningún turista que se alojen allí o tienen un único hotel adherido.
destinoSoloTrabajo(Destino):-
    hayVuelo(Destino),
    sinTurista(Destino).

destinoSoloTrabajo(Destino):-
    soloUnHotel(Destino).    

hayVuelo(Destino):-
    registroVuelo(_,Destino,_,_,_).

sinTurista(Destino):-
    not(hayFacturaHotel(Destino,_)).

soloUnHotel(Destino):-
    hayFacturaHotel(Destino,NombreHotel),
    not((hayFacturaHotel(Destino,Otro),Otro \= NombreHotel)).

% Alternativa
% soloUnHotel(Destino):-
%    hayFacturaHotel(Destino,NombreHotel),
%    forall(hayFacturaHotel(Destino,Otro),Otro = NombreHotel).

hayFacturaHotel(Destino,NombreHotel):-
    comercioAdherido(Destino, NombreHotel),
    factura(_, hotel(NombreHotel, _)).
% Se deducen sólo los hoteles para los que se presentaron facturas.

% 3)
% Saber quiénes son estafadores, que son aquellas personas que sólo presentaron facturas truchas o facturas de monto 0.

estafador(Persona):-
    persona(Persona),
    forall(factura(Persona,Detalle),facturaEstafa(Detalle)).

facturaEstafa(F):-facturaTrucha(F).
facturaEstafa(F):-monto(F,0).
