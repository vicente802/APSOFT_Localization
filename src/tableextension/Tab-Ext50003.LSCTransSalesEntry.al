tableextension 50003 "LSCTransSalesEntry" extends "LSC Trans. Sales Entry"
{
    fields
    {
        field(50001; "Local VAT Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(50002; "Item Disc. % Orig."; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50003; "Item Disc. % Actual"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50004; "Item Disc. Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ",SRC,PWD;
        }
        // MARCUS 20260107
        field(50005; "Original Price Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 2;
        }
    }
}