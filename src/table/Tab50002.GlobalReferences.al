table 50002 "Global References"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "Transaction Code","Item Department","Discount Code","Item Classification","Keyboard","Store Code","Source Code","GHL Acquirer";
        }
        field(2; Code; Code[50])
        {
            DataClassification = CustomerContent;

        }
        field(3; Description; Text[200])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Transaction Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ",CASH,SRC,ZERO,PWD,SOLO,CHARGE,WHT1,VATW,ATHL,"NAAC","MOV","Online Customer";
            //"REG","SRC","ZERO","PWD","SOLO","WHT1","VATW","ZRWH","ATHL","NAAC","MOV"
        }
        field(5; "Discount Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ",SRC,ZERO,PWD,SOLO,WHT1,VATW,ATHL,"NAAC","MOV","Online Customer";
            //"REG","SRC","ZERO","PWD","SOLO","WHT1","VATW","ZRWH","ATHL","NAAC","MOV"
        }
        field(6; "Include in Store Sales"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(7; "Tender Type Card Setup"; Code[50])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry Type", "Code", Description)
        {
            Clustered = true;
        }
    }

}