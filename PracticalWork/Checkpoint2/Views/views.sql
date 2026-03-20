-- VIEW_B
CREATE OR REPLACE VIEW VIEW_B AS
SELECT M.id_maquina AS "IDMAQUINA", M.LOCAL AS "LOCAL", P.ID_PRODUTO AS "REF_PRODUTO", P.nome AS "PRODUTO", C.stock AS "QUANT_EXISTENTE", RC.quantidade_reposta AS "QUANT_ABASTECIDA"
FROM REABASTECIMENTO_COMPARTIMENTO RC, MAQUINA M, COMPARTIMENTO C, PRODUTO P
WHERE RC.id_visita_maquina IN (
    SELECT vm_id
    FROM ( 
        -- Extrai-se as maquinas visitadas com o order by da data da visita e para assim por tanto saber quais compartimentos foram abastecidos nestas visitas
        SELECT DISTINCT VM.id_visita_maquina AS vm_id, VM.data_hora AS data
        FROM VIAGEM V, CONTEM C, VISITA_MAQUINA VM
        WHERE V.id_viagem = 2025031105                  -- onde o id da viagem for 2025031105 (e.g. real na nossa bd: 36)
          AND V.id_viagem = VM.id_viagem                -- associa VISITA_MAQUINA a VIAGEM
          AND VM.id_maquina = C.id_maquina              -- associa CONTEM a VISITA_MAQUINA
        ORDER BY data asc                               -- ordena a data da visita ascendentemente
    )
)
AND M.id_maquina = C.id_maquina                         -- associa MAQUINA a COMPARTIMENTO
AND C.id_compartimento = RC.id_compartimento            -- associa COMPARTIMENTO a REABASTECIMENTO_COMPARTIMENTO
AND P.id_produto = C.id_produto                         -- associa PRODUTO A COMPRTIMENTO
ORDER BY QUANT_ABASTECIDA DESC;                         -- ordena descendentemente pela quantidade abastecida

SELECT * FROM VIEW_B;

COMMIT;

-- testes -------------------------------------------------------------------------------------------------------------------
SELECT * FROM VIAGEM WHERE ID_VIAGEM=36; --ROTA 12 -- VIAGEM 36
SELECT id_visita_maquina FROM VISITA_MAQUINA WHERE ID_VIAGEM IN 36; -- ID_VISITA_MAQUINA 176 177 178 179 180 --ID MAQUINA 1 2 3 4 5
SELECT * FROM CONTEM WHERE ID_ROTA = (SELECT ID_ROTA FROM VIAGEM WHERE ID_VIAGEM=36);
select * from contem;
SELECT * FROM REABASTECIMENTO_COMPARTIMENTO WHERE ID_VISITA_MAQUINA IN (SELECT id_visita_maquina FROM VISITA_MAQUINA WHERE ID_VIAGEM IN 36); -- ID_VISITA_MAQUINA 176 177 178 179 180 --ID MAQUINA 1 2 3 4 5
-- testes -------------------------------------------------------------------------------------------------------------------






-- VIEW_D
CREATE OR REPLACE VIEW VIEW_D AS
SELECT      
    M.id_maquina AS MAQUINAID, 
    M.local AS LOCAL,
    ROUND(DISTANCIA_LINEAR(A.latitude, A.longitude, M.latitude, M.longitude), 1) AS DISTANCIA_LINEAR,   -- Calcula a distancia linear entre o armazem e a maquina em questao
    (SELECT MAX(RC.DATA_HORA)                                                                           -- Extrai a data do ultimo abastecimento de qualquer compartimento da maquina em questao 
    FROM REABASTECIMENTO_COMPARTIMENTO RC, COMPARTIMENTO CC
    WHERE RC.id_compartimento = CC.id_compartimento AND
    CC.id_maquina = M.id_maquina) AS DATA_ULT_ABAST, 
    (SELECT SUM(stock)                                                                                  -- Extrai a quantidade de produtos que estão na máquina em questao
    FROM compartimento CC
    WHERE CC.id_maquina = M.id_maquina) AS QUANT_TOTAL_PRODUTOS
FROM MAQUINA M, COMPARTIMENTO C, PRODUTO P, ARMAZEM A
WHERE M.id_maquina = C.id_maquina AND                                                                   -- maquinas que possuem um compartimento com o produto: KITKAT
      C.id_produto = P.id_produto AND                                                                   -- compartimentos com o produto: KITKAT
      UPPER(P.nome) = 'KITKAT'                                                                          -- apenas o produto: KITKAT
      AND UPPER(A.localizacao) = 'TAVEIRO'
GROUP BY M.id_maquina, M.local, DISTANCIA_LINEAR(A.latitude, A.longitude, M.latitude, M.longitude)      -- agrupar por maquina, local e distancia em km
ORDER BY 3;
   
SELECT * FROM VIEW_D;
      
COMMIT;
-- testes -------------------------------------------------------------------------------------------------------------------
SELECT DATA_HORA, id_compartimento FROM REABASTECIMENTO_COMPARTIMENTO ORDER BY 1 ASC;


SELECT * FROM MAQUINA;
SELECT * FROM PRODUTO;
SELECT * FROM COMPARTIMENTO;

DELETE FROM COMPARTIMENTO;
-- testes -------------------------------------------------------------------------------------------------------------------



    
    
    












-- VIEW_E
-- CALCULA-SE PARA O TIPO DE PRODUTO/CATEGORIA E MOSTRA-SE OS PRODUTOS
CREATE OR REPLACE VIEW VIEW_E AS
SELECT 
  M.id_maquina AS maquina,                               -- ID da máquina onde o produto está
  P.nome AS produto,                                     -- Nome do produto
  ROUND(S.MEDIAMENSAL, 2) AS MEDIAMENSAL                 -- Média mensal das vendas da categoria do produto
FROM PRODUTO P, MAQUINA M, COMPARTIMENTO C, (
    -- Calcula para cada tipo de produto, a média da quantidade vendida em cada mês
    SELECT maquina, categoria, ROUND(AVG(soma),2) AS MEDIAMENSAL
    FROM (
        -- Sub-subquery: soma as vendas por mês, por categoria e por máquina
        SELECT COUNT(*) as soma, P.categoria AS categoria, TO_CHAR(V.DATA_HORA, 'YYYY-MM') as ano_mes, M.id_maquina as maquina
        FROM VENDAS V, PRODUTO P, MAQUINA M, COMPARTIMENTO C
        WHERE TO_CHAR(V.data_hora, 'YYYY') IN ('2023', '2024') AND            -- Apenas anos 2023 e 2024
              P.id_produto = V.id_produto AND                                 -- Liga venda ao produto
              V.id_compartimento = C.id_compartimento AND                     -- Liga venda ao compartimento
              M.id_maquina = C.id_maquina AND                                 -- Liga compartimento à máquina
              UPPER(M.estado_atual) = 'OPERACIONAL' AND                       -- Apenas máquinas operacionais
              M.id_maquina IN (                                               -- Filtra máquinas com reabastecimentos acima da média
                  SELECT ID_MAQUINA
                  FROM (
                      SELECT C.id_maquina, COUNT(*) AS num_reabast            -- calcula-se a quantidade de reabasteciemtnos que cada maquina teve
                      FROM REABASTECIMENTO_COMPARTIMENTO RC, COMPARTIMENTO C
                      WHERE RC.id_compartimento = C.id_compartimento
                      GROUP BY C.id_maquina
                  )
                  WHERE num_reabast > (                                       -- confirma-se se a quantidade calculada em cima é maior que a media da quantidade de reabastecimento
                      SELECT AVG(num_reabast) 
                      FROM (
                          SELECT COUNT(*) AS num_reabast
                          FROM REABASTECIMENTO_COMPARTIMENTO RC, COMPARTIMENTO C
                          WHERE RC.id_compartimento = C.id_compartimento
                          GROUP BY C.id_maquina
                      )
                  )
              )
        GROUP BY TO_CHAR(V.DATA_HORA, 'YYYY-MM'), P.categoria, M.id_maquina   -- Agrupa por mês, categoria e máquina
    )
    GROUP BY maquina, categoria                                               -- Agrupa para calcular a média mensal final
) S
WHERE P.categoria = S.categoria                                               -- Liga produto à categoria com média calculada
  AND C.id_produto = P.id_produto                                             -- Liga compartimento ao produto
  AND C.id_maquina = S.maquina                                                -- Liga compartimento à máquina correta
  AND M.id_maquina = C.id_maquina                                             -- Liga máquina à mesma usada na subquery
GROUP BY M.id_maquina, P.nome, S.MEDIAMENSAL                                  -- Agrupa para evitar duplicados
ORDER BY 3 DESC, 2;                                                           -- Ordena pela média e depois pelo nome do produto

SELECT * FROM VIEW_E;

COMMIT;

-- testes -------------------------------------------------------------------------------------------------------------------
-- CALCULA-SE E MOSTRA-SE PARA OS TIPOS DE PRODUTOS/CATEGORIA
SELECT categoria, ROUND(AVG(soma),2) AS MEDIAMENSAL -- MEDIA DA QUANTIDADE VENDIDA EM CADA MES PARA CADA TIPO DE PRODUTO
FROM(
    SELECT COUNT(*) as soma, P.categoria AS categoria, TO_CHAR(DATA_HORA, 'YYYY-MM') as ano_mes -- soma das vendas de cada CATEGORIA em cada mes entre 2023 e 2024
    FROM VENDAS V, PRODUTO P, COMPARTIMENTO C, MAQUINA M
    WHERE TO_CHAR(V.data_hora, 'YYYY') IN ('2023', '2024') AND
    P.id_produto = V.id_produto AND
    V.ID_COMPARTIMENTO = C.ID_COMPARTIMENTO AND
    M.id_maquina = C.id_maquina
    GROUP BY TO_CHAR(DATA_HORA, 'YYYY-MM'), categoria
    ORDER BY TO_CHAR(DATA_HORA, 'YYYY-MM') asc
)
GROUP BY categoria;

SELECT maquina, categoria, ROUND(AVG(soma),2) AS MEDIAMENSAL -- MEDIA DA QUANTIDADE VENDIDA EM CADA MES PARA CADA TIPO DE PRODUTO/CATEGORIA
FROM(
    SELECT COUNT(*) as soma, P.categoria AS categoria, TO_CHAR(V.DATA_HORA, 'YYYY-MM') as ano_mes, M.id_maquina as maquina -- soma das vendas de cada TIPO DE PRODUTO/CATEGORIA em cada mes entre 2023 e 2024
    FROM VENDAS V, PRODUTO P, MAQUINA M, COMPARTIMENTO C
    WHERE TO_CHAR(V.data_hora, 'YYYY') IN ('2023', '2024') AND
    P.id_produto = V.id_produto AND
    V.id_compartimento = C.id_compartimento AND
    M.id_maquina = C.id_maquina AND
    UPPER(M.estado_atual) = 'OPERACIONAL' AND
    M.id_maquina IN (
      SELECT ID_MAQUINA
      FROM (
          SELECT C.id_maquina, COUNT(*) AS num_reabast
          FROM REABASTECIMENTO_COMPARTIMENTO RC, COMPARTIMENTO C
          WHERE RC.id_compartimento = C.id_compartimento
          GROUP BY C.id_maquina
      )
      WHERE num_reabast > (
          SELECT AVG(num_reabast) 
          FROM (
              SELECT COUNT(*) AS num_reabast
              FROM REABASTECIMENTO_COMPARTIMENTO RC, COMPARTIMENTO C
              WHERE RC.id_compartimento = C.id_compartimento
              GROUP BY C.id_maquina
          )
      )
    )
    GROUP BY TO_CHAR(V.DATA_HORA, 'YYYY-MM'), P.categoria, M.id_maquina
    ORDER BY TO_CHAR(V.DATA_HORA, 'YYYY-MM') asc
)
GROUP BY maquina, categoria
ORDER BY 3 desc, 2;

----------------/--------------------------------/----------------
-- CALCULA-SE E MOSTRA-SE PARA OS PRODUTOS --

SELECT nome, ROUND(AVG(soma),2) AS MEDIAMENSAL -- MEDIA DA QUANTIDADE VENDIDA EM CADA MES PARA CADA PRODUTO
FROM(
    SELECT COUNT(*) as soma, P.nome AS nome, TO_CHAR(V.DATA_HORA, 'YYYY-MM') as ano_mes -- soma das vendas de cada PRODUTO em cada mes entre 2023 e 2024
    FROM VENDAS V, PRODUTO P
    WHERE TO_CHAR(V.data_hora, 'YYYY') IN ('2023', '2024') AND
    P.id_produto = V.id_produto
    GROUP BY TO_CHAR(V.DATA_HORA, 'YYYY-MM'), nome
    ORDER BY TO_CHAR(V.DATA_HORA, 'YYYY-MM') asc
)
GROUP BY nome;

SELECT maquina, produto, ROUND(AVG(soma),2) AS MEDIAMENSAL -- MEDIA DA QUANTIDADE VENDIDA EM CADA MES PARA CADA PRODUTO
FROM(
    SELECT COUNT(*) as soma, P.nome AS produto, TO_CHAR(V.DATA_HORA, 'YYYY-MM') as ano_mes, M.id_maquina as maquina -- soma das vendas de cada PRODUTO em cada mes entre 2023 e 2024
    FROM VENDAS V, PRODUTO P, MAQUINA M, COMPARTIMENTO C
    WHERE TO_CHAR(V.data_hora, 'YYYY') IN ('2023', '2024') AND
    P.id_produto = V.id_produto AND
    V.id_compartimento = C.id_compartimento AND
    M.id_maquina = C.id_maquina AND
    UPPER(M.estado_atual) = 'OPERACIONAL' AND
    M.id_maquina IN (
      SELECT ID_MAQUINA
      FROM (
          SELECT C.id_maquina, COUNT(*) AS num_reabast
          FROM REABASTECIMENTO_COMPARTIMENTO RC, COMPARTIMENTO C
          WHERE RC.id_compartimento = C.id_compartimento
          GROUP BY C.id_maquina
      )
      WHERE num_reabast > (
          SELECT AVG(num_reabast) 
          FROM (
              SELECT COUNT(*) AS num_reabast
              FROM REABASTECIMENTO_COMPARTIMENTO RC, COMPARTIMENTO C
              WHERE RC.id_compartimento = C.id_compartimento
              GROUP BY C.id_maquina
          )
      )
    )
    GROUP BY TO_CHAR(V.DATA_HORA, 'YYYY-MM'), P.nome, M.id_maquina
    ORDER BY TO_CHAR(V.DATA_HORA, 'YYYY-MM') asc
)
GROUP BY maquina, produto
ORDER BY 3 desc, 2;
-- testes -------------------------------------------------------------------------------------------------------------------




CREATE OR REPLACE VIEW VIEW_J_2023146226 AS
SELECT V.ID_MAQUINA, M.LOCAL, V.RECEITA_TOTAL, sub.CATEGORIA_MAIS_VENDIDA
FROM 
    MAQUINA M,
   (SELECT ID_MAQUINA, RECEITA_TOTAL -- Select que obtem as duas maquinas que tiveram mais venda
    FROM (
        SELECT C.ID_MAQUINA, SUM(V.VALOR_VENDA) AS RECEITA_TOTAL -- Subquery que calcula a receita total nos últimos 3 meses por máquina
        FROM VENDAS V, COMPARTIMENTO C
        WHERE V.ID_COMPARTIMENTO = C.ID_COMPARTIMENTO AND V.DATA_HORA >= ADD_MONTHS(SYSDATE, -3)
        GROUP BY C.ID_MAQUINA -- Group by 1 -- agrupa por maquina
        ORDER BY SUM(V.VALOR_VENDA) DESC -- Ordena a receita total descendentemente para saber as duas receitas mais altas
    )
    WHERE ROWNUM <= 2) V,
   (SELECT ID_MAQUINA, CATEGORIA_MAIS_VENDIDA 
    FROM (SELECT C.ID_MAQUINA, P.CATEGORIA AS CATEGORIA_MAIS_VENDIDA, COUNT(*) AS QTD_VENDAS -- Subquery que descobre a quantidade de vendas por cada categoria de cada maquina
          FROM VENDAS V, PRODUTO P, COMPARTIMENTO C
          WHERE V.ID_COMPARTIMENTO = C.ID_COMPARTIMENTO AND V.ID_PRODUTO = P.ID_PRODUTO AND V.DATA_HORA >= ADD_MONTHS(SYSDATE, -3)
          GROUP BY C.ID_MAQUINA, P.CATEGORIA -- Group by 2 -- agrupa por maquina, mas principalmente por categoria
    ) subsub
    WHERE (ID_MAQUINA, QTD_VENDAS) IN ( -- Subquery que descobre encontra a categoria da maquina em questao que for igual à quantidade de vendas por cada categoria de cada maquina procurada na subquery de cima
        SELECT ID_MAQUINA, MAX(QTD_VENDAS)
        FROM (SELECT C.ID_MAQUINA, P.CATEGORIA, COUNT(*) AS QTD_VENDAS
              FROM VENDAS V, PRODUTO P, COMPARTIMENTO C
              WHERE V.ID_COMPARTIMENTO = C.ID_COMPARTIMENTO AND V.ID_PRODUTO = P.ID_PRODUTO AND V.DATA_HORA >= ADD_MONTHS(SYSDATE, -3)
              GROUP BY C.ID_MAQUINA, P.CATEGORIA -- Group by 3 -- agrupa por maquina, mas principalmente por categoria
        )
        GROUP BY ID_MAQUINA -- Group by 4 -- agrupa por maquina
    )) sub
WHERE M.ID_MAQUINA = V.ID_MAQUINA AND sub.ID_MAQUINA = V.ID_MAQUINA; -- liga maquina às maquinas com as receitas maximas e as receitas maximas às categorias mais vendidas
  
SELECT * FROM VIEW_J_2023146226;

COMMIT;






CREATE OR REPLACE VIEW VIEW_K_2023146226 AS
SELECT 
  A.ID_ARMAZEM, A.LOCALIZACAO, P.NOME AS PRODUTO, STOCK_ATUAL.QUANTIDADE_ATUAL, VENDAS_REC.QTD_VENDIDA_30DIAS, ROUND(REAB_REC.MEDIA_REAB, 2) AS MEDIA_REABASTECIMENTO,
  -- Indicador de estado com base na comparação entre stock e vendas
  CASE 
    WHEN STOCK_ATUAL.QUANTIDADE_ATUAL < VENDAS_REC.QTD_VENDIDA_30DIAS * 1.2 THEN 'Reabastecimento Urgente'
    WHEN STOCK_ATUAL.QUANTIDADE_ATUAL < VENDAS_REC.QTD_VENDIDA_30DIAS * 1.5 THEN 'Reabastecimento Recomendado'
    ELSE 'Stock Suficiente'
  END AS ESTADO_REABASTECIMENTO
FROM ARMAZEM A, PRODUTO P,
  -- select encadeado 1: stock atual no armazém
  (SELECT ID_ARMAZEM, ID_PRODUTO, QUANTIDADE_ATUAL
   FROM ARMAZENADO) STOCK_ATUAL,
   
  -- select encadeado 2: total vendido nos últimos 30 dias por produto
  (SELECT V.ID_PRODUTO, COUNT(*) AS QTD_VENDIDA_30DIAS
   FROM VENDAS V
   WHERE V.DATA_HORA >= SYSDATE - 30
   GROUP BY V.ID_PRODUTO) VENDAS_REC,
   
  -- select encadeado 3: média de reabastecimento por produto
  (SELECT ID_PRODUTO, ROUND(AVG(QUANTIDADE_REPOSTA), 2) AS MEDIA_REAB
   FROM REABASTECIMENTO_ARMAZEM
   GROUP BY ID_PRODUTO) REAB_REC
WHERE 
  STOCK_ATUAL.ID_ARMAZEM = A.ID_ARMAZEM AND           -- associa o armazem do stock atual ao armazem em questao
  STOCK_ATUAL.ID_PRODUTO = P.ID_PRODUTO AND           -- associa o produto do stock atual ao produto em questao 
  STOCK_ATUAL.ID_PRODUTO = VENDAS_REC.ID_PRODUTO AND  -- associa o produto do stock atual ao produto do total vendido nos ultimos 030 dias
  STOCK_ATUAL.ID_PRODUTO = REAB_REC.ID_PRODUTO;       -- associa o produto do stock atual ao produto da media de reabastecimento

SELECT * FROM VIEW_K_2023146226;

COMMIT;
