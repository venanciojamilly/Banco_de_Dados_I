/*
   Grupo 02:
   Anna Beatriz Soares Furtado 
   Jamilly Venâncio da Silva   
   Luana Bringel Leite         
   Vitória Maria do Nasciemnto 
*/

/*1 - Implemente uma função PL/SQL chamada calcula_total_cidade. Esta
função deverá receber o nome de uma cidade, calcular e retornar o valor total das
ordens de compra efetuadas com endereço de entrega para a cidade informada.*/

create or replace function calcula_total_cidade (nome_cidade ordem_de_compra.end_cidade%type)
return nota_fiscal.valor_total%type
is
    total_valor nota_fiscal.valor_total%type;
begin                          
    begin
        select sum(nf.valor_total) into total_valor
        from ordem_de_compra oc 
        join nota_fiscal nf on oc.codordem = nf.cod_ordem_compra
        where oc.end_cidade = nome_cidade
        group by oc.end_cidade;

    exception 
        when no_data_found then
            dbms_output.put_line('A cidade ' || nome_cidade || ' não foi encontrada.');
    end;
    return total_valor;
end;
/

/*2 - Implemente uma procedure PL/SQL chamada calcular_valor_nota. Esta
procedure recebe o código da ordem de compra e atualiza o VALOR_TOTAL da sua
respectiva nota fiscal. O valor é calculado com a seguinte fórmula:
(preço de cada produto comprado x quantidade do respectivo produto) + frete -
desconto.*/

create or replace procedure calcular_valor_nota (cod_ordem in ordem_de_compra.codordem%type) is
 valor_total_nf nota_fiscal.valor_total%type;
begin
    begin
        select nvl(sum(p.preco_venda * cp.quantidade) + oc.valor_frete - oc.desconto, 0) into valor_total_nf 
        from ordem_de_compra oc
        join compra_produto cp on oc.codordem = cp.codigo_compra
        join produto p on p.codprod = cp.codigo_produto
        where oc.codordem = cod_ordem
        group by oc.valor_frete, oc.desconto;

        update nota_fiscal nf 
        set nf.valor_total = valor_total_nf
        where nf.cod_ordem_compra = cod_ordem;

        commit;
        
    exception
        when no_data_found then
            dbms_output.put_line('A ordem de compra ' || cod_ordem || ' não foi encontrada.');
        when others then
            dbms_output.put_line('Ocorreu um erro ao calcular o valor da nota fiscal: ' || SQLERRM);
    end;
end;
/

/*3 - Implemente uma procedure PL/SQL chamada remover_produto_vencido.
Esta procedure recebe o código de um produto e remove o mesmo do banco, caso
ele esteja vencido.*/

create or replace procedure remover_produto_vencido (cod_produto Produto.codprod%type)
is 
begin    
    declare
        atual_data date := sysdate;
        expiration_date date;               
    begin
        select data_validade into expiration_date
        from produto
        where codprod = cod_produto;

        if expiration_date < atual_data then
            delete from produto
            where codprod = cod_produto;

            commit;

            dbms_output.put_line('Produto com código ' || cod_produto || ' foi removido por estar vencido.');
        
        else dbms_output.put_line('Produto com código ' || cod_produto || ' não está vencido.');
        end if;
        
    exception when no_data_found then
        dbms_output.put_line('O produto com código ' || cod_produto || ' não foi encontrado.');
        when others then
        dbms_output.put_line('Ocorreu um erro. Provavelmente, o produto está associado a outra tabela e não pôde ser deletado');
    end;
end;
/

/*4 - Crie uma visão que liste os as ordens de compra no valor de mais de 10 mil reais
que foram transportadas pela transportadora 'Azul Cargo'.*/

create or replace view azul_cargo as
select oc.*  
from ordem_de_compra oc 
join nota_fiscal nf on nf.cod_ordem_compra = oc.codordem 
join transportadora t on t.codtrans = oc.codigo_transportadora 
where t.nome = 'Azul Cargo' and nf.valor_total > 10000 and oc.status = 'FINALIZADA'; 

/*5 - Crie uma visão que liste todos os dados das ordens de compra juntamente do
valor total da sua nota fiscal, o nome do cliente que efetuou a compra e o nome da
transportadora responsável pelo transporte do pedido.*/

create or replace view info_compras as
select oc.*, nf.valor_total, cl.nome as nome_cliente, t.nome as nome_transportadora   
from ordem_de_compra oc join nota_fiscal nf on nf.cod_ordem_compra = oc.codordem 
join transportadora t on t.codtrans = oc.codigo_transportadora 
join cliente cl on cl.codcli = oc.codigo_cliente;

/*6 - Crie uma visão que exiba o valor médio das avaliações já feitas a cerca de um
produto. A visão deve exibir o código do Produto, e o valor médio das suas
avaliações. Exibindo 0 para Produtos ainda não avaliados. Ordene do melhor
avaliado para o pior.*/

create or replace view media_avaliacoes as
select p.codprod, nvl(avg(n.nota), 0) as media  
from produto p 
left join compra_avalia_produto n on p.codprod = n.codigo_produto 
group by p.codprod 
order by media desc;

/*7 - Crie um trigger para atualizar os pontos de um cliente quando ele finalizar uma
compra, cada compra é equivalente a 100 pontos.*/

create or replace trigger tg_atualiza_pontos
after update or insert of status on ordem_de_compra
for each row 
when (new.status = 'FINALIZADA')
begin
    update Cliente
    set pontos = pontos + 100
    where codcli = :new.codigo_cliente;
end;
/

/*8 - Crie um trigger para deixar em caixa alta todo nome de produto que estiver no
banco quando os dados de seu fornecedor forem atualizados.*/

create or replace trigger tg_upper
after update on Fornecedor
for each row 
begin 
    update Produto 
    set nome = UPPER(nome) 
    where codprod in (select codigo_produto
                    from Fornecimento where codigo_fornecedor = :new.codforn);
end;
/

/*9 - Crie uma trigger para associar uma compra a transportadora que menos tiver
compras associadas no momento da inserção de algum produto na compra.*/

create or replace trigger tg_associa_compra
before insert on compra_produto
for each row
begin

    update ordem_de_compra
    set codigo_transportadora = (select codtrans 
                                from (select t.codtrans, count(oc.codordem) as total_compras 
                                        from transportadora t
                                        left join ordem_de_compra oc on oc.codigo_transportadora = t.codtrans
                                        group by t.codtrans)
                                where total_compras = (select min(total_compras) 
                                                        from (select t.codtrans, count(oc.codordem) as total_compras 
                                                                from transportadora t
                                                                left join ordem_de_compra oc on oc.codigo_transportadora = t.codtrans
                                                                group by t.codtrans)))
    where codordem = :new.codigo_compra;

end;
/