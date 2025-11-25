create schema if not exists dw;

drop table if exists dw.fat_mtr;
drop table if exists dw.dim_crp;
drop table if exists dw.dim_dta;
drop table if exists dw.dim_hra;

create table if not exists dw.dim_dta (
    srk_dta integer primary key,        
    dte_cpt date not null,              
    num_dia smallint,                   
    num_mes smallint,                   
    num_ano smallint,                   
    nom_mes varchar(20),                
    nom_sem varchar(20),                
    num_tri smallint,                   
    num_sem smallint,                   
    flg_fds boolean                     
);

create index if not exists idx_dta_dte on dw.dim_dta(dte_cpt);

create table if not exists dw.dim_hra (
    srk_hra integer primary key,        
    hre_cpt time not null,              
    num_hra smallint,                   
    num_min smallint,                   
    num_seg smallint,                   
    nom_per varchar(20)                 
);

create index if not exists idx_hra_hre on dw.dim_hra(hre_cpt);

create table if not exists dw.dim_crp (
    srk_crp bigserial primary key,         
    nky_nom varchar(255) not null unique,  
    cod_sym varchar(32),                   
    vlr_max_sup numeric(38,10),            
    flg_atv boolean,                       
    dte_add date                           
);

create index if not exists idx_crp_nom on dw.dim_crp(nky_nom);

create table if not exists dw.fat_mtr (
    srk_fat bigserial primary key,        
    srk_crp bigint not null,              
    srk_dta integer not null,             
    srk_hra integer not null,             
    rnk_cmc integer,                      
    vlr_pre_usd numeric(30,8),            
    vlr_vlm_24h numeric(30,2),            
    vlr_mkt numeric(30,2),             
    vlr_dom numeric(8,4),                 
    vlr_tvr numeric(12,6),                
    qtd_par integer,                      
    qtd_cir_sup numeric(30,8),            
    qtd_tot_sup numeric(30,8),            
    vlr_fld_mkt numeric(30,2),          
    vlr_mkt_tot numeric(30,2),         
    pct_ytd numeric(38,10),               
    pct_1hr numeric(38,10),               
    pct_24h numeric(38,10),               
    pct_7dd numeric(38,10),               
    pct_30d numeric(38,10),               
    pct_60d numeric(38,10),               
    pct_90d numeric(38,10),               

    constraint fk_fat_crp foreign key (srk_crp) references dw.dim_crp(srk_crp),
    constraint fk_fat_dta foreign key (srk_dta) references dw.dim_dta(srk_dta),
    constraint fk_fat_hra foreign key (srk_hra) references dw.dim_hra(srk_hra)
);

create index if not exists idx_fat_crp on dw.fat_mtr(srk_crp);
create index if not exists idx_fato_data on dw.fat_mtr_crp(sk_data);
create index if not exists idx_fato_hora on dw.fat_mtr_crp(sk_hora);
create index if not exists idx_fato_data_crpt on dw.fat_mtr_crp(sk_data, sk_crpt);
create index if not exists idx_fato_marketcap on dw.fat_mtr_crp(vlr_mktcap desc);
