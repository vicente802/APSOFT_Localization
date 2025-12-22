table 50005 "LSC POS X-report statistics"
{
    Caption = 'POS X-report statistics';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store No."; Code[10])
        {
            Caption = 'Store No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(2; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(3; "X-Report Id"; Code[10])
        {
            Caption = 'X-Report Id';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(4; Date; Date)
        {
            Caption = 'Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(5; "Sales Amount"; Decimal)
        {
            Caption = 'Sales Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6; "Cumulative Sales Amount"; Decimal)
        {
            Caption = 'Cumulative Sales Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(7; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(8; "Staff ID"; Code[10])
        {
            Caption = 'Staff ID';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(9; "Trans. Date"; Date)
        {
            Caption = 'Trans. Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Store No.", "POS Terminal No.", "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Store No.", "POS Terminal No.", "X-Report Id")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
    }

    trigger OnInsert()
    var
        XReportStats: Record "LSC POS X-report statistics";
    begin
        XReportStats.SetRange("Store No.", "Store No.");
        XReportStats.SetRange("POS Terminal No.", "POS Terminal No.");
        if not XReportStats.FindLast() then
            XReportStats.Init;

        // "Entry No." := GetNextEntryNo;
        "Cumulative Sales Amount" := XReportStats."Cumulative Sales Amount" + "Sales Amount";
    end;

    procedure GetNextEntryNo(): Integer
    var
        LSCPOSXreportstatistics: Record "LSC POS X-report statistics";

    begin
        LSCPOSXreportstatistics.RESET;
        IF LSCPOSXreportstatistics.FINDLAST THEN
            EXIT(LSCPOSXreportstatistics."Entry No." + 1)
        ELSE
            EXIT(1);
    end;
}