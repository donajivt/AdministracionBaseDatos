### Universidad Tecnológica de Tula-Tepeji.

#### Carrera: Ingeniería en Desarrollo y Gestión de Software.

#### Unidad de Aprendizaje: 1

#### Evaluación: 3

#### Alumno: Vania Donaji Velazquez Torres.

#### Matricula: 22300049

#### Grupo: 8 IDGS-G1

#### Periodo: Enero-Abril 2025.

#### Docente: Ing. Jose Luis Herrera Gallardo
---

# Reporte del Proyecto: Administración de Base Datos en MongoDB
---
## Clase: MongoDBService

### Descripción
`MongoDBService` es un servicio que proporciona funcionalidad para administrar bases de datos y colecciones en MongoDB. Permite realizar operaciones como la creación y eliminación de bases de datos, colecciones y documentos, así como realizar copias de seguridad y restauraciones.

### Funcionalidad

#### Constructor
```csharp
public MongoDBService(IConfiguration config)
```
- Obtiene la cadena de conexión desde la configuración y crea una instancia de `MongoClient`.

#### Operaciones con bases de datos
##### `ObtenerBasesDeDatos()`
```csharp
public List<string> ObtenerBasesDeDatos()
```
- Retorna una lista con los nombres de todas las bases de datos existentes en el servidor MongoDB.

##### `CrearBaseDeDatos(string nombreBase)`
```csharp
public void CrearBaseDeDatos(string nombreBase)
```
- Crea una nueva base de datos y una colección por defecto.

##### `EliminarBaseDeDatos(string nombreBase)`
```csharp
public void EliminarBaseDeDatos(string nombreBase)
```
- Elimina una base de datos del servidor.

#### Operaciones con colecciones
##### `ObtenerColecciones(string baseDeDatos)`
```csharp
public List<string> ObtenerColecciones(string baseDeDatos)
```
- Retorna una lista con los nombres de todas las colecciones de una base de datos.

##### `CrearColeccion(string nombreBase, string nombreColeccion)`
```csharp
public void CrearColeccion(string nombreBase, string nombreColeccion)
```
- Crea una nueva colección en una base de datos especificada.

##### `EliminarColeccion(string nombreBase, string nombreColeccion)`
```csharp
public void EliminarColeccion(string nombreBase, string nombreColeccion)
```
- Elimina una colección de una base de datos.

#### Operaciones con documentos
##### `InsertarDocumento(string nombreBase, string nombreColeccion, Dictionary<string, object> datos)`
```csharp
public void InsertarDocumento(string nombreBase, string nombreColeccion, Dictionary<string, object> datos)
```
- Inserta un documento en una colección especificada.

##### `ObtenerDocumentos(string nombreBase, string nombreColeccion)`
```csharp
public List<BsonDocument> ObtenerDocumentos(string nombreBase, string nombreColeccion)
```
- Retorna todos los documentos de una colección dada.

#### Copias de seguridad y restauración
##### `RealizarBackup(string nombreBase, string backupFolder)`
```csharp
public void RealizarBackup(string nombreBase, string backupFolder)
```
- Realiza una copia de seguridad de una base de datos utilizando `mongodump` en un contenedor Docker.

##### `RestaurarBackup(string nombreBase, string backupFolder)`
```csharp
public void RestaurarBackup(string nombreBase, string backupFolder)
```
- Restaura una base de datos a partir de un respaldo previo usando `mongorestore`.

##### `CopiarBackupDesdeContenedor(string backupFolder, string nombreBase)`
```csharp
public void CopiarBackupDesdeContenedor(string backupFolder, string nombreBase)
```
- Copia los archivos de respaldo desde el contenedor Docker al sistema local.

#### Gestión de usuarios
##### `CrearUsuario(string usuario, string contraseña, string[] roles)`
```csharp
public void CrearUsuario(string usuario, string contraseña, string[] roles)
```
- Crea un nuevo usuario con los roles especificados.

##### `EliminarUsuario(string usuario)`
```csharp
public void EliminarUsuario(string usuario)
```
- Elimina un usuario de MongoDB.

##### `ObtenerUsuarios()`
```csharp
public List<BsonDocument> ObtenerUsuarios()
```
- Devuelve una lista de todos los usuarios registrados en MongoDB.

---

## Clase: AdministracionMongoController

### Descripción
`AdministracionMongoController` es un controlador MVC en ASP.NET Core que permite gestionar bases de datos, colecciones y documentos en MongoDB a través de una interfaz web.

### Funcionalidad

#### Métodos para la vista principal
##### `Index()`
```csharp
[HttpGet]
public IActionResult Index()
```
- Obtiene la lista de bases de datos y colecciones disponibles, además de los backups almacenados.

##### `CrearBaseDeDatos(string nombreBase)`
```csharp
[HttpPost]
public IActionResult CrearBaseDeDatos(string nombreBase)
```
- Crea una nueva base de datos y redirige a la página principal.

#### Gestión de colecciones
##### `Gestionar(string nombreBase)`
```csharp
[HttpGet]
public IActionResult Gestionar(string nombreBase)
```
- Muestra la lista de colecciones de una base de datos específica.

##### `CrearColeccion(string nombreBase, string nombreColeccion)`
```csharp
[HttpPost]
public IActionResult CrearColeccion(string nombreBase, string nombreColeccion)
```
- Crea una nueva colección en la base de datos seleccionada.

##### `EliminarColeccion(string nombreBase, string nombreColeccion)`
```csharp
[HttpPost]
public IActionResult EliminarColeccion(string nombreBase, string nombreColeccion)
```
- Elimina una colección y redirige a la vista de gestión.

#### Operaciones con documentos
##### `VerDocumentos(string nombreBase, string nombreColeccion)`
```csharp
[HttpGet]
public IActionResult VerDocumentos(string nombreBase, string nombreColeccion)
```
- Obtiene y muestra todos los documentos de una colección.

##### `InsertarDocumento(string nombreBase, string nombreColeccion, string[] clave, string[] valor)`
```csharp
[HttpPost]
public IActionResult InsertarDocumento(string nombreBase, string nombreColeccion, string[] clave, string[] valor)
```
- Inserta un nuevo documento en la colección.

#### Copias de seguridad y restauración
##### `Backup(string nombreBase)`
```csharp
public IActionResult Backup(string nombreBase)
```
- Realiza un backup de la base de datos seleccionada y lo almacena en el servidor.

##### `Restaurar(string nombreBase)`
```csharp
[HttpPost]
public IActionResult Restaurar(string nombreBase)
```
- Restaura una base de datos a partir de un backup disponible.

#### Gestión de usuarios
##### `CrearUsuario(string usuario, string contraseña, string[] roles)`
```csharp
[HttpPost]
public IActionResult CrearUsuario(string usuario, string contraseña, string[] roles)
```
- Crea un nuevo usuario en MongoDB.

##### `EliminarUsuario(string usuario)`
```csharp
[HttpPost]
public IActionResult EliminarUsuario(string usuario)
```
- Elimina un usuario de MongoDB.

##### `VerUsuarios()`
```csharp
public IActionResult VerUsuarios()
```
- Muestra una lista de todos los usuarios registrados en MongoDB.

---

## Vista: **Crear Usuario**
**Descripción:**  
Formulario para registrar un nuevo usuario en el sistema.  

**Componentes principales:**  
- Campo de texto para el nombre de usuario.  
- Campo de contraseña.  
- Selector múltiple para asignar roles.  
- Botón para enviar el formulario.  
- Botón para cancelar y regresar a la lista de usuarios.  

---

## Vista: **Gestión de Base de Datos**
**Descripción:**  
Permite administrar una base de datos específica en MongoDB, incluyendo sus colecciones.  

**Componentes principales:**  
- Lista de colecciones dentro de la base de datos.  
- Botón para crear una nueva colección.  
- Opción para eliminar colecciones.  
- Formulario para insertar documentos en una colección.  

---

## Vista: **Administración de MongoDB**
**Descripción:**  
Página principal de administración, donde se pueden gestionar bases de datos y usuarios.  

**Componentes principales:**  
- Listado de bases de datos con sus colecciones.  
- Botones para crear bases de datos, hacer backup y restaurar bases de datos.  
- Opción para eliminar bases de datos.  
- Enlace para administrar usuarios.  

---

## Vista: **Documentos en la Colección**
**Descripción:**  
Muestra los documentos almacenados en una colección específica de MongoDB en formato JSON.  

**Componentes principales:**  
- Tabla con los documentos en formato JSON.  
- Botón para regresar a la gestión de la base de datos.  

---

## Vista: **Ver Usuarios**
**Descripción:**  
Lista de usuarios registrados en el sistema con sus respectivos roles.  

**Componentes principales:**  
- Tabla con nombre de usuario y roles asignados.  
- Botones para editar o eliminar usuarios.  
