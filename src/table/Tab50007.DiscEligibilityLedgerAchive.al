table 50007 DiscEligibilityLedgerAchive
{
    Caption = 'Discount Eligibility Ledger Archive';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }
        field(3; "Customer Type"; Option)
        {
            Caption = 'Customer Type';
            OptionMembers = " ","Regular","SRC","PWD","Solo Parent","Athlete","Zero Rated","Withholding Tax","VATW","ZRWHT";
        }
        field(4; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(5; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
        }
        field(6; Store; Code[20])
        {
            Caption = 'Store';
        }
        field(7; Terminal; Code[20])
        {
            Caption = 'Terminal';
        }
        field(8; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionMembers = "","BEG BAL","Sales";
        }
        field(9; DateTimeArchive; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(10; "Transaction Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(11; "Transaction Time"; time)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }

    }
    internal procedure getnxtlineno(): Integer;
    var
        DiscountEligibilityLedger: Record DiscEligibilityLedgerAchive;
    begin
        DiscountEligibilityLedger.Reset();
        if DiscountEligibilityLedger.FindLast() then
            exit(DiscountEligibilityLedger.Count + 1)
        else
            exit(1);


    end;
}
