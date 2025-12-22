pageextension 50003 "itemCardext" extends "LSC Retail Item Card"
{
    layout
    {
        addlast("General")
        {
            group("Localization")
            {
                field("Enable Vat Exempt"; Rec."Enable Vat Exempt")
                {
                    Caption = 'Enable Vat Exempt';
                    ApplicationArea = All;
                }
                field("Food Item"; Rec."Food Item")
                {
                    Caption = 'Food Item';
                    ApplicationArea = All;
                }
                field("SRC Discount %"; Rec."SRC Discount %")
                {
                    Caption = 'SRC Discount %';
                    ApplicationArea = All;
                }
                field("PWD Discount %"; Rec."PWD Discount %")
                {
                    Caption = 'PWD Discount %';
                    ApplicationArea = All;
                }
                field("SOLO Discount %"; Rec."SOLO Discount %")
                {
                    Caption = 'SOLO Discount %';
                    ApplicationArea = All;
                }
                /*  field("Athlete Discount %"; Rec."Athlete Discount %")
                 {
                     Caption = 'Athlete Discount %';
                     ApplicationArea = All;
                 } */
                field("NAAC Discount %"; Rec."NAAC Discount %")
                {
                    Caption = 'NAAC Discount %';
                    ApplicationArea = All;
                }
                field("MOV Discount %"; Rec."MOV Discount %")
                {
                    Caption = 'MOV Discount %';
                    ApplicationArea = All;
                }
            }
        }

    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}