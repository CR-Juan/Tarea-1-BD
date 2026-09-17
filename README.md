# API REST para AdventureWorks con SQL Server y Node.js
 
### Nombre y carné:
- Juan Mora — 2024126028

### Estado del proyecto:
Completado — API REST funcional con operaciones CRUD y consultas mediante Stored Procedures.
 
### Enlace del video:
https://youtu.be/hNyud_kWw7w
 
---
 
## 1. Introducción de la actividad
 
Este proyecto implementa una API REST desarrollada en Node.js con Express, que se comunica con una base de datos SQL Server (AdventureWorks completa) a través de Stored Procedures. El objetivo es exponer operaciones CRUD (Crear, Leer, Actualizar, Borrar) sobre la tabla `Production.Location`, además de dos consultas adicionales: una selección simple sobre una tabla y una consulta con JOIN entre dos tablas.
 
La arquitectura utiliza una comunicación descentralizada entre la aplicación (API) y la base de datos, corriendo esta última en un contenedor Docker con SQL Server sobre Linux, dentro de un entorno WSL2 (Ubuntu) sobre Windows.
 
**Stack utilizado:**
- Sistema operativo: WSL2 (Ubuntu) sobre Windows
- Motor de base de datos: SQL Server 2025, corriendo en un contenedor Docker
- Base de datos: AdventureWorks
- Backend: Node.js + Express + librería `mssql`
## 2. Instalación de los requerimientos paso a paso
 
### 2.1. Habilitar WSL2
 
```bash
wsl --install -d Ubuntu
```
 
Si aparece un error relacionado con virtualización, verificar que la opción de virtualización (Intel VT-x / AMD-V) esté activa en el BIOS, y habilitar las siguientes características de Windows desde PowerShell como administrador:
 
```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```
 
Reiniciar la máquina y confirmar la instalación de Ubuntu.
 
### 2.2. Instalar Docker Desktop
 
Descargar e instalar Docker Desktop desde [docker.com](https://www.docker.com/products/docker-desktop/), asegurando que quede marcada la opción **"Use WSL 2 based engine"**. Luego, en Docker Desktop, ir a **Settings > Resources > WSL Integration** y activar la integración con la distribución Ubuntu.
 
Verificar desde la terminal de Ubuntu:
 
```bash
docker --version
docker ps
```
 
### 2.3. Instalar Node.js (dentro de WSL)
 
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install --lts
node -v
npm -v
```
 
## 3. Instalación de los programas y configuración de los servicios
 
### 3.1. Levantar el contenedor de SQL Server
 
```bash
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=<TU_PASSWORD>" \
  -p 1433:1433 --name sqlserver --hostname sqlserver \
  -d mcr.microsoft.com/mssql/server:2025-latest
```
 
> Se utilizó la imagen `2025-latest` porque el backup de AdventureWorks disponible fue generado con una versión de SQL Server más reciente que 2022, incompatible con motores anteriores.
 
Verificar que el contenedor esté corriendo:
 
```bash
docker ps
```
 
### 3.2. Restaurar la base de datos AdventureWorks
 
Copiar el archivo `.bak` dentro del contenedor:
 
```bash
docker cp AdventureWorks2025.bak sqlserver:/var/opt/mssql/data/AdventureWorks2025.bak
```
 
Consultar los nombres lógicos del backup:
 
```bash
docker exec -it sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P '<TU_PASSWORD>' -C -Q \
"RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/data/AdventureWorks2025.bak'"
```
 
Restaurar la base indicando la ubicación física dentro del contenedor:
 
```bash
docker exec -it sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P '<TU_PASSWORD>' -C -Q \
"RESTORE DATABASE AdventureWorks2025 FROM DISK = '/var/opt/mssql/data/AdventureWorks2025.bak' WITH MOVE 'AdventureWorks' TO '/var/opt/mssql/data/AdventureWorks2025.mdf', MOVE 'AdventureWorks_log' TO '/var/opt/mssql/data/AdventureWorks2025_log.ldf'"
```
 
### 3.3. Crear los Stored Procedures
 
Ejecutar el script `sql/stored_procedures.sql` contra la base `AdventureWorks2025`, usando sqlcmd o la extensión **SQL Server (mssql)** de VS Code.
 
### 3.4. Instalar dependencias del proyecto Node.js
 
Dentro de la carpeta del proyecto:
 
```bash
npm install
```
 
Esto instala `express` y `mssql`, ya declaradas en `package.json`.
 
### 3.5. Configurar la conexión
 
En `server.js`, ajustar el objeto `dbConfig` con las credenciales del contenedor:
 
```javascript
const dbConfig = {
    user: 'sa',
    password: '<TU_PASSWORD>',
    server: 'localhost',
    database: 'AdventureWorks2025',
    options: {
        encrypt: false,
        trustServerCertificate: true
    }
};
```
 
### 3.6. Levantar la API
 
```bash
node server.js
```
 
La API queda disponible en `http://localhost:8081`.
 
## 4. Endpoints disponibles
 
| Método | Endpoint                | Descripción                                                      |
|--------|---------------------------|-------------------------------------------------------------------|
| GET    | `/locations`               | Devuelve todas las ubicaciones (consulta simple)                  |
| GET    | `/locations/:id`           | Devuelve una ubicación específica por ID                          |
| GET    | `/locations/:id/stock`     | Devuelve el inventario de productos por ubicación (JOIN con `ProductInventory`) |
| POST   | `/locations`                | Crea una nueva ubicación                                          |
| PUT    | `/locations/:id`            | Actualiza una ubicación existente                                 |
| DELETE | `/locations/:id`            | Elimina una ubicación                                              |
 
## 5. Datos de prueba
 
### GET /locations
 
```
http://localhost:8081/locations
```

<img width="561" height="858" alt="image" src="https://github.com/user-attachments/assets/a6d16521-3e67-4f31-b192-cfccb562695e" />

Respuesta esperada (ejemplo):
 
```json
[
  {
    "LocationID": 1,
    "Name": "Tool Crib",
    "CostRate": 0,
    "Availability": 0,
    "ModifiedDate": "2019-04-30T00:00:00.000Z"
  }
]
```
 
### GET /locations/:id
 
```
http://localhost:8081/locations/60
```
<img width="582" height="682" alt="image" src="https://github.com/user-attachments/assets/41506916-90dc-414f-a18a-10749584ab57" />

 
### GET /locations/:id/stock
 
```
http://localhost:8081/locations/1/stock
```
<img width="530" height="911" alt="image" src="https://github.com/user-attachments/assets/7973eb61-314c-4069-b906-5cb677859f66" />

 
### POST /locations

<img width="783" height="316" alt="image" src="https://github.com/user-attachments/assets/35248e8f-d0dc-43c6-a48c-59263f2e79ac" />

<img width="419" height="146" alt="image" src="https://github.com/user-attachments/assets/66db8811-5806-462d-82f4-8f976b1ae84a" />

 
Body (JSON):
 
```json
{
  "name": "Bodega Norte",
  "costRate": 8.5,
  "availability": 80.0,
  "modifiedDate": "2026-09-14"
}
```
 
### PUT /locations/:id
 
```
http://localhost:8081/locations/62
```

<img width="704" height="327" alt="image" src="https://github.com/user-attachments/assets/7db9155e-0e33-4517-8ae9-f9d411527036" />

 
Body (JSON):
 
```json
{
  "name": "Almacén Principal Actualizado",
  "costRate": 12.00,
  "availability": 90.00,
  "modifiedDate": "2026-09-14"
}
```
 
### DELETE /locations/:id
 
```
http://localhost:8081/locations/62
```

<img width="573" height="246" alt="image" src="https://github.com/user-attachments/assets/5d3083df-8d00-4c7b-95db-e207b28dbc9c" />

 
## 6. Estructura del proyecto
 
```
tarea1-api-bd2/
├── node_modules/
├── sql/
│   └── stored_procedures.sql
├── server.js
├── package.json
├── package-lock.json
└── README.md
```
