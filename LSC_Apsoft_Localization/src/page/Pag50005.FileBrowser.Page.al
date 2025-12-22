page 50005 "File Browser"
{    /*
    REFERENCE:
    Overcoming File Management limitations in SaaS using BlobStorages  By:  Mark Soriano (Dynamics NAV / 365 BC Developer)
    */

    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "BLOB File Storage";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    Caption = 'POS E-File Browser';

    layout
    {
        area(Content)
        {
            Repeater(ItemList)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    trigger OnDrillDown()
                    begin
                        if Rec.Type = Rec.Type::Folder then begin
                            FileBrowser.SetCurrentFolder(Rec.ID);
                            FileBrowser.RunModal();
                        end else begin
                            FileMgt.DownloadFile(Rec.ID);
                        end;
                    end;
                }
                field("Parent ID"; Rec."Parent ID")
                {
                    ApplicationArea = All;
                    Caption = 'File Type ID';
                    Editable = FALSE;
                }
                field("File Date"; Rec."File Date")
                {
                    ApplicationArea = All;
                    Caption = 'File Date';
                    Editable = FALSE;
                }
                field("Created Date"; Rec.SystemCreatedAt)
                { ApplicationArea = All; Caption = 'Created Date & Time'; }
                field("Created By"; FileMgt.GetUserNameFromSID(Rec.SystemCreatedBy))
                { ApplicationArea = All; Caption = 'Created By'; }
                field("Modified Date"; Rec.SystemModifiedAt)
                { ApplicationArea = All; Caption = 'Modified Date & Time'; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            /* **********************************
            //**** Temporarily commented as it was not needed yet ****
            action(NewFolder)
            {
                ApplicationArea = All;
                Caption = 'New Folder';
                Image = Journal;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = New;
                trigger OnAction()
                var
                    FileMgt: Codeunit BLOBFileManagement;
                begin
                    FileMgt.CreateNewFolder(CurrentFolder, 'New Folder');
                end;
            }
            action(NewFile)
            {
                ApplicationArea = All;
                Caption = 'New File';
                Image = BeginningText;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = New;
                trigger OnAction()
                var
                    FileMgt: Codeunit BLOBFileManagement;
                begin
                    FileMgt.CreateNewFile(CurrentFolder, 'New File');
                end;
            }
            ******************************** */
            action(ImportFile)
            {
                ApplicationArea = All;
                Caption = 'Import File';
                Image = Import;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = New;
                trigger OnAction()
                var
                    FileMgt: Codeunit BLOBFileManagement;
                begin
                    FileMgt.ImportFile(CurrentFolder);
                end;
            }
            action(DownloadMultiFile)
            {
                ApplicationArea = All;
                Caption = 'Download Multi-Selected Files';
                Image = Download;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    cduLBLOBFileMgt: Codeunit BLOBFileManagement;
                    txtLFileIDFilter: Text;
                begin
                    CurrPage.SetSelectionFilter(Rec);
                    IF Rec.FindSet() THEN BEGIN
                        REPEAT
                            IF txtLFileIDFilter = '' THEN
                                txtLFileIDFilter := FORMAT(Rec.ID)
                            ELSE
                                txtLFileIDFilter += ('|' + FORMAT(Rec.ID));
                        UNTIL Rec.Next() = 0;
                    END;
                    CLEAR(cduLBLOBFileMgt);
                    cduLBLOBFileMgt.DownloadMultiFile(txtLFileIDFilter);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        UpdateList();
    end;

    procedure SetCurrentFolder(CurrFolder: Integer)
    begin
        CurrentFolder := CurrFolder;
    end;

    local procedure UpdateList()
    begin
        Rec.Reset();
        IF CurrentFolder <> 0 THEN
            Rec.SetRange("Parent ID", CurrentFolder)
        ELSE BEGIN
            Rec.SetCurrentKey("File Date");
            Rec.Ascending(TRUE);
        END;
        CurrPage.Update();
    end;

    var
        FileBrowser: Page "File Browser";
        FileMgt: Codeunit BLOBFileManagement;
        CurrentFolder: Integer;
}

