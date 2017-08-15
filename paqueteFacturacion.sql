--
-- Antonio Pérez Caballero
-- Julio 2010
-- Versión 1.0
--
-- Paquete de facturación Redmoon Consultores 
--
--
--
--
--
Create or replace package pkFactRedmoon AS

	--BLOQUE DE FACTURACIÓN

	--Leer los consumos de un periodo de tiempo o un determinado criterio
	--Procedure LeerConsumos(xIDExpe out Integer, xUsuario in varchar2);
	
	--Generar facturas a partir de los consumos
	Procedure CrearFacturacion;
	
	--Verificación facturación
	--Procedure VerificarFacturacion();
	
	--METODOS DE PAGO
	--Domiciliacion bancaria
	--Pago electronico
	
	--NOTIFICACIONES A CLIENTES
	--Correo electronico
	--E-factura
	
	
	--Modificación factura
	
	--Crea una nueva factura
	Procedure addFactura(xCliente in integer);
	
	
	--crear el detalle de una factura
	Procedure addDetalle(xCliente in integer,xIDFactura in integer);
	
	--añadir los tipos de iva de la factura
	procedure addFiscalidad(xIDFactura in integer);
	
	--añadir el total base y total iva
	procedure addTotal(xIDFactura in integer);
	
	--devuelve el nombre de un servicio, variable de netrada su id
	function nombreServicio(xIDServicio in integer) return varchar2;
	
	--Aumentar el contador de facturas
	Procedure ContadorFactura(xNUMFactura out varchar2);
	
	--actualizar la tabla de consumos despues de generar la factura
	procedure updateConsumos();
	
	--Variables publicas del paquete
	xFormaPago varchar2(20):='TRANSFERENCIA';
	xFechaFact date:=sysdate;
	
	
	

END pkFactRedmoon;
/


/* **********************************************************************************************************************
Proceso de creación de un expediente comienza con la introducción de los datos del solicitante en Solicitnates.HTML
Desde esta página podemos buscar, modificar o dar de alta un nuevo Solicitante.
Realizado este proceso pasamos a dar de Alta el Expediente y ponemos su Titular del Expediente en la tabla de 
Clientes_Expe, tantos como sean necesarios.

************************************************************************************************************************* */

-- Antonio Perez Caballero
-- Agosto 2009
--
-- Cabecera del paquete
--
--

Create or replace package body pkFactRedmoon AS

Procedure CrearFacturacion
as

	CURSOR cClientes IS SELECT IDCLIENTE FROM CONSUMOS WHERE FACTURADO='PR' GROUP BY idcliente;
				
begin
	
	--
	update consumos set facturado='PR' WHERE FACTURADO='PE';
	
	for vClientes IN cClientes loop
	
		addFactura(vClientes.IDCLIENTE);
		
	end loop;
	
	--EN EL CASO DE ENCONTRARNOS 'PR' EN LA BD SIGNIFICARIA QUE HA HABIDO UN ERROR EN EL PERIODO DE FACTURACION
	update consumos set facturado='FA' WHERE FACTURADO='PR';	
	
end;

	
PROCEDURE ContadorFactura(xFactura OUT VARCHAR2)
as
xNumFact integer;
xYear char(4);

begin
	update redmoon set factura=factura+1 where id=1 returning factura,year into xNumFact,xYear;
	--formatear numero de factura
	xFactura:=xYear||'/'||LPAD (to_char(xNumFact),5,'0');
	

end;

Procedure addFactura(xCliente in integer)
as
xID integer;
xNUMfactura varchar2(40);
begin

	--el numero de factura
	contadorFactura(xNUMfactura);
	
	-- insert en facturas
	insert into facturas (fecha,idcliente,forma_pago,ne) VALUES(xFechaFact,xCliente,xFormaPago,xNUMfactura) returning id into xID;
	addDetalle(xCliente,xID);
	addFiscalidad(xID);
	addTotal(xID);
end;

Procedure addDetalle(xCliente in integer,xIDFactura in integer)
as
CURSOR cDetalle IS SELECT COUNT(ID_SERVICIO) as xCantidad, id_servicio,precio,TIPO_IVA FROM CONSUMOS WHERE idcliente=xCliente
		GROUP BY id_servicio,precio,TIPO_IVA
		ORDER BY id_servicio;
begin

for vDetalle IN cDetalle loop
	
		insert into factura_detalle (idfactura,cantidad,concepto,importe,tipo_iva) 
		values (xIDFactura,vDetalle.xCantidad,nombreServicio(vDetalle.id_servicio),vDetalle.precio*vDetalle.xCantidad,vDetalle.tipo_iva);
		
	end loop;
	
end;

Procedure addFiscalidad(xIDFactura in integer)
as
	cursor cIVA is select tipo_iva,sum(importe) as base from factura_detalle where idfactura=xIDFactura
	GROUP by tipo_iva;
begin
	for vIVA in cIVA loop
		insert into fiscalidad (idfactura,tipo_iva,base) values (xIDFactura,vIVA.tipo_iva,vIVA.base);
	end loop;
end;

procedure addTotal(xIDFactura in integer)
as
begin
	UPDATE FACTURAS 
	SET BASE=(select SUM(BASE) FROM FISCALIDAD 
	WHERE idfactura=xIDFactura), IMPORTE_IVA=(select SUM(IMPORTE* tipo_iva/100) 
	FROM factura_detalle WHERE idfactura=xIDFactura) WHERE ID=xIDFactura;
end;

function nombreServicio(xIDServicio in integer) return varchar2
as
xServicio varchar2(50);
begin
select servicio into xServicio from servicios where id= xIDServicio ;
return xServicio;
end;


	
END pkFactRedmoon;
/
