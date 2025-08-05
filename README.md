# Banking-Transaction-Batch-Processor

This COBOL batch program processes bank account transactions and updates account balances in a VSAM KSDS file.

System Overview
The system consists of three main components: 
1. VSAM KSDS file for storing account information
2. Transaction input file for processing
3. Overdraft report file for accounts with negative balances

File Structure
BANKUPD.cbl — Main COBOL program
BANKUPD.JCL — JCL to compile and run the program
INITDATA.JCL — JCL to load initial account data
OVERDRAFT.JCL — JCL to generate overdraft report

Data Files
VSAM KSDS File (ACCOUNTS)
Record format: FB
Record length: 80 bytes
Key: Account Number (10 bytes)
Fields:
Account Number (10 bytes)
Name (30 bytes)
Balance (15 bytes)
Transaction File (TRANSACTIONS)
Record format: FB
Record length: 50 bytes
Fields:
Account Number (10 bytes)
Transaction Type (1 byte)
Amount (15 bytes)
Overdraft Report File (OVERDRAFT)
Record format: FB
Record length: 80 bytes
Fields:
Account Number (10 bytes)
Name (30 bytes)
Balance (15 bytes)
Transaction Amount (15 bytes)
Transaction Types
'D' — Deposit
'W' — Withdrawal
Error Handling
Negative balances trigger an overdraft report
Invalid transaction types are skipped
Invalid account numbers are skipped
Requirements
COBOL compiler
VSAM support
JCL support

Usage
1. Load initial data using INITDATA.JCL
2. Process transactions using BANKUPD.JCL
3. Generate overdraft report using OVERDRAFT.JCL

Notes
All monetary values are stored as packed decimal
Account numbers must be 10 digits
Names are truncated to 30 characters
Amounts are stored with 2 decimal places
