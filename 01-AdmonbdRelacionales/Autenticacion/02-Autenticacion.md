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

# Reporte del Proyecto: Administración de Usuarios en Base de Datos

## 1. Introducción
Este documento explica la estructura y funcionalidad de un proyecto ASP.NET Core para la administración de usuarios en bases de datos SQL Server. Se detallan las clases, controladores, vistas y procedimientos almacenados empleados, junto con su utilidad en el sistema.

## 2. Estructura del Proyecto
El proyecto está compuesto por los siguientes elementos clave:

- **Controlador (UserController.cs)**: Maneja la lógica de negocio relacionada con los usuarios.
- **Modelo (UserModel.cs)**: Representa los datos de los usuarios y sus permisos.
- **Vistas**: Formulario para la creación de usuarios y asignación de permisos.
- **Procedimientos Almacenados (SQL Server)**: Gestionan la creación de logins, asignación de permisos y consulta de información.

## 3. Explicación del Código Fuente
A continuación, se describe el código fuente de los principales elementos del proyecto, explicando cada línea y su función en la aplicación.

### 3.1 Controlador: UserController.cs

```csharp
// Importación de namespaces necesarios
using Microsoft.AspNetCore.Mvc; // Proporciona funcionalidades para trabajar con controladores y acciones en ASP.NET Core.
using Microsoft.Extensions.Configuration; // Permite acceder a la configuración de la aplicación, como la cadena de conexión a la base de datos.
using System.Data.SqlClient; // Proporciona clases para interactuar con bases de datos SQL Server.
using System.Data; // Contiene clases necesarias para manejar datos y conexiones con bases de datos.
using Proyecto.Models; // Referencia el espacio de nombres donde se encuentra el modelo `UserModel`.

public class UserController : Controller
{
    private readonly IConfiguration _configuration; // Permite acceder a la configuración de la aplicación.

    // Constructor del controlador, recibe la configuración a través de la inyección de dependencias.
    public UserController(IConfiguration configuration)
    {
        _configuration = configuration; // Asigna la configuración al campo privado `_configuration`.
    }

    // Acción para mostrar la lista de usuarios.
    public IActionResult Index()
    {
        return View(); // Devuelve la vista que muestra la lista de usuarios registrados.
    }

    // Acción GET para mostrar el formulario de creación de usuarios.
    public IActionResult Create()
    {
        return View(); // Devuelve la vista con el formulario para crear un nuevo usuario.
    }

    // Acción POST que recibe los datos del usuario y los envía a la base de datos.
    [HttpPost] // Indica que este método manejará solicitudes HTTP POST.
    public IActionResult Create(UserModel user)
    {
        if (ModelState.IsValid) // Verifica si los datos del formulario son válidos.
        {
            // Se obtiene la cadena de conexión desde el archivo de configuración (appsettings.json).
            string connectionString = _configuration.GetConnectionString("DefaultConnection");

            using (SqlConnection connection = new SqlConnection(connectionString)) // Se crea una conexión con la base de datos.
            {
                using (SqlCommand command = new SqlCommand("sp_CreateLoginAndUser", connection)) // Se define el procedimiento almacenado a ejecutar.
                {
                    command.CommandType = CommandType.StoredProcedure; // Indica que se usará un procedimiento almacenado.

                    // Se agregan los parámetros necesarios para el procedimiento almacenado.
                    command.Parameters.AddWithValue("@LoginName", user.LoginName); // Nombre del login en SQL Server.
                    command.Parameters.AddWithValue("@Password", user.Password); // Contraseña del usuario.
                    command.Parameters.AddWithValue("@DatabaseName", "NombreDeLaBaseDeDatos"); // Nombre de la base de datos a la que tendrá acceso.

                    connection.Open(); // Se abre la conexión con la base de datos.
                    command.ExecuteNonQuery(); // Se ejecuta el procedimiento almacenado en SQL Server.
                }
            }

            return RedirectToAction("Index"); // Redirige al usuario a la vista principal si todo fue exitoso.
        }

        return View(user); // Si los datos no son válidos, devuelve la vista con los errores.
    }
}
```

---

#### **1. Namespaces Importados**
```csharp
using Microsoft.AspNetCore.Mvc;
```
- Permite definir controladores y manejar solicitudes HTTP en ASP.NET Core.

```csharp
using Microsoft.Extensions.Configuration;
```
- Permite acceder a la configuración de la aplicación, como la **cadena de conexión** a la base de datos.

```csharp
using System.Data.SqlClient;
```
- Proporciona clases necesarias para conectarse y ejecutar comandos en SQL Server.

```csharp
using System.Data;
```
- Contiene tipos de datos usados en conexiones a bases de datos.

```csharp
using Proyecto.Models;
```
- Importa el modelo `UserModel` que representa los datos del usuario.

---

#### **2. Clase `UserController` y Constructor**
```csharp
public class UserController : Controller
```
- Declara la clase `UserController`, que hereda de `Controller` para manejar solicitudes HTTP.

```csharp
private readonly IConfiguration _configuration;
```
- Se define un campo privado `_configuration` que almacenará la configuración de la aplicación.

```csharp
public UserController(IConfiguration configuration)
{
    _configuration = configuration;
}
```
- El **constructor** recibe la configuración de la aplicación y la asigna al campo privado `_configuration`.  
- Esto permite acceder a la cadena de conexión a la base de datos desde `appsettings.json`.

---

#### **3. Método `Index()`**
```csharp
public IActionResult Index()
{
    return View();
}
```
- Muestra la vista principal de la aplicación, donde se listarán los usuarios creados.

---

#### **4. Método `Create()` (GET)**
```csharp
public IActionResult Create()
{
    return View();
}
```
- Muestra el formulario de creación de usuarios.

---

#### **5. Método `Create(UserModel user)` (POST)**
```csharp
[HttpPost]
```
- Indica que este método solo responderá a **solicitudes HTTP POST**.

```csharp
public IActionResult Create(UserModel user)
```
- Recibe los datos del usuario desde el formulario en la vista.

```csharp
if (ModelState.IsValid)
```
- Verifica que los datos del usuario cumplan con las validaciones establecidas en `UserModel`.

---

#### **6. Conexión con la Base de Datos**
```csharp
string connectionString = _configuration.GetConnectionString("DefaultConnection");
```
- Obtiene la **cadena de conexión** de `appsettings.json`.

```csharp
using (SqlConnection connection = new SqlConnection(connectionString))
```
- **Crea una conexión** a la base de datos SQL Server.  
- `using` asegura que la conexión se cierre automáticamente al finalizar la ejecución.

```csharp
using (SqlCommand command = new SqlCommand("sp_CreateLoginAndUser", connection))
```
- Se define el **procedimiento almacenado** que se ejecutará en SQL Server.

```csharp
command.CommandType = CommandType.StoredProcedure;
```
- Indica que el comando es un procedimiento almacenado.

---

#### **7. Parámetros del Procedimiento Almacenado**
```csharp
command.Parameters.AddWithValue("@LoginName", user.LoginName);
```
- **Asigna el valor** de `LoginName` al parámetro `@LoginName` del procedimiento almacenado.

```csharp
command.Parameters.AddWithValue("@Password", user.Password);
```
- **Asigna la contraseña** ingresada al parámetro `@Password`.

```csharp
command.Parameters.AddWithValue("@DatabaseName", "NombreDeLaBaseDeDatos");
```
- **Especifica la base de datos** donde se creará el usuario.

---

#### **8. Ejecución del Procedimiento Almacenado**
```csharp
connection.Open();
```
- **Abre la conexión** con la base de datos.

```csharp
command.ExecuteNonQuery();
```
- **Ejecuta el procedimiento almacenado**, que creará el usuario en SQL Server.

---

#### **9. Redirección o Devolución de la Vista**
```csharp
return RedirectToAction("Index");
```
- Si la ejecución es exitosa, redirige al usuario a la vista `Index()`.

```csharp
return View(user);
```
- Si los datos no son válidos, devuelve la vista de creación con los errores.

---

#### **¿Cómo se relaciona esto con la Aplicación?**
1. **Permite la creación de usuarios** en SQL Server desde una interfaz web.
2. **Valida los datos ingresados** en el formulario antes de guardarlos.
3. **Ejecuta el procedimiento almacenado `sp_CreateLoginAndUser`** para registrar el usuario en la base de datos.
4. **Redirige a la lista de usuarios** tras la creación exitosa.
5. **Maneja errores de validación**, evitando el envío de datos incorrectos.

---

### 3.2 Modelo: UserModel.cs
```csharp
public class UserModel
{
    public string LoginName { get; set; } // Nombre del login en SQL Server
    public string Password { get; set; } // Contraseña del usuario
    public string UserName { get; set; } // Nombre del usuario en la base de datos
    public List<string> AssignedDatabases { get; set; } // Bases de datos asignadas al usuario
    public List<string> ServerPermissions { get; set; } // Permisos a nivel de servidor
    public List<string> DatabasePermissions { get; set; } // Permisos a nivel de base de datos
    public List<string> TablePermissions { get; set; } // Permisos a nivel de tabla
}
```

Este modelo representa un usuario en la aplicación. Cada propiedad almacena información necesaria para gestionar accesos y permisos.

---

### 3.3 Procedimiento Almacenado: sp_CreateLoginAndUser
```sql
CREATE PROCEDURE sp_CreateLoginAndUser
    @LoginName NVARCHAR(50),
    @Password NVARCHAR(50),
    @DatabaseName NVARCHAR(50)
AS
BEGIN
    DECLARE @Sql NVARCHAR(MAX);
    
    -- Crear login en SQL Server
    SET @Sql = 'CREATE LOGIN ' + QUOTENAME(@LoginName) + ' WITH PASSWORD = ''' + @Password + '''';
    EXEC(@Sql);
    
    -- Crear usuario en la base de datos especificada
    SET @Sql = 'USE ' + QUOTENAME(@DatabaseName) + '; CREATE USER ' + QUOTENAME(@LoginName) + ' FOR LOGIN ' + QUOTENAME(@LoginName);
    EXEC(@Sql);
END
```

Explicación:
1. Se declara la variable `@Sql` para almacenar la consulta SQL dinámica.
2. Se construye una consulta `CREATE LOGIN` con la contraseña proporcionada.
3. Se ejecuta la consulta usando `EXEC(@Sql)`.
4. Luego, se crea un usuario en la base de datos seleccionada.

Este procedimiento es clave para permitir la creación de usuarios con acceso a bases de datos específicas.

---

### 3.4 Vista: Create.cshtml
```html
@model UserModel

<h2>Crear Usuario</h2>

<form asp-action="Create" method="post">
    <div>
        <label>Nombre de Login:</label>
        <input asp-for="LoginName" required />
    </div>
    <div>
        <label>Contraseña:</label>
        <input type="password" asp-for="Password" required />
    </div>
    <div>
        <label>Nombre de Usuario:</label>
        <input asp-for="UserName" required />
    </div>
    <div>
        <label>Bases de Datos Asignadas:</label>
        <input asp-for="AssignedDatabases" />
    </div>
    <div>
        <label>Permisos de Servidor:</label>
        <input asp-for="ServerPermissions" />
    </div>
    <div>
        <label>Permisos de Base de Datos:</label>
        <input asp-for="DatabasePermissions" />
    </div>
    <div>
        <label>Permisos de Tabla:</label>
        <input asp-for="TablePermissions" />
    </div>
    <button type="submit">Guardar</button>
</form>
```

Explicación:
- Usa `@model UserModel` para asociar la vista con el modelo de usuario.
- Se crea un formulario que envía los datos al método `Create` del `UserController`.
- Los campos de entrada usan `asp-for` para vincularse a las propiedades del modelo.
- El botón de envío manda la información al servidor para su procesamiento.

Esta vista permite al usuario ingresar la información necesaria para crear un nuevo usuario en la base de datos.

---

## 4. Conclusión
El proyecto permite la administración eficiente de usuarios y permisos en bases de datos SQL Server mediante una interfaz web en ASP.NET Core. La combinación de controladores, modelos, vistas y procedimientos almacenados facilita la gestión centralizada y segura de accesos a los datos.

