tableextension 50000 "LSCRetailSetup" extends "LSC Retail Setup"
{
    fields
    {
        field(50000; "Allow Y Read With Susp Trans"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(50001; "Enable GHL"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(50002; " GHL Timeout"; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
}