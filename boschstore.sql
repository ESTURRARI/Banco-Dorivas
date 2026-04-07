-- =========================
-- CRIAR BANCO (só cria se não existir)
-- =========================
CREATE DATABASE IF NOT EXISTS boschstore;
USE boschstore;

-- =========================
-- LIMPAR TABELAS (evita erro)
-- =========================
DROP TABLE IF EXISTS itens_pedido;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS produtos;
DROP TABLE IF EXISTS clientes;

-- =========================
-- CRIAR TABELAS
-- =========================

CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY,
    nome VARCHAR(100),
    email VARCHAR(100),
    cidade VARCHAR(100)
);

CREATE TABLE produtos (
    id_produto INT PRIMARY KEY,
    nome_produto VARCHAR(100),
    preco DECIMAL(10,2)
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

-- =========================
-- INSERIR DADOS (AGORA COMPLETO)
-- =========================

INSERT INTO clientes VALUES 
(1, 'Ana', 'ana@email.com', 'Campinas'),
(2, 'Bruno', 'bruno@email.com', 'São Paulo'),
(3, 'Carla', 'carla@email.com', 'Rio de Janeiro');

INSERT INTO produtos VALUES 
(1, 'Notebook', 3000.00),
(2, 'Mouse', 100.00),
(3, 'Teclado', 200.00),
(4, 'Monitor', 1500.00); -- produto que NÃO será vendido

INSERT INTO pedidos VALUES 
(1, 1, '2026-04-01'),
(2, 2, '2026-04-02');

INSERT INTO itens_pedido VALUES 
(1, 1, 1, 2), -- Ana comprou 2 notebooks
(2, 1, 2, 1), -- Ana comprou 1 mouse
(3, 2, 2, 3); -- Bruno comprou 3 mouses

-- =========================
-- RELATÓRIOS
-- =========================

-- 1. Clientes que fizeram pedidos
SELECT 
    clientes.nome,
    pedidos.id_pedido,
    pedidos.data_pedido
FROM clientes
JOIN pedidos 
ON clientes.id_cliente = pedidos.id_cliente;

-- 2. Produtos comprados
SELECT 
    clientes.nome,
    produtos.nome_produto,
    itens_pedido.quantidade
FROM clientes
JOIN pedidos ON clientes.id_cliente = pedidos.id_cliente
JOIN itens_pedido ON pedidos.id_pedido = itens_pedido.id_pedido
JOIN produtos ON itens_pedido.id_produto = produtos.id_produto;

-- 3. Todos clientes e pedidos (mesmo sem compra)
SELECT 
    clientes.nome,
    pedidos.id_pedido
FROM clientes
LEFT JOIN pedidos 
ON clientes.id_cliente = pedidos.id_cliente;

-- 4. Clientes que nunca compraram
SELECT clientes.nome
FROM clientes
LEFT JOIN pedidos 
ON clientes.id_cliente = pedidos.id_cliente
WHERE pedidos.id_cliente IS NULL;

-- 5. Todos produtos e itens de pedido
SELECT 
    produtos.nome_produto,
    itens_pedido.id_item
FROM produtos
LEFT JOIN itens_pedido 
ON produtos.id_produto = itens_pedido.id_produto;

-- 6. Produtos nunca vendidos
SELECT produtos.nome_produto
FROM produtos
LEFT JOIN itens_pedido 
ON produtos.id_produto = itens_pedido.id_produto
WHERE itens_pedido.id_produto IS NULL;

-- 7. Todos clientes e todos pedidos (FULL JOIN simulado)
SELECT 
    clientes.nome,
    pedidos.id_pedido
FROM clientes
LEFT JOIN pedidos 
ON clientes.id_cliente = pedidos.id_cliente

UNION

SELECT 
    clientes.nome,
    pedidos.id_pedido
FROM clientes
RIGHT JOIN pedidos 
ON clientes.id_cliente = pedidos.id_cliente;

-- 8. Cliente + produto + quantidade + valor total
SELECT 
    clientes.nome,
    produtos.nome_produto,
    itens_pedido.quantidade,
    (itens_pedido.quantidade * produtos.preco) AS valor_total
FROM clientes
JOIN pedidos ON clientes.id_cliente = pedidos.id_cliente
JOIN itens_pedido ON pedidos.id_pedido = itens_pedido.id_pedido
JOIN produtos ON itens_pedido.id_produto = produtos.id_produto;

-- 9. Total gasto por cliente
SELECT 
    clientes.nome,
    SUM(itens_pedido.quantidade * produtos.preco) AS total_gasto
FROM clientes
JOIN pedidos ON clientes.id_cliente = pedidos.id_cliente
JOIN itens_pedido ON pedidos.id_pedido = itens_pedido.id_pedido
JOIN produtos ON itens_pedido.id_produto = produtos.id_produto
GROUP BY clientes.nome;

-- 10. Produto mais vendido
SELECT 
    produtos.nome_produto,
    SUM(itens_pedido.quantidade) AS total_vendido
FROM produtos
JOIN itens_pedido 
ON produtos.id_produto = itens_pedido.id_produto
GROUP BY produtos.nome_produto
ORDER BY total_vendido DESC
LIMIT 1;