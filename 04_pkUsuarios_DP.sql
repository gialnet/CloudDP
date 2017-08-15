

-- Antonio
-- Septiembre 2010
--
-- Gestión de usuarios
--
Create or replace package pkUsersCDP AS


-- AÑADIR UN NUEVO CLIENTE Y ADEMÁS GENERAR SU CLAVE ALEATORIA AES
Procedure ClientNewUser(xNOMBRE IN VARCHAR2,
		xRAZON_SOCIAL IN VARCHAR2,
		xNIF IN VARCHAR2,
		xMVL IN VARCHAR2,
		xTLF IN VARCHAR2,
		xMAIL IN VARCHAR2,
		xCALLE_NUM IN VARCHAR2,
		xOBJETO IN VARCHAR2,
		xCP IN VARCHAR2,
		xCIUDAD IN VARCHAR2,
		xPROVINCIA IN VARCHAR2, 
		xCC IN VARCHAR2,
		xTITULAR_CC IN VARCHAR2,
		xNomUsuario IN VARCHAR2,
		xPASSWD IN VARCHAR2, xIDGremio Integer);

		
-- AÑADIR UN NUEVO EMPLEADO DE NUESTRO CLIENTE
Procedure EmployeeClientNewUser(xNOMBRE IN VARCHAR2,
		xNIF IN VARCHAR2,
		xMVL IN VARCHAR2,
		xMAIL IN VARCHAR2,
		xPASSWD IN VARCHAR2,
		xPERTENECE_A IN Integer, xGrupo IN Integer, xDto IN Integer);

		
		
-- Añadir un invitado
Procedure GuestClientNewUser(xNOMBRE IN VARCHAR2,
		xNIF IN VARCHAR2,
		xMVL IN VARCHAR2,
		xMAIL IN VARCHAR2,
		xPASSWD IN VARCHAR2,
		xPERTENECE_A IN Integer);
		


		
-- Crear un Dto clientes.DTO%TYPE
Procedure AddDto(xIDCliente IN DEPARTAMENTOS.IDCLIENTE%TYPE, 
				xNombre_Dto IN DEPARTAMENTOS.NOMBRE_DTO%TYPE);

-- Crear un Grupo rCliente Clientes%ROWTYPE;
Procedure AddGrupo(xIDGrupo IN GRUPOS.ID_GRUPO%TYPE, 
					xNombre_Grupo IN GRUPOS.NOMBRE_GRUPO%TYPE);
					
-- Asignar un departamento a un grupo
Procedure AddDtoGrupo(xID_DTO IN GRUPOS_DTOS.ID_DTO%TYPE,
					xIDCliente IN GRUPOS_DTOS.IDCLIENTE%TYPE, 
					xID_GRUPO IN GRUPOS_DTOS.ID_GRUPO%TYPE);
					
-- Añadir los valores por defecto al crear un nuevo cliente
Procedure AddDefaultDtoGrupos(xIDCliente IN CLIENTES.ID%TYPE, 
			xDtos_Staff OUT DEPARTAMENTOS.ID_DTO%TYPE, 
			xGrupo_Staff OUT GRUPOS.ID_GRUPO%TYPE);

					
						
END pkUsersCDP;
/

--
-- Cuerpo del paquete
--
Create or replace package body pkUsersCDP AS




--
--
--
Procedure AddDefaultDtoGrupos(xIDCliente IN CLIENTES.ID%TYPE, 
			xDtos_Staff OUT DEPARTAMENTOS.ID_DTO%TYPE, 
			xGrupo_Staff OUT GRUPOS.ID_GRUPO%TYPE)
as
xDtos_Employee DEPARTAMENTOS.ID_DTO%TYPE;
xGrupos_Employee DEPARTAMENTOS.ID_DTO%TYPE;
begin

-- Departamentos por defecto
Insert Into DEPARTAMENTOS (IDCLIENTE, NOMBRE_DTO) 
		values (xIDCliente,'staff') 
		RETURNING ID_DTO INTO xDtos_Staff;
		
Insert Into DEPARTAMENTOS (IDCLIENTE, NOMBRE_DTO) 
		values (xIDCliente,'employee') 
		RETURNING ID_DTO INTO xDtos_Employee;


-- GRUPOS POR DEFECTO
Insert Into Grupos (IDCLIENTE, NOMBRE_GRUPO) values (xIDCliente,'staff') RETURNING ID_GRUPO INTO xGrupo_Staff;
Insert Into Grupos (IDCLIENTE, NOMBRE_GRUPO) values (xIDCliente,'employee') RETURNING ID_GRUPO INTO xGrupos_Employee;


-- Departamentos de los Grupos
Insert Into GRUPOS_DTOS (ID_DTO, IDCLIENTE, ID_GRUPO) 
	values (xDtos_Staff, xIDCliente, xGrupo_Staff);
	
Insert Into GRUPOS_DTOS (ID_DTO, IDCLIENTE, ID_GRUPO) 
	values (xDtos_Employee, xIDCliente, xGrupos_Employee);

end;


--
-- Asignar un Dto a un grupo
--
-- Un grupo no podrá tener más de una vez a un dto
--
Procedure AddDtoGrupo(xID_DTO IN GRUPOS_DTOS.ID_DTO%TYPE,
					xIDCliente IN GRUPOS_DTOS.IDCLIENTE%TYPE, 
					xID_GRUPO IN GRUPOS_DTOS.ID_GRUPO%TYPE)
as
begin

	INSERT INTO GRUPOS_DTOS (ID_GRUPO, IDCLIENTE, ID_DTO) 
			VALUES (xID_GRUPO, xIDCliente, xID_DTO);


end;

-- Añadir un GRUPO
Procedure AddGrupo(xIDGrupo IN GRUPOS.ID_GRUPO%TYPE, 
					xNombre_Grupo IN GRUPOS.NOMBRE_GRUPO%TYPE)
AS
BEGIN

	INSERT INTO GRUPOS (ID_GRUPO, NOMBRE_GRUPO) 
			VALUES (xIDGrupo, xNombre_Grupo);

END;

-- Añadir un DEPARTAMENTO
Procedure AddDto(xIDCliente IN DEPARTAMENTOS.IDCLIENTE%TYPE, 
				xNombre_Dto IN DEPARTAMENTOS.NOMBRE_DTO%TYPE)
as
begin

	INSERT INTO DEPARTAMENTOS (IDCLIENTE, NOMBRE_DTO) 
			VALUES (xIDCliente, xNombre_Dto);
			
end;

--
-- AÑADIR UN NUEVO CLIENTE
--
Procedure ClientNewUser(xNOMBRE IN VARCHAR2,
		xRAZON_SOCIAL IN VARCHAR2,
		xNIF IN VARCHAR2,
		xMVL IN VARCHAR2,
		xTLF IN VARCHAR2,
		xMAIL IN VARCHAR2,
		xCALLE_NUM IN VARCHAR2,
		xOBJETO IN VARCHAR2,
		xCP IN VARCHAR2,
		xCIUDAD IN VARCHAR2,
		xPROVINCIA IN VARCHAR2,
		xCC IN VARCHAR2,
		xTITULAR_CC IN VARCHAR2,
		xNomUsuario IN VARCHAR2,
		xPASSWD IN VARCHAR2, xIDGremio Integer)
as
xIDCliente Integer;
xALMACENCERT Integer;

xDtos_Staff Integer;
xGrupo_Staff Integer;

num_key_bytes NUMBER := 256/8; -- key length 256 bits (32 bytes)

key_bytes_raw RAW (32); -- stores 256-bit encryption key

begin

-- Generar una clave aleatoria para la firma AES 256
key_bytes_raw := DBMS_CRYPTO.RANDOMBYTES(num_key_bytes);

-- USO_CERTIFICADO POR AHORA A PIÑON FIJO 1
Insert Into ALMACENCERT (AES, USO_CERTIFICADO) values (key_bytes_raw, 1) RETURNING ID INTO xALMACENCERT;


-- gremio 1 asesores fiscales y contables
Insert Into CLIENTES (NOMBRE,RAZON_SOCIAL,NIF,MVL,TLF,MAIL,
		CALLE_NUM,OBJETO,CP,CIUDAD,PROVINCIA,CC,TITULAR_CC,IDGREMIO, ALMACENCERT)
values (UPPER(xNOMBRE),UPPER(xRAZON_SOCIAL),UPPER(xNIF),xMVL,xTLF,xMAIL,
		xCALLE_NUM,xOBJETO,xCP,xCIUDAD,xPROVINCIA,xCC,xTITULAR_CC, xIDGremio, xALMACENCERT)
returning ID Into xIDCliente;

-- Agregar los depatamentos y grupos por defecto
AddDefaultDtoGrupos(xIDCliente, xDtos_Staff, xGrupo_Staff);

--
-- EL administrador del sistema quien tiene visibilidad global
--

Update Clientes Set Grupo=xGrupo_Staff, Dto=xDtos_Staff Where ID=xIDCliente;

-- Tipo de Cliente CL,clientes IN clientes indirectos
-- Se añade una tira de 16 caractres mayusculas y números aleatorio
Insert Into USUARIOS (USUARIO,NOMBRE,IDCLIENTE,MOVIL,EMAIL,TIPO,PERFIL,PASSWD,
	DIGITOS,IDDATOSPER,IDGREMIO,NIF) 
	values (xNomUsuario,UPPER(xNOMBRE),xIDCliente,xMVL,xMAIL,'CL','index.php',xPASSWD,
	(SELECT dbms_random.string('X', 16) FROM DUAL),1,xIDGremio,UPPER(xNIF));

	
-- Preferencias de usuario
Insert Into CONFI_USER (IDCLIENTE) values (xIDCliente);

end;

--
-- AÑADIR UN NUEVO EMPLEADO DE NUESTRO CLIENTE
--
Procedure EmployeeClientNewUser(xNOMBRE IN VARCHAR2,
		xNIF IN VARCHAR2,
		xMVL IN VARCHAR2,
		xMAIL IN VARCHAR2,
		xPASSWD IN VARCHAR2,
		xPERTENECE_A IN Integer, xGrupo IN Integer, xDto IN Integer)
as

xIDGREMIO INTEGER;
xIDEmpleado INTEGER;
xNumUser INTEGER;
xUsuario VARCHAR2(30);
begin


BEGIN
	--Averiguar el gremio
	SELECT IDGREMIO INTO xIDGREMIO FROM USUARIOS WHERE IDCLIENTE=xPERTENECE_A AND TIPO='CL';
exception
   	when no_data_found then
 	begin  		
  		  RETURN;
   	end;
END;

-- gremio 1 asesores fiscales y contables
Insert into CLIENTES (NOMBRE,NIF,MVL,MAIL,IDGREMIO,PERTENECE_A, Grupo, Dto) 
values (UPPER(xNOMBRE),UPPER(xNIF),xMVL,xMAIL, xIDGREMIO	, xPERTENECE_A, xGrupo, xDto) RETURNING ID INTO xIDEmpleado;

SELECT count(USUARIO) INTO xNumUser FROM USUARIOS WHERE USUARIO=xNIF;
IF (xNumUser>0) THEN 
	xUsuario:=xNIF||'-'||to_char(xIDEmpleado);
ELSE 
	xUsuario:=xNIF;
END IF;

--Tipo de Cliente CL,clientes IN clientes indirectos, empleados EM
Insert into USUARIOS (USUARIO,NIF,NOMBRE,IDCLIENTE,MOVIL,EMAIL,TIPO,PERFIL,PASSWD,DIGITOS,IDDATOSPER, IDGREMIO,IDEMPLEADO) 
	values (xUsuario,UPPER(xNIF),UPPER(xNOMBRE),xPERTENECE_A,xMVL,xMAIL,'EM','index.php',xPASSWD,
	(SELECT dbms_random.string('X', 16) FROM DUAL),1, xIDGREMIO,xIDEmpleado);


end;

--
-- AÑADIR UN INVITADO
--
Procedure GuestClientNewUser(xNOMBRE IN VARCHAR2,
		xNIF IN VARCHAR2,
		xMVL IN VARCHAR2,
		xMAIL IN VARCHAR2,
		xPASSWD IN VARCHAR2,
		xPERTENECE_A IN Integer)
as

xIDINVITADO  Integer;
xIDGREMIO INTEGER;
xNumUser INTEGER;
xUsuario VARCHAR2(30);
begin



BEGIN
	--Averiguar el gremio
	SELECT IDGREMIO INTO xIDGREMIO FROM USUARIOS WHERE IDCLIENTE=xPERTENECE_A and TIPO='CL';
exception
   	when no_data_found then
 	begin  		
  		  RETURN;
   	end;
END;





INSERT INTO INVITADOS (IDCLIENTE, NIF, RAZON_SOCIAL, EMAIL) 
	VALUES (xPERTENECE_A,UPPER( xNIF),UPPER( xNOMBRE), xMAIL) 
	returning ID into xIDINVITADO;

SELECT count(USUARIO) INTO xNumUser FROM USUARIOS WHERE USUARIO=xNIF;
IF (xNumUser>0) THEN 
	xUsuario:=xNIF||'-'||to_char(xIDINVITADO);
ELSE 
	xUsuario:=xNIF;
END IF;

--Tipo de Cliente CL,clientes IN clientes indirectos
Insert into USUARIOS (USUARIO,NIF,NOMBRE,IDCLIENTE,IDINVITADO,MOVIL,EMAIL,TIPO,
		PERFIL,PASSWD,DIGITOS,IDDATOSPER, IDGREMIO) 
	values (xUsuario,UPPER(xNIF),UPPER(xNOMBRE),xPERTENECE_A,xIDINVITADO,xMVL,xMAIL,'IN',
		'index.php',xPASSWD,(SELECT dbms_random.string('X', 16) FROM DUAL),1,xIDGREMIO);


end;




END pkUsersCDP;
/




