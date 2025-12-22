pageextension 50006 "LSC Tender Type Card Ext" extends "LSC Tender Type Card Setup"
{
    layout
    {
        addlast(General)
        {
            field("E-Wallet"; Rec."E-Wallet")
            {
                ApplicationArea = all;
            }
            field("Enable GHL"; Rec."Enable GHL")
            {
                ApplicationArea = all;
            }
        }
    }
}
