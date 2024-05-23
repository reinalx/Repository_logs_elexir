
# Repositoy of Logs
This project was developed as part of a university assignment, involving collaboration among multiple individuals. It focuses on creating a system that gathers logs from diverse machines, enabling users to query and filter these logs. Additionally, users can subscribe to specific individuals to receive real-time logs. The architecture is implemented using the Elixir language with a repository pattern. Moreover, a frontend has been crafted utilizing the Phoenix framework and Tailwind CSS for styling
# Práctica grupal

## Nombre del equipo

Leño

## Autores

  - Santiago Alfredo, Castro Rampersad, s.a.castro.rampersad, santiago2699
  - Pablo, Díaz Coira, pablo.coira, pablodiazcoira
  - David, López Casas, david.lopez.casas, davidlopezcasas
  - Andrés, Reinaldo Cid, a.reinaldo, areinaldo
  - Daniel Rodríguez Mondragón, daniel.rodriguez.mondragon, DanielRodriguezMondragon
  - Miguel Rodriguez Novoa, migue.rodriguez.novoa, miguel-rguez
  - Iván, Varela González, ivan.varela.gonzalez, ivan-varela
    
  
  
## Descripción de la aplicación
Este proyecto consiste en un repositorio centralizado que almacena la última hora de logs de usuarios específicos. Solo clientes autorizados pueden enviar sus logs. Permite realizar búsquedas y aplicar filtros a dichas búsquedas. Además, ofrece un sistema de suscripciones mediante el cual los usuarios reciben logs de ciertos usuarios a intervalos regulares.

Los clientes pueden acceder al repositorio utilizando un cliente externo que proporciona funcionalidades de búsqueda, filtrado y suscripción. Este cliente externo no forma parte de la arquitectura central del proyecto.



## Normas para el código


- Codigo documentado con _ExDoc_. Usar mix docs para generar la documentación.

- Formato del codigo: `mix format`.
  

## Documentación


### Aplicación
#### Requisitos Funcionales
- **Envío de Logs**: Los logs deben enviarse al repositorio en el formato: 'Mon dd hh:mm:ss localhost service[pid]: log message'.
Recepción y Almacenamiento: Almacenamiento en memoria de los logs de la última hora.
- **Búsqueda de Logs**: Capacidad para buscar en los logs por los últimos x minutos, palabras clave y servicio que generó el log.
- **Sistema de Suscripción**: Suscripción a logs de usuarios específicos, enviando estos logs al suscriptor periódicamente.
- **Almacenamiento en Base de Datos**: Guardado de logs en formato JSON.

#### Requisitos No Funcionales
- **Autorización**: Solo los usuarios autorizados pueden enviar logs al repositorio.
- **Tolerancia a Fallos**: El sistema solo puede sufrir la pérdida de logs de hasta 10 minutos en caso de fallo.
- **Disponibilidad**: El sistema debe estar disponible, con interrupciones que no superen los 3 minutos.

### Diseño

#### Diagramas C4

[**Diagrama de contexto**](docs/diagrama_contexto.png)

[**Diagrama de contenedor**](docs/diagrama_container.png)

[**Diagrama de componente**](docs/diagrama_component.png)

**Diagramas de codigo:**
- [Enviar logs correctamente](docs/send_logs_success.png)
- [Errores enviar logs](docs/send_logs_error.png)
- [Filtrado](docs/filter_func.png)
- [Suscripcion](docs/subscirbe&get_logs.png)

#### Arquitectura General
La arquitectura seleccionada para este proyecto es un modelo en repositorio con clientes distribuidos. Los Clientes Emisores de Logs (CEL) están dispersos en distintos nodos, lo cual asegura que el sistema sea más resistente a fallos. En caso de que un nodo específico falle, solo afectará la captura y gestión de logs de ese nodo en particular, permitiendo que los demás nodos continúen funcionando de manera normal. Esta configuración ayuda a minimizar los puntos únicos de fallo en la arquitectura y mejora la disponibilidad global del sistema.

#### Justificación de la Arquitectura en Repositorio
- **Centralización de Datos**: El repositorio centralizado actúa como el núcleo lógico y de almacenamiento del sistema, permitiendo una gestión unificada de los logs. Los backups solo se tienen que realizar sobre el repositorio y cualquier cambio en los datos es visible inmediatamente por las otras partes del sistema.
- **Acceso y Búsqueda Eficiente**: La centralización de logs permite implementar búsqueda y filtrado que pueden operar sobre un conjunto de datos consolidado, mejorando la rapidez y la precisión de las búsquedas.
- **Integración de Nuevos Componentes**: El modelo de repositorio es altamente adaptable, permitiendo la incorporación de nuevos componentes, como herramientas analíticas o de reporte, que pueden aprovechar directamente los datos centralizados.

#### Componentes Clave
- **Repositorio Centralizado:**
	* **Función Principal:** Recibir y almacenar logs de los CEL en memoria.
	* **Resiliencia de Datos:** Integra un mecanismo de respaldo periódico que almacena los logs en una base de datos JSON. Este mecanismo es crucial para recuperar datos en caso de un fallo del repositorio.

- **Cliente Emisor de Logs (CEL):**
	* **Función Principal:** Enviar logs al repositorio centralizado siguiendo el formato especificado.
	* **Distribución:** Ubicados en diferentes nodos, cada uno responsable de capturar y transmitir logs desde su localización específica.

- **Componente de Filtrado:**
	* **Función Principal:** Aplicar filtros dinámicos a los logs almacenados para facilitar búsquedas específicas por parte de los usuarios.
	* **Capacidades Avanzadas:** Permite el filtrado, como la búsqueda por tiempo, palabra clave o servicio específico.
	* **Interfaz de Usuario:** Proporciona una API que facilita la interacción con aplicaciones cliente para realizar consultas personalizadas.

- **Sistema de Suscripción:**
	* **Función Principal:** Permitir a los usuarios suscribirse a logs de usuarios específicos y recibir actualizaciones periódicas. Proporcionar lista de los CEL en el repositorio.
	* **Notificaciones:** Envío de logs a los suscriptores en intervalos de tiempo.
	* **Gestión de Suscripciones:** Proporciona una API que facilita la interacción con aplicaciones cliente para realizar suscripciones a una lista de usuario.

#### Monitoreo y Supervisión:
- **Supervisor de Elixir:**
	* **Estrategia One-for-One:** En caso de fallo de cualquier componente, el Supervisor reinicia automáticamente el componente específico sin afectar al resto del sistema.
	* **Monitorización Continua:** Vigila el estado y rendimiento de todos los componentes críticos del sistema para garantizar la máxima disponibilidad y respuesta rápida ante incidentes.

#### Seguridad:
- **Lista Blanca de Usuarios Autorizados:**
	* **Control de Acceso:** Solo los usuarios en la lista blanca pueden enviar los logs, asegurando que solo partes autorizadas interactúen con el sistema.


### Instrucciones

#### Instrucciones de compilación:
**Desde ./elixir_log**

`mix deps.get`

`mix compile`

**Desde ./front** 
Si no tienes instalado **Phoenix Framework**

`mix local.hex`

`mix archive.install hex phx_new`

Ya con el Phoenix instalado

`mix deps.get`

`mix compile`
#### Instrucciones de uso:
Ir al apartado de [ver Replicar Demo](#replicar-demo)

- En la pantalla principal del front se pueden aplicar busquedas y filtros. 
- En el apartado follow aparecera una lista con los usuarios a los que te puedes suscribir.

#### Instrucciones para ejecutar los test
**UNITARIOS**

EL DIRECTORIO data_base DEBE ESTAR VACIO

`MIX_ENV=repo_off elixir --sname server@localhost -S mix test test/repository_test.exs`

`MIX_ENV=repo_off elixir --sname server@localhost -S mix test test/data_base_test.exs`

**INTEGRACIÓN**

Descomentar la siguiente linea en ./elixir_log/lib/eilixir_log/subscription_manager.ex:

`#@poll_time 10 * 1000 * 1 ##USAR PARA TEST repository_and_sub_man_test`

`MIX_ENV=repo_off elixir --sname server@localhost -S mix test test/repository_and_filters_int_test.exs`

ENCENDER EL REPOSITORIO EN UNA TERMINAL `iex --sname server@localhost -S mix`

`MIX_ENV=repo_off elixir --sname server@localhost -S mix test test/repository_and_sub_man_test.exs`



### Tests

#### Tipos de Test:

##### Unitarios:
Solo implementamos tests unitarios para estas clases, ya que los demás componentes necesitaban del repositorio para funcionar, por lo que los testeamos con pruebas unitarias.

- **Repository:**
	- Inicio del repositorio exitosamente.
	- Conexión de usuario exitosa.
	- Retorna `:already_connected` para un usuario ya conectado.
	- Inserta logs correctamente.
	- Recuperar todos los logs en formato crudo.
	- Enviar logs del último minuto de un usuario específico.
	- Retorna `[]` para logs de un usuario que no existe.
	- Recupera todos los logs de todos los usuarios.
	- Recupera todos los usuarios conectados al repositorio.
- **DataBase:**
	- Base de datos con ficheros.
	- Base de datos vacía devuelve `[]`.

#### Integración

- **Repository and Filters:**
	- Filtrar por usuario y último minuto.
	- Filtrar por todos los logs del repositorio.
	- Filtrar por keyword.
	- Filtrar por service.
	- Redo filtrado.
- **Repository and SyslogReader:**
	- Verificamos que está suscrito.
	- Enviar mensaje y verificar que llegó al repositorio.
	- Parseo correcto de un log bien formateado.
- **Repositorio y SubscriptionManager:**
	- Cliente se puede suscribir y recibir mensajes.
	- Suscripción a usuario que no existe en el repositorio.
	- Cambiar de suscripción y recibir mensajes.
	- Obtener lista de usuarios del repositorio.


# Replicar Demo

Crear una terminal para cada apartado

1. GENERADOR DE LOGS:

`MIX_ENV=repo_off iex -S mix`

`LogGenerator.start_link`

2. REPOSITORIO, FILTROS Y BBDD

`iex --sname server@localhost -S mix`

3. CLIENTES 

Crear 3 terminales, cada terminal será un cliente. Ejecutar los siguientes comandos:

Cambiar <x> por algun 1,2,3 respectivamente

`MIX_ENV=repo_off iex --sname client<X>@localhost -S mix`

`SyslogReader.start_link(<nombre cliente>)`

Los clientes serán los admitidos en la whitelist:

	- santiPC
	- santiago
	- david24
4. EJECUCIÓN DEL FRONT

`iex --sname front -S mix phx.server`

Abrir en un navegador `http://localhost:4000/`
>>>>>>> 7f9124b (Upload Repository)
