CREATE TABLE CLIENTE(
	COD SERIAL NOT NULL PRIMARY KEY,
	NOME VARCHAR(100) NOT NULL,
	CPF VARCHAR(15) NOT NULL UNIQUE,
	CONTATO VARCHAR(20) NOT NULL,
	EMAIL VARCHAR(50) NOT NULL
);

CREATE TABLE CARGO(
	COD SERIAL NOT NULL PRIMARY KEY,
	NOME VARCHAR(50) NOT NULL,
	SALARIO NUMERIC(8,2) NOT NULL
);

CREATE TABLE LOJA
	COD SERIAL NOT NULL PRIMARY KEY,
	NOME VARCHAR(50) NOT NULL
);

CREATE TABLE FUNCIONARIO(
	COD SERIAL NOT NULL PRIMARY KEY,
	COD_CARGO INT NOT NULL REFERENCES CARGO(COD) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	COD_LOJA INT NOT NULL REFERENCES LOJA(COD) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	NOME VARCHAR(100) NOT NULL,
	CPF VARCHAR(15) NOT NULL UNIQUE,
	CONTATO VARCHAR(20) NOT NULL,
	EMAIL VARCHAR(50) NOT NULL
);

CREATE TABLE PAGAMENTO(
	COD SERIAL NOT NULL PRIMARY KEY,
	NOME VARCHAR(50) NOT NULL
);

CREATE TABLE CATEGORIA(
	COD SERIAL NOT NULL PRIMARY KEY,
	NOME VARCHAR(100) NOT NULL,
	DESCRICAO TEXT NOT NULL
);

CREATE TABLE PRODUTO(
	COD SERIAL NOT NULL PRIMARY KEY,
	COD_CATEGORIA INT NOT NULL REFERENCES CATEGORIA(COD) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	NOME VARCHAR(50) NOT NULL,
	VALOR_UNITARIO NUMERIC(8,2) NOT NULL
);

CREATE TABLE ESTOQUE(
	COD SERIAL NOT NULL PRIMARY KEY, 
	COD_PRODUTO INT NOT NULL REFERENCES PRODUTO(COD) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	COD_LOJA INT NOT NULL REFERENCES LOJA(COD) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	QUANTIDADE INT NOT NULL
);

CREATE TABLE PEDIDO(
	COD SERIAL NOT NULL PRIMARY KEY,
	COD_CLIENTE INT NOT NULL REFERENCES CLIENTE(COD) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	COD_FUNCIONARIO INT NOT NULL REFERENCES FUNCIONARIO(COD) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	COD_PAGAMENTO INT NOT NULL REFERENCES PAGAMENTO(COD) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	VALOR_TOTAL NUMERIC(8,2) NOT NULL,
	DATA_HORA TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	PAGO BOOLEAN DEFAULT FALSE NOT NULL
);

CREATE TABLE ITEM_PEDIDO(
	COD SERIAL NOT NULL PRIMARY KEY,
	COD_PEDIDO INT NOT NULL REFERENCES PEDIDO(COD) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	COD_ESTOQUE INT NOT NULL REFERENCES ESTOQUE(COD) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	QUANTIDADE INT NOT NULL,
	VALOR_TOTAL_ITEM NUMERIC(8,2) NOT NULL
);