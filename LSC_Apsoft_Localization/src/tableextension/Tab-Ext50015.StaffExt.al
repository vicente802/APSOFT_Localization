tableextension 50015 "StaffExt" extends "LSC staff"
{
    fields
    {
        field(50001; "Last X-Report"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(50002; "Tender Decl"; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    var
        myInt: Integer;
}