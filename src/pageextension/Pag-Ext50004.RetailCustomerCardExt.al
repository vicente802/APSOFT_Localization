pageextension 50004 "RetailCustomerCardExt" extends "LSC Retail Customer Card"
{
    layout
    {
        addlast(General)
        {
            group("Localization")
            {
                field(TIN; Rec.TIN)
                {
                    Caption = 'TIN';
                    ApplicationArea = All;
                }
                field(Company; Rec.Company)
                {
                    Caption = 'Company';
                    ApplicationArea = All;
                }
                // field("Business Style"; Rec."Business Style")
                // {
                //     Caption = 'Business Style';
                //     ApplicationArea = All;
                // }
                field("Customer Type"; Rec."Customer Type")
                {
                    Caption = 'Customer Type';
                    ApplicationArea = All;
                }
                field("Name of Child"; Rec."Name of Child")
                {
                    ApplicationArea = All;
                }
                field("Birthdate of Child"; Rec."Birthdate of Child")
                {
                    ApplicationArea = All;
                }
                field("VEC Expiry Date"; Rec."VEC Expiry Date")
                {
                    ApplicationArea = All;
                }
                field("Reference ID"; Rec."Reference ID")
                {
                    ApplicationArea = All;
                }
                field("Reference ID Expiry Date"; Rec."Reference ID Expiry Date")
                {
                    ApplicationArea = All;
                }
                field("Retail Price Group"; Rec."Retail Price Group")
                {
                    ApplicationArea = all;
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

