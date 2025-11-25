create database campusx_project3;

use campusx_project3;

create table Supplier(
supplier_id int primary key identity(1,1),
supplier_code nvarchar(10) unique not null,
supplier_name nvarchar(50)
);


create table Customer(
Customer_id int primary key identity(1,1),
Customer_code  nvarchar(10) unique not null,
Customer_name nvarchar(100)
);

create table RawMaterial(
Material_id int  primary key identity(1,1),
Material_name varchar(30),
Material_grade nvarchar(30)
constraint unique_material Unique(Material_name,Material_grade)
);

drop table machines
create table Machines(
Machine_id int primary key identity(1,1),
Machine_code nvarchar(10) unique not null,
Machine_name nvarchar(30) not null,
Machine_Type varchar(50),
Plant_id nvarchar(10) not null,
Last_maintainance_date date
);


create table Production(
Production_id int primary key identity(1,1),
Production_code nvarchar(10) unique not null,
Customer_id int not null,
Component_to_produce nvarchar(20) not null,
Quantity_to_produce int not null,
Order_date datetime not null,
Schedule_start_date datetime not null,
Schedule_end_date datetime not null,
[Status] varchar(50) not null,
Assigned_machine_id int not null,
Plant_id nvarchar(10) not null,
Foreign key (Customer_id) references Customer(Customer_id),
Foreign Key (Assigned_Machine_id) references Machines(Machine_id),
Constraint chk_status check (status in ('Scheduled','inprogress','Complete','On-Hold','Cancelled','Rework required','Quoted','Pending Material','Rework Completed')),
Constraint Date_chk check (Schedule_start_date>=Order_date),
Constraint Datchk_process check(Schedule_end_date>=Schedule_start_date)
);
-------------------------------------------------------------------------------------------
alter table production
drop constraint FK__Productio__Custo__59063A47
alter table production
drop constraint FK__Productio__Assig__59FA5E80
alter table production 
add  Foreign key (customer_id) references customer(customer_id)
alter table production 
add  Foreign key (Assigned_Machine_id) references Machines(Machine_id)
--------------------------------------------------------------------------------------------


create table MaterialInventory(
Batch_id int primary key identity(1,1),
Original_Batch_id nvarchar(50) unique,
Material_id int not null,
Supplier_id int not null,
Recieved_date date not null,
Initial_quantity decimal(10,2) not null,
Remaining_quantity decimal(10,2) not null,
Unit varchar(10),
Foreign key (Material_id) references RawMaterial(Material_id),
Foreign key (Supplier_id) references Supplier(Supplier_id)
);


Create table Product_Material_Usage(
Usage_id int primary key identity(1,1),
Production_order_id int not null,
Batch_id int not null,
Quantity_Used decimal(10,2) not null,
Foreign key (Production_order_id) references Production(Production_id),
Foreign key (Batch_id) references MaterialInventory(Batch_id)
);


create table Employee(
Employee_id int primary key identity(1,1),
Full_name nvarchar(100) not null,
[Role] nvarchar(50) not null
);


create table Quality_check(
Quality_chk_id int primary key identity(1,1),
Original_Quantity_chk_id nvarchar(50),
Production_Order_id int not null,
Inspector_id int not null,
Check_timestamp datetime not null,
Result nvarchar(10),
Foreign key (Production_order_id) references Production(Production_id),
Foreign key (Inspector_id) references Employee(employee_id)
);


-------------------- --------MIGRATION OF DATA FROM ORIGINAL DATA SOURCE TO MY DATABASE------------------------------


------ Supplier------

select distinct SupplierID from ABC_10000;
select distinct Suppliername from ABC_10000;
select distinct SupplierID,Suppliername from ABC_10000;

alter table Supplier
drop UQ__Supplier__A82CE4694C8E2836

alter table Supplier
drop column Supplier_code

-- insert into Supplier Table

insert into Supplier

select distinct
	case
		when Suppliername like '%Global Metals%' then 'GlobalMetals'
		when Suppliername like '%PlasticPro' then 'PlasticPro Inc.'
		when Suppliername like '%Copper Co.' then 'CopperCo'
		when Suppliername like '%Steel Corp' then 'SteelCorp'
		when Suppliername like 'Alu Works' then 'AluWorks'
	else Suppliername
	end
	from abc_10000 where suppliername is  not null;

select * from Supplier


---- Customer-----


select distinct CustomerOrderID from ABC_10000;
select distinct CustomerName from ABC_10000;
select distinct CustomerOrderID,CustomerName from ABC_10000;



alter table customer 
drop UQ__Customer__40FA0809A9F1778E

alter table Customer
drop column Customer_code


--- insert into Customer Table


insert into Customer(Customer_name)
select distinct CustomerName from ABC_10000


select * from Customer


------ RawMaterial-------


select distinct MaterialName from ABC_10000;
select distinct MaterialGrade from ABC_10000;
select distinct MaterialName,MaterialGrade from ABC_10000;

--insert into RawMaterial

insert into RawMaterial(Material_name,Material_grade)
select distinct MaterialName,MaterialGrade from ABC_10000;

select * from RawMaterial;


------Machines-------

---Machine Names--
select distinct Trim(Replace(Replace(MachineName,'P2-',''),'P1-','')) from ABC_10000;
---Machine code--
select distinct MachineID from ABC_10000;
select distinct MachineID,MachineName from ABC_10000;
alter table Machines
drop UQ__Machines__EF5981170F7AA8D6;
alter table Machines
drop column Machine_code

---Machine Type--
select distinct trim(MachineType) from ABC_10000;
---Plant ID--
select distinct left(MachineName,2) from ABC_10000;

---insert into Machines
insert into Machines(Machine_name,Machine_Type,Plant_id,Last_maintainance_date)
select Trim(Replace(Replace(MachineName,'P2-',''),'P1-','')),trim(MachineType),left(MachineName,2),MAX(Try_Convert(Date,LastMaintenanceDate)) from ABC_10000
group by Trim(Replace(Replace(MachineName,'P2-',''),'P1-','')),trim(MachineType),left(MachineName,2) 

select * from Machines;

-----------Material Inventory--------------

select * from ABC_10000;
select * from MaterialInventory;


--Original Batch id--
select distinct RawMaterialBatchID from ABC_10000;
select distinct left(RawMaterialBatchID,7) from ABC_10000;

-- Material ID

--Supplier ID--


--Recived Date--
select Try_Convert(date,ReceiveDate,105) from ABC_10000;

---Initial_Quantity---
select InitialQuantity from ABC_10000;
select InitialQuantity From ABC_10000 where InitialQuantity like '%[^0-9.]%';

--cleaning 
select cast(cast(replace(replace(replace(replace(InitialQuantity,',',''),'$',''),'E+',''),' ','') as float) as decimal(10,2)) from ABC_10000;


---Remaining Quantity---
--Can not filled as this stage


----Constraints----
alter table MaterialInventory
add constraint chk_units CHECK(Unit in ('KG','M','PCS','FT','SQ_FT'))



alter table MaterialInventory
drop  chk_units;
alter table MaterialInventory
add constraint chk_units CHECK(Unit in ('KG','M','PCS','FT','SQ_FT','lbs'));

---Units---

select unit,
	case 
		when UPPER(TRIM(UNIT)) in ('KG','KILOGRAM','KGS') then 'KG'
		when UPPER(TRIM(UNIT)) in ('M','METER','METERS') then 'M'
		when UPPER(TRIM(UNIT)) in ('PCS','PIECES') then 'PCS'
		when UPPER(TRIM(UNIT)) in ('FT','FEET') then 'FT'
		when UPPER(TRIM(UNIT)) in ('SQ_FT','SQUARE FEET') then 'SQ_FT'
		when UPPER(TRIM(UNIT)) = 'LBS' then 'LBS'
		else null
		end as StandardUnit
FROM ABC_10000;

with T as (
	select distinct left(RawMaterialBatchID,7) as RawMaterialID,Try_Convert(date,ReceiveDate,105) as RECEIVEDDATE,
	cast(cast(replace(replace(replace(replace(InitialQuantity,',',''),'$',''),'E+',''),' ','') as float) as decimal(10,2)) AS INITIALQUANTITY,
	case 
		when UPPER(TRIM(UNIT)) in ('KG','KILOGRAM','KGS') then 'KG'
		when UPPER(TRIM(UNIT)) in ('M','METER','METERS') then 'M'
		when UPPER(TRIM(UNIT)) in ('PCS','PIECES') then 'PCS'
		when UPPER(TRIM(UNIT)) in ('FT','FEET') then 'FT'
		when UPPER(TRIM(UNIT)) in ('SQ_FT','SQUARE FEET') then 'SQ_FT'
		when UPPER(TRIM(UNIT)) = 'LBS' then 'LBS'
		else null
		end as StandardUnit
FROM Dummy
)

select * from T;

select * from Dummy;
select * INTO Dummy from ABC_10000;


UPDATE Dummy  
SET SupplierName = 
LTRIM(RTRIM(case
		when Suppliername like '%Global Metals%' then 'GlobalMetals'
		when Suppliername like '%PlasticPro' then 'PlasticPro Inc.'
		when Suppliername like '%Copper Co.' then 'CopperCo'
		when Suppliername like '%Steel Corp' then 'SteelCorp'
		when Suppliername like 'Alu Works' then 'AluWorks'
	else Suppliername
	end))

select Distinct SupplierName From ABC_10000;
select Distinct SupplierName FROM Dummy where SupplierName IS not null;



-- RAW MATERIAL TABLE
-- ABC[T]--- SUPPLIER   (SUPPLIER NAME)
-- ABC[]--- RAW MATERIAL TABLE( MATERIALNAME, MATERIALGRADE)

with T as (
	select distinct left(RawMaterialBatchID,7) as RawMaterialID,Try_Convert(date,ReceiveDate,105) as RECEIVEDDATE,
	cast(cast(replace(replace(replace(replace(InitialQuantity,',',''),'$',''),'E+',''),' ','') as float) as decimal(10,2)) AS INITIALQUANTITY,
	case 
		when UPPER(TRIM(UNIT)) in ('KG','KILOGRAM','KGS') then 'KG'
		when UPPER(TRIM(UNIT)) in ('M','METER','METERS') then 'M'
		when UPPER(TRIM(UNIT)) in ('PCS','PIECES') then 'PCS'
		when UPPER(TRIM(UNIT)) in ('FT','FEET') then 'FT'
		when UPPER(TRIM(UNIT)) in ('SQ_FT','SQUARE FEET') then 'SQ_FT'
		when UPPER(TRIM(UNIT)) = 'LBS' then 'LBS'
		else null
		end as StandardUnit,SupplierName,MaterialName,MaterialGrade
FROM Dummy
)
select T.RawMaterialID,m.Material_id,s.supplier_id,t.RECEIVEDDATE,t.INITIALQUANTITY,t.STANDARDUNIT 
from T INNER JOIN
Supplier as s on s.supplier_name = t.SupplierName
INNER JOIN  RawMaterial as m
on m.Material_grade = T.MaterialGrade and  m.Material_name = T.MaterialName;


 
with T as (
	select distinct left(RawMaterialBatchID,7) as RawMaterialID,Try_Convert(date,ReceiveDate,105) as RECEIVEDDATE,
	cast(cast(replace(replace(replace(replace(InitialQuantity,',',''),'$',''),'E+',''),' ','') as float) as decimal(10,2)) AS INITIALQUANTITY,
	case 
		when UPPER(TRIM(UNIT)) in ('KG','KILOGRAM','KGS') then 'KG'
		when UPPER(TRIM(UNIT)) in ('M','METER','METERS') then 'M'
		when UPPER(TRIM(UNIT)) in ('PCS','PIECES') then 'PCS'
		when UPPER(TRIM(UNIT)) in ('FT','FEET') then 'FT'
		when UPPER(TRIM(UNIT)) in ('SQ_FT','SQUARE FEET') then 'SQ_FT'
		when UPPER(TRIM(UNIT)) = 'LBS' then 'LBS'
		else null
		end as StandardUnit,SupplierName,MaterialName,MaterialGrade
FROM Dummy
)
INSERT INTO MaterialInventory(Original_Batch_id,Material_id,Supplier_id,Recieved_date,Initial_quantity,Unit)
select T.RawMaterialID,m.Material_id,s.supplier_id,t.RECEIVEDDATE,t.INITIALQUANTITY,t.STANDARDUNIT 
from T INNER JOIN
Supplier as s on s.supplier_name = t.SupplierName
INNER JOIN  RawMaterial as m
on m.Material_grade = T.MaterialGrade and  m.Material_name = T.MaterialName;

--remove
alter table materialinventory
alter column remaining_quantity decimal(9,2) null

alter table Materialinventory
drop UQ__Material__5CAF999AF5769D58

select * from MaterialInventory;

--- To orginate Default constarint from 1 use this command

delete from MaterialInventory
dbcc checkident('MaterialInventory',reseed,0)

select * from MaterialInventory;


--------Production--------

select * from Production;
select * from Dummy;

-- 60% -- DATA IS FROM ABC
-- 10% CUSTOMER --- CUSTOMERS ID 
-- 30% MACHINES ---- MACHINE ID AND PLANT ID

--- Production Code---
select distinct ProductionOrderID from ABC_10000;
select replace(replace(ProductionOrderID,'/','-'),'_','-') from ABC_10000;

select Distinct Right(replace(replace(ProductionOrderID,'/','-'),'_','-'),4) from ABC_10000;

---Customer ID---
select * from Customer;
select * from Dummy as D
Inner Join Customer as c
on c.Customer_name = D.CustomerName


--- Component To Produce---
select Componenttoproduce from ABC_10000;

--- Quantity To Produce---
select QuantityToProduce from ABC_10000

select cast(ceiling(QuantityToProduce) as int)  from ABC_10000;


---Order date---
select OrderDate from ABC_10000;
select coalesce(TRY_CONVERT(datetime,OrderDate,105),TRY_CONVERT(datetime,OrderDate,110)) from ABC_10000;

--- Schedule Start and Schedule End Date---
select TRY_CONVERT(datetime,ScheduledStart,105),TRY_CONVERT(datetime,ScheduledEnd,105) from ABC_10000;

---Status---
select Distinct status from ABC_10000;



--- Machine ID and Plant ID ---

select * from Machines;
select * from ABC_10000;

update dummy
set MachineName = Trim(Replace(Replace(MachineName,'P2-',''),'P1-','')),
MachineType = trim(MachineType)

select * from Dummy;

select * from Machines as M
inner join Dummy as D
on D.MachineName = M.Machine_Name and D.MachineType = M.Machine_Type;

--- Data Selection

select Right(replace(replace(d.ProductionOrderID,'/','-'),'_','-'),4) as Original_ProductionID ,c.Customer_id,d.Componenttoproduce,
cast(ceiling(QuantityToProduce) as int) as Quantity_To_Produce,coalesce(TRY_CONVERT(datetime,OrderDate,105),TRY_CONVERT(datetime,OrderDate,110)) as Order_date,
TRY_CONVERT(datetime,ScheduledStart,105) as Scheduledstart,TRY_CONVERT(datetime,ScheduledEnd,105) as ScheduledEnd ,
d.status,m.Machine_Id,m.Plant_Id from Dummy d
inner join Customer c on c.Customer_name = d.CustomerName
inner join Machines m on m.Machine_name = d.MachineName and m.Machine_Type = d.MachineType


--- data Insertion

Insert into Production
select Right(replace(replace(d.ProductionOrderID,'/','-'),'_','-'),4) as Original_ProductionID ,c.Customer_id,d.Componenttoproduce,
cast(ceiling(QuantityToProduce) as int) as Quantity_To_Produce,coalesce(TRY_CONVERT(datetime,OrderDate,105),TRY_CONVERT(datetime,OrderDate,110)) as Order_date,
TRY_CONVERT(datetime,ScheduledStart,105) as Scheduledstart,TRY_CONVERT(datetime,ScheduledEnd,105) as ScheduledEnd ,
d.status,m.Machine_Id,m.Plant_Id from Dummy d
inner join Customer c on c.Customer_name = d.CustomerName
inner join Machines m on m.Machine_name = d.MachineName and m.Machine_Type = d.MachineType
where TRY_CONVERT(datetime, ScheduledEnd,105)>=TRY_CONVERT(datetime, ScheduledStart, 105)and TRY_CONVERT(datetime, ScheduledStart, 105)>= coalesce(
          TRY_CONVERT(datetime, OrderDate,105),
		  TRY_CONVERT(datetime, OrderDate,110))
---editing

alter table Production
drop UQ__Producti__355021E9220E0786


alter table Production
drop constraint chk_status

alter table Production
add Constraint chk_status check (status in ('Scheduled','In Progress','Completed','On Hold','Cancelled','Rework Required','Quoted','Pending Materials','Rework Complete'))
 
 select * from Production;

 
delete  from PRODUCTION
dbcc  checkident('PRODUCTION', reseed, 0)


------------Product_material_Usage-------------
select * from Product_Material_Usage;
select * from Dummy;

-- Production_order_id from Production
-- Batch ID from MaterialInventory
--Quantity_used from dummy

---- ADD COLUMN MATERIAL ID
alter table Product_Material_Usage
add Material_id int

alter table Product_Material_Usage
add foreign key (Material_id) references RAWMATERIAL(Material_id);

update DUMMY 
set ProductionOrderID = RIGHT(REPLACE(REPLACE(PRODUCTIONORDERID,'/','-'),'_','-'),4),
    ScheduledStart= TRY_CONVERT(datetime, ScheduledStart, 105),
	ScheduledEnd= TRY_CONVERT(datetime, ScheduledEnd, 105),
	QuantityToProduce=  cast(ceiling(QuantityToProduce) as int)

select * from Dummy d inner join Production p
on p.Production_Code = d.ProductionOrderID and p.Schedule_start_date = d.ScheduledStart and p.Schedule_end_date = d.ScheduledEnd and 
p.Quantity_to_produce = d.QuantityToProduce and p.Component_to_produce = d.ComponentToProduce


---BatchID
select distinct Original_batch_id from MaterialInventory;
select distinct MaterialUsedBatchID from Dummy;
select * from Production
select * from MaterialInventory


select * from Product_Material_Usage
insert into Product_Material_Usage(Production_order_id,Batch_id,Quantity_used,Material_id)
select p.Production_id,m.Batch_id,d.Quantityused,m.Material_id from Dummy d
inner join Production p on  p.Production_Code = d.ProductionOrderID and p.Schedule_start_date = d.ScheduledStart and p.Schedule_end_date = d.ScheduledEnd and 
p.Quantity_to_produce = d.QuantityToProduce and p.Component_to_produce = d.ComponentToProduce
inner join MaterialInventory m on m.Original_Batch_id = d.MaterialUsedBatchID

---editing--------------------------------------------
alter table Product_Material_Usage
alter column Quantity_used decimal (10,2) null 

delete  from Product_Material_Usage
dbcc checkident('Product_Material_Usage',reseed)
------------------------------------------------------

select * from MaterialInventory
update m
set m.Remaining_quantity = m.initial_quantity - p.quantity_used
from Product_Material_Usage p
inner join MaterialInventory m
on m.Batch_id = p.batch_id and p.Material_id =  m.Material_id

update MATERIALINVENTORY
set REMAINING_QUANTITY= INITIAL_QUANTITY where REMAINING_QUANTITY is null


---------Employee---------

select * from Employee
insert into Employee values
('John Doe', 'Quality Inspector'),
('Jane Smith', 'Quality Inspector'),
('Peter Jones', 'Plant Manager'),
    ('Mary Williams', 'Quality Inspector'),
    ('David Brown', 'Operator'),
    ('Susan Miller', 'Quality Inspector'),
    ('Robert Johnson', 'Plant Manager'),
    ('Karen White', 'Operator'),
    ('Michael Lee', 'Quality Inspector'),
    ('Patricia Garcia', 'Operator'),
    ('James Rodriguez', 'Operator'),
    ('Linda Martinez', 'Quality Inspector'),
    ('Charles Hernandez', 'Plant Manager'),
    ('Barbara Lopez', 'Operator'),
    ('Thomas Gonzalez', 'Quality Inspector')


select * from Quality_check
select * from dummy

-- col2 -dummy,col3 -Production,col4 -employee,col5,6-dummy

--Original_Quantity_chk_id
select distinct QualityCheckID from Dummy where QualityCheckID is not null ;

select * from Dummy d 
inner join Production p on d.ProductionOrderID= p.Production_code and d.ScheduledStart= p.Schedule_start_date and 
d.ScheduledEnd= p.Schedule_end_date and d.QuantityToProduce= p.Quantity_to_produce and d.ComponentToProduce= p.Component_to_produce
where QualityCheckID is not null;

select *,try_convert(datetime, d.CheckTimestamp, 105) from DUMMY as d
inner join PRODUCTION as p 
on d.ProductionOrderID= p.Production_code and d.ScheduledStart= p.Schedule_start_date and 
d.ScheduledEnd= p.Schedule_end_date and d.QuantityToProduce= p.Quantity_to_produce and d.ComponentToProduce= p.Component_to_produce
inner join employee as e on e.Full_name= d.InspectorName where QualityCheckID is not null;



insert into Quality_check(Original_Quantity_chk_id, Production_Order_id, Inspector_id, Check_timestamp, Result)
select d.QualityCheckID, p.PRODUCTION_ID, e.Employee_id,try_convert(datetime, d.CheckTimestamp, 105), d.Result from DUMMY as d
inner join PRODUCTION as p 
on d.ProductionOrderID= p.PRODUCTION_CODE and d.ScheduledStart= p.Schedule_start_date and d.ScheduledEnd= p.Schedule_end_date 
and d.QuantityToProduce= p.Quantity_to_produce and d.ComponentToProduce= p.Component_to_produce 
inner join employee as e on e.Full_name= d.InspectorName where QualityCheckID is not null;

alter table Quality_check
alter column Check_timestamp datetime null;

select * from Quality_check;

delete from Quality_check
dbcc checkident('Quality_check',reseed,0)

--------------------------------------------------------DATA INSERION COMPLETE----------------------------------------------------------


---- SCENERIO - 1
-- QUALITY CHECK - FAILED , 



-- SCENERIO 2
-- PRODUCTION MATERIAL USAGE -- TABLE --- UPDATED ANY QUANTITY, OR INSERTED ANY NEW ROW ,
-- MATERIAL INVENTORY -- REMAINING QUANTITY


-- SCENERIO 3 

-- NEW PRODUCTION --- INSERT  OR UPDATING SCHEDULE FOR ANY PRODUCTION --- MACHINE THAT IS  TO BE USED IS FREE OF NOT.



-- SCENERIO 4
-- MATERIAL INVENTORY TABLE , I HAVE NO ALARMING SYSTEM.


----------------------------------------------------------------------------------------------------------------------------
-- SCENERIO 1

select * from Quality_check
select * from Production where production_id = 352

--- QUALITY --- FAILED --- PRODUCTION ID --- PRODUCTION TABLE -- STATUS -- UPDATE
update Production
set [status]  = 'Rework Required'
where Production_id in (
select production_order_id from Quality_check 
where Result  = 'Failed'
)

-- Infuture quality result failed , look for the production id  and for that production id , update the status as rework required.
-- trigger - quality check -- after insert 


create trigger updateProductionStatus_onfail
on Quality_check
after insert
as 
begin
		update  P
		set p.[status] = 'Rework Required'
		from inserted i
		inner join Production p
		on p.Production_id = i.Production_Order_id
		where Result = 'Failed'
end

insert into Quality_check(Original_Quantity_chk_id, Production_Order_id, Inspector_ID, Check_TimeStamp,Result)
values ('QC-283', 1,1, null, 'Failed')

select * from Product_Material_Usage
select * from MaterialInventory
	
--  Scenerio 2
-- any updations in my production material used table should make relative chnages in the inventory table.


create trigger trg_updatematerialRemaining
on Product_material_usage
after insert,update
as
begin
	if exists(select 1 from deleted)
	begin
	     update mi
		 set mi.remaining_quantity = mi.remaining_quantity+d.Quantity_Used
		 from deleted d
		 inner join MaterialInventory mi
		 on mi.batch_id = d.batch_id and mi.Material_id = d.Batch_id
	end
	update mi 
	set mi.remaining_quantity = mi.Remaining_quantity - i.Quantity_used
	from MaterialInventory mi 
	join inserted i on i.Batch_id = mi.Batch_id and i.Material_id = mi.Material_id

	if exists(select 1 from MaterialInventory mi
			  inner join inserted i 
			  on mi.Batch_id = i.Batch_id and mi.Material_id = i.Material_id
			  where mi.Remaining_quantity<0
			  )
	begin
		raiserror('Insufficient Material',16,1)
		rollback transaction
		return
	end
	
end

-- scenerio 3  avoidiong multiple machines to be scheduled at same time for different tasks

select * from Production
create trigger trg_CheckMachineSchedule
on Production 
after insert,update
as
begin
	if exists(
		select 1 from Production p
		join inserted i 
		on i.Assigned_machine_id = p.Assigned_machine_id
		and i.Production_id<>p.Production_id
		where 
			i.[status] not in ('Completed','Cancelled')
		and i.Schedule_start_date<p.Schedule_end_date 
		and i.Schedule_end_date<p.Schedule_start_date
		)
		begin
			Raiserror('Schedule conflict: The assigned machine is already occupied during this time period.', 16, 1);
			rollback Transaction ;
			return;
		end
end



----  SCENERIO 4 
-- MATERIAL INVENTORY -- KEEP AN ALARM ON MATERIALS WHOSE QUANTITY BECOMES LESS THAN 500 

CREATE TABLE MaterialLowStockLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    MaterialID INT NOT NULL,
    MaterialName NVARCHAR(100),
    MaterialGrade NVARCHAR(50),
    AlertTriggerQuantity DECIMAL(10, 2), -- How much was left when triggered
    QuantityToOrder DECIMAL(10, 2),      -- The new calculated column
    AlertDate DATETIME DEFAULT GETDATE()
);
select * from MaterialLowStockLog;

create trigger TRG_LOWSTOCK
on MaterialInventory
after insert,update
as
begin
	Insert into MaterialLowStockLog(materialID,MaterialName,AlertTriggerQuantity,MaterialGrade,QuantityToOrder)
	SELECT I.material_ID, M.MATERIAL_NAME, M.MATERIAL_GRADE, I.REMAINING_QUANTITY, (4000-I.REMAINING_QUANTITY) FROM inserted  I 
	INNER JOIN  RAWMATERIAL AS M ON I.Material_id= M.Material_id
	WHERE I.REMAINING_QUANTITY<500
end

