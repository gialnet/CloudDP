
--
-- Pruebas de funcionamiento del paquete pkCriptoCloudDP
--

create or replace procedure test_pkCriptoCloudDP
as

xORIGINAL BLOB;
xBFileCifrado BLOB;

xIDDoc Integer:=0;
xURL_Nube varchar2(250);
begin

	--dbms_output.put_line('Leer archivo del sistema');
	-- Leer un archivo del sistema de ficheros y guardarlo en la base de datos.
	pkDocSystemCustody.DBgetFileFromFileSystem('Que_es_VideoCasa.pdf', 9, 1, 1,	'publicidad', xIDDoc);
	/*
	pkDocSystemCustody.AddDocMisDocs(9, 
		1,
		1,
		'Que_es_VideoCasa.pdf', 
		0,
		'publicidad',
		xURL_Nube, xIDDoc);*/
		
	--dbms_output.put_line(xURL_Nube);
	IF xIDDoc=0 THEN
		RETURN;
	END IF;
	
	SELECT ORIGINAL INTO xORIGINAL from tmpBLOB WHERE IDSESION=1;
	
	-- cifrar un campo blob
	pkCriptoCloudDP.CifrarAES256(1, 1, xORIGINAL, xBFileCifrado);

	/*
	SELECT CRYPTO INTO xORIGINAL from doc_custodia WHERE ID=xIDDoc FOR UPDATE;
	
	DBMS_LOB.APPEND(xORIGINAL, xBFileCifrado);
	
	COMMIT;
	 */
end;
/


create or replace procedure test_pkCriptoCloudDP2
as

xORIGINAL BLOB;
xBFileCifrado BLOB;
xAES_ENCRIPTADA BLOB;
xIDDoc Integer:=0;
xURL_Nube varchar2(250);

key_bytes_raw RAW (32); -- stores 256-bit encryption key

-- total encryption type
encryption_type PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5;


BEGIN

	
	--
	-- Leer la clave de encriptación
	--
	BEGIN
		SELECT AES INTO key_bytes_raw FROM ALMACENCERT WHERE ID=1;
	Exception
   	When no_data_found then
 		begin  		
  		  	RETURN;
   		end;
	END;
	
	SELECT CRYPTO,AES_ENCRIPTADA INTO xORIGINAL,xAES_ENCRIPTADA from doc_custodia WHERE ID=12 FOR UPDATE;
	
	
	DBMS_CRYPTO.ENCRYPT(dst => xAES_ENCRIPTADA, src => xORIGINAL, typ => encryption_type, key => key_bytes_raw);

	
	COMMIT;

END;


