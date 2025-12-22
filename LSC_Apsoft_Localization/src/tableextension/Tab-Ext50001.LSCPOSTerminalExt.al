tableextension 50001 "LSCPOSTerminalExt" extends "LSC POS Terminal"
{
    fields
    {
        field(50000; "EJ Local Path"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(50001; "MIN Number"; Code[30])
        {
            DataClassification = CustomerContent;
        }
        field(50002; "Serial Number"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(50003; "POS Permit Number"; Code[30])
        {
            DataClassification = CustomerContent;
        }

        field(50006; "Accumulated Sales"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("End Of Day Ledger"."Total Net Sales" WHERE("Store No." = FIELD("Store No."), "POS Terminal No." = FIELD("No."), Date = FIELD("Date Filter")));
        }
        field(50007; "Invoice No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(50008; "Invoice Counter"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(50009; "Receipt Counter"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(50010; "Accumulated Sales Counter"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(50011; "Last X-Report"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(50012; "Allow Float Entry"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(50013; "Accreditation Number"; Code[30])
        {
            DataClassification = CustomerContent;
        }
        field(50014; "TIN Number"; Code[30])
        {
            DataClassification = CustomerContent;
        }
        field(50015; "Non Sales Transaction Footer"; Text[50])
        {
            DataClassification = CustomerContent;
        }
    }
}