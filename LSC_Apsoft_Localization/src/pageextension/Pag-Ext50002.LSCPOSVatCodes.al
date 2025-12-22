pageextension 50002 "LSCPOSVatCodes" extends "LSC POS VAT Codes"
{
    layout
    {
        addafter("Fiscal ID")
        {
            field("POS Command"; Rec."POS Command")
            {
                ApplicationArea = All;
            }
            field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
            {
                ApplicationArea = All;
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