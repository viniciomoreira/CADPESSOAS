if exists(select top 1 1 from sys.sysobjects where id = object_id('dbo.p_inserir_pessoa') and objectproperty(id,N'IsProcedure') = 1 )
	drop procedure dbo.p_inserir_pessoa
go
create procedure dbo.p_inserir_pessoa
(
	@nm_pessoa					varchar(120)	= null,
	@nr_cnpj_cpf				bigint			= null,
	@id_tp_pessoa				int				= null,
	@id_sexo					int				= null,
	@dt_nascimento				date			= null,
	@ds_altura					varchar(25)		= null,
	@ds_peso					varchar(25)		= null,
	@nm_naturalidade			varchar(50)		= null,
	@nr_inscricao_estadual		bigint			= null,
	@nr_inscricao_municipal		bigint			= null,
	@nm_fantasia				varchar(80)		= null,
	@cd_retorno					int				= null output,
	@nm_retorno					varchar(max)	= null output
)
as
begin
/*Objetivo: Cadastrar uma pessoa fisica ou juridica e não duplicar a pessoa considerando o seu documento

declare @cd_retorno int, @nm_retorno varchar(max)
exec dbo.p_inserir_pessoa
	@nm_pessoa					= 'Vinicio Moreira',
	@nr_cnpj_cpf				= 12345678912,
	@id_tp_pessoa				= 1,
	@id_sexo					= 1,
	@dt_nascimento				= '20000212',
	@ds_altura					= '1.74 metros',
	@ds_peso					= '88 Kg',
	@nm_naturalidade			= 'Brasileiro',
	@nr_inscricao_estadual		= null,
	@nr_inscricao_municipal		= null,
	@nm_fantasia				= null,
	@cd_retorno					= @cd_retorno output,
	@nm_retorno					= @nm_retorno output
select '@cd_retorno' = @cd_retorno, '@nm_retorno' = @nm_retorno
select top 1 * from dbo.t_pessoa order by 1 desc
select top 1 * from dbo.t_pessoa_fisica order by 1 desc
select top 1 * from dbo.t_pessoa_juridica order by 1 desc
*/
begin try
	set nocount on
	set xact_abort on
	declare @nm_proc varchar(128) = 'dbo.p_inserir_pessoa'

	declare @id_pessoa		int

	/*Criação de tabelas temporárias*/
	begin
		if object_id('tempdb..#t_pessoa_output') is not null
			drop table #t_pessoa_output
		create table #t_pessoa_output
		(
			id_pessoa					int,
			nr_cnpj_cpf					bigint
		)

		if object_id('tempdb..#t_pessoa_entrada') is not null
			drop table #t_pessoa_entrada
		create table #t_pessoa_entrada
		(
			id_pessoa					int,
			nm_pessoa					varchar(120),
			nr_cnpj_cpf					bigint,
			id_tp_pessoa				int,
			id_sexo						int,
			dt_nascimento				date,
			ds_altura					varchar(25),
			ds_peso						varchar(25),
			nm_naturalidade				varchar(50),
			nr_inscricao_estadual		bigint,
			nr_inscricao_municipal		bigint,
			nm_fantasia					varchar(80),
		)
	end

	/*Populando tabelas temporárias*/
	begin
		insert into #t_pessoa_entrada
		(
			nm_pessoa,
			nr_cnpj_cpf,
			id_tp_pessoa,
			id_sexo,
			dt_nascimento,
			ds_altura,
			ds_peso,
			nm_naturalidade,
			nr_inscricao_estadual,
			nr_inscricao_municipal,
			nm_fantasia
		)
		values
		(
			@nm_pessoa,
			@nr_cnpj_cpf,
			@id_tp_pessoa,
			@id_sexo,
			@dt_nascimento,
			@ds_altura,
			@ds_peso,
			@nm_naturalidade,
			@nr_inscricao_estadual,
			@nr_inscricao_municipal,
			@nm_fantasia
		)
		
		update t set
			id_pessoa		= tp.id_pessoa
		from
			#t_pessoa_entrada t
			inner join dbo.t_pessoa tp
				on tp.nr_cnpj_cpf = t.nr_cnpj_cpf
		
		delete t from #t_pessoa_entrada t where t.id_pessoa is not null
	end

	/*Resultado*/
	if exists(select top 1 1 from #t_pessoa_entrada t)
	begin
		insert into dbo.t_pessoa
		(
			nm_pessoa,
			nr_cnpj_cpf,
			id_tp_pessoa
		) output inserted.id_pessoa,inserted.nr_cnpj_cpf into #t_pessoa_output (id_pessoa,nr_cnpj_cpf)
		select
			t.nm_pessoa,
			t.nr_cnpj_cpf,
			t.id_tp_pessoa
		from
			#t_pessoa_entrada t

		update t set
			id_pessoa = ot.id_pessoa
		from
			#t_pessoa_entrada t
			inner join #t_pessoa_output ot
				on ot.nr_cnpj_cpf = t.nr_cnpj_cpf
		
		/*Inserindo pessoa física*/
		begin
			insert into dbo.t_pessoa_fisica
			(
				id_pessoa,
				id_sexo,
				dt_nascimento,
				ds_altura,
				ds_peso,
				nm_naturalidade
			)
			select
				t.id_pessoa,
				t.id_sexo,
				t.dt_nascimento,
				t.ds_altura,
				t.ds_peso,
				t.nm_naturalidade
			from
				#t_pessoa_entrada t
			where
				t.id_tp_pessoa = 1 /*Fisica*/
		end
		
		/*Inserindo pessoa juridica*/
		begin
			insert into dbo.t_pessoa_juridica
			(
				id_pessoa,
				nr_inscricao_estadual,
				nr_inscricao_municipal,
				nm_fantasia
			)
			select
				t.id_pessoa,
				t.nr_inscricao_estadual,
				t.nr_inscricao_municipal,
				t.nm_fantasia
			from
				#t_pessoa_entrada t
			where
				t.id_tp_pessoa = 2 /*Juridica*/
		end
		
	end
	
	select	@cd_retorno = 0,
			@nm_retorno = 'Cadastro de pessoa efetuado com sucesso'
end try
begin catch
	set @cd_retorno = 1
	set @nm_retorno = 
		'Procedure: ' + isnull(@nm_proc,'') + ' - ' + 'Mensagem: ' + isnull(convert(varchar(1000),error_message()),'') + 
		case when isnull(error_line(),0) <> 0 then ' - Linha: ' +convert(varchar(max),error_line()) else '' end
					
end catch

end