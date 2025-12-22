table 50006 "BLOB File Storage"
{


    DataClassification = CustomerContent;

    fields
    {
        field(1; "Type"; Enum "BLOB File Types")
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
        }
        field(2; "ID"; Integer)
        {
            AutoIncrement = true;
        }
        field(3; "Parent ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
        }
        field(4; "Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Name';
        }
        field(5; "File Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'File Date';
        }
        field(10; "BLOB"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'BLOB';
        }
    }

    keys
    {
        key(key1; "Type", "ID")
        {
            Clustered = true;
        }
        Key(Key2; "File Date")
        { }
    }

    trigger OnDelete()
    var
        BlobFile: Record "BLOB File Storage";
    begin
        if Rec.Type = Rec.Type::Folder then begin
            BlobFile.SetRange("Parent ID", Rec.ID);
            if BlobFile.FindSet() then
                BlobFile.DeleteAll(true);
        end;
    end;

}