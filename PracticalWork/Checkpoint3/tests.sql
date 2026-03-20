-- Testar procedimentos: 
--CALL LIVRARIA.AUMENTA_PRECO();


-- Testar funcoes
-- fazer selects com as funcoes no select
-- LIVRARIA.FUNCTION()

SET SERVEROUTPUT ON;

ALTER TRIGGER R_TRIG_2023146226 DISABLE;
ALTER TRIGGER ABASTECE DISABLE;
ALTER TRIGGER R_TRIG_2023140728 ENABLE;
ALTER TRIGGER UPDATE_STOCK DISABLE;
ALTER TRIGGER UPDATE_VIAGEM DISABLE;

CREATE OR REPLACE FUNCTION QUANTIDE_VENDIDA(IDMAQUINA NUMBER, IDPRODUTO NUMBER, DATA_INICIO DATE, DATA_FIM DATE)
RETURN NUMBER
IS
    DATA_FIM_MESMO DATE;
    QUANT_VENDIDA NUMBER;
    
    CONT_MAQUINA NUMBER; CONT_PRODUTO NUMBER;
    MAQUINA_NAO_EXISTE EXCEPTION;
    PRODUTO_NAO_EXISTE EXCEPTION;
    DATA_E_IMPOSSIVEL EXCEPTION;
BEGIN
    DATA_FIM_MESMO := NVL(DATA_FIM, SYSDATE);
    
    SELECT COUNT(*) INTO CONT_MAQUINA FROM MAQUINA WHERE ID_MAQUINA = IDMAQUINA;
    IF(CONT_MAQUINA=0) THEN
        RAISE MAQUINA_NAO_EXISTE;
    END IF;
    
    SELECT COUNT(*) INTO CONT_PRODUTO FROM PRODUTO WHERE ID_PRODUTO = IDPRODUTO;
    IF(CONT_PRODUTO=0) THEN
        RAISE PRODUTO_NAO_EXISTE;
    END IF;
    
    IF(DATA_FIM_MESMO < DATA_INICIO) THEN
        RAISE DATA_E_IMPOSSIVEL;
    END IF;    
    
    SELECT COUNT(*) INTO QUANT_VENDIDA
    FROM VENDAS V, COMPARTIMENTO C
    WHERE V.ID_PRODUTO = IDPRODUTO 
    AND C.ID_MAQUINA = IDMAQUINA
    AND V.ID_COMPARTIMENTO = C.ID_COMPARTIMENTO
    AND V.DATA_HORA BETWEEN DATA_INICIO AND DATA_FIM_MESMO; 
    
    RETURN QUANT_VENDIDA;

EXCEPTION
    WHEN MAQUINA_NAO_EXISTE THEN
        RAISE_APPLICATION_ERROR(-20801, 'Codigo de máquina inexistente.');
    WHEN PRODUTO_NAO_EXISTE THEN
        RAISE_APPLICATION_ERROR(-20802, 'Código de produto inexistente.');
    WHEN DATA_E_IMPOSSIVEL THEN
        RAISE_APPLICATION_ERROR(-20809, 'Inválido intervalo temporal.');
END;
/

-- Outro teste, sem passar a data de fim (usa SYSDATE por defeito)
DECLARE
    RESULTADO NUMBER;
BEGIN
    RESULTADO := QUANTIDE_VENDIDA(1, 25, TO_DATE('2025-04-13','YYYY-MM-DD'), SYSDATE);
    DBMS_OUTPUT.PUT_LINE('Quantidade vendida até hoje: ' || RESULTADO);
END;
/

select * from vendas V, COMPARTIMENTO C where V.id_produto = 25 AND C.ID_MAQUINA = 1  AND V.ID_COMPARTIMENTO = C.ID_COMPARTIMENTO;

SELECT COUNT(*)
    FROM VENDAS V, COMPARTIMENTO C
    WHERE V.ID_PRODUTO = 25 
    AND C.ID_MAQUINA = 1
    AND V.ID_COMPARTIMENTO = C.ID_COMPARTIMENTO;
    
    
    
    
    
    
    
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION QUANTIDADE_EM_FALTA (IDMAQUINA NUMBER, IDPRODUTO NUMBER)
RETURN NUMBER
IS
    STOCK_ATUAL NUMBER;
    JA_DEFINIDO NUMBER;
    DIFERENCA NUMBER;
    
    CONT_MAQUINA NUMBER; CONT_PRODUTO NUMBER;
    MAQUINA_NAO_EXISTE EXCEPTION;
    PRODUTO_NAO_EXISTE EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO CONT_MAQUINA FROM MAQUINA WHERE ID_MAQUINA = IDMAQUINA;
    IF(CONT_MAQUINA=0) THEN
        RAISE MAQUINA_NAO_EXISTE;
    END IF;
    
    SELECT COUNT(*) INTO CONT_PRODUTO FROM PRODUTO WHERE ID_PRODUTO = IDPRODUTO;
    IF(CONT_PRODUTO=0) THEN
        RAISE PRODUTO_NAO_EXISTE;
    END IF;

    SELECT STOCK, CAPAC_MAX INTO STOCK_ATUAL, JA_DEFINIDO 
    FROM COMPARTIMENTO 
    WHERE ID_MAQUINA = IDMAQUINA AND ID_PRODUTO = IDPRODUTO;
    
    DIFERENCA := GREATEST(JA_DEFINIDO - STOCK_ATUAL,0); -- PARA DAR SEMPRE 0, CASO Dï¿½ UM NUMERO NEGATIVO
    RETURN DIFERENCA;
EXCEPTION
    WHEN MAQUINA_NAO_EXISTE THEN
        RAISE_APPLICATION_ERROR(-20801, 'Código de máquina inexistente.');
    WHEN PRODUTO_NAO_EXISTE THEN
        RAISE_APPLICATION_ERROR(-20802, 'Código de produto inexistente.');
END;
/

-- Exemplo de chamada da função
DECLARE
    FALTA NUMBER;
BEGIN
    FALTA := QUANTIDADE_EM_FALTA(1, 25);
    DBMS_OUTPUT.PUT_LINE('Quantidade em falta: ' || FALTA);
END;
/

SELECT * FROM COMPARTIMENTO WHERE ID_PRODUTO = 25 AND ID_MAQUINA = 1;



---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE OR REPLACE FUNCTION QUANTIDADE_MEDIA_DIARIA (IDMAQUINA NUMBER, IDPRODUTO NUMBER) 
RETURN NUMBER
IS
    CURSOR C1 IS SELECT COUNT(V.ID_VENDA) AS QUANTIDADE_DIARIA_VENDIDA, TO_CHAR(V.DATA_HORA, 'YYYY-MM-DD') AS DIA
                 FROM VENDAS V, COMPARTIMENTO C
                 WHERE V.ID_PRODUTO = IDPRODUTO
                 AND C.ID_MAQUINA = IDMAQUINA
                 AND V.ID_COMPARTIMENTO = C.ID_COMPARTIMENTO
                 AND V.DATA_HORA > ( SELECT DATA_HORA 
                                     FROM (  SELECT DATA_HORA 
                                             FROM ( SELECT RC.DATA_HORA 
                                                     FROM REABASTECIMENTO_COMPARTIMENTO RC, COMPARTIMENTO C
                                                     WHERE RC.ID_PRODUTO = 33
                                                     AND C.ID_MAQUINA = 1
                                                     AND RC.ID_COMPARTIMENTO = C.ID_COMPARTIMENTO
                                                     ORDER BY 1 DESC)
                                             WHERE ROWNUM<=2
                                             ORDER BY 1 ASC)
                                     WHERE ROWNUM = 1)
                 GROUP BY TO_CHAR(V.DATA_HORA, 'YYYY-MM-DD');       
    CONTAGEM NUMBER := 0;
    SOMA NUMBER := 0;
    MEDIA NUMBER;

    CONT_MAQUINA NUMBER; CONT_PRODUTO NUMBER;
    MAQUINA_NAO_EXISTE EXCEPTION;
    PRODUTO_NAO_EXISTE EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO CONT_MAQUINA FROM MAQUINA WHERE ID_MAQUINA = IDMAQUINA;
    IF(CONT_MAQUINA=0) THEN
        RAISE MAQUINA_NAO_EXISTE;
    END IF;
    
    SELECT COUNT(*) INTO CONT_PRODUTO FROM PRODUTO WHERE ID_PRODUTO = IDPRODUTO;
    IF(CONT_PRODUTO=0) THEN
        RAISE PRODUTO_NAO_EXISTE;
    END IF;

    FOR R IN C1 LOOP
        CONTAGEM := CONTAGEM + 1;
        SOMA := SOMA + R.QUANTIDADE_DIARIA_VENDIDA;
    END LOOP;
    
    -- Evitar divisão por zero
    IF CONTAGEM > 0 THEN
        MEDIA := SOMA / CONTAGEM;
    ELSE
        MEDIA := 0;
    END IF;
   
    RETURN MEDIA;

EXCEPTION
    WHEN MAQUINA_NAO_EXISTE THEN
        RAISE_APPLICATION_ERROR(-20801, 'Código de máquina inexistente.');
    WHEN PRODUTO_NAO_EXISTE THEN
        RAISE_APPLICATION_ERROR(-20802, 'Código de produto inexistente.');
END;
/

ALTER TRIGGER R_TRIG_2023146226 DISABLE;
ALTER TRIGGER ABASTECE DISABLE;
ALTER TRIGGER R_TRIG_2023140728 DISABLE;
ALTER TRIGGER UPDATE_STOCK DISABLE;
ALTER TRIGGER UPDATE_VIAGEM DISABLE;

-- Todos os compartimentos já estão criados

-- Reabastecimento antigo
INSERT INTO REABASTECIMENTO_COMPARTIMENTO 
(ID_RC, ID_VISITA_MAQUINA, ID_COMPARTIMENTO, ID_PRODUTO, QUANTIDADE_REPOSTA, DATA_HORA)
VALUES (176, 1, 1, 33, 2, TO_DATE('2024-01-01 10:00', 'YYYY-MM-DD HH24:MI'));

--DELETE FROM REABASTECIMENTO_COMPARTIMENTO WHERE ID_RC = 177;

-- Reabastecimento mais recente
INSERT INTO REABASTECIMENTO_COMPARTIMENTO 
(ID_RC, ID_VISITA_MAQUINA, ID_COMPARTIMENTO, ID_PRODUTO, QUANTIDADE_REPOSTA, DATA_HORA)
VALUES (177, 1, 1, 33, 3, TO_DATE('2024-05-01 09:00', 'YYYY-MM-DD HH24:MI'));

-- Dia 1 (duas vendas)
INSERT INTO VENDAS (ID_VENDA, ID_COMPARTIMENTO, ID_PRODUTO, VALOR_VENDA, METODO_PAGAMENTO, DATA_HORA)
VALUES (2081, 1, 33, 1.5, 'MBWay', TO_DATE('2024-02-01 10:30', 'YYYY-MM-DD HH24:MI'));

INSERT INTO VENDAS (ID_VENDA, ID_COMPARTIMENTO, ID_PRODUTO, VALOR_VENDA, METODO_PAGAMENTO, DATA_HORA)
VALUES (2082, 1, 33, 1.5, 'Multibanco', TO_DATE('2024-02-01 13:20', 'YYYY-MM-DD HH24:MI'));

-- Dia 2 (uma venda)
INSERT INTO VENDAS (ID_VENDA, ID_COMPARTIMENTO, ID_PRODUTO, VALOR_VENDA, METODO_PAGAMENTO, DATA_HORA)
VALUES (2083, 1, 33, 1.5, 'MBWay', TO_DATE('2024-02-02 09:10', 'YYYY-MM-DD HH24:MI'));

--DELETE FROM VENDAS WHERE ID_VENDA = 2083;


SELECT DATA_HORA FROM (
                        SELECT DATA_HORA 
                                     FROM (  SELECT RC.DATA_HORA 
                                             FROM REABASTECIMENTO_COMPARTIMENTO RC, COMPARTIMENTO C
                                             WHERE RC.ID_PRODUTO = 33
                                             AND C.ID_MAQUINA = 1
                                             AND RC.ID_COMPARTIMENTO = C.ID_COMPARTIMENTO
                                             ORDER BY 1 DESC)
                                     WHERE ROWNUM<=2
                                     ORDER BY 1 ASC
                                     )
                                WHERE ROWNUM = 1
ORDER BY DATA_HORA;
         
SELECT DATA_HORA 
                                     FROM (  SELECT RC.DATA_HORA 
                                             FROM REABASTECIMENTO_COMPARTIMENTO RC, COMPARTIMENTO C
                                             WHERE RC.ID_PRODUTO = 33
                                             AND C.ID_MAQUINA = 1
                                             AND RC.ID_COMPARTIMENTO = C.ID_COMPARTIMENTO
                                             ORDER BY 1 DESC)WHERE ROWNUM<=2;

-- Chamar a função e mostrar o resultado no output
DECLARE
    MEDIA NUMBER;
BEGIN
    MEDIA := QUANTIDADE_MEDIA_DIARIA(1, 33);
    DBMS_OUTPUT.PUT_LINE('Média diária de vendas: ' || MEDIA);
END;
/





---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE OR REPLACE FUNCTION DATA_ULTIMO_ABASTEC (IDMAQUINA NUMBER, IDPRODUTO NUMBER) 
RETURN DATE
IS
    DATA_FINAL DATE;
    
    CONT_MAQUINA NUMBER; CONT_PRODUTO NUMBER;
    MAQUINA_NAO_EXISTE EXCEPTION;
    PRODUTO_NAO_EXISTE EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO CONT_MAQUINA FROM MAQUINA WHERE ID_MAQUINA = IDMAQUINA;
    IF(CONT_MAQUINA=0) THEN
        RAISE MAQUINA_NAO_EXISTE;
    END IF;
    
    SELECT COUNT(*) INTO CONT_PRODUTO FROM PRODUTO WHERE ID_PRODUTO = IDPRODUTO;
    IF(CONT_PRODUTO=0) THEN
        RAISE PRODUTO_NAO_EXISTE;
    END IF;

    SELECT MAX(RC.DATA_HORA) INTO DATA_FINAL
    FROM REABASTECIMENTO_COMPARTIMENTO RC, COMPARTIMENTO C
    WHERE RC.ID_COMPARTIMENTO = C.ID_COMPARTIMENTO
    AND C.ID_MAQUINA = IDMAQUINA
    AND RC.ID_PRODUTO = IDPRODUTO;
    
    IF (DATA_FINAL IS NULL) THEN
        RAISE PRODUTO_NAO_EXISTE;
    END IF;
    
    RETURN DATA_FINAL;
EXCEPTION
    WHEN MAQUINA_NAO_EXISTE THEN
        RAISE_APPLICATION_ERROR(-20801, 'Código de máquina inexistente.');
    WHEN PRODUTO_NAO_EXISTE THEN
        RAISE_APPLICATION_ERROR(-20802, 'Código de produto inexistente.');
END;
/


-- Testar função com dados válidos
DECLARE
    DATA_ABAST DATE;
BEGIN
    DATA_ABAST := DATA_ULTIMO_ABASTEC(1, 33);
    DBMS_OUTPUT.PUT_LINE('Último abastecimento: ' || TO_CHAR(DATA_ABAST, 'DD/MM/YYYY HH24:MI'));
END;
/






---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------





CREATE OR REPLACE FUNCTION DISTANCIA_ENTRE_MAQUINAS (IDMAQUINA1 NUMBER, IDMAQUINA2 NUMBER)
RETURN NUMBER
IS
    LAT1 NUMBER; LAT2 NUMBER;
    LON1 NUMBER; LON2 NUMBER;
    DISTANCIA_ENTRE_MAQUINAS NUMBER;

    CONT_MAQUINA1 NUMBER; CONT_MAQUINA2 NUMBER;
    MAQUINA1_NAO_EXISTE EXCEPTION;
    MAQUINA2_NAO_EXISTE EXCEPTION;
    MAQUINAS_INAVALIDAS EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO CONT_MAQUINA1 FROM MAQUINA WHERE ID_MAQUINA = IDMAQUINA1;
    IF(CONT_MAQUINA1=0) THEN
        RAISE MAQUINA1_NAO_EXISTE;
    END IF;
    
    SELECT COUNT(*) INTO CONT_MAQUINA2 FROM MAQUINA WHERE ID_MAQUINA = IDMAQUINA2;
    IF(CONT_MAQUINA2=0) THEN
        RAISE MAQUINA2_NAO_EXISTE;
    END IF;
    
    IF(IDMAQUINA1 = IDMAQUINA2) THEN
        RAISE MAQUINAS_INAVALIDAS;
    END IF;
    
    SELECT LATITUDE, LONGITUDE INTO LAT1, LON1 FROM MAQUINA WHERE ID_MAQUINA = IDMAQUINA1;
    SELECT LATITUDE, LONGITUDE INTO LAT2, LON2 FROM MAQUINA WHERE ID_MAQUINA = IDMAQUINA2;
    
    DISTANCIA_ENTRE_MAQUINAS := DISTANCIA_LINEAR(LAT1, LON1, LAT2, LON2);
    
    RETURN DISTANCIA_ENTRE_MAQUINAS;
EXCEPTION
    WHEN MAQUINA1_NAO_EXISTE OR MAQUINA2_NAO_EXISTE THEN
        RAISE_APPLICATION_ERROR(-20801, 'Código de máquina inexistente.');
    WHEN MAQUINAS_INAVALIDAS THEN
        RAISE_APPLICATION_ERROR(-20810, 'Máquinas inválidas. Devem ser diferentes.');
END;
/

DECLARE
    DIST NUMBER;
BEGIN
    DIST := DISTANCIA_ENTRE_MAQUINAS(1, 2);
    DBMS_OUTPUT.PUT_LINE('Distância entre máquinas: ' || ROUND(DIST, 2) || ' km');
END;
/

SELECT * FROM MAQUINA;





---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------






CREATE OR REPLACE FUNCTION DISTANCIA_VIAGEM (IDVIAGEM NUMBER)
RETURN NUMBER
IS
    CURSOR C1 IS SELECT C.ID_MAQUINA, R.ID_ARMAZEM, C.ORDEM_MAQUINA
                 FROM CONTEM C, ROTA R, VIAGEM V, VISITA_MAQUINA VM, REABASTECIMENTO_COMPARTIMENTO RC
                 WHERE V.ID_VIAGEM = IDVIAGEM
                 AND VM.ID_VIAGEM = V.ID_VIAGEM
                 AND RC.ID_VISITA_MAQUINA = VM.ID_VISITA_MAQUINA
                 AND V.ID_ROTA = R.ID_ROTA
                 AND C.ID_ROTA = R.ID_ROTA
                 ORDER BY C.ORDEM_MAQUINA ASC;
    LAT1 NUMBER; LON1 NUMBER;
    LAT_ANTIGA NUMBER; LON_ANTIGA NUMBER;
    LAT_INICIAL NUMBER; LON_INICIAL NUMBER;
    DISTANCIA_FINAL NUMBER := 0;
    CONTAGEM NUMBER;
    
    VIAGEM_INEXISTENTE EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO CONTAGEM FROM VIAGEM WHERE ID_VIAGEM = IDVIAGEM;
    IF(CONTAGEM = 0) THEN
        RAISE VIAGEM_INEXISTENTE;
    END IF;
    FOR R IN C1 LOOP
        IF(R.ORDEM_MAQUINA = 1) THEN
            SELECT LATITUDE, LONGITUDE INTO LAT1, LON1 FROM MAQUINA WHERE ID_MAQUINA = R.ID_MAQUINA;
            SELECT LATITUDE, LONGITUDE INTO LAT_INICIAL, LON_INICIAL FROM ARMAZEM WHERE ID_ARMAZEM = R.ID_ARMAZEM;
            
            DISTANCIA_FINAL := DISTANCIA_FINAL + DISTANCIA_LINEAR(LAT_INICIAL, LON_INICIAL, LAT1, LON1);
            
            LAT_ANTIGA := LAT1;
            LON_ANTIGA := LON1;
        ELSE
            SELECT LATITUDE, LONGITUDE INTO LAT1, LON1 FROM MAQUINA WHERE ID_MAQUINA = R.ID_MAQUINA;
            
            DISTANCIA_FINAL := DISTANCIA_FINAL + DISTANCIA_LINEAR(LAT_ANTIGA, LON_ANTIGA, LAT1, LON1);
            
            LAT_ANTIGA := LAT1;
            LON_ANTIGA := LON1;
        END IF;
    END LOOP;
    
    DISTANCIA_FINAL := DISTANCIA_FINAL + DISTANCIA_LINEAR(LAT_ANTIGA, LON_ANTIGA, LAT_INICIAL, LON_INICIAL);
    
    RETURN DISTANCIA_FINAL;
EXCEPTION
    WHEN VIAGEM_INEXISTENTE THEN
        RAISE_APPLICATION_ERROR(-20807,'Viagem de abastecimento inexistente.');
END;
/


DECLARE
    DIST NUMBER;
BEGIN
    DIST := DISTANCIA_VIAGEM(3);
    DBMS_OUTPUT.PUT_LINE('Distância total da viagem: ' || ROUND(DIST, 2) || ' km');
END;
/

SELECT * FROM CONTEM WHERE ID_ROTA=1;





---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE OR REPLACE FUNCTION MAQUINA_MAIS_PROXIMA (IDPRODUTO NUMBER, LAT NUMBER, LON NUMBER)
RETURN NUMBER
IS
    CURSOR C1 IS SELECT M.ID_MAQUINA, M.LATITUDE, M.LONGITUDE 
                 FROM COMPARTIMENTO C, MAQUINA M 
                 WHERE C.ID_PRODUTO = IDPRODUTO 
                 AND M.ID_MAQUINA = C.ID_MAQUINA
                 AND LOWER(M.ESTADO_ATUAL) = 'operacional'
                 AND C.STOCK > 0;
    DISTANCIA_FINAL NUMBER := 0;
    DISTANCIA_MIN NUMBER := 999999999999999999999999;
    ID_MAQ NUMBER;
    CONTAGEM NUMBER;
    
    PRODUTO_NAO_EXISTE EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO CONTAGEM FROM PRODUTO WHERE ID_PRODUTO = IDPRODUTO;
    IF(CONTAGEM = 0) THEN
        RAISE PRODUTO_NAO_EXISTE;
    END IF;
    
    FOR R IN C1 LOOP
        DISTANCIA_FINAL := DISTANCIA_LINEAR(LAT, LON, R.LATITUDE, R.LONGITUDE);
        IF(DISTANCIA_FINAL < DISTANCIA_MIN) THEN
            DISTANCIA_MIN := DISTANCIA_FINAL;
            ID_MAQ := R.ID_MAQUINA;
        END IF;
    END LOOP;
    
    IF ID_MAQ IS NULL THEN
        RAISE_APPLICATION_ERROR(-20857, 'Nenhuma máquina operacional com stock foi encontrada.');
    END IF;
    
    RETURN ID_MAQ;
EXCEPTION
    WHEN PRODUTO_NAO_EXISTE THEN
        RAISE_APPLICATION_ERROR(-20802,'Código de produto inexistente');
END;
/




SELECT M.ID_MAQUINA, M.LATITUDE, M.LONGITUDE, C.STOCK
FROM COMPARTIMENTO C
JOIN MAQUINA M ON M.ID_MAQUINA = C.ID_MAQUINA
WHERE C.ID_PRODUTO = 31
  AND LOWER(M.ESTADO_ATUAL) = 'operacional'
  AND C.STOCK > 0;
  
  
DECLARE
    ID_MAQ NUMBER;
BEGIN
    ID_MAQ := MAQUINA_MAIS_PROXIMA(31, 40.1933, -8.5103);
    IF ID_MAQ IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('ID da máquina mais próxima: ' || NVL(ID_MAQ, -1));
ELSE
    DBMS_OUTPUT.PUT_LINE('Nenhuma máquina encontrada!');
END IF;
END;
/

SELECT DISTANCIA_LINEAR(40.1933, -8.5103, 40.2095, -8.4259) FROM DUAL;





---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE OR REPLACE FUNCTION PROX_MAQUINA_SEM_PRODUTO (IDPRODUTO NUMBER, IDMAQUINA NUMBER)
RETURN NUMBER
IS
    CURSOR C1 IS SELECT M.ID_MAQUINA, M.LATITUDE, M.LONGITUDE
                 FROM MAQUINA M, COMPARTIMENTO C
                 WHERE C.ID_MAQUINA = M.ID_MAQUINA
                 AND C.ID_PRODUTO = IDPRODUTO
                 AND LOWER(M.ESTADO_ATUAL) = 'operacional'
                 AND C.STOCK = 0
                 AND M.ID_MAQUINA <> IDMAQUINA; -- para nao ler a que está a ser passada por parametro
    LAT1 NUMBER; LON1 NUMBER;
    DISTANCIA_MINIMA NUMBER := 999999999999999999999999999999999999999999999999999;
    DISTANCIA NUMBER;
    ID_MAQ NUMBER;
    
    CONT_PRODUTO NUMBER;
    PRODUTO_NAO_EXISTE EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO CONT_PRODUTO FROM PRODUTO WHERE ID_PRODUTO = IDPRODUTO;
    IF(CONT_PRODUTO = 0) THEN
        RAISE PRODUTO_NAO_EXISTE;
    END IF;
    
    SELECT LATITUDE, LONGITUDE INTO LAT1, LON1 FROM MAQUINA WHERE ID_MAQUINA = IDMAQUINA;
    FOR R IN C1 LOOP
        DISTANCIA := DISTANCIA_LINEAR(LAT1, LON1, R.LATITUDE, R.LONGITUDE);
        IF(DISTANCIA < DISTANCIA_MINIMA) THEN
            DISTANCIA_MINIMA := DISTANCIA;
            ID_MAQ := R.ID_MAQUINA;
        END IF;
    END LOOP;
    
    RETURN ID_MAQ;
EXCEPTION
    WHEN PRODUTO_NAO_EXISTE THEN
        RAISE_APPLICATION_ERROR(-20802, 'Código de produto inexistente');
END;
/

SELECT C.ID_MAQUINA, M.LATITUDE, M.LONGITUDE, C.STOCK, M.ESTADO_ATUAL
FROM COMPARTIMENTO C
JOIN MAQUINA M ON C.ID_MAQUINA = M.ID_MAQUINA
WHERE C.ID_PRODUTO = 16
  AND LOWER(M.ESTADO_ATUAL) = 'operacional';
  
UPDATE COMPARTIMENTO SET STOCK = 0 WHERE ID_PRODUTO = 16;

DECLARE
    ID_PROX_MAQ NUMBER;
BEGIN
    ID_PROX_MAQ := PROX_MAQUINA_SEM_PRODUTO(16, 6);
    DBMS_OUTPUT.PUT_LINE('ID da máquina mais próxima sem stock do produto: ' || ID_PROX_MAQ);
END;
/




---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE OR REPLACE PROCEDURE CRIA_VIAGEM_ABAST (COD_ARMAZEM NUMBER, RAIO NUMBER)
IS
    CURSOR C1 IS SELECT * 
                 FROM ( SELECT M.ID_MAQUINA
                        FROM MAQUINA M, COMPARTIMENTO C, ARMAZEM A
                        WHERE C.ID_MAQUINA = M.ID_MAQUINA
                        AND A.ID_ARMAZEM = COD_ARMAZEM
                        AND C.STOCK >= 0
                        AND DISTANCIA_LINEAR(M.LATITUDE, M.LONGITUDE, A.LATITUDE, A.LONGITUDE) <= RAIO
                        GROUP BY M.ID_MAQUINA
                        ORDER BY SUM(C.STOCK) ASC) 
                 WHERE ROWNUM <= 10; -- 10 maquinas com menos stock (no total de todos os compartimentos)
    ORDEM NUMBER := 1;
    IDROTA NUMBER;
    IDVIAGEM NUMBER;
    
    CONTAGEM NUMBER;
    ARMAZEM_NAO_EXISTE EXCEPTION;
    RAIO_ERRADO EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO CONTAGEM FROM ARMAZEM WHERE ID_ARMAZEM = COD_ARMAZEM;
    IF(CONTAGEM = 0) THEN
        RAISE ARMAZEM_NAO_EXISTE;
    END IF;
    
    IF(RAIO < 0) THEN
        RAISE RAIO_ERRADO;
    END IF;
    
    SELECT SEQ_ROTA.NEXTVAL INTO IDROTA FROM DUAL;
    INSERT INTO ROTA VALUES(IDROTA, COD_ARMAZEM, 'nao predefinido', '10 maquinas com maior rutura de stock', 500);
    
    SELECT SEQ_VIAGEM.NEXTVAL INTO IDVIAGEM FROM DUAL;
    INSERT INTO VIAGEM VALUES(IDVIAGEM, 1, IDROTA, 1, 500, SYSDATE, NULL);
        
    FOR R IN C1 LOOP
        INSERT INTO CONTEM VALUES(R.ID_MAQUINA, IDROTA, ORDEM);
        ORDEM := ORDEM +1;        
    END LOOP;
EXCEPTION 
    WHEN ARMAZEM_NAO_EXISTE THEN
        RAISE_APPLICATION_ERROR(-20806, 'Código de armazém inexistente.');
    WHEN RAIO_ERRADO THEN
        RAISE_APPLICATION_ERROR(-20811, 'Distância Inválida.');
END;
/

BEGIN
    CRIA_VIAGEM_ABAST(1, 10);  -- raio de 10 km
END;
/

SELECT * FROM ROTA WHERE ID_ARMAZEM = 1 ORDER BY ID_ROTA DESC;
SELECT * FROM VIAGEM WHERE ID_ROTA = (SELECT MAX(ID_ROTA) FROM ROTA WHERE ID_ARMAZEM = 1);
SELECT * FROM CONTEM WHERE ID_ROTA = (SELECT MAX(ID_ROTA) FROM ROTA WHERE ID_ARMAZEM = 1);





---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------




CREATE OR REPLACE PROCEDURE ENCOMENDA_PRODUTOS (COD_ARMAZEM NUMBER, DATAINICIO DATE)
IS
    CURSOR C1 IS SELECT COUNT(V.ID_VENDA) AS QUANTIDADE_VENDIDA, C.ID_PRODUTO, C.ID_COMPARTIMENTO
                 FROM VENDAS V, COMPARTIMENTO C
                 WHERE V.ID_COMPARTIMENTO = C.ID_COMPARTIMENTO
                 AND V.DATA_HORA > DATAINICIO
                 GROUP BY C.ID_PRODUTO, C.ID_COMPARTIMENTO;
    QUANTIDADE_EXISTENTE NUMBER;
    QUANT_STOCK_ARMAZEM NUMBER;
    VALOR_A_ENCOMENDAR NUMBER;
    ID_RA NUMBER;
    
    CONTAGEM NUMBER;
    ARMAZEM_NAO_EXISTE EXCEPTION;
    DATA_INVALIDA EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO CONTAGEM FROM ARMAZEM WHERE ID_ARMAZEM = COD_ARMAZEM;
    IF(CONTAGEM = 0) THEN
        RAISE ARMAZEM_NAO_EXISTE;
    END IF;
    
    IF(DATAINICIO >= SYSDATE) THEN
        RAISE DATA_INVALIDA;
    END IF;
    
    FOR R IN C1 LOOP
        SELECT SUM(STOCK) INTO QUANTIDADE_EXISTENTE FROM COMPARTIMENTO WHERE ID_COMPARTIMENTO = R.ID_COMPARTIMENTO;
        BEGIN
            SELECT QUANTIDADE_ATUAL INTO QUANT_STOCK_ARMAZEM 
            FROM ARMAZENADO 
            WHERE ID_PRODUTO = R.ID_PRODUTO AND ID_ARMAZEM = COD_ARMAZEM;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                QUANT_STOCK_ARMAZEM := 0;
        END;
        
        VALOR_A_ENCOMENDAR := R.QUANTIDADE_VENDIDA - QUANTIDADE_EXISTENTE - QUANT_STOCK_ARMAZEM;
        
        IF(VALOR_A_ENCOMENDAR > 0) THEN
            UPDATE ARMAZENADO SET QUANTIDADE_PREVISTA = VALOR_A_ENCOMENDAR, DATA_PROX_PREVISAO = SYSDATE+7 WHERE ID_PRODUTO = R.ID_PRODUTO AND ID_ARMAZEM = COD_ARMAZEM;
            IF SQL%ROWCOUNT = 0 THEN
                INSERT INTO ARMAZENADO (ID_PRODUTO, ID_ARMAZEM, QUANTIDADE_ATUAL, QUANTIDADE_PREVISTA, DATA_PROX_PREVISAO)
                VALUES (R.ID_PRODUTO, COD_ARMAZEM, 0, VALOR_A_ENCOMENDAR, SYSDATE+7);
            END IF;
            
            SELECT SEQ_RA.NEXTVAL INTO ID_RA FROM DUAL;
            INSERT INTO REABASTECIMENTO_ARMAZEM VALUES(ID_RA, COD_ARMAZEM, R.ID_PRODUTO, VALOR_A_ENCOMENDAR, SYSDATE+7);
        END IF;
    END LOOP;
EXCEPTION
    WHEN ARMAZEM_NAO_EXISTE THEN
        RAISE_APPLICATION_ERROR(-20806, 'Código de armazém inexistente.');
    WHEN DATA_INVALIDA THEN
        RAISE_APPLICATION_ERROR(-20812, 'Data inválida. Deve ser anterior à data atual.');
END;
/

BEGIN
    ENCOMENDA_PRODUTOS(1, TO_DATE('2024-01-01', 'YYYY-MM-DD'));
END;
/

-- Verifica se houve previsão
SELECT * FROM ARMAZENADO WHERE ID_ARMAZEM = 1 AND QUANTIDADE_PREVISTA IS NOT NULL;

-- Verifica novas encomendas
SELECT * FROM REABASTECIMENTO_ARMAZEM WHERE ID_ARMAZEM = 1 ORDER BY DATA_REABASTECIMENTO DESC;





---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------




CREATE OR REPLACE PROCEDURE ABASTECE_PRODUTO (COD_ARMAZEM NUMBER, COD_PRODUTO NUMBER, QUANTIDADE NUMBER)
IS
    CURSOR C1 IS SELECT C.ID_MAQUINA
                 FROM COMPARTIMENTO C 
                 WHERE C.ID_PRODUTO = COD_PRODUTO
                 ORDER BY C.STOCK ASC;
    ID_ROTA NUMBER;
    ID_VIAGEM NUMBER;
    ID_VM NUMBER;
    ID_RC NUMBER;
    ID_C NUMBER;
    
    QUANT_STOCK_C NUMBER;
    QUANT_MAX NUMBER;
    QUANT_A_MUDAR NUMBER;
    
    CONTAGEM_P NUMBER;
    CONTAGEM_A NUMBER;
    
    PRODUTO_NAO_EXISTE EXCEPTION;
    ARMAZEM_NAO_EXISTE EXCEPTION;
    QUANT_INVALIDA EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO CONTAGEM_P FROM PRODUTO WHERE ID_PRODUTO = COD_PRODUTO;
    IF(CONTAGEM_P = 0) THEN
        RAISE PRODUTO_NAO_EXISTE;
    END IF;
    
    SELECT COUNT(*) INTO CONTAGEM_A FROM ARMAZEM WHERE ID_ARMAZEM = COD_ARMAZEM;
    IF(CONTAGEM_A = 0) THEN
        RAISE ARMAZEM_NAO_EXISTE;
    END IF;
    
    IF(QUANTIDADE < 0) THEN
        RAISE QUANT_INVALIDA;
    END IF;
    
    QUANT_A_MUDAR := QUANTIDADE;

    SELECT SEQ_ROTA.NEXTVAL, SEQ_VIAGEM.NEXTVAL INTO ID_ROTA, ID_VIAGEM FROM DUAL;
    INSERT INTO ROTA VALUES(ID_ROTA, COD_ARMAZEM, 'nao predefinido', 'Maquinas com muita rotura de stock.', 15);
    INSERT INTO VIAGEM VALUES(ID_VIAGEM, 1, ID_ROTA, 1, 15, SYSDATE, NULL);
    
    FOR R IN C1 LOOP
        IF(QUANT_A_MUDAR > 0) THEN -- SE AINDA HOUVER QUANTIDADE PARA REPOR
            SELECT SEQ_VM.NEXTVAL INTO ID_VM FROM DUAL;
            INSERT INTO VISITA_MAQUINA VALUES(ID_VM, R.ID_MAQUINA, ID_VIAGEM, SYSDATE);
            
            SELECT ID_COMPARTIMENTO, STOCK, CAPAC_MAX INTO ID_C, QUANT_STOCK_C, QUANT_MAX
            FROM COMPARTIMENTO 
            WHERE ID_PRODUTO = COD_PRODUTO AND ID_MAQUINA = R.ID_MAQUINA;
            
            IF (QUANT_A_MUDAR <= QUANT_MAX-QUANT_STOCK_C) THEN -- mete apenas a quant disponivel na carrinha, mesmo que o compartimento nao fique full
                SELECT SEQ_RC.NEXTVAL INTO ID_RC FROM DUAL;
                INSERT INTO REABASTECIMENTO_COMPARTIMENTO VALUES(ID_RC, ID_VM, ID_C, COD_PRODUTO, QUANT_A_MUDAR, SYSDATE);
                
                QUANT_A_MUDAR := QUANT_A_MUDAR - QUANT_A_MUDAR;
            ELSE                                               -- mete toda a quantidade disponivel no compartimento
                SELECT SEQ_RC.NEXTVAL INTO ID_RC FROM DUAL;
                INSERT INTO REABASTECIMENTO_COMPARTIMENTO VALUES(ID_RC, ID_VM, ID_C, COD_PRODUTO, QUANT_MAX-QUANT_STOCK_C, SYSDATE);
                
                QUANT_A_MUDAR := QUANT_A_MUDAR - (QUANT_MAX-QUANT_STOCK_C);
            END IF;
        END IF;
        
        EXIT WHEN QUANT_A_MUDAR <= 0;
    END LOOP;
EXCEPTION
    WHEN PRODUTO_NAO_EXISTE THEN
        RAISE_APPLICATION_ERROR(-20802, 'Código de produto inexistente.');
    WHEN ARMAZEM_NAO_EXISTE THEN
        RAISE_APPLICATION_ERROR(-20806, 'Código de armazém inexistente.');
    WHEN QUANT_INVALIDA THEN
        RAISE_APPLICATION_ERROR(-20813, 'Quantidade inválida.');
END;
/


BEGIN
    ABASTECE_PRODUTO(1, 31, 50);
END;
/
-- Última rota criada
SELECT * FROM ROTA ORDER BY ID_ROTA DESC;

-- Viagem criada associada à rota
SELECT * FROM VIAGEM WHERE ID_ROTA = (SELECT MAX(ID_ROTA) FROM ROTA);

-- Máquinas envolvidas na viagem
SELECT * FROM VISITA_MAQUINA WHERE ID_VIAGEM = (SELECT MAX(ID_VIAGEM) FROM VIAGEM);

-- Compartimentos reabastecidos
SELECT * FROM REABASTECIMENTO_COMPARTIMENTO 
WHERE ID_VISITA_MAQUINA IN (
    SELECT ID_VISITA_MAQUINA 
    FROM VISITA_MAQUINA 
    WHERE ID_VIAGEM = (SELECT MAX(ID_VIAGEM) FROM VIAGEM)
);


DECLARE
    MAX_ID NUMBER;
BEGIN
    SELECT MAX(ID_RC) INTO MAX_ID FROM REABASTECIMENTO_COMPARTIMENTO;
    IF MAX_ID IS NOT NULL THEN
        EXECUTE IMMEDIATE 'ALTER SEQUENCE SEQ_RC INCREMENT BY ' || (MAX_ID + 1 - SEQ_RC.CURRVAL);
        SELECT SEQ_RC.NEXTVAL INTO MAX_ID FROM DUAL; -- força o nextval
        EXECUTE IMMEDIATE 'ALTER SEQUENCE SEQ_RC INCREMENT BY 1'; -- volta ao normal
    END IF;
END;
/





---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------




DROP TRIGGER UPDATE_STOCK;
CREATE OR REPLACE TRIGGER UPDATE_STOCK
BEFORE INSERT
ON VENDAS
FOR EACH ROW
DECLARE 
    QUANT_NO_COMPARTIMENTO NUMBER;
    IDMAQUINA NUMBER;
    QUANTIDADE NUMBER;
    
    SEM_STOCK_PARA_VENDER EXCEPTION;
BEGIN
    SELECT STOCK INTO QUANT_NO_COMPARTIMENTO FROM COMPARTIMENTO WHERE ID_COMPARTIMENTO = :NEW.ID_COMPARTIMENTO AND ID_PRODUTO = :NEW.ID_PRODUTO;
    IF(QUANT_NO_COMPARTIMENTO = 0) THEN
        RAISE SEM_STOCK_PARA_VENDER;
    END IF;
    
    UPDATE COMPARTIMENTO SET STOCK = STOCK - 1 WHERE ID_COMPARTIMENTO = :NEW.ID_COMPARTIMENTO AND ID_PRODUTO = :NEW.ID_PRODUTO;
    
    SELECT ID_MAQUINA INTO IDMAQUINA FROM COMPARTIMENTO WHERE ID_COMPARTIMENTO = :NEW.ID_COMPARTIMENTO AND ID_PRODUTO = :NEW.ID_PRODUTO;
    SELECT SUM(STOCK) INTO QUANTIDADE FROM COMPARTIMENTO WHERE ID_MAQUINA = IDMAQUINA;
    IF(QUANTIDADE = 0) THEN
        UPDATE MAQUINA SET ESTADO_ATUAL = 'SEM STOCK' WHERE ID_MAQUINA = IDMAQUINA;
    END IF;
EXCEPTION
    WHEN SEM_STOCK_PARA_VENDER THEN -- opcioal, caso não exista quantidade suficiente no compartimento para vender o produto
        RAISE_APPLICATION_ERROR(-20814, 'O compartimento não possui stock suficiente para vender.');
END;
/





---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE OR REPLACE TRIGGER ABASTECE
BEFORE INSERT
ON REABASTECIMENTO_COMPARTIMENTO
FOR EACH ROW
DECLARE
    STOCK_ATUAL NUMBER; MAXIMO NUMBER;
    --QUANT_INVALIDA EXCEPTION;
BEGIN
    SELECT STOCK, CAPAC_MAX INTO STOCK_ATUAL, MAXIMO FROM COMPARTIMENTO WHERE ID_COMPARTIMENTO = :NEW.ID_COMPARTIMENTO AND ID_PRODUTO = :NEW.ID_PRODUTO;
    
    IF(:NEW.QUANTIDADE_REPOSTA > MAXIMO-STOCK_ATUAL OR :NEW.QUANTIDADE_REPOSTA <= 0) THEN -- chekar se a quantidade é possivel
        :NEW.QUANTIDADE_REPOSTA := MAXIMO-STOCK_ATUAL;
        --RAISE QUANT_INVALIDA;
    END IF;
--EXCEPTION
--    WHEN QUANT_INVALIDA THEN -- impede abastecimento com quantidade inválida (negativa ou excede capacidade)
--        RAISE_APPLICATION_ERROR(-20813, 'Quantidade inválida.');
END;
/





---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------





CREATE OR REPLACE TRIGGER UPDATE_VIAGEM
BEFORE INSERT -- before para trocar a quantidade caso esteja incorreta
ON REABASTECIMENTO_COMPARTIMENTO
FOR EACH ROW
DECLARE
    IDVIAGEM NUMBER;
    QUANT_DISPONIVEL NUMBER;
BEGIN
    SELECT ID_VIAGEM INTO IDVIAGEM FROM VISITA_MAQUINA WHERE ID_VISITA_MAQUINA = :NEW.ID_VISITA_MAQUINA;
    BEGIN
        SELECT QUANTIDADE INTO QUANT_DISPONIVEL FROM PRODUTOS_TRANSPORTADOS WHERE ID_PRODUTO = :NEW.ID_PRODUTO AND ID_VIAGEM = IDVIAGEM;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            QUANT_DISPONIVEL := 0;
    END;
    IF(:NEW.QUANTIDADE_REPOSTA > QUANT_DISPONIVEL OR :NEW.QUANTIDADE_REPOSTA <= 0) THEN -- chekar se a quantidade for é possivel
        :NEW.QUANTIDADE_REPOSTA := QUANT_DISPONIVEL;
    END IF;
    
    UPDATE PRODUTOS_TRANSPORTADOS SET QUANTIDADE = QUANTIDADE - :NEW.QUANTIDADE_REPOSTA WHERE ID_PRODUTO = :NEW.ID_PRODUTO AND ID_VIAGEM = IDVIAGEM;
END;
/





---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION P_FUNC_2023146226 (LAT_REF NUMBER, LON_REF NUMBER, DATA_INICIO DATE, DATA_FIM DATE)
RETURN NUMBER
IS
    ID_MAIS_PROXIMA NUMBER;
    ID_PRODUTO_FINAL NUMBER;
BEGIN                       
    -- encontra a maquina mais próxima
    SELECT ID_MAQUINA INTO ID_MAIS_PROXIMA
    FROM (
        SELECT ID_MAQUINA, DISTANCIA_LINEAR(LAT_REF, LON_REF, LATITUDE, LONGITUDE) AS DIST
        FROM MAQUINA
        WHERE LOWER(ESTADO_ATUAL) = 'operacional'
        ORDER BY DIST ASC
    )
    WHERE ROWNUM = 1;
    
    -- encontra o produto mais reabastecido nessa maquina no intervalo de tempo
    SELECT ID_PRODUTO INTO ID_PRODUTO_FINAL
    FROM (
        SELECT RC.ID_PRODUTO, SUM(RC.QUANTIDADE_REPOSTA) AS TOTAL
        FROM REABASTECIMENTO_COMPARTIMENTO RC, COMPARTIMENTO C 
        WHERE RC.ID_COMPARTIMENTO = C.ID_COMPARTIMENTO
        AND C.ID_MAQUINA = ID_MAIS_PROXIMA
        AND RC.DATA_HORA BETWEEN DATA_INICIO AND DATA_FIM
        GROUP BY RC.ID_PRODUTO
        ORDER BY TOTAL DESC
    )
    WHERE ROWNUM = 1;
    
    RETURN ID_PRODUTO_FINAL;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/

DECLARE
    ID_PRODUTO NUMBER;
BEGIN
    ID_PRODUTO := P_FUNC_2023146226(40.1933, -8.5103, TO_DATE('2024-01-01','YYYY-MM-DD'), TO_DATE('2025-12-31','YYYY-MM-DD'));
    
    IF ID_PRODUTO IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Produto mais reabastecido na máquina mais próxima: ' || ID_PRODUTO);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nenhum produto encontrado.');
    END IF;
END;
/



---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE OR REPLACE PROCEDURE Q_PROC_2023146226 (CATEGORIAA VARCHAR2, PERCENTAGEM NUMBER)
IS
    MEDIA_PRECO NUMBER;
BEGIN
    SELECT AVG(PRECO) INTO MEDIA_PRECO
    FROM PRODUTO 
    WHERE LOWER(CATEGORIA) = LOWER(CATEGORIAA);
    
    -- Atualiza precos abaixo da media com base na percentagem, por ordem crescente de preco
    FOR PROD IN (
        SELECT ID_PRODUTO
        FROM PRODUTO
        WHERE LOWER(CATEGORIA) = LOWER(CATEGORIAA)
          AND PRECO < MEDIA_PRECO
        ORDER BY PRECO ASC
    ) LOOP
        UPDATE PRODUTO
        SET PRECO = PRECO + (PRECO * PERCENTAGEM / 100)
        WHERE ID_PRODUTO = PROD.ID_PRODUTO;
    END LOOP;
      
    COMMIT;
END;
/

BEGIN
    Q_PROC_2023146226('Snack', 20); -- aumenta 10% aos produtos da categoria 'Snacks' com preço abaixo da média
END;
/

SELECT ID_PRODUTO, CATEGORIA, PRECO
FROM PRODUTO
WHERE LOWER(CATEGORIA) = 'snack'
ORDER BY PRECO;


SELECT ID_PRODUTO, CATEGORIA, PRECO
FROM PRODUTO
WHERE LOWER(CATEGORIA) = 'snack'
ORDER BY PRECO;




---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER R_TRIG_2023146226
BEFORE INSERT ON REABASTECIMENTO_COMPARTIMENTO
FOR EACH ROW
DECLARE
    STOCK_ATUAL NUMBER;
    CAPACIDADE_MAX NUMBER;
BEGIN
    -- Vai buscar o stock atual e capacidade máxima
    SELECT STOCK, CAPAC_MAX INTO STOCK_ATUAL, CAPACIDADE_MAX
    FROM COMPARTIMENTO
    WHERE ID_COMPARTIMENTO = :NEW.ID_COMPARTIMENTO
    AND ID_PRODUTO = :NEW.ID_PRODUTO;
    
    IF (:NEW.QUANTIDADE_REPOSTA + STOCK_ATUAL > CAPACIDADE_MAX) THEN
        RAISE_APPLICATION_ERROR(-20815, 'Reabastecimento excede a capacidade máxima do compartimento.');
    END IF;
END;
/


INSERT INTO REABASTECIMENTO_COMPARTIMENTO (ID_RC, ID_VISITA_MAQUINA, ID_COMPARTIMENTO, ID_PRODUTO, QUANTIDADE_REPOSTA, DATA_HORA)
VALUES (215, 1, 1, 33, 6, SYSDATE); -- assume que 5 + stock atual ? capacidade


INSERT INTO REABASTECIMENTO_COMPARTIMENTO (ID_RC, ID_VISITA_MAQUINA, ID_COMPARTIMENTO, ID_PRODUTO, QUANTIDADE_REPOSTA, DATA_HORA)
VALUES (216, 1, 1, 33, 9999, SYSDATE); -- assume que 9999 + stock atual > capacidade

