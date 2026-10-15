# Laravel Domain Setup

Script de automatización desarrollado en Bash para configurar dominios locales en proyectos Laravel sobre Linux, utilizando Apache.

## Descripción

**Laravel Domain Setup** simplifica la configuración de un entorno de desarrollo local al automatizar tareas que normalmente requieren modificar archivos del sistema y configurar manualmente el servidor web.

El script detecta proyectos Laravel, identifica el nombre del proyecto y configura un dominio local con la extensión `.test`, facilitando el acceso a la aplicación desde el navegador.

## Características

- **Detección de proyectos Laravel:** verifica la existencia del archivo `artisan`.
- **Dominios locales automáticos:** genera un dominio basado en el nombre del directorio del proyecto.
- **Configuración de Apache:** crea la configuración del VirtualHost y habilita el sitio cuando corresponde.
- **Actualización de `/etc/hosts`:** vincula el dominio local con `127.0.0.1`.
- **Compatibilidad con distintos entornos Apache:** contempla instalaciones nativas en Linux y XAMPP en `/opt/lampp`.
- **Gestión de permisos:** ajusta permisos y propiedad de archivos para facilitar el acceso del servidor web.
- **Validación del entorno:** comprueba el sistema operativo, el servidor web y el estado del servicio.
- **Interfaz por terminal:** proporciona mensajes informativos, colores y un panel de ayuda.

## Tecnologías

- Bash
- Linux
- Laravel
- Apache HTTP Server
- XAMPP (opcional)

## Requisitos

- Un sistema operativo Linux.
- Un proyecto Laravel existente.
- Bash y utilidades estándar de Linux.
- Apache instalado y en ejecución.
- `sudo` para las operaciones que requieren permisos administrativos.

## Instalación

Clona el repositorio:

```bash
git clone https://github.com/Raul-dd/laravel-domain-setup.git
```

Entra al directorio del repositorio:

```bash
cd laravel-domain-setup
```

## Uso

Sitúate en la raíz del proyecto Laravel que deseas configurar y ejecuta el script indicando Apache:

```bash
bash /ruta/al/repositorio/laravel-domain-setup/laravel-domain.sh -s apache
```

También puedes copiar el script a tu proyecto Laravel y ejecutarlo desde su directorio:

```bash
bash laravel-domain.sh -s apache
```

Para consultar las opciones disponibles:

```bash
bash laravel-domain.sh -h
```

## ¿Cómo funciona?

1. Comprueba que el sistema operativo sea Linux.
2. Verifica que el directorio actual corresponda a un proyecto Laravel.
3. Obtiene el nombre del proyecto para construir el dominio local.
4. Comprueba la disponibilidad y el estado del servidor Apache.
5. Genera la configuración del VirtualHost y prepara el acceso al dominio.
6. Añade una entrada a `/etc/hosts` si es necesario.
7. Configura los permisos de archivos y directorios.
8. Reinicia el servidor web y muestra la dirección local resultante.

### Ejemplo

Si el proyecto se encuentra en un directorio llamado `mi-aplicacion`, el dominio generado será:

```text
http://mi-aplicacion.test
```

El dominio es local y está destinado al entorno de desarrollo; no publica la aplicación en Internet.

## Servidores compatibles

| Servidor | Estado |
| --- | --- |
| Apache | Implementación de configuración disponible |
| Nginx | Opción contemplada, implementación pendiente |

## Consideraciones de seguridad

Este script modifica configuraciones del sistema, permisos de archivos y entradas de `/etc/hosts`. También puede reiniciar servicios y modificar configuraciones de systemd según el entorno detectado.

Antes de ejecutarlo, revisa el código y asegúrate de comprender los cambios que realizará en tu sistema.

Se recomienda probarlo primero en un entorno de desarrollo controlado y verificar los permisos resultantes.

## Objetivo del proyecto

Reducir el trabajo manual necesario para preparar dominios locales de proyectos Laravel, mediante automatización con Bash y administración de servicios en Linux.

## Autor

**Raul-dd**

- GitHub: [@Raul-dd](https://github.com/Raul-dd)
- Repositorio: [laravel-domain-setup](https://github.com/Raul-dd/laravel-domain-setup)

## Licencia

Consulta el repositorio para conocer los términos de licencia aplicables.
