# Laravel Domain Setup

Automatiza la creación de dominios locales para proyectos Laravel mediante Bash, simplificando la configuración del servidor web y el acceso a las aplicaciones desde el navegador.

## Descripción

**Laravel Domain Setup** es una herramienta de automatización diseñada para facilitar la configuración de entornos de desarrollo local para proyectos Laravel en Linux.

A partir del nombre del directorio del proyecto, el script genera un dominio local con la extensión `.test`, prepara la configuración del servidor web, actualiza el archivo `/etc/hosts` y configura los permisos necesarios para facilitar el acceso a la aplicación.

El proyecto está diseñado con una estructura extensible para incorporar soporte para diferentes servidores web, permitiendo ampliar sus funcionalidades sin tener que rediseñar toda la herramienta.

## Características

- **Detección automática de Laravel:** valida la existencia del archivo `artisan`.
- **Generación de dominios locales:** utiliza el nombre del directorio del proyecto para crear el dominio `.test`.
- **Configuración de Apache:** genera un archivo VirtualHost y habilita la configuración en entornos compatibles.
- **Resolución local de dominios:** agrega una entrada a `/etc/hosts` que apunta a `127.0.0.1`.
- **Gestión de permisos:** ajusta permisos y propiedad de archivos y directorios del proyecto.
- **Administración del servicio web:** comprueba el estado del servidor y reinicia el servicio después de aplicar los cambios.
- **Compatibilidad prevista con múltiples servidores:** estructura preparada para incorporar nuevos servidores web.
- **Interfaz por terminal:** incluye argumentos de ejecución, mensajes de estado y un panel de ayuda.

## Tecnologías

- Bash
- Linux
- Laravel
- Apache HTTP Server
- systemd
- Utilidades estándar de administración de Linux

## Requisitos

- Un sistema operativo Linux.
- Un proyecto Laravel existente.
- Bash y utilidades estándar de Linux.
- Apache instalado y configurado.
- `systemctl` para la administración del servicio en instalaciones nativas compatibles.
- Permisos administrativos mediante `sudo`.

> **Estado actual:** Apache cuenta con una implementación de configuración. Nginx está contemplado como opción, pero su configuración automática aún está pendiente de desarrollo.

## Instalación

Clona el repositorio:

```bash
git clone https://github.com/Raul-dd/laravel-domain-setup.git
```

Entra al directorio descargado:

```bash
cd laravel-domain-setup
```

El script puede ejecutarse directamente con Bash, por lo que no es obligatorio asignarle permisos de ejecución.

## Uso

### 1. Acceder al proyecto Laravel

Abre una terminal y sitúate en el directorio raíz del proyecto que deseas configurar:

```bash
cd /ruta/a/tu-proyecto
```

Este directorio debe contener el archivo `artisan`.

### 2. Ejecutar el script

Ejecuta el script indicando la ruta donde clonaste el repositorio:

```bash
bash /ruta/al/repositorio/laravel-domain-setup/laravel-domain.sh -s apache
```

Sustituye `/ruta/al/repositorio/` por la ubicación real del repositorio en tu equipo.

Por ejemplo, si lo clonaste dentro de tu directorio personal:

```bash
bash ~/laravel-domain-setup/laravel-domain.sh -s apache
```

**Importante:** el script utiliza el directorio de trabajo actual (`pwd`) para localizar el proyecto Laravel. Por eso, debes ejecutar el comando desde la raíz de la aplicación, no desde la carpeta del repositorio del script.

### 3. Acceder al dominio local

El dominio se genera automáticamente a partir del nombre del directorio del proyecto.

Por ejemplo, si tu aplicación se encuentra en:

```text
/home/usuario/proyectos/mi-aplicacion/
```

El dominio generado será:

```text
http://mi-aplicacion.test
```

El script prepara la configuración de Apache y agrega el dominio a `/etc/hosts` para que el sistema lo resuelva localmente.

## Opciones disponibles

| Opción | Descripción |
| --- | --- |
| `-s apache` | Selecciona Apache como servidor web. |
| `-s nginx` | Selecciona la opción prevista para Nginx; su configuración automática está pendiente. |
| `-h` | Muestra el panel de ayuda. |

Para consultar las opciones:

```bash
bash ~/laravel-domain-setup/laravel-domain.sh -h
```

## ¿Cómo funciona?

El script sigue un flujo de ejecución organizado en varias etapas:

### 1. Validación del entorno

Comprueba que el sistema operativo sea Linux y verifica que el directorio actual contenga el archivo `artisan`, utilizado para identificar el proyecto Laravel.

### 2. Identificación del proyecto

Obtiene la ruta absoluta del proyecto y extrae el nombre de su directorio.

A partir de ese nombre construye el dominio local con la extensión `.test`.

### 3. Selección del servidor web

El argumento `-s` permite seleccionar el servidor web que se utilizará.

Esta separación facilita incorporar nuevos servidores mediante funciones específicas para cada implementación.

### 4. Generación de la configuración

En la implementación de Apache, el script identifica directorios de configuración compatibles y genera un archivo VirtualHost con el dominio y el directorio raíz del sitio.

Para una aplicación Laravel nativa, el directorio público debe apuntar a `public/`, ya que es el punto de entrada web de la aplicación.

### 5. Configuración del archivo hosts

Comprueba si el dominio ya aparece en `/etc/hosts`. Si no existe, agrega una entrada asociada a `127.0.0.1`.

Esto permite utilizar el dominio desde el propio equipo sin contratar un dominio público ni configurar DNS externo.

### 6. Ajuste de permisos

Configura la propiedad y los permisos de los archivos del proyecto, incluyendo los directorios de almacenamiento y caché que Laravel necesita para escribir datos.

También contempla ajustes de systemd para determinados entornos en los que las restricciones del servicio puedan impedir el acceso al directorio del proyecto.

### 7. Reinicio del servicio

Reinicia el servicio web correspondiente para aplicar la configuración y muestra el dominio local generado.

## Arquitectura extensible

Laravel Domain Setup está concebido como una herramienta modular. La selección del servidor y la implementación de su configuración se separan mediante funciones específicas.

La estructura permite incorporar progresivamente nuevos servidores web y entornos de desarrollo sin concentrar toda la lógica en una única función.

### Servidores web

| Servidor | Estado |
| --- | --- |
| Apache | Configuración implementada; requiere validación según la distribución y el entorno. |
| Nginx | Opción declarada; configuración automática pendiente. |
| Otros servidores | Posibles integraciones futuras. |

El objetivo es evolucionar hacia una herramienta que permita configurar dominios locales de Laravel de forma uniforme, independientemente del servidor web utilizado.

## Seguridad y consideraciones

El script realiza operaciones que pueden modificar la configuración del sistema. Antes de utilizarlo, ten en cuenta lo siguiente:

- Revisa el código antes de ejecutarlo.
- Comprueba las rutas de configuración del servidor web.
- Verifica los permisos asignados a los archivos y directorios.
- Ten presente que el reinicio de servicios puede interrumpir temporalmente otras aplicaciones.
- Utiliza un entorno de desarrollo controlado para las primeras pruebas.

La herramienta está orientada al desarrollo local y no sustituye la configuración de seguridad necesaria para publicar una aplicación en producción.

## Objetivo del proyecto

Simplificar tareas repetitivas de administración y configuración en entornos de desarrollo Laravel mediante automatización con Bash.

Además de reducir el trabajo manual, el proyecto busca establecer una base extensible para incorporar distintos servidores web y nuevas funcionalidades en futuras versiones.

## Autor

**Raul-dd**

- GitHub: [@Raul-dd](https://github.com/Raul-dd)
- Repositorio: [laravel-domain-setup](https://github.com/Raul-dd/laravel-domain-setup)

## Licencia

Consulta el repositorio para conocer la licencia aplicable al proyecto.
