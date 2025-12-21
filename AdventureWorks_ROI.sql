--Se imprimen los primeros reglones de las tablas para explorar los datos
SELECT *
FROM tventas_2017
LIMIT 10 

--Se unen tablas y se reemplazan valores nulos
SELECT 
COALESCE(p.precio_producto,0) AS precio_producto,
COALESCE(p.costo_producto,0) AS costo_producto,
COALESCE(v.cantidad_pedido,0) AS cantidad_pedido,
    v.numero_pedido,
    v.clave_producto,
    v.clave_territorio,
    p.nombre_producto,
    pc.clave_categoria,
    t.pais,
    t.continente
FROM ventas_2017 AS v
LEFT JOIN productos AS p
    ON p.clave_producto = v.clave_producto
LEFT JOIN productos_categorias AS pc
    ON p.clave_subcategoria = pc.clave_subcategoria
LEFT JOIN territorios AS t 
    ON v.clave_territorio = t.clave_territorio

--Se calculan nuevas columnada para ingreso_total y costo_total
SELECT
    v.numero_pedido,
    v.clave_producto,
    p.nombre_producto,
    pc.clave_categoria,
    COALESCE(p.precio_producto, 0)  AS precio_producto,
    COALESCE(v.cantidad_pedido, 0)  AS cantidad_pedido,
    COALESCE(p.costo_producto, 0)   AS costo_producto,
    t.pais,
    t.continente,
    v.clave_territorio,
    p.precio_producto*v.cantidad_pedido AS ingreso_total,
    p.costo_producto*v.cantidad_pedido AS costo_total
FROM ventas_2017 AS v
JOIN productos AS p
  ON v.clave_producto = p.clave_producto
LEFT JOIN productos_categorias AS pc
  ON p.clave_subcategoria = pc.clave_subcategoria
LEFT JOIN territorios AS t
  ON v.clave_territorio = t.clave_territorio

--Se selecciona y agrupa por país y clave de territorio
  SELECT 
    vc.pais,
    vc.clave_territorio,
    SUM(ingreso_total)::INTEGER AS ingresos,
    SUM(costo_total) ::INTEGER AS costos
FROM ventas_clean AS vc 
GROUP BY pais, clave_territorio 
ORDER BY ingresos DESC

--Se suma el costo por campaña
SELECT
    v.pais,
    v.clave_territorio,
    SUM(v.ingreso_total)::integer AS ingresos,
    SUM(v.costo_total)::integer  AS costos,
    COALESCE(SUM(c.costo_campana::integer),0) AS costo_campana
FROM ventas_clean AS v
LEFT JOIN campanas AS c
  ON v.clave_territorio = c.clave_territorio::integer
GROUP BY
    v.pais,
    v.clave_territorio
ORDER BY
    ingresos DESC

--Se calcula beneficio bruto, margen y ROI
SELECT
    p.pais,
    p.clave_territorio,
    SUM(p.ingresos)::integer AS ingresos,
    SUM(p.costos)::integer AS costos,
    COALESCE(SUM(c.costo_campana), 0)::integer AS costo_campana,
    (SUM(p.ingresos)- SUM(p.costos))::integer AS beneficio_bruto,
    (SUM(p.ingresos) - SUM(p.costos))*100/NULLIF(SUM(p.ingresos),0) AS margen_pct,
    (SUM(p.ingresos) - SUM(p.costos))*100/NULLIF(COALESCE(SUM(c.costo_campana), 0),0) AS roi_pct
FROM pais_ingreso_costo AS p
LEFT JOIN pais_campanas AS c
  ON p.clave_territorio = c.clave_territorio
GROUP BY
    p.pais,
    p.clave_territorio
ORDER BY
    p.clave_territorio, ingresos, costos

--Se validan resultados y QA
SELECT 
    SUM(CASE WHEN v.numero_pedido IS NULL THEN 1 ELSE 0 END) AS numero_pedido,
    SUM(CASE WHEN v.clave_producto IS NULL THEN 1 ELSE 0 END) AS clave_producto,
    SUM(CASE WHEN v.clave_territorio IS NULL THEN 1 ELSE 0 END) AS clave_territorio
FROM ventas_2017 AS v


