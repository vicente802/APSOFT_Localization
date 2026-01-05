tableextension 50008 "LSCPOSTransactionExt" extends "LSC POS Transaction"
{
    fields
    {
        field(50000; "LSC Cust. No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(50001; "WHT Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50002; "WHT Disc. %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50003; "Transaction Code Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "REG","SRC","ZERO","PWD","SOLO","WHT1","VATW","ZRWH","ATHL","Regular Customer",DEPOSIT,"DEPOSIT REDEEM","MRS","BRS","CCM","NAAC","MOV","ONLINE";
            /*
                if you add new trans type dont for get to add in procedure GetDiscountCode in codeunit 50002.
            */
        }
        field(50004; "WHT Applied Counter"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(50005; "VAT WHT Applied Counter"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(50006; "Amount Before"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50007; "VAT Withholding Tax Disc. %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50008; "Withholding Tax Disc. %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50009; "VAT Withholding"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50010; "Beginning Balance"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50011; "Current Balance"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50012; "Senior Discount %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50013; "PWD Discount %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50014; "SOLO Discount %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50015; "SC Total Line Discount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("LSC POS Trans. Line"."Discount Amount" where("Receipt No." = field("Receipt No."), "Entry Type" = const(Item), "Entry Status" = const(" "), "Item Disc. Type" = const(SRC)));
        }
        field(50016; "PWD Total Line Discount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("LSC POS Trans. Line"."Discount Amount" where("Receipt No." = field("Receipt No."), "Entry Type" = const(Item), "Entry Status" = const(" "), "Item Disc. Type" = const(PWD)));
        }
        field(50017; "SRC Applied Counter"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(50018; "PWD Applied Counter"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(50019; "ZRWHT Applied Counter"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(50020; "ZRWHT Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50021; "Zero Rated Applied Counter"; integer)
        {
            DataClassification = CustomerContent;
        }

        field(50022; "Zero Rated Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50023; "Booklet No."; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(50024; "Total Pressed"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(50025; "AP Credit Card Number"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(50026; "AP Approval Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(50027; "AP Card Name"; Code[50])
        {
            DataClassification = CustomerContent;
        }
        field(50028; "SRC Discount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50029; "PWD Discount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50030; "SOLO Discount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50031; "ATHL Discount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50032; "Refund Reason"; Option)
        {
            OptionMembers = " ","Defected","Outdated","Color","Size","Dissatisfied","Other Reason";
            DataClassification = CustomerContent;
        }
    }

    var
        myInt: Integer;
}