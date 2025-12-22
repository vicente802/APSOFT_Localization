pageextension 50000 "LSCPOSTerminalCardExt" extends "LSC POS Terminal Card"
{
    layout
    {
        addlast("General")
        {
            group(Localization)
            {
                group("Local Setup")
                {
                    Caption = 'Terminal New Local Setup';
                    field("EJ Local Path"; Rec."EJ Local Path")
                    {
                        Caption = 'EJ Local Path';
                        ApplicationArea = All;
                    }
                    field("Accumulated Sales"; Rec."Accumulated Sales")
                    {
                        Caption = 'Accumulated Sales';
                        ApplicationArea = All;
                    }
                    field("Invoice No."; Rec."Invoice No.")
                    {
                        Caption = 'Invoice No.';
                        ApplicationArea = All;
                    }
                    field("Last Y-Report"; Rec."Last Y-Report")
                    {
                        Caption = 'Last Y-Report';
                        ApplicationArea = All;
                    }
                    field("Last Z-Report_"; Rec."Last Z-Report")
                    {
                        Caption = 'Last Z-Report';
                        ApplicationArea = All;
                    }
                    field("Non Sales Transaction Footer"; Rec."Non Sales Transaction Footer")
                    {
                        Caption = 'Non Sales Transaction Footer';
                        ApplicationArea = All;
                    }
                }
                group("BIR")
                {
                    field("MIN Number"; Rec."MIN Number")
                    {
                        Caption = 'MIN Number';
                        ApplicationArea = All;
                    }
                    field("Serial Number"; Rec."Serial Number")
                    {
                        Caption = 'Serial Number';
                        ApplicationArea = All;
                    }
                    field("POS Permit Number"; Rec."POS Permit Number")
                    {
                        Caption = 'POS Permit Number';
                        ApplicationArea = All;
                    }

                }
            }
        }
    }
    actions
    {
        // Add changes to page actions here

    }
    var

}