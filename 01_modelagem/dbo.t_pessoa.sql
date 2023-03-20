if object_id('dbo.t_pessoa') is not null
	drop table dbo.t_pessoa
create table dbo.t_pessoa
(
	id_pessoa			int identity(1,1),
	nm_pessoa			varchar(120),
	nr_cnpj_cpf			bigint,
	id_tp_pessoa		int
)