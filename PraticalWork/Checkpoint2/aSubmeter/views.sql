--------------------------------------------------------------------------------------------------------------------------------

-- VIEW_A - Diogo
CREATE OR REPLACE VIEW VIEW_A AS 
SELECT
    m.id_maquina AS IDMAQUINA,
    rc.data_hora AS data_hora_abast,
    m.local,
    SUM(rc.quantidade_reposta) AS quant_abastecida,    -- Quantidade total reabastecida 
    COUNT(DISTINCT rc.id_produto) AS num_produtos_diferentes
FROM 
    reabastecimento_compartimento rc,
    produto p,
    visita_maquina vm,
    maquina m,
    compartimento c
WHERE 
    p.id_produto = rc.id_produto
    AND vm.id_visita_maquina = rc.id_visita_maquina
    AND m.id_maquina = vm.id_maquina
    AND c.id_maquina = m.id_maquina 
    AND c.id_produto = p.id_produto
    AND UPPER(p.categoria) = 'SNACK'
    AND UPPER(m.cidade) = 'COIMBRA'
    AND UPPER(m.estado_atual) = 'OPERACIONAL' --EXCLUIR INATIVAS
    AND c.stock =0 --sem stock
    AND rc.data_hora BETWEEN TRUNC(SYSDATE - 1) AND TRUNC(SYSDATE) -- REABASTECIDAS ONTEM
GROUP BY
    m.id_maquina,
    rc.data_hora,
    m.local
ORDER BY
    quant_abastecida DESC;

--------------------------------------------------------------------------------------------------------------------------------

-- VIEW_B - Saraiva
CREATE OR REPLACE VIEW VIEW_B AS
SELECT M.id_maquina AS "IDMAQUINA", M.LOCAL AS "LOCAL", P.ID_PRODUTO AS "REF_PRODUTO", P.nome AS "PRODUTO", C.stock AS "QUANT_EXISTENTE", RC.quantidade_reposta AS "    "
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

--------------------------------------------------------------------------------------------------------------------------------

-- VIEW_C - Lucas
CREATE OR REPLACE VIEW VIEW_C AS
SELECT 
    m.id_maquina,                           -- ID da máquina
    m.local,                                -- Localização da máquina
    p.id_produto AS ref_produto,            -- Referência do produto
    p.nome AS produto,                      -- Nome do produto
    COUNT(v.id_venda) AS quant_vendida_mes, -- Quantidade total vendida no último mês
    -- Subconsulta: calcula quantidade vendida desde o último reabastecimento
    (
        SELECT COUNT(v2.id_venda)  -- Conta vendas desde o último reabastecimento
        FROM vendas v2
        JOIN compartimento c2 ON v2.id_compartimento = c2.id_compartimento
        WHERE c2.id_maquina = m.id_maquina              -- Para a mesma máquina (externa)
          AND v2.id_produto = p.id_produto              -- Para o mesmo produto (externo)
          AND v2.data_hora >= (                         -- Data venda posterior ao último reabastecimento
              SELECT MAX(r.data_hora)                   -- Última data/hora reabastecimento deste compartimento
              FROM reabastecimento_compartimento r 
              WHERE r.id_compartimento = c2.id_compartimento
          )
    ) AS quant_vend_desde_ultimo  -- Quantidade vendida desde último reabastecimento
FROM maquina m
JOIN compartimento c ON m.id_maquina = c.id_maquina -- Liga máquinas aos compartimentos
JOIN vendas v ON c.id_compartimento = v.id_compartimento -- Liga compartimentos às vendas
JOIN produto p ON v.id_produto = p.id_produto -- Liga vendas aos produtos vendidos
-- Filtragem dos dados:
WHERE v.data_hora >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -1)  -- Vendas do mês passado
  AND v.data_hora < TRUNC(SYSDATE, 'MM')                   -- Até início deste mês
  AND c.stock <= c.capac_max * 0.5                         -- Apenas compartimentos com menos ou igual a 50% do stock máximo
-- Agrupamento dos dados:
GROUP BY m.id_maquina, m.local, p.id_produto, p.nome -- Agrupa resultados por máquina e produto
-- Ordenação final:
ORDER BY quant_vendida_mes ASC;  -- Ordena pela quantidade vendida, crescente

--------------------------------------------------------------------------------------------------------------------------------

-- VIEW_D - Saraiva
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

-- Auxilio da funcao fornecida nas aulas:
create or replace FUNCTION DISTANCIA_LINEAR(LAT1  NUMBER,LON1  NUMBER,LAT2  NUMBER,LON2  NUMBER) 
RETURN NUMBER
IS
    R NUMBER := 6371; -- Raio da Terra em Kms
    PI CONSTANT NUMBER := 3.141592653589793;
    D_LAT NUMBER ;
    D_LON NUMBER ;
    A NUMBER ;
    D NUMBER ;
BEGIN
    D_LAT := (LAT2 - LAT1) * PI / 180;
    D_LON := (LON2 - LON1) * PI / 180;
    A := SIN(D_LAT/2) * SIN(D_LAT/2) + COS(LAT1*PI/180) * COS(LAT2*PI/180) * SIN(D_LON/2) * SIN(D_LON/2);
    D := R * (2 * ATAN2(SQRT(A), SQRT(1 - A)));
    RETURN ROUND(D,3);
END;

--------------------------------------------------------------------------------------------------------------------------------

-- VIEW_E - Saraiva
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

--------------------------------------------------------------------------------------------------------------------------------

-- VIEW_F - Lucas 
CREATE OR REPLACE VIEW VIEW_F AS
WITH maquina_top AS (
    -- Encontra a máquina que vendeu mais produtos do tipo 'AGUA' nas últimas 72 horas
    SELECT id_maquina FROM (
        SELECT c.id_maquina, COUNT(*) AS total_vendas -- Contagem das vendas por máquina
        FROM vendas v
        JOIN compartimento c ON v.id_compartimento = c.id_compartimento -- Relaciona vendas com compartimento
        JOIN produto p ON c.id_produto = p.id_produto -- Relaciona compartimento com produto
        WHERE p.categoria = 'AGUA' -- Filtro para categoria 'AGUA'
          AND v.data_hora >= SYSDATE - 3 -- Últimas 72 horas (3 dias)
        GROUP BY c.id_maquina -- Agrupa resultados por máquina
        ORDER BY total_vendas DESC -- Ordena por total de vendas em ordem decrescente
    ) WHERE ROWNUM = 1 -- Retorna apenas a primeira máquina (a que mais vendeu)
),
total_vendas_fev AS (
    -- Calcula o total de produtos vendidos pela máquina escolhida, em fevereiro
    SELECT COUNT(*) AS total -- Total de todas as vendas dessa máquina
    FROM vendas v
    JOIN compartimento c ON v.id_compartimento = c.id_compartimento -- Relaciona vendas com compartimento
    WHERE c.id_maquina = (SELECT id_maquina FROM maquina_top) -- Filtra pela máquina selecionada
      AND EXTRACT(MONTH FROM v.data_hora) = 2 -- Apenas vendas no mês de fevereiro
),
vendas_produto_agua AS (
    -- Calcula quantidade vendida por produto do tipo 'AGUA' pela máquina em fevereiro
    SELECT 
        c.id_maquina, -- ID da máquina
        p.id_produto, -- ID do produto
        COUNT(*) AS quant_vendida -- Quantidade vendida do produto
    FROM vendas v
    JOIN compartimento c ON v.id_compartimento = c.id_compartimento -- Liga vendas aos compartimentos
    JOIN produto p ON c.id_produto = p.id_produto -- Liga compartimento ao produto
    WHERE p.categoria = 'AGUA' -- Apenas produtos da categoria 'AGUA'
      AND c.id_maquina = (SELECT id_maquina FROM maquina_top) -- Máquina selecionada
      AND EXTRACT(MONTH FROM v.data_hora) = 2 -- Apenas vendas no mês de fevereiro
    GROUP BY c.id_maquina, p.id_produto -- Agrupa resultados por máquina e produto
),
reabastecimento_fev AS (
    -- Calcula a quantidade total reabastecida dos produtos tipo 'AGUA' na máquina em fevereiro
    SELECT 
        c.id_maquina, -- ID da máquina
        rc.id_produto, -- ID do produto
        SUM(rc.quantidade_reposta) AS quant_reabastecida -- Soma das quantidades reabastecidas
    FROM reabastecimento_compartimento rc
    JOIN compartimento c ON rc.id_compartimento = c.id_compartimento -- Liga reabastecimentos aos compartimentos
    JOIN produto p ON rc.id_produto = p.id_produto -- Liga ao produto reabastecido
    WHERE p.categoria = 'AGUA' -- Apenas produtos tipo 'AGUA'
      AND c.id_maquina = (SELECT id_maquina FROM maquina_top) -- Máquina selecionada
      AND EXTRACT(MONTH FROM rc.data_hora) = 2 -- Apenas reabastecimentos no mês de fevereiro
    GROUP BY c.id_maquina, rc.id_produto -- Agrupa por máquina e produto
)

-- Seleção final dos resultados para a VIEW_F
SELECT 
    vp.id_maquina AS IDMAQUINA, -- ID da máquina selecionada
    vp.id_produto AS REFPRODUTO, -- ID de cada produto vendido
    vp.quant_vendida AS QUANT_VENDIDA, -- Quantidade vendida do produto em fevereiro
    ROUND((vp.quant_vendida / tv.total) * 100, 2) AS PERCENTAGEM, -- Percentagem das vendas do produto em relação ao total vendido pela máquina
    NVL(rf.quant_reabastecida, 0) AS QUANT_REABASTECIDA -- Quantidade reabastecida do produto (0 caso não tenha sido reabastecido)
FROM vendas_produto_agua vp -- Resultados das vendas dos produtos tipo 'AGUA'
CROSS JOIN total_vendas_fev tv -- Total vendido pela máquina para calcular a percentagem
LEFT JOIN reabastecimento_fev rf ON vp.id_produto = rf.id_produto -- Junta dados de reabastecimento por produto (LEFT JOIN para considerar produtos não reabastecidos)
ORDER BY vp.id_produto; -- Ordena resultado final por produto

--------------------------------------------------------------------------------------------------------------------------------

-- VIEW_G - Lucas 

CREATE OR REPLACE VIEW VIEW_G AS
WITH viagens_validas AS (
    -- Viagens no ano passado que abasteceram mais de 3 máquinas
    SELECT v.id_viagem
    FROM viagem v
    JOIN visita_maquina vm ON v.id_viagem = vm.id_viagem
    WHERE EXTRACT(YEAR FROM v.data_chegada) = EXTRACT(YEAR FROM SYSDATE) - 1
    GROUP BY v.id_viagem
    HAVING COUNT(DISTINCT vm.id_maquina) > 3
),
produtos_mais_frequentes AS (
    -- Identifica os 2 tipos de produtos mais frequentemente abastecidos em Coimbra
    SELECT categoria FROM (
        SELECT p.categoria, COUNT(rc.id_visita_maquina) AS frequencia
        FROM reabastecimento_compartimento rc
        JOIN compartimento c ON rc.id_compartimento = c.id_compartimento
        JOIN maquina m ON c.id_maquina = m.id_maquina
        JOIN produto p ON rc.id_produto = p.id_produto
        JOIN visita_maquina vm ON rc.id_visita_maquina = vm.id_visita_maquina
        WHERE m.cidade LIKE '%Coimbra%'
          AND vm.id_viagem IN (SELECT id_viagem FROM viagens_validas)
          AND EXTRACT(YEAR FROM rc.data_hora) = EXTRACT(YEAR FROM SYSDATE) - 1
        GROUP BY p.categoria
        ORDER BY frequencia DESC
    )
    WHERE ROWNUM <= 2
)

SELECT
    v.id_viagem AS VIAGEM,                               -- ID da viagem
    p.categoria AS TIPO_PRODUTO,                         -- Categoria do produto
    SUM(rc.quantidade_reposta) AS QUANT_ABASTECIDA,      -- Quantidade total abastecida
    COUNT(DISTINCT m.id_maquina) AS NUM_MAQ_ABASTECIDAS  -- Número de máquinas abastecidas
FROM viagem v
JOIN visita_maquina vm ON v.id_viagem = vm.id_viagem
JOIN reabastecimento_compartimento rc ON vm.id_visita_maquina = rc.id_visita_maquina
JOIN compartimento c ON rc.id_compartimento = c.id_compartimento
JOIN maquina m ON c.id_maquina = m.id_maquina
JOIN produto p ON rc.id_produto = p.id_produto
WHERE v.id_viagem IN (SELECT id_viagem FROM viagens_validas)
  AND m.cidade LIKE '%Coimbra%'
  AND p.categoria IN (SELECT categoria FROM produtos_mais_frequentes)
GROUP BY v.id_viagem, p.categoria
ORDER BY SUM(p.volume * rc.quantidade_reposta) DESC;

--------------------------------------------------------------------------------------------------------------------------------

-- VIEW_H - Diogo 

CREATE OR REPLACE VIEW view_h AS
SELECT *
FROM (
    SELECT 
        ve.matricula AS MATRICULA,  
        ve.marca AS MARCA,          
        ve.modelo AS MODELO,        
        -- Conta o número de máquinas distintas reabastecidas nas viagens válidas
        COUNT(DISTINCT vm.id_maquina) AS N_MAQUINAS_REABASTE
    FROM 
        veiculo ve,
        viagem v,
        visita_maquina vm,
        reabastecimento_compartimento rc,
        compartimento c,
        produto p

    WHERE 
        v.id_veiculo = ve.id_veiculo
        AND v.id_viagem = vm.id_viagem
        AND vm.id_visita_maquina = rc.id_visita_maquina
        AND rc.id_compartimento = c.id_compartimento
        AND rc.id_produto = p.id_produto

        -- Considera apenas os reabastecimentos com o produto “agua Luso 33cl”
        AND p.nome = 'agua Luso 33cl'

        -- Apenas viagens com mais de 50 km de distância
        AND v.distancia_percorrida > 50

        -- Apenas viagens realizadas no mês passado
        AND EXTRACT(MONTH FROM v.data_partida) = EXTRACT(MONTH FROM ADD_MONTHS(SYSDATE, -1))

        -- Considera apenas viagens em que foram reabastecidas 3 ou mais máquinas com água
        AND v.id_viagem IN (
            SELECT vm.id_viagem
            FROM visita_maquina vm,
                 reabastecimento_compartimento rc,
                 compartimento c,
                 produto p
            WHERE 
                vm.id_visita_maquina = rc.id_visita_maquina
                AND rc.id_compartimento = c.id_compartimento
                AND rc.id_produto = p.id_produto
                AND p.nome = 'agua Luso 33cl'
            GROUP BY vm.id_viagem
            HAVING COUNT(DISTINCT vm.id_maquina) >= 3  -- 3 ou mais máquinas na mesma viagem
        )

    GROUP BY 
        ve.matricula, ve.marca, ve.modelo --agrupa por veiculo

    ORDER BY 
        N_MAQUINAS_REABASTE DESC  -- Veículos mais utilizados ordenados
)
WHERE ROWNUM <= 5;  -- Apenas os 5 veículos mais utilizados

--------------------------------------------------------------------------------------------------------------------------------

-- VIEW_I - Diogo 
CREATE OR REPLACE VIEW view_i AS
SELECT *
FROM (
    SELECT 
        a.localizacao AS armazem,  
        m.id_maquina AS maquina,  
        COUNT(DISTINCT vm.id_visita_maquina) AS n_visitas, -- Número de visitas distintas feitas à máquina
        SUM(rc.quantidade_reposta) AS quant_total, -- Quantidade total abastecida à máquina
        ROUND(SUM(rc.quantidade_reposta) / COUNT(DISTINCT vm.id_visita_maquina),2) AS quant_media_visita, -- Quantidade média abastecida por visita
        -- média de produtos distintos abastecidos 
        (
            SELECT ROUND(AVG(
                (
                    -- Conta produtos diferentes por visita individual
                    SELECT COUNT(DISTINCT rc.id_produto)
                    FROM reabastecimento_compartimento rc
                    WHERE rc.id_visita_maquina = vmi.id_visita_maquina
                )
            ),2)
            FROM visita_maquina vmi
            WHERE vmi.id_maquina = m.id_maquina
        ) AS n_prod_dif

  
    FROM 
        maquina m,
        visita_maquina vm,
        viagem v,
        rota r,
        armazem a,
        reabastecimento_compartimento rc

    WHERE 
        m.id_maquina = vm.id_maquina
        AND vm.id_viagem = v.id_viagem
        AND vm.id_visita_maquina = rc.id_visita_maquina
        AND v.id_rota = r.id_rota
        AND r.id_armazem = a.id_armazem
        -- Considera apenas as viagens que partiram do armazém com mais viagens no ano atual
        AND r.id_armazem = (
            SELECT id_armazem
            FROM (
                SELECT r.id_armazem
                FROM viagem v, rota r
                WHERE v.id_rota = r.id_rota
                  AND EXTRACT(YEAR FROM v.data_partida) = EXTRACT(YEAR FROM SYSDATE)
                GROUP BY r.id_armazem
                ORDER BY COUNT(*) DESC
            )
            WHERE ROWNUM = 1
        )
    -- Agrupamento por máquina e armazém
    GROUP BY 
        a.localizacao, m.id_maquina, m.local
    -- Ordenação decrescente pelo número de visitas
    ORDER BY 
        n_visitas DESC
)
WHERE ROWNUM <= 3;

--------------------------------------------------------------------------------------------------------------------------------

-- VIEW_J_2023146226 - Saraiva
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

--------------------------------------------------------------------------------------------------------------------------------

-- VIEW_K_2023146226 - Saraiva
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
  
--------------------------------------------------------------------------------------------------------------------------------

-- view_j_2023141377 - Diogo
CREATE OR REPLACE VIEW view_j_2023141377 AS
SELECT 
    localizacao AS cidade,
    SUM((ocupacao * capac_maxima) / 100) AS ocupacao_total,  -- Soma da ocupação real dos armazéns
    SUM(capac_maxima) AS capacidade_total,-- Soma das capacidades máximas dos armazéns
    ROUND(AVG(ocupacao), 2) AS percentagem_media_ocupacao --    -- Média das percentagens de ocupação
FROM 
    armazem
GROUP BY 
    localizacao;
    
--------------------------------------------------------------------------------------------------------------------------------

-- view_K_2023141377 - Diogo
CREATE OR REPLACE VIEW view_K_2023141377 AS
SELECT *
FROM (
    SELECT 
        f.id_funcionario,
        f.nome,
        COUNT(v.id_viagem) AS num_viagens  -- Numero total de viagens realizadas por ele
    FROM 
        funcionario f,
        viagem v
    WHERE 
        f.id_funcionario = v.id_funcionario
    GROUP BY 
        f.id_funcionario, f.nome
    ORDER BY 
        num_viagens DESC
)
WHERE ROWNUM <= 10;

--------------------------------------------------------------------------------------------------------------------------------

-- VIEW_J_2023140728 - Lucas

CREATE OR REPLACE VIEW VIEW_J_2023140728 AS
SELECT 
    a.id_armazem,                                -- ID único do armazém
    a.localizacao,                               -- Localização do armazém
    COUNT(rc.id_rc) AS num_reabastecimentos,     -- Total de reabastecimentos associados a este armazém
    SUM(rc.quantidade_reposta) AS total_quantidade_reposta -- Quantidade total de produtos reabastecidos
FROM reabastecimento_compartimento rc             -- Tabela de reabastecimentos realizados nos compartimentos
JOIN visita_maquina v ON rc.id_visita_maquina = v.id_visita_maquina -- Liga o reabastecimento à visita correspondente à máquina
JOIN viagem vi ON v.id_viagem = vi.id_viagem      -- Liga a visita à viagem onde ocorreu
JOIN veiculo ve ON vi.id_veiculo = ve.id_veiculo  -- Liga a viagem ao veículo que a realizou
JOIN garagem g ON ve.id_garagem = g.id_garagem    -- Liga o veículo à garagem onde está alocado
JOIN armazem a ON g.id_armazem = a.id_armazem     -- Liga a garagem ao armazém a que pertence
GROUP BY a.id_armazem, a.localizacao;                 -- Agrupa os resultados por armazém para obter totais por cada um

--------------------------------------------------------------------------------------------------------------------------------

-- VIEW_K_2023140728 - Lucas

CREATE OR REPLACE VIEW VIEW_K_2023140728 AS
SELECT
    m.id_maquina,                                  -- ID da máquina
    m.local,                                       -- Localização da máquina
    SUM(v.valor_venda) AS faturamento_maquina,     -- Soma total do valor das vendas feitas por esta máquina
    -- Subquery para calcular a média geral de faturamento entre todas as máquinas
    (SELECT AVG(faturamento_total) 
     FROM (
        SELECT SUM(v2.valor_venda) AS faturamento_total -- Faturamento total por máquina
        FROM vendas v2
        JOIN compartimento c2 ON v2.id_compartimento = c2.id_compartimento -- Liga vendas aos compartimentos
        GROUP BY c2.id_maquina -- Agrupa por máquina
    )) AS media_geral_faturamento,
    -- Diferença entre o faturamento da máquina atual e a média geral, com arredondamento a 2 casas decimais
    ROUND(
        SUM(v.valor_venda) - 
        (SELECT AVG(faturamento_total) 
         FROM (
            SELECT SUM(v2.valor_venda) AS faturamento_total
            FROM vendas v2
            JOIN compartimento c2 ON v2.id_compartimento = c2.id_compartimento
            GROUP BY c2.id_maquina
        )), 2) AS diferenca_em_relacao_media
FROM maquina m
JOIN compartimento c ON m.id_maquina = c.id_maquina -- Liga a máquina aos seus compartimentos
JOIN vendas v ON c.id_compartimento = v.id_compartimento -- Liga cada compartimento às vendas realizadas
GROUP BY m.id_maquina, m.local; -- Agrupa os resultados por máquina (para aplicar funções agregadas)