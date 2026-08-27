# Proyecto Construcción de Software — construcción por versiones (edición SIN Docker)

Proyecto de curso (USB Medellín). Aquí NO se descarga un sistema terminado:
**se construye un sistema real por versiones en C# / ASP.NET Core**, guiado
por especificaciones. El repositorio siempre contiene la **versión en
curso, funcionando** — usted la ejecuta, la estudia y luego la
**reconstruye desde cero** en su propio proyecto.

> 🐳 **¿Y esta edición qué es?** El gemelo de
> [proyecto_construccion_de_software1](https://github.com/ccastro2050/proyecto_construccion_de_software1)
> para quienes **no pueden usar Docker** en su equipo: la MISMA API, el
> MISMO spec kit y los MISMOS criterios — pero con **PostgreSQL instalado
> en Windows** y la API corriendo con `dotnet watch run`. Lo que allá hace
> el compose, aquí lo hacen `db\crear_bd.ps1` y el SDK de .NET.

---

## 1. Cómo le trabaja el estudiante (léame primero)

### Qué necesita instalado (una sola vez)

| Herramienta | Para qué |
|---|---|
| **Git** | Clonar el repositorio y traer versiones nuevas |
| **PostgreSQL** (instalador oficial, [postgresql.org](https://www.postgresql.org/download/windows/)) | La base de datos — corre como servicio en el puerto 5432 (superusuario `postgres`, clave `postgres`) y trae **pgAdmin 4** |
| **SDK de .NET 10** ([dotnet.microsoft.com](https://dotnet.microsoft.com/download)) | Compila y corre la API (viene con Visual Studio, o instálelo solo para VS Code) |
| **VS Code** | El editor — y su terminal integrada (*Terminal → New Terminal*) |

> ⚠️ Al instalar PostgreSQL deje la clave del superusuario en `postgres`
> (la estándar de las salas). Si usó otra, edite la línea `PGPASSWORD` de
> `db\crear_bd.ps1`.

### Primera vez: cargar y EJECUTAR la versión

En la terminal integrada de VS Code (*Terminal → New Terminal*, PowerShell):

```powershell
git clone https://github.com/ccastro2050/proyecto_construccion_de_software1_sindocker.git
cd proyecto_construccion_de_software1_sindocker

# 1. Crear la base de datos en el PostgreSQL instalado (una sola vez):
.\db\crear_bd.ps1

# 2. Arrancar la API (queda corriendo; se detiene con Ctrl+C):
cd api_facturas
dotnet watch run
```

Quedan corriendo la base de datos (bdfacturas completa) y la API:

| Qué | Dónde |
|---|---|
| **API Facturas** — diagnóstico | http://localhost:8042/ |
| **Swagger** (documentación interactiva: ver y probar los endpoints) | http://localhost:8042/swagger |
| Listar productos | http://localhost:8042/api/producto |
| PostgreSQL (para pgAdmin/SQLTools) | `localhost:5432` · `construccion`/`Construccion123!` |

Pruebe la joya didáctica de la v1: PUT con solo `{"stock": 99}` → 422; el
mismo body en PATCH → 200. Esa diferencia es parte de lo que enseña la
versión (contratos exactos en el spec kit).

> ℹ️ La API usa el puerto 8042, fijado en
> `api_facturas/Properties/launchSettings.json`. La BD usa el 5432 del
> servicio de PostgreSQL.

### Los días siguientes (volver a encender)

PostgreSQL es un servicio de Windows: arranca solo con la máquina. Solo
falta la API:

```powershell
cd api_facturas
dotnet watch run
```

### Cuando hay cambios

| Qué cambió | Qué hacer |
|---|---|
| **Usted edita un `.cs`** | **Nada** — `dotnet watch` recompila y reinicia la API sola (espere unos segundos) |
| **El profesor publicó una versión nueva** | `git pull` y volver a arrancar (`dotnet watch run`) |
| **Quiere resetear la BD** a sus datos originales | En pgAdmin: `DROP DATABASE bdfacturas_postgres_local;` (o con psql) y re-correr `.\db\crear_bd.ps1` (⚠️ borra los datos) |
| **Apagar todo** | `Ctrl+C` en la terminal de la API (PostgreSQL puede seguir: es un servicio) |

### Y ahora, SU trabajo: reconstruirla desde cero

Ejecutar la versión del repo es solo el punto de partida. Lo que se evalúa
es **reconstruirla usted mismo, en una carpeta propia (fuera del clon)**,
siguiendo las especificaciones — con o sin ayuda de IA:

> 🤖 ¿Va a trabajar con IA? Siga la **[Guía para construir la versión con
> IA](docs/spec_kit/versiones/v1_producto_postgres/GUIA_IA1.md)** — cubre los dos caminos con su prompt exacto listo
> para copiar: **chat web** (Gemini, DeepSeek, ChatGPT: qué archivos
> subirle) e **IDE agéntico** (Antigravity, Cursor, Claude Code: cómo
> supervisar al agente). Para la BD de SU reconstrucción:
> `.\db\crear_bd.ps1 -NombreBd bdfacturas_mi_v1`.

### Conceptos resumidos (los que acaba de usar)

| Concepto | En una frase |
|---|---|
| **Clonar** | Descargar el repositorio con su historial; `git pull` trae lo nuevo |
| **Servicio de Windows** | PostgreSQL corre de fondo y arranca solo con la máquina — por eso "los días siguientes" solo encienden la API |
| **crear_bd.ps1** | El "inicializador" de esta edición: crea el usuario del curso, la BD y ejecuta el script — idempotente (correrlo dos veces no daña nada) |
| **dotnet watch** | El vigilante del código: guardar un `.cs` recompila y reinicia la API sola |
| **Spec kit** | Los documentos que dicen QUÉ/CÓMO/EN QUÉ ORDEN — la fuente de verdad |
| **Versión / tag** | Un incremento cerrado y verificado (`v1`, `v2`, …): se avanza solo en verde |

> Detalle del entorno local (el servicio, dónde viven los datos, el
> reset): [docs/ENTORNO_LOCAL.md](docs/ENTORNO_LOCAL.md).

---

## 2. Estructura del repositorio

Qué es cada carpeta y cada archivo, y para qué sirve:

```
proyecto_construccion_de_software1_sindocker/
├── db/
│   ├── crear_bd.ps1             # El inicializador SIN Docker: usuario del curso +
│   │                            #   BD + ejecuta el script (idempotente)
│   └── bdfacturas_postgres.sql  # Crea bdfacturas COMPLETA (12 tablas, triggers,
│                                #   SPs, datos) — lo ejecuta crear_bd.ps1
│
├── postman/                     # La colección de Postman lista para importar:
│                                #   los 13 endpoints en orden didáctico (alternativa a Swagger)
│
├── api_facturas/                # LA API DE LA v1 — C#/ASP.NET Core (puerto 8042)
│   ├── ApiFacturas.csproj       # El proyecto .NET (paquetes: Npgsql, Dapper y Swashbuckle)
│   ├── Program.cs               # Punto de entrada: ENSAMBLADOR (DI) + 422 + rutas
│   ├── appsettings.json         # Cadena de conexión (localhost:5432, usuario del curso)
│   ├── Properties/launchSettings.json  # El puerto 8042, fijado
│   ├── Controllers/             # Capa 1 — HTTP: atributos de verbo y try/catch → códigos
│   ├── Modelos/                 # Los MODELOS = las clases ENTIDAD (v1: Producto)
│   ├── Peticiones/              # Los body por verbo (Crear/Reemplazo/Actualizar):
│   │                            #   sus anotaciones validan la entrada → 422
│   ├── Servicios/               # Capa 2 — negocio: interfaz + reglas
│   ├── Repositorios/            # Capa 3 — datos: interfaz + Dapper (SQL a mano)
│   ├── Excepciones/             # NoEncontradoExcepcion (el servicio la lanza → 404)
│   └── pruebas/                 # Proyecto de consola: el servicio con repositorio
│                                #   FALSO en memoria (criterio 6, corre sin BD)
├── docs/
│   ├── spec_kit/                # LAS ESPECIFICACIONES: constitución permanente +
│   │                            #   una carpeta de specs por versión (v1, v2, …)
│   │                            #   + la GUIA_IA de ESA versión
│   ├── ENTORNO_LOCAL.md         # El entorno SIN Docker: servicio, datos, reset
│   ├── FLUJO_DE_UNA_PETICION.md # Dónde "está" el GET, dónde se captura el POST
│   ├── TUTORIAL_VSCODE_SQLTOOLS.md # Administrar la BD desde VS Code (SQLTools)
│   ├── PARADIGMA_POO.md         # Material conceptual: POO, SOLID+capas, ACID
│   ├── SOLID_CAPAS_PATRONES.md  #   y SDD (un .md por tema)
│   ├── PRINCIPIOS_ACID.md       #
│   └── SDD_SPECKIT.md           #
│
├── .gitignore / .gitattributes  # Higiene del repo (bin/, obj/, .session.sql; .sh con LF)
└── README.md                    # Este archivo
```

La regla de lectura: **la BD vive en el PostgreSQL de su máquina** (la
crea `db\crear_bd.ps1`), la API vive en `api_facturas/` (una carpeta por
capa), y **todo lo que explica** vive en `docs/`.

## 3. La ruta de versiones

```
v1  api_facturas (C#/ASP.NET Core): CRUD de producto, solo PostgreSQL   ← USTED ESTÁ AQUÍ (cerrada: tag v1)
v2  persona (el molde replicado) + factura maestro-detalle con SPs
v3  el RESTO de las entidades: toda la bdfacturas cubierta con
    UN motor (usuario con BCrypt, tablas puente)
v4  segundo motor (SQL Server) — nace la fábrica de repositorios
v5  tercer motor (MariaDB)
v6  frontend FLASK (Jinja2): CRUD de las 12 entidades + login + facturación
```

La regla del juego: la **constitución** es permanente, cada versión tiene
su propia spec, y una versión está TERMINADA solo cuando pasa sus criterios
de aceptación (commit + tag). Mapa completo:
[docs/spec_kit/versiones/0_mapa_versiones.md](docs/spec_kit/versiones/0_mapa_versiones.md).

> ℹ️ Nota honesta de esta edición: las versiones de MÁS MOTORES (v4 SQL
> Server, v5 MariaDB) piden instalar cada motor en Windows — llegado ese
> punto, el gemelo CON Docker se vuelve la vía cómoda. Hasta v3 (toda la
> BD con PostgreSQL) esta edición va perfecta.

## 4. Las especificaciones de la versión actual (v1)

| Documento | Contenido |
|---|---|
| [1_constitution.md](docs/spec_kit/1_constitution.md) | Las reglas permanentes del proyecto |
| [2_spec.md](docs/spec_kit/versiones/v1_producto_postgres/2_spec.md) | QUÉ construir y los criterios de aceptación |
| [3_plan.md](docs/spec_kit/versiones/v1_producto_postgres/3_plan.md) | CÓMO: stack, estructura y diseño de las capas |
| [4_research.md](docs/spec_kit/versiones/v1_producto_postgres/4_research.md) | Decisiones y alternativas (el porqué) |
| [5_data_model.md](docs/spec_kit/versiones/v1_producto_postgres/5_data_model.md) | La BD completa (dada) y la tabla producto |
| [6_contracts.md](docs/spec_kit/versiones/v1_producto_postgres/6_contracts.md) | Los 7 endpoints con formatos exactos |
| [7_quickstart.md](docs/spec_kit/versiones/v1_producto_postgres/7_quickstart.md) | Arranque y smoke test |
| [8_tasks.md](docs/spec_kit/versiones/v1_producto_postgres/8_tasks.md) | Orden de construcción por fases verificables |

## 5. Material conceptual del curso

| Documento | Qué cubre |
|---|---|
| [El flujo de una petición](docs/FLUJO_DE_UNA_PETICION.md) | **Léalo primero:** dónde está el GET, dónde se captura el POST, y el viaje completo por las capas |
| [Colección de Postman](postman/README.md) | Los 13 endpoints de la v1 listos para importar y probar con clics — incluida la pareja PUT=422 vs PATCH=200 |
| [SDD y Spec Kit](docs/SDD_SPECKIT.md) | La metodología con la que se trabaja este curso: la spec manda sobre el código |
| [Calidad de las pruebas](docs/CALIDAD_DE_PRUEBAS.md) | Cobertura, la métrica CRAP y mutation testing: cómo saber si sus pruebas de verdad protegen — y por qué hoy es reto opcional, no alcance del proyecto |
| [Programación asincrónica](docs/PROGRAMACION_ASINCRONICA.md) | Qué resuelve el async/await en la web, qué se daña sin él (con diagramas), y cómo se ve en el código de este proyecto |
| [El paradigma P.O.O. en C#](docs/PARADIGMA_POO.md) | Qué es un paradigma, los 4 pilares, y las propiedades e interfaces de C# |
| [SOLID, capas y patrones de diseño](docs/SOLID_CAPAS_PATRONES.md) | Los 5 principios y las capas — y en qué versión se demuestra cada uno |
| [Principios ACID](docs/PRINCIPIOS_ACID.md) | Las 4 garantías transaccionales, por qué una facturación las exige |
| [El entorno local](docs/ENTORNO_LOCAL.md) | Esta edición sin Docker: el servicio de PostgreSQL, dónde viven los datos y cómo se resetea |

---

*Proyecto Construcción de Software · USB Medellín · Base de datos bdfacturas
(facturación + RBAC) · Edición sin Docker.*
