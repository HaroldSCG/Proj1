# Guía de Exposición: Proceso de Migración de Datos con Python

Este documento detalla los puntos clave a exponer referentes a la fase de carga y migración de datos. Su lectura asegurará que puedas explicar claramente cómo se abordó la automatización, la integridad de los datos y el manejo de flujos desde `Python`.

## 1. Arquitectura de la Migración
El sistema de migración fue totalmente orquestado con **Python**, aprovechando sus librerías de manejo de archivos y conexión directa al motor SQL.

**Estructura del proceso (Ubicada en `/python`):**
- **`/data/`**: Los archivos CSV crudos originales.
- **`reset.py`**: Este script se creó para iniciar desde un lienzo en blanco. Limpia los registros de la base de datos previniendo fallos por colisión de Llaves Primarias durante múltiples pruebas.
- **`run.py`**: Es el orquestador principal. Una vez iniciado, este archivo manda a llamar de manera automatizada a los demás "submódulos" de carga.
- **`1_sucursales.py` a `6_transacciones.py`**: Submódulos encargados de procesar la lógica de limpieza e inserción, separados por entidad para mayor legibilidad y mantenibilidad.

## 2. Configuración y Seguridad (Uso de `.env`)
*👉 **Punto clave:** Al mencionar esto, se demuestra dominio en buenas prácticas de seguridad informática.*

Aclarar que, a nivel código, las contraseñas de las bases de datos no se colocaron en texto plano ("hardcode"). Se utilizó la biblioteca `python-dotenv` permitiendo leer de un archivo oculto `.env` el Usuario, Contraseña y Host. Cualquier usuario (o evaluador) solo clona o renombra el archivo `.env.example` y el proyecto funcionará en sus máquinas sin re-escribir lógica de Python.

## 3. Lógica de Limpieza (Proceso ETL)
*👉 **Punto clave:** Explica cómo se lidió con datos redundantes.*

El problema pedía quitar anomalías e inconsistencias de datos crudos. Durante la ejecución de los scripts de Python se resolvió creando un proceso **ETL** *(Extract, Transform, Load)*:
1. **Extracción:** Se lee la metadata original empleando sentencias de extracción desde las carpetas CSV.
2. **Transformación (Limpieza):** Se validan formatos de fecha incompatibles, strings nulos o mal formateados y se hace un mapeo de datos que se adhiera al diseño 3FN (Tercera Forma Normal).
3. **Carga:** Se inserta nativamente en MySQL utilizando cursores.

## 4. Integridad Referencial y el Orden Estricto de Carga
*👉 **Punto clave:** Destacar por qué los scripts tienen números (1, 2, 3...).*

La inserción debe seguir reglas rígidas para evitar vulnerar las **Llaves Foráneas (Foreign Keys)**. En Python se estructuró la ejecución en este orden:
1. Se levantan **Sucursales**, porque no dependen de nadie.
2. Se procesan **Clientes y Empleados**, buscando en el diccionario sus respectvos Cargos y Sucursales.
3. Se cargan las **Cuentas**, que lógicamente no pueden existir sin referenciar a un Cliente y a una Sucursal.
4. Al final, se levantan **Transacciones y Transferencias**, que dependen absolutamente de todo el organigrama superior.

## 5. Prevención de Errores Transaccionales (Rollbacks en Python)
*👉 **Punto clave:** Este es un punto altísimo dentro de la rúbrica sobre manejo de transacciones seguras.*

Al migrar información, si ocurre una interrupción del proceso insertando en la fila mil, la base de datos quedaría a medias o "corrupta". 
En nuestros scripts de migración empleamos controles lógicos (`try-except`). Las inserciones a nivel Python se realizan aglutinadas; se envía la orden final con `connection.commit()` de manera atómica, única y exclusivamente si todas las líneas se procesaron con éxito. En caso de inconsistencia, se dispara de inmediato un `connection.rollback()`, deshaciendo virtualmente las acciones y devolviendo el sistema al inicio seguro antes de arrancar.
