CREATE TABLE lista_comp
(
 id SERIAL PRIMARY KEY,
 categoria VARCHAR(10) NOT NULL,
 mes SMALLINT NOT NULL,
 ano INTEGER NOT NULL,
 dt_fim DATE NOT NULL
);

CREATE TABLE item_lista
(
 id SERIAL PRIMARY KEY,
 descricao TEXT NOT NULL,
 marca VARCHAR(30),
 quantidade VARCHAR(10) NOT NULL,
 dur_dias SMALLINT NOT NULL,
 fk_lista INTEGER NOT NULL
 REFERENCES lista_comp(id)
 ON DELETE CASCADE
);

--Auxiliar table
CREATE TABLE public.sistema
(
 codigo INTEGER PRIMARY KEY,
 nome TEXT NOT NULL,
 versao VARCHAR(12) NOT NULL,
 dt_inicio DATE NOT NULL,
 dt_fim DATE,
 is_available BOOLEAN NOT NULL
); 
INSERT INTO public.sistema
(codigo,nome,versao,dt_inicio,is_available) 
VALUES (1,'NotiFair','1.0.1','2018-09-01',True);