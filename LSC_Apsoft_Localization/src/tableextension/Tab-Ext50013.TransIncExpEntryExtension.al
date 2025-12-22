tableextension 50013 "TransInc/ExpEntryExtension" extends "LSC Trans. Inc./Exp. Entry"
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