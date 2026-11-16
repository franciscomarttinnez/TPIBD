/*
  Sistema de Gestión para Concesionaria
  Script 1/3 - Creación de base de datos y tablas (SQL Server)
*/
USE master;
GO

-- Recrea la BD si ya existe
IF DB_ID(N'Concesionaria') IS NOT NULL
BEGIN
    ALTER DATABASE Concesionaria SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Concesionaria;
END
GO

CREATE DATABASE Concesionaria;
GO

USE Concesionaria;
GO

/* ========== VEHÍCULO / MODELO / MARCA ========== */

CREATE TABLE MARCA (
    nombre       VARCHAR(50)  NOT NULL,
    pais_origen  VARCHAR(50)  NOT NULL,
    CONSTRAINT PK_MARCA PRIMARY KEY (nombre)
);

CREATE TABLE MODELO (
    id_modelo         INT            NOT NULL,
    denominacion      VARCHAR(50)    NOT NULL,
    version           VARCHAR(50)    NOT NULL,
    anio_fabricacion  SMALLINT       NOT NULL,
    precio_lista      DECIMAL(12,2)  NOT NULL,
    activo            BIT            NOT NULL CONSTRAINT DF_MODELO_activo DEFAULT (1),
    nombre_marca      VARCHAR(50)    NOT NULL,
    CONSTRAINT PK_MODELO PRIMARY KEY (id_modelo),
    CONSTRAINT FK_MODELO_MARCA FOREIGN KEY (nombre_marca) REFERENCES MARCA(nombre)
);

/* ========== SUCURSAL / EMPLEADO ========== */

CREATE TABLE SUCURSAL (
    codigo_suc  VARCHAR(10)   NOT NULL,
    nombre      VARCHAR(50)   NOT NULL,
    direccion   VARCHAR(100)  NOT NULL,
    telefono    VARCHAR(20)   NOT NULL,
    correo      VARCHAR(100)  NOT NULL,
    CONSTRAINT PK_SUCURSAL PRIMARY KEY (codigo_suc)
);

CREATE TABLE EMPLEADO (
    legajo           INT           NOT NULL,
    nombre_completo  VARCHAR(100)  NOT NULL,
    fecha_ingreso    DATE          NOT NULL,
    telefono         VARCHAR(20)   NOT NULL,
    correo           VARCHAR(100)  NOT NULL,
    cod_sucursal     VARCHAR(10)   NOT NULL,
    CONSTRAINT PK_EMPLEADO PRIMARY KEY (legajo),
    CONSTRAINT FK_EMPLEADO_SUCURSAL FOREIGN KEY (cod_sucursal) REFERENCES SUCURSAL(codigo_suc)
);

-- Especialización disjunta: VENDEDOR / ADMINISTRATIVO
CREATE TABLE VENDEDOR (
    legajo INT NOT NULL,
    CONSTRAINT PK_VENDEDOR PRIMARY KEY (legajo),
    CONSTRAINT FK_VENDEDOR_EMPLEADO FOREIGN KEY (legajo) REFERENCES EMPLEADO(legajo)
);

CREATE TABLE ADMINISTRATIVO (
    legajo INT NOT NULL,
    CONSTRAINT PK_ADMINISTRATIVO PRIMARY KEY (legajo),
    CONSTRAINT FK_ADMINISTRATIVO_EMPLEADO FOREIGN KEY (legajo) REFERENCES EMPLEADO(legajo)
);

/* ========== ADQUISICIÓN / PROVEEDOR ========== */

CREATE TABLE PROVEEDOR (
    cuit          VARCHAR(11)   NOT NULL,
    razon_social  VARCHAR(100)  NOT NULL,
    domicilio     VARCHAR(100)  NOT NULL,
    telefono      VARCHAR(20)   NOT NULL,
    correo        VARCHAR(100)  NOT NULL,
    CONSTRAINT PK_PROVEEDOR PRIMARY KEY (cuit)
);

CREATE TABLE ADQUISICION (
    num_comprobante  VARCHAR(20)    NOT NULL,
    fecha            DATE           NOT NULL,
    tipo_comprobante VARCHAR(20)    NOT NULL,
    importe_total    DECIMAL(14,2)  NOT NULL,
    cuit_proveedor   VARCHAR(11)    NOT NULL,
    CONSTRAINT PK_ADQUISICION PRIMARY KEY (num_comprobante),
    CONSTRAINT FK_ADQUISICION_PROVEEDOR FOREIGN KEY (cuit_proveedor) REFERENCES PROVEEDOR(cuit)
);

-- num_comprobante NULL: unidad ingresada por parte de pago (sin adquisición)
CREATE TABLE UNIDAD_VEHICULO (
    num_serie       VARCHAR(17)    NOT NULL,
    num_motor       VARCHAR(20)    NOT NULL,
    color           VARCHAR(20)    NOT NULL,
    fecha_ingreso   DATE           NOT NULL,
    condicion       VARCHAR(10)    NOT NULL,
    precio_venta    DECIMAL(12,2)  NOT NULL,
    estado_actual   VARCHAR(20)    NOT NULL,
    id_modelo       INT            NOT NULL,
    codigo_suc      VARCHAR(10)    NOT NULL,
    num_comprobante VARCHAR(20)    NULL,
    CONSTRAINT PK_UNIDAD_VEHICULO PRIMARY KEY (num_serie),
    CONSTRAINT FK_UNIDAD_MODELO FOREIGN KEY (id_modelo) REFERENCES MODELO(id_modelo),
    CONSTRAINT FK_UNIDAD_SUCURSAL FOREIGN KEY (codigo_suc) REFERENCES SUCURSAL(codigo_suc),
    CONSTRAINT FK_UNIDAD_ADQUISICION FOREIGN KEY (num_comprobante) REFERENCES ADQUISICION(num_comprobante),
    CONSTRAINT CK_UNIDAD_condicion CHECK (condicion IN ('Nuevo', 'Usado')),
    CONSTRAINT CK_UNIDAD_estado CHECK (estado_actual IN ('Disponible', 'Reservado', 'Vendido', 'Fuera de exhibición'))
);

/* ========== CLIENTE / VENTA ========== */

-- PK compuesta: tipo_documento + num_documento
CREATE TABLE CLIENTE (
    tipo_documento   VARCHAR(10)   NOT NULL,
    num_documento    VARCHAR(20)   NOT NULL,
    nombre_completo  VARCHAR(100)  NOT NULL,
    domicilio        VARCHAR(150)  NOT NULL,
    correo           VARCHAR(100)  NOT NULL,
    CONSTRAINT PK_CLIENTE PRIMARY KEY (tipo_documento, num_documento)
);

CREATE TABLE CONTACTO_TELEFONICO (
    tipo_documento   VARCHAR(10)   NOT NULL,
    num_documento    VARCHAR(20)   NOT NULL,
    telefono         VARCHAR(20)   NOT NULL,
    nombre_contacto  VARCHAR(100)  NOT NULL,
    CONSTRAINT PK_CONTACTO_TELEFONICO PRIMARY KEY (tipo_documento, num_documento, telefono),
    CONSTRAINT FK_CONTACTO_CLIENTE FOREIGN KEY (tipo_documento, num_documento)
        REFERENCES CLIENTE(tipo_documento, num_documento)
);

CREATE TABLE PLANES (
    cod_plan                 VARCHAR(10)   NOT NULL,
    descripcion              VARCHAR(50)   NOT NULL,
    porcentaje_financiacion  DECIMAL(5,2)  NOT NULL,
    cantidad_cuotas          SMALLINT      NOT NULL,
    interes_anual            DECIMAL(5,2)  NOT NULL,
    CONSTRAINT PK_PLANES PRIMARY KEY (cod_plan)
);

CREATE TABLE ACCESORIO (
    codigo       VARCHAR(10)    NOT NULL,
    descripcion  VARCHAR(100)   NOT NULL,
    precio       DECIMAL(12,2)  NOT NULL,
    disponible   BIT            NOT NULL CONSTRAINT DF_ACCESORIO_disponible DEFAULT (1),
    CONSTRAINT PK_ACCESORIO PRIMARY KEY (codigo)
);

-- cod_plan NULL: venta sin financiación
CREATE TABLE BOLETO (
    num_boleto       INT            NOT NULL,
    fecha_emision    DATE           NOT NULL,
    importe_total    DECIMAL(14,2)  NOT NULL,
    estado           VARCHAR(15)    NOT NULL,
    cod_plan         VARCHAR(10)    NULL,
    legajo_vendedor  INT            NOT NULL,
    tipo_documento   VARCHAR(10)    NOT NULL,
    num_documento    VARCHAR(20)    NOT NULL,
    num_serie        VARCHAR(17)    NOT NULL,
    CONSTRAINT PK_BOLETO PRIMARY KEY (num_boleto),
    CONSTRAINT FK_BOLETO_PLAN FOREIGN KEY (cod_plan) REFERENCES PLANES(cod_plan),
    CONSTRAINT FK_BOLETO_VENDEDOR FOREIGN KEY (legajo_vendedor) REFERENCES VENDEDOR(legajo),
    CONSTRAINT FK_BOLETO_CLIENTE FOREIGN KEY (tipo_documento, num_documento)
        REFERENCES CLIENTE(tipo_documento, num_documento),
    CONSTRAINT FK_BOLETO_UNIDAD FOREIGN KEY (num_serie) REFERENCES UNIDAD_VEHICULO(num_serie),
    CONSTRAINT CK_BOLETO_estado CHECK (estado IN (N'en negociación', N'confirmado', N'cancelado'))
);

CREATE TABLE PAGO (
    id_pago           INT            NOT NULL,
    fecha_vencimiento DATE           NOT NULL,
    importe           DECIMAL(12,2)  NOT NULL,
    estado            VARCHAR(15)    NOT NULL,
    num_boleto        INT            NOT NULL,
    CONSTRAINT PK_PAGO PRIMARY KEY (id_pago),
    CONSTRAINT FK_PAGO_BOLETO FOREIGN KEY (num_boleto) REFERENCES BOLETO(num_boleto),
    CONSTRAINT CK_PAGO_estado CHECK (estado IN (N'pendiente', N'pagado', N'vencido'))
);

-- Unidad usada entregada como parte de pago (distinta de BOLETO.num_serie)
CREATE TABLE PARTE_PAGO (
    num_boleto        INT            NOT NULL,
    num_serie         VARCHAR(17)    NOT NULL,
    valor_reconocido  DECIMAL(12,2)  NOT NULL,
    CONSTRAINT PK_PARTE_PAGO PRIMARY KEY (num_boleto, num_serie),
    CONSTRAINT FK_PARTE_PAGO_BOLETO FOREIGN KEY (num_boleto) REFERENCES BOLETO(num_boleto),
    CONSTRAINT FK_PARTE_PAGO_UNIDAD FOREIGN KEY (num_serie) REFERENCES UNIDAD_VEHICULO(num_serie)
);

-- Tabla puente N:N entre BOLETO y ACCESORIO
CREATE TABLE BOLETO_ACCESORIO (
    num_boleto  INT          NOT NULL,
    codigo      VARCHAR(10)  NOT NULL,
    CONSTRAINT PK_BOLETO_ACCESORIO PRIMARY KEY (num_boleto, codigo),
    CONSTRAINT FK_BA_BOLETO FOREIGN KEY (num_boleto) REFERENCES BOLETO(num_boleto),
    CONSTRAINT FK_BA_ACCESORIO FOREIGN KEY (codigo) REFERENCES ACCESORIO(codigo)
);
GO
