-- CRIAR BANCO

CREATE DATABASE IF NOT EXISTS boschstore;
USE boschstore;

-- LIMPAR TABELAS

DROP TABLE IF EXISTS itens_pedido;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS produtos;
DROP TABLE IF EXISTS clientes;

-- CRIAR TABELAS

CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY,
    nome VARCHAR(100),
    email VARCHAR(100),
    cidade VARCHAR(100)
);

CREATE TABLE produtos (
    id_produto INT PRIMARY KEY,
    nome_produto VARCHAR(100),
    preco DECIMAL(10,2),
    categoria VARCHAR(50)
);

CREATE TABLE pedidos (
    id_pedido INT PRIMARY KEY,
    id_cliente INT,
    data_pedido DATE,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE itens_pedido (
    id_item INT PRIMARY KEY,
    id_pedido INT,
    id_produto INT,
    quantidade INT,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

-- INSERIR DADOS

INSERT INTO clientes VALUES 
(1, 'Ana', 'ana@email.com', 'Campinas'),
(2, 'Bruno', 'bruno@email.com', 'São Paulo'),
(3, 'Carla', 'carla@email.com', 'Rio de Janeiro'),
(4, 'Daniel', 'daniel@email.com', 'Belo Horizonte'); 

INSERT INTO produtos VALUES 
(1, 'Notebook', 3000.00, 'Informatica'),
(2, 'Mouse', 100.00, 'Informatica'),
(3, 'Teclado', 200.00, 'Informatica'),
(4, 'Monitor', 1500.00, 'Eletronicos'),
(5, 'Fone', 250.00, 'Eletronicos'),
(6, 'Super TV', 5000.00, 'Eletronicos');

INSERT INTO pedidos VALUES 
(1, 1, '2026-04-01'),
(2, 2, '2026-04-02');

INSERT INTO itens_pedido VALUES 
(1, 1, 1, 2), 
(2, 1, 2, 1), 
(3, 2, 2, 3); 

-- CONSULTAS AVANÇADAS

-- 1. Clientes com gasto acima da média
SELECT 
    clientes.nome,
    SUM(itens_pedido.quantidade * produtos.preco) AS total_gasto
FROM clientes
JOIN pedidos ON clientes.id_cliente = pedidos.id_cliente
JOIN itens_pedido ON pedidos.id_pedido = itens_pedido.id_pedido
JOIN produtos ON itens_pedido.id_produto = produtos.id_produto
GROUP BY clientes.id_cliente
HAVING total_gasto > (
    SELECT AVG(total_cliente)
    FROM (
        SELECT 
            SUM(itens_pedido.quantidade * produtos.preco) AS total_cliente
        FROM clientes
        JOIN pedidos ON clientes.id_cliente = pedidos.id_cliente
        JOIN itens_pedido ON pedidos.id_pedido = itens_pedido.id_pedido
        JOIN produtos ON itens_pedido.id_produto = produtos.id_produto
        GROUP BY clientes.id_cliente
    ) AS media
);

-- 2. Produtos mais caros que todos da categoria "Informatica"
SELECT nome_produto, preco
FROM produtos
WHERE preco > ALL (
    SELECT preco 
    FROM produtos 
    WHERE categoria = 'Informatica'
);

-- 3. Clientes sem pedidos (NOT IN)
SELECT nome
FROM clientes
WHERE id_cliente NOT IN (
    SELECT id_cliente FROM pedidos
);

-- 4. Clientes sem pedidos (NOT EXISTS)
SELECT nome
FROM clientes c
WHERE NOT EXISTS (
    SELECT 1 
    FROM pedidos p
    WHERE p.id_cliente = c.id_cliente
);