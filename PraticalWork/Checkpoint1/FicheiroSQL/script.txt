/*==============================================================*/
/* DBMS name:      ORACLE Version 11g                           */
/* Created on:     09/03/2025 21:07:43                          */
/*==============================================================*/


alter table COMPARTIMENTO
   drop constraint FK_COMPARTI_C_M_MAQUINA;

alter table COMPARTIMENTO
   drop constraint FK_COMPARTI_C_P_PRODUTO;

alter table LOG_ESTADOS
   drop constraint FK_LOG_ESTA_L_E_M_MAQUINA;

alter table MANUTENCAO_MAQUINA
   drop constraint FK_MANUTENC_M_M_V_M2_VISITA_M;

alter table PREV_REAB_ARMAZEM
   drop constraint FK_PREV_REA_P_R_A_A_ARMAZEM;

alter table PREV_REAB_ARMAZEM
   drop constraint FK_PREV_REA_P_R_A_P_PRODUTO;

alter table PRODUTO_ARMAZEM
   drop constraint FK_PRODUTO__PRODUTO_A_PRODUTO;

alter table PRODUTO_ARMAZEM
   drop constraint FK_PRODUTO__PRODUTO_A_ARMAZEM;

alter table REABASTECIMENTO_ARMAZEM
   drop constraint FK_REABASTE_R_A_A_ARMAZEM;

alter table REABASTECIMENTO_ARMAZEM
   drop constraint FK_REABASTE_R_A_P_PRODUTO;

alter table REABASTECIMENTO_COMPARTIMENTO
   drop constraint FK_REABASTE_R_C_C_COMPARTI;

alter table REABASTECIMENTO_COMPARTIMENTO
   drop constraint FK_REABASTE_R_C_P_PRODUTO;

alter table REABASTECIMENTO_COMPARTIMENTO
   drop constraint FK_REABASTE_R_C_V_M_VISITA_M;

alter table ROTA
   drop constraint FK_ROTA_R_A_ARMAZEM;

alter table ROTA_MAQUINA
   drop constraint FK_ROTA_MAQ_ROTA_MAQU_MAQUINA;

alter table ROTA_MAQUINA
   drop constraint FK_ROTA_MAQ_ROTA_MAQU_ROTA;

alter table VEICULO
   drop constraint FK_VEICULO_V_G_GARAGEM;

alter table VENDAS
   drop constraint FK_VENDAS_V_C_COMPARTI;

alter table VENDAS
   drop constraint FK_VENDAS_V_P_PRODUTO;

alter table VIAGEM
   drop constraint FK_VIAGEM_V_F_FUNCIONA;

alter table VIAGEM
   drop constraint FK_VIAGEM_V_R_ROTA;

alter table VIAGEM
   drop constraint FK_VIAGEM_V_V_VEICULO;

alter table VISITA_MAQUINA
   drop constraint FK_VISITA_M_V_M_M_MAQUINA;

alter table VISITA_MAQUINA
   drop constraint FK_VISITA_M_V_M_V_VIAGEM;

drop table ARMAZEM cascade constraints;

drop index C_M_FK;

drop index C_P_FK;

drop table COMPARTIMENTO cascade constraints;

drop table FUNCIONARIO cascade constraints;

drop table GARAGEM cascade constraints;

drop index L_E_M_FK;

drop table LOG_ESTADOS cascade constraints;

drop index M_M_V_M2_FK;

drop table MANUTENCAO_MAQUINA cascade constraints;

drop table MAQUINA cascade constraints;

drop index P_R_A_A_FK;

drop index P_R_A_P_FK;

drop table PREV_REAB_ARMAZEM cascade constraints;

drop table PRODUTO cascade constraints;

drop index PRODUTO_ARMAZEM2_FK;

drop index PRODUTO_ARMAZEM_FK;

drop table PRODUTO_ARMAZEM cascade constraints;

drop index R_A_A_FK;

drop index R_A_P_FK;

drop table REABASTECIMENTO_ARMAZEM cascade constraints;

drop index R_C_P_FK;

drop index R_C_C_FK;

drop index R_C_V_M_FK;

drop table REABASTECIMENTO_COMPARTIMENTO cascade constraints;

drop index R_A_FK;

drop table ROTA cascade constraints;

drop index ROTA_MAQUINA2_FK;

drop index ROTA_MAQUINA_FK;

drop table ROTA_MAQUINA cascade constraints;

drop index V_G_FK;

drop table VEICULO cascade constraints;

drop index V_P_FK;

drop index V_C_FK;

drop table VENDAS cascade constraints;

drop index V_R_FK;

drop index V_V_FK;

drop index V_F_FK;

drop table VIAGEM cascade constraints;

drop index V_M_V_FK;

drop index V_M_M_FK;

drop table VISITA_MAQUINA cascade constraints;

/*==============================================================*/
/* Table: ARMAZEM                                               */
/*==============================================================*/
create table ARMAZEM 
(
   ID_ARMAZEM           NUMBER               not null,
   LOCALIZACAO          VARCHAR2(150)        not null,
   CAPAC_MAXIMA         NUMBER               not null,
   OCUPACAO             NUMBER               not null,
   constraint PK_ARMAZEM primary key (ID_ARMAZEM)
);

/*==============================================================*/
/* Table: COMPARTIMENTO                                         */
/*==============================================================*/
create table COMPARTIMENTO 
(
   ID_COMPARTIMENTO     NUMBER               not null,
   ID_MAQUINA           NUMBER               not null,
   ID_PRODUTO           NUMBER,
   CODIGO               NUMBER               not null,
   POSICAO              VARCHAR2(2)          not null,
   STOCK                NUMBER               not null,
   CAPAC_MAX            NUMBER               not null,
   constraint PK_COMPARTIMENTO primary key (ID_COMPARTIMENTO)
);

/*==============================================================*/
/* Index: C_P_FK                                                */
/*==============================================================*/
create index C_P_FK on COMPARTIMENTO (
   ID_PRODUTO ASC
);

/*==============================================================*/
/* Index: C_M_FK                                                */
/*==============================================================*/
create index C_M_FK on COMPARTIMENTO (
   ID_MAQUINA ASC
);

/*==============================================================*/
/* Table: FUNCIONARIO                                           */
/*==============================================================*/
create table FUNCIONARIO 
(
   ID_FUNCIONARIO       NUMBER               not null,
   NOME                 VARCHAR2(150)        not null,
   EMAIL                VARCHAR2(150)        not null,
   TELEFONE             NUMBER               not null,
   constraint PK_FUNCIONARIO primary key (ID_FUNCIONARIO)
);

/*==============================================================*/
/* Table: GARAGEM                                               */
/*==============================================================*/
create table GARAGEM 
(
   ID_GARAGEM           NUMBER               not null,
   LOCALIZACAO          VARCHAR2(150)        not null,
   OCUPACAO             NUMBER               not null,
   CAPAC_MAX            NUMBER               not null,
   constraint PK_GARAGEM primary key (ID_GARAGEM)
);

/*==============================================================*/
/* Table: LOG_ESTADOS                                           */
/*==============================================================*/
create table LOG_ESTADOS 
(
   ID_LOG_ESTADOS       NUMBER               not null,
   ID_MAQUINA           NUMBER               not null,
   ESTADO_MAQUINA       VARCHAR2(50)         not null,
   DATA_HORA            DATE,
   constraint PK_LOG_ESTADOS primary key (ID_LOG_ESTADOS)
);

/*==============================================================*/
/* Index: L_E_M_FK                                              */
/*==============================================================*/
create index L_E_M_FK on LOG_ESTADOS (
   ID_MAQUINA ASC
);

/*==============================================================*/
/* Table: MANUTENCAO_MAQUINA                                    */
/*==============================================================*/
create table MANUTENCAO_MAQUINA 
(
   ID_MANUTENCAO        NUMBER               not null,
   ID_VISITA_MAQUINA    NUMBER               not null,
   DESCRICAO            VARCHAR2(250)        not null,
   DURACAO              DATE                 not null,
   constraint PK_MANUTENCAO_MAQUINA primary key (ID_MANUTENCAO)
);

/*==============================================================*/
/* Index: M_M_V_M2_FK                                           */
/*==============================================================*/
create index M_M_V_M2_FK on MANUTENCAO_MAQUINA (
   ID_VISITA_MAQUINA ASC
);

/*==============================================================*/
/* Table: MAQUINA                                               */
/*==============================================================*/
create table MAQUINA 
(
   ID_MAQUINA           NUMBER               not null,
   CIDADE               VARCHAR2(100)        not null,
   LOCAL                VARCHAR2(150)        not null,
   ESTADO_ATUAL         VARCHAR2(100)        not null,
   ULTIMA_ATUALIZACAO   DATE                 not null,
   ULTIMA_VISITA        DATE                 not null,
   constraint PK_MAQUINA primary key (ID_MAQUINA)
);

/*==============================================================*/
/* Table: PREV_REAB_ARMAZEM                                     */
/*==============================================================*/
create table PREV_REAB_ARMAZEM 
(
   ID_PRA               NUMBER               not null,
   ID_ARMAZEM           NUMBER               not null,
   ID_PRODUTO           NUMBER               not null,
   QUANTIDADE_PREVISTA  NUMBER               not null,
   QUANTIDADE_VENDIDA   NUMBER               not null,
   DATA_PREVISTA        DATE                 not null,
   constraint PK_PREV_REAB_ARMAZEM primary key (ID_PRA)
);

/*==============================================================*/
/* Index: P_R_A_P_FK                                            */
/*==============================================================*/
create index P_R_A_P_FK on PREV_REAB_ARMAZEM (
   ID_PRODUTO ASC
);

/*==============================================================*/
/* Index: P_R_A_A_FK                                            */
/*==============================================================*/
create index P_R_A_A_FK on PREV_REAB_ARMAZEM (
   ID_ARMAZEM ASC
);

/*==============================================================*/
/* Table: PRODUTO                                               */
/*==============================================================*/
create table PRODUTO 
(
   ID_PRODUTO           NUMBER               not null,
   NOME                 VARCHAR2(150)        not null,
   CATEGORIA            VARCHAR2(100)        not null,
   VOLUME               NUMBER               not null,
   PRECO                NUMBER               not null,
   constraint PK_PRODUTO primary key (ID_PRODUTO)
);

/*==============================================================*/
/* Table: PRODUTO_ARMAZEM                                       */
/*==============================================================*/
create table PRODUTO_ARMAZEM 
(
   ID_PRODUTO           NUMBER               not null,
   ID_ARMAZEM           NUMBER               not null,
   STOCK_ARMAZEM        NUMBER               not null,
   constraint PK_PRODUTO_ARMAZEM primary key (ID_PRODUTO, ID_ARMAZEM)
);

/*==============================================================*/
/* Index: PRODUTO_ARMAZEM_FK                                    */
/*==============================================================*/
create index PRODUTO_ARMAZEM_FK on PRODUTO_ARMAZEM (
   ID_PRODUTO ASC
);

/*==============================================================*/
/* Index: PRODUTO_ARMAZEM2_FK                                   */
/*==============================================================*/
create index PRODUTO_ARMAZEM2_FK on PRODUTO_ARMAZEM (
   ID_ARMAZEM ASC
);

/*==============================================================*/
/* Table: REABASTECIMENTO_ARMAZEM                               */
/*==============================================================*/
create table REABASTECIMENTO_ARMAZEM 
(
   ID_RA                NUMBER               not null,
   ID_ARMAZEM           NUMBER               not null,
   ID_PRODUTO           NUMBER               not null,
   QUANTIDADE_REPOSTA   NUMBER               not null,
   DATA_REABASTECIMENTO DATE                 not null,
   constraint PK_REABASTECIMENTO_ARMAZEM primary key (ID_RA)
);

/*==============================================================*/
/* Index: R_A_P_FK                                              */
/*==============================================================*/
create index R_A_P_FK on REABASTECIMENTO_ARMAZEM (
   ID_PRODUTO ASC
);

/*==============================================================*/
/* Index: R_A_A_FK                                              */
/*==============================================================*/
create index R_A_A_FK on REABASTECIMENTO_ARMAZEM (
   ID_ARMAZEM ASC
);

/*==============================================================*/
/* Table: REABASTECIMENTO_COMPARTIMENTO                         */
/*==============================================================*/
create table REABASTECIMENTO_COMPARTIMENTO 
(
   ID_REABASTECIMENTO   NUMBER               not null,
   ID_VISITA_MAQUINA    NUMBER               not null,
   ID_COMPARTIMENTO     NUMBER               not null,
   ID_PRODUTO           NUMBER               not null,
   QUANTIDADE_REPOSTA   NUMBER               not null,
   DATA_HORA            DATE                 not null,
   constraint PK_REABASTECIMENTO_COMPARTIMEN primary key (ID_REABASTECIMENTO)
);

/*==============================================================*/
/* Index: R_C_V_M_FK                                            */
/*==============================================================*/
create index R_C_V_M_FK on REABASTECIMENTO_COMPARTIMENTO (
   ID_VISITA_MAQUINA ASC
);

/*==============================================================*/
/* Index: R_C_C_FK                                              */
/*==============================================================*/
create index R_C_C_FK on REABASTECIMENTO_COMPARTIMENTO (
   ID_COMPARTIMENTO ASC
);

/*==============================================================*/
/* Index: R_C_P_FK                                              */
/*==============================================================*/
create index R_C_P_FK on REABASTECIMENTO_COMPARTIMENTO (
   ID_PRODUTO ASC
);

/*==============================================================*/
/* Table: ROTA                                                  */
/*==============================================================*/
create table ROTA 
(
   ID_ROTA              NUMBER               not null,
   ID_ARMAZEM           NUMBER               not null,
   TIPO                 VARCHAR2(50)         not null,
   DESCRICAO            VARCHAR2(250)        not null,
   constraint PK_ROTA primary key (ID_ROTA)
);

/*==============================================================*/
/* Index: R_A_FK                                                */
/*==============================================================*/
create index R_A_FK on ROTA (
   ID_ARMAZEM ASC
);

/*==============================================================*/
/* Table: ROTA_MAQUINA                                          */
/*==============================================================*/
create table ROTA_MAQUINA 
(
   ID_MAQUINA           NUMBER               not null,
   ID_ROTA              NUMBER               not null,
   ORDEM_MAQUINAS       NUMBER               not null,
   constraint PK_ROTA_MAQUINA primary key (ID_MAQUINA, ID_ROTA)
);

/*==============================================================*/
/* Index: ROTA_MAQUINA_FK                                       */
/*==============================================================*/
create index ROTA_MAQUINA_FK on ROTA_MAQUINA (
   ID_MAQUINA ASC
);

/*==============================================================*/
/* Index: ROTA_MAQUINA2_FK                                      */
/*==============================================================*/
create index ROTA_MAQUINA2_FK on ROTA_MAQUINA (
   ID_ROTA ASC
);

/*==============================================================*/
/* Table: VEICULO                                               */
/*==============================================================*/
create table VEICULO 
(
   ID_VEICULO           NUMBER               not null,
   ID_GARAGEM           NUMBER               not null,
   MATRICULA            VARCHAR2(10)         not null,
   AUTONOMIA_MAX        NUMBER               not null,
   CAPACIDADE_CARGA     NUMBER               not null,
   constraint PK_VEICULO primary key (ID_VEICULO)
);

/*==============================================================*/
/* Index: V_G_FK                                                */
/*==============================================================*/
create index V_G_FK on VEICULO (
   ID_GARAGEM ASC
);

/*==============================================================*/
/* Table: VENDAS                                                */
/*==============================================================*/
create table VENDAS 
(
   ID_VENDAS            NUMBER               not null,
   ID_COMPARTIMENTO     NUMBER               not null,
   ID_PRODUTO           NUMBER               not null,
   VALOR_VENDA          NUMBER               not null,
   METODO_PAGAMENTO     VARCHAR2(100)        not null,
   DATA_HORA            DATE                 not null,
   constraint PK_VENDAS primary key (ID_VENDAS)
);

/*==============================================================*/
/* Index: V_C_FK                                                */
/*==============================================================*/
create index V_C_FK on VENDAS (
   ID_COMPARTIMENTO ASC
);

/*==============================================================*/
/* Index: V_P_FK                                                */
/*==============================================================*/
create index V_P_FK on VENDAS (
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
   DISTANCIA_PERCORRIDA NUMBER               not null,
   DATA_PARTIDA         DATE                 not null,
   DATA_CHEGADA         DATE                 not null,
   constraint PK_VIAGEM primary key (ID_VIAGEM)
);

/*==============================================================*/
/* Index: V_F_FK                                                */
/*==============================================================*/
create index V_F_FK on VIAGEM (
   ID_FUNCIONARIO ASC
);

/*==============================================================*/
/* Index: V_V_FK                                                */
/*==============================================================*/
create index V_V_FK on VIAGEM (
   ID_VEICULO ASC
);

/*==============================================================*/
/* Index: V_R_FK                                                */
/*==============================================================*/
create index V_R_FK on VIAGEM (
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
   TIPO                 VARCHAR2(50)         not null,
   DATA_HORA            DATE                 not null,
   constraint PK_VISITA_MAQUINA primary key (ID_VISITA_MAQUINA)
);

/*==============================================================*/
/* Index: V_M_M_FK                                              */
/*==============================================================*/
create index V_M_M_FK on VISITA_MAQUINA (
   ID_MAQUINA ASC
);

/*==============================================================*/
/* Index: V_M_V_FK                                              */
/*==============================================================*/
create index V_M_V_FK on VISITA_MAQUINA (
   ID_VIAGEM ASC
);

alter table COMPARTIMENTO
   add constraint FK_COMPARTI_C_M_MAQUINA foreign key (ID_MAQUINA)
      references MAQUINA (ID_MAQUINA);

alter table COMPARTIMENTO
   add constraint FK_COMPARTI_C_P_PRODUTO foreign key (ID_PRODUTO)
      references PRODUTO (ID_PRODUTO);

alter table LOG_ESTADOS
   add constraint FK_LOG_ESTA_L_E_M_MAQUINA foreign key (ID_MAQUINA)
      references MAQUINA (ID_MAQUINA);

alter table MANUTENCAO_MAQUINA
   add constraint FK_MANUTENC_M_M_V_M2_VISITA_M foreign key (ID_VISITA_MAQUINA)
      references VISITA_MAQUINA (ID_VISITA_MAQUINA);

alter table PREV_REAB_ARMAZEM
   add constraint FK_PREV_REA_P_R_A_A_ARMAZEM foreign key (ID_ARMAZEM)
      references ARMAZEM (ID_ARMAZEM);

alter table PREV_REAB_ARMAZEM
   add constraint FK_PREV_REA_P_R_A_P_PRODUTO foreign key (ID_PRODUTO)
      references PRODUTO (ID_PRODUTO);

alter table PRODUTO_ARMAZEM
   add constraint FK_PRODUTO__PRODUTO_A_PRODUTO foreign key (ID_PRODUTO)
      references PRODUTO (ID_PRODUTO);

alter table PRODUTO_ARMAZEM
   add constraint FK_PRODUTO__PRODUTO_A_ARMAZEM foreign key (ID_ARMAZEM)
      references ARMAZEM (ID_ARMAZEM);

alter table REABASTECIMENTO_ARMAZEM
   add constraint FK_REABASTE_R_A_A_ARMAZEM foreign key (ID_ARMAZEM)
      references ARMAZEM (ID_ARMAZEM);

alter table REABASTECIMENTO_ARMAZEM
   add constraint FK_REABASTE_R_A_P_PRODUTO foreign key (ID_PRODUTO)
      references PRODUTO (ID_PRODUTO);

alter table REABASTECIMENTO_COMPARTIMENTO
   add constraint FK_REABASTE_R_C_C_COMPARTI foreign key (ID_COMPARTIMENTO)
      references COMPARTIMENTO (ID_COMPARTIMENTO);

alter table REABASTECIMENTO_COMPARTIMENTO
   add constraint FK_REABASTE_R_C_P_PRODUTO foreign key (ID_PRODUTO)
      references PRODUTO (ID_PRODUTO);

alter table REABASTECIMENTO_COMPARTIMENTO
   add constraint FK_REABASTE_R_C_V_M_VISITA_M foreign key (ID_VISITA_MAQUINA)
      references VISITA_MAQUINA (ID_VISITA_MAQUINA);

alter table ROTA
   add constraint FK_ROTA_R_A_ARMAZEM foreign key (ID_ARMAZEM)
      references ARMAZEM (ID_ARMAZEM);

alter table ROTA_MAQUINA
   add constraint FK_ROTA_MAQ_ROTA_MAQU_MAQUINA foreign key (ID_MAQUINA)
      references MAQUINA (ID_MAQUINA);

alter table ROTA_MAQUINA
   add constraint FK_ROTA_MAQ_ROTA_MAQU_ROTA foreign key (ID_ROTA)
      references ROTA (ID_ROTA);

alter table VEICULO
   add constraint FK_VEICULO_V_G_GARAGEM foreign key (ID_GARAGEM)
      references GARAGEM (ID_GARAGEM);

alter table VENDAS
   add constraint FK_VENDAS_V_C_COMPARTI foreign key (ID_COMPARTIMENTO)
      references COMPARTIMENTO (ID_COMPARTIMENTO);

alter table VENDAS
   add constraint FK_VENDAS_V_P_PRODUTO foreign key (ID_PRODUTO)
      references PRODUTO (ID_PRODUTO);

alter table VIAGEM
   add constraint FK_VIAGEM_V_F_FUNCIONA foreign key (ID_FUNCIONARIO)
      references FUNCIONARIO (ID_FUNCIONARIO);

alter table VIAGEM
   add constraint FK_VIAGEM_V_R_ROTA foreign key (ID_ROTA)
      references ROTA (ID_ROTA);

alter table VIAGEM
   add constraint FK_VIAGEM_V_V_VEICULO foreign key (ID_VEICULO)
      references VEICULO (ID_VEICULO);

alter table VISITA_MAQUINA
   add constraint FK_VISITA_M_V_M_M_MAQUINA foreign key (ID_MAQUINA)
      references MAQUINA (ID_MAQUINA);

alter table VISITA_MAQUINA
   add constraint FK_VISITA_M_V_M_V_VIAGEM foreign key (ID_VIAGEM)
      references VIAGEM (ID_VIAGEM);

