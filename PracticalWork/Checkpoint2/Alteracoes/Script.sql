/*==============================================================*/
/* DBMS name:      ORACLE Version 11g                           */
/* Created on:     22/03/2025 14:05:31                          */
/*==============================================================*/


alter table ARMAZENADO
   drop constraint FK_ARMAZENA_ARMAZENAD_PRODUTO;

alter table ARMAZENADO
   drop constraint FK_ARMAZENA_ARMAZENAD_ARMAZEM;

alter table COMPARTIMENTO
   drop constraint FK_COMPARTI_CONTEM_PR_PRODUTO;

alter table COMPARTIMENTO
   drop constraint FK_COMPARTI_POSSUI_CO_MAQUINA;

alter table CONTEM
   drop constraint FK_CONTEM_CONTEM_MAQUINA;

alter table CONTEM
   drop constraint FK_CONTEM_CONTEM2_ROTA;

alter table EVENTOS
   drop constraint FK_EVENTOS_MAQUINA_P_MAQUINA;

alter table GARAGEM
   drop constraint FK_GARAGEM_GARAGEM_D_ARMAZEM;

alter table LOG_ESTADOS
   drop constraint FK_LOG_ESTA_REGISTA_E_MAQUINA;

alter table MANUTENCAO_MAQUINA
   drop constraint FK_MANUTENC_VISITA_MA_VISITA_M;

alter table PRODUTOS_TRANSPORTADOS
   drop constraint FK_PRODUTOS_PRODUTOS__VIAGEM;

alter table PRODUTOS_TRANSPORTADOS
   drop constraint FK_PRODUTOS_PRODUTOS__PRODUTO;

alter table REABASTECIMENTO_ARMAZEM
   drop constraint FK_REABASTE_ARMAZEM_A_ARMAZEM;

alter table REABASTECIMENTO_ARMAZEM
   drop constraint FK_REABASTE_PRODUTO_A_PRODUTO;

alter table REABASTECIMENTO_COMPARTIMENTO
   drop constraint FK_REABASTE_REABASTEC_COMPARTI;

alter table REABASTECIMENTO_COMPARTIMENTO
   drop constraint FK_REABASTE_REABASTEC_PRODUTO;

alter table REABASTECIMENTO_COMPARTIMENTO
   drop constraint FK_REABASTE_VISITA_RE_VISITA_M;

alter table ROTA
   drop constraint FK_ROTA_ROTA_ARMA_ARMAZEM;

alter table VEICULO
   drop constraint FK_VEICULO_GUARDA_GARAGEM;

alter table VENDAS
   drop constraint FK_VENDAS_COMPARTIM_COMPARTI;

alter table VENDAS
   drop constraint FK_VENDAS_PRODUTO_V_PRODUTO;

alter table VIAGEM
   drop constraint FK_VIAGEM_ROTA_DA_V_ROTA;

alter table VIAGEM
   drop constraint FK_VIAGEM_VIAGEM_FE_FUNCIONA;

alter table VIAGEM
   drop constraint FK_VIAGEM_VIAGEM_VE_VEICULO;

alter table VISITA_MAQUINA
   drop constraint FK_VISITA_M_VIAGEM_VI_VIAGEM;

alter table VISITA_MAQUINA
   drop constraint FK_VISITA_M_VISITA_A__MAQUINA;

drop table ARMAZEM cascade constraints;

drop index ARMAZENADO2_FK;

drop index ARMAZENADO_FK;

drop table ARMAZENADO cascade constraints;

drop index POSSUI_COMPARTIMENTO_FK;

drop index CONTEM_PRODUTO_FK;

drop table COMPARTIMENTO cascade constraints;

drop index CONTEM2_FK;

drop index CONTEM_FK;

drop table CONTEM cascade constraints;

drop index MAQUINA_PINGS_FK;

drop table EVENTOS cascade constraints;

drop table FUNCIONARIO cascade constraints;

drop index GARAGEM_DO_ARMAZEM_FK;

drop table GARAGEM cascade constraints;

drop index REGISTA_ESTADO_FK;

drop table LOG_ESTADOS cascade constraints;

drop index VISITA_MANUTENCAO2_FK;

drop table MANUTENCAO_MAQUINA cascade constraints;

drop table MAQUINA cascade constraints;

drop table PRODUTO cascade constraints;

drop index PRODUTOS_TRANSPORTADOS2_FK;

drop index PRODUTOS_TRANSPORTADOS_FK;

drop table PRODUTOS_TRANSPORTADOS cascade constraints;

drop index ARMAZEM_A_REABASTECER_FK;

drop index PRODUTO_A_REABASTECER_FK;

drop table REABASTECIMENTO_ARMAZEM cascade constraints;

drop index REABASTECE_PRODUTO_FK;

drop index REABASTECE_COMPARTIMENTO_FK;

drop index VISITA_REABASTECIMENTO_FK;

drop table REABASTECIMENTO_COMPARTIMENTO cascade constraints;

drop index ROTA_ARMAZEM_FK;

drop table ROTA cascade constraints;

drop index GUARDA_FK;

drop table VEICULO cascade constraints;

drop index PRODUTO_VENDA_FK;

drop index COMPARTIMENTO_VENDA_FK;

drop table VENDAS cascade constraints;

drop index ROTA_DA_VIAGEM_FK;

drop index VIAGEM_VEICULO_FK;

drop index VIAGEM_FEITA_POR_FK;

drop table VIAGEM cascade constraints;

drop index VIAGEM_VISITAS_FK;

drop index VISITA_A_MAQUINA_FK;

drop table VISITA_MAQUINA cascade constraints;

/*==============================================================*/
/* Table: ARMAZEM                                               */
/*==============================================================*/
create table ARMAZEM 
(
   ID_ARMAZEM           NUMBER               not null,
   LOCALIZACAO          VARCHAR2(150),
   LATITUDE             NUMBER,
   LONGITUDE            NUMBER,
   CAPAC_MAXIMA         NUMBER,
   OCUPACAO             NUMBER,
   constraint PK_ARMAZEM primary key (ID_ARMAZEM)
);

/*==============================================================*/
/* Table: ARMAZENADO                                            */
/*==============================================================*/
create table ARMAZENADO 
(
   ID_PRODUTO           NUMBER               not null,
   ID_ARMAZEM           NUMBER               not null,
   QUANTIDADE_ATUAL     NUMBER,
   QUANTIDADE_PREVISTA  NUMBER,
   DATA_PROX_PREVISAO   DATE,
   constraint PK_ARMAZENADO primary key (ID_PRODUTO, ID_ARMAZEM)
);

/*==============================================================*/
/* Index: ARMAZENADO_FK                                         */
/*==============================================================*/
create index ARMAZENADO_FK on ARMAZENADO (
   ID_PRODUTO ASC
);

/*==============================================================*/
/* Index: ARMAZENADO2_FK                                        */
/*==============================================================*/
create index ARMAZENADO2_FK on ARMAZENADO (
   ID_ARMAZEM ASC
);

/*==============================================================*/
/* Table: COMPARTIMENTO                                         */
/*==============================================================*/
create table COMPARTIMENTO 
(
   ID_COMPARTIMENTO     NUMBER               not null,
   ID_MAQUINA           NUMBER               not null,
   ID_PRODUTO           NUMBER,
   CODIGO               NUMBER,
   POSICAO              VARCHAR2(2),
   STOCK                NUMBER,
   CAPAC_MAX            NUMBER,
   constraint PK_COMPARTIMENTO primary key (ID_COMPARTIMENTO)
);

/*==============================================================*/
/* Index: CONTEM_PRODUTO_FK                                     */
/*==============================================================*/
create index CONTEM_PRODUTO_FK on COMPARTIMENTO (
   ID_PRODUTO ASC
);

/*==============================================================*/
/* Index: POSSUI_COMPARTIMENTO_FK                               */
/*==============================================================*/
create index POSSUI_COMPARTIMENTO_FK on COMPARTIMENTO (
   ID_MAQUINA ASC
);

/*==============================================================*/
/* Table: CONTEM                                                */
/*==============================================================*/
create table CONTEM 
(
   ID_MAQUINA           NUMBER               not null,
   ID_ROTA              NUMBER               not null,
   ORDEM_MAQUINA        NUMBER,
   constraint PK_CONTEM primary key (ID_MAQUINA, ID_ROTA)
);

/*==============================================================*/
/* Index: CONTEM_FK                                             */
/*==============================================================*/
create index CONTEM_FK on CONTEM (
   ID_MAQUINA ASC
);

/*==============================================================*/
/* Index: CONTEM2_FK                                            */
/*==============================================================*/
create index CONTEM2_FK on CONTEM (
   ID_ROTA ASC
);

/*==============================================================*/
/* Table: EVENTOS                                               */
/*==============================================================*/
create table EVENTOS 
(
   ID_PING              NUMBER               not null,
   ID_MAQUINA           NUMBER               not null,
   PING                 VARCHAR2(50),
   DATA_PING            DATE,
   constraint PK_EVENTOS primary key (ID_PING)
);

/*==============================================================*/
/* Index: MAQUINA_PINGS_FK                                      */
/*==============================================================*/
create index MAQUINA_PINGS_FK on EVENTOS (
   ID_MAQUINA ASC
);

/*==============================================================*/
/* Table: FUNCIONARIO                                           */
/*==============================================================*/
create table FUNCIONARIO 
(
   ID_FUNCIONARIO       NUMBER               not null,
   NOME                 VARCHAR2(150),
   EMAIL                VARCHAR2(150),
   TELEFONE             NUMBER,
   constraint PK_FUNCIONARIO primary key (ID_FUNCIONARIO)
);

/*==============================================================*/
/* Table: GARAGEM                                               */
/*==============================================================*/
create table GARAGEM 
(
   ID_GARAGEM           NUMBER               not null,
   ID_ARMAZEM           NUMBER               not null,
   OCUPACAO             NUMBER,
   CAPAC_MAX            NUMBER,
   constraint PK_GARAGEM primary key (ID_GARAGEM)
);

/*==============================================================*/
/* Index: GARAGEM_DO_ARMAZEM_FK                                 */
/*==============================================================*/
create index GARAGEM_DO_ARMAZEM_FK on GARAGEM (
   ID_ARMAZEM ASC
);

/*==============================================================*/
/* Table: LOG_ESTADOS                                           */
/*==============================================================*/
create table LOG_ESTADOS 
(
   ID_LOG_ESTADOS       NUMBER               not null,
   ID_MAQUINA           NUMBER               not null,
   ESTADO_MAQUINA       VARCHAR2(50),
   DATA_HORA            DATE,
   constraint PK_LOG_ESTADOS primary key (ID_LOG_ESTADOS)
);

/*==============================================================*/
/* Index: REGISTA_ESTADO_FK                                     */
/*==============================================================*/
create index REGISTA_ESTADO_FK on LOG_ESTADOS (
   ID_MAQUINA ASC
);

/*==============================================================*/
/* Table: MANUTENCAO_MAQUINA                                    */
/*==============================================================*/
create table MANUTENCAO_MAQUINA 
(
   ID_MANUTENCAO        NUMBER               not null,
   ID_VISITA_MAQUINA    NUMBER               not null,
   DESCRICAO            VARCHAR2(250),
   DURACAO              NUMBER,
   constraint PK_MANUTENCAO_MAQUINA primary key (ID_MANUTENCAO)
);

/*==============================================================*/
/* Index: VISITA_MANUTENCAO2_FK                                 */
/*==============================================================*/
create index VISITA_MANUTENCAO2_FK on MANUTENCAO_MAQUINA (
   ID_VISITA_MAQUINA ASC
);

/*==============================================================*/
/* Table: MAQUINA                                               */
/*==============================================================*/
create table MAQUINA 
(
   ID_MAQUINA           NUMBER               not null,
   CIDADE               VARCHAR2(100),
   LOCAL                VARCHAR2(150),
   LATITUDE             NUMBER,
   LONGITUDE            NUMBER,
   ESTADO_ATUAL         VARCHAR2(100),
   ULTIMA_ATUALIZACAO   DATE,
   ULTIMA_VISITA        DATE,
   constraint PK_MAQUINA primary key (ID_MAQUINA)
);

/*==============================================================*/
/* Table: PRODUTO                                               */
/*==============================================================*/
create table PRODUTO 
(
   ID_PRODUTO           NUMBER               not null,
   NOME                 VARCHAR2(150),
   CATEGORIA            VARCHAR2(100),
   VOLUME               NUMBER,
   PRECO                NUMBER,
   constraint PK_PRODUTO primary key (ID_PRODUTO)
);

/*==============================================================*/
/* Table: PRODUTOS_TRANSPORTADOS                                */
/*==============================================================*/
create table PRODUTOS_TRANSPORTADOS 
(
   ID_VIAGEM            NUMBER               not null,
   ID_PRODUTO           NUMBER               not null,
   QUANTIDADE           NUMBER,
   constraint PK_PRODUTOS_TRANSPORTADOS primary key (ID_VIAGEM, ID_PRODUTO)
);

/*==============================================================*/
/* Index: PRODUTOS_TRANSPORTADOS_FK                             */
/*==============================================================*/
create index PRODUTOS_TRANSPORTADOS_FK on PRODUTOS_TRANSPORTADOS (
   ID_VIAGEM ASC
);

/*==============================================================*/
/* Index: PRODUTOS_TRANSPORTADOS2_FK                            */
/*==============================================================*/
create index PRODUTOS_TRANSPORTADOS2_FK on PRODUTOS_TRANSPORTADOS (
   ID_PRODUTO ASC
);

/*==============================================================*/
/* Table: REABASTECIMENTO_ARMAZEM                               */
/*==============================================================*/
create table REABASTECIMENTO_ARMAZEM 
(
   ID_RA                NUMBER               not null,
   ID_ARMAZEM           NUMBER               not null,
   ID_PRODUTO           NUMBER               not null,
   QUANTIDADE_REPOSTA   NUMBER,
   DATA_REABASTECIMENTO DATE,
   constraint PK_REABASTECIMENTO_ARMAZEM primary key (ID_RA)
);

/*==============================================================*/
/* Index: PRODUTO_A_REABASTECER_FK                              */
/*==============================================================*/
create index PRODUTO_A_REABASTECER_FK on REABASTECIMENTO_ARMAZEM (
   ID_PRODUTO ASC
);

/*==============================================================*/
/* Index: ARMAZEM_A_REABASTECER_FK                              */
/*==============================================================*/
create index ARMAZEM_A_REABASTECER_FK on REABASTECIMENTO_ARMAZEM (
   ID_ARMAZEM ASC
);

/*==============================================================*/
/* Table: REABASTECIMENTO_COMPARTIMENTO                         */
/*==============================================================*/
create table REABASTECIMENTO_COMPARTIMENTO 
(
   ID_RC                NUMBER               not null,
   ID_VISITA_MAQUINA    NUMBER               not null,
   ID_COMPARTIMENTO     NUMBER               not null,
   ID_PRODUTO           NUMBER               not null,
   QUANTIDADE_REPOSTA   NUMBER,
   DATA_HORA            DATE,
   constraint PK_REABASTECIMENTO_COMPARTIMEN primary key (ID_RC)
);

/*==============================================================*/
/* Index: VISITA_REABASTECIMENTO_FK                             */
/*==============================================================*/
create index VISITA_REABASTECIMENTO_FK on REABASTECIMENTO_COMPARTIMENTO (
   ID_VISITA_MAQUINA ASC
);

/*==============================================================*/
/* Index: REABASTECE_COMPARTIMENTO_FK                           */
/*==============================================================*/
create index REABASTECE_COMPARTIMENTO_FK on REABASTECIMENTO_COMPARTIMENTO (
   ID_COMPARTIMENTO ASC
);

/*==============================================================*/
/* Index: REABASTECE_PRODUTO_FK                                 */
/*==============================================================*/
create index REABASTECE_PRODUTO_FK on REABASTECIMENTO_COMPARTIMENTO (
   ID_PRODUTO ASC
);

/*==============================================================*/
/* Table: ROTA                                                  */
/*==============================================================*/
create table ROTA 
(
   ID_ROTA              NUMBER               not null,
   ID_ARMAZEM           NUMBER               not null,
   TIPO                 VARCHAR2(50),
   DESCRICAO            VARCHAR2(250),
   KMS                  NUMBER,
   constraint PK_ROTA primary key (ID_ROTA)
);

/*==============================================================*/
/* Index: ROTA_ARMAZEM_FK                                       */
/*==============================================================*/
create index ROTA_ARMAZEM_FK on ROTA (
   ID_ARMAZEM ASC
);

/*==============================================================*/
/* Table: VEICULO                                               */
/*==============================================================*/
create table VEICULO 
(
   ID_VEICULO           NUMBER               not null,
   ID_GARAGEM           NUMBER               not null,
   MATRICULA            VARCHAR2(10),
   ESTADO               VARCHAR2(50),
   AUTONOMIA_MAX        NUMBER,
   CAPACIDADE_CARGA     NUMBER,
   constraint PK_VEICULO primary key (ID_VEICULO)
);

/*==============================================================*/
/* Index: GUARDA_FK                                             */
/*==============================================================*/
create index GUARDA_FK on VEICULO (
   ID_GARAGEM ASC
);

/*==============================================================*/
/* Table: VENDAS                                                */
/*==============================================================*/
create table VENDAS 
(
   ID_VENDA             NUMBER               not null,
   ID_COMPARTIMENTO     NUMBER               not null,
   ID_PRODUTO           NUMBER               not null,
   VALOR_VENDA          NUMBER,
   METODO_PAGAMENTO     VARCHAR2(100),
   DATA_HORA            DATE,
   constraint PK_VENDAS primary key (ID_VENDA)
);

/*==============================================================*/
/* Index: COMPARTIMENTO_VENDA_FK                                */
/*==============================================================*/
create index COMPARTIMENTO_VENDA_FK on VENDAS (
   ID_COMPARTIMENTO ASC
);

/*==============================================================*/
/* Index: PRODUTO_VENDA_FK                                      */
/*==============================================================*/
create index PRODUTO_VENDA_FK on VENDAS (
   ID_PRODUTO ASC
);

/*==============================================================*/
/* Table: VIAGEM                                                */
/*==============================================================*/
create table VIAGEM 
(
   ID_VIAGEM            NUMBER               not null,
   ID_FUNCIONARIO       NUMBER               not null,
   ID_ROTA              NUMBER               not null,
   ID_VEICULO           NUMBER               not null,
   DISTANCIA_PERCORRIDA NUMBER,
   DATA_PARTIDA         DATE,
   DATA_CHEGADA         DATE,
   constraint PK_VIAGEM primary key (ID_VIAGEM)
);

/*==============================================================*/
/* Index: VIAGEM_FEITA_POR_FK                                   */
/*==============================================================*/
create index VIAGEM_FEITA_POR_FK on VIAGEM (
   ID_FUNCIONARIO ASC
);

/*==============================================================*/
/* Index: VIAGEM_VEICULO_FK                                     */
/*==============================================================*/
create index VIAGEM_VEICULO_FK on VIAGEM (
   ID_VEICULO ASC
);

/*==============================================================*/
/* Index: ROTA_DA_VIAGEM_FK                                     */
/*==============================================================*/
create index ROTA_DA_VIAGEM_FK on VIAGEM (
   ID_ROTA ASC
);

/*==============================================================*/
/* Table: VISITA_MAQUINA                                        */
/*==============================================================*/
create table VISITA_MAQUINA 
(
   ID_VISITA_MAQUINA    NUMBER               not null,
   ID_MAQUINA           NUMBER               not null,
   ID_VIAGEM            NUMBER               not null,
   DATA_HORA            DATE,
   constraint PK_VISITA_MAQUINA primary key (ID_VISITA_MAQUINA)
);

/*==============================================================*/
/* Index: VISITA_A_MAQUINA_FK                                   */
/*==============================================================*/
create index VISITA_A_MAQUINA_FK on VISITA_MAQUINA (
   ID_MAQUINA ASC
);

/*==============================================================*/
/* Index: VIAGEM_VISITAS_FK                                     */
/*==============================================================*/
create index VIAGEM_VISITAS_FK on VISITA_MAQUINA (
   ID_VIAGEM ASC
);

alter table ARMAZENADO
   add constraint FK_ARMAZENA_ARMAZENAD_PRODUTO foreign key (ID_PRODUTO)
      references PRODUTO (ID_PRODUTO);

alter table ARMAZENADO
   add constraint FK_ARMAZENA_ARMAZENAD_ARMAZEM foreign key (ID_ARMAZEM)
      references ARMAZEM (ID_ARMAZEM);

alter table COMPARTIMENTO
   add constraint FK_COMPARTI_CONTEM_PR_PRODUTO foreign key (ID_PRODUTO)
      references PRODUTO (ID_PRODUTO);

alter table COMPARTIMENTO
   add constraint FK_COMPARTI_POSSUI_CO_MAQUINA foreign key (ID_MAQUINA)
      references MAQUINA (ID_MAQUINA);

alter table CONTEM
   add constraint FK_CONTEM_CONTEM_MAQUINA foreign key (ID_MAQUINA)
      references MAQUINA (ID_MAQUINA);

alter table CONTEM
   add constraint FK_CONTEM_CONTEM2_ROTA foreign key (ID_ROTA)
      references ROTA (ID_ROTA);

alter table EVENTOS
   add constraint FK_EVENTOS_MAQUINA_P_MAQUINA foreign key (ID_MAQUINA)
      references MAQUINA (ID_MAQUINA);

alter table GARAGEM
   add constraint FK_GARAGEM_GARAGEM_D_ARMAZEM foreign key (ID_ARMAZEM)
      references ARMAZEM (ID_ARMAZEM);

alter table LOG_ESTADOS
   add constraint FK_LOG_ESTA_REGISTA_E_MAQUINA foreign key (ID_MAQUINA)
      references MAQUINA (ID_MAQUINA);

alter table MANUTENCAO_MAQUINA
   add constraint FK_MANUTENC_VISITA_MA_VISITA_M foreign key (ID_VISITA_MAQUINA)
      references VISITA_MAQUINA (ID_VISITA_MAQUINA);

alter table PRODUTOS_TRANSPORTADOS
   add constraint FK_PRODUTOS_PRODUTOS__VIAGEM foreign key (ID_VIAGEM)
      references VIAGEM (ID_VIAGEM);

alter table PRODUTOS_TRANSPORTADOS
   add constraint FK_PRODUTOS_PRODUTOS__PRODUTO foreign key (ID_PRODUTO)
      references PRODUTO (ID_PRODUTO);

alter table REABASTECIMENTO_ARMAZEM
   add constraint FK_REABASTE_ARMAZEM_A_ARMAZEM foreign key (ID_ARMAZEM)
      references ARMAZEM (ID_ARMAZEM);

alter table REABASTECIMENTO_ARMAZEM
   add constraint FK_REABASTE_PRODUTO_A_PRODUTO foreign key (ID_PRODUTO)
      references PRODUTO (ID_PRODUTO);

alter table REABASTECIMENTO_COMPARTIMENTO
   add constraint FK_REABASTE_REABASTEC_COMPARTI foreign key (ID_COMPARTIMENTO)
      references COMPARTIMENTO (ID_COMPARTIMENTO);

alter table REABASTECIMENTO_COMPARTIMENTO
   add constraint FK_REABASTE_REABASTEC_PRODUTO foreign key (ID_PRODUTO)
      references PRODUTO (ID_PRODUTO);

alter table REABASTECIMENTO_COMPARTIMENTO
   add constraint FK_REABASTE_VISITA_RE_VISITA_M foreign key (ID_VISITA_MAQUINA)
      references VISITA_MAQUINA (ID_VISITA_MAQUINA);

alter table ROTA
   add constraint FK_ROTA_ROTA_ARMA_ARMAZEM foreign key (ID_ARMAZEM)
      references ARMAZEM (ID_ARMAZEM);

alter table VEICULO
   add constraint FK_VEICULO_GUARDA_GARAGEM foreign key (ID_GARAGEM)
      references GARAGEM (ID_GARAGEM);

alter table VENDAS
   add constraint FK_VENDAS_COMPARTIM_COMPARTI foreign key (ID_COMPARTIMENTO)
      references COMPARTIMENTO (ID_COMPARTIMENTO);

alter table VENDAS
   add constraint FK_VENDAS_PRODUTO_V_PRODUTO foreign key (ID_PRODUTO)
      references PRODUTO (ID_PRODUTO);

alter table VIAGEM
   add constraint FK_VIAGEM_ROTA_DA_V_ROTA foreign key (ID_ROTA)
      references ROTA (ID_ROTA);

alter table VIAGEM
   add constraint FK_VIAGEM_VIAGEM_FE_FUNCIONA foreign key (ID_FUNCIONARIO)
      references FUNCIONARIO (ID_FUNCIONARIO);

alter table VIAGEM
   add constraint FK_VIAGEM_VIAGEM_VE_VEICULO foreign key (ID_VEICULO)
      references VEICULO (ID_VEICULO);

alter table VISITA_MAQUINA
   add constraint FK_VISITA_M_VIAGEM_VI_VIAGEM foreign key (ID_VIAGEM)
      references VIAGEM (ID_VIAGEM);

alter table VISITA_MAQUINA
   add constraint FK_VISITA_M_VISITA_A__MAQUINA foreign key (ID_MAQUINA)
      references MAQUINA (ID_MAQUINA);