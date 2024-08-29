---------------------------------------------------REVISÃO PROVA 2----------------------------------------------------------------------
CREATE TABLE PRODUTO(
	COD SERIAL PRIMARY KEY,
	NOME VARCHAR(50) NOT NULL,
	QUANTIDADE INT NOT NULL
);

CREATE TABLE COMBO(
	COD_PROD_COMBO INT NOT NULL REFERENCES PRODUTO(COD),
	COD_PROD INT NOT NULL REFERENCES PRODUTO(COD),
	QUANTIDADE INT NOT NULL	
);

/*
*****************************************************PRODUTO CARTESIANO******************************************
1.(UPDATE) CRIAR UMA FUNÇÃO QUE DECREMENTA SOMENTE OS PRODUTOS COMBOS, COMO CONSEQUÊNCIA DECREMENTAR OS PRODUTOS
QUE COMPÔEM OS COMBOS. A FUNÇÃO IRÁ RECEBER: CÓDIGO DO PRODUTO E QUANTIDADE. 
obs:considere que só exista um combo.

2.(DELETE) CRIAR UMA FUNÇÃO QUE RECEBA O CÓDIGO DE UM PRODUTO NÃO COMBO, SE ESSE PRODUTO NÃO COMBO FIZER PARTE
DE UM COMBO, DELETAR ESSE PRODUTO DO COMBO.
*/