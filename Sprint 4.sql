#creacion de la base de datos:
CREATE DATABASE transactions;

-- USE DATABASE transactions; # para setear como default 

#crear tablas:
#american_users:
CREATE TABLE IF NOT EXISTS american_users (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255)
);
#european_users:
CREATE TABLE IF NOT EXISTS european_users (
        id INT PRIMARY KEY, 
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255)
);
#occio que es la misma tabla de los american_users
        
#companies:
CREATE TABLE IF NOT EXISTS companies (
        company_id VARCHAR(15) PRIMARY KEY, #este id no va int porque es alfanumerico
        company_name VARCHAR(100),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
);
        
#credit_cards
CREATE TABLE IF NOT EXISTS credit_cards (
	id VARCHAR(20) PRIMARY KEY,
    user_id INT,
    iban VARCHAR(50),
    pan VARCHAR(25),
    pin VARCHAR(4),
    cvv VARCHAR(15), #no es int para que no elimine los que inician por 0
    track1 VARCHAR (255),
    track2 VARCHAR (255),
    expiring_date VARCHAR (255)
);

#products
CREATE TABLE IF NOT EXISTS products (
        id INT PRIMARY KEY,
        product_name VARCHAR(50),
        price DECIMAL(10, 2),
        colour VARCHAR(50),
        weight DECIMAL(5, 2),
        warehouse_id VARCHAR(15)
);


#transactions
 CREATE TABLE IF NOT EXISTS transactions (
        id VARCHAR(255) PRIMARY KEY,
        card_id VARCHAR(20),
        business_id VARCHAR(20), 
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined TINYINT,
        product_ids VARCHAR (50),
        user_id INT,
        lat FLOAT,
        longitude FLOAT
    );


#Cargar los datos en las tablas:
show variables like "secure_file_priv";
-- 'secure_file_priv', 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\'
show global variables like "local_infile";
SET GLOBAL local_infile = 1;
SHOW GRANTS FOR CURRENT_USER();
GRANT FILE ON *.* TO 'root'@'localhost';
FLUSH PRIVILEGES;

#tabla american_users:
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/american_users.csv'
INTO TABLE american_users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,name,surname,phone,email,birth_date,country,city,postal_code,address);

#tabla european_users:
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/european_users.csv'
INTO TABLE european_users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,name,surname,phone,email,birth_date,country,city,postal_code,address);

#tabla companies:
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(company_id,company_name,phone,email,country,website);
        
#credit_cards
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,user_id,iban,pan,pin,cvv,track1,track2,expiring_date);

#products
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,product_name,@price,colour,weight,warehouse_id)
SET price = CAST(REPLACE(@price,'$','') AS DECIMAL(10,2));

#transactions
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,card_id,business_id,timestamp,amount,declined,product_ids,user_id,lat,longitude);

#creacion de las relaciones entre las tablas:

-- antes de hacer la union habria que verificar que no se repitan los ids entre las tablas
-- para ello se hace una join entre ellas y asi ver que no hay ninguno = entre ambas
-- que no haya solapamiento.
SELECT a.id AS americans, e.id AS europeans
FROM american_users AS a
JOIN european_users AS e
	ON	a.id=e.id;

# union tabla european_users y tabla european_users:
CREATE TABLE IF  NOT EXISTS users(
SELECT id ,name,surname,phone,email,birth_date,country,city,postal_code,address
FROM american_users
UNION
SELECT id,name,surname,phone,email,birth_date,country,city,postal_code,address
FROM european_users);

#si despues de crear users en base a americans y europeans,
#pero despues hago drop a estas dos que ya no voy a necesitar
#¿Afecta mi tabla users? --> NO AFECTA
-- es buenas practicas borrarlas?

DROP TABLE american_users;
DROP TABLE european_users;

#Forein keys contructions:
-- OCCIO que aqui es la misma correccion del sprint 3 que todas las fk se haccen en una sola query
#nombres menos comfusos pretty please

ALTER TABLE transactions
	ADD CONSTRAINT FK_t_u FOREIGN KEY (user_id) REFERENCES users(id), #con users
    ADD CONSTRAINT FK_t_c FOREIGN KEY (business_id) REFERENCES companies(company_id),#con companies
    ADD CONSTRAINT FK_t_cc FOREIGN KEY (card_id) REFERENCES credit_cards(id) #con credit caards
    ;
#me da error 1822 el mismo error dde la tabla padre
#porque al crear la tabla users con la union de las otras dos no le indique cual era la pk de esa nueva tabla users
ALTER TABLE users
ADD CONSTRAINT users_pk PRIMARY KEY (id);

-- por recomendaciones esta union se hace mas tarde
#transactions- products:
-- ALTER TABLE transaction
-- ADD CONSTRAINT FK_t_p
-- FOREIGN KEY (product_ids)
-- REFERENCES products(id);

#just in case: 
-- #elmininacion de fk
-- ALTER TABLE transactions
-- DROP CONSTRAINT FK_t_cc;

#N1
	#Ejercicio 1:
#usuarios con más de 80 transacciones 
-- cari de mi vida y de mi corazon esto tiene que ir con subconsulta:
-- ves? --> Realiza una subconsulta que muestre a todos los usuarios con más de 80 transacciones utilizando al menos 2 tablas.
#con JOIN
SELECT  u.name, u.surname, COUNT(t.id) AS num_transacciones
FROM transactions AS t
JOIN users AS u
	ON t.user_id=u.id
GROUP BY u.name, u.surname
HAVING COUNT(t.id) > 80;

#con Subconsulta:
#para saber los id de los usuarios con mas de 80 transacciones (subconsulta):
SELECT t.user_id
FROM transactions AS t
GROUP BY t.user_id
HAVING COUNT(t.id) > 80;
#ahora quiero saber los nombres de esos user_id
SELECT u. id, u.name, u.surname
FROM users AS u
WHERE u.id IN (SELECT t.user_id
		FROM transactions AS t
		GROUP BY t.user_id
		HAVING COUNT(t.id) > 80)
;
#pero es que claro,me da toc y yo quiero que me aparezca el conteo de las transac de cada uno en la tabla

SELECT u.id, u.name, u.surname, 
		(SELECT COUNT(t.id) 
			FROM transactions AS t
            WHERE u.id= t.user_id) AS conteo_transacciones
FROM users AS u
HAVING conteo_transacciones >80;

-- Ejercicio 2
#Muestra la media de amount -- table t avg(amount)
#por IBAN de las tarjetas de crédito en la -- group by por iban table cc
#compañía Donec Ltd. --tabla c
#utiliza por lo menos 2 tablas.

#por JOIN
SELECT cc.id AS id_tarjeta,	cc.iban AS iban_terjeta, 
    ROUND(AVG(t.amount),2) AS media_cantidad, 
    c.company_name AS nombre_empresa
FROM transactions AS t
JOIN credit_cards AS cc
	ON t.card_id=cc.id
JOIN companies AS c
	ON t.business_id=c.company_id
WHERE c.company_name='Donec Ltd'
GROUP BY cc.iban, c.company_name, cc.id;

#N2
-- Crea una nueva tabla que refleje 
#el estado de las tarjetas de crédito basado en -- declined para saber el estado está en table transactions add column
#si las tres últimas transacciones han sido declinadas entonces es inactivo -- cuales son las 3 ultimas? fecha y hora en transactions
#si al menos una no es rechazada entonces es activo .

#creacion de la nueva tabla con las columnas que necesito

CREATE TABLE estado_tarjeta AS
SELECT card_id, id AS id_transaction, timestamp, declined
FROM transactions;

-- probando probando
#Cuantas transacciones se han hecho por tarjeta
-- SELECT e.card_id, COUNT(e.id_transaction) AS num_transactions
-- FROM estado_tarjetas AS e
-- GROUP BY e.card_id
-- ORDER BY num_transactions DESC;

#funcion de ventana para agrupar por card_id y ordenar por timestamp
SELECT *,
ROW_NUMBER () OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS ranking_transactions
FROM estado_tarjeta
; 

#ahora necesito perdirle el top 3 de cada card_id 
SELECT *
FROM (SELECT *,
		ROW_NUMBER () OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS ranking_transactions
		FROM estado_tarjeta) AS ranking_top_3
WHERE ranking_top_3.ranking_transactions <= 3;

#evaluar si cada card_id esta activa o inactiva segun su top 3
#si las tres últimas transacciones han sido declinadas entonces es inactivo
#si al menos una no es rechazada entonces es activo
#declined 0=false=aceptada
#declined 1=true=declinada
#inactiva -> ranking=3
#activa -> ranking >=1
-- (CASE
	-- WHEN SUM(declined) = 3 THEN 'inactiva'
    -- ELSE 'activa'
    -- END AS estado_tarjetas );

#Vale pues ahora unir todas las partes en una sola query
CREATE TABLE estado_tarjetas AS
SELECT card_id,
	CASE
		WHEN SUM(declined) = 3 THEN 'inactiva'
		ELSE 'activa'
    END AS estado_tarjetas
FROM (SELECT card_id, id AS id_transaction, timestamp, declined,
		ROW_NUMBER () OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS ranking_transactions
		FROM transactions) AS ranking_top_3
WHERE ranking_top_3.ranking_transactions <= 3
GROUP BY card_id;

#Cuantas estan activas?
SELECT COUNT(estado_tarjetas)
FROM estado_tarjetas
WHERE estado_tarjetas = "activa";

#Nivel 3
	#Ejercicio 1
    
#Creacion de la tabla puente:
CREATE TABLE tabla_puente (
  transaction_id VARCHAR(100),
  product_id INT,
  PRIMARY KEY (transaction_id, product_id),
  FOREIGN KEY (transaction_id) REFERENCES transactions.transactions(id),
  FOREIGN KEY (product_id) REFERENCES transactions.products(id)
);
    
#product_ids convertida a JSON 
SELECT id AS id_transactions, product_ids, CONCAT('[', REPLACE(t.product_ids, ',', '],['), ']') AS t_prod_ids_json
FROM transactions AS t;

SELECT id AS id_transactions, 
       product_ids, 
       CONCAT('[', REPLACE(product_ids, ',', '],['), ']') AS t_prod_ids_json
FROM transactions AS t;

INSERT INTO tabla_puente (transaction_id, product_id)
SELECT 
  t.id AS transaction_id,
  jt.product_id
FROM transactions AS t,
JSON_TABLE(
  CONCAT('[', t.product_ids, ']'),
  '$[*]' COLUMNS (product_id INT PATH '$')
) AS jt;

#cuantas veces se ha vendido cada producto:
SELECT product_id, COUNT(transaction_id) AS num_ventas_por_producto
FROM tabla_puente
GROUP BY product_id
ORDER BY num_ventas_por_producto DESC;