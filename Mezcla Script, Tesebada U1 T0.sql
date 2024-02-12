   /* Drop Database Northwind
   GO */
   
   Use Northwind
   GO
/* Pasos para duplicación de mezcla
   Paso 1.- Crear sucursales y agregar una sucursal. */

   -- Creación de Tabla Sucursal
   Create Table Sucursal(
   SucID int not null, 
   SucNom Nvarchar(30)
   )
   GO

   -- PK
   Alter Table Sucursal Add Constraint PK_Sucursal Primary Key(SucID)
   GO

   -- Agregar sucursal
   Insert into Sucursal Values (01, 'Joji')
   GO

-- Paso 2. Quitar llaves foráneas entre orders y orderdetails.
Alter Table Orders Drop Constraint FK_Orders_Customers 
Go

Alter Table Orders Drop Constraint FK_Orders_Employees 
Go

Alter Table Orders Drop Constraint FK_Orders_Shippers 
Go

Alter Table [Order Details] Drop Constraint FK_Order_Details_Orders
Go

Alter Table [Order Details] Drop Constraint FK_Order_Details_Products
Go

/* Procesar Tabla Orders
   Paso 3. Agregar el campo orders.sucid */
   Alter Table Orders Add SucId Int
   Go

-- Paso 4. Actualizar el campo orders.sucid con la clave sucid del punto 1.
Update Orders set SucID = 1
Go

-- Paso 5. Quitar PK en orders
Alter Table Orders Drop Constraint PK_Orders
Go

-- Paso 6. Quitar la propiedad identity en orders.orderid
-- Tabla Auxiliar 
Create Table OrdersT(
    "SucID" "int",
    "OrderID" "int" NOT NULL ,
	"CustomerID" nchar (5) NULL ,
	"EmployeeID" "int" NULL ,
	"OrderDate" "datetime" NULL ,
	"RequiredDate" "datetime" NULL ,
	"ShippedDate" "datetime" NULL ,
	"ShipVia" "int" NULL ,
	"Freight" "money" NULL,
	"ShipName" nvarchar (40) NULL ,
	"ShipAddress" nvarchar (60) NULL ,
	"ShipCity" nvarchar (15) NULL ,
	"ShipRegion" nvarchar (15) NULL ,
	"ShipPostalCode" nvarchar (10) NULL ,
	"ShipCountry" nvarchar (15) NULL
)
Go

-- Pasar todos los datos a la tabla auxiliar
Insert into OrdersT 
Select SucID, OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, 
ShippedDate, ShipVia, Freight, ShipName, ShipAddress, 
ShipCity, ShipRegion, ShipPostalCode, ShipCountry 
From Orders
Go

-- Drop la tabla original
Drop table Orders
Go

-- Renombrar la tabla auxiliar
Exec sp_rename 'OrdersT', 'Orders'
Go

-- Paso 7. Que no permita nulos orders.sucid
Alter Table Orders Alter Column SucID int not null
Go

-- Paso 8. Crear PK en orders (sucid, orderid).
Alter Table Orders Add Constraint "PK_Or_Suc_Ord" Primary Key(SucID, OrderID)
GO

-- Paso 9. Crear la FK entre orders y sucursales.
Alter Table Orders Add Constraint "FK_Orders_Customers" FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
GO

Alter Table Orders Add Constraint "FK_Orders_Employees" FOREIGN KEY (EmployeeID) REFERENCES Employees (EmployeeID)
GO

Alter Table Orders Add Constraint "FK_Orders_Shippers" FOREIGN KEY (ShipVia) REFERENCES Shippers (ShipperID)
GO

Alter Table Orders Add Constraint "FK_Or_SucId" Foreign Key(SucID) References Sucursal(SucID)
Go

/* Procesar orderdetails
   Paso 10. Agregar orderdetails.sucid */
   Alter Table [Order Details] Add SucID int
   Go

  -- Tabla auxiliar para eliminar identity
  Create Table "Order DetailsA"(
  "SucID" "int",
  "OrderID" "int" NOT NULL,
  "ProductID" "int" NOT NULL,
  "UnitPrice" "money" NOT NULL,
  "Quantity" "smallint" NOT NULL,
  "Discount" "real" NOT NULL 
   )
   Go

 Alter Table [Order Details] Add Constraint "FK_OrderDetails_Products" Foreign Key(ProductID) References Products(ProductID)
Go

-- Paso 11. Actualizar orderdetails.sucid con la clave sucid del punto 1.
Update [Order Details] set SucID = 1
Go

-- Paso 12. Quitar PK en orderdetails.
Alter Table [Order Details] Drop PK_Order_Details
Go

-- Pasar todos los datos a la tabla auxiliar
  Insert into [Order DetailsA] Select
  SucID, OrderID, ProductID, 
  UnitPrice, Quantity, Discount From [Order Details]
  Go

  -- Drop Order Details
  Drop Table [Order Details]
  Go

  -- Renombrar la tabla auxiliar
  Exec sp_rename 'Order DetailsA', 'Order Details'
  Go

-- Paso 13. Que no permita nulos orderdetails.sucid
Alter Table [Order Details] Alter Column SucID int not null
Go

-- Paso 14. Crear PK en orderdetails (sucid, orderid, productid).

Alter Table [Order Details] Add Constraint "PK_OrdersDetails" Primary Key (SucID, OrderID, ProductID)
Go

-- Paso 15. Crear FK entre orderdetails y orders
Alter Table [Order Details] Add Constraint "FK_OrderDetails" Foreign Key (SucID, OrderID) References Orders(SucID, OrderID)
Go

-- Inserciones
Insert into Orders Values(1, 1, 'VINET', 1, '2024-10-06', '2024-10-08','2024-10-10', 1, 300.00, 'Emilio Payán', 'Santa Fe', 'Culiacán', 'Sinaloa', 80200, 'Mexico')
Go

Insert into [Order Details] Values (1, 1, 69, 70.00, 5, 20)
Go

-- Identity
Select name, is_identity
From sys.columns
Where object_id = OBJECT_ID('Orders') and Name = 'OrderID'
Go