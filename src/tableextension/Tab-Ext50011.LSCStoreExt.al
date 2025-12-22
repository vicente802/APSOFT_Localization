tableextension 50011 "LSCStoreExt" extends "LSC Store"
{
    fields
    {
        field(50001; "Global Setup"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(50002; "Open After Midnight"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(50003; "Store Open To"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(50004; "EOD Time"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(50005; "Service Charge No."; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(50006; "Delivery Charge No."; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(50007; "Handling Charge No."; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(50008; "NAV Reports File Path"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(50009; "Daily Report Process File Path"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(50010; "Default POS Terminal"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "LSC POS Terminal";
        }
        field(50011; "Send SRC/PWD Beg Bal Job ID"; code[50])
        {
            DataClassification = CustomerContent;
            TableRelation = "LSC Scheduler Job Header"."Job ID";
        }
        field(50012; "Request SRC/PWD Beg Bal Job Id"; code[50])
        {
            DataClassification = CustomerContent;
            TableRelation = "LSC Scheduler Job Header"."Job ID";
        }

    }

    var
        myInt: Integer;
}