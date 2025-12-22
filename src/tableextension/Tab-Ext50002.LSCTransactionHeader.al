tableextension 50002 "LSCTransactionHeader" extends "LSC Transaction header"
{
    fields
    {
        field(50000; "Invoice No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(50001; "Transaction Code Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "REG","Regular Customer","SRC","ZERO","PWD","SOLO","WHT1","VATW","ZRWH","ATHL",DEPOSIT,"DEPOSIT REDEEM","MRS","BRS","CCM","NAAC","MOV","ONLINE";
        }
        field(50002; "Cashier Report ID"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(50003; "WHT Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50004; "VAT Withholding"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50005; "VAT Code Filter"; Code[10])
        {
            FieldClass = FlowFilter;
        }
        field(50006; "Total VAT Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("LSC Trans. Sales Entry"."VAT Amount" WHERE("Store No." = FIELD("Store No."), "POS Terminal No." = FIELD("POS Terminal No."), "Transaction No." = FIELD("Transaction No."), "VAT Code" = FIELD("VAT Code Filter"), "Local VAT Code" = field("Local VAT Code Filter")));
        }
        field(50007; "Total Net Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("LSC Trans. Sales Entry"."Net Amount" WHERE("Store No." = FIELD("Store No."), "POS Terminal No." = FIELD("POS Terminal No."), "Transaction No." = FIELD("Transaction No."), "VAT Code" = FIELD("VAT Code Filter"), "Local VAT Code" = field("Local VAT Code Filter")));
        }
        field(50008; "Identification Number"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(50009; "Customer Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ","Senior Citizen","Zero Rated","Solo Parent","Withholding Tax","PWD","VAT Withholding Tax","Regular Customer","ZRWH","ATHL","NAAC","MOV","ONLINE";
            ;
        }
        field(50010; "Beginning Balance"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50011; "Current Balance"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50012; "Amount Before"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50013; "Local VAT Code Filter"; Code[10])
        {
            FieldClass = FlowFilter;
        }
        field(50014; "ZRWHT Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50015; "Zero Rated Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50016; "SRC Discount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50017; "PWD Discount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50018; "SOLO Discount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50019; "ATHL Discount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
    }

    var
        myInt: Integer;
}