tableextension 50012 "TransTenderDeclareEntryExt" extends "LSC Trans. Tender Declar. Entr"

{
    fields
    {
        field(50001; "Cashier Report ID"; Code[10])
        {
            DataClassification = CustomerContent;
        }
    }

    var
        myInt: Integer;
}