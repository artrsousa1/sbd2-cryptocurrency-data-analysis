create schema if not exists dw;

drop table if exists dw.fato_metricas_crpt;
drop table if exists dw.dim_crpt;
drop table if exists dw.dim_data;
drop table if exists dw.dim_hora;

create table if not exists dw.dim_data (
    sk_data integer primary key,           
    dt_cpta date not null,                 
    nr_dia smallint,                       
    nr_mes smallint,                       
    nr_ano smallint,                       
    nm_mes varchar(20),                    
    nm_d_sem varchar(20),                  
    nr_trim smallint,                      
    nr_sem smallint,                       
    fl_fds boolean                         
);

create index if not exists idx_dim_data_dt on dw.dim_data(dt_cpta);

create table if not exists dw.dim_hora (
    sk_hora integer primary key,           
    hr_cpta time not null,                 
    nr_hora smallint,                      
    nr_min smallint,                       
    nr_seg smallint,                       
    nm_perdd varchar(20)                   
);

create index if not exists idx_dim_hora_hr on dw.dim_hora(hr_cpta);

create table if not exists dw.dim_crpt (
    sk_crpt bigserial primary key,         
    nk_nome varchar(255) not null unique,  
    cd_symbol varchar(32),                 
    vlr_max_supply numeric(38,10),         
    fl_ativa boolean,                      
    dt_add date                            
);

create index if not exists idx_dim_crpt_nome on dw.dim_crpt(nk_nome);

create table if not exists dw.fato_metricas_crpt (
    sk_fato bigserial primary key,         
    sk_crpt bigint not null,               
    sk_data integer not null,              
    sk_hora integer not null,              
    rnk_cmc integer,                       
    vlr_preco_usd numeric(30,8),           
    vlr_volume_24h numeric(30,2),          
    vlr_mktcap numeric(30,2),              
    vlr_dmn numeric(8,4),                  
    vlr_tovr numeric(12,6),                
    qtd_pairs integer,                     
    qtd_circ_sup numeric(30,8),            
    qtd_tot_sup numeric(30,8),             
    vlr_fd_mktcap numeric(30,2),           
    vlr_mcap_ts numeric(30,2),            
    pc_ytd numeric(38,10),                  
    pc_1h numeric(38,10),                   
    pc_24h numeric(38,10),                  
    pc_7d numeric(38,10),                   
    pc_30d numeric(38,10),                  
    pc_60d numeric(38,10),                  
    pc_90d numeric(38,10),                  
    
    constraint fk_fato_crpt foreign key (sk_crpt) references dw.dim_crpt(sk_crpt),
    constraint fk_fato_data foreign key (sk_data) references dw.dim_data(sk_data),
    constraint fk_fato_hora foreign key (sk_hora) references dw.dim_hora(sk_hora)
);

create index if not exists idx_fato_crpt on dw.fato_metricas_crpt(sk_crpt);
create index if not exists idx_fato_data on dw.fato_metricas_crpt(sk_data);
create index if not exists idx_fato_hora on dw.fato_metricas_crpt(sk_hora);
create index if not exists idx_fato_data_crpt on dw.fato_metricas_crpt(sk_data, sk_crpt);
create index if not exists idx_fato_marketcap on dw.fato_metricas_crpt(vlr_mktcap desc);