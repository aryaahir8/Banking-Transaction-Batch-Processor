       IDENTIFICATION DIVISION.
       PROGRAM-ID. BANKUPD.
       AUTHOR. Cascade.
       DATE-WRITTEN. 2025-07-10.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCOUNTS-FILE
               ASSIGN TO ACCOUNTS
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS ACCOUNT-NUMBER
               FILE STATUS IS WS-FILE-STATUS.

           SELECT TRANSACTION-FILE
               ASSIGN TO TRANSACTIONS
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL.

           SELECT OVERDRAFT-FILE
               ASSIGN TO OVERDRAFT
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.

       FD  ACCOUNTS-FILE
           RECORDING MODE IS F
           RECORD LENGTH IS 80.
       01  ACCOUNT-RECORD.
           05  ACCOUNT-NUMBER         PIC X(10).
           05  ACCOUNT-NAME           PIC X(30).
           05  ACCOUNT-BALANCE        PIC S9(12)V99 COMP-3.

       FD  TRANSACTION-FILE
           RECORDING MODE IS F
           RECORD LENGTH IS 50.
       01  TRANSACTION-RECORD.
           05  TRANS-ACCOUNT-NUMBER   PIC X(10).
           05  TRANS-TYPE             PIC X.
           05  TRANS-AMOUNT           PIC S9(12)V99 COMP-3.

       FD  OVERDRAFT-FILE
           RECORDING MODE IS F
           RECORD LENGTH IS 80.
       01  OVERDRAFT-RECORD.
           05  OD-ACCOUNT-NUMBER      PIC X(10).
           05  OD-ACCOUNT-NAME        PIC X(30).
           05  OD-BALANCE             PIC S9(12)V99 COMP-3.
           05  OD-TRANSACTION-AMOUNT  PIC S9(12)V99 COMP-3.

       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUS             PIC XX.
       01  WS-EOF-FLAG               PIC X VALUE 'N'.
           88  END-OF-FILE            VALUE 'Y'.
       01  WS-ERROR-COUNT            PIC 9(4) VALUE 0.
       01  WS-TRANSACTIONS-PROCESSED PIC 9(4) VALUE 0.

       PROCEDURE DIVISION.
       MAIN-LOGIC SECTION.
           OPEN INPUT TRANSACTION-FILE
           OPEN I-O ACCOUNTS-FILE
           OPEN OUTPUT OVERDRAFT-FILE

           PERFORM UNTIL END-OF-FILE
               READ TRANSACTION-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF-FLAG
                   NOT AT END
                       PERFORM PROCESS-TRANSACTION
               END-READ
           END-PERFORM

           CLOSE TRANSACTION-FILE
           CLOSE ACCOUNTS-FILE
           CLOSE OVERDRAFT-FILE

           DISPLAY 'Program completed successfully'
           DISPLAY 'Total transactions processed: ' WS-TRANSACTIONS-PROCESSED
           DISPLAY 'Total errors encountered: ' WS-ERROR-COUNT
           STOP RUN.

       PROCESS-TRANSACTION SECTION.
           ADD 1 TO WS-TRANSACTIONS-PROCESSED

           READ ACCOUNTS-FILE
               KEY IS TRANS-ACCOUNT-NUMBER
               INVALID KEY
                   DISPLAY 'Error: Account not found - ' TRANS-ACCOUNT-NUMBER
                   ADD 1 TO WS-ERROR-COUNT
                   GO TO NEXT-TRANSACTION
           END-READ

           EVALUATE TRANS-TYPE
               WHEN 'D'
                   ADD TRANS-AMOUNT TO ACCOUNT-BALANCE
               WHEN 'W'
                   SUBTRACT TRANS-AMOUNT FROM ACCOUNT-BALANCE
                   IF ACCOUNT-BALANCE < 0
                       MOVE TRANS-ACCOUNT-NUMBER TO OD-ACCOUNT-NUMBER
                       MOVE ACCOUNT-NAME TO OD-ACCOUNT-NAME
                       MOVE ACCOUNT-BALANCE TO OD-BALANCE
                       MOVE TRANS-AMOUNT TO OD-TRANSACTION-AMOUNT
                       WRITE OVERDRAFT-RECORD
                   END-IF
               WHEN OTHER
                   DISPLAY 'Error: Invalid transaction type - ' TRANS-TYPE
                   ADD 1 TO WS-ERROR-COUNT
           END-EVALUATE

           REWRITE ACCOUNT-RECORD

       NEXT-TRANSACTION.
           EXIT.
