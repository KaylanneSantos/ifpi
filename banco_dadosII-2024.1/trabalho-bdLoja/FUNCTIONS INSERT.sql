------------------------------------------FUNCTIONS INSERT----------------------------------------------------

CREATE OR REPLACE FUNCTION ADD_CLIENTE(NOME_C VARCHAR(100), CPF_C VARCHAR(15), CONTATO_C VARCHAR(20), EMAIL_C VARCHAR(50))
RETURNS VOID AS $$
BEGIN 
	IF NOT EXISTS(SELECT * FROM CLIENTE WHERE NOME ILIKE NOME_C OR CPF_C = CPF) THEN
		INSERT INTO CLIENTE(NOME, CPF, CONTATO, EMAIL) VALUES (TRIM(NOME_C), TRIM(CPF_C), TRIM(CONTATO_C), TRIM(EMAIL_C));
		RAISE NOTICE 'O CLIENTE %, % FOI CADASTRADO COM SUCESSO.', NOME_C, CPF_C;
	ELSE
		RAISE EXCEPTION 'O CLIENTE JÁ EXISTE.';
	END IF;	
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ADD_CARGO(NOME_C VARCHAR(50), SALARIO_C NUMERIC(8,2), COMISSAO_C NUMERIC(4,2))--DROP FUNCTION ADD_CARGO
RETURNS VOID AS $$ 
BEGIN 
	IF NOT EXISTS(SELECT * FROM CARGO WHERE NOME ILIKE NOME_C) THEN 
		INSERT INTO CARGO (NOME,SALARIO,COMISSAO) VALUES (TRIM(NOME_C),SALARIO_C,COMISSAO_C);
		RAISE NOTICE 'O CARGO % FOI CADASTRADO COM SUCESSO.', NOME_C;
	ELSE 
		RAISE EXCEPTION 'O CARGO JÁ EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL; 

CREATE OR REPLACE FUNCTION ADD_LOJA(NOME_L VARCHAR(20), CNPJ_L VARCHAR(18), ENDERECO_L TEXT)--DROP FUNCTION ADD_LOJA
RETURNS VOID AS $$
BEGIN
	IF NOT EXISTS(SELECT * FROM LOJA WHERE NOME ILIKE NOME_L OR CNPJ ILIKE CNPJ_L) THEN 
		INSERT INTO LOJA(NOME,CNPJ,ENDERECO) VALUES(TRIM(NOME_L),TRIM(CNPJ_L),TRIM(ENDERECO_L));
		RAISE NOTICE 'A % FOI CADASTRADA COM SUCESSO', NOME_L;
	ELSE 
		RAISE EXCEPTION 'O NOME DA LOJA OU O CNPJ JÁ EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ADD_FUNCIONARIO(--DROP FUNCTION ADD_FUNCIONARIO 
	NOME_F VARCHAR(100), 
	CPF_F VARCHAR(50), 
	CONTATO_F VARCHAR(50), 
	EMAIL_F VARCHAR(50),	
	NOME_CAR VARCHAR(50), 
	NOME_LOJ VARCHAR(20))
RETURNS VOID AS $$
DECLARE 
	COD_CAR INT;
	COD_LOJ INT;
BEGIN
	IF NOT EXISTS(SELECT * FROM FUNCIONARIO WHERE NOME ILIKE NOME_F OR CPF ILIKE CPF_F) THEN 
		IF EXISTS(SELECT * FROM CARGO WHERE NOME ILIKE NOME_CAR) THEN
			IF EXISTS(SELECT * FROM LOJA WHERE NOME = NOME_LOJ) THEN
				SELECT COD INTO COD_CAR FROM CARGO WHERE NOME ILIKE TRIM(NOME_CAR);
				SELECT COD INTO COD_LOJ FROM LOJA WHERE NOME ILIKE TRIM(NOME_LOJ);
	
				INSERT INTO FUNCIONARIO (COD_CARGO, COD_LOJA, NOME, CPF, CONTATO, EMAIL) VALUES(COD_CAR, COD_LOJ, TRIM(NOME_F), TRIM(CPF_F), TRIM(CONTATO_F), TRIM(EMAIL_F));
				RAISE NOTICE 'O FUNCIONARIO %, % FOI CADASTRADO COM SUCESSO', NOME_F, CPF_F;
			ELSE 
				RAISE EXCEPTION 'A LOJA NÃO EXISTE.';
			END IF;
		ELSE
			RAISE EXCEPTION 'O CARGO NÃO EXISTE.';
		END IF;
	ELSE
		RAISE EXCEPTION 'O FUNCIONARIO JÁ EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ADD_CATEGORIA(NOME_C VARCHAR(50), DESC_C TEXT) 
RETURNS VOID AS $$
BEGIN
	IF NOT EXISTS(SELECT * FROM CATEGORIA WHERE NOME ILIKE NOME_C) THEN
		INSERT INTO CATEGORIA(NOME, DESCRICAO) VALUES(TRIM(NOME_C), TRIM(DESC_C));
		RAISE NOTICE 'A CATEGORIA % FOI CADASTRADA COM SUCESSO', NOME_C;
	ELSE 
		RAISE EXCEPTION 'A CATEGORIA JÁ EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ADD_PRODUTO(NOME_CAT VARCHAR(50), NOME_P VARCHAR(50), VALOR_P NUMERIC(8,2))--DROP FUNCTION ADD_PRODUTO
RETURNS VOID AS $$ 
DECLARE
	COD_CAT INT;
BEGIN
	SELECT COD INTO COD_CAT FROM CATEGORIA WHERE NOME ILIKE TRIM(NOME_CAT);
	
	IF EXISTS(SELECT * FROM CATEGORIA WHERE NOME ILIKE NOME_CAT) THEN
		IF NOT EXISTS(SELECT * FROM PRODUTO WHERE NOME ILIKE NOME_P) THEN
			INSERT INTO PRODUTO(COD_CATEGORIA, NOME, VALOR_UNITARIO) VALUES(COD_CAT, TRIM(NOME_P), VALOR_P);
			RAISE NOTICE 'O PRODUTO % FOI CADASTRADO COM SUCESSO.', NOME_CAT;
		ELSE 
			RAISE EXCEPTION 'O PRODUTO JÁ EXISTE.';
		END IF;
	ELSE 
		RAISE EXCEPTION 'A CATEGORIA NÃO EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ADD_PAGAMENTO(NOME_PAG VARCHAR(50))
RETURNS VOID AS $$
BEGIN
	IF NOT EXISTS(SELECT * FROM PAGAMENTO WHERE NOME ILIKE NOME_PAG) THEN
		INSERT INTO PAGAMENTO(NOME) VALUES(TRIM(NOME_PAG));
		RAISE NOTICE 'O PAGAMENTO % FOI CADASTRADO COM SUCESSO.', NOME_PAG;
	ELSE 
		RAISE EXCEPTION 'O PAGAMENTO JÁ EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ADD_ESTOQUE(NOME_PROD VARCHAR(50), NOME_LOJ VARCHAR(20), QUANT_P INT)--DROP FUNCTION ADD_ESTOQUE
RETURNS VOID AS $$
DECLARE
	COD_PROD INT;
	COD_LOJ INT;
BEGIN 
	SELECT COD INTO COD_PROD FROM PRODUTO WHERE NOME ILIKE TRIM(NOME_PROD);
	SELECT COD INTO COD_LOJ FROM LOJA WHERE NOME ILIKE TRIM(NOME_LOJ);
	
	IF EXISTS(SELECT * FROM PRODUTO WHERE NOME ILIKE NOME_PROD) THEN 
		IF EXISTS(SELECT * FROM LOJA WHERE NOME ILIKE NOME_LOJ) THEN
			INSERT INTO ESTOQUE(COD_PRODUTO, COD_LOJA, QUANTIDADE) VALUES(COD_PROD, COD_LOJ, QUANT_P);
			RAISE NOTICE 'ESTOQUE CADASTRADO COM SUCESSO.';
		ELSE 
			RAISE EXCEPTION 'A LOJA NÃO EXISTE.';
		END IF;
	ELSE 
		RAISE EXCEPTION 'O PRODUTO NÃO EXISTE.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

----------------------------------------------------FUNCOES DE CADASTRO---------------------------------------------------------------
CREATE OR REPLACE FUNCTION CADASTRAR(--CLIENTE DROP FUNCTION CADASTRAR(VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR)
	TABELA VARCHAR(15), 
	NOME VARCHAR(100), 
	CPF VARCHAR(15), 
	CONTATO VARCHAR(20), 
	EMAIL VARCHAR(50)) 
RETURNS VOID AS $$
BEGIN 
	IF TABELA ILIKE 'CLIENTE' THEN
		PERFORM ADD_CLIENTE(NOME, CPF, CONTATO, EMAIL);
	ELSIF TABELA ILIKE 'CARGO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'LOJA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'FUNCIONARIO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PAGAMENTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION CADASTRAR(--LOJA DROP FUNCTION CADASTRAR(VARCHAR,VARCHAR,VARCHAR,TEXT)
	TABELA VARCHAR(15), 
	NOME VARCHAR(20), 
	CNPJ VARCHAR(18), 
	ENDERECO TEXT) 
RETURNS VOID AS $$
BEGIN 
	IF TABELA ILIKE 'CLIENTE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CARGO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'LOJA' THEN
		PERFORM ADD_LOJA(NOME, CNPJ, ENDERECO);
	ELSIF TABELA ILIKE 'FUNCIONARIO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PAGAMENTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION CADASTRAR(--CARGO DROP FUNCTION CADASTRAR(VARCHAR,VARCHAR,NUMERIC,NUMERIC)
	TABELA VARCHAR(15), 
	NOME VARCHAR(50), 
	SALARIO NUMERIC(8,2),
	COMISSAO NUMERIC(4,2)) 
RETURNS VOID AS $$
BEGIN 
	IF TABELA ILIKE 'CLIENTE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CARGO' THEN
		PERFORM ADD_CARGO(NOME, SALARIO, COMISSAO);
	ELSIF TABELA ILIKE 'LOJA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'FUNCIONARIO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PAGAMENTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION CADASTRAR(--PAGAMENTO DROP FUNCTION CADASTRAR(VARCHAR,VARCHAR)
	TABELA VARCHAR(15), 
	NOME VARCHAR(50))
RETURNS VOID AS $$
BEGIN 
	IF TABELA ILIKE 'CLIENTE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CARGO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'LOJA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'FUNCIONARIO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PAGAMENTO' THEN
		PERFORM ADD_PAGAMENTO(NOME);
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION CADASTRAR(--FUNCIONARIO DROP FUNCTION CADASTRAR(VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR)
	TABELA VARCHAR(15),  
	NOME VARCHAR(100), 
	CPF VARCHAR(15), 
	CONTATO VARCHAR(20), 
	EMAIL VARCHAR(50),
	NOME_CAR VARCHAR(50), 
	NOME_LOJ VARCHAR(20)) 
RETURNS VOID AS $$
BEGIN 
	IF TABELA ILIKE 'CLIENTE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CARGO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'LOJA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'FUNCIONARIO' THEN
		PERFORM ADD_FUNCIONARIO(NOME, CPF, CONTATO, EMAIL,NOME_CAR, NOME_LOJ);
	ELSIF TABELA ILIKE 'PAGAMENTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION CADASTRAR(--CATEGORIA DROP FUNCTION CADASTRAR(VARCHAR,VARCHAR,TEXT)
	TABELA VARCHAR(15), 
	NOME VARCHAR(50), 
	DESCRICAO TEXT) 
RETURNS VOID AS $$
BEGIN 
	IF TABELA ILIKE 'CLIENTE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CARGO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'LOJA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'FUNCIONARIO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PAGAMENTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		PERFORM ADD_CATEGORIA(NOME, DESCRICAO);
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION CADASTRAR(--PRODUTO DROP FUNCTION CADASTRAR(VARCHAR,VARCHAR,VARCHAR,NUMERIC)
	TABELA VARCHAR(15), 
	CATEGORIA VARCHAR(50), 
	PRODUTO VARCHAR(50), 
	VALOR NUMERIC(8,2)) 
RETURNS VOID AS $$
BEGIN 
	IF TABELA ILIKE 'CLIENTE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CARGO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'LOJA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'FUNCIONARIO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PAGAMENTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		PERFORM ADD_PRODUTO(CATEGORIA, PRODUTO, VALOR);
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		PERFORM ADD_PRODUTO(CATEGORIA, PRODUTO, VALOR);
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION CADASTRAR(--ESTOQUE DROP FUNCTION CADASTRAR(VARCHAR,VARCHAR,VARCHAR,INT)
	TABELA VARCHAR(15), 
	PRODUTO VARCHAR(50), 
	LOJA VARCHAR(20), 
	QUANTIDADE INT) 
RETURNS VOID AS $$
BEGIN 
	IF TABELA ILIKE 'CLIENTE' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CARGO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'LOJA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'FUNCIONARIO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PAGAMENTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'CATEGORIA' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'PRODUTO' THEN
		RAISE EXCEPTION 'PARÂMETROS INCORRETOS.';
	ELSIF TABELA ILIKE 'ESTOQUE' THEN
		PERFORM ADD_ESTOQUE(PRODUTO, LOJA, QUANTIDADE);
	ELSE
		RAISE EXCEPTION 'TABELA NÃO ENCONTRADA.';
	END IF;
END;
$$ LANGUAGE PLPGSQL;