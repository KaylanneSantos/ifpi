----------------------------------------------TRIGGER DE VERIFICAÇÃO-----------------------------------------------------------
CREATE OR REPLACE FUNCTION CHECK_EXIST_CLIENTE() --DROP FUNCTION CHECK_EXIST_CLIENTE
RETURNS TRIGGER AS $$
BEGIN
	/*IF EXISTS(SELECT * FROM CLIENTE WHERE (NOME ILIKE NEW.NOME OR CPF ILIKE NEW.CPF) AND COD <> NEW.COD) THEN
		RAISE EXCEPTION 'O CLIENTE JÁ EXISTE.';
	END IF;*/
	
	IF (TG_OP = 'INSERT') THEN
		IF EXISTS(SELECT 1 FROM FUNCIONARIO WHERE NOME ILIKE NEW.NOME OR CPF ILIKE NEW.CPF) THEN
			RAISE EXCEPTION 'O FUNCIONÁRIO JÁ EXISTE.';
		END IF;
	ELSIF (TG_OP = 'UPDATE') THEN
		IF EXISTS(SELECT 1 FROM FUNCIONARIO WHERE (NOME ILIKE NEW.NOME OR CPF ILIKE NEW.CPF) AND COD <> NEW.COD) THEN
			RAISE EXCEPTION 'O FUNCIONÁRIO JÁ EXISTE.';
		END IF;
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER TG_INSERT_CLIENTE --DROP TRIGGER TG_INSERT_CLIENTE ON CLIENTE
BEFORE INSERT OR UPDATE ON CLIENTE
FOR EACH ROW
EXECUTE FUNCTION CHECK_EXIST_CLIENTE();

CREATE OR REPLACE FUNCTION CHECK_EXIST_CARGO() --DROP FUNCTION CHECK_EXIST_CARGO
RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS(SELECT * FROM CARGO WHERE NOME ILIKE NEW.NOME) THEN
		RAISE EXCEPTION 'O CARGO JÁ EXISTE.';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER TG_INSERT_CARGO --DROP TRIGGER TG_INSERT_CARGO ON CARGO
BEFORE INSERT OR UPDATE ON CARGO
FOR EACH ROW
EXECUTE FUNCTION CHECK_EXIST_CARGO();

CREATE OR REPLACE FUNCTION CHECK_EXIST_LOJA() --DROP FUNCTION CHECK_EXIST_LOJA
RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS(SELECT * FROM LOJA WHERE NOME ILIKE NEW.NOME OR CNPJ ILIKE NEW.CNPJ) THEN
		RAISE EXCEPTION 'O LOJA JÁ EXISTE.';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER TG_INSERT_LOJA --DROP TRIGGER TG_INSERT_LOJA ON LOJA
BEFORE INSERT OR UPDATE ON LOJA
FOR EACH ROW
EXECUTE FUNCTION CHECK_EXIST_LOJA();

CREATE OR REPLACE FUNCTION CHECK_EXIST_FUNCIONARIO() --DROP FUNCTION CHECK_EXIST_FUNCIONARIO
RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS(SELECT * FROM FUNCIONARIO WHERE NOME ILIKE NEW.NOME OR CPF ILIKE NEW.CPF) THEN
		RAISE EXCEPTION 'O FUNCIONÁRIO JÁ EXISTE.';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER TG_INSERT_FUNCIONARIO --DROP TRIGGER TG_INSERT_FUNCIONARIO ON FUNCIONARIO
BEFORE INSERT OR UPDATE ON FUNCIONARIO
FOR EACH ROW
EXECUTE FUNCTION CHECK_EXIST_FUNCIONARIO();

CREATE OR REPLACE FUNCTION CHECK_EXIST_CATEGORIA() --DROP FUNCTION CHECK_EXIST_CATEGORIA
RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS(SELECT * FROM CATEGORIA WHERE NOME ILIKE NEW.NOME) THEN
		RAISE EXCEPTION 'O CATEGORIA JÁ EXISTE.';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER TG_INSERT_CATEGORIA --DROP TRIGGER TG_INSERT_CATEGORIA ON CATEGORIA
BEFORE INSERT OR UPDATE ON CATEGORIA
FOR EACH ROW
EXECUTE FUNCTION CHECK_EXIST_CATEGORIA();

CREATE OR REPLACE FUNCTION CHECK_EXIST_PRODUTO() --DROP FUNCTION CHECK_EXIST_PRODUTO
RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS(SELECT * FROM PRODUTO WHERE NOME ILIKE NEW.NOME) THEN
		RAISE EXCEPTION 'O PRODUTO JÁ EXISTE.';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER TG_INSERT_PRODUTO --DROP TRIGGER TG_INSERT_PRODUTO ON PRODUTO
BEFORE INSERT OR UPDATE ON PRODUTO
FOR EACH ROW
EXECUTE FUNCTION CHECK_EXIST_PRODUTO();

CREATE OR REPLACE FUNCTION CHECK_EXIST_PAGAMENTO() --DROP FUNCTION CHECK_EXIST_PAGAMENTO
RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS(SELECT * FROM PAGAMENTO WHERE NOME ILIKE NEW.NOME) THEN
		RAISE EXCEPTION 'O PAGAMENTO JÁ EXISTE.';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER TG_INSERT_PAGAMENTO --DROP TRIGGER TG_INSERT_PAGAMENTO ON PAGAMENTO
BEFORE INSERT OR UPDATE ON PAGAMENTO
FOR EACH ROW
EXECUTE FUNCTION CHECK_EXIST_PAGAMENTO();

CREATE OR REPLACE FUNCTION CHECK_EXIST_ESTOQUE() --DROP FUNCTION CHECK_EXIST_ESTOQUE
RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS(SELECT * FROM ESTOQUE WHERE COD_PRODUTO = NEW.COD_PRODUTO AND COD_LOJA = NEW.COD_LOJA) THEN
		RAISE EXCEPTION 'O ESTOQUE PARA ESTE PRODUTO NESSA LOJA JÁ EXISTE.';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER TG_INSERT_ESTOQUE --DROP TRIGGER TG_INSERT_ESTOQUE ON ESTOQUE
BEFORE INSERT OR UPDATE ON ESTOQUE
FOR EACH ROW
EXECUTE FUNCTION CHECK_EXIST_ESTOQUE();