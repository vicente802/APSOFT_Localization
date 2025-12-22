tableextension 50004 "LSCTransPaymentEntry" extends "LSC Trans. Payment Entry"
{
    fields
    {
        field(50001; "Cashier Report ID"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(50002; "Card Approval Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(50003; "Card Type"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(50004; "Current Balance"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50005; "Card holder Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
    }
}