tableextension 50018 EndOfDayLedger extends "End Of Day Ledger"
{
    fields
    {
        field(50000; "Accumulated Reset Counter"; Integer)
        {
            Caption = 'Accumulated Reset Counter';
            DataClassification = CustomerContent;
        }
        field(50001; "No. of Refunds"; Integer)
        {
            Caption = 'No. of Refunds';
            DataClassification = CustomerContent;
        }
        field(50002; "Beg. Void"; Code[12])
        {
            Caption = 'Beg. Void';
            DataClassification = CustomerContent;
        }
        field(50003; "End. Void"; Code[12])
        {
            Caption = 'End. Void';
            DataClassification = CustomerContent;
        }
        field(50004; "Beg. Return"; Code[12])
        {
            Caption = 'Beg. Return';
            DataClassification = CustomerContent;
        }
        field(50005; "End. Return"; Code[12])
        {
            Caption = 'End. Return';
            DataClassification = CustomerContent;
        }
    }
}
