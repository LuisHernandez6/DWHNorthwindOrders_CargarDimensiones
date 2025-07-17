-- Procedimiento almacenado para limpiar los datos de las tablas

USE DWHNorthwindOrders;
GO

CREATE PROCEDURE dbo.LimpiarDatos
AS
BEGIN
    DELETE FROM Fact.[Order];
    DELETE FROM Dimension.[Product];
    DELETE FROM Dimension.Customer;
    DELETE FROM Dimension.Supplier;
    DELETE FROM Dimension.Category;
    DELETE FROM Dimension.Shipper;
    DELETE FROM Dimension.Employee;
    DELETE FROM Dimension.[Date];
END;
GO

-- Vistas en Northwind para extraer y transformar los datos

USE Northwind;
GO

-- vmDimCustomer
CREATE VIEW vmDimCustomer AS
SELECT
    CustomerID,
    CompanyName,
    Country
FROM Northwind.dbo.Customers;
GO

-- vmDimEmployee
CREATE VIEW vmDimEmployee AS
SELECT
    EmployeeID,
    FirstName + ' ' + LastName AS FullName,
    Title,
    Country
FROM Northwind.dbo.Employees;
GO

-- vmDimShipper
CREATE VIEW vmDimShipper AS
SELECT
    ShipperID,
    CompanyName
FROM Northwind.dbo.Shippers;
GO

-- vmDimCategory
CREATE VIEW vmDimCategory AS
SELECT
    CategoryID,
    CategoryName
FROM Northwind.dbo.Categories;
GO

-- vmDimSupplier
CREATE VIEW vmDimSupplier AS
SELECT
    SupplierID,
    CompanyName,
    Country
FROM Northwind.dbo.Suppliers;
GO

-- vmDimProduct
CREATE VIEW vmDimProduct AS
SELECT
    ProductID,
    ProductName,
    SupplierID AS SupplierID_OLTP,
    CategoryID AS CategoryID_OLTP,
    CAST(UnitPrice AS DECIMAL(18,4)) AS UnitPrice
FROM Northwind.dbo.Products;
GO

-- Procedimientos almacenados para finalmente cargar los datos en las Dimension Tables

USE DWHNorthwindOrders;
GO

-- LoadDimCustomer
CREATE PROCEDURE LoadDimCustomer
    @CustomerID NCHAR(5),
    @CompanyName NVARCHAR(100),
    @Country NVARCHAR(50)
AS
BEGIN
    INSERT INTO Dimension.Customer (CustomerID, CompanyName, Country)
    VALUES (@CustomerID, @CompanyName, @Country);
END;
GO

-- LoadDimEmployee
CREATE PROCEDURE LoadDimEmployee
    @EmployeeID INT,
    @FullName NVARCHAR(150),
    @Title NVARCHAR(100),
    @Country NVARCHAR(50)
AS
BEGIN
    INSERT INTO Dimension.Employee (EmployeeID, FullName, Title, Country)
    VALUES (@EmployeeID, @FullName, @Title, @Country);
END;
GO

-- LoadDimShipper
CREATE PROCEDURE LoadDimShipper
    @ShipperID INT,
    @CompanyName NVARCHAR(100)
AS
BEGIN
    INSERT INTO Dimension.Shipper (ShipperID, CompanyName)
    VALUES (@ShipperID, @CompanyName);
END;
GO

-- LoadDimCategory
CREATE PROCEDURE LoadDimCategory
    @CategoryID INT,
    @CategoryName NVARCHAR(50)
AS
BEGIN
    INSERT INTO Dimension.Category (CategoryID, CategoryName)
    VALUES (@CategoryID, @CategoryName);
END;
GO

-- LoadDimSupplier
CREATE PROCEDURE LoadDimSupplier
    @SupplierID INT,
    @CompanyName NVARCHAR(100),
    @Country NVARCHAR(50)
AS
BEGIN
    INSERT INTO Dimension.Supplier (SupplierID, CompanyName, Country)
    VALUES (@SupplierID, @CompanyName, @Country);
END;
GO

-- LoadDimProduct
CREATE PROCEDURE LoadDimProduct
    @ProductID INT,
    @ProductName NVARCHAR(100),
    @SupplierID INT,
    @CategoryID INT,
    @UnitPrice DECIMAL(18,4)
AS
BEGIN
    DECLARE @SupplierKey INT, @CategoryKey INT;

    SELECT @SupplierKey = SupplierKey
    FROM Dimension.Supplier
    WHERE SupplierID = @SupplierID;

    SELECT @CategoryKey = CategoryKey
    FROM Dimension.Category
    WHERE CategoryID = @CategoryID;

    INSERT INTO Dimension.[Product] (
        ProductID, ProductName, SupplierKey_FK, CategoryKey_FK, UnitPrice
    )
    VALUES (
        @ProductID, @ProductName, @SupplierKey, @CategoryKey, @UnitPrice
    );
END;
GO
