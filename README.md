# 🏭 Manufacturing Operations Database Design & Automation (SQL Server)

### 📌 Project Tagline  
A complete SQL Server–based manufacturing database system with full data migration, workflow automation, and integrity enforcement.

---

## 📘 Overview

This project replaces a manufacturing company’s Excel-based operations with a fully structured SQL Server database.  
It covers database design, data migration, automation using triggers, and validation of production workflows.

The system manages:

- Suppliers & customers  
- Raw materials & batch inventory  
- Machines & maintenance  
- Production orders & scheduling  
- Material usage logging  
- Quality inspections  
- Low-stock alerts  

---

## 🗂️ Key Features

### **1️⃣ Normalized Relational Database (3NF)**
Includes structured tables for:
- Supplier  
- Customer  
- RawMaterial  
- Machines  
- Production  
- MaterialInventory  
- Product_Material_Usage  
- Employee  
- Quality_Check  
- MaterialLowStockLog  

All with:
- Primary & foreign keys  
- Unique constraints  
- Check constraints  
- Referential integrity  

---

### **2️⃣ Data Migration (10,000+ Records)**  
Performed complete ETL migration from Excel using SQL scripts:

- Standardized inconsistent units (KG, PCS, M, SQ_FT, LBS)  
- Normalized supplier & material names  
- Cleaned numeric fields and missing values  
- Converted multiple date formats using `TRY_CONVERT()`  
- Removed duplicate & invalid entries  
- Loaded final cleaned data into normalized tables  

---

### **3️⃣ Business Logic Automation (SQL Triggers)**  
Automated core production logic:

- ✔ Auto-set status to **"Rework Required"** when QC fails  
- ✔ Prevent **machine double-booking** in production scheduling  
- ✔ Update **remaining inventory** after material usage  
- ✔ Insert low-stock alerts when quantity < 500  

---

### **4️⃣ Data Validation & Integrity Rules**

- Prevented negative inventory  
- Enforced valid production statuses  
- Validated schedule timelines (Start ≥ Order, End ≥ Start)  
- Ensured unique material name + grade combinations  
- Restricted invalid units and inconsistent entries  

---

## 📊 Reporting Support

Database is structured to support:

- Machine utilization  
- Material consumption trends  
- Production performance  
- Supplier quality performance  
- Inventory status & procurement alerts  

---

## 🛠️ Tech Stack

| Component | Technology |
|----------|------------|
| Database | SQL Server |
| Language | MS SQL |
| ETL | SQL Scripts |
| Modeling | ER Diagram (3NF) |
| Automation | SQL Triggers, Constraints |

---

## 🧩 ER Diagram (Mermaid Format)

```mermaid
erDiagram

    Supplier ||--o{ MaterialInventory : supplies
    RawMaterial ||--o{ MaterialInventory : storedAs
    RawMaterial ||--o{ Product_Material_Usage : usedAs
    MaterialInventory ||--o{ Product_Material_Usage : batchSource

    Customer ||--o{ Production : places
    Machines ||--o{ Production : runsOn

    Production ||--o{ Product_Material_Usage : consumes
    Production ||--o{ Quality_check : inspectedFor
    Employee ||--o{ Quality_check : performs

    %% No direct FK in DB, but logged per material
    MaterialLowStockLog {
        int LogID
        int MaterialID
        string MaterialName
        string MaterialGrade
        decimal AlertTriggerQuantity
        decimal QuantityToOrder
        datetime AlertDate
    }


