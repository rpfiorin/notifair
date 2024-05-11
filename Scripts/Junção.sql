-- Exemplo amarracao sem JOIN
SELECT l.id, l.categoria AS categoria_lista,
       i.descricao AS item, i.fk_lista 
FROM lista_comp l, item_lista i
WHERE l.id = i.fk_lista 
ORDER BY l.id