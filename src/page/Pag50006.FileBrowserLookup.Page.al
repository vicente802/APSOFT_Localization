page 50006 "File Browser Lookup"
{    /*
    REFERENCE:
    Overcoming File Management limitations in SaaS using BlobStorages  By:  Mark Soriano (Dynamics NAV / 365 BC Developer)
    */
    PageType = List;
    SourceTable = "BLOB File Storage";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'File Browser';

    layout
    {
        area(Content)
        {
            group(FileNameGroup)
            {
                field(NewFileName; NewFileName)
                {
                    ApplicationArea = All;
                    Caption = 'File Name';
                }
            }
            Repeater(ItemList)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    Editable = false;
                    trigger OnDrillDown()
                    var
                        FileBrowser: Page "File Browser";
                        FileMgt: Codeunit BLOBFileManagement;
                    begin
                        if Rec.Type = Rec.Type::Folder then begin
                            CurrentFolder := Rec.ID;
                            SelectedFile := Rec.ID;
                            UpdateList();
                        end else begin
                            SelectedFile := Rec.ID;
                            UpdateList();
                        end;
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GoBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Image = PreviousRecord;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    BlobFile: Record "BLOB File Storage";
                begin
                    BlobFile.Reset;
                    BlobFile.SetRange(ID, CurrentFolder);
                    if BlobFile.FindFirst() then
                        CurrentFolder := BlobFile."Parent ID";
                    UpdateList();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        UpdateList();
    end;

    procedure GetSelectedFile(): Integer
    begin
        exit(SelectedFile);
    end;

    procedure GetFileToSave(var lFileName: Text[50]; var lFolder: Integer)
    begin
        lFolder := CurrentFolder;
        lFileName := NewFileName;
    end;

    local procedure UpdateList()
    var
        BlobFile: Record "BLOB File Storage";
    begin
        NewFileName := Rec.Name;
        BlobFile.Reset();
        BlobFile.SetRange("Parent ID", CurrentFolder);
        if BlobFile.FindSet() then
            CurrPage.SetTableView(BlobFile);
        CurrPage.Update();
    end;

    var
        CurrentFolder: Integer;
        SelectedFile: Integer;
        NewFileName: Text[50];
}

