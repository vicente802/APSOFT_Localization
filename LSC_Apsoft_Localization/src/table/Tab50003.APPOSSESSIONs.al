table 50003 "AP POSSESSIONS"
{
    Caption = 'AP POSSESSIONS';

    DataClassification = CustomerContent;

    fields
    {

        field(1; "Entry No."; Code[50])
        {
            DataClassification = CustomerContent;

        }
        field(2; "POST PARAMETER"; Code[50])
        {
            Caption = 'POST PARAMETER';
            DataClassification = CustomerContent;

        }
        field(3; "POST COMMAND"; Code[50])
        {
            Caption = 'POST COMMAND';
            DataClassification = CustomerContent;

        }
        field(4; "Card type Param"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(5; "Trans Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "REG","SRC","ZERO","PWD","SOLO","WHT1","VATW","ZRWH","ATHL","Regular Customer",DEPOSIT,"DEPOSIT REDEEM";
        }
        field(6; "VOID TR"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(7; "Card Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(8; "Current Balance"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(9; "Transaction Code Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "REG","SRC","ZERO","PWD","SOLO","WHT1","VATW","ZRWH","ATHL","Regular Customer",DEPOSIT,"DEPOSIT REDEEM","MOV","NAAC","ONLINE";
        }
        field(10; "card no"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(11; "card Name"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(12; "card approval"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(13; "AP Card Name"; Code[50])
        {
            DataClassification = CustomerContent;
        }
        field(14; "Beg Bal"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(15; "Process GHL"; Boolean)
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
}
