*Instalar:
    - pip check
    - pip install python-dotenv

*Importante*
    Debe tener mysqldump
        checar con "mysqldump --version"
    Clonar *.env* y cambiar los datos de MySQL

-- -----------------------
-- Orden de ejecución:
-- -----------------------
*MySQL:
    1. Ejecutar 1_database.sql
    2. Ejecutar procedures
        2.1. 2_incremental_1.sql
        2.2. 2_incremental_2.sql
        2.3. 2_incremental_3.sql
    3. Ejecutar 4_users.sql
    4. Ejecutar 3_test.sql (opcional para validación)

*Python:
    1. Ejecutar reset.py 
        (es pa resetear la base de datos)
    2. Ejecutar run.py 
        (para las migraciones, ejecuta todos los otros archivos en orden)

*Backups:
    1. ejecutar full_backup.py
        (crea una carpeta /backups, y respando_comp.sql)

    No esta automatizado, si se quiere solo agregar a Programador de tareas de Windows

-- -----------------------
-- Tests:
-- -----------------------
*/tests_acid:
    - test_deadlock.py
    - 