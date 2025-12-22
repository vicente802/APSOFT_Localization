table 50001 "End Of Day Ledger Details"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(3; "Entry Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = Tenders,"Tender Declare","Income/Expense";
        }
        field(4; "Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(5; Amount; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(6; Count; Integer)
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

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}