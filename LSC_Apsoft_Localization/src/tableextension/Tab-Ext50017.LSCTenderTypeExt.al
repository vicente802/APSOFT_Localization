tableextension 50017 "LSC Tender Type Card Setup Ext" extends "LSC Tender Type Card Setup"
{
    fields
    {
        field(50000; "E-Wallet"; Boolean)
        {
            Caption = 'E-Wallet';
            DataClassification = CustomerContent;
        }
        field(50001; "Enable GHL"; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }
}
