codeunit 50005 "BLOBFileManagement"
{
    /*
    REFERENCE:
    Overcoming File Management limitations in SaaS using BlobStorages  By:  Mark Soriano (Dynamics NAV / 365 BC Developer)
    */
    trigger OnRun()
    begin
    end;

    Procedure IsFileExist(var FileID: Integer; FileName: Text[100]): Boolean
    var
        BlobFile: Record "BLOB File Storage";
    begin
        BlobFile.Reset();
        BlobFile.SetRange(BlobFile.Type, BlobFile.Type::File);
        BlobFile.SetRange(BlobFile.ID);
        BlobFile.SetFilter(BlobFile.Name, '=%1', FileName);
        IF BlobFile.FindFirst() THEN BEGIN
            FileID := BlobFile.ID;
            EXIT(TRUE);
        END ELSE
            EXIT(FALSE);
    end;

    Procedure CreateNewFile(Folder: Integer; FileName: Text[100]): Integer
    var
        BlobFile: Record "BLOB File Storage";
    begin
        BlobFile.Init();
        BlobFile.Type := BlobFile.Type::File;
        BlobFile."Parent ID" := Folder;
        BlobFile.Name := FileName;
        BlobFile."File Date" := Today;
        BlobFile.Insert();
        exit(BlobFile.ID);
    end;

    Internal Procedure CreateNewFolder(Folder: Integer; FolderName: Text[50]): Integer
    var
        BlobFile: Record "BLOB File Storage";
    begin
        BlobFile.Init();
        BlobFile.Type := BlobFile.Type::Folder;
        BlobFile."Parent ID" := Folder;
        BlobFile.Name := FolderName;
        BlobFile.Insert();
        exit(BlobFile.ID);
    end;

    Internal Procedure DownloadFile(FileID: Integer)
    var
        BlobFile: Record "BLOB File Storage";
        lOutStream: OutStream;
        lInStream: InStream;
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        intLX: Integer;
        txtLExportMsg: Text;
        txtLPathName: Text;
        blnLIsHandled: Boolean;
    begin
        BlobFile.SetRange(ID, FileID);
        if not BlobFile.FindFirst() then exit;
        OnBeforeDownloadFile(BlobFile, blnLIsHandled);
        IF blnLIsHandled THEN
            EXIT;
        BlobFile.CalcFields(BLOB);
        BlobFile.BLOB.CreateInStream(lInStream);
        TempBlob.CreateOutStream(lOutStream);
        CopyStream(lOutStream, lInStream);
        FileMgt.BLOBExport(TempBlob, BlobFile.Name, true);
    end;

    Internal Procedure DownloadMultiFile(FileIDFilter: Text)
    var
        recLBlobFile: Record "BLOB File Storage";
        cduLTempBlob: Codeunit "Temp Blob";
        cduLFileMgt: Codeunit "File Management";
        cduLDataCompression: Codeunit "Data Compression";
        outLFileStream: OutStream;
        outLZipStream: OutStream;
        insLFileStream: InStream;
        insLSrcFile: InStream;
        insLZipStream: InStream;
        intLFileCnt: Integer;
        txtLZipFilename: Text;
        blnLIsHandled: Boolean;
        TextLFileExtractName: Label 'EJFile_%1_%2.zip';
    begin
        /*
        REFERENCE: https://yzhums.com/38031/
        From: Dynamics 365 Lab (yzhums)
        Github Ref: https://github.com/yzhums/Bulk-Download-Attachments/blob/main/DocumentAttachmentDetailsExt.al
        */
        recLBlobFile.Reset();
        recLBlobFile.SetFilter(recLBlobFile.ID, FileIDFilter);
        IF recLBlobFile.FindSet() THEN BEGIN
            cduLDataCompression.CreateZipArchive();
            intLFileCnt := 0;
            REPEAT
                recLBlobFile.CalcFields(BLOB);
                IF recLBlobFile.BLOB.HasValue THEN BEGIN
                    intLFileCnt += 1;
                    CLEAR(insLSrcFile);
                    CLEAR(outLFileStream);
                    CLEAR(insLFileStream);
                    recLBlobFile.BLOB.CreateInStream(insLSrcFile);
                    cduLTempBlob.CreateOutStream(outLFileStream);
                    CopyStream(outLFileStream, insLSrcFile); //** Export the file
                    cduLTempBlob.CreateInStream(insLFileStream);
                    cduLDataCompression.AddEntry(insLFileStream, recLBlobFile.Name);
                END;
            UNTIL recLBlobFile.Next() = 0;
        END;
        //** Compress all files in 1 (zip file)
        txtLZipFilename := StrSubstNo(TextLFileExtractName, FORMAT(intLFileCnt),
                                                        FORMAT(TODAY, 0, '<Day,2><Filler Character,0><Month Text,3><Year4>'));
        cduLTempBlob.CreateOutStream(outLZipStream);
        cduLDataCompression.SaveZipArchive(outLZipStream);
        cduLTempBlob.CreateInStream(insLZipStream);
        OnBeforeMultiDownloadFile(recLBlobFile, insLZipStream, outLZipStream, txtLZipFilename, blnLIsHandled);
        IF blnLIsHandled THEN
            EXIT;
        DownloadFromStream(insLZipStream, '', '', '', txtLZipFilename);
    end;

    Procedure ImportFile(FolderID: Integer)
    var
        TempBlob: Codeunit "Temp Blob";
        lInStream: InStream;
        lOutStream: OutStream;
        FileMgt: Codeunit "File Management";
        BlobFile: Record "BLOB File Storage";
        FileName: Text;
    begin
        TempBlob.CreateInStream(lInStream);
        UploadIntoStream('Select a file to import', '', 'All Files (*.*)|*.*', FileName, lInStream);
        BlobFile.Init();
        BlobFile."Parent ID" := FolderID;
        BlobFile.Name := FileName;
        BlobFile.Type := BlobFile.Type::File;
        BlobFile.Insert();
        BlobFile.BLOB.CreateOutStream(lOutStream);
        CopyStream(lOutStream, lInStream);
        BlobFile."File Date" := Today;
        BlobFile.Modify();
    end;

    Internal procedure OpenFileDialog() FileID: Integer;
    var
        FileBroswer: Page "File Browser Lookup";
    begin
        FileBroswer.LookupMode(true);
        if FileBroswer.RunModal = Action::LookupOK then begin
            FileID := FileBroswer.GetSelectedFile();
            exit(FileID);
        end;
        exit(FileID);
    end;

    Internal procedure SaveFileDialog(var lFileName: Text[50]; var lFolder: Integer)
    var
        FileBroswer: Page "File Browser Lookup";
        BlobFile: Record "BLOB File Storage";
    begin
        FileBroswer.LookupMode(true);
        if FileBroswer.RunModal = Action::LookupOK then begin
            FileBroswer.GetFileToSave(lFileName, lFolder);
            if lFileName <> '' then begin
                BlobFile.Reset();
                BlobFile.SetRange("Parent ID", lFolder);
                BlobFile.SetRange(Name, lFileName);
                if BlobFile.FindFirst() then
                    if not Dialog.Confirm(FileFoundConfirm, true, BlobFile.Name) then begin
                        lFileName := '';
                        lFolder := 0;
                    end else begin
                        lFileName := BlobFile.Name;
                        lFolder := BlobFile."Parent ID";
                    end;
            end;
        end;
    end;

    // MARCUS 20260107
    procedure RegenSalesEJ(StartDate: Date; EndDate: Date)
    var
        recLTmpBLOBFile: Record "BLOB File Storage" temporary;
        recBLOBFile: Record "BLOB File Storage";
        recBLOBFile2: Record "BLOB File Storage";
        cduLFileMngt: Codeunit "File Management";
        cduLTempBlob: Codeunit "Temp Blob";
        outLFile: OutStream;
        insLFile: InStream;
        txtLFileTextLne: Text;
        txtLEJFileName: Text[100];
        intLFileID: Integer;
        TextLEJFilePath: Label '%1\%2';
        TextLEJFileNameSingleDate: Label 'REGEN. EJ%1%2.txt';
        TextLEJFileNameDoubleDate: Label 'REGEN. EJ%1%2 TO %1%2.txt';
        FormattedStartDate: Text[10];
        FormattedEndDate: Text[10];
    begin
        IF NOT recLTmpBLOBFile.IsEmpty THEN //** Clear the temp table
            recLTmpBLOBFile.DeleteAll();

        FormattedStartDate := Format(StartDate, 0, '<Year4><Month,2><Day,2>');
        FormattedEndDate := Format(EndDate, 0, '<Year4><Month,2><Day,2>');

        IF StartDate <> EndDate THEN BEGIN
            txtLEJFileName := STRSUBSTNO(TextLEJFileNameDoubleDate, Globals.TerminalNo, FORMAT(FormattedStartDate), Globals.TerminalNo(), FORMAT(FormattedEndDate));
        END ELSE BEGIN
            txtLEJFileName := STRSUBSTNO(TextLEJFileNameSingleDate, Globals.TerminalNo, FORMAT(FormattedStartDate));
        END;

        IF NOT IsFileExist(intLFileID, txtLEJFileName) THEN BEGIN
            intLFileID := CreateNewFile(1, txtLEJFileName);  //* 1 = Txt File
            Commit();
        END;

        IF NOT recBLOBFile.GET(recBLOBFile.Type::File, intLFileID) THEN
            EXIT;

        recBLOBFile2.RESET;
        recBLOBFile2.SETFILTER("FILE DATE", '%1..%2', StartDate, EndDate);
        recBLOBFile2.SETFILTER("Name", '*SALES*|*POSTVOID*');
        IF recBLOBFile2.FINDSET THEN BEGIN
            recBLOBFile.BLOB.CreateOutStream(outLFile);
            REPEAT
                recBLOBFile2.CalcFields(BLOB);
                IF recBLOBFile2.BLOB.HasValue THEN BEGIN
                    recLTmpBLOBFile.BLOB := recBLOBFile2.BLOB;       //** Copy the BLOB field to Temp table BLOB field
                    recLTmpBLOBFile.BLOB.CreateInStream(insLFile);  //** Create instream from Temp Table Blob field                
                    WHILE NOT (insLFile.EOS()) DO BEGIN
                        CLEAR(txtLFileTextLne);
                        insLFile.ReadText(txtLFileTextLne);         //** Then write it back to the outstream of the Orig table BLOB
                        outLFile.WriteText(COPYSTR(txtLFileTextLne, 1, STRLEN(txtLFileTextLne)));
                        outLFile.Writetext();
                    END;
                END ELSE
                    recBLOBFile.BLOB.CreateOutStream(outLFile);
            UNTIL recBLOBFile2.NEXT = 0;
            recBLOBFile.MODIFY;
            DownloadFile(recBLOBFile.ID);
        END;
    end;
    //

    Procedure GetUserNameFromSID(UserSID: Guid): code[50]
    var
        recSysUser: Record User;
    begin
        IF NOT recSysUser.GET(UserSID) THEN
            EXIT('');
        EXIT(recSysUser."User Name");
    end;

    [IntegrationEvent(FALSE, FALSE)]
    local procedure OnBeforeDownloadFile(var BLOBFile: record "BLOB File Storage"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(FALSE, FALSE)]
    local procedure OnBeforeMultiDownloadFile(var BLOBFile: record "BLOB File Storage"; var ZipInsStream: InStream; var ZipOutStream: OutStream; ZipFileName: Text; var IsHandled: Boolean)
    begin
    end;

    var
        FileFoundConfirm: Label 'The file %1 already exists within the selected directory. Overwrite?';
        Globals: Codeunit "LSC POS Session";
}