if object_id('dbo.t_pessoa_fisica') is not null
	drop table dbo.t_pessoa_fisica
create table dbo.t_pessoa_fisica
(
	id_pessoa_fisica	int identity(1,1),
	id_pessoa			int,
	id_sexo				int,
	dt_nascimento		date,
	ds_altura			varchar(25),
	ds_peso				varchar(25),
	nm_naturalidade		varchar(50)
)