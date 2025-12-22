pageextension 50001 "LSCPOSFuncProfile" extends "LSC POS Func. Profile Card"
{
    layout
    {
        addafter("LS Omni Server")
        {
            group("Local Setup")
            {
                /*
                field("SRC Retail Disc. %"; Rec."SRC Retail Disc. %")
                {
                    ApplicationArea = All;
                }
                field("SRC Hosp. Disc. %"; Rec."SRC Hosp. Disc. %")
                {
                    ApplicationArea = All;
                }
                field("PWD Retail Disc. %"; Rec."PWD Retail Disc. %")
                {
                    ApplicationArea = All;
                }
                field("PWD Hosp. Disc. %"; Rec."PWD Hosp. Disc. %")
                {
                    ApplicationArea = All;
                }
                field("SOLO Disc. %"; Rec."SOLO Disc. %")
                {
                    ApplicationArea = All;
                }
                */
                field("SRC Max Disc. Allowance"; Rec."Beg Bal Allowance")
                {
                    ApplicationArea = All;
                    Caption = 'SRC Max Disc. Allowance';
                }
                field("PWD Max Disc. Allowance"; Rec."Beg Bal Allowance")
                {
                    ApplicationArea = All;
                    Caption = 'PWD Max Disc. Allowance';
                }
                // field("WHT PERCENT"; Rec."WHT1 Discount %")
                // {
                //     ApplicationArea = All;
                // }
                field("Withholding Tax Disc. %"; Rec."Withholding Tax Disc. %")
                {
                    ApplicationArea = All;
                }
                field("VAT Withholding Tax Disc. %"; Rec."VAT Withholding Tax Disc. %")
                {
                    ApplicationArea = All;
                }
                // field("WHT/BOI Must Be Register"; Rec."WHT/BOI Must Be Register")
                // {
                //     ApplicationArea = All;
                // }
                // field("VAT WHT Must Be Register"; Rec."VAT WHT Must Be Register")
                // {
                //     ApplicationArea = All;
                // }
                // field("Additional Item on VAT WHT"; Rec."Additional Item on VAT WHT")
                // {
                //     ApplicationArea = All;
                // }

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