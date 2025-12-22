page 50002 "Table Cleanup Utility"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Table Cleanup List";

    layout
    {
        area(Content)
        {
            repeater("Group")
            {
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;

                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                }
                field("Delete Mark"; Rec."Delete Mark")
                {
                    ApplicationArea = All;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = All;
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action("Get All Tables")
            {
                ApplicationArea = All;

                trigger OnAction();
                begin
                    GetAllTables();
                end;
            }
            action("Delete Data")
            {
                ApplicationArea = All;

                trigger OnAction();
                begin
                    DeleteData();
                end;
            }
            action("Mark All")
            {
                ApplicationArea = All;

                trigger OnAction();
                begin
                    MarkUnmarkTable(1);
                end;
            }
            action("Unmark All")
            {
                ApplicationArea = All;

                trigger OnAction();
                begin
                    MarkUnmarkTable(2);
                end;
            }
        }
    }
    local procedure GetAllTables()
    var
        i: Integer;
        j: Integer;
    begin
        if Confirm(StrSubstNo(Text90000, 'Populate'), true) then begin
            window.Open('Getting All Tables.. Please Wait..\' +
                        'Obj Id           #1##################\' +
                        'Obj Name         #2##################\' +
                        '@3@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');

            recAllObj.SetRange("Object Type", recAllObj."Object Type"::Table);
            if recAllObj.FindFirst() then
                repeat
                    i += 1;
                    Evaluate(j, Format(Round(i / recAllObj.Count * 10000, 1)));
                    window.Update(1, recAllObj."Object ID");
                    window.Update(2, recAllObj."Object Name");
                    window.Update(3, j);

                    if not recTableCleanup.Get(recAllObj."Object ID") then begin
                        recTableCleanup.Init();
                        recTableCleanup."Table ID" := recAllObj."Object ID";
                        recTableCleanup."Table Name" := recAllObj."Object Name";
                        recTableCleanup.Insert();
                    end;
                until recAllObj.Next() = 0;
            Message(Text90001, 'Populate');
            window.Close();
        end;
    end;

    local procedure DeleteData()
    var
        ctr1: Integer;
        ctr2: Integer;
    begin
        if Confirm(StrSubstNo(Text90000, 'Delete'), true) then begin
            window.Open('Cleaning All selected Tables.. Please Wait..\' +
                        'Obj Id           #1##################\' +
                        'Obj Name         #2##################\' +
                        '@3@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');

            if Rec.FindFirst() then
                repeat
                    ctr1 += 1;
                    Evaluate(ctr2, Format(Round(ctr1 / Rec.Count * 10000, 1)));

                    window.Update(1, Rec."Table ID");
                    window.Update(2, Rec."Table Name");
                    window.Update(3, ctr2);

                    if Rec."Delete Mark" then begin
                        if Rec.Blocked = false then begin
                            recRef.Open(Rec."Table ID");
                            recRef.DeleteAll();
                            recRef.Close();
                        end;
                    end;
                until Rec.Next() = 0;
            window.Close();
            Message(Text90001, 'Table Cleanup!');
        end;
    end;

    local procedure MarkUnmarkTable(mode: Integer)
    begin
        if Rec.FindFirst() then begin
            case mode of
                1:
                    Rec.ModifyAll("Delete Mark", true);
                2:
                    Rec.ModifyAll("Delete Mark", false);
            end;
        end;
    end;

    var
        recAllObj: Record AllObj;
        recTableCleanup: Record "Table Cleanup List";
        recRef: RecordRef;
        window: Dialog;
        Text90000: TextConst ENU = 'Are you sure you want to %1 Table Records?';
        Text90001: TextConst ENU = 'Successful %1';
}