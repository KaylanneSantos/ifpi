/*	
'^[^a-zA-Z0-9]+$' - caracteres especiais
'^[0-9]{3}\.[0-9]{3}\.[0-9]{3}\-[0-9]{2}$' - formato cpf
'^\([0-9]{2}\) [0-9]{10}' - formato contato
'.*[0-9].*' - numeros dentro de uma string
'^[0-9]' - numeros no comeco da string
*/

------------------------------------------------EXCEÇÕES--------------------------------------------------------------
CREATE OR REPLACE FUNCTION VERIFICAR_ATRIBUTOS_INT(ATRIBUTOS VARCHAR[]) --CHECK_VALUES_INT
RETURNS VOID AS $$ 
DECLARE 
	ATRIBUTO VARCHAR;
BEGIN 
    FOREACH ATRIBUTO IN ARRAY ATRIBUTOS
    LOOP
		IF ATRIBUTO !~ '^[0-9\.\(\)\-\s]+$' THEN
			RAISE EXCEPTION 'ERROR: VALOR INVÁLIDO %.', ATRIBUTO;
		ELSIF ATRIBUTO = '' OR TRIM(ATRIBUTO) = '' THEN
			RAISE EXCEPTION 'ERROR: ATRIBUTO VÁZIO.';
		END IF;
    END LOOP;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION TRIGGER_VERIFICAR_ATRIBUTOS()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM VERIFICAR_ATRIBUTOS_INT(ARRAY[NEW.CPF, NEW.CONTATO]);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--TRIGGER BY TABLE
CREATE TRIGGER TRIGGER_ADD_ALTER
BEFORE INSERT OR UPDATE ON CLIENTE
FOR EACH ROW 
EXECUTE FUNCTION TRIGGER_VERIFICAR_ATRIBUTOS()

CREATE TRIGGER TRIGGER_ADD_ALTER
BEFORE INSERT OR UPDATE ON FUNCIONARIO
FOR EACH ROW 
EXECUTE FUNCTION TRIGGER_VERIFICAR_ATRIBUTOS()

---------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION VERIFICAR_ATRIBUTOS_VARCHAR(ATRIBUTO VARCHAR) -- CHECK_VALUES_VARCHAR
RETURNS VOID AS $$
BEGIN
	IF ATRIBUTO ~ '.*[0-9].*' OR ATRIBUTO ~ '[0-9]' THEN 
		RAISE EXCEPTION 'ERROR: ATRIBUTO INVÁLIDO %', ATRIBUTO;
	ELSIF ATRIBUTO = '' OR TRIM(ATRIBUTO) = '' THEN
		RAISE EXCEPTION 'ERROR: ATRIBUTO VAZIO.';
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION TRIGGER_VERIFICAR_ATRIBUTO()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM VERIFICAR_ATRIBUTOS_VARCHAR(NEW.NOME);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--TRIGGER BY TABLE
CREATE TRIGGER TRIGGER_INSERT_UPDATE
BEFORE INSERT OR UPDATE ON CLIENTE
FOR EACH ROW
EXECUTE FUNCTION TRIGGER_VERIFICAR_ATRIBUTO();

CREATE TRIGGER TRIGGER_INSERT_UPDATE
BEFORE INSERT OR UPDATE ON CARGO
FOR EACH ROW
EXECUTE FUNCTION TRIGGER_VERIFICAR_ATRIBUTO();

CREATE TRIGGER TRIGGER_INSERT_UPDATE
BEFORE INSERT OR UPDATE ON FUNCIONARIO
FOR EACH ROW
EXECUTE FUNCTION TRIGGER_VERIFICAR_ATRIBUTO();

CREATE TRIGGER TRIGGER_INSERT_UPDATE
BEFORE INSERT OR UPDATE ON PAGAMENTO
FOR EACH ROW
EXECUTE FUNCTION TRIGGER_VERIFICAR_ATRIBUTO();

CREATE TRIGGER TRIGGER_INSERT_UPDATE
BEFORE INSERT OR UPDATE ON CATEGORIA
FOR EACH ROW
EXECUTE FUNCTION TRIGGER_VERIFICAR_ATRIBUTO();

CREATE TRIGGER TRIGGER_INSERT_UPDATE
BEFORE INSERT OR UPDATE ON PRODUTO
FOR EACH ROW
EXECUTE FUNCTION TRIGGER_VERIFICAR_ATRIBUTO();

-----------------------------------------------------FUNÇÕES DE VENDA-----------------------------------------------------------

CREATE OR REPLACE FUNCTION ADD_PEDIDO(
	CPF_C VARCHAR(15), 
	NOME_P VARCHAR(50), 
	QUANT_V INT, 
	NOME_PAG VARCHAR(50), 
	CPF_F VARCHAR(15))
RETURNS VOID AS $$
DECLARE
	COD_PDD INT; --PEDIDO
	COD_C INT;
	COD_P INT;
	COD_F INT;
	COD_E INT;
	QUANT_E INT;
	VALOR_UNIT NUMERIC(8,2);
	COD_PAG INT;
BEGIN
	SELECT COD INTO COD_C FROM CLIENTE WHERE CPF ILIKE CPF_C;
	SELECT COD INTO COD_F FROM FUNCIONARIO WHERE CPF ILIKE CPF_F;
	SELECT COD INTO COD_P FROM PRODUTO WHERE NOME ILIKE NOME_P;
	SELECT COD INTO COD_PDD FROM PEDIDO WHERE COD_CLIENTE = COD_C AND PAGO = FALSE;
	SELECT COD INTO COD_E FROM ESTOQUE WHERE COD_PRODUTO = COD_P;

	SELECT QUANTIDADE INTO QUANT_E FROM ESTOQUE WHERE COD_PRODUTO = COD_P;
	SELECT VALOR_UNITARIO INTO VALOR_UNIT FROM PRODUTO WHERE COD = COD_P;
	SELECT COD INTO COD_PAG FROM PAGAMENTO WHERE NOME ILIKE NOME_PAG;

	IF EXISTS(SELECT * FROM FUNCIONARIO F JOIN CARGO C ON C.COD = F.COD_CARGO JOIN LOJA L ON L.COD = F.COD_LOJA WHERE F.COD = COD_F AND C.NOME ILIKE 'Caixa' ) THEN
		IF (QUANT_E >= QUANT_V) THEN
			IF EXISTS(SELECT * FROM PEDIDO WHERE COD = COD_PDD) THEN
				IF NOT EXISTS(SELECT * FROM PAGAMENTO WHERE COD = COD_PAG) THEN
					RAISE EXCEPTION 'O TIPO DE PAGAMENTO % NÃO EXISTE.', NOME_PAG;
				ELSE
					IF NOT EXISTS(SELECT * FROM PEDIDO P JOIN CLIENTE C ON C.COD = P.COD_CLIENTE) THEN
						RAISE EXCEPTION 'O PEDIDO % JÁ EXISTE, PORÉM OS DADOS NÃO CORRESPONDEM', COD_PDD;
					ELSIF EXISTS(SELECT * FROM ITEM_PEDIDO IP JOIN ESTOQUE E ON E.COD = IP.COD_ESTOQUE JOIN PRODUTO P ON P.COD = E.COD_PRODUTO WHERE IP.COD = COD_PDD AND COD_P = E.COD_PRODUTO) THEN
						UPDATE ITEM_PEDIDO SET 
							QUANTIDADE = QUANTIDADE + QUANT_V,
							VALOR_TOTAL_ITEM = VALOR_TOTAL_ITEM + (VALOR_UNIT * QUANT_V)
						WHERE COD_PEDIDO = COD_PDD AND COD_ESTOQUE = COD_E; 
						RAISE INFO 'PEDIDO ATUALIZADO COM SUCESSO.';
	
					ELSE 
						INSERT INTO ITEM_PEDIDO(COD_PEDIDO, COD_ESTOQUE, QUANTIDADE, VALOR_TOTAL_ITEM) VALUES(COD_PDD, COD_E, QUANT_V, (QUANT_V * VALOR_UNIT));
						RAISE INFO 'PEDIDO ADICIONADO COM SUCESSO.';
	
					END IF;
					UPDATE PEDIDO SET VALOR_TOTAL = VALOR_TOTAL + (VALOR_UNIT * QUANT_V) WHERE COD = COD_PDD;
				END IF;
			ELSE 
				-- PEDIDO
				INSERT INTO PEDIDO(COD_CLIENTE, COD_FUNCIONARIO, COD_PAGAMENTO, VALOR_TOTAL)
				VALUES(COD_C, COD_F, COD_PAG, (VALOR_UNIT * QUANT_V)) RETURNING COD INTO COD_PDD;
	
				-- ITEM_PEDIDO
				INSERT INTO ITEM_PEDIDO(COD_PEDIDO, COD_ESTOQUE, QUANTIDADE, VALOR_TOTAL_ITEM)
				VALUES(COD_PDD, COD_E, QUANT_V, (VALOR_UNIT * QUANT_V));

				RAISE INFO 'PEDIDO CRIADO COM SUCESSO.';
			END IF;
			UPDATE ESTOQUE SET QUANTIDADE = QUANTIDADE - QUANT_V WHERE COD = COD_E;
		ELSE
			RAISE EXCEPTION 'QUANTIDADE EM ESTOQUE INSUFICIENTE.';
		END IF;
	
	ELSIF EXISTS(SELECT * FROM FUNCIONARIO F JOIN CARGO C ON C.COD = F.COD_CARGO JOIN LOJA L ON L.COD = F.COD_LOJA WHERE F.COD = COD_F AND C.NOME NOT ILIKE 'Caixa' ) THEN
		RAISE EXCEPTION 'O FUNCIONÁRIO % NÃO PERTENCE AO SETOR.', CPF_F;
	ELSE
		RAISE EXCEPTION 'O FUNCIONÁRIO % NÃO EXISTE.', CPF_F;
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--
SELECT ADD_PEDIDO('900.800.700-10', 'Calça Jeans Reta', 1, 'Dinheiro', '555.666.777-99')

CREATE OR REPLACE FUNCTION FINALIZAR_PEDIDO(CPF_C VARCHAR(15))
RETURNS VOID AS $$
DECLARE
	COD_C INT;
	COD_P INT;
BEGIN 
	SELECT COD INTO COD_C FROM CLIENTE WHERE CPF ILIKE CPF_C;
	SELECT COD INTO COD_P FROM PEDIDO WHERE COD_CLIENTE = COD_C AND PAGO = FALSE;

	IF EXISTS(SELECT * FROM PEDIDO WHERE COD = COD_P AND PAGO = FALSE) THEN
		UPDATE PEDIDO SET PAGO = TRUE WHERE COD = COD_P;
		RAISE INFO 'PEDIDO FINALIZADO COM SUCESSO.';
	ELSE
		RAISE EXCEPTION 'O CLIENTE % NÃO POSSUI PEDIDO EM ABERTO.', CPF_C;
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--
SELECT FINALIZAR_PEDIDO('789.123.456-78')

CREATE OR REPLACE FUNCTION NOTA_FISCAL(CPF_C VARCHAR(15))
RETURNS TABLE ("n°Pedido" VARCHAR, Cliente VARCHAR, Produto VARCHAR, Funcionario VARCHAR,Valor NUMERIC(8,2), Quantidade INT, Total NUMERIC(8,2), Data VARCHAR, Hora VARCHAR) AS $$
DECLARE
	COD_C INT;
	COD_PDD INT;
BEGIN
	SELECT COD INTO COD_C FROM CLIENTE WHERE CPF = CPF_C;
	SELECT P.COD INTO COD_PDD FROM PEDIDO P JOIN CLIENTE C ON C.COD = P.COD_CLIENTE WHERE C.COD = COD_C AND PAGO = FALSE;

	IF EXISTS(SELECT * FROM CLIENTE WHERE COD = COD_C) THEN
		IF EXISTS(SELECT * FROM PEDIDO WHERE COD = COD_PDD) THEN
			RETURN QUERY
				SELECT 
					((PDD.COD)::VARCHAR) "n°Pedido", 
					C.NOME Cliente, 
					P.NOME Produto, 
					F.NOME Funcionario,
					P.VALOR_UNITARIO Valor, 
					IP.QUANTIDADE Quantidade, 
					(P.VALOR_UNITARIO * IP.QUANTIDADE) Total, 
					(TO_CHAR(PDD.DATA_HORA, 'DD-MM-YYYY'))::VARCHAR Data, 
					(TO_CHAR(PDD.DATA_HORA, 'HH24:MI:SS'))::VARCHAR Hora
				FROM PEDIDO PDD 
					JOIN ITEM_PEDIDO IP ON IP.COD_PEDIDO = PDD.COD 
					JOIN ESTOQUE E ON E.COD = IP.COD_ESTOQUE 
					JOIN CLIENTE C ON C.COD = PDD.COD_CLIENTE 
					JOIN PRODUTO P ON P.COD = E.COD_PRODUTO 
					JOIN FUNCIONARIO F ON F.COD = PDD.COD_FUNCIONARIO
				WHERE PDD.COD = COD_PDD;
		ELSE
			RAISE EXCEPTION 'O CLIENTE NÃO POSSUI VENDAS EM ABERTO.';
		END IF;
	ELSE
		RAISE EXCEPTION 'O CLIENTE % NÃO POSSUI VENDA EM ABERTO.', CPF_C;
	END IF;
END;
$$ LANGUAGE PLPGSQL;
--
SELECT NOTA_FISCAL('789.123.456-78')





CREATE OR REPLACE FUNCTION NOTA_FISCAL2(CPF_C VARCHAR(15))
RETURNS TABLE ("n°Pedido" VARCHAR, Cliente VARCHAR, Produto VARCHAR, Funcionario VARCHAR, Valor NUMERIC(8,2), Quantidade INT, Total NUMERIC(8,2), Data VARCHAR, Hora VARCHAR) AS $$
DECLARE
    COD_C INT;
    COD_PDD INT;
BEGIN
    SELECT COD INTO COD_C FROM CLIENTE WHERE CPF = CPF_C;
    SELECT P.COD INTO COD_PDD FROM PEDIDO P JOIN CLIENTE C ON C.COD = P.COD_CLIENTE WHERE C.COD = COD_C AND PAGO = FALSE;

    IF EXISTS(SELECT * FROM CLIENTE WHERE COD = COD_C) THEN
        IF EXISTS(SELECT * FROM PEDIDO WHERE COD = COD_PDD) THEN
            RETURN QUERY
                SELECT 
                    PDD.COD::VARCHAR AS "n°Pedido", 
                    C.NOME AS Cliente, 
                    P.NOME AS Produto, 
                    F.NOME AS Funcionario,
                    P.VALOR_UNITARIO AS Valor, 
                    IP.QUANTIDADE AS Quantidade, 
                    (P.VALOR_UNITARIO * IP.QUANTIDADE) AS Total, 
                    TO_CHAR(PDD.DATA_HORA, 'DD-MM-YYYY') AS Data, 
                    TO_CHAR(PDD.DATA_HORA, 'HH24:MI:SS') AS Hora
                FROM PEDIDO PDD 
                    JOIN ITEM_PEDIDO IP ON IP.COD_PEDIDO = PDD.COD 
                    JOIN ESTOQUE E ON E.COD = IP.COD_ESTOQUE 
                    JOIN CLIENTE C ON C.COD = PDD.COD_CLIENTE 
                    JOIN PRODUTO P ON P.COD = E.COD_PRODUTO 
                    JOIN FUNCIONARIO F ON F.COD = PDD.COD_FUNCIONARIO
                WHERE PDD.COD = COD_PDD;
        ELSE
            RAISE EXCEPTION 'O CLIENTE NÃO POSSUI VENDAS EM ABERTO.';
        END IF;
    ELSE
        RAISE EXCEPTION 'O CLIENTE % NÃO POSSUI VENDA EM ABERTO.', CPF_C;
    END IF;
END;
$$ LANGUAGE PLPGSQL;

SELECT NOTA_FISCAL2('789.123.456-78')