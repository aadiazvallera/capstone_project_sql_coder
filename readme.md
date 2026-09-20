# Proyecto Capstone: Análisis Exploratorio de Datos (EDA) en PostgreSQL
**Comisión:** SQL
**Curso:** Diplomatura en Data Science
**Área de Dominio:** Retail & Supermercado Gourmet
**Motor de Base de Datos:** PostgreSQL  

---

## 1. Contexto y Problema de Negocio

Un supermercado boutique especializado en café de alta gama, vinos de cava y delicatessen requiere analizar su histórico de ventas para optimizar sus decisiones estratégicas y comerciales. 

A medida que el volumen de transacciones se incrementa, la gerencia enfrenta tres preguntas críticas de negocio:
1. **¿Quiénes son nuestros clientes de mayor valor (VIP) y qué tipo de membresía poseen?**
2. **¿Cómo evolucionan los ingresos mes a mes y cuáles son los períodos de mayor facturación?**
3. **¿Qué productos registran una rotación baja en góndola y podrían estar generando costos ineficientes de almacenamiento?**

Además, el sistema de facturación presentó fallos puntuales donde algunos registros no capturaron el campo 'monto_total'. El objetivo de este proyecto es estructurar el modelo relacional, realizar un proceso riguroso de **limpieza de datos** mediante PostgreSQL y extraer conclusiones con impacto comercial.

---

## 2. Estructura de la Base de Datos

El modelo relacional está compuesto por tres tablas vinculadas mediante llaves primarias ('PRIMARY KEY') y foráneas ('FOREIGN KEY'):

* **'clientes'**: Información demográfica del comprador, fecha de alta y categoría de membresía ('Standard', 'Gold', 'Black').
* **'productos'**: Catálogo de artículos disponibles, categoría analítica y precio unitario.
* **'pedidos'**: Registro de cada transacción individual, fecha/hora, cantidad y monto total pagado.

```
  +------------------+         +------------------+         +---------------------+
  |     CLIENTES     |         |     PEDIDOS      |         |      PRODUCTOS      |
  +------------------+         +------------------+         +---------------------+
  | PK cliente_id    | 1 ---- N| PK pedido_id     |N ---- 1 | PK producto_id      |
  |    nombre        |         | FK cliente_id    |         |    nombre_producto  |
  |    email         |         | FK producto_id   |         |    categoria        |
  |    fecha_registro|         |    fecha_pedido  |         |    precio           |
  |    membresia     |         |    cantidad      |         +---------------------+
  +------------------+         |    monto_total   |
                               +------------------+
```

---

## 3. Estrategia de Limpieza de Datos

Durante la auditoría inicial de los datos se detectaron valores nulos ('NULL') en la columna 'monto_total' de la tabla 'pedidos', originados por errores en la integración de la pasarela de pagos.

Para solventar esta inconsistencia sin descartar información relevante, se construyó la vista analítica 'vista_pedidos_limpios'. En ella se implementó la función **`COALESCE`**:

```sql
COALESCE(p.monto_total, p.cantidad * pr.precio) AS monto_total_calculado
```

* **Lógica:** Si 'monto_total' contiene un valor nulo, la consulta lo calcula automáticamente multiplicando la 'cantidad' comprada por el 'precio' unitario de catálogo del producto.

---

## 4. Hallazgos Principales e Insights de Negocio

A partir de la ejecución de las consultas analíticas en 'analisis.sql', se extraen los siguientes hallazgos estratégicos:

### A. Concentración de Ingresos y Segmento VIP (Top Clientes)
* **Hallazgo:** Sofía Martínez (Membresia *Black*) y Alejandro Díaz (Membresia *Gold*) encabezan el ranking de facturación, concentrando la mayor proporción del ingreso acumulado.
* **Recomendación de Negocio:** Implementar beneficios exclusivos para clientes con membresías *Black* y *Gold* (ej. catas privadas o prioridad en lotes limitados de vino), asegurando la retención de este segmento de alto valor.

### B. Comportamiento Temporal de las Ventas
* **Hallazgo:** Se observa una tendencia positiva sostenida en la facturación mensual entre enero y abril, impulsada por compras de mayor volumen unitario (como botellas de vino de alta gama y molinillos de café).
* **Recomendación de Negocio:** Fortalecer las promociones orientadas a la venta cruzada (cross-selling) durante los primeros días de cada mes para mantener el ritmo ascendente en la facturación.

### C. Rotación de Inventario y Productos Menos Vendidos
* **Hallazgo:** Artículos como el *Té Hebras Blend Orgánico* y el *Chocolate Amargo 70% Cacao* registran el menor volumen de rotación en unidades.
* **Recomendación de Negocio:** Crear promociones de empaquetado o "bundles" (por ejemplo: *Combo Cafetería & Té* o *Maridaje Vinos & Chocolates*) para incentivar la venta de productos con menor salida individual y evitar stock inmovilizado.

### D. Rendimiento por Categoría (Window Function)
* **Hallazgo:** Utilizando la función de ventana `RANK() OVER (PARTITION BY categoria ORDER BY monto_total DESC)`, se identificaron las transacciones de mayor impacto por departamento. La categoría *Cava & Vinos* lidera los tickets promedios más elevados del supermercado.

---

## 5. Instrucciones para la Ejecución del Código

### Requisitos Previos
* PostgreSQL (versión 13 o superior).
* Un cliente SQL como **pgAdmin 4**, DBeaver o la consola interactiva 'psql'.

### Pasos de Configuración y Despliegue

1. **Crear la Base de Datos:**
   Abre tu consola SQL y ejecuta:
   ```sql
   CREATE DATABASE capstone_project;
   ```

2. **Cargar la Estructura e Insertar Datos ('estructura.sql'):**
   Conéctate a la base de datos 'capstone_project' y ejecuta el contenido íntegro del archivo 'estructura.sql'. Esto creará las 3 tablas relacionales con sus restricciones de clave primaria/foránea e insertará el conjunto de datos de prueba.

3. **Ejecutar la Limpieza y las Consultas Analíticas ('analisis.sql'):**
   Ejecuta el archivo 'analisis.sql'. Este script creará la vista 'vista_pedidos_limpios' utilizando 'COALESCE' y responderá a todas las preguntas de negocio mediante agregaciones ('GROUP BY'), funciones de fecha y funciones de ventana ('RANK').

---

## 6. Estructura del Repositorio

El repositorio está organizado con los 3 archivos requeridos para el Proyecto Capstone:

```
├── estructura.sql   # Script de definición de tablas e inserción de datos
├── analisis.sql     # Script de limpieza y consultas analíticas comentadas
└── README.md        # Documentación ejecutiva del proyecto e interpretación de hallazgos
```
