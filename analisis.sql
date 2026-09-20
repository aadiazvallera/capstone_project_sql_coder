-- ============================================================================
-- PROYECTO CAPSTONE: ANÁLISIS EXPLORATORIO DE DATOS Y LIMPIEZA
-- Temática: Supermercado Gourmet
-- ============================================================================

-- ----------------------------------------------------------------------------
-- FASE 1: LIMPIEZA DE DATOS Y GESTIÓN DE VALORES NULOS
-- Identificamos montos nulos derivados de fallas de registro y calculamos su valor
-- esperado mediante COALESCE combinando la cantidad pedida con el precio de catálogo.
-- ----------------------------------------------------------------------------

-- Creamos una vista limpia del dataset para asegurar la integridad analítica.
CREATE OR REPLACE VIEW vista_pedidos_limpios AS
SELECT 
    p.pedido_id,
    p.cliente_id,
    c.nombre AS cliente_nombre,
    c.membresia,
    p.producto_id,
    pr.nombre_producto,
    pr.categoria,
    p.fecha_pedido,
    p.cantidad,
    -- Aplicamos COALESCE: Si el monto_total es NULL, lo recalculamos multiplicando cantidad * precio
    COALESCE(p.monto_total, p.cantidad * pr.precio) AS monto_total_calculado
FROM pedidos p
INNER JOIN clientes c ON p.cliente_id = c.cliente_id
INNER JOIN productos pr ON p.producto_id = pr.producto_id;

-- ----------------------------------------------------------------------------
-- FASE 2: CONSULTAS DE ANÁLISIS DE NEGOCIO
-- ----------------------------------------------------------------------------

-- Consulta 1: Top 5 Clientes por Gasto Total
-- Objetivo: Identificar el segmento de alto valor (VIP) para focalizar ofertas de fidelización.
SELECT 
    cliente_nombre,
    membresia,
    COUNT(pedido_id) AS total_pedidos,
    SUM(monto_total_calculado) AS gasto_total
FROM vista_pedidos_limpios
GROUP BY cliente_nombre, membresia
ORDER BY gasto_total DESC
LIMIT 5;


-- Consulta 2: Ventas Totales por Mes
-- Objetivo: Analizar el comportamiento temporal de los ingresos para gestionar stock y promociones.
SELECT 
    TO_CHAR(fecha_pedido, 'YYYY-MM') AS mes,
    COUNT(pedido_id) AS cantidad_pedidos,
    SUM(monto_total_calculado) AS ingresos_totales
FROM vista_pedidos_limpios
GROUP BY TO_CHAR(fecha_pedido, 'YYYY-MM')
ORDER BY mes ASC;


-- Consulta 3: 3 Productos Menos Vendidos
-- Objetivo: Detectar artículos con baja rotación en góndola para evaluar promociones o descontinuación.
SELECT 
    pr.nombre_producto,
    pr.categoria,
    COALESCE(SUM(v.cantidad), 0) AS unidades_vendidas
FROM productos pr
LEFT JOIN vista_pedidos_limpios v ON pr.producto_id = v.producto_id
GROUP BY pr.producto_id, pr.nombre_producto, pr.categoria
ORDER BY unidades_vendidas ASC, pr.nombre_producto ASC
LIMIT 3;


-- Consulta 4: Ranking de Pedidos por Categoría de Producto
-- Objetivo: Determinar cuáles son las ventas individuales de mayor valor dentro de cada categoría.
WITH pedidos_rankeados AS (
    SELECT 
        pedido_id,
        nombre_producto,
        categoria,
        monto_total_calculado,
        RANK() OVER (
            PARTITION BY categoria 
            ORDER BY monto_total_calculado DESC
        ) AS ranking_en_categoria
    FROM vista_pedidos_limpios
)
SELECT * 
FROM pedidos_rankeados
WHERE ranking_en_categoria <= 3
ORDER BY categoria, ranking_en_categoria;