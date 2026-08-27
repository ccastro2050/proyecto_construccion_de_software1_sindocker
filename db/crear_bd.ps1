# ==============================================================
# crear_bd.ps1 — crea la base de datos bdfacturas en el
# PostgreSQL instalado en Windows (SIN Docker).
#
# PostgreSQL, instalado con el instalador oficial, corre como
# SERVICIO de Windows (arranca solo con la máquina) en el puerto
# 5432, con el superusuario `postgres` (clave: postgres). Este
# script hace lo que en el gemelo con Docker hace el compose:
# crea el usuario del curso, crea la BD y ejecuta el script
# provisto db/bdfacturas_postgres.sql (las 12 tablas con sus
# triggers, procedimientos y datos).
#
# Es IDEMPOTENTE: correrlo mil veces no daña nada — si la BD ya
# existe, no hace nada.
#
# Uso (desde la raíz del proyecto):
#   .\db\crear_bd.ps1
#
# Para crear una BD con OTRO nombre (la de SU reconstrucción):
#   .\db\crear_bd.ps1 -NombreBd bdfacturas_mi_v1
#
# Si su PostgreSQL escucha en otro puerto:
#   .\db\crear_bd.ps1 -Puerto 5433
# ==============================================================

param(
    [string]$NombreBd = "bdfacturas_postgres_local",
    [int]$Puerto = 5432
)

# --- Encontrar psql (el instalador NO lo agrega al PATH) ---
$carpetaPg = "C:\Program Files\PostgreSQL"
if (-not (Test-Path $carpetaPg)) {
    Write-Host "[crear_bd] ERROR: no se encontró $carpetaPg"
    Write-Host "[crear_bd] ¿PostgreSQL está instalado (instalador oficial)?"
    exit 1
}
$version = Get-ChildItem $carpetaPg -Directory | Sort-Object { [int]$_.Name } -Descending | Select-Object -First 1
$psql = Join-Path $version.FullName "bin\psql.exe"
Write-Host "[crear_bd] Usando PostgreSQL $($version.Name) ($psql)"

# --- Credenciales del superusuario (la clave estándar de las salas) ---
$env:PGPASSWORD = "postgres"
# Los .sql del curso están en UTF-8; sin esto las tildes se dañan:
$env:PGCLIENTENCODING = "UTF8"

Write-Host "[crear_bd] Verificando que PostgreSQL responda en el puerto $Puerto..."
& $psql -h localhost -p $Puerto -U postgres -d postgres -c "SELECT 1" *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[crear_bd] ERROR: PostgreSQL no responde en localhost:$Puerto."
    Write-Host "[crear_bd] Verifique el servicio (services.msc → postgresql) y la clave."
    exit 1
}

Write-Host "[crear_bd] Asegurando el usuario del curso (construccion)..."
# La API NO se conecta como postgres: usa el usuario del curso, igual que
# en producción se usa un usuario con permisos limitados a SU base:
& $psql -h localhost -p $Puerto -U postgres -d postgres -c "DO `$`$ BEGIN IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'construccion') THEN CREATE ROLE construccion LOGIN PASSWORD 'Construccion123!'; END IF; END `$`$;"

Write-Host "[crear_bd] Verificando si la base de datos $NombreBd existe..."
$existe = & $psql -h localhost -p $Puerto -U postgres -d postgres -t -A -c "SELECT COUNT(*) FROM pg_database WHERE datname = '$NombreBd'"

if ("$existe".Trim() -eq "1") {
    Write-Host "[crear_bd] La base de datos $NombreBd ya existe. No se hace nada."
    exit 0
}

Write-Host "[crear_bd] Creando la base de datos $NombreBd (dueño: construccion)..."
& $psql -h localhost -p $Puerto -U postgres -d postgres -c "CREATE DATABASE $NombreBd OWNER construccion"

Write-Host "[crear_bd] Ejecutando bdfacturas_postgres.sql (12 tablas, triggers, SPs y datos)..."
$script = Join-Path $PSScriptRoot "bdfacturas_postgres.sql"
$env:PGPASSWORD = "Construccion123!"
& $psql -h localhost -p $Puerto -U construccion -d $NombreBd -v ON_ERROR_STOP=1 -f $script
if ($LASTEXITCODE -ne 0) {
    Write-Host "[crear_bd] ERROR ejecutando bdfacturas_postgres.sql."
    exit 1
}

Write-Host "[crear_bd] Listo: $NombreBd creada con sus 12 tablas y datos de ejemplo."
