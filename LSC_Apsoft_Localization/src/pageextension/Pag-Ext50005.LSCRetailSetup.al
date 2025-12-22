pageextension 50005 "LSCRetailSetup" extends "LSC Retail Setup"
{
    layout
    {
        addlast("general")
        {
            group("Localization")
            {
                field("Allow Y Read W/SusRet"; Rec."Allow Y Read With Susp Trans")
                {
                    Caption = 'Allow Y Read With Suspend Transaction';
                    ApplicationArea = all;
                }
                field("Enable GHL"; Rec."Enable GHL")
                {
                    ApplicationArea = all;
                }
                field("GHL Timeout"; Rec." GHL Timeout")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}