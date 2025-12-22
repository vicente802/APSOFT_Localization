table 50004 "Table Cleanup List"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" where("Object Type" = const(Table));
            trigger OnValidate()
            begin
                if recALLObj.Get(recAllObj."Object Type"::Table, "Table ID") then begin
                    "Table Name" := recAllObj."Object Name";
                end;
            end;
        }
        field(2; "Table Name"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Delete Mark"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(4; Remarks; Text[30])
        {
            DataClassification = CustomerContent;

        }
        field(5; Blocked; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Table ID")
        {
            Clustered = true;
        }
    }

    var
        recAllObj: Record AllObj;

}