-- Deletar sequências
drop sequence sequence_codcli;
drop sequence sequence_ordemDeCompra; 
drop sequence sequence_notaFiscal; 
drop sequence sequence_transportadora; 
drop sequence sequence_produto; 
drop sequence sequence_categoria; 
drop sequence sequence_fornecedor;

-- Deletar restrições de Cliente
alter table Cliente drop constraint clienteRefCliente;

-- Deletar restrições de Telefones
alter table Telefones drop constraint telefonesRefCliente;

-- Deletar restrições de Ordem de Compra
alter table Ordem_de_Compra drop constraint ordemDeCompraRefCliente;
alter table Ordem_de_Compra drop constraint ordemDeCompraRefTransportadora;
alter table Ordem_de_Compra drop constraint ordemDeCompraRefNotaFiscal;

-- Deletar restrições de Produto
alter table Produto drop constraint produtoRefCategoria;

-- Deletar restrições de Avalia
alter table Avalia drop constraint avaliaRefProduto;
alter table Avalia drop constraint avaliaRefOrdemDeCompra;
alter table Avalia drop constraint notaValida;

-- Deletar restrições de Possui
alter table Possui drop constraint possuiRefProduto;
alter table Possui drop constraint possuiRefOrdemDeCompra;

-- Deletar restrições de Fornece
alter table Fornece drop constraint forneceRefProduto;
alter table Fornece drop constraint forneceRefFornecedor;

--Deletar atributos que são chaves primarias
alter table Cliente drop primary key cascade;
alter table Telefones drop primary key cascade;
alter table Ordem_de_Compra drop primary key cascade;
alter table Produto drop primary key cascade;
alter table Avalia drop primary key cascade;
alter table Possui drop primary key cascade;
alter table Fornece drop primary key cascade;
alter table Categoria drop primary key cascade;
alter table Nota_Fiscal drop primary key cascade;
alter table Fornecedor drop primary key cascade;
alter table Transportadora drop primary key cascade;

-- Deletar Tabelas
drop table Fornece;
drop table Avalia;
drop table Possui;
drop table Fornecedor;
drop table Produto;
drop table Ordem_de_Compra;
drop table Telefones;
drop table Cliente;
drop table Nota_Fiscal;
drop table Transportadora;
drop table Categoria;

-- Entidade
create table Cliente (

    pontos Int default 0 not null,
    sexo Char,
    nome Varchar(30) not null,
    sobrenome Varchar(30) not null,
    cpf Varchar(15) not null unique,
    codcli Int,
    data_de_nascimento Date not null,
    email Varchar(30) not null unique,
    end_CEP Varchar(10) not null,
    end_cidade Varchar(25) not null,
    end_bairro Varchar(25) not null,
    end_num Int not null,
    end_rua Varchar(50) not null,
    data_indicacao Date,
    codcli_indicacao Int,

    primary key (codcli)
);

-- Atributo multivalorado
create table Telefones (

    telefone Varchar(15) unique,
    codcli Int,

    primary key (telefone, codcli)
);

-- Entidade
create table Ordem_de_Compra(

    end_CEP Varchar(10) not null,
    end_cidade Varchar(25) not null,
    end_bairro Varchar(25) not null,
    end_num Int not null,
    end_rua Varchar(50) not null,
    frete Numeric(7,2) default 0 not null, 
    desconto Numeric(5,2) default 0 not null,
    status Varchar(15),
    data_compra Date,
    codigo Int,
    codcli Int not null,
    codigo_transportadora Int not null,
    codigo_nota_fiscal Int not null unique,

    primary key (codigo)
);

-- Entidade
create table Nota_Fiscal(

    data_nf Date not null,
    valor_final Numeric(7,2) default 0 not null, 
    chave_de_acesso Varchar(50) not null unique,
    inscricao_estadual Int not null,
    serie Varchar(10) not null unique,
    numero Int not null unique,
    codigo Int,

    primary key (codigo)
);

-- Entidade
create table Transportadora(

    site_da_transportadora Varchar(60) unique,
    telefone Varchar(15) not null unique,
    email Varchar(60) not null unique, 
    nome Varchar (50) not null unique, 
    codigo Int,
    end_CEP Varchar(10) not null,
    end_cidade Varchar(25) not null,
    end_bairro Varchar(25) not null,
    end_num Int not null,
    end_rua Varchar(50) not null,

    primary key (codigo)
);

-- Entidade
create table Produto (

    codigo Int,
    nome Varchar(30) not null,
    preco_compra Numeric(7,2),
    preco_venda Numeric(7,2) not null,
    data_de_fabricacao Date not null,
    descricao Varchar(150),
    quantidade Int default 0 not null,
    especificacao Varchar(150),
    data_de_validade Date not null,
    codigo_categoria Int not null,

    primary key (codigo)
);

-- Entidade
create table Categoria(

    nome Varchar(30) not null unique,
    codigo Int,

    primary key (codigo)
);

-- Entidade
create table Fornecedor(

    codigo Int,
    cnpj Int not null unique,
    nome Varchar(50) not null unique,
    home_page Varchar(60) unique,
    email Varchar(60) not null unique,
    telefone Varchar(15) not null unique, 
    end_CEP Varchar(10) not null,
    end_cidade Varchar(25) not null,
    end_bairro Varchar(25) not null,
    end_num Int not null,
    end_rua Varchar(50) not null,

    primary key (codigo)
); 

-- Relacionamento N para N entre Produto e Ordem de Compra
create table Avalia (

    nota Numeric(3,1) not null,
    descricao Varchar(150),
    codigo_produto Int,
    codigo_compra Int,

    primary key (codigo_produto, codigo_compra)    
);

-- Relacionamento N para N entre Produto e Ordem de Compra
create table Possui (

    quantidade Int default 0 not null,
    valor_atual Numeric(7,2) default 0 not null,
    codigo_produto Int,
    codigo_compra Int,

    primary key (codigo_produto, codigo_compra)
);

-- Relacionamento N para N entre Produto e Fornecedor
create table Fornece (

    codigo_produto Int,
    codigo_fornecedor Int,

    primary key (codigo_produto, codigo_fornecedor)
);


-- Alter Tables

-- Alter table Cliente
alter table Cliente add constraint clienteRefCliente foreign key (codcli_indicacao) references Cliente (codcli);

-- Alter table Telefones
alter table Telefones add constraint telefonesRefCliente foreign key (codcli) references Cliente (codcli);

-- Alter table Ordem de Compra
alter table Ordem_de_Compra add constraint ordemDeCompraRefCliente foreign key (codcli) references Cliente (codcli);
alter table Ordem_de_Compra add constraint ordemDeCompraRefTransportadora foreign key (codigo_transportadora) references Transportadora (codigo);
alter table Ordem_de_Compra add constraint ordemDeCompraRefNotaFiscal foreign key (codigo_nota_fiscal) references Nota_Fiscal (codigo);

-- Alter table Produto
alter table Produto add constraint produtoRefCategoria foreign key (codigo_categoria) references Categoria (codigo);

-- Alter table Avalia
alter table Avalia add constraint avaliaRefProduto foreign key (codigo_produto) references Produto (codigo);
alter table Avalia add constraint avaliaRefOrdemDeCompra foreign key (codigo_compra) references Ordem_de_compra (codigo);
alter table Avalia add constraint notaValida check (nota >= 0 and nota <= 10);

-- Alter table Possui
alter table Possui add constraint possuiRefProduto foreign key (codigo_produto) references Produto (codigo);
alter table Possui add constraint possuiRefOrdemDeCompra foreign key (codigo_compra) references Ordem_de_compra (codigo);

-- Alter table Fornece
alter table Fornece add constraint forneceRefProduto foreign key (codigo_produto) references Produto (codigo);
alter table Fornece add constraint forneceRefFornecedor foreign key (codigo_fornecedor) references Fornecedor (codigo);

-- Criar sequências
create sequence sequence_codcli start with 1;
create sequence sequence_ordemDeCompra start with 1; 
create sequence sequence_notaFiscal start with 1; 
create sequence sequence_transportadora start with 1; 
create sequence sequence_produto start with 1; 
create sequence sequence_categoria start with 1; 
create sequence sequence_fornecedor start with 1;
