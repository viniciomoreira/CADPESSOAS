if object_id('dbo.t_pessoa_juridica') is not null
	drop table dbo.t_pessoa_juridica
create table dbo.t_pessoa_juridica
(
	id_pessoa_juridica			int identity(1,1),
	id_pessoa					int,
	nr_inscricao_estadual		bigint,
	nr_inscricao_municipal		bigint,
	nm_fantasia					varchar (80)
)
