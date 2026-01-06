codeunit 50000 "AP POS Print Utility"
{
    [IntegrationEvent(TRUE, false)]
    internal procedure APOnBeforePrintSalesSlip(var LscSender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var IsHandled: Boolean; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    internal procedure APOnBeforePrintVoidSlip(var LscSender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    internal procedure APOnBeforePrintRemoveAddTenderSlip(var LscSender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    internal procedure APOnBeforePrintReturnsSlip(var LscSender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    internal procedure APOnBeforePrintSubHeader(var LscSender: Codeunit "LSC POS Print Utility"; var TransactionHeader: Record "LSC Transaction Header"; Tray: Integer; var POSPrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    internal procedure APOnBeforePrintSuspendSlip(var LscSender: Codeunit "LSC POS Print Utility"; var DSTR1: Text[100]; var IsHandled: Boolean; var ReturnValue: Boolean; var POSTrans: Record "LSC POS Transaction"; var tmpPosTransLines: Record "LSC POS Trans. Line" temporary; GrAmount: Decimal)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    internal procedure OnAfterPrintSlipSettlement(var LscSender: Codeunit "LSC POS Print Utility"; var Transaction: Record LSCMobileTransaction; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100])
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    internal procedure OnAfterPrintSlips(var LscSender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var MsgTxt: Text[50]; PrintSlip: Boolean; var ReturnValue: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    internal procedure APOnBeforePrintTenderDeclSlip(var LscSender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean; var ReturnValue: Boolean)
    begin
    end;
    //Start *************************************Events*************************************
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", OnBeforePrintXZReport, '', false, false)]
    local procedure "LSC POS Print Utility_OnBeforePrintXZReport"(var Sender: Codeunit "LSC POS Print Utility"; RunType: Option; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean; var ReturnValue: Boolean; FiscalON: Boolean; OnlyFiscal: Boolean; gNoSuspPOSTransactionsVoided: Integer; var IsCustomZReport: Boolean)
    var
        FileMgt: Codeunit BLOBFileManagement;
        BLOBFileStorage: record "BLOB File Storage";
        printx: Boolean;
    begin
        cduSender := Sender;
        IsHandled := true;
        ReturnValue := true;
        optRunType := RunType;

        if MyLSCPOSTransaction.CheckifEODProcessToday THEN //if already performed EOD
            EXIT;
        if MyLSCPOSTransaction.ValidateAllowedFloatEntry THEN
            EXIT;
        // if not MyLSCPOSTransaction.Checkifwithsuspendtrans(Transaction."Store No.") then begin
        //     codPOSTrans.PosErrorBanner(StrSubstNo('You are not allowed to print %1 reading if with suspended transaction', format(optRunType)));
        //     EXIT;
        // end;
        PrintXYZReportNew(RunType);
        POSSESSION.ClearManagerID();
        BLOBFileStorage.reset;
        if BLOBFileStorage.findlast then
            FileMgt.DownloadFile(BLOBFileStorage.ID);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", OnAfterClosePrinter, '', false, false)]
    local procedure "LSC POS Print Utility_OnAfterClosePrinter"(var ActivePrinterLine: Record "LSC POS Print Line"; var PrintBuffer: Record "LSC POS Print Buffer"; var LastErrorText: Text)
    var
        recLTmpBLOBFile: Record "BLOB File Storage" temporary;
        cduLFileMngt: Codeunit "File Management";
        cduLTempBlob: Codeunit "Temp Blob";
        outLFile: OutStream;
        insLFile: InStream;
        txtLFileTextLne: Text;
        txtLEJFileName: Text[100];
        intLFileID: Integer;
        TextLEJFilePath: Label '%1\%2';
        TextLEJFileName: Label 'EJ%1%2%3.txt';
    begin
        IF NOT recLTmpBLOBFile.IsEmpty THEN //** Clear the temp table
            recLTmpBLOBFile.DeleteAll();

        txtLEJFileName := CheckIfReading(PrintBuffer);
        IF NOT cduBLOBFileMgt.IsFileExist(intLFileID, txtLEJFileName) THEN BEGIN
            intLFileID := cduBLOBFileMgt.CreateNewFile(1, txtLEJFileName);  //* 1 = Txt File
            Commit();
        END;
        IF NOT recBLOBFile.GET(recBLOBFile.Type::File, intLFileID) THEN
            EXIT;
        recBLOBFile.CalcFields(BLOB);
        IF recBLOBFile.BLOB.HasValue THEN BEGIN
            recLTmpBLOBFile.BLOB := recBLOBFile.BLOB;       //** Copy the BLOB field to Temp table BLOB field
            recBLOBFile.BLOB.CreateOutStream(outLFile);
            recLTmpBLOBFile.BLOB.CreateInStream(insLFile);  //** Create instream from Temp Table Blob field                
            WHILE NOT (insLFile.EOS()) DO BEGIN
                CLEAR(txtLFileTextLne);
                insLFile.ReadText(txtLFileTextLne);         //** Then write it back to the outstream of the Orig table BLOB
                outLFile.WriteText(COPYSTR(txtLFileTextLne, 1, STRLEN(txtLFileTextLne)));
                outLFile.Writetext();
            END;
        END ELSE
            recBLOBFile.BLOB.CreateOutStream(outLFile);
        IF PrintBuffer.FindSet() THEN BEGIN
            REPEAT
                IF PrintBuffer."Printed Line No." <> 0 THEN BEGIN
                    // IF (STRPOS(PrintBuffer.Text, 'Z-REPORT') > 0) OR (STRPOS(PrintBuffer.Text, 'Terminal Reading') > 0) OR (STRPOS(PrintBuffer.Text, 'Cashier Reading') > 0) THEN
                    //     IsReading := true;
                    outLFile.Writetext(COPYSTR(PrintBuffer.Text, 1));
                    outLFile.Writetext();
                END;
            UNTIL PrintBuffer.Next = 0;
            recBLOBFile.Modify();
        END;
    end;

    local procedure CheckIfReading(var PrintBuffer: Record "LSC POS Print Buffer"): Text[100];
    var
        IsReading: Boolean;
        c_Transaction: Codeunit "LSC POS Transaction";
        r_TransactionHeader: Record "LSC Transaction Header";
        TextLEJFileName: Label 'EJ%1%2%3.txt';
        TextLEJFileNameStandard: Label 'EJ%1%2.txt';
        txtLEJFileName: Text[100];
    begin
        IF PrintBuffer.FINDSET THEN BEGIN
            REPEAT
                IF PrintBuffer."Printed Line No." <> 0 THEN BEGIN
                    IF (STRPOS(PrintBuffer.Text, 'Z-REPORT') > 0) OR (STRPOS(PrintBuffer.Text, 'Terminal Reading') > 0) OR (STRPOS(PrintBuffer.Text, 'Cashier Reading') > 0) THEN BEGIN
                        IsReading := true;
                        BREAK;
                    END;
                END;
            UNTIL PrintBuffer.Next = 0;
        END;

        IF NOT IsReading THEN BEGIN
            r_TransactionHeader.Get(c_Transaction.GetStoreNo(), c_Transaction.GetPOSTerminalNo(), c_Transaction.GetLastTransNo());

            IF (r_TransactionHeader."Gross Amount" < 0) and (r_TransactionHeader."Entry Status" = r_TransactionHeader."Entry Status"::" ") then begin
                exit(STRSUBSTNO(TextLEJFileName, 'SALES', Globals.TerminalNo, FORMAT(WORKDATE, 0, '<Month,2><day,2><year>')));
            end ELSE
                IF r_TransactionHeader."Entry Status" = r_TransactionHeader."Entry Status"::Voided then begin
                    exit(STRSUBSTNO(TextLEJFileName, 'CANCEL', Globals.TerminalNo, FORMAT(WORKDATE, 0, '<Month,2><day,2><year>')));
                end ELSE
                    IF (r_TransactionHeader."Gross Amount" > 0) and (r_TransactionHeader."Entry Status" = r_TransactionHeader."Entry Status"::" ") THEN begin
                        exit(STRSUBSTNO(TextLEJFileName, 'POSTVOID', Globals.TerminalNo, FORMAT(WORKDATE, 0, '<Month,2><day,2><year>')));
                    end;
        END;

        exit(STRSUBSTNO(TextLEJFileNameStandard, Globals.TerminalNo, FORMAT(WORKDATE, 0, '<Month,2><day,2><year>')));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", OnBeforePrintSalesSlip, '', false, false)]
    local procedure "LSC POS Print Utility_OnBeforePrintSalesSlip"(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var IsHandled: Boolean; var ReturnValue: Boolean)
    var
        POSTerminal: Record "LSC POS Terminal";
        TransPaymentEntry: Record "LSC Trans. Payment Entry";
        bc: Text;
        DSTR1: Text[100];
        bcWidth: Integer;
        bcHeight: Integer;
        Tray: Integer;
        QRCodeDataString: Text;
        DeliveryReceipt: Label 'Delivery receipt';
        NOChargeTOAccountLbl1: Label 'NOT A';
        NOChargeTOAccountLbl2: Label 'PURCHASE RECEIPT';
    begin
        cduSender := Sender;
        APOnBeforePrintSalesSlip(Sender, Transaction, PrintBuffer, PrintBufferIndex, LinesPrinted, IsHandled, ReturnValue);
        if IsHandled then
            exit;
        CurrentPrintID := 100;
        IsHandled := true;
        if Transaction."Transaction No." = 0 then
            ReturnValue := true;

        WindowInitialize();
        if GenPosFunc."Sales Slip Report ID" <> 0 then begin
            Transaction.SetRange("Store No.", Transaction."Store No.");
            Transaction.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
            Transaction.SetRange("Transaction No.", Transaction."Transaction No.");
            REPORT.Run(GenPosFunc."Sales Slip Report ID", false, true, Transaction);
        end else begin
            if not Transaction."Sale Is Return Sale" then begin
                POSTerminal.Get(Transaction."POS Terminal No.");

                if Transaction.GetPrintedCounter(1) > 0 then begin
                    if not cduSender.OpenReceiptPrinter(2, 'SALES', 'COPY', Transaction."Transaction No.", Transaction."Receipt No.") then
                        ReturnValue := false;
                end
                else begin
                    if not cduSender.OpenReceiptPrinter(2, 'SALES', '', Transaction."Transaction No.", Transaction."Receipt No.") then
                        ReturnValue := false;
                end;

                PrintLogo(2);
                cduSender.PrintHeader(Transaction, false, 2);

                RetailSetup.Get();
                if (GenPosFunc."Print Tax Invoice on Receipt") and (RetailSetup."W1 for Country  Code" = RetailSetup."W1 for Country  Code"::AE) then
                    PrintTaxHeader(Transaction, 2);
                if (RetailSetup."W1 for Country  Code" = RetailSetup."W1 for Country  Code"::ZA) then
                    PrintTaxHeader(Transaction, 2);

                PrintSubHeader(Transaction, 2, Transaction.Date, Transaction.Time);

                PrintSalesInfo(Transaction, 2);
                if Transaction."Member Card No." <> '' then
                    PrintLoyalty(Transaction, 2);

                PrintRecommendation(Transaction);

                PrintFooter(Transaction, 2);
                if Transaction."Post as Shipment" then
                    PrintSignature('');

                if POSTerminal."Receipt Barcode" and not Transaction."Sale Is Return Sale" then begin
                    GetReceiptBarcodeWidthAndHeight(POSTerminal, bcWidth, bcHeight);
                    if POSTerminal."Receipt Barcode ID" > 0 then begin
                        bc := 'T' + Format(POSTerminal."Receipt Barcode ID", 4, '<Integer,4><Filler Character,0>') +
                          Format(Transaction."Transaction No.", 9, '<Integer,9><Filler Character,0>');
                        PrintBarcode(2, bc, bcWidth, bcHeight, Format(POSTerminal."Print Receipt BC Type"), 2);
                    end
                    else
                        PrintBarcode(2, 'T' + Transaction."Receipt No.", bcWidth, bcHeight, Format(POSTerminal."Print Receipt BC Type"), 2);

                    PrintSpoOrderBarcode(Transaction, 2, true);
                end;
                if not cduSender.ClosePrinter(2) then
                    ReturnValue := false;
            end

        end;

        //Accounting Copy 
        IF not Transaction."Sale Is Return Sale" then
            if Transaction."Customer Type" <> Transaction."Customer Type"::" " then begin
                if not cduSender.OpenReceiptPrinter(2, 'SALES', '', Transaction."Transaction No.", Transaction."Receipt No.") then;
                PrintLogo(2);
                cduSender.PrintHeader(Transaction, false, 2);

                RetailSetup.Get();
                if (GenPosFunc."Print Tax Invoice on Receipt") and (RetailSetup."W1 for Country  Code" = RetailSetup."W1 for Country  Code"::AE) then
                    PrintTaxHeader(Transaction, 2);
                if (RetailSetup."W1 for Country  Code" = RetailSetup."W1 for Country  Code"::ZA) then
                    PrintTaxHeader(Transaction, 2);

                PrintSubHeader(Transaction, 2, Transaction.Date, Transaction.Time);

                PrintSalesInfo(Transaction, 2);
                if Transaction."Member Card No." <> '' then
                    PrintLoyalty(Transaction, 2);

                PrintRecommendation(Transaction);

                PrintFooter(Transaction, 2);
                if Transaction."Post as Shipment" then
                    PrintSignature('');

                if POSTerminal."Receipt Barcode" and not Transaction."Sale Is Return Sale" then begin
                    GetReceiptBarcodeWidthAndHeight(POSTerminal, bcWidth, bcHeight);
                    if POSTerminal."Receipt Barcode ID" > 0 then begin
                        bc := 'T' + Format(POSTerminal."Receipt Barcode ID", 4, '<Integer,4><Filler Character,0>') +
                          Format(Transaction."Transaction No.", 9, '<Integer,9><Filler Character,0>');
                        PrintBarcode(2, bc, bcWidth, bcHeight, Format(POSTerminal."Print Receipt BC Type"), 2);
                    end
                    else
                        PrintBarcode(2, 'T' + Transaction."Receipt No.", bcWidth, bcHeight, Format(POSTerminal."Print Receipt BC Type"), 2);

                    PrintSpoOrderBarcode(Transaction, 2, true);

                end;
                PrintAccountingCopy();

                if not cduSender.ClosePrinter(2) then
                    ReturnValue := false;
            end;
        //Accounting Copy
        bSecondPrintActive := false;
        Transaction.IncPrintedCounter(1);
        Commit;

        ReturnValue := true;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", OnBeforePrintTenderDeclSlip, '', false, false)]
    local procedure "LSC POS Print Utility_OnBeforePrintTenderDeclSlip"(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean; var ReturnValue: Boolean)
    var
        POSTerminal: Record "LSC POS Terminal";
        Qty: Integer;
        NumPrintSlips: Integer;
    begin
        APOnBeforePrintTenderDeclSlip(Sender, Transaction, PrintBuffer, PrintBufferIndex, LinesPrinted, DSTR1, IsHandled, ReturnValue);
        if IsHandled then
            exit;

        IsHandled := true;
        if Transaction."Transaction Type" <> Transaction."Transaction Type"::"Tender Decl." then
            ReturnValue := false;

        if not POSTerminal.Get(Globals.TerminalNo) then
            ReturnValue := false;

        TendDeclEntry.SetCurrentKey("Store No.", "POS Terminal No.", "Transaction No.");
        Qty := 0;
        NumPrintSlips := NumTenderDeclSlips(Transaction);
        //repeat
        if not cduSender.OpenReceiptPrinter(2, 'TENDER', 'DECL', Transaction."Transaction No.", Transaction."Receipt No.") then
            ReturnValue := false;


        PrintLogo(2);
        cduSender.PrintHeader(Transaction, false, 2);
        PrintSubHeader(Transaction, 2, Transaction.Date, Transaction.Time);
        if Transaction.GetPrintedCounter(1) > 0 then
            PrintCopyText(2);

        if Transaction."Entry Status" = Transaction."Entry Status"::Training then
            PrintTrainingText(2);

        PrintTransType(Transaction, 2);

        Clear(TendDeclEntry);
        LocalTotal := 0;
        TendDeclEntry.SetRange("Store No.", Transaction."Store No.");
        TendDeclEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TendDeclEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        BufferTendDeclEntry;

        TempTendDeclEntry.SetFilter("Currency Code", '=%1', '');
        PrintTenderDeclLines;
        if TempTendDeclEntry.Count > 1 then begin
            DSTR1 := '#L#################    #R###############';
            FieldValue[1] := Text005 + ' ' + Globals.GetValue("LSC POS Tag"::"CURRSYM");
            NodeName[1] := 'Total Text';
            FieldValue[2] := POSFunctions.FormatAmount(LocalTotal);
            NodeName[2] := 'Total Amount';
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
            AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, true, false, false, 2);
            PrintLineFeed(2, 1);
        end;

        TempTendDeclEntry.SetFilter("Currency Code", '<>%1', '');
        PrintTenderDeclLines;
        PrintCashDeclaration(Transaction);
        PrintSignature('');

        PrintNonSalesFooter(Transaction, 2);
        if not cduSender.ClosePrinter(2) then
            ReturnValue := false;
        //Qty := Qty + 1;
        //until Qty = NumPrintSlips;
        Transaction.IncPrintedCounter(1);
        Commit;
        ReturnValue := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", OnBeforePrintRemoveAddTenderSlip, '', false, false)]
    local procedure "LSC POS Print Utility_OnBeforePrintRemoveAddTenderSlip"(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean; var ReturnValue: Boolean)
    var
        POSTerminal: Record "LSC POS Terminal";
        Qty: Integer;
        NoOfCopies: Integer;
        FiscalOption: Integer;
        Text039: Label 'DRAWER COPY';
        Text040: Label 'COPY WITH REMOVAL';
    begin
        APOnBeforePrintRemoveAddTenderSlip(Sender, Transaction, PrintBuffer, PrintBufferIndex, LinesPrinted, DSTR1, IsHandled, ReturnValue);
        if IsHandled then
            exit;
        IsHandled := true;
        if (Transaction."Transaction Type" <> Transaction."Transaction Type"::"Float Entry") and
           (Transaction."Transaction Type" <> Transaction."Transaction Type"::"Remove Tender") then
            ReturnValue := FALSE;
        if Transaction."Transaction Type" = Transaction."Transaction Type"::"Remove Tender" then begin
            NoOfCopies := NumTenderDeclSlips(Transaction);
            Sign := -1;
            //FiscalOption := gPrintBufferRef.FiscalLineType::RemoveTender;
        end else begin
            NoOfCopies := 1;
            Sign := 1;
            //FiscalOption := gPrintBufferRef.FiscalLineType::FloatTender;
        end;

        if not POSTerminal.Get(Globals.TerminalNo) then
            ReturnValue := FALSE;

        Qty := 0;
        repeat
            if not cduSender.OpenReceiptPrinter(2, 'TENDER', 'ADDREMOVE', Transaction."Transaction No.", Transaction."Receipt No.") then
                ReturnValue := FALSE;

            PrintLogo(2);
            cduSender.PrintHeader(Transaction, false, 2);
            PrintSubHeader(Transaction, 2, Transaction.Date, Transaction.Time);

            if Transaction.GetPrintedCounter(1) > 0 then
                PrintCopyText(2);

            if Transaction."Entry Status" = Transaction."Entry Status"::Training then
                PrintTrainingText(2);

            PrintTransType(Transaction, 2);

            Clear(PaymEntry);
            LocalTotal := 0;
            PaymEntry.SetRange("Store No.", Transaction."Store No.");
            PaymEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
            PaymEntry.SetRange("Transaction No.", Transaction."Transaction No.");
            PaymEntry.SetFilter("Currency Code", '=%1', '');
            PrintRemoveAddTenderLines(Transaction);
            PrintCashDeclTotalLCYLine(LocalTotal * Sign);
            PrintLineFeed(2, 1);
            PaymEntry.SetFilter("Currency Code", '<>%1', '');
            PrintRemoveAddTenderLines(Transaction);

            PrintCashDeclaration(Transaction);

            PrintSignature('');
            PrintNonSalesFooter(Transaction, 2);
            if Transaction."Transaction Type" = Transaction."Transaction Type"::"Remove Tender" then begin
                PrintLineFeed(2, 1);
                DSTR1 := '#L##################';
                if Qty = 1 then
                    FieldValue[1] := Text039
                else
                    FieldValue[1] := Text040;
                NodeName[1] := 'Description';
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, TRUE, FALSE, FALSE));
                cduSender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, 2);
            end;



            if not cduSender.ClosePrinter(2) then
                ReturnValue := FALSE;
            Qty := Qty + 1;
        until Qty = NoOfCopies;

        Transaction.IncPrintedCounter(1);
        Commit;
        ReturnValue := TRUE;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", OnBeforePrintVoidSlip, '', false, false)]
    local procedure "LSC POS Print Utility_OnBeforePrintVoidSlip"(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean; var ReturnValue: Boolean)
    VAR
        POSTerminal: Record "LSC POS Terminal";
        bc: Text;
        //DSTR1: Text[100];
        bcWidth: Integer;
        bcHeight: Integer;
        Tray: Integer;
    begin

        APOnBeforePrintVoidSlip(Sender, Transaction, PrintBuffer, PrintBufferIndex, LinesPrinted, DSTR1, IsHandled, ReturnValue);
        if IsHandled then
            exit;

        CurrentPrintID := 100;
        IsHandled := true;
        if Transaction."Transaction No." = 0 then
            ReturnValue := true;

        WindowInitialize();
        if GenPosFunc."Sales Slip Report ID" <> 0 then begin
            Transaction.SetRange("Store No.", Transaction."Store No.");
            Transaction.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
            Transaction.SetRange("Transaction No.", Transaction."Transaction No.");
            REPORT.Run(GenPosFunc."Sales Slip Report ID", false, true, Transaction);
        end else begin
            if not Transaction."Sale Is Return Sale" then begin
                POSTerminal.Get(Transaction."POS Terminal No.");


                if not cduSender.OpenReceiptPrinter(2, 'VOID', '', Transaction."Transaction No.", Transaction."Receipt No.") then
                    ReturnValue := false;

                PrintLogo(2);
                cduSender.PrintHeader(Transaction, false, 2);
                PrintSubHeader(Transaction, 2, Transaction.Date, Transaction.Time);
                if Transaction."Entry Status" = Transaction."Entry Status"::Training then
                    PrintTrainingText(2);
                PrintTransTypeVoid(Transaction, 2, true);
                PrintVOIDTransaction(Transaction, 2);
                PrintRecommendation(Transaction);
                PrintNonSalesFooter(Transaction, 2);
                if not cduSender.ClosePrinter(2) then
                    ReturnValue := false;
            end

        end;

        bSecondPrintActive := false;
        Transaction.IncPrintedCounter(1);
        Commit;

        ReturnValue := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", OnBeforePrintReturnsSlip, '', false, false)]
    local procedure OnBeforePrintReturnsSlip(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean; var ReturnValue: Boolean);
    var
        POSTerminal: Record "LSC POS Terminal";
        bc: Text;
        bcWidth: Integer;
        bcHeight: Integer;
        Tray: Integer;
        QRCodeDataString: Text;
        DeliveryReceipt: Label 'Delivery receipt';
        NOChargeTOAccountLbl1: Label 'NOT A';
        NOChargeTOAccountLbl2: Label 'PURCHASE RECEIPT';
    begin
        APOnBeforePrintReturnsSlip(Sender, Transaction, PrintBuffer, PrintBufferIndex, LinesPrinted, DSTR1, IsHandled, ReturnValue);
        if IsHandled then
            exit;
        CurrentPrintID := 100;
        IsHandled := true;
        if Transaction."Transaction No." = 0 then
            ReturnValue := true;

        WindowInitialize();
        if GenPosFunc."Sales Slip Report ID" <> 0 then begin
            Transaction.SetRange("Store No.", Transaction."Store No.");
            Transaction.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
            Transaction.SetRange("Transaction No.", Transaction."Transaction No.");
            REPORT.Run(GenPosFunc."Sales Slip Report ID", false, true, Transaction);
        end else begin

            POSTerminal.Get(Transaction."POS Terminal No.");

            if Transaction.GetPrintedCounter(1) > 0 then begin
                if not cduSender.OpenReceiptPrinter(2, 'RETURN', 'COPY', Transaction."Transaction No.", Transaction."Receipt No.") then
                    ReturnValue := false;
            end
            else begin
                if not cduSender.OpenReceiptPrinter(2, 'RETURN', '', Transaction."Transaction No.", Transaction."Receipt No.") then
                    ReturnValue := false;
            end;

            PrintLogo(2);
            cduSender.PrintHeader(Transaction, false, 2);

            RetailSetup.Get();
            if (GenPosFunc."Print Tax Invoice on Receipt") and (RetailSetup."W1 for Country  Code" = RetailSetup."W1 for Country  Code"::AE) then
                PrintTaxHeader(Transaction, 2);
            if (RetailSetup."W1 for Country  Code" = RetailSetup."W1 for Country  Code"::ZA) then
                PrintTaxHeader(Transaction, 2);

            PrintSubHeader(Transaction, 2, Transaction.Date, Transaction.Time);

            PrintTransTypeVoid(Transaction, 2, false);
            PrintSalesInfo(Transaction, 2); //22
            if Transaction."Member Card No." <> '' then
                PrintLoyalty(Transaction, 2);

            PrintRecommendation(Transaction);

            //OnBeforeSalesSlipPrintFooter(Transaction, PrintBuffer, PrintBufferIndex, LinesPrinted);
            PrintFooterPosVoid(Transaction, 2);

            PrintNonSalesFooter(Transaction, 2);
            if Transaction."Post as Shipment" then
                PrintSignature('');

            //OnAfterPrintSalesSlip(Transaction, PrintBuffer, PrintBufferIndex, LinesPrinted);

            if POSTerminal."Receipt Barcode" and not Transaction."Sale Is Return Sale" then begin
                GetReceiptBarcodeWidthAndHeight(POSTerminal, bcWidth, bcHeight);
                if POSTerminal."Receipt Barcode ID" > 0 then begin
                    bc := 'T' + Format(POSTerminal."Receipt Barcode ID", 4, '<Integer,4><Filler Character,0>') +
                      Format(Transaction."Transaction No.", 9, '<Integer,9><Filler Character,0>');
                    PrintBarcode(2, bc, bcWidth, bcHeight, Format(POSTerminal."Print Receipt BC Type"), 2);
                end
                else
                    PrintBarcode(2, 'T' + Transaction."Receipt No.", bcWidth, bcHeight, Format(POSTerminal."Print Receipt BC Type"), 2);

                PrintSpoOrderBarcode(Transaction, 2, true);
            end;
            if not cduSender.ClosePrinter(2) then
                ReturnValue := false;

        end;
        bSecondPrintActive := false;
        Transaction.IncPrintedCounter(1);
        Commit;

        ReturnValue := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", OnBeforePrintSubHeader, '', false, false)]
    local procedure "LSC POS Print Utility_OnBeforePrintSubHeader"(var Sender: Codeunit "LSC POS Print Utility"; var TransactionHeader: Record "LSC Transaction Header"; Tray: Integer; var POSPrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var IsHandled: Boolean)
    var
        Staff: Record "LSC Staff";
        DSTR1: Text[100];
        StaffName: Text;
        blankStr: Text;
        SalesReceiptText: Label 'Sales Receipt';
    begin

        APOnBeforePrintSubHeader(Sender, TransactionHeader, Tray, PrintBuffer, PrintBufferIndex, LinesPrinted, IsHandled);
        if IsHandled then
            exit;

        IsHandled := true;

        if Tray = 2 then
            blankStr := StringPad(' ', LineLen - 38)
        else
            if Tray = 4 then
                blankStr := StringPad(' ', InvLineLen - 38);

        if blankStr = '' then
            blankStr := ' ';

        Clear(Value);
        //Transction No. and Transaction Code Type
        DSTR1 := '#L#### #L################## #L### #L###';
        Value[1] := 'TR ' + ':';
        NodeName[1] := 'x';
        Value[2] := TransactionHeader."Receipt No.";
        NodeName[2] := 'Receipt No.';
        Value[3] := 'Type:';
        Value[4] := COPYSTR(FORMAT(TransactionHeader."Transaction Code Type"), 1, 4);
        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, true, false, false));
        cduSender.AddPrintLine(200, 2, NodeName, Value, DSTR1, false, true, false, false, Tray);

        //Invoice No.
        DSTR1 := '#L############### #L##############';
        DSTR1 := '#L############# #L################';
        Value[1] := 'Sales Invoice #:';
        Value[2] := TransactionHeader."Invoice No.";
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        cduSender.AddPrintLine(200, 2, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);

        DSTR1 := '#L#### #L############' + blankStr + '#L#### #N########';
        StaffName := TransactionHeader."Staff ID";
        if Staff.Get(TransactionHeader."Staff ID") then
            StaffName := Staff."Name on Receipt";

        Value[1] := Text051 + ':';
        NodeName[1] := 'x';
        Value[2] := StaffName;
        NodeName[2] := 'x';
        Value[3] := 'Store' + ':';
        NodeName[3] := 'x';
        Value[4] := Format(TransactionHeader."Store No.");
        NodeName[4] := 'Transaction No.';
        if TransactionHeader."Transaction No." = 0 then begin
            Value[3] := '';
            NodeName[3] := 'x';
            Value[4] := '';
            NodeName[4] := 'x';
        end;
        Value[5] := TransactionHeader."Staff ID";
        NodeName[5] := 'Staff ID';
        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, true, false, false));
        cduSender.AddPrintLine(200, 5, NodeName, Value, DSTR1, false, true, false, false, Tray);
        Clear(Value);
        DSTR1 := '#L#### #T###### #T###' + blankStr + '#L### #N#########';
        Value[1] := Text048 + ':';
        NodeName[1] := 'x';
        //POSTrans."Original Date", TransactionHeader."Trans Time"
        Value[2] := Format(TransactionHeader."Original Date");
        NodeName[2] := 'Trans. Date';
        Value[3] := Format(TransactionHeader.time, 5);
        NodeName[3] := 'Trans. Time';
        Value[4] := 'POS:';
        NodeName[4] := 'x';
        Value[5] := Format(TransactionHeader."POS Terminal No.");
        NodeName[5] := 'Terminal';
        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, true, false, false));
        cduSender.AddPrintLine(200, 3, NodeName, Value, DSTR1, false, true, false, false, Tray);

        if TransactionHeader.Comment <> '' then begin
            Clear(Value);
            DSTR1 := '#L#### #T############################';
            if TransactionHeader."Table No." <> 0 then
                Value[1] := Text500 + ':'
            else
                Value[1] := Text367 + ':';
            NodeName[1] := 'x';
            Value[2] := Format(copystr(TransactionHeader.Comment, 1, 80));
            NodeName[2] := 'x';
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, true, false, false));
            cduSender.AddPrintLine(200, 2, NodeName, Value, DSTR1, false, true, false, false, Tray);
        end;
        PrintSeperator(Tray);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", OnBeforePrintSuspendSlip, '', false, false)]
    local procedure "LSC POS Print Utility_OnBeforePrintSuspendSlip"(var Sender: Codeunit "LSC POS Print Utility"; var DSTR1: Text[100]; var IsHandled: Boolean; var ReturnValue: Boolean; var POSTrans: Record "LSC POS Transaction"; var tmpPosTransLines: Record "LSC POS Trans. Line" temporary; GrAmount: Decimal)
    var
        POSTerminal: Record "LSC POS Terminal";
        SalesType: Record "LSC Sales Type";
        Transaction: Record "LSC Transaction Header";
        Customer: Record Customer;
        ItemTranslate: Record "Item Translation";
        POSTransSusp: Record "LSC POS Transaction";
        CreatedPOSTerminal: Record "LSC POS Terminal";
        item: record Item;
        bc: Text;
        bcWidth: Integer;
        bcHeight: Integer;
        ReceiptBarcodeID: Integer;
        SkipPrintTotalOnSuspendSlip: Boolean;
        Text033: Label 'SUSPENDED';
        Text218: Label 'Prev. Prepayments';
        BalanceLbl: Label 'Balance';
        PcsLbl: Label 'pcs';
    begin
        APOnBeforePrintSuspendSlip(Sender, DSTR1, IsHandled, ReturnValue, POSTrans, tmpPosTransLines, GrAmount);
        if IsHandled then
            exit;
        IsHandled := true;
        if not POSTerminal.Get(Globals.TerminalNo) then
            ReturnValue := true;

        if not cduSender.OpenReceiptPrinter(2, 'SUSPEND', '', 0, POSTrans."Receipt No.") then
            ReturnValue := false;
        Clear(Transaction);
        Transaction."POS Terminal No." := Globals.TerminalNo;
        Transaction.Date := POSTrans."Trans. Date";
        Transaction.Time := POSTrans."Trans Time";

        Transaction."Receipt No." := tmpPosTransLines."Receipt No.";
        Transaction."Staff ID" := POSTrans."Staff ID";
        if not POSTransSusp.Get(Transaction."Receipt No.") then
            Clear(POSTransSusp);
        PrintLogo(2);

        if IsHandled then
            ReturnValue := true;
        cduSender.PrintHeader(Transaction, false, 2);
        PrintSubHeader(Transaction, 2, Transaction.Date, Transaction.Time);
        //here
        DSTR1 := '#C##################';
        FieldValue[1] := Text033;
        NodeName[1] := 'Description';
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), true, true, true, false));
        if not IsHandled then
            if (POSTrans."Sales Type" <> '') and SalesType.Get(POSTrans."Sales Type") and (SalesType.Description <> '') then begin
                FieldValue[1] := SalesType.Description;
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), true, true, true, false));
            end;

        cduSender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, true, true, true, false, 2);
        PrintSeperator(2);
        PrintLineFeed(2, 1);

        tmpPosTransLines.SetRange("Entry Type", tmpPosTransLines."Entry Type"::Item);
        tmpPosTransLines.SetRange("Entry Status", tmpPosTransLines."Entry Status"::" ");
        if IsHandled then
            ReturnValue := True;
        if tmpPosTransLines.FindSet() then begin
            DSTR1 := '#L###################### #L#############';
            FieldValue[1] := Text071;
            FieldValue[2] := Text143;
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
            PrintSeperator(2);
            repeat
                item.Get(tmpPosTransLines.Number);
                tmpPosTransLines."Unit of Measure" := item."Sales Unit of Measure";
                if tmpPosTransLines."Unit of Measure" = '' then
                    tmpPosTransLines."Unit of Measure" := PcsLbl;
                FieldValue[1] := RetailHelper.Trim(tmpPosTransLines.Description, 50);

                if Customer.Get(POSTrans."Customer No.") then
                    if Customer."Language Code" <> '' then
                        if ItemTranslate.Get(tmpPosTransLines.Number,
                                             tmpPosTransLines."Variant Code",
                                             Customer."Language Code") then
                            if ItemTranslate.Description <> '' then
                                FieldValue[1] := ItemTranslate.Description;

                FieldValue[2] := POSFunctions.FormatQty(tmpPosTransLines.Quantity) + ' ' + LowerCase(tmpPosTransLines."Unit of Measure");
                if IsHandled then
                    ReturnValue := true;
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                FieldValue[2] := FieldValue[1];
                FieldValue[1] := tmpPosTransLines.Number;
                NodeName[1] := 'Item No.';
                NodeName[2] := 'Item Description';
                FieldValue[3] := tmpPosTransLines."Unit of Measure";
                NodeName[3] := 'UOM ID';
                FieldValue[4] := POSFunctions.FormatQty(tmpPosTransLines.Quantity);
                NodeName[4] := 'Quantity';
                AddPrintLine(300, 4, NodeName, FieldValue, DSTR1, false, false, false, false, 2);
            until tmpPosTransLines.Next = 0;
            PrintSeperator(2);
        end;

        if not SkipPrintTotalOnSuspendSlip then begin
            DSTR1 := '#L################# #R###############   ';
            FieldValue[1] := Text005;
            NodeName[1] := 'Total Text';
            FieldValue[2] := POSFunctions.FormatAmount(GrAmount);
            NodeName[2] := 'Total Amount';
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
            AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, true, false, false, 2);
            PrintSeperator(2);

            tmpPosTransLines.SetRange("Entry Type", tmpPosTransLines."Entry Type"::IncomeExpense);
            tmpPosTransLines.SetRange("Entry Status", tmpPosTransLines."Entry Status"::" ");
            if tmpPosTransLines.FindSet() then begin
                DSTR1 := '#L#################### #N############';
                repeat
                    GrAmount += tmpPosTransLines.Amount;
                    FieldValue[1] := RetailHelper.Trim(tmpPosTransLines.Description, 50);
                    NodeName[1] := 'Total Text';
                    FieldValue[2] := POSFunctions.FormatAmount(-tmpPosTransLines.Amount);
                    NodeName[2] := 'Total Amount';
                    cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                    AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, 2);
                until tmpPosTransLines.Next = 0;
                POSTrans.CalcFields("Gross Amount", "Income/Exp. Amount");
                if (POSTrans."Income/Exp. Amount" <> 0)
                and (POSTrans."Gross Amount" - GrAmount + POSTrans."Income/Exp. Amount" <> 0) then begin
                    FieldValue[1] := Text218;
                    NodeName[1] := 'Total Text';
                    FieldValue[2] := POSFunctions.FormatAmount(GrAmount - POSTrans."Gross Amount" - POSTrans."Income/Exp. Amount");
                    NodeName[2] := 'Total Amount';
                    cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                    AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, 2);
                    GrAmount := POSTrans."Gross Amount" + POSTrans."Income/Exp. Amount";
                end;

                PrintSeperator(2);
                PrintLineFeed(2, 1);
                DSTR1 := '#L################# #R###############   ';
                FieldValue[1] := BalanceLbl;
                NodeName[1] := 'Total Text';
                FieldValue[2] := POSFunctions.FormatAmount(GrAmount);
                NodeName[2] := 'Total Amount';
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
                AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, true, false, false, 2);
                PrintSeperator(2);
            end;
        end;

        PrintFooterPosVoid(Transaction, 2);
        PrintNonSalesFooter(Transaction, 2);
        POSTerminal.Get(Transaction."POS Terminal No.");
        if POSTerminal."Receipt Barcode" then begin
            GetReceiptBarcodeWidthAndHeight(POSTerminal, bcWidth, bcHeight);
            if POSTerminal."Receipt Barcode ID" > 0 then begin
                ReceiptBarcodeID := POSTerminal."Receipt Barcode ID";
                if POSTerminal."No." <> POSTransSusp."Created on POS Terminal" then begin
                    if CreatedPOSTerminal.Get(POSTransSusp."Created on POS Terminal") then
                        if CreatedPOSTerminal."Receipt Barcode ID" > 0 then
                            ReceiptBarcodeID := CreatedPOSTerminal."Receipt Barcode ID";
                end;
                bc := 'P' + Format(ReceiptBarcodeID, 4, '<Integer,4><Filler Character,0>') + CopyStr(Transaction."Receipt No.", 11);
                PrintBarcode(2, bc, bcWidth, bcHeight, Format(POSTerminal."Print Receipt BC Type"), 2);
            end
            else
                PrintBarcode(2, 'P' + Transaction."Receipt No.", bcWidth, bcHeight, Format(POSTerminal."Print Receipt BC Type"), 2);
        end;
        if not cduSender.ClosePrinter(2) then
            ReturnValue := false;
        ReturnValue := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", OnAfterPrintSlips, '', false, false)]
    local procedure "LSC POS Print Utility_OnAfterPrintSlips"(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var MsgTxt: Text[50]; PrintSlip: Boolean; var ReturnValue: Boolean)

    var
        postransction: Codeunit "LSC POS Transaction";
        paymentEnrty: Record "LSC Trans. Payment Entry";
        Change: label 'Change: %1';
        POSGUI: Codeunit "LSC POS GUI";
        RtcGUI: Codeunit "LSC POS Control Interface";
        window: Dialog;
        Answer: Boolean;
    begin
        if Transaction.GetPrintedCounter(1) = 1 then
            if not Transaction."Sale Is Return Sale" then begin
                paymentEnrty.Reset();
                paymentEnrty.SetRange("Receipt No.", Transaction."Receipt No.");
                paymentEnrty.SetRange("Change Line", true);
                if paymentEnrty.FindFirst() then
                    if ABS(paymentEnrty."Amount Tendered") > 0 then begin
                        // Window.OPEN(StrSubstNo(Change, ABS(paymentEnrty."Amount Tendered")));
                        // //window.Update(1, ABS(paymentEnrty."Amount Tendered"));
                        // 
                        // Answer := Dialog.Confirm('Change: %1', true, ABS(paymentEnrty."Amount Tendered"));
                        //Message();
                        Postransction.PosMessageBanner(StrSubstNo(Change, Format(ABS(paymentEnrty."Amount Tendered"), 0, '<Sign><Integer Thousand><Decimal,3>')));
                        Sleep(2000);
                        // POSGUI.PostCommand("LSC POS Command"::MESSAGEBEEP, (StrSubstNo(Change, POSFunctions.FormatAmount(ABS(paymentEnrty."Amount Tendered")))));
                        // POSGUI.PostCommand("LSC POS Command"::CONFIRM, (StrSubstNo(Change, POSFunctions.FormatAmount(ABS(paymentEnrty."Amount Tendered")))));
                        PosMessage(StrSubstNo(Change, POSFunctions.FormatAmount(ABS(paymentEnrty."Amount Tendered"))));
                        //Postransction.PosMessage(StrSubstNo(Change, POSFunctions.FormatAmount(ABS(paymentEnrty."Amount Tendered"))));
                    end;
            end
    end;

    local procedure PosMessage(Txt: text): Boolean
    var
        Ok: Boolean;
        IsHandled: Boolean;
        ReturnVal: Boolean;
    begin
        //PosMessage
        // cduPOSTransactionEvents.OnBeforePosMessage(recPOSTransaction, COPYSTR(Txt, 1, 100), IsHandled, ReturnVal);
        Ok := POSGUI.PosMessage(Txt);
        EXIT(Ok);
    end;

    local procedure PrintAccountingCopy()
    var
        DSTR1: Text[50];

    begin
        CLEAR(FieldValue);

        if store.FindFirst() then begin
            PrintSeperator(2);
            DSTR1 := '#C#################################';
            FieldValue[1] := '*** Accounting Copy ***';
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
            PrintSeperator(2);
        end

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnAfterPrintLine', '', false, false)]
    local procedure OnAfterPrintLine_OpenWriteCloseEJFile(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var Tray: Integer; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer);

    begin
        //cloud version
        // EJFile.TEXTMODE(TRUE);
        // EJFile.WRITEMODE(TRUE);
        // recPOSTerminal.GET(Globals.TerminalNo);
        // IF recPOSTerminal."EJ Local Path" <> '' THEN BEGIN
        //     EJFilename := recPOSTerminal."EJ Local Path" + '\EJ' + Globals.TerminalNo + FORMAT(TODAY, 0, '<Month><day><year>') + '.TXT';
        // END ELSE BEGIN
        //     EJFilename := 'C:\EJ' + Globals.TerminalNo + FORMAT(TODAY, 0, '<Month><day><year>') + '.TXT';
        // END;
        // IF NOT EJFile.OPEN(EJFilename) THEN BEGIN
        //     IF NOT EXISTS(EJFilename) THEN
        //         EJFile.CREATE(EJFilename)
        // END ELSE
        //     EJFile.SEEK(EJFile.LEN);
        // PrintBuffer.SetRange("Printed Line No.", LinesPrinted);
        // PrintBuffer.SetRange("Transaction No.", Transaction."Transaction No.");
        // IF Tray <> 4 THEN
        //     EJFile.WRITE(COPYSTR(PrintBuffer.text, 1));
        // EJFile.CLOSE;
        //cloud version
    end;


    //Ending*************************************Events*************************************

    var //Global variable
        //PosTransactionGui: Codeunit "LSC POS Transaction GUI";
        recBLOBFile: record "BLOB File Storage";
        cduBLOBFileMgt: Codeunit BLOBFileManagement;
        TenderTypeCardSetup: record "LSC Tender Type Card Setup";
        APPOSSESSIONS: Record "AP POSSESSIONS";
        MyPOSAddiFunc: Codeunit "LSC POS Additional Functions";
        PosSetup: Record "LSC POS Hardware Profile";
        TendDeclEntry: Record "LSC Trans. Tender Declar. Entr";
        PaymEntry: Record "LSC Trans. Payment Entry";
        TenderType: Record "LSC Tender Type";
        Currency: Record Currency;
        GenPosFunc: Record "LSC POS Func. Profile";
        Store: Record "LSC Store";
        glTrans: Record "LSC Transaction Header";
        HospitalityType: Record "LSC Hospitality Type";
        ActivePrinter: Record "LSC POS Printer";
        ActivePrintHeader: Record "LSC POS Print Header";
        ActivePrintLine: Record "LSC POS Print Line";
        TaxArea: Record "Tax Area";
        RetailSetup: Record "LSC Retail Setup";
        tmpDeal: Record "LSC Offer" temporary;
        TempTendDeclEntry: Record "LSC Trans. Tender Declar. Entr" temporary;
        TempTransInfoCode: Record "LSC Trans. Infocode Entry" temporary;
        TmpPrintedSalesEntry: Record "LSC Trans. Sales Entry" temporary;
        PrintBuffer: Record "LSC POS Print Buffer" temporary;
        TmpPrintedDealPOSTransLine: Record "LSC POS Trans. Line" temporary;
        PeriodicDiscountInfoTEMP: Record "LSC Periodic Discount" temporary;
        POSTransPeriodicDiscTEMP: Record "LSC POS Trans. Per. Disc. Type" temporary;
        PrintBufferExt: Record "LSC POS Print Buffer Ext." temporary;
        TmpDealHdrTransLine: Record "LSC POS Trans. Line" temporary;
        CustomerOrderHeader_Temp: Record "LSC Customer Order Header" temporary;
        CustomerOrderLine_Temp: Record "LSC Customer Order Line" temporary;
        CustomerOrderPayment_Temp: Record "LSC Customer Order Payment" temporary;
        CustomerOrderDiscountLine_Temp: Record "LSC CO Discount Line" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        Globals: Codeunit "LSC POS Session";
        BOUTIL: Codeunit "LSC BO Utils";
        ApplMan: Codeunit "LSC AutoFormatMgt Ext.";
        POSFunctions: Codeunit "LSC POS Functions";
        RetailHelper: Codeunit "LSC helper";
        codPOSTrans: Codeunit "LSC POS Transaction";
        POSGUI: Codeunit "LSC POS GUI";
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        LocalizationExt: Codeunit "LSC Retail Localization Ext.";
        Value: array[10] of Text[80];
        GlobalScreenLines: array[300] of Text[250];
        NodeName: array[32] of Text[50];
        BreakdownLabel: array[4] of Text[30];
        CpnBarcodeMaskSymbology: Text[30];
        TipsText1: Text;
        TipsText2: Text;
        MailRecipients: Text;
        MailSubject: Text;
        LastErrorText: Text;
        OverrideWindowPrinterName: Text;
        ESC: Text[1];
        tmpCode: Code[50];
        TerminalNo: Code[10];
        PrevTaxPercent: Decimal;
        LocalTotal: Decimal;
        totSPOAmount: Decimal;
        Subtotal: Decimal;
        TotalAmt: Decimal;
        TipsAmount1: Decimal;
        TipsAmount2: Decimal;
        POSSlipTotAmt: Decimal;
        POSSlipSubTotAmt: Decimal;
        TotalLCYInCurrency: Decimal;
        DesignWidthMultiplier: Decimal;
        BreakdownAmt: array[4] of Decimal;
        LineLen: Integer;
        InvLineLen: Integer;
        LinesPrinted: Integer;
        PageNo: Integer;
        Sign: Integer;
        gNoSuspPOSTransactionsVoided: Integer;
        PrintBufferIndex: Integer;
        CurrentPrintID: Integer;
        ActivePrintEntryNo: Integer;
        BrkIdx: Integer;
        PrevPrintOrder: Integer;
        ActiveFontType: Option Normal,Bold,Wide,High,WideAndHight,Italic;
        IsInvoice: Boolean;
        //FisPOSCommand: Codeunit "LSC Fiscal POS Commands";
        VoidedVoucher: Boolean;
        CouponPrinting: Boolean;
        bSecondPrintActive: Boolean;
        CpnPrinting: Boolean;
        WebPrinting: Boolean;
        DisplayOpen: Boolean;
        FiscalON: Boolean;
        FieldValue: array[10] of Text[100];
        OnlyFiscal: Boolean;
        NoPrint_BufferOnly: Boolean;
        KDSwebServiceCalling: Boolean;
        UseTransactionStoreAndPOSForPrintHeader: Boolean;
        EJFile: File;
        EJFilename: Text[100];
        recPOSTerminal: Record "LSC POS Terminal";
        recRetailCalendarLine: Record "LSC Retail Calendar Line";
        vDay: Date;
        recReportBuffer: Record Item temporary;
        ShortOver: Decimal;
        TotalCashAmount: Decimal;
        recNoOfVoidedTrans: Record "LSC Transaction Header";
        recNoofLogon: Record "LSC Transaction Header";
        decTenderAmount: Array[100] of Decimal;
        intNoOfTender: Array[100] of integer;
        txtCardDetailsDescArr: array[100] of text[1024];
        decCardDetailsAmtArr: array[100] of Decimal;
        intCardDetailsCountArr: array[100] of Integer;
        txtCardDetailsDescArr1: array[100] of text[1024];
        decCardDetailsAmtArr1: array[100] of Decimal;
        intCardDetailsCountArr1: array[100] of Integer;
        ActiveTray: Integer;
        //cduPOSAdditionalFunctions: Codeunit " POS Additional Functions";
        TotalTenderDecl: Decimal;
        txtAccumSales: Array[500] of Text;
        gStaffName: Text[100];
        gTimeStart: text;
        gTimeEnd: Text;
        decDeliveryCharge: Decimal;
        decNonVatNetSr: Decimal;
        decTotalTend: Decimal;
        decLVATEx: Decimal;
        decLZeroRated, decLZeroRatedAmount, decLZeroRatedSales : Decimal;
        TransDate: Date;
        ctr: Integer;
        optRunType: Option X,Z,Y;

        POSSESSION: Codeunit "LSC POS Session";
        GiftCardCurrencyCode: Code[10];
        MyPOSFunctions: Codeunit APEventSubscriber;
        POSPrintUtilityExt: Codeunit "LSC POS Print Utility Extras";
        IsSlipCopyRequest: Boolean;
        RecommCount: Integer;
        PrintExtraSignatureLines: boolean;
        MyLSCPOSTransaction: Codeunit "AP POS Transaction";
        MyPosPriceUtil: Codeunit LSCPOSPriceUtilityExt;
        cduSender: Codeunit "LSC POS Print Utility";


        //start ************************************Text Label*************************************
        RecommendationText: Label 'You might also like:   ';
        Text90001: Label 'Cashier Reading';
        Text90002: Label 'Terminal Reading';
        Text90003: Label 'Y-REPORT';
        Text90004: Label 'Z-REPORT';
        Text90005: Label 'X-Report ID:';
        Text90006: Label 'Order No.:';
        Text63069: Label 'Z-REPORT (RE-PRINT)';
        Text63045: Label 'WHT Amount';
        Text63060: Label 'VAT Withholding';
        Text63061: Label 'Senior Disc.';
        Text63062: Label 'Beginning Bal.';
        Text63063: Label 'New Balance';
        Text63064: Label 'Check';
        Text63065: Label 'Cards';
        Text63066: Label 'VATable Sales';
        Text63067: Label 'VAT Exempt Sales';
        Text63068: Label 'Z-Report Id does not exist!';
        Text63070: Label 'Less VAT';
        Text63071: Label '* * REPRINT * *';
        Text63072: Label 'THIS DOCUMENT IS NOT VALID FOR CLAIM OF INPUT TAX.';
        Text63074: Label 'Zero-rated Sales';
        Text63075: Label 'XXXX-XXXX-XXXX-';
        Text68000: Label 'Senior Disc.';
        Text68001: Label 'PWD Disc.';
        Text63000: Label 'Old Accumulated Sales';
        Text63001: Label 'New Accumulated Sales';
        Text63002: Label 'Beginning InvNo';
        Text63003: Label 'Ending InvNo';
        Text63004: Label 'Total Refund Amount';
        Text63005: Label 'Total Voided Trans.';
        Text63006: Label 'No. of Voided Line';
        Text63007: Label 'Total Voided Line';
        Text63008: Label 'Y-REPORT (Terminal)';
        Text63009: Label 'Invoice No.';
        Text63010: Label 'Store';
        Text63011: Label 'InvNo';
        Text63012: Label 'Date Printed:';
        Text63013: Label 'What Floor :';
        Text63014: Label 'Cancelled Line Disc.';
        Text001: Label 'Insert document in printer.';
        Text002: Label 'Expires';
        Text003: Label 'RETURN';
        Text004: Label 'Amount';
        Text005: Label 'Total';
        Text006: Label 'Paid into account no.';
        Text007: Label 'Charge my account no.';
        Text009: Label 'Float entry';
        Text010: Label 'Remove tender';
        Text011: Label 'Gross Sales';
        Text012: Label 'Discount';
        Text015: Label 'Charged to my debetcard';
        Text020: Label 'Slip';
        Text024: Label 'Total Discount';
        Text042: Label 'Subtotal';
        Text046: Label '** COPY **';
        Text047: Label '** TRAINING **';
        Text048: Label 'Date';
        Text051: Label 'Staff';
        Text052: Label 'Trans';
        Text063: Label 'VAT';
        Text063_2: Label 'Net.Amt';
        Text078: Label 'Store no.';
        Text079: Label 'Terminal';
        Text071: Label 'Description';
        Text074: Label 'Item No.: ';
        Text075: Label 'Barcode: ';
        Text084: Label 'Line Discount';
        Text093: Label 'Rounding';
        Text094: Label 'Signature';
        Text129: Label 'The length of the barcode is not correct.';
        Text131: Label 'pcs';
        Text133: Label 'VAT RegNo.:';
        Text143: Label 'Quantity';
        Text145: Label 'Voided';
        Text159: Label 'Tender Type';
        Text160: Label 'Qty.';
        Text162: Label 'Denomination';
        Text163: Label 'SAFE TRANSACTION';
        Text164: Label 'BANK TRANSACTION';
        Text232: Label 'Points';
        Text321: Label 'Tips';
        Text353: Label 'Printing %1';
        Text354: Label 'POS Printer %1 does not exist';
        Text367: Label 'ID';
        Text500: Label 'Table';
        Text501: Label 'Deal';
        Text502: Label 'Deal Modifier';
        Text10001: Label 'Sales Tax';
        MixedReceiptText: Label 'Sale/Refund Receipt';
        Stars: Label '*********************************************************************************';
        Blanks: Label '                                                                                ';
        Zeros: Label '000000000000000000000000000000000000000000000000000000000000000000000000000000000';
        Hashes: Label '################################################################################';
        MixedReceiptText1: Label 'PURCHASE/REFUND';
        MixedReceiptText2: Label 'RECEIPT';
        RePrintCopy: Label '*** COPY %1 ***';

    //Start **********************************Localize Procedures*************************************
    procedure PrintRemoveAddTenderLines(Transaction: Record "LSC Transaction Header")
    var
        TenderType: Record "LSC Tender Type";
        TenderCard: Record "LSC Tender Type Card Setup";
        TransInfoCode: Record "LSC Trans. Infocode Entry";
        DSTR1: Text[100];
        Payment: Text[30];
        IsHandled: Boolean;
    begin
        DSTR1 := '#L######## #R### #R######## #R##########';
        if PaymEntry.FindSet() then
            repeat
                Payment := PaymEntry."Tender Type";
                if TenderType.Get(PaymEntry."Store No.", PaymEntry."Tender Type") then
                    Payment := TenderType.Description
                else
                    Clear(TenderType);
                Clear(FieldValue);
                if TenderType."Function" <> TenderType."Function"::"Tender Remove/Float" then begin
                    LocalTotal := LocalTotal + PaymEntry."Amount Tendered";
                    if TenderType."Foreign Currency" then begin
                        FieldValue[1] := PaymEntry."Currency Code";
                        NodeName[1] := 'Currency Code';
                        NodeName[2] := 'x';
                        NodeName[3] := 'x';
                        if TenderType."Multiply in Tender Operations" then begin
                            FieldValue[2] := POSFunctions.FormatQty(PaymEntry.Quantity);
                            NodeName[2] := 'Quantity';
                            FieldValue[3] := POSFunctions.FormatAmount(Sign * PaymEntry."Amount in Currency" / PaymEntry.Quantity);
                            NodeName[3] := 'Tender Unit Value';
                        end;
                        FieldValue[4] := POSFunctions.FormatCurrency(Sign * PaymEntry."Amount in Currency", PaymEntry."Currency Code");
                        NodeName[4] := 'Amount In Currency';
                    end else begin
                        FieldValue[1] := Payment;
                        if (TenderType."Function" = TenderType."Function"::Card) then
                            if TenderCard.Get(PaymEntry."Store No.", PaymEntry."Tender Type", PaymEntry."Card No.") then
                                if TenderCard.Description <> '' then
                                    FieldValue[1] := TenderCard.Description;
                        NodeName[1] := 'Tender Description';
                        NodeName[2] := 'x';
                        NodeName[3] := 'x';
                        if TenderType."Multiply in Tender Operations" then begin
                            FieldValue[2] := POSFunctions.FormatQty(PaymEntry.Quantity);
                            NodeName[2] := 'Quantity';
                            FieldValue[3] := POSFunctions.FormatAmount(Sign * PaymEntry."Amount Tendered" / PaymEntry.Quantity);
                            NodeName[3] := 'Tender Unit Value';
                        end;
                        FieldValue[4] := POSFunctions.FormatAmount(Sign * PaymEntry."Amount Tendered");
                        NodeName[4] := 'Amount In Tender';
                    end;
                    cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, TRUE, FALSE, FALSE));
                    AddPrintLine(700, 4, NodeName, FieldValue, DSTR1, false, true, false, false, 2);
                    TransInfoCode.SetRange("Store No.", Transaction."Store No.");
                    TransInfoCode.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
                    TransInfoCode.SetRange("Transaction No.", Transaction."Transaction No.");
                    TransInfoCode.SetRange("Transaction Type", TransInfoCode."Transaction Type"::"Payment Entry");
                    TransInfoCode.SetRange("Line No.", PaymEntry."Line No.");
                    PrintTransInfoCode(TransInfoCode, 2, false);
                end;
            until PaymEntry.Next = 0;
    end;

    procedure PrintCashDeclLine(Transaction: Record "LSC Transaction Header"; TenderType: Code[10]; CurrCode: Code[10]; DeclType: Integer)
    var
        TransCashDecl: Record "LSC Trans. Cash Declaration";
        TenderType2: Record "LSC Tender Type";
        Currency2: Record Currency;
        DSTR1: Text[100];
        Len: Integer;
        TotalAmount: Decimal;
        IsHandled: Boolean;
    begin

        TransCashDecl.Reset;
        TransCashDecl.SetCurrentKey("Decl. Type");
        case DeclType of
            1:
                TransCashDecl.SetRange("Decl. Type", TransCashDecl."Decl. Type"::"Counted Amount");
            2:
                TransCashDecl.SetRange("Decl. Type", TransCashDecl."Decl. Type"::"Safe Amount");
            3:
                TransCashDecl.SetRange("Decl. Type", TransCashDecl."Decl. Type"::"Bank Amount");
            4:
                TransCashDecl.SetRange("Decl. Type", TransCashDecl."Decl. Type"::"Fixed Float");
        end;
        TransCashDecl.SetRange("Store No.", Transaction."Store No.");
        TransCashDecl.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransCashDecl.SetRange("Transaction No.", Transaction."Transaction No.");
        TransCashDecl.SetRange("Tender Type", TenderType);
        TransCashDecl.SetRange("Currency Code", CurrCode);
        if TransCashDecl.FindSet() then begin
            PrintSeperator(2);
            Clear(FieldValue);
            TenderType2.Get(Transaction."Store No.", TenderType);
            FieldValue[1] := TenderType2.Description;
            if TenderType2."Foreign Currency" then
                if Currency2.Get(CurrCode) then begin
                    Len := StrLen(FieldValue[1]) + 1;
                    if (Len < 40) then
                        FieldValue[1] := FieldValue[1] + ' ' + CopyStr(Currency2.Description, 1, (40 - Len));
                end;

            FieldValue[1] := FieldValue[1] + ' ' + Text162;
            DSTR1 := '#T######################################';

            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, false, false, false));
            PrintLineFeed(2, 1);

            TotalAmount := 0;
            Clear(FieldValue);
            DSTR1 := '#L#### #R######## #R##### #R############';
            repeat
                FieldValue[1] := Format(TransCashDecl.Type);
                FieldValue[2] := POSFunctions.FormatPrice(TransCashDecl.Amount);
                FieldValue[3] := POSFunctions.FormatQty(TransCashDecl."Qty.");
                FieldValue[4] := POSFunctions.FormatAmount(TransCashDecl.Total);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, false, false, false));
                TotalAmount := TotalAmount + TransCashDecl.Total;
            until TransCashDecl.Next = 0;

            PrintLineFeed(2, 1);
            Clear(FieldValue);
            DSTR1 := '#L##################### #R##############';

            FieldValue[1] := TenderType2.Description;
            if (CurrCode <> '') then
                FieldValue[1] := FieldValue[1] + ' ' + CurrCode;
            FieldValue[1] := FieldValue[1] + ' ' + Text005;
            FieldValue[2] := POSFunctions.FormatAmount(TotalAmount);
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, false, false, false));
        end;

    end;

    procedure PrintLineFeed(Tray: Integer; Lines: Integer)
    begin
        if Lines < 1 then
            Lines := 1;

        while Lines > 0 do begin
            Lines -= 1;
            cduSender.PrintLine(Tray, '');
        end;
    end;

    procedure PrintCashDeclaration(Transaction: Record "LSC Transaction Header"): Boolean
    var
        TendDeclEntry2: Record "LSC Trans. Tender Declar. Entr";
        PayEntry2: Record "LSC Trans. Payment Entry";
        TenderType3: Record "LSC Tender Type";
        TenderTypeTable: Record "LSC Tender Type Setup";
        Currency2: Record Currency;
        TransSafeEntry: Record "LSC Trans. Safe Entry";
        DSTR1: Text[100];
        IsHandled: Boolean;
        ReturnValue: Boolean;
        Text158: Label 'Bag No.';
        Text167: Label 'FLOAT TRANSACTION';
    begin

        if (Transaction."Transaction Type" = Transaction."Transaction Type"::"Tender Decl.") then begin
            TendDeclEntry2.Reset;
            TendDeclEntry2.SetRange("Store No.", Transaction."Store No.");
            TendDeclEntry2.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
            TendDeclEntry2.SetRange("Transaction No.", Transaction."Transaction No.");
            if TendDeclEntry2.FindSet() then begin
                repeat
                    PrintCashDeclLine(Transaction, TendDeclEntry2."Tender Type", TendDeclEntry2."Currency Code", 1);
                until TendDeclEntry2.Next = 0;
            end;
        end;

        if (Transaction."Transaction Type" = Transaction."Transaction Type"::"Float Entry") or
           (Transaction."Transaction Type" = Transaction."Transaction Type"::"Remove Tender") then begin
            TenderTypeTable.SetRange("Default Function", TenderTypeTable."Default Function"::"Tender Remove/Float");
            if TenderTypeTable.FindFirst then begin
                PayEntry2.Reset;
                PayEntry2.SetRange("Store No.", Transaction."Store No.");
                PayEntry2.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
                PayEntry2.SetRange("Transaction No.", Transaction."Transaction No.");
                if PayEntry2.FindSet() then begin
                    repeat
                        if (PayEntry2."Tender Type" <> TenderTypeTable.Code) then
                            PrintCashDeclLine(Transaction, PayEntry2."Tender Type", PayEntry2."Currency Code", 1);
                    until PayEntry2.Next = 0;
                end;
            end;
        end;

        //***************************************
        //* Safe Transaction
        //***************************************
        TransSafeEntry.Reset;
        TransSafeEntry.SetCurrentKey("Transaction Type", "Safe Type");
        TransSafeEntry.SetRange("Safe Type", TransSafeEntry."Safe Type"::Safe);
        TransSafeEntry.SetRange("Store No.", Transaction."Store No.");
        TransSafeEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransSafeEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        if TransSafeEntry.FindSet() then begin
            PrintLineFeed(2, 1);
            PrintSeperator(2);
            Clear(FieldValue);
            DSTR1 := '#C##################';
            FieldValue[1] := Text163;
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), true, true, true, false));
            PrintSeperator(2);

            Clear(FieldValue);
            DSTR1 := '#L######### #L########### #R############';
            FieldValue[1] := Text159;
            FieldValue[2] := Text158;
            FieldValue[3] := Text004;
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            PrintSeperator(2);

            repeat
                Clear(FieldValue);
                DSTR1 := '#L######### #L########### #R###############';
                if not TenderType3.Get(TransSafeEntry."Store No.", TransSafeEntry."Tender Type") then
                    Clear(TenderType3);
                if (TransSafeEntry."Currency Code" <> '') then begin
                    Currency2.Get(TransSafeEntry."Currency Code");
                    FieldValue[1] := Currency2.Description;
                end
                else begin
                    FieldValue[1] := TenderType3.Description;
                end;
                FieldValue[2] := TransSafeEntry."Bank Bag No.";
                FieldValue[3] := POSFunctions.FormatPrice(Abs(TransSafeEntry."Amount in Currency"));
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, false, FALSE, FALSE));
            until TransSafeEntry.Next = 0;

            if TransSafeEntry.FindSet() then begin
                repeat
                    PrintCashDeclLine(Transaction, TransSafeEntry."Tender Type", TransSafeEntry."Currency Code", 2);
                until TransSafeEntry.Next = 0;
            end;
        end;

        TransSafeEntry.Reset;
        TransSafeEntry.SetCurrentKey("Transaction Type", "Safe Type");
        TransSafeEntry.SetRange("Safe Type", TransSafeEntry."Safe Type"::Bank);
        TransSafeEntry.SetRange("Store No.", Transaction."Store No.");
        TransSafeEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransSafeEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        if TransSafeEntry.FindSet() then begin
            PrintLineFeed(2, 1);
            PrintSeperator(2);
            Clear(FieldValue);
            DSTR1 := '#C##################';
            FieldValue[1] := Text164;
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), true, true, true, false));
            PrintSeperator(2);

            Clear(FieldValue);
            DSTR1 := '#L######### #L########### #R############';
            FieldValue[1] := Text159;
            FieldValue[2] := Text158;
            FieldValue[3] := Text004;
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            PrintSeperator(2);

            repeat
                if not TenderType3.Get(TransSafeEntry."Store No.", TransSafeEntry."Tender Type") then
                    Clear(TenderType3);

                Clear(FieldValue);
                DSTR1 := '#L######### #L########### #R############';
                if (TransSafeEntry."Currency Code" <> '') then begin
                    Currency2.Get(TransSafeEntry."Currency Code");
                    FieldValue[1] := Currency2.Description;
                end
                else begin
                    FieldValue[1] := TenderType3.Description;
                end;
                FieldValue[2] := TransSafeEntry."Bank Bag No.";
                FieldValue[3] := POSFunctions.FormatPrice(Abs(TransSafeEntry."Amount in Currency"));
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
            until TransSafeEntry.Next = 0;
            if TransSafeEntry.FindSet() then begin
                repeat
                    PrintCashDeclLine(Transaction, TransSafeEntry."Tender Type", TransSafeEntry."Currency Code", 3);
                until TransSafeEntry.Next = 0;
            end;
        end;

        //*****************************************
        //* Float Transaction
        //*****************************************
        TransSafeEntry.Reset;
        TransSafeEntry.SetCurrentKey("Transaction Type", "Safe Type");
        TransSafeEntry.SetRange("Safe Type", TransSafeEntry."Safe Type"::"Fixed Float");
        TransSafeEntry.SetRange("Store No.", Transaction."Store No.");
        TransSafeEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransSafeEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        if TransSafeEntry.FindSet() then begin
            PrintLineFeed(2, 1);
            PrintSeperator(2);
            Clear(FieldValue);
            DSTR1 := '#C##################';
            FieldValue[1] := Text167;
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), true, true, true, false));
            PrintSeperator(2);

            Clear(FieldValue);
            DSTR1 := '#L######### #L########### #R############';
            FieldValue[1] := Text159;
            FieldValue[2] := Text158;
            FieldValue[3] := Text004;
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            PrintSeperator(2);

            repeat
                Clear(FieldValue);
                DSTR1 := '#L######### #L########### #R############';
                if not TenderType3.Get(TransSafeEntry."Store No.", TransSafeEntry."Tender Type") then
                    Clear(TenderType3);
                if (TransSafeEntry."Currency Code" <> '') then begin
                    Currency2.Get(TransSafeEntry."Currency Code");
                    FieldValue[1] := Currency2.Description;
                end
                else begin
                    FieldValue[1] := TenderType3.Description;
                end;
                FieldValue[2] := TransSafeEntry."Bank Bag No.";
                FieldValue[3] := POSFunctions.FormatPrice(Abs(TransSafeEntry."Amount in Currency"));
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
            until TransSafeEntry.Next = 0;

            if TransSafeEntry.FindSet() then begin
                repeat
                    PrintCashDeclLine(Transaction, TransSafeEntry."Tender Type", TransSafeEntry."Currency Code", 4);
                until TransSafeEntry.Next = 0;
            end;
        end;
    end;

    procedure PrintTransType(Transaction: Record "LSC Transaction Header"; Tray: Integer): Boolean
    var
        DSTR1: Text[100];
        IsHandled: Boolean;
        ReturnValue: Boolean;
    begin
        DSTR1 := '#C##################';


        tmpCode := Format(Transaction."Transaction Type");
        FieldValue[1] := tmpCode;
        NodeName[1] := 'Print Info';
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), true, true, true, false));
        cduSender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, true, true, true, false, Tray);
        PrintSeperator(Tray);
        PrintLineFeed(Tray, 1);

    end;

    procedure PrintTransTypeVoid(Transaction: Record "LSC Transaction Header"; Tray: Integer; boltype: Boolean): Boolean
    var
        transactionheader: Record "LSC Transaction Header";
        DSTR1: Text[100];
        IsHandled: Boolean;
        ReturnValue: Boolean;
    begin
        DSTR1 := '#C##################';
        if boltype then
            tmpCode := Format('CANCEL TRANSACTION')
        else
            tmpCode := Format('POST VOID'); //tmpCode := Format('REFUND');
        if (Transaction."Retrieved from Receipt No." = '') and (not boltype) then
            tmpCode := Format('REFUND');

        FieldValue[1] := tmpCode;
        NodeName[1] := 'Print Info';
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), true, true, true, false));
        cduSender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, true, true, true, false, Tray);
        PrintSeperator(Tray);
        // PrintLineFeed(Tray, 1);

        if not boltype then begin
            DSTR1 := '#L####################################';
            transactionheader.Reset();
            transactionheader.SetRange("Refund Receipt No.", Transaction."Receipt No.");
            if transactionheader.FindFirst() then begin
                // MARCUS 20251229
                FieldValue[1] := 'POST Void Series: ' + FORMAT(transactionheader."Post Void No. Series");
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
                FieldValue[1] := 'Voided Trans. No: ' + format(transactionheader."Receipt No.");
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
                FieldValue[1] := 'Voided Invoice No: ' + format(transactionheader."Invoice No.");
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
                PrintSeperator(Tray);
            end else begin
                FieldValue[1] := 'Return Series: ' + FORMAT(Transaction."Return No. Series");
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
                FieldValue[1] := 'Reference Invoice No: ' + format(Transaction."Invoice No.");
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
                FieldValue[1] := 'Reference Slip No: ' + format(Transaction."Receipt No.");
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
                FieldValue[1] := 'Refund Reason: ' + FORMAT(Transaction."Refund Reason");
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
                PrintSeperator(Tray);
            end;
        end;
    end;

    procedure NumTenderDeclSlips(Transaction: Record "LSC Transaction Header"): Integer
    var
        TransSafeEntry: Record "LSC Trans. Safe Entry";
        NumberOfSlips: Integer;
    begin
        NumberOfSlips := 0;

        TransSafeEntry.Reset;
        TransSafeEntry.SetCurrentKey("Transaction Type", "Safe Type");
        TransSafeEntry.SetRange("Safe Type", TransSafeEntry."Safe Type"::Safe);
        TransSafeEntry.SetRange("Store No.", Transaction."Store No.");
        TransSafeEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransSafeEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        if TransSafeEntry.FindFirst() then
            NumberOfSlips += 1;

        TransSafeEntry.Reset;
        TransSafeEntry.SetCurrentKey("Transaction Type", "Safe Type");
        TransSafeEntry.SetRange("Safe Type", TransSafeEntry."Safe Type"::Bank);
        TransSafeEntry.SetRange("Store No.", Transaction."Store No.");
        TransSafeEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransSafeEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        if TransSafeEntry.FindFirst() then
            NumberOfSlips += 1;

        if NumberOfSlips < 2 then
            NumberOfSlips := 2
        else
            NumberOfSlips := 3;

        exit(NumberOfSlips);
    end;

    procedure GetRecommendationForPrinting(TransactionHeader: Record "LSC Transaction Header"; BatchNo: Code[20]; var LSRecommendItemBuffer: Record "LSC Recomm. Item Buffer"; var ErrorText: Text): Boolean
    var
        Item: Record Item;
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        POSTerminal: Record "LSC POS Terminal";
        Store: Record "LSC Store";
        ItemStatusLink: Record "LSC Item Status Link";
        BOUtils: Codeunit "LSC BO Utils";
    begin
        Item.ClearMarks;
        if TransactionHeader."Transaction Type" <> TransactionHeader."Transaction Type"::Sales then
            exit(false);
        TransSalesEntry.SetRange("Store No.", TransactionHeader."Store No.");
        TransSalesEntry.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransSalesEntry.SetRange("Transaction No.", TransactionHeader."Transaction No.");
        TransSalesEntry.SetFilter(Quantity, '<0');
        if TransSalesEntry.FindSet then
            repeat
                if Item.Get(TransSalesEntry."Item No.") then
                    if not BOUtils.IsBlockFromRecommendation(Item."No.", '', TransSalesEntry."Variant Code", TransactionHeader."Store No.", '', Today, ItemStatusLink) then
                        Item.Mark(true);
            until TransSalesEntry.Next = 0;
        Item.MarkedOnly(true);
        exit(true);
    end;

    local procedure PrintRegularCustomer(recLTransactionHeader: Record "LSC Transaction Header")
    var
        recLCustomer: Record Customer;
        DSTR1: Text[50];
        txtLocationOrig: Text[250];
        txtLocation: Text[250];
        txtLocation2: Text[250];
        txtLocation3: Text[250];
        txtLocation4: Text[250];
        txtCustomerName: Text[50];
        txtBusType1: Text[50];
        txtBusType2: Text[50];
        txtBusType3: Text[50];
        txtLBusType: Text[50];
        txtCustomerName2: Text[50];
        txtADDRESS: Label 'ADDRESS:';
        txtBOOKLET: Label 'BOOKLET:';
        txtTINNUMBER: Label 'TIN :';
        txtIDNo: Label 'ID/TIN No. :';
        txtNAME: Label 'NAME :';
        txtSIGNATURE: Label 'SIGNATURE:';
        vLLineLength: Integer;
        txtUNDERSCORE: Label '_';
    begin
        vLLineLength := 45;
        DSTR1 := '#T######################################';

        IF recLtransactionHeader."Customer No." <> '' THEN BEGIN
            recLcustomer.RESET;
            recLcustomer.SETRANGE("No.", recLtransactionHeader."Customer No.");
            IF recLcustomer.FINDFIRST THEN BEGIN
                txtCustomerName := recLcustomer.Name;
                txtLocationOrig := recLcustomer.Address + recLcustomer."Address 2";

                txtLocation := COPYSTR(txtLocationOrig, 1, 35);
                txtLocation2 := COPYSTR(txtLocationOrig, 36, 35);
                txtLocation3 := COPYSTR(txtLocationOrig, 71, 35);
                txtLocation4 := COPYSTR(txtLocationOrig, 106, 35);
                /* txtLocation := COPYSTR(recLcustomer.Address, 1, 25);
                txtLocation2 := COPYSTR(recLcustomer.Address, 26, 32);
                txtLocation3 := COPYSTR(recLcustomer."Address 2", 58, 32);
                txtLocation4 := COPYSTR(recLcustomer."Address 2", 90, 10); */
                txtBusType1 := recLcustomer."Business Style";
                CLEAR(FieldValue);
                DSTR1 := '#L#################################';
                FieldValue[1] := 'SOLD TO:';
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                CLEAR(FieldValue);
                DSTR1 := '#L#################################';
                FieldValue[1] := txtTINNUMBER + FORMAT(recLcustomer.TIN);
                case recLCustomer."Customer Type" of
                    recLCustomer."Customer Type"::"SRC", recLCustomer."Customer Type"::PWD, recLCustomer."Customer Type"::"Solo Parent", recLCustomer."Customer Type"::Athlete, recLCustomer."Customer Type"::"Zero Rated":
                        begin
                            CLEAR(FieldValue);
                            FieldValue[1] := txtIDNo + FORMAT(recLcustomer.TIN);
                        end;
                end;
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                CLEAR(FieldValue);
                DSTR1 := '#L#################################';
                FieldValue[1] := txtNAME + txtCustomerName;
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                CLEAR(FieldValue);
                // DSTR1 := '#L#################################';
                // FieldValue[1] := 'BUS. TYPE: ' + txtBusType1;
                // cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                // CLEAR(FieldValue);
                DSTR1 := '#L#################################';
                FieldValue[1] := txtADDRESS + txtLocation;
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

                IF (txtLocation2 <> '') THEN BEGIN
                    CLEAR(FieldValue);
                    DSTR1 := '#C#################################';
                    FieldValue[1] := ' ' + txtLocation2;
                    cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                END;
                IF (txtLocation3 <> '') THEN BEGIN
                    CLEAR(FieldValue);
                    DSTR1 := '#C#################################';
                    FieldValue[1] := ' ' + txtLocation3;
                    cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                END;
                IF (txtLocation4 <> '') THEN BEGIN
                    CLEAR(FieldValue);
                    DSTR1 := '#C#################################';
                    FieldValue[1] := ' ' + txtLocation4;
                    cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                END;
                if not recLTransactionHeader."Sale Is Return Sale" then
                    if (recLTransactionHeader."Transaction Code Type" = recLTransactionHeader."Transaction Code Type"::"SC") or (recLTransactionHeader."Transaction Code Type" = recLTransactionHeader."Transaction Code Type"::PWD) then begin
                        CLEAR(FieldValue);
                        DSTR1 := '#L#################################';
                        FieldValue[1] := 'Beginning Balance: ' + POSFunctions.FormatAmount(recLTransactionHeader."Beginning Balance");
                        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                        //end;
                        //if recLTransactionHeader."Current Balance" > 0 then begin
                        CLEAR(FieldValue);
                        DSTR1 := '#L#################################';
                        FieldValue[1] := 'Remaining Balance: ' + POSFunctions.FormatAmount(recLTransactionHeader."Current Balance");
                        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                        //end;
                    end;

                CLEAR(FieldValue);
                DSTR1 := '#L#################################';
                FieldValue[1] := txtSIGNATURE + StringPad(txtUNDERSCORE, vLLineLength - STRLEN(txtSIGNATURE));
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

            END;
        END ELSE BEGIN
            CLEAR(FieldValue);
            FieldValue[1] := 'SOLD TO:';
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
            CLEAR(FieldValue);
            DSTR1 := '#L#################################';
            FieldValue[1] := txtTINNUMBER + StringPad(txtUNDERSCORE, vLLineLength - STRLEN(txtTINNUMBER));
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

            CLEAR(FieldValue);
            DSTR1 := '#L#################################';
            FieldValue[1] := txtNAME + StringPad(txtUNDERSCORE, vLLineLength - STRLEN(txtNAME));
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

            CLEAR(FieldValue);
            DSTR1 := '#L#################################';
            FieldValue[1] := txtADDRESS + StringPad(txtUNDERSCORE, vLLineLength - STRLEN(txtADDRESS));
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));

            // CLEAR(FieldValue);
            // DSTR1 := '#L#################################';
            // FieldValue[1] := 'BUS. TYPE :' + StringPad(txtUNDERSCORE, vLLineLength - STRLEN(txtNAME));
            // cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
        END;
        PrintSeperator(2);
    end;

    //Ending *************************************Localize Procedures*************************************


    procedure PrintSeperator(Tray: Integer)
    var
        DSTR1: Text;
        IsHandled: Boolean;
        LineLength: Integer;
    begin
        LineLength := LineLen;

        if LineLength < 40 then
            LineLength := 40;
        DSTR1 := '#C' + StringPad('#', LineLength - 2);
        FieldValue[1] := StringPad('-', LineLength);
        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));

    end;

    local procedure AddPrintLine(pSectionID: Integer; pMaxIndex: Integer; pNodeName: ARRAY[32] OF Text[50]; pValue: ARRAY[10] OF Text[100]; pDesign: Text[100]; pWide: Boolean; pBold: Boolean; pHigh: Boolean; pItalic: Boolean; pTray: Integer)
    var
        Field: Record Field;
        WSFunc: Codeunit "LSC WS Functions";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        Index: Integer;
        FieldNo: Integer;
        LastLineNo: Integer;
        IntValue: Integer;
        DecValue: Decimal;
        DateValue: Date;
        TimeValue: Time;
        ValueText: Text[30];
        FieldIndex: Text[50];
        MappingID: Integer;
    begin
        IF NOT WebPrinting THEN
            EXIT;

        IF CurrentPrintID = 0 THEN
            EXIT;

        PrintBufferExt.SETRANGE("Print ID", CurrentPrintID);
        PrintBufferExt.SETRANGE("Section ID", pSectionID);
        IF PrintBufferExt.FINDLAST THEN
            LastLineNo := PrintBufferExt."Section Line No."
        ELSE
            LastLineNo := 0;

        LastLineNo := LastLineNo + 1;

        PrintBufferExt.INIT;
        PrintBufferExt."Print ID" := CurrentPrintID;
        PrintBufferExt."Section ID" := pSectionID;
        PrintBufferExt."Section Line No." := LastLineNo;
        PrintBufferExt.Layout := pDesign;
        PrintBufferExt.Wide := pWide;
        PrintBufferExt.Bold := pBold;
        PrintBufferExt.High := pHigh;
        PrintBufferExt.Italic := pItalic;
        PrintBufferExt.Tray := pTray;
        RecRef.GETTABLE(PrintBufferExt);
        Index := 1;
        WHILE ((Index <= pMaxIndex) AND (pNodeName[Index] <> '')) DO BEGIN
            IF pNodeName[Index] <> 'x' THEN BEGIN
                FieldNo := WSFunc.FindFieldNoByFieldName(RecRef.NUMBER, pNodeName[Index]);
                FieldRef := RecRef.FIELD(FieldNo);
                Field.GET(RecRef.NUMBER, FieldNo);
                FieldIndex := FieldIndex + FORMAT(FieldNo) + ';';
                CASE Field.Type OF
                    Field.Type::Integer:
                        BEGIN
                            IF pValue[Index] = '' THEN
                                ValueText := '0'
                            ELSE
                                ValueText := pValue[Index];
                            EVALUATE(IntValue, ValueText);
                            FieldRef.VALUE := IntValue;
                        END;
                    Field.Type::Decimal:
                        BEGIN
                            IF pValue[Index] = '' THEN
                                ValueText := '0'
                            ELSE
                                ValueText := pValue[Index];
                            EVALUATE(DecValue, ValueText);
                            FieldRef.VALUE := DecValue;
                        END;
                    Field.Type::Date:
                        BEGIN
                            IF pValue[Index] = '' THEN
                                ValueText := '0D'
                            ELSE
                                ValueText := pValue[Index];
                            EVALUATE(DateValue, ValueText);
                            FieldRef.VALUE := DateValue;
                        END;
                    Field.Type::Time:
                        BEGIN
                            IF pValue[Index] = '' THEN
                                ValueText := '0T'
                            ELSE
                                ValueText := pValue[Index];
                            EVALUATE(TimeValue, ValueText);
                            FieldRef.VALUE := TimeValue;
                        END;
                    ELSE
                        FieldRef.VALUE := pValue[Index];
                END;
                IF MappingID = 0 THEN
                    MappingID := FieldNo;
            END;
            Index := Index + 1;
        END;
        RecRef.SETTABLE(PrintBufferExt);
        PrintBufferExt."Mapping ID" := MappingID;
        PrintBufferExt."Field Index" := FieldIndex;
        PrintBufferExt.INSERT;
    end;

    local procedure FormatLine(Txt: Text; Wide: Boolean; Bold: Boolean; High: Boolean; Italic: Boolean): Text
    begin
        IF Wide AND High THEN
            ActiveFontType := ActiveFontType::WideAndHight
        ELSE
            IF Wide THEN
                ActiveFontType := ActiveFontType::Wide
            ELSE
                IF High THEN
                    ActiveFontType := ActiveFontType::High
                ELSE
                    IF Bold THEN
                        ActiveFontType := ActiveFontType::Bold
                    ELSE
                        ActiveFontType := ActiveFontType::Normal;

        EXIT(Txt);
    end;

    local procedure StringPad(Char: Text[1]; Length: Integer): Text[250]
    var
        ReturnString: Text[250];
        i: Integer;
    begin
        //StringPad
        ReturnString := '';
        FOR i := 1 TO Length DO
            ReturnString := ReturnString + Char;
        EXIT(ReturnString);
    end;

    procedure PrintSubHeader(var Transaction: Record "LSC Transaction Header"; Tray: Integer; PrDate: Date; PrTime: Time)
    var
        Staff: Record "LSC Staff";
        DSTR1: Text[100];
        StaffName: Text;
        blankStr: Text;
        IsHandled: Boolean;
        SalesReceiptText: Label 'Sales Receipt';
    begin

        if Tray = 2 then
            blankStr := StringPad(' ', LineLen - 38)
        else
            if Tray = 4 then
                blankStr := StringPad(' ', InvLineLen - 38);

        if blankStr = '' then
            blankStr := ' ';

        //VINCENT20250512
        Clear(Value);
        // DSTR1 := '#L#### #L############### #L##########';
        // Value[1] := 'Date:';
        // Value[2] := format(Transaction."Original Date");
        // Value[3] := format(Transaction."Time", 12, '<Hours12,2>:<Minutes,2>:<Seconds,2> <AM/PM>');
        DSTR1 := '#L#### #T################### #T### #T####### ';
        Value[1] := 'Date:';
        Value[2] := format(Transaction."Original Date") + ' ' + format(Transaction."Time", 12, '<Hours12,2>:<Minutes,2>:<Seconds,2> <AM/PM>');
        Value[3] := 'POS:';
        Value[4] := FORMAT(Transaction."POS Terminal No.");
        NodeName[3] := 'Trans. Time';
        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, true, false, false));
        cduSender.AddPrintLine(200, 2, NodeName, Value, DSTR1, false, true, false, false, Tray);
        //END
        //Get Staff
        Clear(Value);
        // DSTR1 := '#L###### #L############  #L#### #L######';
        DSTR1 := '#L###### #L############ #L###### #L#####  ';

        StaffName := Transaction."Staff ID";
        if Staff.Get(Transaction."Staff ID") then
            StaffName := Staff."Name on Receipt";

        //Staff
        // Value[1] := Text051 + ':';
        // NodeName[1] := 'x';
        // Value[2] := StaffName;
        Value[1] := Text051 + ':';
        Value[2] := StaffName;
        Value[3] := 'Store #:';
        Value[4] := FORMAT(Transaction."Store No.");
        NodeName[2] := 'x';
        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, true, false, false));
        cduSender.AddPrintLine(200, 5, NodeName, Value, DSTR1, false, true, false, false, Tray);

        //Receipt No
        Clear(Value);
        DSTR1 := '#L########## #L################## #L###';
        Value[1] := 'Receipt No#:';
        Value[2] := Format(Transaction."Receipt No.");
        Value[3] := Format(Transaction."Transaction Code Type");

        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, true, false, false));
        cduSender.AddPrintLine(200, 5, NodeName, Value, DSTR1, false, true, false, false, Tray);

        //Sales Invoice No.
        PrintSeperator(Tray);
        Clear(Value);
        IF NOT Transaction."Sale Is Return Sale" THEN BEGIN
            DSTR1 := '#L############### #L#### #L#############';
            Value[1] := 'SALES INVOICE No.:';
            Value[3] := Transaction."Invoice No.";
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, true, false, false));
            cduSender.AddPrintLine(200, 5, NodeName, Value, DSTR1, false, true, false, false, Tray);
            PrintSeperator(Tray);
        END;

        /* //Transction No. and Transaction Code Type
        DSTR1 := '#L#### #L################## #L### #L###';
        Value[1] := 'TR ' + ':';
        NodeName[1] := 'x';
        Value[2] := Transaction."Receipt No.";
        NodeName[2] := 'Receipt No.';
        Value[3] := 'Type:';
        Value[4] := COPYSTR(FORMAT(Transaction."Transaction Code Type"), 1, 4);
        if Transaction."Transaction Code Type" = Transaction."Transaction Code Type"::"Regular Customer" then
            Value[4] := 'REG';
        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, true, false, false));
        cduSender.AddPrintLine(200, 2, NodeName, Value, DSTR1, false, true, false, false, Tray);

        //Invoice No.
        DSTR1 := '#L############# #L##################';
        Value[1] := 'Sales Invoice #:';
        Value[2] := Transaction."Invoice No.";
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        cduSender.AddPrintLine(200, 2, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);

        //DSTR1 := '#L#### #L###### #L#######  #L#### #L######';
        DSTR1 := '#L### #L###### #L######  #L#### #L######';
        Value[1] := Text048 + ':';
        NodeName[1] := 'x';
        Value[2] := Format(PrDate);
        NodeName[2] := 'Trans. Date';
        Value[3] := Format(PrTime, 8, '<Hours24,2>:<Minutes,2>:<Seconds,2>');//Format(PrTime, 5);
        NodeName[3] := 'Trans. Time';
        Value[4] := 'POS:';
        NodeName[4] := 'x';
        Value[5] := Format(Transaction."POS Terminal No.");
        NodeName[5] := 'Terminal';
        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, true, false, false));
        cduSender.AddPrintLine(200, 3, NodeName, Value, DSTR1, false, true, false, false, Tray);
        PrintSeperator(Tray); */
    end;


    procedure PrintCardSlipFromEFTEmbedded(Typ: Text[5]; var Transaction: Record "LSC Transaction Header"): Boolean
    var
        EFTPrintLine: Record "LSC POS Card Print Text";
        DSTR1: Text[100];
        new: Boolean;
        IsHandled: Boolean;
        ReturnValue: Boolean;
        lTerminal: Record "LSC POS Terminal";
    begin
        if TerminalNo = '' then
            lTerminal.Get(Globals.TerminalNo)
        else
            lTerminal.Get(TerminalNo);

        EFTPrintLine.SetRange("Store No.", lTerminal."Store No.");
        EFTPrintLine.SetRange("POS Terminal No.", lTerminal."No.");
        EFTPrintLine.SetRange("File No.", 0);
        EFTPrintLine.SetFilter(Destination, '%1', Typ);
        EFTPrintLine.SetRange("Receipt No.", Transaction."Receipt No.");
        if not EFTPrintLine.FindFirst then
            exit(true);

        new := true;
        repeat
            if new then begin
                cduSender.PrintLine(2, '');
                new := false;
            end;
            if EFTPrintLine.Description = '<cut>' then begin
                new := true;
            end
            else begin
                Clear(FieldValue);
                DSTR1 := '#T########################################';
                FieldValue[1] := EFTPrintLine.Description;
                NodeName[1] := 'CardText';
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), EFTPrintLine.FontSize > 1, EFTPrintLine.FontWeight > 0, EFTPrintLine.FontSize > 1, false));
                cduSender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, EFTPrintLine.FontSize > 1, EFTPrintLine.FontWeight > 0, EFTPrintLine.FontSize > 1, false, 2);
            end;
        until EFTPrintLine.Next = 0;
        PrintSeperator(2);
        exit(true);
    end;


    procedure PrintTransInfoCode(var TransInfoEntry: Record "LSC Trans. Infocode Entry"; Tray: Integer; PrintSep: Boolean)
    var
        IsHandled: Boolean;
    begin

        if TransInfoEntry.FindSet() then
            repeat
                PrintInfoCodeLine(Tray, false, TransInfoEntry.Infocode, TransInfoEntry.Subcode, TransInfoEntry.Information, TransInfoEntry."Line No.");
            until TransInfoEntry.Next = 0;
        if PrintSep then
            cduSender.PrintLine(Tray, '');
    end;


    procedure PrintInfoCodeLine(Tray: Integer; PrintSep: Boolean; ICode: Code[20]; ISubCode: Code[20]; Information: Text[100]; LineNo: Integer)
    var
        InfoCode: Record "LSC Infocode";
        InfoSub: Record "LSC Information Subcode";
        DSTR: Text[100];
        InfoText: Text[250];
        IsHandled: Boolean;
    begin
        DSTR := '  #T####################################';
        if InfoCode.Get(ICode) then begin
            InfoText := '';
            if InfoCode."Print Prompt on Receipt" then
                InfoText := InfoText + InfoCode.Prompt + ' ';
            if InfoCode."Print Input on Receipt" then
                InfoText := InfoText + Information + ' ';
            if InfoCode."Print Inp. Name on Rcpt." then
                if InfoSub.Get(InfoCode.Code, ISubCode) then
                    InfoText := InfoText + InfoSub.Description + ' ';
            if InfoText <> '' then begin
                while InfoText <> '' do begin
                    FieldValue[1] := CopyStr(InfoText, 1, LineLen - 2);
                    if StrLen(InfoText) > (LineLen - 2) then
                        InfoText := CopyStr(InfoText, LineLen - 1, StrLen(InfoText) - (LineLen - 2))
                    else
                        InfoText := '';
                    NodeName[1] := 'Extra Info Line';
                    FieldValue[2] := Format(LineNo);
                    NodeName[2] := 'Line No.';
                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR), false, false, false, false));
                    AddPrintLine(350, 2, NodeName, FieldValue, DSTR, false, false, false, false, Tray);
                end;
                if PrintSep then
                    cduSender.PrintLine(Tray, '');
            end;
        end;
    end;


    procedure PrintTrainingText(Tray: Integer): Boolean
    var
        DSTR1: Text[100];
        Payment: Text[30];
    begin

        DSTR1 := '#C##################';
        FieldValue[1] := Text047;
        NodeName[1] := 'Print Info';
        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), true, false, true, false));
        cduSender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, true, false, true, false, Tray);
        PrintSeperator(Tray);

    end;


    procedure PrintTotal(Transaction: Record "LSC Transaction Header"; Tray: Integer; RightIndent: Integer; PrintTax: Boolean): Boolean
    var
        CurrencyExchRate: Record "Currency Exchange Rate";
        lPOSTransPeriodicDisc: Record "LSC POS Trans. Per. Disc. Type";
        DSTR1: Text[100];
        TotalDiscountCode: Code[20];
        SecTotal: Decimal;
        Total: Decimal;
        TotalAmtForSummary: Decimal;
        SecSubTotal: Decimal;
        TotalDiscAmt: Decimal;
        IsHandled: Boolean;
        ReturnValue: Boolean;
        gltesttotal: Label 'gl total';
    begin

        if (Transaction."Transaction Code Type" = Transaction."Transaction Code Type"::MOV) or
        (Transaction."Transaction Code Type" = Transaction."Transaction Code Type"::NAAC) then begin
            //PrintSeperator(Tray);
            DSTR1 := '#L################# #R###############   ';
            FieldValue[1] := ' Less VAT 12%';
            FieldValue[2] := ' ' + POSFunctions.FormatAmount(Transaction."Zero Rated Amount");
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
            cduSender.AddPrintLine(600, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

            DSTR1 := '#L################# #R###############   ';
            FieldValue[1] := ' Amt. Net VAT';
            FieldValue[2] := ' ' + POSFunctions.FormatAmount(Transaction."Zero Rated Amount");
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
            cduSender.AddPrintLine(600, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

            Case Transaction."Transaction Code Type" of
                Transaction."Transaction Code Type"::NAAC, Transaction."Transaction Code Type"::MOV:
                    begin
                        if (GenPosFunc."Print Disc/Cpn Info on Slip" = GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total") and
                                (Transaction."Discount Amount" <> TotalDiscAmt) then begin
                            lPOSTransPeriodicDisc.DiscType := lPOSTransPeriodicDisc.DiscType::Total;
                            TotalDiscountCode := Format(lPOSTransPeriodicDisc.DiscType);
                            if PeriodicDiscountInfoTEMP.FindSet then
                                repeat
                                    if PeriodicDiscountInfoTEMP."No." <> TotalDiscountCode then begin
                                        DSTR1 := '#L################# #R###############   ';
                                        if (Transaction."Transaction Code Type" = Transaction."Transaction Code Type"::MOV) then
                                            FieldValue[1] := ' MOV Disc. 20%';
                                        If (Transaction."Transaction Code Type" = Transaction."Transaction Code Type"::NAAC) then
                                            FieldValue[1] := ' NAAC Disc. 20%';
                                        FieldValue[2] := POSFunctions.FormatAmount(PeriodicDiscountInfoTEMP."Discount Amount Value");
                                        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                                        cduSender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                                    end;
                                until PeriodicDiscountInfoTEMP.Next = 0;
                        end;
                    end;
            end;
        end;
        Clear(FieldValue);
        Clear(Currency);

        Total := -Transaction."Gross Amount" - Transaction."Income/Exp. Amount" + totSPOAmount;
        TotalDiscAmt := 0;

        if GenPosFunc."Display Secondary Total Curr" and (GenPosFunc."Secondary Total Currency" <> '') then begin
            if not Currency.Get(GenPosFunc."Secondary Total Currency") then
                Clear(Currency);
            SecTotal := Round(CurrencyExchRate.ExchangeAmtFCYToFCY(Transaction.Date, Transaction."Trans. Currency", Currency.Code,
                              Total), Currency."Amount Rounding Precision");
        end;
        if (GenPosFunc."Print Disc/Cpn Info on Slip" =
            GenPosFunc."Print Disc/Cpn Info on Slip"::"Summary information below Sub-total") or
           (GenPosFunc."Print Disc/Cpn Info on Slip" =
            GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total") or
           (GenPosFunc."Print Disc/Cpn Info on Slip" =
            GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line")
        then begin
            PeriodicDiscountInfoTEMP.Reset;
            PeriodicDiscountInfoTEMP.SetCurrentKey(Status, Type);
            NodeName[1] := 'Total Text';
            NodeName[2] := 'Total Amount';

            if PeriodicDiscountInfoTEMP.FindSet then begin
                DSTR1 := '#L################# #R###############   ';
                FieldValue[1] := Text042 + '1 ' + Globals.GetValue('CURRSYM');
                FieldValue[2] := POSFunctions.FormatAmount(-Subtotal + TipsAmount1 + TipsAmount2);
                cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                TotalAmtForSummary := Subtotal;
                repeat
                    if (GenPosFunc."Print Disc/Cpn Info on Slip" =
                      GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total") and
                      (PeriodicDiscountInfoTEMP.Description <> Text024) then
                        PeriodicDiscountInfoTEMP."Discount Amount Value" := 0;
                    if PeriodicDiscountInfoTEMP."Discount Amount Value" <> 0 then begin
                        FieldValue[1] := PeriodicDiscountInfoTEMP.Description;
                        Value[1] := '';
                        DSTR1 := '#L################# #R###############   ';
                        Case Transaction."Transaction Code Type" of
                            Transaction."Transaction Code Type"::"SC":
                                FieldValue[1] := 'Senior Discount';
                            Transaction."Transaction Code Type"::PWD:
                                FieldValue[1] := 'PWD Discount';
                            Transaction."Transaction Code Type"::SOLO:
                                FieldValue[1] := 'SOLO Discount';
                            Transaction."Transaction Code Type"::ATHL:
                                FieldValue[1] := 'Athlete Discount';
                        // Transaction."Transaction Code Type"::MOV:
                        //     FieldValue[1] := 'MOV Discount';
                        // Transaction."Transaction Code Type"::NAAC:  FieldValue[1] := ' Less VAT 12%';
                        //     FieldValue[1] := 'NAAC Discount';
                        End;

                        FieldValue[2] := POSFunctions.FormatAmount(-PeriodicDiscountInfoTEMP."Discount Amount Value");
                        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                        AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                        TotalAmtForSummary := TotalAmtForSummary + PeriodicDiscountInfoTEMP."Discount Amount Value";
                        TotalDiscAmt := TotalDiscAmt + PeriodicDiscountInfoTEMP."Discount Amount Value";
                    end;
                    if PeriodicDiscountInfoTEMP."Discount % Value" <> 0 then begin   //Points
                        DSTR1 := '#L################# #R###############   ';
                        FieldValue[1] := PeriodicDiscountInfoTEMP.Description;
                        FieldValue[2] := POSFunctions.FormatAmount(PeriodicDiscountInfoTEMP."Discount % Value") + ' ' + Text232;
                        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                        cduSender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                    end;
                until PeriodicDiscountInfoTEMP.Next = 0;

                if PrintTax and LocalizationExt.IsNALocalizationEnabled then
                    PrintTransTaxInfo(Transaction, Tray, RightIndent);

                DSTR1 := '#L################# #R###############   ';
                FieldValue[1] := Text005 + ' ' + Globals.GetValue('CURRSYM');

                if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                    FieldValue[2] := POSFunctions.FormatAmount(Total + TipsAmount1 + TipsAmount2)
                else
                    FieldValue[2] := POSFunctions.FormatAmount(-TotalAmtForSummary + TipsAmount1 + TipsAmount2 + totSPOAmount);

                if GenPosFunc."Display Secondary Total Curr" and (GenPosFunc."Secondary Total Currency" <> '') and (SecTotal <> 0) then begin
                    DSTR1 := '#L####### #R######### #R#############   ';
                    FieldValue[1] := Text005 + ' ' + Globals.GetValue('CURRSYM');
                    FieldValue[2] := Currency.Code + Format(SecTotal, 0, ApplMan.DoAutoFormatTranslateExt(1, Currency.Code));

                    if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                        FieldValue[3] := POSFunctions.FormatAmount(Total + TipsAmount1 + TipsAmount2)
                    else
                        FieldValue[3] := POSFunctions.FormatAmount(-TotalAmtForSummary + TipsAmount1 + TipsAmount2 + totSPOAmount);
                    NodeName[2] := 'Sec.Curr';
                    NodeName[3] := 'Total Amount';
                end;
                cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                if TipsAmount1 <> 0 then begin
                    DSTR1 := '#L################# #R###############   ';
                    FieldValue[1] := TipsText1 + ' ' + Globals.GetValue('CURRSYM');
                    FieldValue[2] := POSFunctions.FormatAmount(-TipsAmount1);
                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                    AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                end;
                if TipsAmount2 <> 0 then begin
                    DSTR1 := '#L################# #R###############   ';
                    FieldValue[1] := TipsText2 + ' ' + Globals.GetValue('CURRSYM');
                    FieldValue[2] := POSFunctions.FormatAmount(-TipsAmount2);
                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                    AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                end;
                Case Transaction."Transaction Code Type" of
                    Transaction."Transaction Code Type"::"Regular Customer", Transaction."Transaction Code Type"::REG,
                         Transaction."Transaction Code Type"::VATW, Transaction."Transaction Code Type"::WHT1, Transaction."Transaction Code Type"::ZRWH,
                         Transaction."Transaction Code Type"::ZERO:
                        begin
                            if (GenPosFunc."Print Disc/Cpn Info on Slip" = GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total") and
                                    (Transaction."Discount Amount" <> TotalDiscAmt) then begin
                                lPOSTransPeriodicDisc.DiscType := lPOSTransPeriodicDisc.DiscType::Total;
                                TotalDiscountCode := Format(lPOSTransPeriodicDisc.DiscType);
                                if PeriodicDiscountInfoTEMP.FindSet then
                                    repeat
                                        if PeriodicDiscountInfoTEMP."No." <> TotalDiscountCode then begin
                                            DSTR1 := '#L###################################   ';
                                            FieldValue[1] := ' ' + CopyStr(PeriodicDiscountInfoTEMP.Description, 1, 18) + ' ' +
                                              POSFunctions.FormatAmount(PeriodicDiscountInfoTEMP."Discount Amount Value");
                                            FieldValue[2] := '';
                                            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                                            cduSender.AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                                        end;
                                    until PeriodicDiscountInfoTEMP.Next = 0;
                            end;
                        end;
                end;
            end
            else begin
                if LocalizationExt.IsNALocalizationEnabled then begin
                    if Globals.UseSalesTax then begin
                        DSTR1 := '#L################# #R###############   ';
                        FieldValue[1] := Text042 + ' ' + Globals.GetValue('CURRSYM');
                        FieldValue[2] := POSFunctions.FormatAmount(-Subtotal + TipsAmount1 + TipsAmount2 + totSPOAmount);
                        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                    end;

                    if PrintTax then
                        PrintTransTaxInfo(Transaction, Tray, RightIndent);
                end;
                DSTR1 := '#L################# #R###############   ';
                FieldValue[1] := Text005 + ' ' + Globals.GetValue('CURRSYM');
                if GenPosFunc."Print Disc/Cpn Info on Slip" in
                    [GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
                    GenPosFunc."Print Disc/Cpn Info on Slip"::"Summary information below Sub-total"] then begin
                    if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                        FieldValue[2] := POSFunctions.FormatAmount(Total + TipsAmount1 + TipsAmount2)
                    else
                        FieldValue[2] := POSFunctions.FormatAmount(-Subtotal + TipsAmount1 + TipsAmount2 + totSPOAmount);
                    if GenPosFunc."Display Secondary Total Curr" and (GenPosFunc."Secondary Total Currency" <> '') and (SecTotal <> 0) then begin
                        SecSubTotal := Round(CurrencyExchRate.ExchangeAmtFCYToFCY(Transaction.Date, Transaction."Trans. Currency", Currency.Code,
                                       Total), Currency."Amount Rounding Precision");
                        DSTR1 := '#L####### #R######### #R#############   ';
                        FieldValue[1] := Text005 + ' ' + Globals.GetValue('CURRSYM');
                        FieldValue[2] := Currency.Code + Format(SecSubTotal, 0, ApplMan.DoAutoFormatTranslateExt(1, Currency.Code));
                        FieldValue[3] := POSFunctions.FormatAmount(-Subtotal + TipsAmount1 + TipsAmount2 + totSPOAmount);
                        NodeName[2] := 'Sec.Curr';
                        NodeName[3] := 'Total Amount';
                    end;
                end
                else begin
                    if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                        FieldValue[2] := POSFunctions.FormatAmount(Total + TipsAmount1 + TipsAmount2)
                    else
                        FieldValue[2] := POSFunctions.FormatAmount(Total + TipsAmount1 + TipsAmount2 + totSPOAmount);
                    if GenPosFunc."Display Secondary Total Curr" and (GenPosFunc."Secondary Total Currency" <> '') and (SecTotal <> 0) then begin
                        DSTR1 := '#L####### #R######### #R#############   ';
                        FieldValue[1] := Text005 + ' ' + Globals.GetValue('CURRSYM');
                        FieldValue[2] := Currency.Code + Format(SecTotal, 0, ApplMan.DoAutoFormatTranslateExt(1, Currency.Code));
                        FieldValue[3] := POSFunctions.FormatAmount(-TotalAmt + TipsAmount1 + TipsAmount2 + totSPOAmount);
                        NodeName[2] := 'Sec.Curr';
                        NodeName[3] := 'Total Amount';
                    end;
                end;
                cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, GenPosFunc."Print Total Line Bold", false, false));
                AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                if TipsAmount1 <> 0 then begin
                    DSTR1 := '#L################# #R###############   ';
                    FieldValue[1] := TipsText1 + ' ' + Globals.GetValue('CURRSYM');
                    FieldValue[2] := POSFunctions.FormatAmount(-TipsAmount1);
                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                    AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                end;
                if TipsAmount2 <> 0 then begin
                    DSTR1 := '#L################# #R###############   ';
                    FieldValue[1] := TipsText2 + ' ' + Globals.GetValue('CURRSYM');
                    FieldValue[2] := POSFunctions.FormatAmount(-TipsAmount2);
                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                    AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                end;
            end;
        end
        else begin
            if LocalizationExt.IsNALocalizationEnabled then begin
                if Globals.UseSalesTax then begin
                    DSTR1 := '#L################# #R###############   ';
                    FieldValue[1] := Text042 + ' ' + Globals.GetValue('CURRSYM');
                    FieldValue[2] := POSFunctions.FormatAmount(-Subtotal + TipsAmount1 + TipsAmount2 + totSPOAmount);
                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                end;

                if PrintTax then
                    PrintTransTaxInfo(Transaction, Tray, RightIndent);
            end;
            NodeName[1] := 'Total Text';
            NodeName[2] := 'Total Amount';
            DSTR1 := '#L################# #R###############   ';
            FieldValue[1] := Text005 + ' ' + Globals.GetValue('CURRSYM');
            if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                FieldValue[2] := POSFunctions.FormatAmount(Total + TipsAmount1 + TipsAmount2)
            else
                FieldValue[2] := POSFunctions.FormatAmount(Total + TipsAmount1 + TipsAmount2 + totSPOAmount);
            if GenPosFunc."Display Secondary Total Curr" and (GenPosFunc."Secondary Total Currency" <> '') and (SecTotal <> 0) then begin
                DSTR1 := '#L####### #R######### #R#############   ';
                FieldValue[1] := Text005 + ' ' + Globals.GetValue('CURRSYM');
                FieldValue[2] := Currency.Code + Format(SecTotal, 0, ApplMan.DoAutoFormatTranslateExt(1, Currency.Code));
                if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                    FieldValue[3] := POSFunctions.FormatAmount(Total + TipsAmount1 + TipsAmount2)
                else
                    FieldValue[3] := POSFunctions.FormatAmount(-TotalAmt + TipsAmount1 + TipsAmount2 + totSPOAmount);
                NodeName[2] := 'Sec.Curr';
                NodeName[3] := 'Total Amount';
            end;
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, GenPosFunc."Print Total Line Bold", false, false));
            AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            if TipsAmount1 <> 0 then begin
                DSTR1 := '#L################# #R###############   ';
                FieldValue[1] := TipsText1 + ' ' + Globals.GetValue('CURRSYM');
                FieldValue[2] := POSFunctions.FormatAmount(-TipsAmount1);
                cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            end;
            if TipsAmount2 <> 0 then begin
                DSTR1 := '#L################# #R###############   ';
                FieldValue[1] := TipsText2 + ' ' + Globals.GetValue('CURRSYM');
                FieldValue[2] := POSFunctions.FormatAmount(-TipsAmount2);
                cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            end;
        end;
    end;


    procedure PrintTransTaxInfo(Transaction: Record "LSC Transaction Header"; Tray: Integer; RightIndent: Integer)
    var
        TransSalesTaxEntry: Record "LSC Trans. SalesTax Entry";
        DSTR1: Text[100];
        i: Integer;
    begin
        TransSalesTaxEntry.Reset;
        TransSalesTaxEntry.SetRange("Store No.", Transaction."Store No.");
        TransSalesTaxEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        TransSalesTaxEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        if not TransSalesTaxEntry.IsEmpty then begin
            BrkIdx := 0;
            PrevPrintOrder := 0;
            PrevTaxPercent := 0;

            if BrkIdx > 1 then
                for i := 1 to BrkIdx do begin
                    DSTR1 := '#L###################### #R#############';
                    DSTR1 := CopyStr(DSTR1, 1, StrLen(DSTR1) - RightIndent);
                    FieldValue[1] := BreakdownLabel[i];
                    FieldValue[2] := POSFunctions.FormatAmount(BreakdownAmt[i]);
                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
                end;
        end;

        if (TransSalesTaxEntry.IsEmpty) or (BrkIdx = 1) then begin
            DSTR1 := '#L###################### #R#############';
            DSTR1 := CopyStr(DSTR1, 1, StrLen(DSTR1) - RightIndent);
            FieldValue[1] := Text10001;
            FieldValue[2] := POSFunctions.FormatAmount(BreakdownAmt[1]);
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
        end;

    end;



    procedure PrintPaymInfo(Transaction: Record "LSC Transaction Header"; Tray: Integer)
    var
        PaymEntry: Record "LSC Trans. Payment Entry";
        Tendertype: Record "LSC Tender Type";
        Tendercard: Record "LSC Tender Type Card Setup";
        Currency: Record Currency;
        TransInfoCode: Record "LSC Trans. Infocode Entry";
        CouponEntry: Record "LSC Trans. Coupon Entry";
        DSTR1: Text[100];
        DSTR2: Text[100];
        Payment: Text[30];
        tmpStr: Text[50];
        RemainingAmount: Text;
        i: Integer;
        IsHandled: Boolean;
        RemAmountText: Label 'Remaining Amount ';
    begin
        Clear(PaymEntry);
        PaymEntry.SetRange("Store No.", Transaction."Store No.");
        PaymEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        PaymEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        if PaymEntry.FindFirst() then begin
            repeat

                //DSTR1 := '#L################## #R## #R#########';
                DSTR1 := '#L################ #R## #R###########   ';
                DSTR1 := '#L############# #R## #R##############   ';
                Clear(FieldValue);
                Payment := PaymEntry."Tender Type";
                if Tendertype.Get(PaymEntry."Store No.", PaymEntry."Tender Type") then begin
                    if PaymEntry."Change Line" and (Tendertype."Change Line on Receipt" <> '') then
                        Payment := Tendertype."Change Line on Receipt"
                    else
                        Payment := Tendertype.Description;
                end
                else
                    Clear(Tendertype);


                if not Tendertype."Auto Account Payment Tender" then begin
                    FieldValue[1] := Payment;
                    if Tendertype.Function = Tendertype.Function::Card then begin
                        APPOSSESSIONS.Reset();
                        if APPOSSESSIONS.FindFirst() then begin
                            TenderTypeCardSetup.Reset();
                            TenderTypeCardSetup.SetRange("Card No.", PaymEntry."Card Type");
                            if TenderTypeCardSetup."E-Wallet" then
                                FieldValue[1] := 'E-Wallet ' + TenderTypeCardSetup."Card No." + '-' + TenderTypeCardSetup.Description
                            else
                                FieldValue[1] := Payment + ' ' + TenderTypeCardSetup."Card No." + '-' + TenderTypeCardSetup.Description;
                        end;
                    end;
                end;

                NodeName[1] := 'Tender Description';
                if (Tendertype."Function" = Tendertype."Function"::Coupons) and (PaymEntry.Quantity > 1) then
                    FieldValue[2] := Format(PaymEntry.Quantity);
                NodeName[2] := 'Quantity';
                FieldValue[3] := POSFunctions.FormatAmount(Abs(-PaymEntry."Amount Tendered"));
                NodeName[3] := 'Amount In Tender';
                FieldValue[4] := PaymEntry."Tender Type";
                NodeName[4] := 'Tender Type';
                FieldValue[5] := Format(PaymEntry."Line No.");
                NodeName[5] := 'Line No.';
                cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
                AddPrintLine(700, 5, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
                if (Tendertype."Function" = Tendertype."Function"::Card) then begin
                    DSTR2 := '  #L##################################';
                    // APPOSSESSIONS.Reset();
                    // if APPOSSESSIONS.FindFirst() then begin
                    //     TenderTypeCardSetup.Reset();
                    //     TenderTypeCardSetup.SetRange("Card No.", APPOSSESSIONS."Card type Param");
                    //     if TenderTypeCardSetup.FindFirst() then begin
                    //         FieldValue[1] := TenderTypeCardSetup."Tender Type Code" + ' ' + TenderTypeCardSetup.Description;
                    //     end;
                    // end;
                    // FieldValue[2] := Format(PaymEntry."Line No.");
                    // cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR2), false, true, false, false));
                    // AddPrintLine(700, 2, NodeName, FieldValue, DSTR2, false, true, false, false, Tray);
                    //PaymEntry."Card or Account" := '1234567876543';
                    if PaymEntry."Card or Account" <> '' then begin
                        tmpStr := PaymEntry."Card or Account";
                        // for i := 1 to StrLen(tmpStr) - 4 do
                        //     tmpStr[i] := '*';
                        // if tmpStr <> '' then begin
                        //     FieldValue[1] := 'Card # ' +
                        //              //   CopyStr(tmpStr, 1, 4) + ' ' +
                        //              //   CopyStr(tmpStr, 5, 4) + ' ' +
                        //              //   CopyStr(tmpStr, 9, 4) + ' ' +
                        //              CopyStr(tmpStr, 13, 4);
                        //     NodeName[1] := 'Detail Text';
                        //     FieldValue[2] := Format(PaymEntry."Line No.");
                        //     NodeName[2] := 'Line No.';
                        //     cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR2), false, true, false, false));
                        //     AddPrintLine(700, 2, NodeName, FieldValue, DSTR2, false, true, false, false, Tray);
                        // end;

                        // if PaymEntry."Card Approval Code" <> '' then begin
                        //     FieldValue[1] := 'Approval Code: ' + PaymEntry."Card Approval Code";
                        //     FieldValue[2] := Format(PaymEntry."Line No.");
                        //     cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR2), false, true, false, false));
                        //     AddPrintLine(700, 2, NodeName, FieldValue, DSTR2, false, true, false, false, Tray);
                        // end;
                    end;
                end
                else
                    if Tendertype."Card/Account No." then begin
                        DSTR2 := '  #L##################################  ';
                        FieldValue[1] := Tendertype."Ask for Card/Account" + ' ' + PaymEntry."Card or Account";
                        NodeName[1] := 'Detail Text';
                        FieldValue[2] := Format(PaymEntry."Line No.");
                        NodeName[2] := 'Line No.';
                        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR2), false, true, false, false));
                        AddPrintLine(700, 2, NodeName, FieldValue, DSTR2, false, true, false, false, Tray);
                    end;
                if Tendertype."Foreign Currency" then begin
                    if PaymEntry."Amount in Currency" = 0 then
                        PaymEntry."Amount in Currency" := 1;
                    Currency.Get(PaymEntry."Currency Code");
                    DSTR2 := '  #L###### #L####################       ';
                    FieldValue[1] := Currency.Code;
                    NodeName[1] := 'Currency Code';
                    FieldValue[2] := POSFunctions.FormatCurrency(-PaymEntry."Amount in Currency", PaymEntry."Currency Code") +
                    ' @ ' + Format(Round(PaymEntry."Exchange Rate", 0.001, '='));
                    NodeName[2] := 'x';
                    FieldValue[3] := Format(PaymEntry."Line No.");
                    NodeName[3] := 'Line No.';
                    FieldValue[4] := POSFunctions.FormatCurrency(-PaymEntry."Amount in Currency", PaymEntry."Currency Code");
                    NodeName[4] := 'Amount In Currency';
                    FieldValue[5] := Format(PaymEntry."Exchange Rate");
                    NodeName[5] := 'Exchange Rate';
                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR2), false, true, false, false));
                    AddPrintLine(700, 5, NodeName, FieldValue, DSTR2, false, true, false, false, Tray);
                end;

                TransInfoCode.SetRange("Store No.", Transaction."Store No.");
                TransInfoCode.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
                TransInfoCode.SetRange("Transaction No.", Transaction."Transaction No.");
                TransInfoCode.SetRange("Transaction Type", TransInfoCode."Transaction Type"::"Payment Entry");
                TransInfoCode.SetRange("Line No.", PaymEntry."Line No.");
                PrintTransInfoCode(TransInfoCode, Tray, false);
                RemainingAmount := '';
                if TransInfoCode.FindFirst() then
                    if TransInfoCode."Type of Input" = TransInfoCode."Type of Input"::"Apply To Entry" then
                        RemainingAmount := Format(CalcDataEntryRemainingAmount(TransInfoCode)) + ' ' + GiftCardCurrencyCode;
                if RemainingAmount <> '' then begin
                    DSTR1 := '  #L##################################  ';
                    NodeName[1] := RemAmountText;
                    FieldValue[1] := RemAmountText;
                    FieldValue[1] += RemainingAmount;
                    cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                    AddPrintLine(100, 1, NodeName, FieldValue, DSTR1, false, false, false, false, 2);
                end;

            until PaymEntry.Next = 0;
            PrintSeperator(Tray);
        end;

    end;


    local procedure CalcDataEntryRemainingAmount(TransInfoCodeEntry_p: Record "LSC Trans. Infocode Entry"): Decimal
    var
        DataEntry: Record "LSC POS Data Entry";
        DataEntryType_l: Record "LSC POS Data Entry Type";
        Infocode_l: Record "LSC Infocode";
        DataEntryNo: Code[20];
        Balance: Decimal;
        HasExpired: Boolean;
    begin
        Balance := 0;
        GiftCardCurrencyCode := '';
        if Infocode_l.Get(TransInfoCodeEntry_p.Infocode) then
            if DataEntryType_l.Get(Infocode_l."Data Entry Type") then
                if DataEntryType_l."Print Remaining Balance" then begin
                    DataEntry.SetRange("Entry Type", DataEntryType_l.Code);
                    DataEntry.SetRange("Entry Code", TransInfoCodeEntry_p.Information);
                    if DataEntry.FindSet then begin
                        repeat
                            HasExpired := false;
                            if (DataEntry."Expiring Date" <> 0D) and (DataEntry."Expiring Date" < Today) then
                                HasExpired := true;
                            if (not DataEntry.Applied) and (not HasExpired) then
                                Balance += DataEntry.Amount - DataEntry."Applied Amount";
                            if DataEntry."Currency Code" <> '' then
                                GiftCardCurrencyCode := DataEntry."Currency Code";
                        until DataEntry.Next = 0;
                    end;
                end;

        exit(Balance);
    end;


    local procedure GetItemName(ItemNo: Code[20]; VariantCode: Code[20]; CustLanguageCode: Code[10]; StoreLanguageCode: Code[10]): Text
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemName: Text;
        Handled: Boolean;
    begin

        if Item.Get(ItemNo) then begin
            if (VariantCode <> '') and
               (ItemVariant.Get(ItemNo, VariantCode))
            then
                ItemName := CopyStr(ItemVariant.Description, 1, 20)
            else
                ItemName := CopyStr(Item.Description, 1, 20);
        end else begin
            ItemName := ItemNo;
        end;

        GetItemNameTranslation(ItemNo, VariantCode, CustLanguageCode, StoreLanguageCode, ItemName);

        exit(ItemName);
    end;


    local procedure GetItemNameTranslation(ItemNo: Code[20]; VariantCode: Code[20]; CustLanguageCode: Code[10]; StoreLanguageCode: Code[10]; var ItemName: Text)
    var
        ItemTranslation: Record "Item Translation";
    begin
        Clear(ItemTranslation);
        if CustLanguageCode <> '' then begin
            if not ItemTranslation.Get(ItemNo, VariantCode, CustLanguageCode) then
                if StoreLanguageCode <> '' then
                    if ItemTranslation.Get(ItemNo, VariantCode, StoreLanguageCode) then;
        end else
            if StoreLanguageCode <> '' then
                if ItemTranslation.Get(ItemNo, VariantCode, StoreLanguageCode) then;

        if ItemTranslation.Description <> '' then
            ItemName := CopyStr(ItemTranslation.Description, 1, 20);
    end;


    procedure CollectDiscInfo(TransSalesEntry: Record "LSC Trans. Sales Entry"; Tray: Integer; var TotAmt: Decimal; var Subtot: Decimal; var PeriodicDiscountInfoTEMP: Record "LSC Periodic Discount" temporary)
    var
        TransDiscountEntry: Record "LSC Trans. Discount Entry";
        CouponHeader: Record "LSC Coupon Header";
        PeriodicDiscount: Record "LSC Periodic Discount";
        Transaction: record "LSC Transaction Header";
        DiscountText: Text[1000];
        DSTR2: Text[1000];
        OfferCode: Code[20];
    begin
        if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
            Subtot := Subtotal + TransSalesEntry."Net Amount" - TransSalesEntry."Discount Amount"
        else
            Subtot := Subtot + TransSalesEntry."Net Amount" + TransSalesEntry."VAT Amount" - TransSalesEntry."Discount Amount";
        if GenPosFunc."Print Disc/Cpn Info on Slip" in
          [GenPosFunc."Print Disc/Cpn Info on Slip"::"Summary information below Sub-total",
          GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
          GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line"] then begin
            TransDiscountEntry.Reset;
            TransDiscountEntry.SetRange("Store No.", TransSalesEntry."Store No.");
            TransDiscountEntry.SetRange("POS Terminal No.", TransSalesEntry."POS Terminal No.");
            TransDiscountEntry.SetRange("Transaction No.", TransSalesEntry."Transaction No.");
            TransDiscountEntry.SetRange("Line No.", TransSalesEntry."Line No.");
            if TransDiscountEntry.FindSet then
                repeat
                    if TransDiscountEntry."Offer Type" = TransDiscountEntry."Offer Type"::Line then
                        DiscountText := 'empl3'//Text084
                    else
                        DiscountText := Format(TransDiscountEntry."Offer Type");
                    Clear(PeriodicDiscount);
                    if TransDiscountEntry."Offer Type" = TransDiscountEntry."Offer Type"::Coupon then begin
                        if CouponHeader.Get(TransDiscountEntry."Offer No.") then
                            DiscountText := CouponHeader.Description;
                    end
                    else
                        if PeriodicDiscount.Get(TransDiscountEntry."Offer No.") then
                            DiscountText := PeriodicDiscount.Description
                        else
                            case TransDiscountEntry."Offer Type" of
                                TransDiscountEntry."Offer Type"::Total:
                                    begin
                                        DiscountText := Text024;
                                    end;
                                TransDiscountEntry."Offer Type"::Line:
                                    begin
                                        DiscountText := 'empl4';//Text084;
                                        if Transaction.Get(TransSalesEntry."Store No.", TransSalesEntry."POS Terminal No.", TransSalesEntry."Transaction No.") then begin
                                            case Transaction."Transaction Code Type" OF
                                                Transaction."Transaction Code Type"::"SC":
                                                    DiscountText := 'Senior Discount';
                                                Transaction."Transaction Code Type"::PWD:
                                                    DiscountText := 'PWD Discount';
                                                Transaction."Transaction Code Type"::SOLO:
                                                    DiscountText := 'SOLO Discount';
                                                Transaction."Transaction Code Type"::ATHL:
                                                    DiscountText := 'ATHL Discount';
                                                // Transaction."Transaction Code Type"::MOV:
                                                //     DiscountText := 'MOV Disc.';
                                                // Transaction."Transaction Code Type"::NAAC:
                                                //     DiscountText := 'NAAC Discount';
                                                Transaction."Transaction Code Type"::"Regular Customer", Transaction."Transaction Code Type"::REG,
                                                   Transaction."Transaction Code Type"::VATW, Transaction."Transaction Code Type"::WHT1,
                                                   Transaction."Transaction Code Type"::ZRWH, Transaction."Transaction Code Type"::ZERO:
                                                    begin
                                                        DiscountText := Text084;
                                                    end;
                                            end;
                                        end;
                                    end;
                                else
                                    DiscountText := Format(TransDiscountEntry."Offer Type");
                            end;
                    DiscountText := ConvertStr(DiscountText, '&', '+');
                    if GenPosFunc."Print Disc/Cpn Info on Slip" = GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total" then
                        if TransDiscountEntry."Offer Type" <> TransDiscountEntry."Offer Type"::Total then
                            Subtot := Subtot + TransDiscountEntry."Discount Amount";
                    if GenPosFunc."Print Disc/Cpn Info on Slip" =
                      GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line" then begin
                        TotAmt := TotAmt + TransDiscountEntry."Discount Amount";
                    end
                    else begin
                        if TransDiscountEntry."Discount Amount" <> 0 then begin
                            if not PeriodicDiscount."Block Printing" then begin
                                if TransDiscountEntry."Offer No." <> '' then
                                    OfferCode := TransDiscountEntry."Offer No."
                                else
                                    OfferCode := CopyStr(Format(TransDiscountEntry."Offer Type"), 1, MaxStrLen(OfferCode));
                                if not PeriodicDiscountInfoTEMP.Get(OfferCode) then begin
                                    PeriodicDiscountInfoTEMP := PeriodicDiscount;
                                    PeriodicDiscountInfoTEMP."No." := OfferCode;
                                    PeriodicDiscountInfoTEMP."Discount Amount Value" := TransDiscountEntry."Discount Amount";
                                    PeriodicDiscountInfoTEMP."Discount % Value" := 0;
                                    PeriodicDiscountInfoTEMP.Description := DiscountText;
                                    PeriodicDiscountInfoTEMP.Insert;
                                end
                                else begin
                                    PeriodicDiscountInfoTEMP."Discount Amount Value" := PeriodicDiscountInfoTEMP."Discount Amount Value" +
                                      TransDiscountEntry."Discount Amount";
                                    PeriodicDiscountInfoTEMP.Modify;
                                end;
                            end
                            else
                                Subtotal := Subtotal + TransDiscountEntry."Discount Amount";
                        end;
                        if TransDiscountEntry.Points <> 0 then begin
                            if not PeriodicDiscountInfoTEMP.Get(TransDiscountEntry."Offer No.") then begin
                                PeriodicDiscountInfoTEMP := PeriodicDiscount;
                                PeriodicDiscountInfoTEMP."No." := TransDiscountEntry."Offer No.";
                                PeriodicDiscountInfoTEMP."Discount Amount Value" := 0;
                                PeriodicDiscountInfoTEMP."Discount % Value" := TransDiscountEntry.Points;
                                PeriodicDiscountInfoTEMP.Description := DiscountText;
                                PeriodicDiscountInfoTEMP.Insert;
                            end
                            else begin
                                PeriodicDiscountInfoTEMP."Discount % Value" := PeriodicDiscountInfoTEMP."Discount % Value" +
                                  TransDiscountEntry.Points;
                                PeriodicDiscountInfoTEMP.Modify;
                            end;
                        end;
                    end;
                until TransDiscountEntry.Next = 0;
        end;
    end;


    local procedure PrintItemPOSText(ItemNo: Code[20]; CustLanguageCode: Code[10]; StoreLanguageCode: Code[10]; LineNo: Integer; Tray: Integer)
    var
        ItemPosTextHeader: Record "LSC Item POS Text Header";
        ItemPosTextLine: Record "LSC Item POS Text Line";
        DSTR1: Text[100];
        IsHandled: Boolean;
        TextFound: Boolean;
    begin

        TextFound := false;
        Clear(ItemPosTextHeader);
        if CustLanguageCode <> '' then
            if ItemPosTextHeader.Get(ItemNo, ItemPosTextHeader."Text Type"::"Receipt Text", CustLanguageCode) then
                TextFound := true;
        if not TextFound then
            if StoreLanguageCode <> '' then
                if ItemPosTextHeader.Get(ItemNo, ItemPosTextHeader."Text Type"::"Receipt Text", StoreLanguageCode) then
                    TextFound := true;
        if not TextFound then
            if ItemPosTextHeader.Get(ItemNo, ItemPosTextHeader."Text Type"::"Receipt Text", '') then
                TextFound := true;

        if TextFound then begin
            ItemPosTextLine.Reset;
            ItemPosTextLine.SetRange("Item No.", ItemPosTextHeader."Item No.");
            ItemPosTextLine.SetRange("Text Type", ItemPosTextLine."Text Type"::"Receipt Text");
            ItemPosTextLine.SetRange("Language Code", ItemPosTextHeader."Language Code");
            DSTR1 := '#T######################################';
            if ItemPosTextLine.FindSet() then
                repeat
                    FieldValue[1] := ItemPosTextLine.Text;
                    NodeName[1] := 'Extra Info Line';
                    FieldValue[2] := Format(LineNo);
                    NodeName[2] := 'Line No.';
                    cduSender.PrintLine(Tray, ItemPosTextLine.Text);
                    AddPrintLine(350, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                until ItemPosTextLine.Next = 0;
        end;
    end;


    procedure PrintDeal(TransSalesEntry: Record "LSC Trans. Sales Entry"; Tray: Integer; PrintItemNo: Integer)
    var
        tmpTransSalesEntry: Record "LSC Trans. Sales Entry" temporary;
        Deal: Record "LSC Offer";
        DealLine: Record "LSC Offer Line";
        DealEntry: Record "LSC Trans. Deal Entry";
        tmpPOSVATCode: Record "LSC POS VAT Code" temporary;
        TransSalesEntry2: Record "LSC Trans. Sales Entry";
        TransDiscountEntry: Record "LSC Trans. Discount Entry";
        TransDiscountEntryTEMP: Record "LSC Trans. Discount Entry" temporary;
        CouponHeader: Record "LSC Coupon Header";
        PeriodicDiscount: Record "LSC Periodic Discount";
        TransHdr: Record "LSC Transaction Header";
        Customer: Record Customer;
        DSTR1: Text[100];
        DiscountText: Text[1000];
        DSTR2: Text[100];
        DealFilter: Text;
        DealAmountWithoutDisc: Decimal;
        DealQty: Decimal;
        DealAddedAmt: Decimal;
        DealHeaderLineNo: Integer;
        DealPrintingOption: Option "Header Only","Items w/Added Amt. Only","All Lines";
        DealModifierPrintingOption: Option "None","Modifier Desc. & Amt. Only","All Modifier Lines ";
        CompressOk: Boolean;
        IsHandled: Boolean;
    begin
        if not DealEntry.Get(
                 TransSalesEntry."Store No.", TransSalesEntry."POS Terminal No.", TransSalesEntry."Transaction No.",
                 TransSalesEntry."Line No.")
        then
            exit;

        DealHeaderLineNo := TransSalesEntry."Deal Header Line No.";
        DealAmountWithoutDisc := 0;
        DealQty := 0;
        DealAddedAmt := 0;
        CompressOk := false;

        Clear(Customer);
        TransHdr.Get(TransSalesEntry."Store No.", TransSalesEntry."POS Terminal No.", TransSalesEntry."Transaction No.");
        if Customer.Get(TransHdr."Customer No.") then;

        tmpTransSalesEntry.DeleteAll;
        tmpPOSVATCode.DeleteAll;

        if (DealEntry."Total Deal Line Added Amt." = 0) and (DealEntry."Total Deal Modifier Added Amt." = 0) and (DealEntry."Line Discount Amt." = 0) then
            CompressOk := true;

        if CompressOk then begin
            if not tmpDeal.Get(DealEntry."Deal No.") then begin
                tmpDeal."No." := DealEntry."Deal No.";
                tmpDeal."Deal Price" := DealEntry.Price;
                tmpDeal.Insert;
            end else
                if tmpDeal."Deal Price" = DealEntry.Price then
                    exit;

            DealEntry.SetRange("Store No.", DealEntry."Store No.");
            DealEntry.SetRange("POS Terminal No.", DealEntry."POS Terminal No.");
            DealEntry.SetRange("Transaction No.", DealEntry."Transaction No.");
            DealEntry.SetRange("Deal No.", DealEntry."Deal No.");
            DealEntry.SetRange("Total Deal Line Added Amt.", 0);
            DealEntry.SetRange("Total Deal Modifier Added Amt.", 0);
            DealEntry.SetRange("Line Discount Amt.", 0);
            if DealEntry.FindSet then begin
                repeat
                    if GenPosFunc."Print Disc/Cpn Info on Slip" = GenPosFunc."Print Disc/Cpn Info on Slip"::"No printing" then
                        DealAmountWithoutDisc += -DealEntry.Amount
                    else
                        DealAmountWithoutDisc += -(DealEntry.Amount - DealEntry."Total Discount Amt.");
                    DealQty += -DealEntry.Quantity;
                    if DealFilter <> '' then
                        DealFilter := DealFilter + '|' + Format(DealEntry."Deal Header Line No.")
                    else
                        DealFilter := Format(DealEntry."Deal Header Line No.");
                until DealEntry.Next = 0;
            end;
        end else begin
            DealEntry.SetRange("Store No.", DealEntry."Store No.");
            DealEntry.SetRange("POS Terminal No.", DealEntry."POS Terminal No.");
            DealEntry.SetRange("Transaction No.", DealEntry."Transaction No.");
            DealEntry.SetRange("Deal No.", DealEntry."Deal No.");
            DealEntry.SetRange("Deal Header Line No.", DealHeaderLineNo);
            if DealEntry.FindSet then begin
                if GenPosFunc."Print Disc/Cpn Info on Slip" = GenPosFunc."Print Disc/Cpn Info on Slip"::"No printing" then
                    DealAmountWithoutDisc := -DealEntry.Amount
                else
                    DealAmountWithoutDisc := -(DealEntry.Amount - DealEntry."Line Discount Amt." - DealEntry."Total Discount Amt.");
                DealAddedAmt := -DealEntry."Total Deal Line Added Amt." - DealEntry."Total Deal Modifier Added Amt.";
                DealQty := -DealEntry.Quantity;
                DealFilter := Format(DealEntry."Deal Header Line No.");
            end;
        end;

        if Deal.Get(DealEntry."Deal No.") then begin
            if Deal."Deal Lines Printing" <> Deal."Deal Lines Printing"::"From Functionality Profile" then
                DealPrintingOption := Deal."Deal Lines Printing" - 1
            else
                DealPrintingOption := GenPosFunc."Deal Lines Printing";
        end else
            DealPrintingOption := GenPosFunc."Deal Lines Printing";

        TransSalesEntry.SetRange("Store No.", TransSalesEntry."Store No.");
        TransSalesEntry.SetRange("POS Terminal No.", TransSalesEntry."POS Terminal No.");
        TransSalesEntry.SetRange("Transaction No.", TransSalesEntry."Transaction No.");
        TransSalesEntry.SetFilter("Deal Header Line No.", DealFilter);
        if TransSalesEntry.FindSet then
            repeat
                if TransSalesEntry."Promotion No." = DealEntry."Deal No." then begin
                    tmpTransSalesEntry := TransSalesEntry;
                    tmpTransSalesEntry.Insert;
                    if tmpPOSVATCode.Get(tmpTransSalesEntry."VAT Code") then begin
                        if GenPosFunc."Print Disc/Cpn Info on Slip" = GenPosFunc."Print Disc/Cpn Info on Slip"::"No printing" then
                            tmpPOSVATCode."VAT %" += tmpTransSalesEntry."Net Amount" + tmpTransSalesEntry."VAT Amount"
                        else
                            tmpPOSVATCode."VAT %" += tmpTransSalesEntry."Net Amount" + tmpTransSalesEntry."VAT Amount" - tmpTransSalesEntry."Discount Amount";
                        tmpPOSVATCode.Modify;
                    end else begin
                        tmpPOSVATCode."VAT Code" := tmpTransSalesEntry."VAT Code";
                        if GenPosFunc."Print Disc/Cpn Info on Slip" = GenPosFunc."Print Disc/Cpn Info on Slip"::"No printing" then
                            tmpPOSVATCode."VAT %" := tmpTransSalesEntry."Net Amount" + tmpTransSalesEntry."VAT Amount"
                        else
                            tmpPOSVATCode."VAT %" := tmpTransSalesEntry."Net Amount" + tmpTransSalesEntry."VAT Amount" - tmpTransSalesEntry."Discount Amount";
                        tmpPOSVATCode.Insert;
                    end;
                end;
            until TransSalesEntry.Next = 0;

        Clear(FieldValue);
        if Deal.Get(DealEntry."Deal No.") then
            FieldValue[1] := Deal.Description
        else
            FieldValue[1] := Text501;
        NodeName[1] := 'Item Description';
        DSTR1 := '#L###################### #N########## #R';
        if tmpPOSVATCode.Count = 1 then begin
            if DealQty = 1 then begin
                FieldValue[2] := POSFunctions.FormatPrice(DealAmountWithoutDisc);
                NodeName[2] := 'Amount';
                if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then begin
                    if DealAmountWithoutDisc <> 0 then begin
                        FieldValue[3] := 'T';
                        NodeName[3] := 'VAT Code';
                    end else begin
                        FieldValue[3] := 'N';
                        NodeName[3] := 'VAT Code';
                    end;
                end else begin
                    FieldValue[3] := tmpPOSVATCode."VAT Code";
                    NodeName[3] := 'VAT Code';
                end;
                FieldValue[4] := Format(TransSalesEntry."Line No.");
                NodeName[4] := 'Line No.';
                cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                AddPrintLine(300, 4, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            end else begin
                FieldValue[2] := '';
                NodeName[2] := 'x';
                NodeName[3] := 'x';
                FieldValue[4] := Format(TransSalesEntry."Line No.");
                NodeName[4] := 'Line No.';
                cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                AddPrintLine(300, 4, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                DSTR1 := '   #L################### #N########## #R';
                FieldValue[1] :=
                  POSFunctions.FormatQty(DealQty) + GenPosFunc.GetMultipleItemsSymbol()
                  + POSFunctions.FormatPrice(DealAmountWithoutDisc / DealQty);
                NodeName[1] := 'x';
                FieldValue[2] := POSFunctions.FormatPrice(DealAmountWithoutDisc);
                NodeName[2] := 'Amount';
                if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then begin
                    if DealAmountWithoutDisc <> 0 then begin
                        FieldValue[3] := 'T';
                        NodeName[3] := 'VAT Code';
                    end else begin
                        FieldValue[3] := 'N';
                        NodeName[3] := 'VAT Code';
                    end;
                end else begin
                    FieldValue[3] := tmpPOSVATCode."VAT Code";
                    NodeName[3] := 'VAT Code';
                end;
                FieldValue[4] := Format(TransSalesEntry."Line No.");
                NodeName[4] := 'Line No.';
                FieldValue[5] := POSFunctions.FormatQty(DealQty);
                NodeName[5] := 'Quantity';
                FieldValue[6] := POSFunctions.FormatPrice(DealAmountWithoutDisc / DealQty);
                NodeName[6] := 'Price';
                cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                AddPrintLine(300, 6, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            end;
        end else begin
            FieldValue[2] := '';
            NodeName[2] := 'x';
            NodeName[3] := 'x';
            FieldValue[4] := Format(TransSalesEntry."Line No.");
            NodeName[4] := 'Line No.';
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
            AddPrintLine(300, 4, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            DSTR1 := '   #L################### #N########## #R';
            FieldValue[1] :=
              POSFunctions.FormatQty(DealQty) + ' ' + GenPosFunc."Multiple Items Symbol" + ' '
              + POSFunctions.FormatPrice(DealAmountWithoutDisc / DealQty);
            NodeName[1] := 'x';
            FieldValue[2] := '';
            NodeName[2] := 'x';
            NodeName[3] := 'x';
            FieldValue[4] := Format(TransSalesEntry."Line No.");
            NodeName[4] := 'Line No.';
            FieldValue[5] := POSFunctions.FormatQty(DealQty);
            NodeName[5] := 'Quantity';
            FieldValue[6] := POSFunctions.FormatPrice(DealAmountWithoutDisc / DealQty);
            NodeName[6] := 'Price';
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
            AddPrintLine(300, 6, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            tmpPOSVATCode.FindSet();
            DSTR1 := '   #L################### #N########## #R';
            repeat
                if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then begin
                    if tmpPOSVATCode."VAT %" <> 0 then begin
                        FieldValue[3] := 'T';
                        NodeName[3] := 'VAT Code';
                    end else begin
                        FieldValue[3] := 'N';
                        NodeName[3] := 'VAT Code';
                    end;
                end else begin
                    FieldValue[3] := tmpPOSVATCode."VAT Code";
                    NodeName[3] := 'x';
                end;
                FieldValue[2] := POSFunctions.FormatAmount(-tmpPOSVATCode."VAT %");
                NodeName[2] := 'x';
                FieldValue[1] := '';
                NodeName[1] := 'x';
                FieldValue[4] := Format(TransSalesEntry."Line No.");
                NodeName[4] := 'Line No.';
                cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                AddPrintLine(350, 4, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            until tmpPOSVATCode.Next = 0;
        end;
        if GenPosFunc."Print Free Text on Receipt" then begin
            if DealEntry.FindSet then
                repeat
                    PrintDealFreeTextLines(DealEntry, Tray, false, TransSalesEntry."Line No.");
                until DealEntry.Next = 0;
        end;

        if DealPrintingOption <> DealPrintingOption::"Header Only" then begin
            if tmpTransSalesEntry.FindSet() then
                repeat
                    if tmpTransSalesEntry."Deal Modifier Added Amt." <> 0 then begin
                        DSTR1 := '   #L###################################';
                        if DealLine.Get(DealEntry."Deal No.", tmpTransSalesEntry."Deal Line No.") then begin
                            FieldValue[1] := DealLine.Description;
                            DealModifierPrintingOption := DealLine."Receipt Printing" + 1;
                        end else begin
                            FieldValue[1] := Text502;
                            DealModifierPrintingOption := DealModifierPrintingOption::"Modifier Desc. & Amt. Only";
                        end;
                        FieldValue[1] := FieldValue[1] + GenPosFunc.GetMultipleItemsSymbol()
                                    + POSFunctions.FormatPrice(tmpTransSalesEntry."Deal Modifier Added Amt.") + ' ' + Globals.GetValue('CURRSYM');
                        NodeName[1] := 'Extra Info Line';
                        FieldValue[2] := Format(TransSalesEntry."Line No.");
                        NodeName[2] := 'Line No.';
                        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, (tmpTransSalesEntry."Periodic Discount" <> 0), false, false));
                        AddPrintLine(350, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                        TransSalesEntry.SetRange("Deal Header Line No.", tmpTransSalesEntry."Deal Header Line No.");
                        TransSalesEntry.SetRange("Deal Line No.", tmpTransSalesEntry."Deal Line No.");
                        if TransSalesEntry.FindSet() then
                            repeat
                                PrintDealLines(PrintItemNo, TransSalesEntry, Tray, true, DealPrintingOption, DealModifierPrintingOption, Customer."Language Code");
                            until TransSalesEntry.Next = 0;
                        Clear(DealModifierPrintingOption);
                    end else
                        PrintDealLines(PrintItemNo, tmpTransSalesEntry, Tray, false, DealPrintingOption, DealModifierPrintingOption, Customer."Language Code");
                    if GenPosFunc."Print Free Text on Receipt" then
                        PrintFreeTextLines(tmpTransSalesEntry, Tray, true);
                until tmpTransSalesEntry.Next = 0;
        end;

        if GenPosFunc."Print Disc/Cpn Info on Slip" in
                  [GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
                  GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line"]
        then begin
            TransDiscountEntryTEMP.Reset;
            TransDiscountEntryTEMP.DeleteAll;

            TransSalesEntry2.Reset;
            TransSalesEntry2.SetRange("Store No.", TransSalesEntry."Store No.");
            TransSalesEntry2.SetRange("POS Terminal No.", TransSalesEntry."POS Terminal No.");
            TransSalesEntry2.SetRange("Transaction No.", TransSalesEntry."Transaction No.");
            TransSalesEntry2.SetFilter("Deal Header Line No.", DealFilter);
            if TransSalesEntry2.FindSet then
                repeat
                    TransDiscountEntry.Reset;
                    TransDiscountEntry.SetRange("Store No.", TransSalesEntry2."Store No.");
                    TransDiscountEntry.SetRange("POS Terminal No.", TransSalesEntry2."POS Terminal No.");
                    TransDiscountEntry.SetRange("Transaction No.", TransSalesEntry2."Transaction No.");
                    TransDiscountEntry.SetRange("Line No.", TransSalesEntry2."Line No.");
                    if TransDiscountEntry.FindSet then
                        repeat
                            TransDiscountEntryTEMP.SetRange("Offer Type", TransDiscountEntry."Offer Type");
                            TransDiscountEntryTEMP.SetFilter("Offer No.", '%1', TransDiscountEntry."Offer No.");
                            if TransDiscountEntryTEMP.FindFirst then begin
                                TransDiscountEntryTEMP."Discount Amount" := TransDiscountEntryTEMP."Discount Amount" +
                                  TransDiscountEntry."Discount Amount";
                                TransDiscountEntryTEMP.Points := TransDiscountEntryTEMP.Points +
                                  TransDiscountEntry.Points;
                                TransDiscountEntryTEMP.Modify;
                            end
                            else begin
                                TransDiscountEntryTEMP := TransDiscountEntry;
                                TransDiscountEntryTEMP.Insert;
                            end;
                        until TransDiscountEntry.Next = 0;
                until TransSalesEntry2.Next = 0;
            TransDiscountEntryTEMP.Reset;
            if TransDiscountEntryTEMP.FindSet then
                repeat
                    if TransDiscountEntryTEMP."Offer Type" = TransDiscountEntryTEMP."Offer Type"::Line then
                        DiscountText := 'empl5'//Text084
                    else
                        DiscountText := Format(TransDiscountEntryTEMP."Offer Type");

                    if TransDiscountEntryTEMP."Offer Type" = TransDiscountEntryTEMP."Offer Type"::Coupon then begin
                        if CouponHeader.Get(TransDiscountEntryTEMP."Offer No.") then
                            DiscountText := CouponHeader.Description;
                    end
                    else
                        if PeriodicDiscount.Get(TransDiscountEntryTEMP."Offer No.") then
                            DiscountText := PeriodicDiscount.Description
                        else
                            case TransDiscountEntryTEMP."Offer Type" of
                                TransDiscountEntryTEMP."Offer Type"::Total:
                                    DiscountText := Text024;
                                TransDiscountEntryTEMP."Offer Type"::Line:
                                    DiscountText := Text084
                                else
                                    DiscountText := Format(TransDiscountEntryTEMP."Offer Type");
                            end;
                    DiscountText := ConvertStr(DiscountText, '&', '+');
                    NodeName[1] := 'Total Text';
                    NodeName[2] := 'Total Amount';
                    if TransDiscountEntryTEMP."Discount Amount" <> 0 then begin
                        DSTR2 := '   #L################# #N############   ';
                        FieldValue[1] := DiscountText;
                        FieldValue[2] := POSFunctions.FormatAmount(-TransDiscountEntryTEMP."Discount Amount");
                        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR2), false, false, false, false));
                        AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                    end;
                    if TransDiscountEntryTEMP.Points <> 0 then begin
                        DSTR2 := '   #L################# #N############   ';
                        FieldValue[1] := DiscountText;
                        FieldValue[2] := POSFunctions.FormatAmount(TransDiscountEntry."Discount Amount") + ' ' + Text232;
                        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR2), false, false, false, false));
                        AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                    end;
                until TransDiscountEntryTEMP.Next = 0;
        end;
    end;


    procedure PrintDealFreeTextLines(DealEntry: Record "LSC Trans. Deal Entry"; Tray: Integer; Indent: Boolean; LineNo: Integer)
    var
        TransInfoEntry: Record "LSC Trans. Infocode Entry";
        DSTR1: Text[100];
        FromLineNo: Integer;
        ToLineNo: Integer;
        IsHandled: Boolean;
    begin

        FromLineNo := DealEntry."Deal Header Line No." + 1;
        ToLineNo := DealEntry."Deal Header Line No." - (DealEntry."Deal Header Line No." mod 10000) + 9999;

        Clear(TransInfoEntry);
        TransInfoEntry.SetRange("Store No.", DealEntry."Store No.");
        TransInfoEntry.SetRange("POS Terminal No.", DealEntry."POS Terminal No.");
        TransInfoEntry.SetRange("Transaction No.", DealEntry."Transaction No.");
        TransInfoEntry.SetRange("Transaction Type", TransInfoEntry."Transaction Type"::"Sales Entry");
        TransInfoEntry.SetRange("Line No.", FromLineNo, ToLineNo);
        TransInfoEntry.SetRange(Infocode, 'TEXT');
        TransInfoEntry.SetRange("Text Type", TransInfoEntry."Text Type"::"Freetext Input");

        if TransInfoEntry.FindSet then begin
            Clear(FieldValue);
            DSTR1 := '#T######################################';
            if Indent then
                DSTR1 := '   #T###################################';
            repeat
                if (TransInfoEntry.Information <> '') then begin
                    FieldValue[1] := CopyStr(TransInfoEntry.Information, 1, 50);
                    NodeName[1] := 'Extra Info Line';
                    FieldValue[2] := Format(DealEntry."Line No.");
                    NodeName[2] := 'Line No.';
                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
                    AddPrintLine(350, 2, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
                end;
            until TransInfoEntry.Next = 0;
        end;
    end;


    procedure PrintFreeTextLines(SalesEntry: Record "LSC Trans. Sales Entry"; Tray: Integer; Indent: Boolean)
    var
        TransInfoEntry: Record "LSC Trans. Infocode Entry";
        DSTR1: Text[100];
        FromLineNo: Integer;
        ToLineNo: Integer;
        IsHandled: Boolean;
    begin

        FromLineNo := SalesEntry."Line No." + 1;
        ToLineNo := SalesEntry."Line No." - (SalesEntry."Line No." mod 10000) + 9999;

        Clear(TransInfoEntry);
        TransInfoEntry.SetRange("Store No.", SalesEntry."Store No.");
        TransInfoEntry.SetRange("POS Terminal No.", SalesEntry."POS Terminal No.");
        TransInfoEntry.SetRange("Transaction No.", SalesEntry."Transaction No.");
        TransInfoEntry.SetRange("Transaction Type", TransInfoEntry."Transaction Type"::"Sales Entry");
        TransInfoEntry.SetRange("Line No.", FromLineNo, ToLineNo);
        TransInfoEntry.SetRange(Infocode, 'TEXT');
        TransInfoEntry.SetRange("Text Type", TransInfoEntry."Text Type"::"Deal Header");
        if TransInfoEntry.FindFirst then
            ToLineNo := TransInfoEntry."Line No." - 1;
        TransInfoEntry.SetRange("Line No.", FromLineNo, ToLineNo);
        TransInfoEntry.SetRange(Infocode, 'TEXT');
        TransInfoEntry.SetRange("Text Type", TransInfoEntry."Text Type"::"Freetext Input");
        if TransInfoEntry.FindSet then begin
            Clear(FieldValue);
            DSTR1 := '#T######################################';
            if Indent then
                DSTR1 := '   #T###################################';
            repeat
                if (TransInfoEntry.Information <> '') then begin
                    FieldValue[1] := CopyStr(TransInfoEntry.Information, 1, 50);
                    NodeName[1] := 'Extra Info Line';
                    FieldValue[2] := Format(SalesEntry."Line No.");
                    NodeName[2] := 'Line No.';
                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
                    AddPrintLine(350, 2, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
                end;
            until TransInfoEntry.Next = 0;
        end;
    end;

    procedure PrintFreeTextLinesFromBuffer(SalesEntry: Record "LSC Trans. Sales Entry"; var RecipeBufferTransInfoTextTEMP_p: Record "LSC Trans. Infocode Entry" temporary; Tray: Integer; Indent: Boolean)
    var
        TransInfoEntry: Record "LSC Trans. Infocode Entry";
        DSTR1: Text[100];
        FromLineNo: Integer;
        ToLineNo: Integer;
        IsHandled: Boolean;
    begin

        RecipeBufferTransInfoTextTEMP_p.Reset;
        RecipeBufferTransInfoTextTEMP_p.SetRange("Store No.", SalesEntry."Store No.");
        RecipeBufferTransInfoTextTEMP_p.SetRange("POS Terminal No.", SalesEntry."POS Terminal No.");
        RecipeBufferTransInfoTextTEMP_p.SetRange("Transaction No.", SalesEntry."Transaction No.");
        RecipeBufferTransInfoTextTEMP_p.SetRange("Transaction Type", RecipeBufferTransInfoTextTEMP_p."Transaction Type"::"Sales Entry");
        RecipeBufferTransInfoTextTEMP_p.SetRange("Line No.", SalesEntry."Line No.");
        if RecipeBufferTransInfoTextTEMP_p.FindSet then begin
            Clear(FieldValue);
            DSTR1 := '#T######################################';
            if Indent then
                DSTR1 := '   #T###################################';
            repeat
                FieldValue[1] := CopyStr(RecipeBufferTransInfoTextTEMP_p.Information, 1, 50);
                NodeName[1] := 'Extra Info Line';
                FieldValue[2] := Format(RecipeBufferTransInfoTextTEMP_p."Line No.");
                NodeName[2] := 'Line No.';
                cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
                AddPrintLine(350, 2, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
            until RecipeBufferTransInfoTextTEMP_p.Next = 0;
        end;
    end;


    procedure PrintCopyText(Tray: Integer): Boolean
    var
        DSTR1: Text[100];
        Payment: Text[30];
        IsHandled: Boolean;
        ReturnValue: Boolean;
    begin
        DSTR1 := '#C##################';


        FieldValue[1] := Text046 + '`2`';

        NodeName[1] := 'Print Info';
        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), true, false, true, false));
        cduSender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, true, false, true, false, Tray);
        PrintSeperator(Tray);
    end;

    procedure PrintVOIDTransaction(Transaction: Record "LSC Transaction Header"; Tray: Integer)
    var
        DSTR1: Text[100];
        PosVoidtransLine: record "LSC POS Voided Trans. Line";//ditoooo
        totalvoid: Decimal;
    begin
        //VINCENT20251210 VOID
        DSTR1 := '#L############### #R#################';
        FieldValue[1] := 'Description';
        FieldValue[2] := 'Amount';
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
        Clear(FieldValue);
        PosVoidtransLine.RESET();
        PosVoidtransLine.SetRange(PosVoidtransLine."Receipt No.", Transaction."Receipt No.");
        IF PosVoidtransLine.FindFirst() then begin
            PrintSeperator(Tray);
            DSTR1 := '#L#################### #R###############';
            repeat
                FieldValue[1] := GetItemName(PosVoidtransLine."Number", PosVoidtransLine."Variant Code", '', Store."Language Code");
                FieldValue[2] := POSFunctions.FormatAmount(Abs(PosVoidtransLine.Price)) + '  ' + PosVoidtransLine."VAT Code";
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
            until PosVoidtransLine.Next() = 0;
        end;

        //END
        PrintSeperator(Tray);
        DSTR1 := '#L############### #R#################';
        FieldValue[1] := 'Total';
        PosVoidtransLine.reset();
        PosVoidtransLine.SetRange(PosVoidtransLine."Receipt No.", Transaction."Receipt No.");
        if PosVoidtransLine.findfirst() then begin
            repeat
                totalvoid += PosVoidtransLine.Amount;
            until PosVoidtransLine.next() = 0;
        end;

        FieldValue[2] := POSFunctions.FormatAmount(totalvoid);
        NodeName[1] := 'Print Info';
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
        CLEAR(FieldValue);
        PrintSeperator(Tray);
    end;

    procedure PrintDealLines(PrintItemNo: Integer; SalesEntry: Record "LSC Trans. Sales Entry"; Tray: Integer; Indent: Boolean; DealPrintingOption: Option "Header Only","Items w/Added Amt. Only","All Lines"; DealModifierPrintingOption: Option "None","Modifier Desc. & Amt. Only","All Modifier Lines "; CustLanguageCode: Code[10])
    var
        TransInfoEntry: Record "LSC Trans. Infocode Entry";
        DSTR1: Text[100];
        ItemName: Text[30];
        IsHandled: Boolean;
    begin

        if TmpPrintedSalesEntry.Get(
             SalesEntry."Store No.", SalesEntry."POS Terminal No.", SalesEntry."Transaction No.", SalesEntry."Line No.")
        then
            exit
        else begin
            TmpPrintedSalesEntry."Store No." := SalesEntry."Store No.";
            TmpPrintedSalesEntry."POS Terminal No." := SalesEntry."POS Terminal No.";
            TmpPrintedSalesEntry."Transaction No." := SalesEntry."Transaction No.";
            TmpPrintedSalesEntry."Line No." := SalesEntry."Line No.";
            TmpPrintedSalesEntry.Insert;
        end;

        if DealModifierPrintingOption = DealModifierPrintingOption::"Modifier Desc. & Amt. Only" then
            exit;

        if (DealPrintingOption = DealPrintingOption::"Items w/Added Amt. Only") and (SalesEntry."Deal Line Added Amt." = 0) then
            exit;

        if not IsHandled then
            ItemName := GetItemName(SalesEntry."Item No.", SalesEntry."Variant Code", CustLanguageCode, Store."Language Code");

        ItemName := copystr(itemname, 1, 18);

        DSTR1 := '   #L######### #L###################';
        if PrintItemNo <> 0 then begin
            if PrintItemNo = 1 then begin
                FieldValue[1] := Text074;
                NodeName[1] := 'x';
                FieldValue[2] := SalesEntry."Item No.";
                NodeName[2] := 'Item No.';
            end else begin
                if SalesEntry."Barcode No." <> '' then begin
                    FieldValue[1] := Text075;
                    NodeName[1] := 'x';
                    FieldValue[2] := SalesEntry."Barcode No.";
                    NodeName[2] := 'Barcode';
                end else begin
                    FieldValue[1] := Text074;
                    NodeName[1] := 'x';
                    FieldValue[2] := SalesEntry."Item No.";
                    NodeName[2] := 'Item No.';
                end;
            end;
            FieldValue[3] := Format(SalesEntry."Line No.");
            NodeName[3] := 'Line No.';
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
            AddPrintLine(300, 3, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
        end;

        if (Abs(SalesEntry.Quantity) <> 1) or SalesEntry."Scale Item" or SalesEntry."Price in Barcode" then begin
            if Indent then
                DSTR1 := '     #L#################################'
            else
                DSTR1 := '   #L###################################';
            FieldValue[1] := ItemName;
            NodeName[1] := 'x';
            if SalesEntry."Deal Line Added Amt." <> 0 then
                FieldValue[1] := FieldValue[1] + GenPosFunc.GetMultipleItemsSymbol()
                            + POSFunctions.FormatPrice(SalesEntry."Deal Line Added Amt.") + ' ' + Globals.GetValue('CURRSYM');
            FieldValue[2] := ItemName;
            NodeName[2] := 'Item Description';
            FieldValue[3] := Format(SalesEntry."Line No.");
            NodeName[3] := 'Line No.';
            //FieldValue[4] := POSFunctions.FormatPrice(SalesEntry."Deal Line Added Amt.");
            FieldValue[4] := POSFunctions.FormatPrice(SalesEntry.Price);
            NodeName[4] := 'Price';

            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
            AddPrintLine(300, 3, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

            Clear(FieldValue);
            if Indent then
                DSTR1 := '       #L############### #N########## #R'
            else
                DSTR1 := '     #L################# #N########## #R';
            if SalesEntry."Scale Item" or SalesEntry."Price in Barcode" then begin
                if SalesEntry."Weight Manually Entered" then begin
                    if Indent then
                        DSTR1 := '    MAN #L############## #N########## #R'
                    else
                        DSTR1 := '  MAN #L################ #N########## #R';
                end;
                FieldValue[1] := FieldValue[1] + MyPOSFunctions.FormatWeight(-SalesEntry.Quantity, SalesEntry."Unit of Measure");
            end else begin
                if SalesEntry."Unit of Measure" = '' then
                    SalesEntry."Unit of Measure" := Text131;
                if (SalesEntry."UOM Quantity" <> 0) then begin
                    SalesEntry.Quantity := SalesEntry."UOM Quantity";
                    SalesEntry.Price := SalesEntry."UOM Price";
                end;
                FieldValue[1] := POSFunctions.FormatQty(-SalesEntry.Quantity) + LowerCase(SalesEntry."Unit of Measure");
            end;
            NodeName[1] := 'x';
            FieldValue[2] := '';
            NodeName[2] := 'x';
            FieldValue[3] := SalesEntry."VAT Code";
            NodeName[3] := 'VAT Code';
            FieldValue[4] := Format(SalesEntry."Line No.");
            NodeName[4] := 'Line No.';
            FieldValue[5] := SalesEntry."Unit of Measure";
            NodeName[5] := 'UOM ID';
            FieldValue[6] := POSFunctions.FormatQty(-SalesEntry.Quantity);
            NodeName[6] := 'Quantity';
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, (SalesEntry."Periodic Discount" <> 0), false, false));
            AddPrintLine(300, 6, NodeName, FieldValue, DSTR1, false, (SalesEntry."Periodic Discount" <> 0), false, false, Tray);
        end else begin
            if Indent then
                DSTR1 := '     #L############################## #R'
            else
                DSTR1 := '   #L################################ #R';
            FieldValue[1] := ItemName;
            if SalesEntry."Unit of Measure" <> '' then
                FieldValue[1] := FieldValue[1] + ' ' + SalesEntry."Unit of Measure";
            if SalesEntry."Deal Line Added Amt." <> 0 then
                FieldValue[1] := FieldValue[1] + GenPosFunc.GetMultipleItemsSymbol()
                            + POSFunctions.FormatPrice(SalesEntry."Deal Line Added Amt.") + ' ' + Globals.GetValue('CURRSYM');
            NodeName[1] := 'x';
            FieldValue[2] := SalesEntry."VAT Code";
            NodeName[2] := 'VAT Code';
            FieldValue[3] := Format(SalesEntry."Line No.");
            NodeName[3] := 'Line No.';
            FieldValue[4] := SalesEntry."Unit of Measure";
            NodeName[4] := 'UOM ID';
            FieldValue[5] := POSFunctions.FormatQty(-SalesEntry.Quantity);
            NodeName[5] := 'Quantity';
            FieldValue[6] := POSFunctions.FormatPrice(SalesEntry."Deal Line Added Amt.");
            NodeName[6] := 'Price';
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, (SalesEntry."Periodic Discount" <> 0), false, false));
            AddPrintLine(300, 6, NodeName, FieldValue, DSTR1, false, (SalesEntry."Periodic Discount" <> 0), false, false, Tray);

        end;

        PrintItemPOSText(SalesEntry."Item No.", CustLanguageCode, Store."Language Code", SalesEntry."Line No.", Tray);

        TransInfoEntry.SetRange("Store No.", SalesEntry."Store No.");
        TransInfoEntry.SetRange("POS Terminal No.", SalesEntry."POS Terminal No.");
        TransInfoEntry.SetRange("Transaction No.", SalesEntry."Transaction No.");
        TransInfoEntry.SetRange("Transaction Type", TransInfoEntry."Transaction Type"::"Sales Entry");
        TransInfoEntry.SetRange("Line No.", SalesEntry."Line No.");
        PrintTransInfoCode(TransInfoEntry, Tray, false);

    end;

    procedure PrintSalesInfo(var Transaction: Record "LSC Transaction Header"; Tray: Integer)
    var
        TransInfoCode: Record "LSC Trans. Infocode Entry";
        Customer: Record Customer;
        SalesEntry: Record "LSC Trans. Sales Entry";
        Item: Record Item;
        VATSetup: Record "LSC POS VAT Code";
        MixMatchEntry: Record "LSC Trans. Mix & Match Entry";
        PeriodicDiscount: Record "LSC Periodic Discount";
        TransInfoEntry: Record "LSC Trans. Infocode Entry";
        POSTerminal: Record "LSC POS Terminal";
        IncExpEntry: Record "LSC Trans. Inc./Exp. Entry";
        IncExpAcc: Record "LSC Income/Expense Account";
        CompInfo: Record "Company Information";
        ItemVariant: Record "Item Variant";
        Contact: Record Contact;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SalesEntry2: Record "LSC Trans. Sales Entry";
        LinkedItems: Record "LSC Linked Item";
        TransactionOrderEntry: Record "LSC Transaction Order Entry";
        OptTypeValueEntry: Record "LSC Option Type Value Entry";
        TransDiscountEntry: Record "LSC Trans. Discount Entry";
        CouponHeader: Record "LSC Coupon Header";
        ParentItemLine: Record "LSC Trans. Sales Entry";
        ParentItem: Record Item;
        RecipeBufferTEMP: Record "LSC Trans. Sales Entry" temporary;
        RecipeBufferTEMP2: Record "LSC Trans. Sales Entry" temporary;
        RecipeBufferDetailTEMP_l: Record "LSC Trans. Discount Entry" temporary;
        RecipeBufferTransInfoTEMP: Record "LSC Trans. Infocode Entry" temporary;
        RecipeBufferTransInfoTextTEMP: Record "LSC Trans. Infocode Entry" temporary;
        IncomeExpenseAccount: Record "LSC Income/Expense Account";
        VATPostingSetup: Record "VAT Posting Setup";
        RetailSetup: Record "LSC Retail Setup";
        TipsStaff_l: Record "LSC Staff";
        ClientSessionUtility: Codeunit "LSC Client Session Utility";
        FormatAddress: Codeunit "Format Address";
        ItemName: Text[30];
        discText: Text[30];
        DSTR1: Text[100];
        QtyTxt: Text[15];
        LineArr: array[10] of Text[50];
        DSTR2: Text[100];
        DiscountText: Text[80];
        TmpValue: Text[100];
        CustAddr: array[8] of Text[100];
        VATCode: array[5] of Code[10];
        PerDiscOffArr: array[250] of Code[20];
        LastDepartment: Code[10];
        OfferCode, Barcode_ : Code[20];
        VATExtraCharacters: Code[10];
        SalesLineAmount: Decimal;
        SalesAmountVAT: array[5] of Decimal;
        VATPerc: array[5] of Decimal;
        VATAmount: array[5] of Decimal;
        totalCustItemDisc: Decimal;
        PerDiscOffAmtArr: array[250] of Decimal;
        TotalNumberOfItems: Decimal;
        TotalSavings: Decimal;
        TotalAmtForSummary: Decimal;
        DiscountOnBlockPrintOffers: Decimal;
        DiscountOnLine: Decimal;
        LastQuantity: Decimal;
        ItemSoldUOMFactor: Decimal;
        TmpVATPerc: Decimal;
        i: Integer;
        j: Integer;
        PrintItemNo: Integer;
        maxCounter: Integer;
        PerDiscOffArrCount: Integer;
        LineCount: Integer;
        StringLenBeforeSplitLine: Integer;
        NegativeQty: Integer;
        TotalAddrLine: Integer;
        ZALineCount: Integer;
        CheckCopyCount: Integer;
        VATPrinted: Boolean;
        discountSection: Boolean;
        OrderByDepartment: Boolean;
        PrintItem: Boolean;
        CountItemOk: Boolean;
        ThisIsAHospTipsLine: Boolean;
        CompressItemOK: Boolean;
        VATNotSet: Boolean;
        IsHandled: Boolean;
        SkipCollectDiscountInfo: Boolean;
        PrintReturnText: Boolean;
        IncomeExpenseLinePrinted: Boolean;
        Text085: Label 'Customer Discount';
        Text086: Label 'Infocode Discount';
        Text088: Label 'Discount Details';
        Text_DelNot: Label 'DELIVERY';
        Text151: Label 'Number of Items:';
        Text152: Label 'Total Savings:';
        decLSalesAmount: Decimal;
        decLVATAmount: Decimal;
        decLTotalSalesAmount: Decimal;
        recLTransactionHeader: Record "LSC Transaction Header";
        recLVATAmountTemp: Record Item temporary;
    begin

        StringLenBeforeSplitLine := 11;

        DSTR1 := '#T######################################';

        PrintReturnText := true;

        if not IsInvoice then begin
            CheckCopyCount := 0;
            IF Transaction."Sale Is Return Sale" then
                CheckCopyCount := 1;
            if Transaction.GetPrintedCounter(1) > CheckCopyCount then
                PrintCopyText(Tray)
            else
                if bSecondPrintActive then begin
                    DSTR1 := '#C##################';
                    FieldValue[1] := Text046;
                    DSTR1 := '#C' + StringPad('#', LineLen - 2);
                    FieldValue[1] := StringPad('-', LineLen);
                end;
        end;

        PerDiscOffArrCount := 0;
        totalCustItemDisc := 0;

        Clear(TotalNumberOfItems);
        Clear(TotalSavings);

        LineCount := 0;
        Clear(VATCode);
        Clear(VATPerc);
        Clear(VATAmount);
        Clear(SalesAmountVAT);
        Clear(SalesEntry);
        Clear(Value);
        clear(tmpDeal);
        tmpDeal.DeleteAll;
        TmpPrintedSalesEntry.DeleteAll;
        TmpPrintedDealPOSTransLine.DeleteAll;
        recLVATAmountTemp.DeleteAll();
        if GenPosFunc."Print Disc/Cpn Info on Slip" in
         [GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
          GenPosFunc."Print Disc/Cpn Info on Slip"::"Summary information below Sub-total"] then begin
            PeriodicDiscountInfoTEMP.Reset;
            PeriodicDiscountInfoTEMP.DeleteAll;
            Subtotal := 0;
        end;
        TotalAmt := 0;
        TipsAmount1 := 0;
        TipsText1 := '';
        TipsAmount2 := 0;
        TipsText2 := '';
        if LocalizationExt.IsNALocalizationEnabled then begin
            Clear(BreakdownLabel);
            Clear(BreakdownAmt);
            TempSalesLine.Reset;
            TempSalesLine.DeleteAll;
        end;
        glTrans := Transaction;
        //ditoo 10/15/2024
        SalesEntry.SetRange("Store No.", Transaction."Store No.");
        SalesEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        SalesEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        OrderByDepartment := GenPosFunc."Receipt Printing by Category";
        if OrderByDepartment then
            SalesEntry.SetCurrentKey("Item Category Code");
        if SalesEntry.FindSet() then begin

            DSTR1 := '#L############### #R#################'; // Description    Amount
            FieldValue[1] := Text071;
            FieldValue[2] := Text004;
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
            cduSender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
            PrintSeperator(Tray);

            PrintItemNo := 0;
            if POSTerminal.Get(SalesEntry."POS Terminal No.") then
                if POSTerminal."Receipt Setup Location" = POSTerminal."Receipt Setup Location"::Store then begin
                    case Store."Item No. on Receipt" of
                        Store."Item No. on Receipt"::"Item Number":
                            PrintItemNo := 1;
                        Store."Item No. on Receipt"::"Barcode/Item Number":
                            PrintItemNo := 2;
                    end;
                end else begin
                    case POSTerminal."Item No. on Receipt" of
                        POSTerminal."Item No. on Receipt"::"Item Number":
                            PrintItemNo := 1;
                        POSTerminal."Item No. on Receipt"::"Barcode/Item Number":
                            PrintItemNo := 2;
                    end;
                end;
            PrintItemNo := 2;
            LastDepartment := '';
            RecipeBufferTEMP.Reset;
            RecipeBufferTEMP.DeleteAll;
            RecipeBufferDetailTEMP_l.Reset;
            RecipeBufferDetailTEMP_l.DeleteAll;
            RecipeBufferTEMP2.Reset;
            RecipeBufferTEMP2.DeleteAll;
            RecipeBufferTransInfoTEMP.Reset;
            RecipeBufferTransInfoTEMP.DeleteAll;
            RecipeBufferTransInfoTextTEMP.Reset;
            RecipeBufferTransInfoTextTEMP.DeleteAll;
            repeat
                if not SalesEntry."System-Exclude From Print" then begin

                    Clear(Item);
                    if Item.Get(SalesEntry."Item No.") then;

                    if SalesEntry."Parent Line No." = 0 then begin
                        ParentItem := Item;
                        ParentItemLine := SalesEntry;
                    end;

                    SkipCollectDiscountInfo := false;
                    //All lines except deal lines are put into recipe-item buffer. For cases where lines must not be compressed, CompresItemOK is set as false
                    CompressItemOK := true;
                    if ParentItem."LSC Skip Compr. When Printed" then
                        CompressItemOK := false;
                    if not (SalesEntry."Orig. from Infocode" <> '') and (SalesEntry."Parent Line No." <> 0) then begin
                        if SalesEntry."Price Change" then
                            CompressItemOK := false;
                        if SalesEntry."Scale Item" then
                            CompressItemOK := false;
                        if SalesEntry."Price in Barcode" then
                            CompressItemOK := false;
                        if SalesEntry.Quantity > 0 then begin
                            CompressItemOK := false;
                            NegativeQty += 1;
                        end;
                        if LastQuantity = 0 then
                            LastQuantity := SalesEntry.Quantity;
                        if (LastQuantity <> 0) and ((LastQuantity < 0) or (SalesEntry.Quantity < 0)) and (NegativeQty <> 0) then begin
                            CompressItemOK := false;
                            LastQuantity := 0;
                        end;
                    end;
                    if (not SalesEntry."Deal Line") then
                        InsertIntoRecipeBuffer(
                          SalesEntry, RecipeBufferTEMP, RecipeBufferTEMP2, ParentItemLine, RecipeBufferDetailTEMP_l,
                          RecipeBufferTransInfoTEMP, RecipeBufferTransInfoTextTEMP, CompressItemOK);

                    if POSTerminal."Print Total Savings" then begin
                        TotalSavings := TotalSavings + SalesEntry."Discount Amount";
                    end;

                    if POSTerminal."Print Number of Items" then begin
                        if (SalesEntry.Quantity < 0) then begin
                            CountItemOk := true;
                            if SalesEntry."Linked No. not Orig." then begin
                                SalesEntry2.Reset;
                                SalesEntry2.CopyFilters(SalesEntry);
                                if SalesEntry2.Find('-') then begin
                                    repeat
                                        if (SalesEntry2."Item No." <> SalesEntry."Item No.") and SalesEntry2."Orig. of a Linked Item List" then begin
                                            LinkedItems.Reset;
                                            LinkedItems.SetRange("Item No.", SalesEntry2."Item No.");
                                            LinkedItems.SetRange("Linked Item No.", SalesEntry."Item No.");
                                            LinkedItems.SetFilter("Sales Type", '%1|%2', '', Transaction."Sales Type");
                                            if LinkedItems.FindFirst then begin
                                                if LinkedItems."Deposit Item" then
                                                    CountItemOk := false;
                                            end;
                                        end;
                                    until (SalesEntry2.Next = 0) or not CountItemOk;
                                end;
                            end;

                            if CountItemOk then begin
                                if ItemUnitOfMeasure.Get(SalesEntry."Item No.", SalesEntry."Unit of Measure") then begin
                                    if ItemUnitOfMeasure."LSC Count as 1 on Receipt" then
                                        TotalNumberOfItems := TotalNumberOfItems + 1
                                    else
                                        TotalNumberOfItems := TotalNumberOfItems + Abs(SalesEntry.Quantity);
                                end else
                                    TotalNumberOfItems := TotalNumberOfItems + Abs(SalesEntry.Quantity);
                            end;
                        end;
                    end;

                    if SalesEntry."Deal Line" then begin
                        PrintDeal(SalesEntry, Tray, PrintItemNo);
                        CollectDiscInfo(SalesEntry, Tray, TotalAmt, Subtotal, PeriodicDiscountInfoTEMP);
                        if GenPosFunc."Print Disc/Cpn Info on Slip" = GenPosFunc."Print Disc/Cpn Info on Slip"::"No printing" then
                            if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                                SalesLineAmount := SalesEntry."Net Amount"
                            else
                                SalesLineAmount := SalesEntry."Net Amount" + SalesEntry."VAT Amount"
                        else
                            if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                                SalesLineAmount := SalesEntry."Net Amount" - SalesEntry."Discount Amount"
                            else
                                SalesLineAmount := SalesEntry."Net Amount" + SalesEntry."VAT Amount" - SalesEntry."Discount Amount";
                        if GenPosFunc."Print Disc/Cpn Info on Slip" = GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line" then
                            TotalAmt := TotalAmt + SalesLineAmount
                        else
                            if GenPosFunc."Print Disc/Cpn Info on Slip" = GenPosFunc."Print Disc/Cpn Info on Slip"::"No printing" then
                                TotalAmt := TotalAmt + SalesLineAmount;
                        //***************************************** normal line, not deal line printed with recipe-item buffer
                    end else begin
                        if not SkipCollectDiscountInfo then begin
                            CollectDiscInfo(SalesEntry, Tray, TotalAmt, Subtotal, PeriodicDiscountInfoTEMP);
                        end;
                    end;

                    totalCustItemDisc := totalCustItemDisc + SalesEntry."Infocode Discount";

                    if not SkipCollectDiscountInfo then begin
                        i := 0;
                        j := 0;
                        VATNotSet := true;
                        if SalesEntry."Net Amount" > 0 then begin
                            if (SalesEntry."VAT Bus. Posting Group" <> '') and (SalesEntry."VAT Prod. Posting Group" <> '') then
                                if VATPostingSetup.Get(SalesEntry."VAT Bus. Posting Group", SalesEntry."VAT Prod. Posting Group") then
                                    if VATSetup.Get(VATPostingSetup."LSC POS Terminal VAT Code") then
                                        VATNotSet := false;
                            if not VATNotSet and Item.Get(SalesEntry."Item No.") then
                                if VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then
                                    if VATSetup.Get(VATPostingSetup."LSC POS Terminal VAT Code") then
                                        VATNotSet := false;
                        end;
                        if VATNotSet then
                            if VATSetup.Get(SalesEntry."VAT Code") then
                                VATNotSet := false;
                        if (VATSetup."VAT Code" <> '') and not VATNotSet then begin
                            repeat
                                i := i + 1;
                                if j = 0 then
                                    if VATCode[i] = '' then
                                        j := i;
                            until (VATCode[i] = VATSetup."VAT Code") or (i >= 5);
                            if VATCode[i] <> VATSetup."VAT Code" then begin
                                i := j;
                                VATPerc[i] := VATSetup."VAT %";
                                VATCode[i] := VATSetup."VAT Code";
                            end;
                            VATAmount[i] := VATAmount[i] + SalesEntry."VAT Amount";
                            SalesAmountVAT[i] := SalesAmountVAT[i] + SalesEntry."Net Amount" + SalesEntry."VAT Amount";
                        end;

                        IF SalesEntry."Local VAT Code" = '' then begin
                            IF (SalesEntry."VAT Code" <> '') THEN BEGIN
                                CLEAR(recLVATAmountTemp);
                                IF NOT recLVATAmountTemp.GET(SalesEntry."VAT Code") THEN BEGIN
                                    recLVATAmountTemp.INIT();
                                    recLVATAmountTemp."No." := SalesEntry."VAT Code";
                                    recLVATAmountTemp."Unit Price" := SalesEntry."VAT Amount";
                                    if SalesEntry."VAT Code" = 'VE' then begin//VINCENT20260106
                                        recLVATAmountTemp."Unit Price Incl. VAT" := -SalesEntry."Net Amount" + SalesEntry."Discount Amount";//- SalesEntry."Total Discount";
                                    end else begin
                                        recLVATAmountTemp."Unit Price Incl. VAT" := (-SalesEntry."Net Amount" + SalesEntry."Discount Amount") + SalesEntry."VAT Amount";
                                    end;
                                    recLVATAmountTemp.INSERT();
                                END ELSE BEGIN
                                    recLVATAmountTemp."No." := SalesEntry."VAT Code";
                                    recLVATAmountTemp."Unit Price" := recLVATAmountTemp."Unit Price" + SalesEntry."VAT Amount";
                                    recLVATAmountTemp."Unit Price Incl. VAT" += SalesEntry."Net Amount";
                                    recLVATAmountTemp.MODIFY();
                                END;
                            END;
                        end else begin
                            CLEAR(recLVATAmountTemp);
                            IF NOT recLVATAmountTemp.GET('VZ') THEN BEGIN
                                recLVATAmountTemp.INIT();
                                recLVATAmountTemp."No." := 'VZ';
                                recLVATAmountTemp."Unit Price" := SalesEntry."VAT Amount";
                                recLVATAmountTemp."Unit Price Incl. VAT" := SalesEntry."Net Amount" - SalesEntry."Total Discount";
                                recLVATAmountTemp.INSERT();
                            END ELSE BEGIN
                                recLVATAmountTemp."No." := 'VZ';
                                recLVATAmountTemp."Unit Price" := recLVATAmountTemp."Unit Price" + SalesEntry."VAT Amount";
                                recLVATAmountTemp."Unit Price Incl. VAT" += SalesEntry."Net Amount";
                                recLVATAmountTemp.MODIFY();
                            END;
                        end;

                        LineCount := LineCount + 1;
                    end;
                end;
            until SalesEntry.Next = 0;
        end;

        RecipeBufferTEMP.Reset;
        RecipeBufferTEMP2.Reset;
        RecipeBufferTEMP.SetRange("Parent Line No.", 0);
        if OrderByDepartment then
            RecipeBufferTEMP.SetCurrentKey("Item Category Code");
        if RecipeBufferTEMP.FindSet() then
            repeat
                VATExtraCharacters := '';
                if OrderByDepartment and (RecipeBufferTEMP."Item Category Code" <> LastDepartment) then begin
                    DSTR1 := '#L######################################';
                    FieldValue[1] := RecipeBufferTEMP."Item Category Code";
                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, true, false, false));
                    LastDepartment := RecipeBufferTEMP."Item Category Code";
                end;

                DiscountOnLine := 0;
                if GenPosFunc."Print Disc/Cpn Info on Slip" in
                [GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line",
                GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
                GenPosFunc."Print Disc/Cpn Info on Slip"::"Summary information below Sub-total"] then begin
                    DiscountOnLine := -RecipeBufferTEMP."Discount Amount";
                end;

                ItemName := GetItemName(RecipeBufferTEMP."Item No.", RecipeBufferTEMP."Variant Code", Customer."Language Code", Store."Language Code");

                if (Abs(RecipeBufferTEMP.Quantity) <> 1) or
                ((RecipeBufferTEMP."UOM Quantity" <> 0) and (Abs(RecipeBufferTEMP."UOM Quantity") <> 1)) or
                RecipeBufferTEMP."Scale Item" or               //details always printed.
                RecipeBufferTEMP."Price in Barcode"
                then begin
                    DSTR1 := '#L######################################';
                    FieldValue[1] := ItemName;
                    NodeName[1] := 'Item Description';
                    FieldValue[2] := Format(RecipeBufferTEMP."Line No.");
                    NodeName[2] := 'Line No.';
                    FieldValue[3] := RecipeBufferTEMP."Item No.";
                    NodeName[3] := 'Item No.';
                    FieldValue[4] := RecipeBufferTEMP."Variant Code";
                    NodeName[4] := 'Variant Code';
                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                    AddPrintLine(300, 4, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

                    Clear(Value);

                    //DSTR1 := ' #L################### #N############ #R';
                    DSTR1 := '#L################### #N############# #R'; //ditoo
                    if RecipeBufferTEMP."Scale Item" or RecipeBufferTEMP."Price in Barcode" then begin
                        if RecipeBufferTEMP."Weight Manually Entered" then
                            DSTR1 := 'MAN #L################## #N########## #R';
                        if ClientSessionUtility.FindLocalizedVersion = 'AU' then
                            FieldValue[1] := 'Net' + ' ';
                        FieldValue[1] :=
                        FieldValue[1] + MyPOSFunctions.FormatWeight(-RecipeBufferTEMP.Quantity, RecipeBufferTEMP."Unit of Measure")
                                 + GenPosFunc.GetMultipleItemsSymbol();
                        TmpValue := MyPOSFunctions.FormatPricePrUnit(RecipeBufferTEMP.Price, RecipeBufferTEMP."Unit of Measure");
                        if Item.Get(RecipeBufferTEMP."Item No.") then
                            if RecipeBufferTEMP."Unit of Measure" <> Item."Base Unit of Measure" then begin
                                ItemSoldUOMFactor := 0;
                                if ItemUnitOfMeasure.Get(RecipeBufferTEMP."Item No.", RecipeBufferTEMP."Unit of Measure") then
                                    ItemSoldUOMFactor := ItemUnitOfMeasure."Qty. per Unit of Measure";
                                if (ItemSoldUOMFactor <> 1) and (ItemSoldUOMFactor <> 0) then begin
                                    FieldValue[1] := MyPOSFunctions.FormatWeight(-RecipeBufferTEMP.Quantity / ItemSoldUOMFactor, RecipeBufferTEMP."Unit of Measure")
                                    + GenPosFunc.GetMultipleItemsSymbol();
                                    TmpValue := MyPOSFunctions.FormatPricePrUnit(RecipeBufferTEMP.Price * ItemSoldUOMFactor, RecipeBufferTEMP."Unit of Measure");
                                end;
                            end;
                        if StrLen(TmpValue) > StringLenBeforeSplitLine then begin
                            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, (RecipeBufferTEMP."Periodic Discount" <> 0), false, false));
                            FieldValue[1] := TmpValue;
                        end else
                            FieldValue[1] := FieldValue[1] + TmpValue;

                    end else begin
                        if RecipeBufferTEMP."Unit of Measure" = '' then
                            RecipeBufferTEMP."Unit of Measure" := Text131;
                        if RecipeBufferTEMP."UOM Quantity" <> 0 then begin
                            RecipeBufferTEMP.Quantity := RecipeBufferTEMP."UOM Quantity";
                            RecipeBufferTEMP.Price := RecipeBufferTEMP."UOM Price";
                        end;
                        FieldValue[1] :=
                        //POSFunctions.FormatQty(-RecipeBufferTEMP.Quantity) + ' ' + LowerCase(RecipeBufferTEMP."Unit of Measure") + GenPosFunc.GetMultipleItemsSymbol();
                        POSFunctions.FormatQty(-RecipeBufferTEMP.Quantity) + LowerCase(RecipeBufferTEMP."Unit of Measure") + GenPosFunc.GetMultipleItemsSymbol();
                        FieldValue[1] := FieldValue[1] + POSFunctions.FormatPrice(RecipeBufferTEMP.Price);//+ RecipeBufferTEMP."VAT Amount"
                    end;
                    //Message('%1\n%2\n%3\n%4\n%5\n%6',FieldValue[1],FieldValue[2],FieldValue[3],FieldValue[4],FieldValue[5],FieldValue[6]);// ditoo

                    NodeName[1] := 'x';
                    if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                        FieldValue[2] := POSFunctions.FormatAmount(-(RecipeBufferTEMP."Net Amount" + DiscountOnLine))
                    else
                        FieldValue[2] := POSFunctions.FormatAmount(-(RecipeBufferTEMP."Net Amount" + RecipeBufferTEMP."VAT Amount" + DiscountOnLine));
                    NodeName[2] := 'Amount';
                    if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then begin
                        if RecipeBufferTEMP."VAT Amount" <> 0 then begin
                            FieldValue[3] := 'T';
                            NodeName[3] := 'VAT Code';
                        end else begin
                            FieldValue[3] := 'N';
                            NodeName[3] := 'VAT Code';
                        end;
                    end else begin
                        IF (RecipeBufferTEMP."Local VAT Code" <> '') then
                            FieldValue[3] := RecipeBufferTEMP."Local VAT Code"
                        else
                            FieldValue[3] := RecipeBufferTEMP."VAT Code";
                        NodeName[3] := 'VAT Code';
                        if (StrLen(RecipeBufferTEMP."VAT Code") > 2) then
                            VATExtraCharacters := CopyStr(RecipeBufferTEMP."VAT Code", 3, 8);
                    end;
                    FieldValue[4] := Format(RecipeBufferTEMP."Line No.");
                    NodeName[4] := 'Line No.';
                    FieldValue[5] := RecipeBufferTEMP."Unit of Measure";
                    NodeName[5] := 'UOM ID';
                    FieldValue[6] := POSFunctions.FormatQty(-RecipeBufferTEMP.Quantity);
                    NodeName[6] := 'Quantity';
                    FieldValue[7] := POSFunctions.FormatPrice(RecipeBufferTEMP.Price);
                    NodeName[7] := 'Price';

                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, (RecipeBufferTEMP."Periodic Discount" <> 0), false, false));
                    AddPrintLine(300, 7, NodeName, FieldValue, DSTR1, false, (RecipeBufferTEMP."Periodic Discount" <> 0), false, false, Tray);
                    if VATExtraCharacters <> '' then begin
                        DSTR1 := '                              #R########';
                        Clear(Value);
                        FieldValue[1] := VATExtraCharacters;
                        NodeName[1] := 'VAT Code';
                        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, (RecipeBufferTEMP."Periodic Discount" <> 0), false, false));
                    end;
                end
                else begin
                    DSTR1 := '#L###################### #N########## #R';//*****
                    FieldValue[1] := ItemName;
                    if RecipeBufferTEMP."Unit of Measure" <> '' then
                        FieldValue[1] := FieldValue[1] + ' ' + LowerCase(RecipeBufferTEMP."Unit of Measure");
                    NodeName[1] := 'x';
                    if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                        FieldValue[2] := POSFunctions.FormatAmount(-(RecipeBufferTEMP."Net Amount" + DiscountOnLine))//VINCENT20260106
                    else
                        If (Transaction."Transaction Code Type" <> Transaction."Transaction Code Type"::REG) AND (Transaction."Transaction Code Type" <> Transaction."Transaction Code Type"::"Regular Customer") then begin
                            FieldValue[2] := POSFunctions.FormatAmount(-(RecipeBufferTEMP."Net Amount" + DiscountOnLine));
                        end else
                            FieldValue[2] := POSFunctions.FormatAmount(-(RecipeBufferTEMP."Net Amount" + RecipeBufferTEMP."VAT Amount"));
                    NodeName[2] := 'Amount';
                    if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then begin
                        if RecipeBufferTEMP."VAT Amount" <> 0 then begin
                            FieldValue[3] := 'T';
                            NodeName[3] := 'VAT Code';
                        end else begin
                            FieldValue[3] := 'N';
                            NodeName[3] := 'VAT Code';
                        end;
                    end else begin
                        IF (RecipeBufferTEMP."Local VAT Code" <> '') then
                            FieldValue[3] := RecipeBufferTEMP."Local VAT Code"
                        else
                            FieldValue[3] := RecipeBufferTEMP."VAT Code";
                        NodeName[3] := 'VAT Code';
                        if (StrLen(RecipeBufferTEMP."VAT Code") > 2) then
                            VATExtraCharacters := CopyStr(RecipeBufferTEMP."VAT Code", 3, 8);
                    end;
                    FieldValue[4] := Format(RecipeBufferTEMP."Line No.");
                    NodeName[4] := 'Line No.';
                    FieldValue[5] := ItemName;
                    NodeName[5] := 'Item Description';
                    FieldValue[6] := RecipeBufferTEMP."Unit of Measure";
                    NodeName[6] := 'UOM ID';
                    FieldValue[7] := POSFunctions.FormatQty(-RecipeBufferTEMP.Quantity);
                    NodeName[7] := 'Quantity';
                    FieldValue[8] := POSFunctions.FormatPrice(RecipeBufferTEMP.Price);
                    NodeName[8] := 'Price';
                    FieldValue[9] := RecipeBufferTEMP."Item No.";
                    NodeName[9] := 'Item No.';
                    FieldValue[10] := RecipeBufferTEMP."Variant Code";
                    NodeName[10] := 'Variant Code';
                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, (RecipeBufferTEMP."Periodic Discount" <> 0), false, false));
                    AddPrintLine(300, 10, NodeName, FieldValue, DSTR1, false, (RecipeBufferTEMP."Periodic Discount" <> 0), false, false, Tray);
                    if VATExtraCharacters <> '' then begin
                        DSTR1 := '                              #R########';
                        Clear(Value);
                        FieldValue[1] := VATExtraCharacters;
                        NodeName[1] := 'VAT Code';
                        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, (RecipeBufferTEMP."Periodic Discount" <> 0), false, false));
                    end;
                end;

                if GenPosFunc."Print Free Text on Receipt" then
                    PrintFreeTextLinesFromBuffer(RecipeBufferTEMP, RecipeBufferTransInfoTextTEMP, Tray, false);

                PrintItemPOSText(RecipeBufferTEMP."Item No.", Customer."Language Code", Store."Language Code", RecipeBufferTEMP."Line No.", Tray);

                RecipeBufferTransInfoTEMP.SetRange("Store No.", Transaction."Store No.");
                RecipeBufferTransInfoTEMP.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
                RecipeBufferTransInfoTEMP.SetRange("Transaction No.", Transaction."Transaction No.");
                RecipeBufferTransInfoTEMP.SetRange("Transaction Type", RecipeBufferTransInfoTEMP."Transaction Type"::"Sales Entry");
                RecipeBufferTransInfoTEMP.SetRange("Line No.", RecipeBufferTEMP."Line No.");
                PrintTransInfoCode(RecipeBufferTransInfoTEMP, Tray, false);

                if GenPosFunc."Print Disc/Cpn Info on Slip" in
                [GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
                GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line"]
                then begin

                    RecipeBufferDetailTEMP_l.Reset;
                    RecipeBufferDetailTEMP_l.SetRange("Store No.", RecipeBufferTEMP."Store No.");
                    RecipeBufferDetailTEMP_l.SetRange("POS Terminal No.", RecipeBufferTEMP."POS Terminal No.");
                    RecipeBufferDetailTEMP_l.SetRange("Transaction No.", RecipeBufferTEMP."Transaction No.");
                    RecipeBufferDetailTEMP_l.SetRange(RecipeLineNo, RecipeBufferTEMP."Line No.");
                    if RecipeBufferDetailTEMP_l.FindSet then
                        repeat

                            if RecipeBufferDetailTEMP_l."Offer Type" = RecipeBufferDetailTEMP_l."Offer Type"::Line then begin

                                case Transaction."Transaction Code Type" OF
                                    Transaction."Transaction Code Type"::"SC":
                                        DiscountText := 'Senior Disc.';
                                    Transaction."Transaction Code Type"::PWD:
                                        DiscountText := 'PWD Disc.';
                                    Transaction."Transaction Code Type"::SOLO:
                                        DiscountText := 'SOLO Disc.';
                                    Transaction."Transaction Code Type"::ATHL:
                                        DiscountText := 'Athlete Discount';
                                    // Transaction."Transaction Code Type"::MOV:
                                    //     DiscountText := 'MOV Disc.';
                                    // Transaction."Transaction Code Type"::NAAC:
                                    //     DiscountText := 'NAAC Discount';
                                    Transaction."Transaction Code Type"::"Regular Customer", Transaction."Transaction Code Type"::REG,
                                                Transaction."Transaction Code Type"::VATW, Transaction."Transaction Code Type"::WHT1,
                                                Transaction."Transaction Code Type"::ZRWH,
                                                Transaction."Transaction Code Type"::ZERO:
                                        begin
                                            DiscountText := Text084;
                                        end;
                                end;
                            end else
                                DiscountText := Format(RecipeBufferDetailTEMP_l."Offer Type");
                            Clear(PeriodicDiscount);
                            if RecipeBufferDetailTEMP_l."Offer Type" = RecipeBufferDetailTEMP_l."Offer Type"::Coupon then begin
                                if CouponHeader.Get(RecipeBufferDetailTEMP_l."Offer No.") then
                                    DiscountText := CouponHeader.Description;
                            end else

                                IF PeriodicDiscount.GET(RecipeBufferDetailTEMP_l."Offer No.") THEN BEGIN //ORIG
                                    DiscountText := PeriodicDiscount.Description; //ORIG

                                END ELSE BEGIN //ORIG

                                    IF Transaction."Customer Type" = Transaction."Customer Type"::" " THEN BEGIN

                                        CASE RecipeBufferDetailTEMP_l."Offer Type" OF //ORIG
                                            RecipeBufferDetailTEMP_l."Offer Type"::Total:
                                                DiscountText := Text024; //ORIG
                                            RecipeBufferDetailTEMP_l."Offer Type"::Line:
                                                DiscountText := Text084; //ORIG
                                            ELSE //ORIG
                                                DiscountText := FORMAT(RecipeBufferDetailTEMP_l."Offer Type"); //ORIG
                                        END; //ORIG
                                    END ELSE BEGIN

                                        IF Transaction."Customer Type" = Transaction."Customer Type"::"Senior Citizen" THEN BEGIN
                                            DiscountText := 'Senior Discount';
                                        END;
                                        IF Transaction."Customer Type" = Transaction."Customer Type"::PWD THEN BEGIN
                                            DiscountText := 'PWD Discount';
                                        END;
                                        IF Transaction."Customer Type" = Transaction."Customer Type"::ATHL THEN BEGIN
                                            DiscountText := 'ATHL Discount';
                                        END;
                                        IF Transaction."Customer Type" = Transaction."Customer Type"::"Solo Parent" THEN BEGIN
                                            DiscountText := 'SOLO Discount';
                                        END;
                                        // IF Transaction."Customer Type" = Transaction."Customer Type"::MOV THEN BEGIN
                                        //     DiscountText := 'MOV Discount';
                                        // END;
                                        // IF Transaction."Customer Type" = Transaction."Customer Type"::NAAC THEN BEGIN
                                        //     DiscountText := 'NAAC Discount';
                                        // END;
                                    END;
                                    IF DiscountText = '' THEN BEGIN
                                        DiscountText := FORMAT(RecipeBufferDetailTEMP_l."Offer Type");
                                    END;

                                END;
                            DiscountText := ConvertStr(DiscountText, '&', '+');
                            if not PeriodicDiscount."Block Printing" then begin
                                if not RecipeBufferTEMP."Deal Line" then begin
                                    if RecipeBufferDetailTEMP_l."Discount Amount" <> 0 then begin
                                        if not ((RecipeBufferDetailTEMP_l."Offer Type" = RecipeBufferDetailTEMP_l."Offer Type"::Total) and
                                        (GenPosFunc."Print Disc/Cpn Info on Slip" =
                                        GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total")) then begin
                                            DSTR2 := '   #L################# #N############   ';
                                            FieldValue[1] := DiscountText;
                                            NodeName[1] := 'Detail Text';
                                            FieldValue[2] := POSFunctions.FormatAmount(-RecipeBufferDetailTEMP_l."Discount Amount");
                                            NodeName[2] := 'Detail Amount';
                                            FieldValue[3] := Format(RecipeBufferTEMP."Line No.");
                                            NodeName[3] := 'Line No.';
                                            case Transaction."Transaction Code Type" OF
                                                Transaction."Transaction Code Type"::"Regular Customer", Transaction."Transaction Code Type"::REG,
                                                    Transaction."Transaction Code Type"::VATW, Transaction."Transaction Code Type"::WHT1,
                                                    Transaction."Transaction Code Type"::ZRWH, Transaction."Transaction Code Type"::ZERO,
                                                    Transaction."Transaction Code Type"::ATHL, Transaction."Transaction Code Type"::SOLO,
                                                    Transaction."Transaction Code Type"::"SC",
                                                    Transaction."Transaction Code Type"::PWD, Transaction."Transaction Code Type"::ONLINE:
                                                    begin
                                                        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR2), false, false, false, false));
                                                        cduSender.AddPrintLine(360, 4, NodeName, FieldValue, DSTR2, false, false, false, false, Tray);
                                                    end;
                                            END;
                                        end;
                                    end;
                                    if RecipeBufferDetailTEMP_l.Points <> 0 then begin
                                        DSTR2 := '   #L################# #N############   ';
                                        FieldValue[1] := DiscountText;
                                        NodeName[1] := 'Detail Text';
                                        FieldValue[2] := POSFunctions.FormatAmount(RecipeBufferDetailTEMP_l.Points) + ' ' + Text232;
                                        NodeName[2] := 'x';
                                        FieldValue[3] := Format(RecipeBufferTEMP."Line No.");
                                        NodeName[3] := 'Line No.';
                                        FieldValue[4] := POSFunctions.FormatAmount(RecipeBufferDetailTEMP_l.Points);
                                        NodeName[4] := 'Detail Amount';
                                        case Transaction."Transaction Code Type" OF
                                            Transaction."Transaction Code Type"::"Regular Customer", Transaction."Transaction Code Type"::REG,
                                                Transaction."Transaction Code Type"::VATW, Transaction."Transaction Code Type"::WHT1,
                                                Transaction."Transaction Code Type"::ZRWH, Transaction."Transaction Code Type"::ZERO,
                                                Transaction."Transaction Code Type"::ATHL, Transaction."Transaction Code Type"::SOLO,
                                                Transaction."Transaction Code Type"::"SC",
                                                Transaction."Transaction Code Type"::PWD, Transaction."Transaction Code Type"::ONLINE:
                                                begin
                                                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR2), false, false, false, false));
                                                    cduSender.AddPrintLine(360, 4, NodeName, FieldValue, DSTR2, false, false, false, false, Tray);
                                                end;
                                        END;
                                    end;
                                end;
                            end;
                        until RecipeBufferDetailTEMP_l.Next = 0;
                end;

                RecipeBufferTEMP2.SetRange("Parent Line No.", RecipeBufferTEMP."Line No.");
                if RecipeBufferTEMP2.FindSet then
                    repeat
                        ItemName := GetItemName(RecipeBufferTEMP2."Item No.", RecipeBufferTEMP2."Variant Code", Customer."Language Code", Store."Language Code");

                        DSTR1 := '#L######################################';
                        FieldValue[1] := ItemName;
                        NodeName[1] := 'Item Description';
                        FieldValue[2] := Format(RecipeBufferTEMP2."Line No.");
                        NodeName[2] := 'Line No.';
                        FieldValue[3] := RecipeBufferTEMP2."Item No.";
                        NodeName[3] := 'Item No.';
                        FieldValue[4] := RecipeBufferTEMP2."Variant Code";
                        NodeName[4] := 'Variant Code';
                        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                        AddPrintLine(300, 4, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                        if RecipeBufferTEMP2."Unit of Measure" = '' then
                            RecipeBufferTEMP2."Unit of Measure" := Text131;
                        if RecipeBufferTEMP2."UOM Quantity" <> 0 then begin
                            RecipeBufferTEMP2.Quantity := RecipeBufferTEMP2."UOM Quantity";
                            RecipeBufferTEMP2.Price := RecipeBufferTEMP2."UOM Price";
                        end;
                        DSTR1 := '#L###################### #N########## #R';
                        FieldValue[1] :=
                        POSFunctions.FormatQty(-RecipeBufferTEMP2.Quantity) + ' ' + LowerCase(RecipeBufferTEMP2."Unit of Measure") + GenPosFunc.GetMultipleItemsSymbol();
                        FieldValue[1] := FieldValue[1] + POSFunctions.FormatPrice(RecipeBufferTEMP2.Price);
                        NodeName[1] := 'x';
                        if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                            FieldValue[2] := POSFunctions.FormatAmount(-(RecipeBufferTEMP2."Net Amount"))
                        else
                            FieldValue[2] := POSFunctions.FormatAmount(-(RecipeBufferTEMP2."Net Amount" + RecipeBufferTEMP2."VAT Amount"));
                        NodeName[2] := 'Amount';
                        FieldValue[3] := RecipeBufferTEMP2."VAT Code";
                        NodeName[3] := 'VAT Code';
                        FieldValue[4] := Format(RecipeBufferTEMP2."Line No.");
                        NodeName[4] := 'Line No.';
                        FieldValue[5] := RecipeBufferTEMP2."Unit of Measure";
                        NodeName[5] := 'UOM ID';
                        FieldValue[6] := POSFunctions.FormatQty(-RecipeBufferTEMP2.Quantity);
                        NodeName[6] := 'Quantity';
                        FieldValue[7] := POSFunctions.FormatPrice(RecipeBufferTEMP2.Price);
                        NodeName[7] := 'Price';
                        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, (RecipeBufferTEMP2."Periodic Discount" <> 0), false, false));
                        AddPrintLine(300, 7, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                    until RecipeBufferTEMP2.Next = 0;
            until RecipeBufferTEMP.Next = 0;

        if LineCount > 0 then
            PrintSeperator(Tray);

        if (not Globals.UseSalesTax) or (not LocalizationExt.IsNALocalizationEnabled) then begin
            if totalCustItemDisc <> 0 then begin
                DSTR1 := '#L################# #R###############   ';
                FieldValue[1] := Text086;
                NodeName[1] := 'Total Text';
                FieldValue[2] := POSFunctions.FormatAmount(totalCustItemDisc);
                NodeName[2] := 'Total Amount';
                cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                AddPrintLine(600, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            end;

            if Transaction."Customer Discount" <> 0 then begin
                DSTR1 := '#L################# #R###############   ';
                FieldValue[1] := Text085;
                NodeName[1] := 'Total Text';
                FieldValue[2] := POSFunctions.FormatAmount(-Transaction."Customer Discount");
                NodeName[2] := 'Total Amount';
                cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                AddPrintLine(600, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            end;

            if (totalCustItemDisc <> 0) or (Transaction."Customer Discount" <> 0) then
                PrintSeperator(Tray);
        end;

        IncExpEntry.SetRange("Store No.", Transaction."Store No.");
        IncExpEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
        IncExpEntry.SetRange("Transaction No.", Transaction."Transaction No.");
        if IncExpEntry.FindSet() then begin
            repeat
                if not IncExpEntry."System-Exclude From Print" then begin

                    IncomeExpenseLinePrinted := true;

                    IncExpAcc.Get(IncExpEntry."Store No.", IncExpEntry."No.");
                    if (IncExpAcc."Gratuity Type" = IncExpAcc."Gratuity Type"::Tips) and
                    (IncExpAcc."Account Type" = IncExpAcc."Account Type"::Expense)
                    then begin
                        if not (TipsStaff_l.Get(IncExpEntry."Staff ID")) then
                            TipsStaff_l."Name on Receipt" := IncExpEntry."Staff ID";
                        IncExpAcc.Description :=
                        CopyStr(IncExpAcc.Description + ' ' + TipsStaff_l."Name on Receipt", 1, MaxStrLen(IncExpAcc.Description));
                    end;

                    DSTR1 := '#L#################### #N############';
                    FieldValue[1] := IncExpAcc.Description;
                    NodeName[1] := 'Inc./Exp. Description';
                    if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                        FieldValue[2] := POSFunctions.FormatAmount(-IncExpEntry."Net Amount")
                    else
                        FieldValue[2] := POSFunctions.FormatAmount(-IncExpEntry.Amount);
                    NodeName[2] := 'Amount';
                    FieldValue[3] := IncExpEntry."VAT Code";
                    NodeName[3] := 'VAT Code';
                    FieldValue[4] := Format(IncExpEntry."Line No.");
                    NodeName[4] := 'Line No.';
                    FieldValue[5] := IncExpEntry."No.";
                    NodeName[5] := 'Income/Expense No.';
                    DSTR1 := '#L#################### #N############ #R';
                    if IncExpEntry."VAT Code" <> '' then begin
                        i := 0;
                        j := 0;
                        if VATSetup.Get(IncExpEntry."VAT Code") then begin
                            repeat
                                i := i + 1;
                                if j = 0 then
                                    if VATCode[i] = '' then
                                        j := i;
                            until (VATCode[i] = VATSetup."VAT Code") or (i >= 5);
                            if VATCode[i] <> VATSetup."VAT Code" then begin
                                i := j;
                                VATPerc[i] := VATSetup."VAT %";
                                VATCode[i] := VATSetup."VAT Code";
                            end;
                            VATAmount[i] := VATAmount[i] + IncExpEntry."VAT Amount";
                            if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                                SalesAmountVAT[i] := SalesAmountVAT[i] + IncExpEntry."Net Amount"
                            else
                                SalesAmountVAT[i] := SalesAmountVAT[i] + IncExpEntry.Amount;
                        end;
                    end;
                    if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                        TotalAmt := TotalAmt + IncExpEntry."Net Amount"
                    else
                        TotalAmt := TotalAmt + IncExpEntry.Amount;

                    if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                        Subtotal := Subtotal + IncExpEntry."Net Amount"
                    else
                        Subtotal := Subtotal + IncExpEntry.Amount;
                    ThisIsAHospTipsLine := false;
                    if IncExpEntry."No." <> '' then begin
                        if IncExpEntry."No." = HospitalityType."Tips Income Acc. 1" then begin
                            ThisIsAHospTipsLine := true;
                            TipsAmount1 := TipsAmount1 + IncExpEntry.Amount;
                            if TipsText1 = '' then begin
                                IncomeExpenseAccount.Reset;
                                IncomeExpenseAccount.SetRange("Store No.", Transaction."Store No.");
                                IncomeExpenseAccount.SetRange("No.", IncExpEntry."No.");
                                if IncomeExpenseAccount.FindFirst then
                                    TipsText1 := IncomeExpenseAccount.Description
                                else
                                    TipsText1 := Text321;
                            end
                        end
                        else
                            if IncExpEntry."No." = HospitalityType."Tips Income Acc. 2" then begin
                                ThisIsAHospTipsLine := true;
                                TipsAmount2 := TipsAmount2 + IncExpEntry.Amount;
                                if TipsText2 = '' then begin
                                    IncomeExpenseAccount.Reset;
                                    IncomeExpenseAccount.SetRange("Store No.", Transaction."Store No.");
                                    IncomeExpenseAccount.SetRange("No.", IncExpEntry."No.");
                                    if IncomeExpenseAccount.FindFirst then
                                        TipsText2 := IncomeExpenseAccount.Description
                                    else
                                        TipsText2 := Text321;
                                end;
                            end;
                    end;

                    if not ThisIsAHospTipsLine then begin
                        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                        AddPrintLine(340, 5, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                        if Transaction."Customer Order ID" <> '' then begin
                            Clear(Value);
                            FieldValue[1] := 'ID: ' + Transaction."Customer Order ID";
                            NodeName[1] := 'Customer Order ID';
                            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                            AddPrintLine(340, 5, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                        end;
                        FieldValue[1] := Format(IncExpEntry."Line No.");
                        NodeName[1] := 'Line No.';
                        NodeName[2] := 'Extra Info Line';
                        if IncExpAcc."Slip Text 1" <> '' then begin
                            cduSender.PrintLine(Tray, IncExpAcc."Slip Text 1");
                            FieldValue[2] := IncExpAcc."Slip Text 1";
                            AddPrintLine(350, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                        end;
                        if IncExpAcc."Slip Text 2" <> '' then begin
                            cduSender.PrintLine(Tray, IncExpAcc."Slip Text 2");
                            FieldValue[2] := IncExpAcc."Slip Text 2";
                            AddPrintLine(350, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                        end;
                    end;
                    TransInfoEntry.SetRange("Store No.", Transaction."Store No.");
                    TransInfoEntry.SetRange("POS Terminal No.", Transaction."POS Terminal No.");
                    TransInfoEntry.SetRange("Transaction No.", Transaction."Transaction No.");
                    TransInfoEntry.SetRange("Transaction Type", TransInfoEntry."Transaction Type"::"Income/Expense Entry");
                    TransInfoEntry.SetRange("Line No.", IncExpEntry."Line No.");
                    PrintTransInfoCode(TransInfoEntry, Tray, false);
                end;
            until IncExpEntry.Next = 0;
            if IncomeExpenseLinePrinted then
                PrintSeperator(Tray);
        end;

        if Transaction."Transaction Type" = Transaction."Transaction Type"::Sales then
            if Globals.UseSalesTax and LocalizationExt.IsNALocalizationEnabled then
                PrintTotal(Transaction, Tray, 3, true)
            else
                PrintTotal(Transaction, Tray, 3, false);

        if not Transaction."Post as Shipment" then
            PrintPaymInfo(Transaction, Tray);

        if Transaction."Zero Rated Amount" > 0 then
            if (Transaction."Transaction Code Type" = Transaction."Transaction Code Type"::ZRWH) or (Transaction."Transaction Code Type" = Transaction."Transaction Code Type"::ZERO) then begin
                //PrintSeperator(Tray);
                DSTR1 := '#L################# #R###############   ';
                FieldValue[1] := 'Diplomat 12%';
                FieldValue[2] := POSFunctions.FormatAmount(Transaction."Zero Rated Amount");
                cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                AddPrintLine(600, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                PrintSeperator(Tray);
            end;
        if (Transaction."Transaction Code Type" = Transaction."Transaction Code Type"::ZRWH) or (Transaction."Transaction Code Type" = Transaction."Transaction Code Type"::ZERO) then
            if Transaction."Sale Is Return Sale" then begin
                //PrintSeperator(Tray);
                DSTR1 := '#L################# #R###############   ';
                FieldValue[1] := 'Diplomat 12%';
                FieldValue[2] := POSFunctions.FormatAmount(Transaction."Zero Rated Amount");
                cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                AddPrintLine(600, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                PrintSeperator(Tray);
            end;
        if POSTerminal."Print Number of Items" and (TotalNumberOfItems <> 0) then begin
            Clear(Value);
            DSTR1 := '#L####################### #R#########';
            FieldValue[1] := Text151;
            NodeName[1] := 'Total Text';
            FieldValue[2] := POSFunctions.FormatQty(TotalNumberOfItems);
            NodeName[2] := 'Total Amount';
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
            AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            PrintSeperator(Tray);
        end;

        if POSTerminal."Print Total Savings" and (TotalSavings <> 0) then begin
            Clear(Value);
            DSTR1 := '#L##################### #R###########';
            FieldValue[1] := Text152;
            NodeName[1] := 'Total Text';
            FieldValue[2] := POSFunctions.FormatAmount(TotalSavings);
            NodeName[2] := 'Total Amount';
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
            AddPrintLine(800, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            PrintSeperator(Tray);
        end;

        VATPrinted := false;

        DSTR1 := '#L################# #R##################';
        DSTR1 := '#L################# #R###############   ';

        CLEAR(decLSalesAmount);
        CLEAR(decLVATAmount);
        VATSetup.RESET;
        IF VATSetup.FINDFIRST THEN
            REPEAT //VINCENT20260106
                IF (VATSetup."VAT Code" = 'VE') THEN BEGIN
                    FieldValue[1] := 'VAT Amount';
                    FieldValue[2] := POSFunctions.FormatAmount((ROUND(decLVATAmount * -1, 0.01, '=')));
                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                END;
                IF recLVATAmountTemp.GET(VATSetup."VAT Code") THEN BEGIN
                    VATPrinted := TRUE;
                    FieldValue[1] := VATSetup.Description;
                    if VATSetup.Description = 'Vatable' then
                        FieldValue[1] := 'Vatable Sale';

                    IF Transaction."Sale Is Return Sale" THEN BEGIN
                        FieldValue[2] := POSFunctions.FormatAmount(-ROUND(recLVATAmountTemp."Unit Price Incl. VAT", 0.01, '='));
                    END ELSE
                        FieldValue[2] := POSFunctions.FormatAmount((ROUND(recLVATAmountTemp."Unit Price Incl. VAT", 0.01, '=')));
                    FieldValue[3] := POSFunctions.FormatAmount(ABS(ROUND(recLVATAmountTemp."Unit Price", 0.01, '='))); //VAT Amount
                    // IF STRLEN(FieldValue[2]) > 9 THEN
                    //     DSTR1 := '#L################ #N#############';
                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    decLSalesAmount += recLVATAmountTemp."Unit Price Incl. VAT";
                    decLVATAmount += recLVATAmountTemp."Unit Price";
                END ELSE BEGIN
                    VATPrinted := TRUE;
                    FieldValue[1] := VATSetup.Description;
                    if VATSetup.Description = 'Vatable' then
                        FieldValue[1] := 'Vatable Sale';
                    FieldValue[2] := POSFunctions.FormatAmount(0); //SalesAmount
                    FieldValue[3] := POSFunctions.FormatAmount(0); //VATAmount

                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
                END;
            UNTIL VATSetup.NEXT = 0;

        if recLVATAmountTemp.Get('VZ') then begin
            VATPrinted := TRUE;
            FieldValue[1] := 'Zero Rated Sales';
            IF Transaction."Sale Is Return Sale" THEN BEGIN
                FieldValue[2] := POSFunctions.FormatAmount(-ROUND(recLVATAmountTemp."Unit Price Incl. VAT", 0.01, '='));
                // if Transaction."Transaction Code Type" = Transaction."Transaction Code Type"::ZRWH then
                //     FieldValue[2] := POSFunctions.FormatAmount(-ROUND(recLVATAmountTemp."Unit Price Incl. VAT" + Transaction."Zero Rated Amount", 0.01, '='));
            END ELSE
                FieldValue[2] := POSFunctions.FormatAmount((ROUND(recLVATAmountTemp."Unit Price Incl. VAT" * -1, 0.01, '=')));
            FieldValue[3] := POSFunctions.FormatAmount(ABS(ROUND(recLVATAmountTemp."Unit Price", 0.01, '='))); //VAT Amount
            // IF STRLEN(FieldValue[2]) > 9 THEN
            //     DSTR1 := '#L################ #N#############';
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
            decLSalesAmount += recLVATAmountTemp."Unit Price Incl. VAT";
            decLVATAmount += recLVATAmountTemp."Unit Price";
        end else begin
            FieldValue[1] := 'Zero Rated Sales';
            FieldValue[2] := POSFunctions.FormatAmount(0);
            FieldValue[3] := POSFunctions.FormatAmount(0);
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
        end;


        IF Transaction."Sale Is Return Sale" THEN BEGIN
            decLTotalSalesAmount := decLSalesAmount + decLVATAmount;
            FieldValue[1] := 'Amount Due';
            FieldValue[2] := POSFunctions.FormatAmount(-ROUND(decLTotalSalesAmount, 0.01, '='));
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
        END ELSE BEGIN
            decLTotalSalesAmount := decLSalesAmount + decLVATAmount;
            FieldValue[1] := 'Amount Due';
            FieldValue[2] := POSFunctions.FormatAmount((ROUND(decLTotalSalesAmount * -1, 0.01, '=')));
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), FALSE, FALSE, FALSE, FALSE));
            PrintSeperator(2);
        END;
        //20210215JFL 
        if POSTerminal."Print Discount Detail" then begin
            DSTR1 := '#L################# #R###############   ';
            discountSection := false;
            if (PerDiscOffArrCount > 0) then begin
                if POSTerminal."Print Discount Detail" then begin
                    cduSender.PrintLine(Tray, FormatLine(CopyStr(Text088, 1, LineLen), false, false, false, false));
                    discountSection := true;
                end;
                for i := 1 to PerDiscOffArrCount do begin
                    maxCounter := 0;
                    MixMatchEntry.SetRange("Store No.", SalesEntry."Store No.");
                    MixMatchEntry.SetRange("POS Terminal No.", SalesEntry."POS Terminal No.");
                    MixMatchEntry.SetRange("Transaction No.", SalesEntry."Transaction No.");
                    if MixMatchEntry.FindSet() then
                        repeat
                            if MixMatchEntry."Mix & Match Group" = PerDiscOffArr[i] then
                                if MixMatchEntry.Counter > maxCounter then
                                    maxCounter := MixMatchEntry.Counter;
                        until MixMatchEntry.Next = 0;

                    if PeriodicDiscount.Get(PerDiscOffArr[i]) then begin
                        if maxCounter = 0 then
                            FieldValue[1] := PeriodicDiscount.Description
                        else
                            FieldValue[1] := Format(maxCounter) + 'x ' + PeriodicDiscount.Description;
                    end else
                        FieldValue[1] := Format(PeriodicDiscount.Type);
                    FieldValue[2] := POSFunctions.FormatAmount(PerDiscOffAmtArr[i]);
                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                end;
            end;
        end;

        if (discountSection) or (Transaction."Sale Is Return Sale") then
            PrintSeperator(Tray);

        if Tray = 2 then
            PrintCardSlipFromEFTEmbedded('E', Transaction);

        PrintRegularCustomer(Transaction);

        glTrans.Init;

    end;

    procedure InsertIntoRecipeBuffer(TransSalesEntry: Record "LSC Trans. Sales Entry"; var RecipeBufferTEMP: Record "LSC Trans. Sales Entry" temporary; var RecipeBufferModifierTEMP: Record "LSC Trans. Sales Entry" temporary; ParentItemLine: Record "LSC Trans. Sales Entry"; var RecipeBufferDetailTEMP_p: Record "LSC Trans. Discount Entry" temporary; var RecipeBufferTransInfoTEMP_p: Record "LSC Trans. Infocode Entry" temporary; var RecipeBufferTransInfoTextTEMP_p: Record "LSC Trans. Infocode Entry" temporary; CompressItem: Boolean)
    var
        ItemInfocodeItemModifier: Record "LSC Infocode";
        TransDiscEntry_l: Record "LSC Trans. Discount Entry";
        TransInfoEntry: Record "LSC Trans. Infocode Entry";
        EntryNoOfMasterLine: Integer;
        Handled: Boolean;
    begin

        if TransSalesEntry."Parent Line No." = 0 then begin  //Recipe Item
            if CompressItem then begin  //Recipe Item
                RecipeBufferTEMP.Reset;
                RecipeBufferTEMP.SetCurrentKey("Item No.", "Variant Code");
                RecipeBufferTEMP.SetRange("Item No.", TransSalesEntry."Item No.");
                RecipeBufferTEMP.SetFilter("Variant Code", '%1', TransSalesEntry."Variant Code");
                RecipeBufferTEMP.SetFilter("Orig. from Infocode", '%1', TransSalesEntry."Orig. from Infocode");
                RecipeBufferTEMP.SetFilter("Unit of Measure", '%1', TransSalesEntry."Unit of Measure");
                RecipeBufferTEMP.SetFilter(Price, '%1', TransSalesEntry.Price);
                RecipeBufferTEMP.SetRange("Return No Sale", TransSalesEntry."Return No Sale");
                if (TransSalesEntry."Scale Item") then begin
                    RecipeBufferTEMP.SetFilter("Weight Manually Entered", '%1', TransSalesEntry."Weight Manually Entered");
                end;
                if RecipeBufferTEMP.FindFirst then begin
                    RecipeBufferTEMP.Quantity := RecipeBufferTEMP.Quantity + TransSalesEntry.Quantity;
                    RecipeBufferTEMP."Net Amount" := RecipeBufferTEMP."Net Amount" + TransSalesEntry."Net Amount";
                    RecipeBufferTEMP."VAT Amount" := RecipeBufferTEMP."VAT Amount" + TransSalesEntry."VAT Amount";
                    RecipeBufferTEMP."Discount Amount" := RecipeBufferTEMP."Discount Amount" + TransSalesEntry."Discount Amount";
                    RecipeBufferTEMP."UOM Quantity" := RecipeBufferTEMP."UOM Quantity" + TransSalesEntry."UOM Quantity";
                    RecipeBufferTEMP.Modify;

                    if GenPosFunc."Print Disc/Cpn Info on Slip" in
                      [GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
                      GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line"]
                    then
                        BufferLineDiscountDetails(TransSalesEntry, RecipeBufferTEMP, RecipeBufferDetailTEMP_p);

                    TransInfoEntry.Reset;
                    TransInfoEntry.SetRange("Store No.", TransSalesEntry."Store No.");
                    TransInfoEntry.SetRange("POS Terminal No.", TransSalesEntry."POS Terminal No.");
                    TransInfoEntry.SetRange("Transaction No.", TransSalesEntry."Transaction No.");
                    TransInfoEntry.SetRange("Transaction Type", TransInfoEntry."Transaction Type"::"Sales Entry");
                    TransInfoEntry.SetRange("Line No.", TransSalesEntry."Line No.");
                    if TransInfoEntry.FindSet then
                        repeat
                            Clear(RecipeBufferTransInfoTEMP_p);
                            RecipeBufferTransInfoTEMP_p := TransInfoEntry;
                            RecipeBufferTransInfoTEMP_p."Line No." := RecipeBufferTEMP."Line No.";
                            while not RecipeBufferTransInfoTEMP_p.Insert do begin
                                RecipeBufferTransInfoTEMP_p."Entry Line No." += 1;
                            end;
                        until TransInfoEntry.Next = 0;

                    InsertFreeTextLinesInBuffer(TransSalesEntry, RecipeBufferTransInfoTextTEMP_p, RecipeBufferTEMP."Line No.");
                end else
                    CompressItem := false;
            end;
            if not CompressItem then begin
                Clear(RecipeBufferTEMP);
                RecipeBufferTEMP := TransSalesEntry;
                RecipeBufferTEMP.Insert;
                if GenPosFunc."Print Disc/Cpn Info on Slip" in
                  [GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
                  GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line"]
                then begin
                    Clear(RecipeBufferDetailTEMP_p);
                    BufferLineDiscountDetails(TransSalesEntry, RecipeBufferTEMP, RecipeBufferDetailTEMP_p);
                end;
                TransInfoEntry.SetRange("Store No.", TransSalesEntry."Store No.");
                TransInfoEntry.SetRange("POS Terminal No.", TransSalesEntry."POS Terminal No.");
                TransInfoEntry.SetRange("Transaction No.", TransSalesEntry."Transaction No.");
                TransInfoEntry.SetRange("Transaction Type", TransInfoEntry."Transaction Type"::"Sales Entry");
                TransInfoEntry.SetRange("Line No.", TransSalesEntry."Line No.");
                if TransInfoEntry.FindSet then
                    repeat
                        Clear(RecipeBufferTransInfoTEMP_p);
                        RecipeBufferTransInfoTEMP_p := TransInfoEntry;
                        RecipeBufferTransInfoTEMP_p.Insert;
                    until TransInfoEntry.Next = 0;

                InsertFreeTextLinesInBuffer(TransSalesEntry, RecipeBufferTransInfoTextTEMP_p, TransSalesEntry."Line No.");
            end;
        end
        else begin  //print child items
            Clear(ItemInfocodeItemModifier);
            if TransSalesEntry."Orig. from Infocode" <> '' then
                if ItemInfocodeItemModifier.Get(TransSalesEntry."Orig. from Infocode") then;
            if (ItemInfocodeItemModifier."Print Item Modifier on Receipt" =
                  ItemInfocodeItemModifier."Print Item Modifier on Receipt"::"Print All") or
                ((ItemInfocodeItemModifier."Print Item Modifier on Receipt" =
                  ItemInfocodeItemModifier."Print Item Modifier on Receipt"::"Skip Zero Price") and
                (TransSalesEntry."Net Amount" + TransSalesEntry."VAT Amount" <> 0))
            then begin
                EntryNoOfMasterLine := 0;
                RecipeBufferModifierTEMP.Reset;
                RecipeBufferTEMP.Reset;
                RecipeBufferTEMP.SetCurrentKey("Item No.", "Variant Code");
                RecipeBufferTEMP.SetRange("Item No.", ParentItemLine."Item No.");
                RecipeBufferTEMP.SetFilter("Variant Code", '%1', ParentItemLine."Variant Code");
                RecipeBufferTEMP.SetFilter("Orig. from Infocode", '%1', ParentItemLine."Orig. from Infocode");
                if RecipeBufferTEMP.FindFirst then begin
                    if CompressItem then
                        EntryNoOfMasterLine := RecipeBufferTEMP."Line No."
                    else
                        EntryNoOfMasterLine := TransSalesEntry."Parent Line No.";
                    RecipeBufferModifierTEMP.SetRange("Parent Line No.", EntryNoOfMasterLine);
                    RecipeBufferModifierTEMP.SetRange("Item No.", TransSalesEntry."Item No.");
                    RecipeBufferModifierTEMP.SetFilter("Variant Code", '%1', TransSalesEntry."Variant Code");
                    RecipeBufferModifierTEMP.SetRange("Orig. from Infocode");
                    if RecipeBufferModifierTEMP.FindFirst then begin
                        RecipeBufferModifierTEMP.Quantity := RecipeBufferModifierTEMP.Quantity + TransSalesEntry.Quantity;
                        RecipeBufferModifierTEMP."Net Amount" := RecipeBufferModifierTEMP."Net Amount" + TransSalesEntry."Net Amount";
                        RecipeBufferModifierTEMP."VAT Amount" := RecipeBufferModifierTEMP."VAT Amount" + TransSalesEntry."VAT Amount";
                        RecipeBufferModifierTEMP."Discount Amount" := RecipeBufferModifierTEMP."Discount Amount" + TransSalesEntry."Discount Amount";
                        RecipeBufferModifierTEMP."UOM Quantity" := RecipeBufferModifierTEMP."UOM Quantity" + TransSalesEntry."UOM Quantity";
                        RecipeBufferModifierTEMP.Modify;
                    end
                    else begin
                        RecipeBufferModifierTEMP := TransSalesEntry;
                        RecipeBufferModifierTEMP."Parent Line No." := EntryNoOfMasterLine;
                        RecipeBufferModifierTEMP.Insert;
                    end;
                end
                else begin
                    RecipeBufferModifierTEMP := TransSalesEntry;
                    RecipeBufferModifierTEMP."Parent Line No." := EntryNoOfMasterLine;
                    RecipeBufferModifierTEMP.Insert;
                end;
                if GenPosFunc."Print Disc/Cpn Info on Slip" in
                  [GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
                  GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line"]
                then begin
                    Clear(RecipeBufferDetailTEMP_p);
                    BufferLineDiscountDetails(TransSalesEntry, RecipeBufferModifierTEMP, RecipeBufferDetailTEMP_p);
                end;
            end;
        end;

    end;


    procedure InsertFreeTextLinesInBuffer(SalesEntry: Record "LSC Trans. Sales Entry"; var RecipeBufferTransInfoTextTEMP_p: Record "LSC Trans. Infocode Entry" temporary; NewParentLine: Integer)
    var
        TransInfoEntry: Record "LSC Trans. Infocode Entry";
        FromLineNo: Integer;
        ToLineNo: Integer;
    begin
        FromLineNo := SalesEntry."Line No." + 1;
        ToLineNo := SalesEntry."Line No." - (SalesEntry."Line No." mod 10000) + 9999;

        Clear(TransInfoEntry);
        TransInfoEntry.SetRange("Store No.", SalesEntry."Store No.");
        TransInfoEntry.SetRange("POS Terminal No.", SalesEntry."POS Terminal No.");
        TransInfoEntry.SetRange("Transaction No.", SalesEntry."Transaction No.");
        TransInfoEntry.SetRange("Transaction Type", TransInfoEntry."Transaction Type"::"Sales Entry");
        TransInfoEntry.SetRange("Line No.", FromLineNo, ToLineNo);
        TransInfoEntry.SetRange(Infocode, 'TEXT');
        TransInfoEntry.SetRange("Text Type", TransInfoEntry."Text Type"::"Deal Header");
        if TransInfoEntry.FindFirst then
            ToLineNo := TransInfoEntry."Line No." - 1;
        TransInfoEntry.SetRange("Line No.", FromLineNo, ToLineNo);
        TransInfoEntry.SetRange(Infocode, 'TEXT');
        TransInfoEntry.SetRange("Text Type", TransInfoEntry."Text Type"::"Freetext Input");
        if TransInfoEntry.FindSet then begin
            repeat
                if (TransInfoEntry.Information <> '') then begin
                    RecipeBufferTransInfoTextTEMP_p := TransInfoEntry;
                    RecipeBufferTransInfoTextTEMP_p."Line No." := NewParentLine;
                    while not RecipeBufferTransInfoTextTEMP_p.Insert do begin
                        RecipeBufferTransInfoTextTEMP_p."Entry Line No." += 1;
                    end;
                end;
            until TransInfoEntry.Next = 0;
        end;
    end;


    procedure BufferLineDiscountDetails(TransSalesEntry_p: Record "LSC Trans. Sales Entry"; RecipeBufferTEMP_p: Record "LSC Trans. Sales Entry" temporary; var RecipeBufferDetailTEMP_p: Record "LSC Trans. Discount Entry" temporary)
    var
        TransDiscEntry_l: Record "LSC Trans. Discount Entry";
    begin
        TransDiscEntry_l.SetRange("Store No.", TransSalesEntry_p."Store No.");
        TransDiscEntry_l.SetRange("POS Terminal No.", TransSalesEntry_p."POS Terminal No.");
        TransDiscEntry_l.SetRange("Transaction No.", TransSalesEntry_p."Transaction No.");
        TransDiscEntry_l.SetRange("Line No.", TransSalesEntry_p."Line No.");
        if TransDiscEntry_l.FindSet then
            repeat
                if RecipeBufferDetailTEMP_p.Get(TransDiscEntry_l."Store No.", TransDiscEntry_l."POS Terminal No.",
                  TransDiscEntry_l."Transaction No.", RecipeBufferTEMP_p."Line No.", TransDiscEntry_l."Offer Type",
                  TransDiscEntry_l."Offer No.")
                then begin
                    RecipeBufferDetailTEMP_p."Discount Amount" := RecipeBufferDetailTEMP_p."Discount Amount" + TransDiscEntry_l."Discount Amount";
                    RecipeBufferDetailTEMP_p.Modify;
                end else begin
                    RecipeBufferDetailTEMP_p := TransDiscEntry_l;
                    RecipeBufferDetailTEMP_p.RecipeLineNo := RecipeBufferTEMP_p."Line No.";
                    RecipeBufferDetailTEMP_p.Insert;
                end;
            until TransDiscEntry_l.Next = 0;
    end;

    procedure PrintFooter(Transaction: Record "LSC Transaction Header"; Tray: Integer)
    var
        POSText: Record "LSC POS Terminal Receipt Text";
        Terminal: Record "LSC POS Terminal";
        ReceiptHeader: Record "LSC POS Terminal Receipt Head";
        RetailUtil: Codeunit "LSC Retail Price Utils";
        DSTR1: Text[100];
        ReceiptNo: Code[20];
        IsHandled: Boolean;
    begin

        Clear(ReceiptNo);
        ReceiptHeader.Reset;
        ReceiptHeader.SetCurrentKey(Priority);
        if ReceiptHeader.FindLast then begin
            repeat
                if RetailUtil.DiscValPerValid(ReceiptHeader."Validation Period ID", Transaction.Date, Transaction.Time) then begin
                    ReceiptNo := ReceiptHeader."No.";
                end;
            until (ReceiptHeader.Next(-1) = 0) or (ReceiptNo <> '');
        end;

        Clear(POSText);

        if (ReceiptNo <> '') then
            POSText.SetRange("No.", ReceiptNo)
        else
            POSText.SetRange("No.", '');

        Terminal.Get(Globals.TerminalNo);
        if Terminal."Receipt Setup Location" = Terminal."Receipt Setup Location"::Terminal then begin
            POSText.SetRange(Relation, POSText.Relation::Terminal);
            POSText.SetRange(Number, Globals.TerminalNo);
        end else begin
            POSText.SetRange(Relation, POSText.Relation::Store);
            POSText.SetRange(Number, Globals.StoreNo);
        end;

        POSText.SetRange(Type, POSText.Type::Bottom);

        if not POSText.FindFirst then
            POSText.SetRange("No.", '');

        if POSText.FindSet then begin
            repeat
                DSTR1 := GetDesignString(POSText);
                FieldValue[1] := POSText."Receipt Text";
                NodeName[1] := 'Footer Line';
                cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), POSText.Wide, POSText.Bold, POSText.High, POSText.Italic));
                AddPrintLine(1000, 1, NodeName, FieldValue, DSTR1, POSText.Wide, POSText.Bold, POSText.High, POSText.Italic, Tray);
            until POSText.Next = 0;
        end;

    end;

    procedure PrintFooterPosVoid(Transaction: Record "LSC Transaction Header"; Tray: Integer)
    var
        POSText: Record "LSC POS Terminal Receipt Text";
        Terminal: Record "LSC POS Terminal";
        ReceiptHeader: Record "LSC POS Terminal Receipt Head";
        RetailUtil: Codeunit "LSC Retail Price Utils";
        DSTR1: Text[100];
        ReceiptNo: Code[20];
        IsHandled: Boolean;
        ctr: Integer;
    begin

        Clear(ReceiptNo);
        ReceiptHeader.Reset;
        ReceiptHeader.SetCurrentKey(Priority);
        if ReceiptHeader.FindLast then begin
            repeat
                if RetailUtil.DiscValPerValid(ReceiptHeader."Validation Period ID", Transaction.Date, Transaction.Time) then begin
                    ReceiptNo := ReceiptHeader."No.";
                end;
            until (ReceiptHeader.Next(-1) = 0) or (ReceiptNo <> '');
        end;

        Clear(POSText);

        if (ReceiptNo <> '') then
            POSText.SetRange("No.", ReceiptNo)
        else
            POSText.SetRange("No.", '');

        Terminal.Get(Globals.TerminalNo);
        if Terminal."Receipt Setup Location" = Terminal."Receipt Setup Location"::Terminal then begin
            POSText.SetRange(Relation, POSText.Relation::Terminal);
            POSText.SetRange(Number, Globals.TerminalNo);
        end else begin
            POSText.SetRange(Relation, POSText.Relation::Store);
            POSText.SetRange(Number, Globals.StoreNo);
        end;

        POSText.SetRange(Type, POSText.Type::Bottom);

        if not POSText.FindFirst then
            POSText.SetRange("No.", '');

        if POSText.FindSet then begin
            repeat
                ctr += 1;
                if ctr >= 3 then begin
                    DSTR1 := GetDesignString(POSText);
                    FieldValue[1] := POSText."Receipt Text";
                    NodeName[1] := 'Footer Line';
                    cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), POSText.Wide, POSText.Bold, POSText.High, POSText.Italic));
                    AddPrintLine(1000, 1, NodeName, FieldValue, DSTR1, POSText.Wide, POSText.Bold, POSText.High, POSText.Italic, Tray);
                end
            until POSText.Next = 0;
        end;

    end;

    procedure PrintNonSalesFooter(Transaction: Record "LSC Transaction Header"; Tray: Integer)
    var
        Terminal: Record "LSC POS Terminal";
        DSTR1: Text[100];
    begin

        PrintLineFeed(2, 1);
        CLEAR(FieldValue);
        DSTR1 := '#C################################';
        Terminal.Get(Globals.TerminalNo);
        if Terminal."Receipt Setup Location" = Terminal."Receipt Setup Location"::Terminal then begin
            CLEAR(FieldValue);
            FieldValue[1] := '     ' + CopyStr(Terminal."Non Sales Transaction Footer", 1, 26);
            NodeName[1] := 'Description';
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
            AddPrintLine(750, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            CLEAR(FieldValue);
            FieldValue[1] := '     ' + CopyStr(Terminal."Non Sales Transaction Footer", 28, 46);
            NodeName[1] := 'Description';
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
            AddPrintLine(750, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            PrintSeperator(Tray);
        end;

    end;

    local procedure GetDesignString(var POSText: Record "LSC POS Terminal Receipt Text"): Text;
    var
        retVal: Text;

    begin
        case POSText.Align of
            POSText.Align::Left:
                retVal := '#L######################################'; //40 (will be resized by FormatStr)
            POSText.Align::Center:
                retVal := '#C######################################';
            POSText.Align::Right:
                retVal := '#R######################################';
        end;

        if POSText.Wide then
            retVal := CopyStr(retVal, 1, 20);

        exit(retVal);
    end;

    procedure WindowInitialize()
    begin
        LastErrorText := '';
        PosSetup.Get(Globals.HardwareProfileID);
        Store.Get(Globals.StoreNo);
        GenPosFunc.Get(Globals.FunctionalityProfileID);
    end;

    procedure PrintSpoOrderBarcode(var Transaction: Record "LSC Transaction Header"; Tray: Integer; Slip: Boolean): Boolean
    var
        POSTerminal: Record "LSC POS Terminal";
        TransOrderHeader: Record "LSC Transaction Order Header";
        OrderBarcode: Code[20];
        bcWidth: Integer;
        bcHeight: Integer;
        IsHandled: Boolean;
        lText001: Label 'Special Order:';
    begin
        POSTerminal.Get(Transaction."POS Terminal No.");
        exit(true);
    end;

    procedure PrintLogo(Tray: Integer)
    var
        IsHandled: Boolean;
    begin

        if IsHandled then
            exit;

        PrintBuffer.Init;
        PrintBuffer."Buffer Index" := PrintBufferIndex;
        PrintBuffer."Station No." := Tray;
        PrintBuffer."Page No." := PageNo;
        PrintBuffer."Printed Line No." := LinesPrinted;
        PrintBuffer.LineType := PrintBuffer.LineType::PrintLogo;
        PrintBuffer.Text := Format(Globals.GetPrinterBitmapNo);
        PrintBuffer.Insert;
        PrintBufferIndex += 1;

    end;

    local procedure PrintTaxHeader(Transaction: Record "LSC Transaction Header"; Tray: Integer)
    var
        IsHandled: Boolean;
    begin

        if (RetailSetup."W1 for Country  Code" = RetailSetup."W1 for Country  Code"::AE) then begin
            CLEAR(FieldValue);
            if Transaction."Sale Is Return Sale" then
                FieldValue[1] := 'TAX CREDIT NOTE'
            else
                FieldValue[1] := 'TAX INVOICE';
            NodeName[1] := 'Description';
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, '#C##################'), true, false, true, false));
            PrintSeperator(Tray);
        end else
            if (RetailSetup."W1 for Country  Code" = RetailSetup."W1 for Country  Code"::ZA) then begin
                CLEAR(FieldValue);
                if Transaction."Sale Is Return Sale" then
                    FieldValue[1] := '** CREDIT NOTE **'
                else
                    FieldValue[1] := '** TAX INVOICE **';
                NodeName[1] := 'Description';
                cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, '#C##################'), true, false, true, false));
                PrintSeperator(Tray);
            end;
    end;

    procedure PrintBarcode(Tray: Integer; BCString: Text[2048]; Width: Integer; Height: Integer; bcType: Code[10]; bcPos: Integer)
    var
        IsHandled: Boolean;
    begin

        PrintBuffer.Init;
        PrintBuffer."Buffer Index" := PrintBufferIndex;
        PrintBuffer."Station No." := Tray;
        PrintBuffer."Page No." := PageNo;
        PrintBuffer."Printed Line No." := LinesPrinted;
        PrintBuffer.LineType := PrintBuffer.LineType::PrintBarcode;
        PrintBuffer.Text := BCString;
        PrintBuffer.Width := Width;
        PrintBuffer.Height := Height;
        PrintBuffer.BCType := bcType;
        PrintBuffer.BCPos := bcPos;
        PrintBuffer.Insert;
        PrintBufferIndex += 1;

    end;

    procedure PrintLoyalty(var POSTrans: Record "LSC Transaction Header"; Tray: Integer)
    var
        MemberClubTemp_l: Record "LSC Member Club" temporary;
        TransPointEntry: Record "LSC Trans. Point Entry";
        MemberCardTemp_l: Record "LSC Membership Card" temporary;
        FBPWSBufferTEMP: Record "LSC FBP WS Buffer" temporary;
        FBPPOSFunctions: Codeunit "LSC FBP POS Functions";
        MemberText: Text[100];
        MsgText: Text[250];
        DSTR1: Text[100];
        ErrorText: Text;
        ProcessCode: Code[30];
        IssuedPoints: Decimal;
        UsedPoints: Decimal;
        CouponsIssued: Integer;
        IsHandled: Boolean;
        lText000: Label ' pts';
        lText001: Label 'Issued';
        lText002: Label 'Status ';
        lText010: Label 'Member Account %1.';
        lText011: Label 'Membership Card %1.';
        lText012: Label 'Issued Points: %1';
        lText013: Label 'Used Points..: %1';
        lText014: Label 'Point Balance: %1';
        lText015: Label 'You will receive a new coupon';
        lText016: Label 'You will receive %1 new coupons';
    begin

        if POSTrans."Member Card No." = '' then
            exit;
        if not POSFunctions.GetMemberInfoForPos(POSTrans."Member Card No.", ProcessCode, ErrorText) then
            exit;
        POSFunctions.GetMemberShipCardInfo(MemberCardTemp_l);
        POSFunctions.GetMemberClubInfo(MemberClubTemp_l);
        if (MemberClubTemp_l."Show Points on Receipt" = MemberClubTemp_l."Show Points on Receipt"::No) and
           (MemberClubTemp_l."Show FBP Coupons on Receipt" = MemberClubTemp_l."Show FBP Coupons on Receipt"::No)
        then
            exit;

        TransPointEntry.SetRange("Store No.", POSTrans."Store No.");
        TransPointEntry.SetRange("POS Terminal No.", POSTrans."POS Terminal No.");
        TransPointEntry.SetRange("Transaction No.", POSTrans."Transaction No.");
        if TransPointEntry.FindSet then
            repeat
                if TransPointEntry."Entry Type" = TransPointEntry."Entry Type"::Sale then
                    IssuedPoints := IssuedPoints + TransPointEntry.Points
                else
                    UsedPoints := UsedPoints - TransPointEntry.Points;
            until TransPointEntry.Next = 0;

        if (POSTrans."Starting Point Balance" = 0) and (IssuedPoints = 0) and (UsedPoints = 0) then
            exit;

        if MemberCardTemp_l."Account No." <> '' then
            MemberText := StrSubstNo(lText010, MemberCardTemp_l."Account No.")
        else
            MemberText := StrSubstNo(lText011, POSTrans."Member Card No.");

        case MemberClubTemp_l."Show Points on Receipt" of
            MemberClubTemp_l."Show Points on Receipt"::"Issued Points":
                begin
                    if (IssuedPoints <> 0) or (UsedPoints <> 0) then begin
                        cduSender.PrintLine(Tray, '');
                        FieldValue[1] := MemberText;
                        NodeName[1] := 'Member Info';
                        cduSender.PrintLine(Tray, FormatLine(MemberText, false, false, false, false));
                        AddPrintLine(750, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                        FieldValue[1] := Format(IssuedPoints);
                        NodeName[1] := 'Issued Points';
                        cduSender.PrintLine(Tray, FormatLine(StrSubstNo(lText012, IssuedPoints), false, false, false, false));
                        AddPrintLine(750, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                        FieldValue[1] := Format(UsedPoints);
                        NodeName[1] := 'Used Points';
                        cduSender.PrintLine(Tray, FormatLine(StrSubstNo(lText013, UsedPoints), false, false, false, false));
                        AddPrintLine(750, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                    end;
                end;
            MemberClubTemp_l."Show Points on Receipt"::"Point Summary":
                if POSTrans."Starting Point Balance" <> 0 then begin
                    cduSender.PrintLine(Tray, '');
                    FieldValue[1] := MemberText;
                    NodeName[1] := 'Member Info';
                    cduSender.PrintLine(Tray, FormatLine(MemberText, false, false, false, false));
                    AddPrintLine(750, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                    FieldValue[1] := Format(IssuedPoints);
                    NodeName[1] := 'Issued Points';
                    cduSender.PrintLine(Tray, FormatLine(StrSubstNo(lText012, IssuedPoints), false, false, false, false));
                    AddPrintLine(750, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                    FieldValue[1] := Format(UsedPoints);
                    NodeName[1] := 'Used Points';
                    cduSender.PrintLine(Tray, FormatLine(StrSubstNo(lText013, UsedPoints), false, false, false, false));
                    AddPrintLine(750, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                    FieldValue[1] := Format(POSTrans."Starting Point Balance" + IssuedPoints - UsedPoints);
                    NodeName[1] := 'Point Balance';
                    cduSender.PrintLine(Tray, FormatLine(StrSubstNo(lText014, POSTrans."Starting Point Balance" + IssuedPoints - UsedPoints), false, false, false, false));
                    AddPrintLine(750, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                end else begin
                    cduSender.PrintLine(Tray, '');
                    FieldValue[1] := MemberText;
                    NodeName[1] := 'Member Info';
                    cduSender.PrintLine(Tray, FormatLine(MemberText, false, false, false, false));
                    AddPrintLine(750, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                    FieldValue[1] := Format(IssuedPoints);
                    NodeName[1] := 'Issued Points';
                    cduSender.PrintLine(Tray, FormatLine(StrSubstNo(lText012, IssuedPoints), false, false, false, false));
                    AddPrintLine(750, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                    FieldValue[1] := Format(UsedPoints);
                    NodeName[1] := 'Used Points';
                    cduSender.PrintLine(Tray, FormatLine(StrSubstNo(lText013, UsedPoints), false, false, false, false));
                    AddPrintLine(750, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                end;
        end;
        if MemberClubTemp_l."Show FBP Coupons on Receipt" = MemberClubTemp_l."Show FBP Coupons on Receipt"::"Number of Coupons" then begin
            CouponsIssued := FBPPOSFunctions.GetNumberOfNewCouponsInTransaction(POSTrans);
            if CouponsIssued > 0 then begin
                FieldValue[1] := Format(CouponsIssued);
                NodeName[1] := 'FBP Coupons';
                if CouponsIssued = 1 then
                    cduSender.PrintLine(Tray, FormatLine(lText015, false, false, false, false))
                else
                    cduSender.PrintLine(Tray, FormatLine(StrSubstNo(lText016, CouponsIssued), false, false, false, false));
                AddPrintLine(750, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
            end;
        end;
    end;

    local procedure PrintRecommendation(TransactionHeader: Record "LSC Transaction Header")
    var
        Item: Record Item;
        LSRecommendSetup: Record "LSC Recomm. Setup";
        LSRecommendItemBuffer: Record "LSC Recomm. Item Buffer";
        DownloadedItem: Record "LSC Recomm. Item Buffer" temporary;
        WSInventoryBufferTemp: Record "LSC WS Inventory Buffer" temporary;
        ItemStatusLink: Record "LSC Item Status Link";
        BOUtils: Codeunit "LSC BO Utils";
        //LSRecommMgt: Codeunit "LSC Recomm. Mgt.";
        DSTR1: Text[100];
        ErrorText: Text;
        LineNo, MaxLineNo, LineLength, Tray : Integer;
        IsHandled, IsBlockRecommend : Boolean;
    begin

        if not LSRecommendSetup.Get() then
            exit;

        if not LSRecommendSetup."Use LS Recommend on POS" then
            exit;

        if not LSRecommendSetup."Print Recommendation on Slip" then
            exit;

        LineLength := LineLen;
        Tray := 2;

        DSTR1 := CopyStr('#L################################################', 1, LineLength);

        if (not LSRecommendSetup."Show Recommendation on Total") and (not LSRecommendSetup."Show Recommendation on POS") then begin
            LSRecommendItemBuffer.SetRange("Store No.", TransactionHeader."Store No.");
            LSRecommendItemBuffer.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
            if not LSRecommendItemBuffer.IsEmpty then begin
                LSRecommendItemBuffer.DeleteAll();
                Commit();
            end;
            if not GetRecommendationForPrinting(TransactionHeader, '', DownloadedItem, ErrorText) then
                exit;
            if ErrorText <> '' then
                exit;
            RecommCount += 1;

            DownloadedItem.Reset();
            if DownloadedItem.IsEmpty then
                exit;

            if LSRecommendSetup."Print Recomm. (Filter By Inv.)" then begin
                DownloadedItem.Reset();
                DownloadedItem.SetFilter(Inventory, '>%1', 0)
            end;
            if DownloadedItem.FindSet() then begin
                repeat
                    IsBlockRecommend := BOUtils.IsBlockFromRecommendation(DownloadedItem."Recommended Item No.", '', '', DownloadedItem."Store No.", '', Today, ItemStatusLink);
                    if not IsBlockRecommend then
                        if LSRecommendItemBuffer.Get(DownloadedItem."Store No.", DownloadedItem."POS Terminal No.", DownloadedItem."Recommended Item No.", DownloadedItem."Receipt No.") then begin
                            LSRecommendItemBuffer.Inventory := DownloadedItem.Inventory;
                            LSRecommendItemBuffer.Rating := DownloadedItem.Rating;
                            LSRecommendItemBuffer.Use := true;
                            LSRecommendItemBuffer.Modify();
                        end else begin
                            LSRecommendItemBuffer.Init();
                            LSRecommendItemBuffer.TransferFields(DownloadedItem);
                            LSRecommendItemBuffer.Insert();
                        end;
                until DownloadedItem.Next() = 0;
                Commit();
            end;
        end;

        LSRecommendItemBuffer.Reset();
        LSRecommendItemBuffer.SetCurrentKey(Rating);
        LSRecommendItemBuffer.SetAscending(Rating, false);
        LSRecommendItemBuffer.SetRange("Store No.", TransactionHeader."Store No.");
        LSRecommendItemBuffer.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
        LSRecommendItemBuffer.SetRange("Receipt No.", TransactionHeader."Receipt No.");
        LSRecommendItemBuffer.SetRange(Use, true);
        if LSRecommendItemBuffer.FindSet then begin
            cduSender.PrintLine(Tray, '');
            FieldValue[1] := RecommendationText;
            NodeName[1] := 'Recommendation';
            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
            AddPrintLine(980, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

            LineNo := 0;
            MaxLineNo := 5;
            repeat
                if not FindItemInTransSalesEntry(TransactionHeader, LSRecommendItemBuffer."Recommended Item No.") then
                    if Item.Get(LSRecommendItemBuffer."Recommended Item No.") then begin
                        LineNo += 1;
                        if LineNo <= MaxLineNo then begin
                            FieldValue[1] := Item.Description;
                            NodeName[1] := 'Item Description';
                            cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                            NodeName[2] := 'Line No.';
                            FieldValue[2] := Format(LineNo);
                            AddPrintLine(990, 2, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
                        end;
                    end;
            until (LSRecommendItemBuffer.Next = 0) or (LineNo = MaxLineNo);
            cduSender.PrintLine(Tray, '');
        end;
    end;

    local procedure FindItemInTransSalesEntry(TransactionHeader: Record "LSC Transaction Header"; ItemNo: Code[20]): Boolean
    var
        TransSalesEntry: Record "LSC Trans. Sales Entry";
    begin
        TransSalesEntry.SetRange("Store No.", TransactionHeader."Store No.");
        TransSalesEntry.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransSalesEntry.SetRange("Transaction No.", TransactionHeader."Transaction No.");
        TransSalesEntry.SetRange("Item No.", ItemNo);
        if TransSalesEntry.FindFirst then
            exit(true);

        exit(false);
    end;

    procedure PrintSignature(Sign: Text[30])
    var
        DSTR1: Text[100];
        IsHandled: Boolean;
    begin
        cduSender.PrintLine(2, '');
        cduSender.PrintLine(2, '');
        cduSender.PrintLine(2, '');
        PrintSeperator(2);

        DSTR1 := '#C######################################';
        if Sign = '' then
            FieldValue[1] := Text094
        else
            FieldValue[1] := Sign;
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));

    end;

    procedure GetReceiptBarcodeWidthAndHeight(var pPosTerminal: Record "LSC POS Terminal"; var bcWidth: Integer; var bcHeight: Integer)
    begin
        if pPosTerminal."Receipt Barcode Width" > 0 then
            bcWidth := pPosTerminal."Receipt Barcode Width"
        else begin
            if (ActivePrinter.Printer = ActivePrinter.Printer::"ePOS-Printer") and
               (pPosTerminal."Print Receipt BC Type" <> pPosTerminal."Print Receipt BC Type"::QRCODE) then
                bcWidth := 2
            else
                bcWidth := 8;
        end;

        if pPosTerminal."Receipt Barcode Height" > 0 then
            bcHeight := pPosTerminal."Receipt Barcode Height"
        else
            bcHeight := 40;
    end;

    procedure PrintXZLines(StaffID_p: Code[20])
    var
        PaymEntry_: record "LSC Trans. Payment Entry";
        Currency: Record Currency;
        TTCardSetup: Record "LSC Tender Type Card Setup";
        IsHandled: Boolean;
        intLCtr: Integer;
        DSTR1: Text[80];
    begin
        Clear(intLCtr);
        TTCardSetup.SetCurrentKey("Store No.", "Tender Type Code");
        TTCardSetup.SetRange("Store No.", Globals.StoreNo);

        if TenderType.FindSet() then
            repeat
                PaymEntry.SetRange("Tender Type", TenderType.Code);
                if StaffID_p <> '' then
                    PaymEntry.SetRange("Staff ID", StaffID_p)
                else
                    PaymEntry.SetRange("Staff ID");
                PaymEntry.SetRange("Card No.");
                FieldValue[1] := TenderType.Description;
                PaymEntry.CalcSums("Amount Tendered");
                LocalTotal := LocalTotal + PaymEntry."Amount Tendered";

                if TenderType."Foreign Currency" then begin
                    PaymEntry.SetRange("Currency Code");
                    PaymEntry.CalcSums("Amount Tendered");
                    if PaymEntry."Amount Tendered" <> 0 then begin
                        //DSTR1 := '#L##### #R########### #R#################';
                        DSTR1 := '#L############ #R## #R##################';
                        if Currency.FindSet() then
                            repeat
                                PaymEntry.SetRange("Currency Code", Currency.Code);
                                PaymEntry.CalcSums("Amount Tendered", "Amount in Currency");
                                if PaymEntry."Amount Tendered" <> 0 then begin
                                    FieldValue[1] := Currency.Code;
                                    FieldValue[2] := POSFunctions.FormatCurrency(PaymEntry."Amount in Currency", Currency.Code);
                                    FieldValue[3] := POSFunctions.FormatAmount(PaymEntry."Amount Tendered");
                                    cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                                end;
                                TotalLCYInCurrency := TotalLCYInCurrency + PaymEntry."Amount Tendered";
                            until Currency.Next = 0;
                    end;
                end else begin
                    if (TenderType."Function" = TenderType."Function"::Card) then begin
                        PaymEntry.SetRange("Card No.");
                        PaymEntry.CalcSums("Amount Tendered");
                        if PaymEntry."Amount Tendered" <> 0 then begin
                            //DSTR1 := '#L############# #R## #R##################';
                            DSTR1 := '#L############ #R## #R##################';
                            FieldValue[2] := POSFunctions.FormatQty(PaymEntry.Count);
                            FieldValue[3] := POSFunctions.FormatAmount(PaymEntry."Amount Tendered");
                            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                            TTCardSetup.SetRange("Tender Type Code", TenderType.Code);
                            if TTCardSetup.FindSet() then
                                repeat
                                    DSTR1 := '   #L########## #R## #R###########';
                                    PaymEntry.SetRange("Card No.", TTCardSetup."Card No.");
                                    PaymEntry.CalcSums("Amount Tendered");
                                    if PaymEntry."Amount Tendered" <> 0 then begin
                                        FieldValue[1] := TTCardSetup.Description;
                                        FieldValue[2] := POSFunctions.FormatQty(PaymEntry.Count);
                                        FieldValue[3] := POSFunctions.FormatAmount(PaymEntry."Amount Tendered");
                                        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                                    end
                                until TTCardSetup.Next = 0;
                        end;
                    end else begin
                        // DSTR1 := '#L############# #R## #R#################';
                        DSTR1 := '#L############ #R## #R##################';
                        PaymEntry.SetRange("Card No.");

                        PaymEntry.CalcSums("Amount Tendered");

                        if PaymEntry."Amount Tendered" <> 0 then begin
                            if TenderType."POS Count Entries" then
                                FieldValue[2] := POSFunctions.FormatQty(PaymEntry.Count())
                            else
                                FieldValue[2] := '';
                            PaymEntry_.CopyFilters(PaymEntry);
                            PaymEntry_.SetRange("Change Line", false);
                            FieldValue[2] := POSFunctions.FormatQty(PaymEntry_.Count());
                            FieldValue[3] := POSFunctions.FormatAmount(PaymEntry."Amount Tendered");
                            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(FieldValue, DSTR1), false, false, false, false));
                        end;
                    end;
                end
            until TenderType.Next = 0;

    end;

    procedure ReprintZ(StartDate: Date; EndDate: Date): Boolean
    var
        Transaction: Record "LSC Transaction Header";
        Staff: Record "LSC Staff";
        Terminal: Record "LSC POS Terminal";
        recEODLedgerEntry: Record "End Of Day Ledger";
        FormattedStartDate: Text[10];
        FormattedEndDate: Text[10];
        DSTR1: Text[80];
        SCode: Code[20];
        decLTotalTender: Integer;
        TotalVatDetails: Decimal;
        l_ResetCtrCode: Text[4];
        Text116: Label 'Z-Reading Counter: ';
        CashTransactionTotal: Integer;
        CashTransactionAmtTotal: Decimal;
        TotalTenderAmtTotal: Decimal;
        FloatEntryTotal: Decimal;
        RemoveTenderTotal: Decimal;
        GrossSalesAmtTotal: Decimal;
        LineDiscAmtTotal: Decimal;
        AthlDiscTotal: Decimal;
        SoloParentDiscTotal: Decimal;
        PWDDiscTotal: Decimal;
        SCDiscTotal: Decimal;
        TotalDisc: Decimal;
        TotalNetSales: Decimal;
        ZeroRatedAmtTotal: Decimal;
        VatableSalesTotal: Decimal;
        VatAmtTotal: Decimal;
        VatExemptSalesTotal: Decimal;
        ZeroRatedSalesTotal: Decimal;
        NoOfPayingCustomersTotal: Integer;
        NoOfTransactionsTotal: Integer;
        ItemSoldTotal: Integer;
        NoOfRefundTotal: Integer;
        TotalRefundAmt: Decimal;
        NoOfReturnTotal: Integer;
        TotalReturnAmt: Decimal;
        NoOfSuspendedTotal: Integer;
        NoOfVoidedLineTotal: Integer;
        TotalVoidedLineAmt: Decimal;
        NoOfVoidedTransTotal: Integer;
        NoOfTrainingTotal: Integer;
        NoOfOpenDrawerTotal: Integer;
        CodBegInvNo: Code[20];
        DecOldAccumulated: Decimal;
        CodLBegPostVoidSeries: Code[20];
        CodLBegReturnSeries: Code[20];
        CodEnvInvNo: Code[20];
        DecNewAccumulated: Decimal;
        ZReportIDFrom: Code[20];
        ZReportIDTo: Code[20];
        CodLEndPostVoidSeries: Code[20];
        CodLEndReturnSeries: Code[20];
        IntBegAccumResetCtr: Integer;
        IntEndAccumResetCtr: Integer;
    begin
        gTimeStart := Format(Time());

        if not Staff.Get(Globals.StaffID) then
            exit(true);

        if not Terminal.Get(Globals.TerminalNo) then
            exit(true);

        if not cduSender.OpenReceiptPrinter(2, 'TENDER', 'ZXREPORT', 0, '') then
            exit(false);

        if not Terminal."Terminal Statement" then
            Terminal."Statement Method" := Store."Statement Method";

        FormattedStartDate := Format(StartDate, 0, '<Year4>-<Month,2>-<Day,2>');
        FormattedEndDate := Format(EndDate, 0, '<Year4>-<Month,2>-<Day,2>');
        EVALUATE(StartDate, FormattedStartDate);
        EVALUATE(EndDate, FormattedEndDate);
        recEODLedgerEntry.RESET;
        recEODLEdgerEntry.SetCurrentKey("Store No.", "POS Terminal No.", Date);
        recEODLedgerEntry.SetRange("Store No.", Globals.StoreNo);
        recEODLedgerEntry.SetRange("POS Terminal No.", Globals.TerminalNo);
        // Dapat kahit hindi existing 
        recEODLedgerEntry.SetFilter(Date, '%1..%2', StartDate, EndDate);

        IF recEODLedgerEntry.FindFirst THEN BEGIN
            IF recEODLedgerEntry.FINDFIRST THEN BEGIN
                CodBegInvNo := recEODLedgerEntry."Beginning Invoice No.";
                DecOldAccumulated := recEODLedgerEntry."Old Accumulated Sales";
                ZReportIDFrom := recEODLedgerEntry."Z-Report ID";
                CodLBegPostVoidSeries := recEODLedgerEntry."Beg. Void";
                CodLBegReturnSeries := recEODLedgerEntry."Beg. Return";
                IntBegAccumResetCtr := recEODLedgerEntry."Accumulated Reset Counter";
            END;

            IF recEODLedgerEntry.FINDLAST THEN BEGIN
                CodEnvInvNo := recEODLedgerEntry."Ending Invoice No.";
                DecNewAccumulated := recEODLedgerEntry."New Accumulated Sales";
                ZReportIDTo := recEODLedgerEntry."Z-Report ID";
                CodLEndPostVoidSeries := recEODLedgerEntry."End. Void";
                CodLEndReturnSeries := recEODLedgerEntry."End. Return";
                IntEndAccumResetCtr := recEODLedgerEntry."Accumulated Reset Counter";
            END;

            SCode := POSFunctions.GetStatementCode;

            PrintLogo(2);
            cduSender.PrintHeader(Transaction, false, 2);

            IF StartDate <> EndDate THEN BEGIN
                // Trans Date
                DSTR1 := '#L###############################';
                Value[1] := 'Trans. Date: ' + FORMAT(StartDate) + ' to ' + FORMAT(EndDate);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

                DSTR1 := '#L########### #T###### #T#######';
                Value[1] := 'Printed Date:';
                Value[2] := FORMAT(TODAY());
                Value[3] := Format(Time, 8, '<Hours24,2>:<Minutes,2>:<Seconds,2>');// FORMAT(TIME(), 5);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

                // Staff
                DSTR1 := '#L###################################### ';
                Value[1] := Text051 + ':';
                IF Staff."Name on Receipt" <> '' THEN
                    Value[1] := Value[1] + ' ' + Staff."Name on Receipt"
                ELSE
                    Value[1] := Value[1] + ' ' + Globals.StaffID;

                gStaffName := Value[2];

                Value[1] := Value[1] + ' POS: ' + FORMAT(Terminal."No.");

                Value[1] := Value[1] + ' Store #: ' + Globals.StoreNo();

                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                PrintSeperator(2);
            END ELSE BEGIN
                DSTR1 := '#L########### #T###### #T### #T####### ';
                Value[1] := 'Trans. Date:';
                Value[2] := FORMAT(recEODLedgerEntry.Date);
                Value[3] := 'POS:';
                Value[4] := FORMAT(Terminal."No.");
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

                DSTR1 := '#L########### #T###### #T#######';
                Value[1] := 'Printed Date:';
                Value[2] := FORMAT(TODAY());
                Value[3] := Format(Time, 8, '<Hours24,2>:<Minutes,2>:<Seconds,2>');// FORMAT(TIME(), 5);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

                DSTR1 := '#L###### #L###########  #T###### #T#####  ';
                Value[1] := Text051 + ':';
                IF Staff."Name on Receipt" <> '' THEN
                    Value[2] := Staff."Name on Receipt"
                ELSE
                    Value[2] := Globals.StaffID;

                gStaffName := Value[2];

                Value[3] := 'Store #:';
                Value[4] := Globals.StoreNo();

                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, true, false, false));
                PrintSeperator(2);
            END;

            DSTR1 := '#C######################';
            Value[1] := 'Z-REPORT (REPRINT)';
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), true, true, true, false));
            cduSender.AddPrintLine(200, 2, NodeName, Value, DSTR1, false, true, false, false, 2);
            PrintSeperator(2);
            IF recEODLedgerEntry.FINDFIRST THEN BEGIN
                REPEAT
                    CashTransactionTotal += recEODLedgerEntry."No. of Cash Transaction";
                    CashTransactionAmtTotal += recEODLedgerEntry."Cash Transaction Amount";
                    TotalTenderAmtTotal += recEODLedgerEntry."Total Tender Amount";
                    FloatEntryTotal += recEODLedgerEntry."Float Entry";
                    RemoveTenderTotal += recEODLedgerEntry."Remove Tender";
                    GrossSalesAmtTotal += recEODLedgerEntry."Gross Sales Amount";
                    LineDiscAmtTotal += recEODLedgerEntry."Line Discount Amount";
                    AthlDiscTotal += recEODLedgerEntry."Athl Discount";
                    SoloParentDiscTotal += recEODLedgerEntry."Solo Parent Discount";
                    PWDDiscTotal += recEODLedgerEntry."PWD Discount";
                    SCDiscTotal += recEODLedgerEntry."Senior Citizen Discount";
                    TotalDisc += recEODLedgerEntry."Total Discount Amount";
                    TotalNetSales += recEODLedgerEntry."Total Net Sales";
                    ZeroRatedAmtTotal += recEODLedgerEntry."Zero Rated Amount";
                    VatableSalesTotal += recEODLedgerEntry."Vatable Sales";
                    VatAmtTotal += recEODLedgerEntry."Total VAT Amount";
                    VatExemptSalesTotal += recEODLedgerEntry."VAT Exempt Sales";
                    ZeroRatedSalesTotal += recEODLedgerEntry."Zero Rated Sales";
                    TotalVatDetails += (Abs(recEODLedgerEntry."Vatable Sales") + Abs(recEODLedgerEntry."VAT Exempt Sales") + Abs(recEODLedgerEntry."Zero Rated Amount") + Abs(recEODLedgerEntry."Total VAT Amount") + Abs(recEODLedgerEntry."Zero Rated Sales"));
                    NoOfPayingCustomersTotal += recEODLedgerEntry."No. of Paying Customers";
                    NoOfTransactionsTotal += recEODLedgerEntry."No. of Transactions";
                    ItemSoldTotal += recEODLedgerEntry."No. of Item Sold";
                    NoOfRefundTotal += recEODLedgerEntry."No. of Refunds";
                    TotalRefundAmt += recEODLedgerEntry."Total Refund Amount";
                    NoOfReturnTotal += recEODLedgerEntry."No. of Returns";
                    TotalReturnAmt += recEODLedgerEntry."Total Return Amount";
                    NoOfSuspendedTotal += recEODLedgerEntry."No. of Suspended";
                    NoOfVoidedLineTotal += recEODLedgerEntry."No. of Voided Line";
                    TotalVoidedLineAmt += recEODLedgerEntry."Total Voided Line Amount";
                    NoOfVoidedTransTotal += recEODLedgerEntry."No. of Voided Transaction";
                    NoOfTrainingTotal += recEODLedgerEntry."No. of Training";
                    NoOfOpenDrawerTotal += recEODLedgerEntry."No. of Open Drawer";
                UNTIL recEODLedgerEntry.Next() = 0;
                // Cash =
                DSTR1 := '#L############ #R## #R##################';
                Value[1] := 'Cash';
                Value[2] := POSFunctions.FormatQty(CashTransactionTotal);
                Value[3] := POSFunctions.FormatAmount(ABS(CashTransactionAmtTotal));
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // Total Tender Amount =
                PrintSeperator(2);
                DSTR1 := '#L########          #R##################';
                Value[1] := Text005 + ':';
                Value[2] := POSFunctions.FormatAmount(TotalTenderAmtTotal);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                PrintSeperator(2);
                // Float Entry =
                DSTR1 := '#L##############    #R##################';
                Value[1] := Text009 + ':';
                Value[2] := POSFunctions.FormatAmount(FloatEntryTotal);
                cduSender.PrintLine(2, FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                // Remove Tender =
                DSTR1 := '#L##############    #R##################';
                Value[1] := Text010 + ':';
                Value[2] := POSFunctions.FormatAmount(RemoveTenderTotal);
                cduSender.PrintLine(2, FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                PrintSeperator(2);
                // Gross Sales 
                DSTR1 := '#L############### #R####################'; // #L##################### #R##############
                Value[2] := POSFunctions.FormatAmount(GrossSalesAmtTotal);
                Value[1] := Text011;
                cduSender.PrintLine(2, FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                // Discounts
                DSTR1 := '#L###################################';
                Value[1] := 'Discount';
                DSTR1 := '#L###########################';
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // Line disc./Total disc.   
                Value[1] := ' Line disc./Total disc.';
                Value[2] := POSFunctions.FormatAmount(LineDiscAmtTotal);
                DSTR1 := '#L#################### #R###############';
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // NAAC
                Value[1] := ' NAAC'; //VINCENT20251211
                Value[2] := POSFunctions.FormatAmount(AthlDiscTotal);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // SOLO
                Value[1] := ' SOLO';
                Value[2] := POSFunctions.FormatAmount(SoloParentDiscTotal);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // PWD
                Value[1] := ' PWD';
                Value[2] := POSFunctions.FormatAmount(ROUND(PWDDiscTotal, 0.01));
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // SC
                Value[1] := ' SC';
                Value[2] := POSFunctions.FormatAmount(ROUND(SCDiscTotal, 0.01));
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // Total Discount
                Value[1] := ' Total Discount';
                Value[2] := POSFunctions.FormatAmount(ABS(TotalDisc));
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                PrintSeperator(2);
                // Total net Sales
                DSTR1 := '#L################ #R###################';
                Value[1] := 'Total Net Sales';
                Value[2] := POSFunctions.FormatAmount(TotalNetSales);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                PrintSeperator(2);
                // Zero Rated Amount
                DSTR1 := '#L################ #R###################';
                Value[1] := 'Zero-rated Amount';
                Value[2] := POSFunctions.FormatAmount(ZeroRatedAmtTotal);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                PrintSeperator(2);
                // Vatable Sales
                Value[1] := 'Vatable Sales';
                Value[2] := POSFunctions.FormatAmount(VatableSalesTotal);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // VAT Amount
                Value[1] := 'VAT Amount';
                Value[2] := POSFunctions.FormatAmount(VatAmtTotal);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // VAT Exempt Sales
                Value[1] := 'VAT Exempt Sales';
                Value[2] := POSFunctions.FormatAmount(VatExemptSalesTotal);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // Zero Rated Sales
                Value[1] := 'Zero-rated Sales';
                Value[2] := POSFunctions.FormatAmount(ZeroRatedSalesTotal);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                PrintSeperator(2);
                // Total
                Value[1] := Text005;
                Value[2] := POSFunctions.FormatAmount(TotalVatDetails);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                PrintSeperator(2);
                DSTR1 := '#L#################### #R###############';
                // No. of Paying Customer
                Value[1] := 'No. of Paying Customer';
                Value[2] := FORMAT(NoOfPayingCustomersTotal);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // No. of Transactions
                Value[1] := 'No. of Transactions';
                Value[2] := FORMAT(NoOfTransactionsTotal);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // Items Sold
                Value[1] := 'Items Sold';
                Value[2] := FORMAT(ItemSoldTotal);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // No. of Refunds
                Value[1] := 'No. of Refunds'; // Text030
                Value[2] := FORMAT(NoOfRefundTotal);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // Total Refund Amount
                Value[1] := 'Total Refund Amt';
                Value[2] := POSFunctions.FormatAmount(TotalRefundAmt);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // No. of Returns
                Value[1] := 'No. of Returns';
                Value[2] := FORMAT(NoOfReturnTotal);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // Total Return Amount
                Value[1] := 'Total Return Amt';
                Value[2] := POSFunctions.FormatAmount(TotalReturnAmt);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // No. of Suspended
                Value[1] := 'No. of Suspended';
                Value[2] := FORMAT(NoOfSuspendedTotal);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // No. of Voided Line
                Value[1] := 'No. of Voided Line';
                Value[2] := FORMAT(NoOfVoidedLineTotal);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // Total Voided Line
                Value[1] := 'Total Voided Line';
                Value[2] := POSFunctions.FormatAmount(TotalVoidedLineAmt);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // No. of Voided Trans
                Value[1] := 'No. of Voided Trans';
                Value[2] := FORMAT(NoOfVoidedTransTotal);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // No. of Traning
                Value[1] := 'No. of Training';
                Value[2] := FORMAT(NoOfTrainingTotal);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // No. of Open Drawer =
                Value[1] := 'No. of Open Drawer';
                Value[2] := FORMAT(NoOfOpenDrawerTotal);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // Beginning Invoice No
                Value[1] := 'Beg. SI #:';
                CodBegInvNo := CheckIfNoSeriesIsEmpty(CodBegInvNo);
                Value[2] := FORMAT(CodBegInvNo);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // Ending Invoice No
                Value[1] := 'End. SI #:';
                CodEnvInvNo := CheckIfNoSeriesIsEmpty(CodEnvInvNo);
                Value[2] := FORMAT(CodEnvInvNo);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // Return Series    
                Value[1] := 'Beg. VOID #: ';
                CodLBegPostVoidSeries := CheckIfNoSeriesIsEmpty(CodLBegPostVoidSeries);
                Value[2] := FORMAT(CodLBegPostVoidSeries);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                Value[1] := 'End. VOID #:';
                CodLEndPostVoidSeries := CheckIfNoSeriesIsEmpty(CodLEndPostVoidSeries);
                Value[2] := FORMAT(CodLEndPostVoidSeries);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // Void Series
                Value[1] := 'Beg. RETURN #:';
                CodLBegReturnSeries := CheckIfNoSeriesIsEmpty(CodLBegReturnSeries);
                Value[2] := FORMAT(CodLBegReturnSeries);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                Value[1] := 'End. RETURN #:';
                CodLEndReturnSeries := CheckIfNoSeriesIsEmpty(CodLEndReturnSeries);
                Value[2] := FORMAT(CodLEndReturnSeries);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // Old Accumulated Sales
                DSTR1 := '#L################### #R################';
                Value[1] := Text63000;
                Value[2] := POSFunctions.FormatAmount(DecOldAccumulated);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // New Accumulated Sales
                Value[1] := Text63001;
                Value[2] := POSFunctions.FormatAmount(DecNewAccumulated);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                // Reset Counter
                Value[1] := 'Reset Counter';
                IF StartDate <> EndDate THEN BEGIN
                    // FIRST
                    l_ResetCtrCode := '0000';
                    l_ResetCtrCode := CopyStr(l_ResetCtrCode, 1, (4 - Strlen(FORMAT(IntBegAccumResetCtr))));
                    Value[2] := l_ResetCtrCode + FORMAT(IntBegAccumResetCtr);
                    // LAST
                    l_ResetCtrCode := '0000';
                    l_ResetCtrCode := CopyStr(l_ResetCtrCode, 1, (4 - Strlen(FORMAT(IntEndAccumResetCtr))));
                    Value[2] := Value[2] + '-' + l_ResetCtrCode + FORMAT(IntEndAccumResetCtr);
                END ELSE BEGIN
                    l_ResetCtrCode := '0000';
                    l_ResetCtrCode := CopyStr(l_ResetCtrCode, 1, (4 - Strlen(FORMAT(IntBegAccumResetCtr))));
                    Value[2] := l_ResetCtrCode + FORMAT(IntBegAccumResetCtr);
                END;
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                PrintSeperator(2);
                // Z Report ID
                IF StartDate <> EndDate THEN BEGIN
                    cduSender.PrintLine(2, Text116);
                    cduSender.PrintLine(2, ZReportIDFrom + ' to ' + ZReportIDTo);
                END ELSE BEGIN
                    cduSender.PrintLine(2, Text116 + recEODLedgerEntry."Z-Report ID");
                END;
            END;

            IF NOT cduSender.ClosePrinter(2) THEN
                EXIT(FALSE);
        END;
    end;

    local procedure CheckIfNoSeriesIsEmpty(NoSeries: Code[20]): Code[20]
    begin
        IF NoSeries = '' THEN
            exit('000000000000');
        exit(NoSeries);
    end;

    procedure PrintXYZReportNew(RunType: Option X,Z,Y): Boolean
    var
        transactionheader: Record "LSC Transaction Header";
        salesEntry: Record "LSC Trans. Sales Entry";
        PaymTrans2: Record "LSC Trans. Payment Entry";
        PaymTrans3: Record "LSC Trans. Payment Entry";
        PaymTemp: Record "LSC Trans. Payment Entry" temporary;
        Terminal: Record "LSC POS Terminal";
        Staff: Record "LSC Staff";
        Transaction: Record "LSC Transaction Header";
        Transaction2: Record "LSC Transaction Header";
        Transaction3: Record "LSC Transaction Header";
        Transaction4: Record "LSC Transaction Header";
        IncExpAccount: Record "LSC Income/Expense Account";
        IncExpEntry: Record "LSC Trans. Inc./Exp. Entry";
        SuspTrans: Record "LSC POS Transaction";
        TendDeclEntry2: Record "LSC Trans. Tender Declar. Entr";
        IncExpEntry2: Record "LSC Trans. Inc./Exp. Entry";
        TransServerWorkTable: Record "LSC Trans. Server Work Table";
        SuspTransLine: Record "LSC POS Trans. Line";
        POSTransactionSuspend: Record "LSC POS Transaction";
        POSTransactionSuspendTEMP: Record "LSC POS Transaction" temporary;
        POSTransactionSuspendMM: Record "LSC POS Transaction";
        POSTransLineSuspend: Record "LSC POS Trans. Line";
        YReportStats: Record "LSC POS Y-report statistics";
        ZReportStats: Record "LSC POS Z-report statistics";
        TipsBufferTmp: Record "LSC Trans. Inc./Exp. Entry" temporary;
        TipsStaff_l: Record "LSC Staff";
        TransPaymentStaff_l: Record "LSC Trans. Payment Entry";
        StaffPayment_l: Record "LSC Staff";
        ItemCategory_l: Record "Item Category" temporary;
        ProductGroup_l: Record "LSC Retail Product Group" temporary;
        POSVATCode_l: Record "LSC POS VAT Code" temporary;
        recLTransDisc: Record "LSC Trans. Discount Entry";
        CompanyInformation: Record "Company Information";
        STAFFStoreLink: Record "LSC STAFF Store Link";
        XreportStatistics: Record "LSC POS X-report statistics";
        TSUtil: Codeunit "LSC POS Trans. Server Utility";
        POSGUI: Codeunit "LSC POS GUI";
        POSTransaction: Codeunit "LSC POS Transaction";
        FormatAddress: Codeunit "Format Address";
        OldestDate: Date;
        CompanyAddr: array[8] of Text[100];
        DSTR1: Text[80];
        HeaderText: Text[50];
        SCode: Code[20];
        YReportID: Code[10];
        ZReportID: Code[10];
        i: Integer;
        SuspendQuantity: Integer;
        RefundTransCount: Integer;
        PrintHeaderLines: Boolean;
        LineFound: Boolean;
        IsHandled: Boolean;
        ReturnValue: Boolean;
        RemoveTotal: Decimal;
        SalesTotal: Decimal;
        SuspPrepayment: Decimal;
        YReportStatsAmount: Decimal;
        ZReportStatsAmount: Decimal;
        RefundAmount: Decimal;
        TotalSafeType: Decimal;
        SuspendAmount: Decimal;
        RecCount: Integer;
        TransNotSent: Integer;
        NoSuspended: Integer;
        NoSuspPrepayment: Integer;
        TSErr: Integer;
        lSafeType: Integer;
        NoOfLines: Integer;
        NoTables: Integer;
        NoSplitTrans: Integer;
        PosLogAmount: array[6] of Decimal;
        FloatTotal, YReportStatsSalesAmount, ZReportStatsSalesAmount, YReportStatsReturnsAmount, ZReportStatsReturnsAmount, ChargedAmount, GrossAmount, TotalSales, VoidedTransactionsAmount : Decimal;
        PosLogQuantity: array[6] of Integer;
        DiscountQuantity, ChargedTransCount, TotalAddrLine, AddrLineCount : Integer;
        Handled, CumulateIsHandled : Boolean;
        lText001: Label 'No of Trans. not on Z-report';
        lText002: Label '    Date of oldest Trans.';
        lText003: Label 'Total Trans not on Z-report';
        lText004: Label 'Unsent WarrHotel entries';
        Text027: Label 'Total Net Sales';
        Text028: Label 'No. of Transactions';
        Text029: Label 'Items Sold';
        Text030: Label 'No. of Refunds';
        Text031: Label 'No. of Suspended';
        Text032: Label 'No. of Voided Trans.';
        Text034: Label 'No. of Training';
        Text035: Label 'Accumulated total Sales';
        Text036: Label 'Accumulated total Returns';
        Text037: Label 'No. of Open Drawer';
        Text038: Label 'Accumulated total Net';
        Text039: Label 'Total Sales - Refunds';
        Text080: Label 'VAT Registration No.';
        Text112: Label 'Tender declaration:';
        //Text116: Label 'Z-Report ID:'; VINCENT20251211
        Text116: Label 'Z-Reading Counter: ';
        Text117: Label 'Y-Report ID:';
        Text134: Label 'No. of Paying Customers';
        Text139: Label 'No. of logins';
        Text141: Label 'THIS Z IS FOR TERMINAL %1 ONLY!';
        Text153: Label 'Transaction Server Error';
        Text154: Label 'No. Susp. with Payment';
        Text155: Label 'Suspended Prepayment';
        Text161: Label '%1 Transactions are pending';
        Text230: Label 'System Voided';
        Text235: Label 'No. of Covers';
        Text236: Label 'No. of Split Trans.';
        Text237: Label 'Avg. Covers/Table';
        Text238: Label 'Avg. Paying Cust/Tbl';
        Text240: Label 'Amount';
        Text241: Label 'Price check';
        Text242: Label 'Copy receipts';
        Text243: Label 'Pro forma receipts';
        Text244: Label 'including ,excluding ';
        Text245: Label 'Voided lines';
        Text246: Label 'Open Drawer zero registration';
        Text247: Label 'No. of Delivery Receipts';
        Text248: Label 'Reduced Quantity';
        Text300: Label 'Foreign Currency:';
        Text301: Label 'Local and Foreign:';
        Text320: Label 'Float';
        Text321: Label 'Printed from ';
        Text035_NO: Label 'Grand total Sales';
        Text036_NO: Label 'Grand total Returns';
        Text038_NO: Label 'Grand total Net';
        decLGrandTotalNetAmt: Decimal;
        decLGrandTotalVATAmt: Decimal;
        decLGrossSales: Decimal;
        decLLineDiscount: Decimal;
        decLNonVATSales: Decimal;
        decLTotalDiscount: Decimal;
        decLTotalNetAmt: Decimal;
        decLTotalNetSales: Decimal;
        decLTotalVATAmt: Decimal;
        decLTotalVoided: Decimal;
        decLTotalVoidLineAmt: Decimal;
        decLVatableSales: Decimal;
        intLTotalNoOfVoidLine: Integer;
        decLOldAccumulatedSales: Decimal;
        decLNewAccumulatedSales: Decimal;
        intLNoOfRefunds: Integer;
        intLNoOfVoidLine: Integer;
        intLNoOfVoided: Integer;
        intLNoOfTrans: Integer;
        intLNoOfItemSold: Integer;
        intLNoOfTraining: Integer;
        intLNoOfOpenDrawer: Integer;
        intLNoOfLogins: Integer;
        codLBegInvNo: Code[20];
        codLEndInvNo: Code[20];
        codLFirstReceiptNo: Code[20];
        codLLastReceiptNo: Code[20];
        recLTransaction: Record "LSC Transaction Header";
        recLPOSVoidedTrans: Record "LSC POS Voided Transaction";
        recLPOSVoidedLine: Record "LSC POS Voided Trans. Line";
        txtLString: Text;
        decLTotalWHTAmt: Decimal;
        decLTotalVATWAmt: Decimal;
        intLTotalNoOfWHT1: Integer;
        intLTotalNoOfVATW: Integer;
        intLNoOfCashTender: Integer;
        intLNoOfCardTender: Integer;
        decLVAT12: Decimal;
        decLTotalTender: Decimal;
        decLAdjSales: Decimal;
        decLRounding: Decimal;
        dateLTransactionDate: Date;
        recLStore: Record "LSC Store";
        TransactionLocal: Record "LSC Transaction Header";
        intLTotalNoOfCash: Integer;
        intLTotalNoOfZero: Integer;
        intLTotalNoOfBOI: Integer;
        intLTotalNoOfSRC: Integer;
        intLTotalNoOfPWD: Integer;
        decLTotalCashTrans: Decimal;
        decLTotalZeroTrans: Decimal;
        decLTotalBOIAmount: Decimal;
        decLTotalSRCDisc: Decimal;
        decLTotalSRCTrans: Decimal;
        decLTotalPWDDisc: Decimal;
        decLTotalPWDTrans: Decimal;
        StaffLocal: Record "LSC Staff";
        blankStr: Text[30];
        recEODLedgerEntry: Record "End Of Day Ledger";
        intLTotalNoOfSOLO: Integer;
        decLTotalSOLODisc: Decimal;
        decLTotalSOLOTrans: Decimal;
        intLTotalNoOfATHL: Integer;
        decLTotalATHLDisc: Decimal;
        decLTotalATHLTrans: Decimal;
        recNoOfTransaction: Record "LSC Transaction Header";
        recNoOfItems: Record "LSC Transaction Header";
        recNoOfOpenDrawer: Record "LSC Transaction Header";
        recLTransPaymentEntries: Record "LSC Trans. Payment Entry";
        intLNoOfReturns: Integer;
        decTotalReturns: Decimal;
        recTransPaymentEntries1: Record "LSC Trans. Payment Entry";
        recTransPaymentEntries2: Record "LSC Trans. Payment Entry";
        decLVATDetailsTotalNetSales: Decimal;
        decLVATDetailsVatableSales: Decimal;
        decLVATDetailsVATAmount: Decimal;
        recLTransHeader: Record "LSC Trans. Sales Entry";
        decLCashTakeout: Decimal;
        TotalVAtExempt: Decimal;
        TotalZeroRated: Decimal;
        TotalVATABLESALES: Decimal;
        TotalVATAmount: Decimal;
        x: Decimal;
        TotalVatDetails: Decimal;
        recLTransHeader1, recLTransHeader2 : Record "LSC Transaction Header";
        LRetailSetup: Record "LSC Retail Setup";
        lPOSTerminal: Record "LSC POS Terminal";
        GenerateSalesUponEOD: Boolean;
        lStore: Record "LSC Store";
        XReportID: Code[10];
        codLayalabegin: Code[10];
        codLayalaend: Code[10];
        recLTransactionHeader: Record "LSC Transaction Header";
        recLTransPaymentEntry: Record "LSC Trans. Payment Entry";
        recLTransPaymentEntry2: Record "LSC Trans. Payment Entry";
        recLTransIncomeExpenseEntry: Record "LSC Trans. Inc./Exp. Entry";
        recLTransTenderDeclare: Record "LSC Trans. Tender Declar. Entr";
        recLTenderTypes: Record "LSC Tender Type";
        decLTenderAmount: Decimal;
        intLTenderCount: Integer;
        recLAccumSalesLedger: Record "End Of Day Ledger";
        intLEntryNo: Integer;
        recLIncomeExpense: Record "LSC Income/Expense Account";
        decLHandlingCharge: Decimal;
        recLStoreIncExp: Record "LSC Store";
        recLTransHeaderVATDetails: Record "LSC Transaction Header";
        decLServiceCharge: Decimal;
        recLVATSetup: Record "LSC POS VAT Code";
        decLTotalRefund: Decimal;
        Text63000: Label 'Old Accumulated Sales';
        Text63001: Label 'New Accumulated Sales';
        Text63002: Label 'Beg. SI #:';
        Text63003: Label 'End. SI #:';
        Text63004: Label 'Total Refund Amount';
        Text63005: Label 'Total Voided Trans.';
        Text63006: Label 'No. of Voided Line';
        Text63007: Label 'Total Voided Line';
        Text63008: Label 'Y-REPORT (Terminal)';
        Text63009: Label 'Invoice No.';
        Text63010: Label 'Store';
        Text63011: Label 'InvNo';
        Text63012: Label 'Date Printed :';
        Text63013: Label 'What Floor :';
        Text63014: Label 'Cancelled Line Disc.';
        l_ResetCtrCode: Code[4];
        l_ResetCtrInt: Integer;
        decLTotalRefundTrans: Code[10];
        decLTotalPayingCustomer: Code[10];
        BegVoid: Code[12];
        EndVoid: Code[12];
        BegReturn: Code[12];
        EndReturn: Code[12];
    begin
        gTimeStart := Format(Time());

        if not Staff.Get(Globals.StaffID) then
            exit(true);
        if not Terminal.Get(Globals.TerminalNo) then
            exit(true);

        optRunType := RunType;

        if not cduSender.OpenReceiptPrinter(2, 'TENDER', 'ZXREPORT', 0, '') then
            exit(false);

        if not Terminal."Terminal Statement" then
            Terminal."Statement Method" := Store."Statement Method";

        CLEAR(decLGrandTotalNetAmt);
        CLEAR(decLGrandTotalVATAmt);
        CLEAR(decLGrossSales);
        CLEAR(decLLineDiscount);
        CLEAR(decLNonVATSales);
        CLEAR(decLTotalDiscount);
        CLEAR(decLTotalNetAmt);
        CLEAR(decLTotalNetSales);
        CLEAR(decLTotalVATAmt);
        CLEAR(decLTotalVoidLineAmt);
        CLEAR(decLVatableSales);
        CLEAR(intLTotalNoOfVoidLine);

        Terminal.CalcFields("Accumulated Sales");
        decLOldAccumulatedSales := Terminal."Accumulated Sales";

        TransDate := GetTransactionDate();

        dateLTransactionDate := TransDate;
        //Print Header info
        /* DSTR1 := '#L######## #L#########';
        Value[1] := Text078 + ':';
        Value[2] := Store."No.";
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, true, false, false)); */

        if Terminal."Statement Method" = Terminal."Statement Method"::"POS Terminal" then begin
            DSTR1 := '#L####### #L########';
            Value[1] := Text079 + ':';
            Value[2] := Terminal."No.";
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, true, false, false));
        end;

        SCode := POSFunctions.GetStatementCode;

        Transaction.Date := TransDate;
        Transaction.Time := Time;
        PrintLogo(2);
        cduSender.PrintHeader(Transaction, false, 2);

        DSTR1 := '#L########### #T###### #T### #T####### ';
        Value[1] := 'Trans. Date:';
        Value[2] := FORMAT(TransDate);
        Value[3] := 'POS:';
        Value[4] := FORMAT(Terminal."No.");
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

        DSTR1 := '#L########### #T###### #T#######';
        Value[1] := 'Printed Date:';
        Value[2] := FORMAT(TODAY());
        Value[3] := Format(Time, 8, '<Hours24,2>:<Minutes,2>:<Seconds,2>');// FORMAT(TIME(), 5);

        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

        DSTR1 := '#L###### #L###########  #T###### #T#####  ';
        Value[1] := Text051 + ':';
        IF Staff."Name on Receipt" <> '' THEN
            Value[2] := Staff."Name on Receipt"
        ELSE
            Value[2] := Globals.StaffID;

        gStaffName := Value[2];

        Value[3] := 'Store #:';
        Value[4] := Globals.StoreNo();

        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, true, false, false));
        PrintSeperator(2);

        //X or Z Report..
        DSTR1 := '#C###################';

        case RunType of
            RunType::Z:
                Value[1] := Text90004;
            RunType::X:
                Value[1] := Text90001;
            RunType::Y:
                Value[1] := Text90002;
        end;
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), true, true, true, false));
        cduSender.AddPrintLine(200, 2, NodeName, Value, DSTR1, false, true, false, false, 2);
        if GenPosFunc."TS Floating Cashier" and
           (Terminal."Statement Method" = Terminal."Statement Method"::Staff) and
           (Globals.GetValue('TS_ERROR') <> '') then begin
            cduSender.PrintLine(2, '');
            cduSender.PrintLine(2, FormatLine(StrSubstNo(Text141, Terminal."No."), false, true, false, false));
        end;

        PrintSeperator(2);

        CASE RunType OF
            RunType::X:
                SCode := Globals.StaffID();
            RunType::Y:
                SCode := Globals.TerminalNo;
            RunType::Z:
                SCode := '';
        END;
        // Report Body
        //  Line per Tender Type
        Clear(PaymEntry);


        CASE RunType OF
            RunType::X:
                BEGIN
                    PaymEntry.SETCURRENTKEY("Staff ID", "Z-Report ID", "Tender Type", "Currency Code", "Card No.", Date, Time);
                    PaymEntry.SETRANGE("Staff ID", SCode);
                    PaymEntry.SETRANGE(PaymEntry."Cashier Report ID", '');
                END;
            RunType::Y:
                BEGIN
                    recLStore.RESET;
                    recLStore.SETRANGE(recLStore."No.", Globals.StoreNo);
                    IF recLStore.FINDFIRST THEN
                        IF NOT Store."Global Setup" THEN BEGIN
                            PaymEntry.SETCURRENTKEY("POS Terminal No.", "Z-Report ID", "Tender Type", "Currency Code", "Card No.", Date, Time);
                            PaymEntry.SETRANGE("POS Terminal No.", SCode);
                        END;
                END;
            RunType::Z:
                BEGIN
                    PaymEntry.SETCURRENTKEY("Statement Code", "Z-Report ID", "Tender Type", "Currency Code", "Card No.", Date, Time);
                    //PaymEntry.SETRANGE("Statement Code",SCode);
                    PaymEntry.SETRANGE(PaymEntry."Store No.", Globals.StoreNo);
                END;
        END;

        PaymEntry.SETRANGE("Z-Report ID", '');
        IF RunType = RunType::X THEN
            PaymEntry.SETRANGE("Cashier Report ID", '');

        IF recRetailCalendarLine.FINDLAST THEN BEGIN
            IF recRetailCalendarLine."Midnight Open" THEN BEGIN
                IF recRetailCalendarLine."Time To" > TIME THEN BEGIN
                    vDay := CALCDATE('<-1D>', TransDate);
                    PaymEntry.SETFILTER(PaymEntry.Date, '%1', vDay)
                END ELSE
                    PaymEntry.SETFILTER(PaymEntry.Date, '%1', TransDate);
            END ELSE
                PaymEntry.SETFILTER(PaymEntry.Date, '%1', TransDate);
        END ELSE BEGIN
            PaymEntry.SETFILTER(PaymEntry.Date, '%1', TransDate);
        END;

        PaymTrans3.CopyFilters(PaymEntry);

        TenderType.SetCurrentKey("Store No.");
        TenderType.SetRange("Store No.", Globals.StoreNo);
        TenderType.SetFilter(TenderType."Function", '<>%1', TenderType."Function"::"Tender Remove/Float");
        TenderType.SetRange("Foreign Currency", false);
        LocalTotal := 0;
        recReportBuffer.DeleteAll();
        AssignTenderDetailstoBuffer(PaymTrans3);
        if RunType = RunType::X then
            PrintXZLines(SCode)
        else
            PrintXZLines('');

        //  Totals for LCY
        IF LocalTotal <> 0 THEN BEGIN
            PrintSeperator(2);
            DSTR1 := '#L########          #R##################';
            Value[1] := Text005 + ':';
            Value[2] := POSFunctions.FormatAmount(LocalTotal);
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

        END;
        decLTotalTender := LocalTotal;

        //  Totals for FCY
        cduSender.PrintLine(2, '');
        TenderType.SETRANGE("Foreign Currency", TRUE);

        TotalLCYInCurrency := 0;
        PrintXZLines('');
        IF TotalLCYInCurrency <> 0 THEN BEGIN
            PrintSeperator(2);
            DSTR1 := '#L##################### #R##############';
            Value[1] := Text300;
            Value[2] := POSFunctions.FormatAmount(TotalLCYInCurrency);
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            cduSender.PrintLine(2, '');
            PrintSeperator(2);
            DSTR1 := '#L##################### #R##############';
            Value[1] := Text301;
            Value[2] := POSFunctions.FormatAmount(LocalTotal);
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            PrintSeperator(2);
        END;

        CLEAR(RemoveTotal);
        CLEAR(FloatTotal);
        TransactionLocal.RESET;
        TransactionLocal.SETRANGE("Z-Report ID", '');
        IF (RunType = RunType::X) THEN
            TransactionLocal.SETRANGE("Cashier Report ID", '');
        TransactionLocal.SETRANGE("Transaction Type", TransactionLocal."Transaction Type"::"Float Entry");
        //TransactionLocal.SETRANGE(Date,TODAY);
        recRetailCalendarLine.RESET;
        recRetailCalendarLine.SETRANGE(recRetailCalendarLine."Calendar ID", POSSESSION.StoreNo);
        IF recRetailCalendarLine.FINDLAST THEN BEGIN
            IF recRetailCalendarLine."Midnight Open" THEN BEGIN
                IF recRetailCalendarLine."Time To" > TIME THEN BEGIN
                    vDay := CALCDATE('<-1D>', TransDate);
                    TransactionLocal.SETFILTER(TransactionLocal.Date, '%1', vDay)
                END ELSE
                    TransactionLocal.SETFILTER(TransactionLocal.Date, '%1', TransDate);
            END ELSE
                TransactionLocal.SETFILTER(TransactionLocal.Date, '%1', TransDate);
        END ELSE BEGIN
            TransactionLocal.SETFILTER(TransactionLocal.Date, '%1', TransDate);
        END;
        CASE RunType OF
            RunType::X:
                TransactionLocal.SETRANGE("Staff ID", Globals.StaffID);
            RunType::Y:
                BEGIN
                    recLStore.RESET;
                    recLStore.SETRANGE(recLStore."No.", Globals.StoreNo);
                    IF recLStore.FINDFIRST THEN
                        IF NOT Store."Global Setup" THEN BEGIN
                            TransactionLocal.SETRANGE("POS Terminal No.", Globals.TerminalNo);
                        END;
                END;
            RunType::Z:
                TransactionLocal.SETRANGE("Store No.", Globals.StoreNo);
        END;


        IF TransactionLocal.FINDFIRST THEN
            REPEAT
                recLTransPaymentEntry2.Reset();
                recLTransPaymentEntry2.SetRange("Store No.", TransactionLocal."Store No.");
                recLTransPaymentEntry2.SetRange("POS Terminal No.", TransactionLocal."POS Terminal No.");
                recLTransPaymentEntry2.SetRange("Transaction No.", TransactionLocal."Transaction No.");
                recLTransPaymentEntry2.SetFilter("Tender Type", '<>9');
                if recLTransPaymentEntry2.FindFirst() then
                    repeat
                        FloatTotal := FloatTotal + recLTransPaymentEntry2."Amount Tendered";
                    until recLTransPaymentEntry2.Next() = 0;
            UNTIL TransactionLocal.NEXT = 0;
        PrintSeperator(2);
        DSTR1 := '#L##############    #R##################';
        Value[1] := Text009 + ':';
        Value[2] := POSFunctions.FormatAmount(FloatTotal);
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));

        // Remove Tender
        TransactionLocal.RESET;
        TransactionLocal.SETRANGE("Z-Report ID", '');
        IF (RunType = RunType::X) THEN
            TransactionLocal.SETRANGE("Cashier Report ID", '');
        TransactionLocal.SETRANGE("Transaction Type", TransactionLocal."Transaction Type"::"Remove Tender");
        //TransactionLocal.SETRANGE(Date,TODAY);
        recRetailCalendarLine.RESET;
        recRetailCalendarLine.SETRANGE(recRetailCalendarLine."Calendar ID", POSSESSION.StoreNo);
        IF recRetailCalendarLine.FINDLAST THEN BEGIN
            IF recRetailCalendarLine."Midnight Open" THEN BEGIN
                IF recRetailCalendarLine."Time To" > TIME THEN BEGIN
                    vDay := CALCDATE('<-1D>', TransDate);
                    TransactionLocal.SETFILTER(TransactionLocal.Date, '%1', vDay)
                END ELSE
                    TransactionLocal.SETFILTER(TransactionLocal.Date, '%1', TransDate);
            END ELSE
                TransactionLocal.SETFILTER(TransactionLocal.Date, '%1', TransDate);
        END ELSE BEGIN
            TransactionLocal.SETFILTER(TransactionLocal.Date, '%1', TransDate);
        END;
        CASE RunType OF
            RunType::X:
                TransactionLocal.SETRANGE("Staff ID", Globals.StaffID);
            RunType::Y:
                BEGIN
                    recLStore.RESET;
                    recLStore.SETRANGE(recLStore."No.", Globals.StoreNo);
                    IF recLStore.FINDFIRST THEN
                        IF NOT Store."Global Setup" THEN BEGIN
                            TransactionLocal.SETRANGE("POS Terminal No.", Globals.TerminalNo);
                        END;
                END;
            RunType::Z:
                TransactionLocal.SETRANGE("Store No.", Globals.StoreNo);
        END;


        IF TransactionLocal.FINDFIRST THEN
            REPEAT
                recLTransPaymentEntry2.Reset();
                recLTransPaymentEntry2.SetRange("Store No.", TransactionLocal."Store No.");
                recLTransPaymentEntry2.SetRange(Date, TransactionLocal.Date);
                recLTransPaymentEntry2.SetRange("POS Terminal No.", TransactionLocal."POS Terminal No.");
                recLTransPaymentEntry2.SetRange("Transaction No.", TransactionLocal."Transaction No.");
                recLTransPaymentEntry2.SetFilter("Tender Type", '<>9');
                if recLTransPaymentEntry2.FindFirst() then
                    repeat
                        RemoveTotal := RemoveTotal + recLTransPaymentEntry2."Amount Tendered";
                    until recLTransPaymentEntry2.Next() = 0;
            UNTIL TransactionLocal.NEXT = 0;

        DSTR1 := '#L##############    #R##################';
        Value[1] := Text010 + ':';
        Value[2] := POSFunctions.FormatAmount(RemoveTotal);
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));

        IF (LocalTotal <> 0) OR (FloatTotal <> 0) OR (RemoveTotal <> 0) THEN
            PrintSeperator(2);

        //  Tender Declaration
        Transaction."Transaction No." := 0;
        CASE RunType OF
            RunType::X:
                BEGIN
                    TendDeclEntry.SETCURRENTKEY("Staff ID", "Z-Report ID", "Tender Type", "Currency Code", "Card No.", Date, Time);
                    TendDeclEntry.SETRANGE("Staff ID", SCode);
                    TendDeclEntry.SETRANGE(TendDeclEntry."Cashier Report ID", '');
                END;
            RunType::Y:
                BEGIN
                    TendDeclEntry.SETCURRENTKEY("POS Terminal No.", "Z-Report ID", "Tender Type", "Currency Code", "Card No.", Date, Time);
                    recLStore.RESET;
                    recLStore.SETRANGE(recLStore."No.", Globals.StoreNo);
                    IF recLStore.FINDFIRST THEN
                        IF NOT Store."Global Setup" THEN BEGIN
                            TendDeclEntry.SETRANGE("POS Terminal No.", SCode);
                        END;
                END;
            RunType::Z:
                BEGIN
                    TendDeclEntry.SETCURRENTKEY("Statement Code", "Z-Report ID", "Tender Type", "Currency Code", "Card No.", Date, Time);
                    TendDeclEntry.SETRANGE(TendDeclEntry."Store No.", Globals.StoreNo);
                END;
        END;

        TendDeclEntry.SETRANGE("Z-Report ID", '');
        IF RunType = RunType::X THEN
            TendDeclEntry.SETRANGE("Cashier Report ID", '');

        recRetailCalendarLine.RESET;
        recRetailCalendarLine.SETRANGE(recRetailCalendarLine."Calendar ID", POSSESSION.StoreNo);
        IF recRetailCalendarLine.FINDLAST THEN BEGIN
            IF recRetailCalendarLine."Midnight Open" THEN BEGIN
                IF recRetailCalendarLine."Time To" > TIME THEN BEGIN
                    vDay := CALCDATE('<-1D>', TransDate);
                    TendDeclEntry.SETFILTER(TendDeclEntry.Date, '%1', vDay)
                END ELSE
                    TendDeclEntry.SETFILTER(TendDeclEntry.Date, '%1', TransDate);
            END ELSE
                TendDeclEntry.SETFILTER(TendDeclEntry.Date, '%1', TransDate);
        END ELSE BEGIN
            TendDeclEntry.SETFILTER(TendDeclEntry.Date, '%1', TransDate);
        END;


        IF Store."Tend. Decl. Calculation" = Store."Tend. Decl. Calculation"::Sum THEN BEGIN
            BufferTendDeclEntry;
            IF TendDeclEntry.FIND('-') THEN
                Transaction."Transaction No." := TendDeclEntry."Transaction No.";
        END ELSE BEGIN
            IF TendDeclEntry.FIND('-') THEN
                REPEAT
                    IF TendDeclEntry."Transaction No." > Transaction."Transaction No." THEN
                        Transaction.GET(TendDeclEntry."Store No.", TendDeclEntry."POS Terminal No.", TendDeclEntry."Transaction No.")
                UNTIL TendDeclEntry.NEXT = 0;
        END;

        IF Transaction."Transaction No." <> 0 THEN BEGIN
            cduSender.PrintLine(2, FormatLine(Text112, FALSE, TRUE, FALSE, FALSE));
            CLEAR(TendDeclEntry);
            LocalTotal := 0;
            IF Store."Tend. Decl. Calculation" = Store."Tend. Decl. Calculation"::Last THEN BEGIN
                TendDeclEntry.SETCURRENTKEY("Store No.", "POS Terminal No.", "Transaction No.");
                TendDeclEntry.SETRANGE("Store No.", Transaction."Store No.");
                TendDeclEntry.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
                TendDeclEntry.SETRANGE("Transaction No.", Transaction."Transaction No.");
                IF RunType = RunType::X THEN BEGIN
                    TendDeclEntry.SETRANGE(TendDeclEntry."Cashier Report ID", '');
                    TendDeclEntry.SETRANGE(TendDeclEntry."Staff ID", Globals.StaffID);
                END;
                BufferTendDeclEntry;
            END;
            TempTendDeclEntry.SETFILTER("Currency Code", '=%1', '');
            IF RunType = RunType::X THEN BEGIN
                TempTendDeclEntry.SETRANGE(TempTendDeclEntry."Cashier Report ID", '');
                TempTendDeclEntry.SETRANGE(TempTendDeclEntry."Staff ID", Globals.StaffID);
            END;
            PrintTenderDeclLines;
            PrintCashDeclTotalLCYLine(LocalTotal);
            cduSender.PrintLine(2, '');
            IF RunType = RunType::X THEN BEGIN
                TempTendDeclEntry.SETRANGE(TempTendDeclEntry."Cashier Report ID", '');
                TempTendDeclEntry.SETRANGE(TempTendDeclEntry."Staff ID", Globals.StaffID);
            END;
            TempTendDeclEntry.SETFILTER("Currency Code", '<>%1', '');
            PrintTenderDeclLines;
            PrintSeperator(2);
        END;
        ShortOver := ROUND(LocalTotal - TotalCashAmount, 0.01);



        CASE RunType OF
            RunType::X:
                BEGIN
                    Transaction.SETCURRENTKEY("Staff ID", "Z-Report ID", "Transaction Type", "Entry Status", Date, Time);
                    Transaction.SETRANGE("Staff ID", SCode);
                    Transaction.SETRANGE(Transaction."Cashier Report ID", '');
                END;
            RunType::Y:
                BEGIN
                    Transaction.SETCURRENTKEY("POS Terminal No.", "Z-Report ID", "Transaction Type", "Entry Status", Date, Time);
                    recLStore.RESET;
                    recLStore.SETRANGE(recLStore."No.", Globals.StoreNo);
                    IF recLStore.FINDFIRST THEN
                        IF NOT Store."Global Setup" THEN BEGIN
                            Transaction.SETRANGE("POS Terminal No.", SCode);
                        END;
                END;
            RunType::Z:
                BEGIN
                    Transaction.SETCURRENTKEY("Statement Code", "Z-Report ID", "Transaction Type", "Entry Status", Date, Time);
                    Transaction.SETRANGE(Transaction."Store No.", Globals.StoreNo);
                END;
        END;

        IF (RunType = RunType::X) THEN
            Transaction.SETRANGE("Cashier Report ID", '');
        Transaction.SETRANGE("Z-Report ID", '');
        IF RunType = RunType::X THEN
            Transaction.SETRANGE("Cashier Report ID", '');
        Transaction.SETRANGE("Transaction Type", Transaction."Transaction Type"::Sales);
        Transaction.SETFILTER("Entry Status", '%1|%2', Transaction."Entry Status"::" ", Transaction."Entry Status"::Posted);
        recRetailCalendarLine.RESET;
        recRetailCalendarLine.SETRANGE(recRetailCalendarLine."Calendar ID", POSSESSION.StoreNo);
        IF recRetailCalendarLine.FINDLAST THEN BEGIN
            IF recRetailCalendarLine."Midnight Open" THEN BEGIN
                IF recRetailCalendarLine."Time To" > TIME THEN BEGIN
                    vDay := CALCDATE('<-1D>', TransDate);
                    Transaction.SETFILTER(Transaction.Date, '%1', vDay)
                END ELSE
                    Transaction.SETFILTER(Transaction.Date, '%1', TransDate);
            END ELSE
                Transaction.SETFILTER(Transaction.Date, '%1', TransDate);
        END ELSE BEGIN
            Transaction.SETFILTER(Transaction.Date, '%1', TransDate);
        END;


        Transaction.CALCSUMS("Gross Amount", "Discount Amount", "Total Discount", Rounded, "No. of Items",
                             "No. of Covers", "WHT Amount", "VAT Withholding", "Net Amount", "ZRWHT Amount");

        CLEAR(decLTotalWHTAmt);
        CLEAR(decLTotalVATWAmt);
        CLEAR(intLTotalNoOfWHT1);
        CLEAR(intLTotalNoOfVATW);
        CLEAR(intLNoOfCashTender);
        CLEAR(intLNoOfCardTender);

        decLTotalWHTAmt := Transaction."WHT Amount";
        decLTotalVATWAmt := Transaction."VAT Withholding";

        recLTransaction.RESET;
        recLTransaction.COPY(Transaction);
        IF RunType = RunType::X THEN
            recLTransaction.SETRANGE(recLTransaction."Cashier Report ID", '');
        IF recLTransaction.FINDFIRST THEN
            REPEAT

                CASE recLTransaction."Transaction Code Type" OF
                    recLTransaction."Transaction Code Type"::WHT1:
                        intLTotalNoOfWHT1 += 1;
                    recLTransaction."Transaction Code Type"::VATW:
                        intLTotalNoOfVATW += 1;
                    recLTransaction."Transaction Code Type"::REG:
                        BEGIN
                            intLTotalNoOfCash += 1;
                            decLTotalCashTrans += recLTransaction."Gross Amount";
                            recLTransDisc.Reset();

                            recLTransDisc.SetRange("Receipt No.", recLTransaction."Receipt No.");
                            if recLTransDisc.FINDFIRST then
                                repeat
                                    decLLineDiscount += ROUND(recLTransDisc."Discount Amount");
                                until recLTransDisc.next() = 0;
                            // decLLineDiscount += ROUND(recLTransaction."Discount Amount", 0.01);
                        END;
                    recLTransaction."Transaction Code Type"::"Regular Customer":
                        BEGIN
                            recLTransDisc.Reset();
                            recLTransDisc.SetRange("Receipt No.", recLTransaction."Receipt No.");
                            if recLTransDisc.FINDFIRST then
                                repeat
                                    decLLineDiscount += ROUND(recLTransDisc."Discount Amount");
                                until recLTransDisc.next() = 0;
                            // decLLineDiscount += ROUND(recLTransaction."Discount Amount", 0.01);
                        END;

                    recLTransaction."Transaction Code Type"::ZERO:
                        BEGIN
                            intLTotalNoOfZero += 1;
                            decLTotalZeroTrans += recLTransaction."Gross Amount";
                        END;
                    recLTransaction."Transaction Code Type"::ZRWH:
                        BEGIN
                            intLTotalNoOfBOI += 1;
                            decLTotalBOIAmount += recLTransaction."Gross Amount";
                        END;
                    recLTransaction."Transaction Code Type"::"SC":
                        BEGIN
                            intLTotalNoOfSRC += 1;
                            decLTotalSRCDisc += ROUND(recLTransaction."Discount Amount", 0.01);
                            decLTotalSRCTrans += recLTransaction."Gross Amount";
                        END;
                    recLTransaction."Transaction Code Type"::PWD:
                        BEGIN
                            intLTotalNoOfPWD += 1;
                            decLTotalPWDDisc += ROUND(recLTransaction."Discount Amount", 0.01);
                            decLTotalPWDTrans += recLTransaction."Gross Amount";
                        END;
                    recLTransaction."Transaction Code Type"::SOLO:
                        BEGIN
                            intLTotalNoOfSOLO += 1;
                            decLTotalSOLODisc += ROUND(recLTransaction."Discount Amount", 0.01);
                            decLTotalSOLOTrans += recLTransaction."Gross Amount";
                        END;
                    /* recLTransaction."Transaction Code Type"::ATHL:
                        BEGIN
                            intLTotalNoOfATHL += 1;
                            decLTotalATHLDisc += ROUND(recLTransaction."Discount Amount", 0.01);
                            decLTotalATHLTrans += recLTransaction."Gross Amount";
                        END; */
                    recLTransaction."Transaction Code Type"::MOV:
                        BEGIN
                            // intLTotalNoOfATHL += 1;
                            // decLTotalATHLDisc += ROUND(recLTransaction."Discount Amount", 0.01);
                            // decLTotalATHLTrans += recLTransaction."Gross Amount";
                        END;
                    recLTransaction."Transaction Code Type"::NAAC:
                        BEGIN
                            intLTotalNoOfATHL += 1;
                            decLTotalATHLDisc += ROUND(recLTransaction."Discount Amount", 0.01);
                            decLTotalATHLTrans += recLTransaction."Gross Amount";
                        END;
                END;

            UNTIL recLTransaction.NEXT = 0;

        DSTR1 := '#L################ #R###################';//Abs(Transaction."Total Discount") + Abs(decLLineDiscount)
        Value[2] := POSFunctions.FormatAmount(Abs(Transaction."Gross Amount") + Abs(Transaction."Total Discount") + ABS(decLTotalATHLDisc) + Abs(decLTotalSRCDisc) + Abs(decLTotalPWDDisc) + Abs(decLTotalSOLODisc) + Abs(decLLineDiscount));
        //Value[2] := POSFunctions.FormatAmount(-Transaction."Gross Amount");// + decLTotalSRCDisc + decLTotalPWDDisc + decLTotalSOLODisc + decLTotalATHLDisc);
        Value[1] := Text011;
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
        //decLGrossSales := -Transaction."Gross Amount" + decLTotalSRCDisc + decLTotalPWDDisc + decLTotalSOLODisc + decLTotalATHLDisc;
        Evaluate(decLGrossSales, Value[2]);
        //(DISCOUNT AMOUNT ON XYZ REPORT)
        Transaction.SETRANGE(Transaction."Sale Is Return Sale", FALSE);

        Transaction.SETRANGE("Z-Report ID", '');
        IF RunType = RunType::X THEN BEGIN
            Transaction.SETRANGE("Cashier Report ID", '');
            Transaction.SETRANGE("Staff ID", POSSESSION.StaffID);
        END;
        IF RunType = RunType::Y THEN BEGIN
            Transaction.SETRANGE("POS Terminal No.", POSSESSION.TerminalNo);
        END;

        Transaction.CALCSUMS(Transaction."Total Discount");
        DSTR1 := '#L###################################';
        Value[1] := 'Discount';
        DSTR1 := '#L###########################';
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

        // MARCUS 20251227
        decLTotalDiscount := Abs(Abs(Transaction."Total Discount") + Abs(decLLineDiscount) + Abs(decLTotalSOLODisc + decLTotalPWDDisc + decLTotalSRCDisc + decLTotalATHLDisc));
        // EVALUATE(decLTotalDiscount, Value[2]);

        //cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
        //decLLineDiscount := Abs(Transaction."Total Discount" - Abs(decLTotalSOLODisc + decLTotalPWDDisc + decLTotalSRCDisc));
        Value[1] := ' Line disc./Total disc.';
        Value[2] := POSFunctions.FormatAmount(Abs(Transaction."Total Discount") + Abs(decLLineDiscount));

        DSTR1 := '#L################### #R###############';
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        Value[1] := ' NAAC'; //VINCENT20251211
        Value[2] := POSFunctions.FormatAmount(decLTotalATHLDisc);
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        /* Value[1] := ' ATHL'; //VINCENT20251211
        Value[2] := POSFunctions.FormatAmount(decLTotalATHLDisc);
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE)); */
        Value[1] := ' SOLO';
        Value[2] := POSFunctions.FormatAmount(decLTotalSOLODisc);
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        Value[1] := ' PWD';
        Value[2] := POSFunctions.FormatAmount(ROUND(decLTotalPWDDisc, 0.01));
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        Value[1] := ' SC';
        Value[2] := POSFunctions.FormatAmount(ROUND(decLTotalSRCDisc, 0.01));
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

        Value[1] := ' Total Discount';
        Value[2] := POSFunctions.FormatAmount(Abs(Abs(Transaction."Total Discount") + Abs(decLLineDiscount) + Abs(decLTotalSOLODisc + decLTotalPWDDisc + decLTotalSRCDisc + decLTotalATHLDisc)));
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));

        PrintSeperator(2);
        DSTR1 := '#L################ #R###################';
        Value[1] := Text027;
        Value[2] := POSFunctions.FormatAmount(-Transaction."Gross Amount");
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        EVALUATE(decLTotalNetSales, Value[2]);

        PrintSeperator(2);
        IncExpAccount.SETRANGE(IncExpAccount."Store No.", Globals.StoreNo);
        IF IncExpAccount.FIND('-') THEN BEGIN

            CASE RunType OF
                RunType::X:
                    BEGIN
                        IncExpEntry.SETCURRENTKEY("Staff ID", "Z-Report ID", "No.", Date, Time);
                        IncExpEntry.SETRANGE("Staff ID", SCode);
                        IncExpEntry.SETRANGE(IncExpEntry."Cashier Report ID", '');
                    END;
                RunType::Y:
                    BEGIN
                        IncExpEntry.SETCURRENTKEY("POS Terminal No.", "Z-Report ID", "No.", Date, Time);
                        recLStore.RESET;
                        recLStore.SETRANGE(recLStore."No.", Globals.StoreNo);
                        IF recLStore.FINDFIRST THEN
                            IF NOT Store."Global Setup" THEN BEGIN
                                IncExpEntry.SETRANGE("POS Terminal No.", SCode);
                            END;
                    END;
                RunType::Z:
                    BEGIN
                        IncExpEntry.SETCURRENTKEY("Statement Code", "Z-Report ID", "No.", Date, Time);

                        IncExpEntry.SETRANGE(IncExpEntry."Store No.", Globals.StoreNo);
                    END;
            END;

            IncExpEntry.SETRANGE("Z-Report ID", '');
            IF RunType = RunType::X THEN
                IncExpEntry.SETRANGE(IncExpEntry."Cashier Report ID", '');
            recRetailCalendarLine.RESET;
            recRetailCalendarLine.SETRANGE(recRetailCalendarLine."Calendar ID", POSSESSION.StoreNo);
            IF recRetailCalendarLine.FINDLAST THEN BEGIN
                IF recRetailCalendarLine."Midnight Open" THEN BEGIN
                    IF recRetailCalendarLine."Time To" > TIME THEN BEGIN
                        vDay := CALCDATE('<-1D>', TransDate);
                        IncExpEntry.SETFILTER(IncExpEntry.Date, '%1', vDay)
                    END ELSE
                        IncExpEntry.SETFILTER(IncExpEntry.Date, '%1', TransDate);
                END ELSE
                    IncExpEntry.SETFILTER(IncExpEntry.Date, '%1', TransDate);
            END ELSE BEGIN
                IncExpEntry.SETFILTER(IncExpEntry.Date, '%1', TransDate);
            END;
            IF RunType = RunType::Y THEN
                IncExpEntry.SETRANGE("Z-Report ID", '');
            IF IncExpEntry.FIND('-') THEN BEGIN
                REPEAT
                    IncExpEntry.SETRANGE("No.", IncExpAccount."No.");
                    IF IncExpEntry.FIND('-') THEN BEGIN
                        Value[1] := IncExpAccount.Description;
                        IncExpEntry.CALCSUMS(Amount);

                        //Service Charge ---
                        recLStoreIncExp.RESET;
                        recLStoreIncExp.SETRANGE("Service Charge No.", IncExpEntry."No.");
                        IF recLStoreIncExp.FINDFIRST THEN BEGIN
                            decLServiceCharge := ABS(IncExpEntry.Amount);
                        END;
                        //Delivery Charge ---
                        recLStoreIncExp.RESET;
                        recLStoreIncExp.SETRANGE("Delivery Charge No.", IncExpEntry."No.");
                        IF recLStoreIncExp.FINDFIRST THEN BEGIN
                            decDeliveryCharge := ABS(IncExpEntry.Amount);
                        END;
                        //Handling Charge ---
                        recLStoreIncExp.RESET;
                        recLStoreIncExp.SETRANGE("Handling Charge No.", IncExpEntry."No.");
                        IF recLStoreIncExp.FINDFIRST THEN BEGIN
                            decLHandlingCharge := ABS(IncExpEntry.Amount);
                        END;

                        Value[2] := POSFunctions.FormatAmount(-IncExpEntry.Amount);
                        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                        IF (IncExpAccount."Service Charge %" <> 0) THEN
                            decLServiceCharge += IncExpAccount.Amount;
                        IF (IncExpAccount."Gratuity Type" = IncExpAccount."Gratuity Type"::Tips) AND
                          (IncExpAccount."Account Type" = IncExpAccount."Account Type"::Expense)
                        THEN
                            BufferTipsInfo(TipsBufferTmp, IncExpEntry);
                    END;
                UNTIL IncExpAccount.NEXT = 0;
                PrintSeperator(2);
            END;
        END;

        CLEAR(decLGrandTotalNetAmt);
        CLEAR(decLGrandTotalVATAmt);
        CLEAR(decLNonVATSales);
        CLEAR(decLVatableSales);
        recLVATSetup.RESET;
        IF recLVATSetup.FINDFIRST THEN BEGIN
            REPEAT
                CLEAR(decLTotalVATAmt);
                CLEAR(decLTotalNetAmt);
                recLTransHeader1.RESET;
                recLTransHeader1.SETCURRENTKEY(recLTransHeader1.Date, recLTransHeader1."Transaction No.",
                recLTransHeader1."Statement Code", recLTransHeader1."Staff ID", recLTransHeader1."Store No.");
                recLTransHeader1.SETRANGE(recLTransHeader1."Z-Report ID", '');
                IF RunType = RunType::X THEN
                    recLTransHeader1.SETRANGE("Cashier Report ID", '');
                recRetailCalendarLine.RESET;
                recRetailCalendarLine.SETRANGE(recRetailCalendarLine."Calendar ID", POSSESSION.StoreNo);
                IF recRetailCalendarLine.FINDLAST THEN BEGIN
                    IF recRetailCalendarLine."Midnight Open" THEN BEGIN
                        IF recRetailCalendarLine."Time To" > TIME THEN BEGIN
                            vDay := CALCDATE('<-1D>', TransDate);
                            recLTransHeader1.SETFILTER(recLTransHeader1.Date, '%1', vDay)
                        END ELSE
                            recLTransHeader1.SETFILTER(recLTransHeader1.Date, '%1', TransDate);
                    END ELSE
                        recLTransHeader1.SETFILTER(recLTransHeader1.Date, '%1', TransDate);
                END ELSE BEGIN
                    recLTransHeader1.SETFILTER(recLTransHeader1.Date, '%1', TransDate);
                END;
                recLTransHeader1.SETFILTER(recLTransHeader1."Transaction No.", '<>%1', 0);
                CASE RunType OF
                    RunType::X:
                        recLTransHeader1.SETRANGE(recLTransHeader1."Staff ID", POSSESSION.StaffID);
                    RunType::Y:
                        BEGIN
                            recLStore.RESET;
                            recLStore.SETRANGE(recLStore."No.", Globals.StoreNo);
                            IF recLStore.FINDFIRST THEN
                                IF NOT Store."Global Setup" THEN BEGIN
                                    recLTransHeader1.SETRANGE(recLTransHeader1."POS Terminal No.", POSSESSION.TerminalNo);
                                END;
                        END;
                    RunType::Z:
                        recLTransHeader1.SETRANGE(recLTransHeader1."Store No.", Globals.StoreNo);
                END;
                IF RunType = RunType::X THEN
                    recLTransHeader1.SETRANGE("Cashier Report ID", '');
                recLTransHeader1.SETFILTER("VAT Code Filter", recLVATSetup."VAT Code");
                recLTransHeader1.SetFilter("Local VAT Code Filter", '<>%1', 'VZ');
                IF recLTransHeader1.FINDFIRST THEN
                    REPEAT
                        recLTransHeader1.CALCFIELDS("Total VAT Amount", "Total Net Amount");
                        decLTotalVATAmt += recLTransHeader1."Total VAT Amount";
                        decLTotalNetAmt += recLTransHeader1."Total Net Amount";

                        decLGrandTotalVATAmt += recLTransHeader1."Total VAT Amount";
                        decLGrandTotalNetAmt += recLTransHeader1."Total Net Amount";

                        IF (recLVATSetup."VAT %" <> 0) THEN BEGIN
                            decLVatableSales += recLTransHeader1."Total Net Amount";
                        END ELSE BEGIN
                            decLNonVATSales += recLTransHeader1."Total Net Amount";
                        END;

                    UNTIL recLTransHeader1.NEXT = 0;
                decLVAT12 += -decLTotalVATAmt;
                CASE recLVATSetup."VAT Code" OF
                    'VE':
                        decLVATEx := -decLTotalNetAmt;
                END;

            UNTIL recLVATSetup.NEXT = 0;
        END;
        CLEAR(decLTotalVATAmt);
        CLEAR(decLTotalNetAmt);
        recLTransHeader1.RESET;
        recLTransHeader1.SETCURRENTKEY(recLTransHeader1.Date, recLTransHeader1."Transaction No.",
        recLTransHeader1."Statement Code", recLTransHeader1."Staff ID", recLTransHeader1."Store No.");
        recLTransHeader1.SETRANGE(recLTransHeader1."Z-Report ID", '');
        IF RunType = RunType::X THEN
            recLTransHeader1.SETRANGE("Cashier Report ID", '');
        recRetailCalendarLine.RESET;
        recRetailCalendarLine.SETRANGE(recRetailCalendarLine."Calendar ID", POSSESSION.StoreNo);
        IF recRetailCalendarLine.FINDLAST THEN BEGIN
            IF recRetailCalendarLine."Midnight Open" THEN BEGIN
                IF recRetailCalendarLine."Time To" > TIME THEN BEGIN
                    vDay := CALCDATE('<-1D>', TransDate);
                    recLTransHeader1.SETFILTER(recLTransHeader1.Date, '%1', vDay)
                END ELSE
                    recLTransHeader1.SETFILTER(recLTransHeader1.Date, '%1', TransDate);
            END ELSE
                recLTransHeader1.SETFILTER(recLTransHeader1.Date, '%1', TransDate);
        END ELSE BEGIN
            recLTransHeader1.SETFILTER(recLTransHeader1.Date, '%1', TransDate);
        END;
        recLTransHeader1.SETFILTER(recLTransHeader1."Transaction No.", '<>%1', 0);
        CASE RunType OF
            RunType::X:
                recLTransHeader1.SETRANGE(recLTransHeader1."Staff ID", POSSESSION.StaffID);
            RunType::Y:
                BEGIN
                    recLStore.RESET;
                    recLStore.SETRANGE(recLStore."No.", Globals.StoreNo);
                    IF recLStore.FINDFIRST THEN
                        IF NOT Store."Global Setup" THEN BEGIN
                            recLTransHeader1.SETRANGE(recLTransHeader1."POS Terminal No.", POSSESSION.TerminalNo);
                        END;
                END;
            RunType::Z:
                recLTransHeader1.SETRANGE(recLTransHeader1."Store No.", Globals.StoreNo);
        END;
        IF RunType = RunType::X THEN
            recLTransHeader1.SETRANGE("Cashier Report ID", '');
        recLTransHeader1.SETFILTER("VAT Code Filter", 'VE');
        recLTransHeader1.SetFilter("Local VAT Code Filter", 'VZ');
        IF recLTransHeader1.FINDFIRST THEN
            REPEAT
                recLTransHeader1.CALCFIELDS("Total VAT Amount", "Total Net Amount");
                decLTotalVATAmt += recLTransHeader1."Total VAT Amount";
                decLTotalNetAmt += recLTransHeader1."Total Net Amount";
                decLGrandTotalVATAmt += recLTransHeader1."Total VAT Amount";
                decLGrandTotalNetAmt += recLTransHeader1."Total Net Amount";
                decLNonVATSales += recLTransHeader1."Total Net Amount";

                //if NOT recLTransHeader1."Sale Is Return Sale" then begin
                decLZeroRatedAmount += recLTransHeader1."Zero Rated Amount";
                salesEntry.Reset();
                salesEntry.SetRange("Receipt No.", recLTransHeader1."Receipt No.");
                salesEntry.SetRange("VAT Code", 'VZ');
                if salesEntry.findfirst() then
                    repeat
                        decLZeroRatedSales += salesEntry."Net Amount";
                    until salesEntry.next() = 0;

            UNTIL recLTransHeader1.NEXT = 0;
        recLTransHeader2.RESET;
        recLTransHeader2.SETCURRENTKEY(recLTransHeader2.Date, recLTransHeader2."Transaction No.",
        recLTransHeader2."Statement Code", recLTransHeader2."Staff ID", recLTransHeader2."Store No.");
        recLTransHeader2.SETRANGE(recLTransHeader2."Z-Report ID", '');
        IF RunType = RunType::X THEN
            recLTransHeader2.SETRANGE("Cashier Report ID", '');
        recRetailCalendarLine.RESET;
        recRetailCalendarLine.SETRANGE(recRetailCalendarLine."Calendar ID", POSSESSION.StoreNo);
        IF recRetailCalendarLine.FINDLAST THEN BEGIN
            IF recRetailCalendarLine."Midnight Open" THEN BEGIN
                IF recRetailCalendarLine."Time To" > TIME THEN BEGIN
                    vDay := CALCDATE('<-1D>', TransDate);
                    recLTransHeader2.SETFILTER(recLTransHeader2.Date, '%1', vDay)
                END ELSE
                    recLTransHeader2.SETFILTER(recLTransHeader2.Date, '%1', TransDate);
            END ELSE
                recLTransHeader2.SETFILTER(recLTransHeader2.Date, '%1', TransDate);
        END ELSE BEGIN
            recLTransHeader2.SETFILTER(recLTransHeader2.Date, '%1', TransDate);
        END;
        recLTransHeader2.SETFILTER(recLTransHeader2."Transaction No.", '<>%1', 0);
        CASE RunType OF
            RunType::X:
                recLTransHeader2.SETRANGE(recLTransHeader2."Staff ID", POSSESSION.StaffID);
            RunType::Y:
                BEGIN
                    recLStore.RESET;
                    recLStore.SETRANGE(recLStore."No.", Globals.StoreNo);
                    IF recLStore.FINDFIRST THEN
                        IF NOT Store."Global Setup" THEN BEGIN
                            recLTransHeader2.SETRANGE(recLTransHeader2."POS Terminal No.", POSSESSION.TerminalNo);
                        END;
                END;
            RunType::Z:
                recLTransHeader2.SETRANGE(recLTransHeader2."Store No.", Globals.StoreNo);
        END;
        IF RunType = RunType::X THEN
            recLTransHeader2.SETRANGE("Cashier Report ID", '');
        IF recLTransHeader2.FINDFIRST THEN
            REPEAT
                salesEntry.Reset();
                salesEntry.SetRange("Receipt No.", recLTransHeader2."Receipt No.");
                salesEntry.SetRange("VAT Code", 'V');
                if salesEntry.findfirst() then
                    repeat
                        TotalVATABLESALES += (salesEntry."Net Amount");
                        TotalVATAmount += (salesEntry."VAt Amount");
                    until salesEntry.next() = 0;
            UNTIL recLTransHeader2.NEXT = 0;

        TotalVatDetails := Abs(TotalVATABLESALES) + Abs(decLVATEx) + Abs(decLZeroRated) + Abs(TotalVATAmount) + Abs(decLZeroRatedSales);
        DSTR1 := '#L################ #R###################';
        //ZERORATED Amount
        Value[1] := 'Zero-rated Amount';
        Value[2] := POSFunctions.FormatAmount(Abs(decLZeroRatedAmount));
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        PrintSeperator(2);
        //VATABLE SALES
        Value[1] := 'Vatable Sales';
        Value[2] := POSFunctions.FormatAmount(Abs(TotalVATABLESALES));
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        //VAT Amount
        Value[1] := 'VAT Amount';
        Value[2] := POSFunctions.FormatAmount(Abs(TotalVATAmount));
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

        //VATExempt SALES
        Value[1] := 'VAT Exempt Sales';
        Value[2] := POSFunctions.FormatAmount(Abs(decLVATEx));
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

        //ZERORATED SALES
        Value[1] := 'Zero-rated Sales';
        Value[2] := POSFunctions.FormatAmount((Abs(decLZeroRatedSales)));
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

        PrintSeperator(2);

        //TotalVat Details
        Value[1] := Text005;
        Value[2] := POSFunctions.FormatAmount((TotalVatDetails));
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

        PrintSeperator(2);
        DSTR1 := '#L#################### #R###############';

        //Transaction counting
        CASE RunType OF
            RunType::X:
                PaymTrans3.SETCURRENTKEY("Staff ID", "Z-Report ID", "Tender Type", "Currency Code", "Card No.", Date, Time);
            RunType::Y:
                PaymTrans3.SETCURRENTKEY("POS Terminal No.", "Z-Report ID", "Tender Type", "Currency Code", "Card No.", Date, Time);
            RunType::Z:
                PaymTrans3.SETCURRENTKEY("Statement Code", "Z-Report ID", "Tender Type", "Currency Code", "Card No.", Date, Time);
        END;
        //(+)20160412#AB
        IF RunType = RunType::X THEN
            PaymTrans3.SETRANGE("Cashier Report ID", '');

        // PaymTrans3.SetRange(Date, TransDate); Paano kunin No. of Paying Customers inadd q to pwede tanggalin
        IF PaymTrans3.FIND('-') THEN
            REPEAT
                IF NOT PaymTemp.GET(PaymTrans3."Store No.", PaymTrans3."POS Terminal No.", PaymTrans3."Transaction No.") THEN BEGIN
                    Transaction2.GET(PaymTrans3."Store No.", PaymTrans3."POS Terminal No.", PaymTrans3."Transaction No.");
                    IF (Transaction2."Transaction Type" = Transaction2."Transaction Type"::Sales) AND (Transaction2."Invoice No." <> '') THEN
                        RecCount := RecCount + 1;
                    PaymTemp."Store No." := PaymTrans3."Store No.";
                    PaymTemp."POS Terminal No." := PaymTrans3."POS Terminal No.";
                    PaymTemp."Transaction No." := PaymTrans3."Transaction No.";
                    PaymTemp.INSERT;
                END;
            UNTIL PaymTrans3.NEXT = 0;

        transactionheader.COPY(Transaction);
        transactionheader.SetCurrentKey("Invoice No.");
        if transactionheader.FindFirst() then begin
            Value[1] := Text134 + ':';
            Value[2] := FORMAT(transactionheader.COUNT);
            decLTotalPayingCustomer := Value[2];
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        end;

        //Beginning & Ending Invoice on XYZ Reading
        CLEAR(codLBegInvNo);
        CLEAR(codLEndInvNo);
        CLEAR(codLFirstReceiptNo);
        CLEAR(codLLastReceiptNo);
        CLEAR(recLTransaction);
        recLTransaction.COPY(Transaction);
        recLTransaction.SETCURRENTKEY("Invoice No.");
        IF recLTransaction.FINDFIRST THEN BEGIN
            codLFirstReceiptNo := recLTransaction."Receipt No.";
            IF codLBegInvNo = '' THEN
                codLBegInvNo := '0';
        END;
        IF recLTransaction.FINDLAST THEN BEGIN
            codLLastReceiptNo := recLTransaction."Receipt No.";
            codLEndInvNo := recLTransaction."Invoice No.";
            IF codLEndInvNo = '' THEN
                codLEndInvNo := '0';
        END;

        recLTransaction.COPY(Transaction);
        recLTransaction.SETCURRENTKEY("Invoice No.");
        recLTransaction.SETFILTER("Invoice No.", '<>%1', '');
        IF recLTransaction.FINDFIRST THEN BEGIN
            codLFirstReceiptNo := recLTransaction."Receipt No.";
            codLBegInvNo := recLTransaction."Invoice No.";
            IF codLBegInvNo = '' THEN
                codLBegInvNo := '0';
        END;

        recLPOSVoidedLine.RESET;
        recLPOSVoidedLine.SETCURRENTKEY("Receipt No.", "Entry Type", "Entry Status");
        recLPOSVoidedLine.SETRANGE("Entry Type", recLPOSVoidedLine."Entry Type"::Item);
        recLPOSVoidedLine.SETRANGE("Entry Status", recLPOSVoidedLine."Entry Status"::Voided);
        recRetailCalendarLine.RESET;
        recRetailCalendarLine.SETRANGE(recRetailCalendarLine."Calendar ID", POSSESSION.StoreNo);
        IF recRetailCalendarLine.FINDLAST THEN BEGIN
            IF recRetailCalendarLine."Midnight Open" THEN BEGIN
                IF recRetailCalendarLine."Time To" > TIME THEN BEGIN
                    vDay := CALCDATE('<-1D>', TransDate);
                    recLPOSVoidedLine.SETFILTER(recLPOSVoidedLine."Trans. Date", '%1', vDay)
                END ELSE
                    recLPOSVoidedLine.SETFILTER(recLPOSVoidedLine."Trans. Date", '%1', TransDate);
            END ELSE
                recLPOSVoidedLine.SETFILTER(recLPOSVoidedLine."Trans. Date", '%1', TransDate);
        END ELSE BEGIN
            recLPOSVoidedLine.SETFILTER(recLPOSVoidedLine."Trans. Date", '%1', TransDate);
        END;

        CASE RunType OF
            RunType::X:
                recLPOSVoidedLine.SETRANGE(recLPOSVoidedLine."Created by Staff ID", POSSESSION.StaffID);
            RunType::Y:
                BEGIN
                    recLStore.RESET;
                    recLStore.SETRANGE(recLStore."No.", Globals.StoreNo);
                    IF recLStore.FINDFIRST THEN
                        IF NOT Store."Global Setup" THEN BEGIN
                            recLPOSVoidedLine.SETRANGE(recLPOSVoidedLine."POS Terminal No.", POSSESSION.TerminalNo);
                        END;
                END;
            RunType::Z:
                recLPOSVoidedLine.SETRANGE(recLPOSVoidedLine."Store No.", POSSESSION.StoreNo);
        END;
        IF recLPOSVoidedLine.FINDFIRST THEN BEGIN
            recLPOSVoidedLine.CALCSUMS(recLPOSVoidedLine.Amount);
            intLTotalNoOfVoidLine := recLPOSVoidedLine.COUNT;
            decLTotalVoidLineAmt := recLPOSVoidedLine.Amount;
        END;

        //No. of Transactions
        CLEAR(intLNoOfTrans);
        recNoOfTransaction.RESET;
        recNoOfTransaction.SETCURRENTKEY(recNoOfTransaction.Date, recNoOfTransaction."Transaction No.",
        recNoOfTransaction."Statement Code", recNoOfTransaction."Staff ID", recNoOfTransaction."Store No.");
        recNoOfTransaction.SETRANGE(recNoOfTransaction."Z-Report ID", '');

        IF RunType = RunType::X THEN
            recNoOfTransaction.SETRANGE("Cashier Report ID", '');
        recRetailCalendarLine.RESET;
        recRetailCalendarLine.SETRANGE(recRetailCalendarLine."Calendar ID", POSSESSION.StoreNo);
        IF recRetailCalendarLine.FINDLAST THEN BEGIN
            IF recRetailCalendarLine."Midnight Open" THEN BEGIN
                IF recRetailCalendarLine."Time To" > TIME THEN BEGIN
                    vDay := CALCDATE('<-1D>', TransDate);
                    recNoOfTransaction.SETFILTER(recNoOfTransaction.Date, '%1', vDay)
                END ELSE
                    recNoOfTransaction.SETFILTER(recNoOfTransaction.Date, '%1', TransDate);
            END ELSE
                recNoOfTransaction.SETFILTER(recNoOfTransaction.Date, '%1', TransDate);
        END ELSE BEGIN
            recNoOfTransaction.SETFILTER(recNoOfTransaction.Date, '%1', TransDate);
        END;
        recNoOfTransaction.SETFILTER(recNoOfTransaction."Transaction No.", '<>%1', 0);
        CASE RunType OF
            RunType::X:
                recNoOfTransaction.SETRANGE(recNoOfTransaction."Staff ID", POSSESSION.StaffID);
            RunType::Y:
                BEGIN
                    recLStore.RESET;
                    recLStore.SETRANGE(recLStore."No.", Globals.StoreNo);
                    IF recLStore.FINDFIRST THEN
                        IF NOT Store."Global Setup" THEN BEGIN
                            recNoOfTransaction.SETRANGE(recNoOfTransaction."POS Terminal No.", POSSESSION.TerminalNo);
                        END;
                END;
            RunType::Z:
                recNoOfTransaction.SETRANGE(recNoOfTransaction."Store No.", Globals.StoreNo);
        END;
        IF recNoOfTransaction.FINDFIRST THEN BEGIN
            Value[1] := Text028;
            Value[2] := FORMAT(recNoOfTransaction.COUNT, 0, '<Integer>');
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            EVALUATE(intLNoOfTrans, Value[2]);
        END;

        //No. of Items Sold
        CLEAR(intLNoOfItemSold);
        recNoOfItems.RESET;
        recNoOfItems.SETCURRENTKEY(recNoOfItems.Date, recNoOfItems."Transaction No.",
        recNoOfItems."Statement Code", recNoOfItems."Staff ID", recNoOfItems."Store No.");
        recRetailCalendarLine.RESET;
        recRetailCalendarLine.SETRANGE(recRetailCalendarLine."Calendar ID", POSSESSION.StoreNo);
        IF recRetailCalendarLine.FINDLAST THEN BEGIN
            IF recRetailCalendarLine."Midnight Open" THEN BEGIN
                IF recRetailCalendarLine."Time To" > TIME THEN BEGIN
                    vDay := CALCDATE('<-1D>', TransDate);
                    recNoOfItems.SETFILTER(recNoOfItems.Date, '%1', vDay)
                END ELSE
                    recNoOfItems.SETFILTER(recNoOfItems.Date, '%1', TransDate);
            END ELSE
                recNoOfItems.SETFILTER(recNoOfItems.Date, '%1', TransDate);
        END ELSE BEGIN
            recNoOfItems.SETFILTER(recNoOfItems.Date, '%1', TransDate);
        END;

        CASE RunType OF
            RunType::X:
                recNoOfItems.SETRANGE(recNoOfItems."Staff ID", POSSESSION.StaffID);
            RunType::Y:
                BEGIN
                    recLStore.RESET;
                    recLStore.SETRANGE(recLStore."No.", Globals.StoreNo);
                    IF recLStore.FINDFIRST THEN
                        IF NOT Store."Global Setup" THEN BEGIN
                            recNoOfItems.SETRANGE(recNoOfItems."POS Terminal No.", POSSESSION.TerminalNo);
                        END;
                END;
            RunType::Z:
                recNoOfItems.SETRANGE(recNoOfItems."Store No.", Globals.StoreNo);
        END;
        recNoOfItems.SETRANGE(recNoOfItems."Z-Report ID", '');
        IF (RunType = RunType::X) THEN
            recNoOfItems.SETRANGE("Cashier Report ID", '');
        recNoOfItems.CALCSUMS(recNoOfItems."No. of Items");

        Value[1] := Text029;
        Value[2] := FORMAT(recNoOfItems."No. of Items", 0, '<Integer>');
        //Replace(Format(recNoOfItems."No. of Items"), ',', ' ');
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        EVALUATE(intLNoOfItemSold, Value[2]);

        //No. of Refunds
        Transaction.SETRANGE(Transaction."Sale Is Return Sale", TRUE);
        Transaction.SETFILTER(Transaction."Retrieved from Receipt No.", '%1', '');
        Value[1] := Text030;
        // MARCUS 20251229
        // Value[2] := FORMAT(Transaction.COUNT, 0, '<Integer>');
        decLTotalRefundTrans := FORMAT(Transaction.COUNT, 0, '<Integer>');
        Value[2] := decLTotalRefundTrans;
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

        EVALUATE(intLNoOfRefunds, Value[2]);

        IF Transaction.FINDFIRST THEN
            REPEAT
                decLTotalRefund := decLTotalRefund + Transaction."Gross Amount";
            UNTIL Transaction.NEXT = 0;

        Value[1] := 'Total Refund Amt';
        Value[2] := POSFunctions.FormatAmount(decLTotalRefund);
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        EVALUATE(decLTotalRefund, Value[2]);

        Transaction.SETRANGE(Transaction."Sale Is Return Sale", TRUE);
        Transaction.SETFILTER(Transaction."Retrieved from Receipt No.", '<>%1', '');
        Value[1] := 'No. of Returns';
        Value[2] := FORMAT(Transaction.COUNT, 0, '<Integer>');
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

        EVALUATE(intLNoOfReturns, Value[2]);

        IF Transaction.FINDFIRST THEN
            REPEAT
                decTotalReturns := decTotalReturns + Transaction."Gross Amount";
            UNTIL Transaction.NEXT = 0;

        Value[1] := 'Total Return Amt';
        Value[2] := POSFunctions.FormatAmount(decTotalReturns);
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        EVALUATE(decTotalReturns, Value[2]);

        //No. of Suspended
        SuspTrans.SETRANGE("Store No.", Store."No.");
        SuspTrans.SETRANGE("Entry Status", SuspTrans."Entry Status"::Suspended);
        NoSuspended := SuspTrans.COUNT;
        Value[1] := Text031;
        Value[2] := FORMAT(NoSuspended, 0, '<Integer>');
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        SuspTrans.SETRANGE("Store No.");

        IF RunType = RunType::Z THEN BEGIN
            IF Terminal."Print Suspend with Prepayment" THEN BEGIN
                NoSuspPrepayment := 0;
                SuspPrepayment := 0;

                SuspTransLine.RESET;
                SuspTransLine.SETCURRENTKEY("Receipt No.", "Entry Type", "Entry Status");
                SuspTransLine.SETRANGE("Entry Type", SuspTransLine."Entry Type"::IncomeExpense);
                IF SuspTransLine.FIND('-') THEN BEGIN
                    REPEAT
                        IF (SuspTransLine."POS Terminal No." = '0') THEN BEGIN
                            NoSuspPrepayment := NoSuspPrepayment + 1;
                            SuspPrepayment := SuspPrepayment + SuspTransLine.Amount;
                        END;
                    UNTIL SuspTransLine.NEXT = 0;
                END;
                SuspPrepayment := ABS(SuspPrepayment);
                IF (NoSuspPrepayment > 0) THEN BEGIN
                    Value[1] := '  ' + Text154;
                    Value[2] := FORMAT(NoSuspPrepayment, 0, '<Integer>');
                    cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                END;
                IF (SuspPrepayment > 0) THEN BEGIN
                    Value[1] := '  ' + Text155;
                    Value[2] := POSFunctions.FormatAmount(SuspPrepayment);
                    cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                END;
            END;
        END;

        IF RunType = RunType::Y THEN BEGIN
            IF Terminal."Print Suspend with Prepayment" THEN BEGIN
                NoSuspPrepayment := 0;
                SuspPrepayment := 0;

                SuspTransLine.RESET;
                SuspTransLine.SETCURRENTKEY("Receipt No.", "Entry Type", "Entry Status");
                SuspTransLine.SETRANGE("Entry Type", SuspTransLine."Entry Type"::IncomeExpense);
                IF SuspTransLine.FIND('-') THEN BEGIN
                    REPEAT
                        IF (SuspTransLine."POS Terminal No." = '0') THEN BEGIN
                            NoSuspPrepayment := NoSuspPrepayment + 1;
                            SuspPrepayment := SuspPrepayment + SuspTransLine.Amount;
                        END;
                    UNTIL SuspTransLine.NEXT = 0;
                END;
                SuspPrepayment := ABS(SuspPrepayment);
                IF (NoSuspPrepayment > 0) THEN BEGIN
                    Value[1] := '  ' + Text154;
                    Value[2] := FORMAT(NoSuspPrepayment, 0, '<Integer>');
                    cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                END;
                IF (SuspPrepayment > 0) THEN BEGIN
                    Value[1] := '  ' + Text155;
                    Value[2] := POSFunctions.FormatAmount(SuspPrepayment);
                    cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                END;
            END;
        END;

        //No. of Voided Line Trans.
        Value[1] := Text63006;
        Value[2] := FORMAT(intLTotalNoOfVoidLine, 0, '<Integer>');
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

        //Total Voided Line Trans. Amount
        Value[1] := Text63007;
        Value[2] := POSFunctions.FormatAmount(decLTotalVoidLineAmt);
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

        CLEAR(intLNoOfVoided);
        recNoOfVoidedTrans.RESET;
        recNoOfVoidedTrans.SETCURRENTKEY(recNoOfVoidedTrans.Date, recNoOfVoidedTrans."Transaction No.",
        recNoOfVoidedTrans."Statement Code", recNoOfVoidedTrans."Staff ID", recNoOfVoidedTrans."Store No.");
        recRetailCalendarLine.RESET;
        recRetailCalendarLine.SETRANGE(recRetailCalendarLine."Calendar ID", POSSESSION.StoreNo);
        IF recRetailCalendarLine.FINDLAST THEN BEGIN
            IF recRetailCalendarLine."Midnight Open" THEN BEGIN
                IF recRetailCalendarLine."Time To" > TIME THEN BEGIN
                    vDay := CALCDATE('<-1D>', TransDate);
                    recNoOfVoidedTrans.SETFILTER(recNoOfVoidedTrans.Date, '%1', vDay)
                END ELSE
                    recNoOfVoidedTrans.SETFILTER(recNoOfVoidedTrans.Date, '%1', TransDate);
            END ELSE
                recNoOfVoidedTrans.SETFILTER(recNoOfVoidedTrans.Date, '%1', TransDate);
        END ELSE BEGIN
            recNoOfVoidedTrans.SETFILTER(recNoOfVoidedTrans.Date, '%1', TransDate);
        END;
        CASE RunType OF
            RunType::X:
                recNoOfVoidedTrans.SETRANGE(recNoOfVoidedTrans."Staff ID", POSSESSION.StaffID);
            RunType::Y:
                BEGIN
                    recLStore.RESET;
                    recLStore.SETRANGE(recLStore."No.", Globals.StoreNo);
                    IF recLStore.FINDFIRST THEN
                        IF NOT Store."Global Setup" THEN BEGIN
                            recNoOfVoidedTrans.SETRANGE(recNoOfVoidedTrans."POS Terminal No.", POSSESSION.TerminalNo);
                        END;
                END;
            RunType::Z:
                recNoOfVoidedTrans.SETRANGE(recNoOfVoidedTrans."Store No.", Globals.StoreNo);
        END;
        recNoOfVoidedTrans.SETRANGE(recNoOfVoidedTrans."Z-Report ID", '');
        recNoOfVoidedTrans.SETRANGE("Entry Status", Transaction."Entry Status"::Voided);
        Value[1] := Text032;
        Value[2] := FORMAT(recNoOfVoidedTrans.COUNT, 0, '<Integer>');
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

        EVALUATE(intLNoOfVoided, Value[2]);

        IF Transaction.FINDFIRST THEN
            REPEAT
                recLPOSVoidedTrans.RESET;
                recLPOSVoidedTrans.SETRANGE("Receipt No.", Transaction."Receipt No.");
                IF recLPOSVoidedTrans.FINDFIRST THEN BEGIN
                    recLPOSVoidedTrans.CALCFIELDS("Gross Amount");
                    decLTotalVoided += recLPOSVoidedTrans."Gross Amount";
                END;
            UNTIL Transaction.NEXT = 0;

        //No. of Training
        Transaction.SETRANGE("Entry Status", Transaction."Entry Status"::Training);
        Value[1] := Text034;
        Value[2] := FORMAT(Transaction.COUNT, 0, '<Integer>');
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        Transaction.SETRANGE("Entry Status");
        EVALUATE(intLNoOfTraining, Value[2]);

        //No. of Open Drawer
        CLEAR(intLNoOfOpenDrawer);
        recNoOfOpenDrawer.RESET;
        recNoOfOpenDrawer.SETCURRENTKEY(recNoOfOpenDrawer.Date, recNoOfOpenDrawer."Transaction No.",
        recNoOfOpenDrawer."Statement Code", recNoOfOpenDrawer."Staff ID", recNoOfOpenDrawer."Store No.");
        recNoOfOpenDrawer.SETRANGE(recNoOfOpenDrawer."Z-Report ID", '');
        recRetailCalendarLine.RESET;
        recRetailCalendarLine.SETRANGE(recRetailCalendarLine."Calendar ID", POSSESSION.StoreNo);
        IF recRetailCalendarLine.FINDLAST THEN BEGIN
            IF recRetailCalendarLine."Midnight Open" THEN BEGIN
                IF recRetailCalendarLine."Time To" > TIME THEN BEGIN
                    vDay := CALCDATE('<-1D>', TransDate);
                    recNoOfOpenDrawer.SETFILTER(recNoOfOpenDrawer.Date, '%1', vDay)
                END ELSE
                    recNoOfOpenDrawer.SETFILTER(recNoOfOpenDrawer.Date, '%1', TransDate);
            END ELSE
                recNoOfOpenDrawer.SETFILTER(recNoOfOpenDrawer.Date, '%1', TransDate);
        END ELSE BEGIN
            recNoOfOpenDrawer.SETFILTER(recNoOfOpenDrawer.Date, '%1', TransDate);
        END;
        recNoOfOpenDrawer.SETFILTER("Transaction Type", '%1|%2|%3|%4|%5',
        recNoOfOpenDrawer."Transaction Type"::Sales, recNoOfOpenDrawer."Transaction Type"::"Open Drawer", recNoOfOpenDrawer."Transaction Type"::"Tender Decl.",
        recNoOfOpenDrawer."Transaction Type"::"Float Entry", recNoOfOpenDrawer."Transaction Type"::"Remove Tender");
        recNoOfOpenDrawer.SETFILTER(recNoOfOpenDrawer."Entry Status", '<>%1', recNoOfOpenDrawer."Entry Status"::Voided);

        IF RunType = RunType::X THEN
            recNoOfOpenDrawer.SETRANGE(recNoOfOpenDrawer."Cashier Report ID", '');

        CASE RunType OF
            RunType::X:
                recNoOfOpenDrawer.SETRANGE(recNoOfOpenDrawer."Staff ID", POSSESSION.StaffID);
            RunType::Y:
                BEGIN
                    recLStore.RESET;
                    recLStore.SETRANGE(recLStore."No.", Globals.StoreNo);
                    IF recLStore.FINDFIRST THEN
                        IF NOT Store."Global Setup" THEN BEGIN
                            recNoOfOpenDrawer.SETRANGE(recNoOfOpenDrawer."POS Terminal No.", POSSESSION.TerminalNo);
                        END;
                END;
            RunType::Z:
                recNoOfOpenDrawer.SETRANGE(recNoOfOpenDrawer."Store No.", Globals.StoreNo);
        END;

        IF recNoOfOpenDrawer.FINDFIRST THEN BEGIN
            Value[1] := Text037;
            Value[2] := FORMAT(recNoOfOpenDrawer.COUNT, 0, '<Integer>');
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            Transaction.SETRANGE("Open Drawer");
            EVALUATE(intLNoOfOpenDrawer, Value[2]);
        END;

        //No. of Logins
        CLEAR(intLNoOfVoided);
        recNoOfLogon.RESET;
        recNoOfLogon.SETCURRENTKEY(recNoOfLogon.Date, recNoOfLogon."Transaction No.",
        recNoOfLogon."Statement Code", recNoOfLogon."Staff ID", recNoOfLogon."Store No.");
        recRetailCalendarLine.RESET;
        recRetailCalendarLine.SETRANGE(recRetailCalendarLine."Calendar ID", POSSESSION.StoreNo);
        IF recRetailCalendarLine.FINDLAST THEN BEGIN
            IF recRetailCalendarLine."Midnight Open" THEN BEGIN
                IF recRetailCalendarLine."Time To" > TIME THEN BEGIN
                    vDay := CALCDATE('<-1D>', TransDate);
                    recNoOfLogon.SETFILTER(recNoOfLogon.Date, '%1', vDay)
                END ELSE
                    recNoOfLogon.SETFILTER(recNoOfLogon.Date, '%1', TransDate);
            END ELSE
                recNoOfLogon.SETFILTER(recNoOfLogon.Date, '%1', TransDate);
        END ELSE BEGIN
            recNoOfLogon.SETFILTER(recNoOfLogon.Date, '%1', TransDate);
        END;
        CASE RunType OF
            RunType::X:
                recNoOfLogon.SETRANGE(recNoOfLogon."Staff ID", POSSESSION.StaffID);
            RunType::Y:
                BEGIN
                    recLStore.RESET;
                    recLStore.SETRANGE(recLStore."No.", Globals.StoreNo);
                    IF recLStore.FINDFIRST THEN
                        IF NOT Store."Global Setup" THEN BEGIN
                            recNoOfLogon.SETRANGE(recNoOfLogon."POS Terminal No.", POSSESSION.TerminalNo);
                        END;
                END;
            RunType::Z:
                recNoOfLogon.SETRANGE(recNoOfLogon."Store No.", POSSESSION.StoreNo);
        END;
        recNoOfLogon.SETRANGE("Transaction Type", Transaction."Transaction Type"::Logon);
        Value[1] := Text139;
        Value[2] := FORMAT(recNoOfLogon.COUNT, 0, '<Integer>');
        Transaction.SETRANGE("Transaction Type");
        Transaction.SETRANGE("Z-Report ID", ''); //JONNEL20191203
        EVALUATE(intLNoOfLogins, Value[2]);

        IF (RunType = RunType::Z) OR (RunType = RunType::Y) THEN BEGIN
            DSTR1 := '#L################## #R#################';
            //Beginning Invoice No.
            Value[1] := Text63002;
            Value[2] := codLBegInvNo;
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

            //Ending Invoice.
            Value[1] := Text63003;
            Value[2] := codLEndInvNo;
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            // Beginning Void
            Transaction3.SETRANGE("Sale Is Return Sale", true);
            Transaction3.SETFILTER("Date", '%1', TransDate);
            Transaction3.SETFILTER("Transaction Code Type", '<>%1', Transaction3."Transaction Code Type"::DEPOSIT);
            Transaction3.SETFILTER("Retrieved from Receipt No.", '<>%1', '');
            IF Transaction3.FINDFIRST THEN
                Transaction4.SETRANGE("Receipt No.", Transaction3."Retrieved from Receipt No.");
            Value[1] := 'Beg. VOID #:';
            IF Transaction4.FINDFIRST THEN BEGIN
                Value[2] := CheckIfNoSeriesIsEmpty(Transaction4."Post Void No. Series");
            END ELSE BEGIN
                Value[2] := '000000000000';
            END;
            BegVoid := Value[2];
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            // Ending Void
            IF Transaction3.FINDLAST THEN BEGIN
                Transaction4.RESET;
                Transaction4.SETRANGE("Receipt No.", Transaction3."Retrieved from Receipt No.");
            END;
            Value[1] := 'End. VOID #:';
            IF Transaction4.FINDLAST THEN BEGIN
                Value[2] := CheckIfNoSeriesIsEmpty(Transaction4."Post Void No. Series");
            END ELSE BEGIN
                Value[2] := '000000000000';
            END;
            EndVoid := Value[2];
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            // Beginning Return
            Transaction3.RESET;
            Transaction3.SETRANGE("Sale Is Return Sale", true);
            Transaction3.SETFILTER("Date", '%1', TransDate);
            Transaction3.SETFILTER("Transaction Code Type", '<>%1', Transaction3."Transaction Code Type"::DEPOSIT);
            Transaction3.SETRANGE("Retrieved from Receipt No.", '');
            Value[1] := 'Beg. RETURN #:';
            IF Transaction3.FINDFIRST THEN BEGIN
                Value[2] := CheckIfNoSeriesIsEmpty(Transaction3."Return No. Series");
            END ELSE BEGIN
                Value[2] := '000000000000';
            END;
            BegReturn := Value[2];
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            // Ending Return
            Value[1] := 'End. RETURN #:';
            IF Transaction3.FINDLAST THEN BEGIN
                Value[2] := CheckIfNoSeriesIsEmpty(Transaction3."Return No. Series");
            END ELSE BEGIN
                Value[2] := '000000000000';
            END;
            EndReturn := Value[2];
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

            decLNewAccumulatedSales := decLOldAccumulatedSales + DecLTotalNetSales;
            IF decLNewAccumulatedSales >= 999999999999.99 then begin
                Terminal.RESET;
                IF Terminal.Get(Globals.TerminalNo) THEN begin
                    Terminal."Accumulated Reset Counter" := Terminal."Accumulated Reset Counter" + 1;
                    l_ResetCtrInt := Terminal."Accumulated Reset Counter";
                end;

                decLNewAccumulatedSales := decLNewAccumulatedSales - 999999999999.99;
                decLOldAccumulatedSales := decLNewAccumulatedSales;

                DSTR1 := '#L################### #R################'; // Old DSTR1 := '#L##################### #R##############';
                //Old Accumulated Sales
                Value[1] := Text63000;
                Value[2] := POSFunctions.FormatAmount(decLOldAccumulatedSales);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));

                //New Accumulated Sales
                Value[1] := Text63001;
                Value[2] := POSFunctions.FormatAmount(decLNewAccumulatedSales);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            end else begin
                DSTR1 := '#L################### #R################'; // Old DSTR1 := '#L##################### #R##############';
                //Old Accumulated Sales
                Value[1] := Text63000;
                Value[2] := POSFunctions.FormatAmount(decLOldAccumulatedSales);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                //New Accumulated Sales
                Value[1] := Text63001;
                Value[2] := POSFunctions.FormatAmount(decLNewAccumulatedSales);
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            end;

            //Reset Counter
            Value[1] := 'Reset Counter';
            l_ResetCtrCode := '0000';
            l_ResetCtrCode := CopyStr(l_ResetCtrCode, 1, (4 - Strlen(FORMAT(Terminal."Accumulated Reset Counter"))));
            Value[2] := l_ResetCtrCode + FORMAT(Terminal."Accumulated Reset Counter");
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        END;

        TipsBufferTmp.RESET;
        IF TipsBufferTmp.COUNT > 0 THEN
            PrintTipsInfo(TipsBufferTmp, 1);

        IF RunType = RunType::Z THEN BEGIN

            IF Terminal."Statement Method" = Terminal."Statement Method"::"POS Terminal" THEN BEGIN
                IF Terminal."Last Z-Report" <> '' THEN
                    Terminal."Last Z-Report" := INCSTR(Terminal."Last Z-Report")
                ELSE
                    Terminal."Last Z-Report" := 'T000000001';
                ZReportID := Terminal."Last Z-Report";
            END ELSE BEGIN
                IF Staff."Last Z-Report" <> '' THEN
                    Staff."Last Z-Report" := INCSTR(Staff."Last Z-Report")
                ELSE
                    Staff."Last Z-Report" := 'S000000001';
                ZReportID := Staff."Last Z-Report";
            END;

            IF Terminal."Last Z-Report" <> '' THEN
                Terminal."Last Z-Report" := INCSTR(Terminal."Last Z-Report")
            ELSE
                Terminal."Last Z-Report" := 'T000000001';
            ZReportID := Terminal."Last Z-Report";

            IF (Globals.GetValue('TS_ERROR') <> '') THEN
                ZReportID := 'X' + COPYSTR(ZReportID, 2);
            PrintSeperator(2);
            cduSender.PrintLine(2, Text116 + ZReportID);

        END;


        IF RunType = RunType::X THEN BEGIN
            IF Terminal."Statement Method" = Terminal."Statement Method"::"POS Terminal" THEN BEGIN
                IF Terminal."Last X-Report" <> '' THEN
                    Terminal."Last X-Report" := INCSTR(Terminal."Last X-Report")
                ELSE
                    Terminal."Last X-Report" := 'T000000001';
                XReportID := Terminal."Last X-Report";
            END ELSE BEGIN
                IF Staff."Last X-Report" <> '' THEN
                    Staff."Last X-Report" := INCSTR(Staff."Last X-Report")
                ELSE
                    Staff."Last X-Report" := 'S000000001';
                XReportID := Staff."Last X-Report";
            END;
            IF (Globals.GetValue('TS_ERROR') <> '') THEN
                XReportID := 'X' + COPYSTR(XReportID, 2);
            PrintSeperator(2);
            cduSender.PrintLine(2, Text90005 + XReportID);
        END;

        IF (RunType = RunType::Z) OR (RunType = RunType::Y) THEN BEGIN
            DSTR1 := '#L##################### #R##############';
            Value[1] := Text035;

            IF RunType = RunType::Y THEN
                Value[2] := POSFunctions.FormatAmount(YReportStats."Cumulative Sales Amount")
            ELSE
                Value[2] := POSFunctions.FormatAmount(ZReportStats."Cumulative Sales Amount");

            Transaction2.SETCURRENTKEY("Statement Code", "Z-Report ID", "Transaction Type", "Entry Status");
            Transaction2.SETFILTER("Statement Code", '<>%1', SCode);
            Transaction2.SETRANGE("Z-Report ID", '');
            Transaction2.SETRANGE("Transaction Type", Transaction."Transaction Type"::Sales);
            Transaction2.SETFILTER("Entry Status", '%1|%2', Transaction."Entry Status"::" ", Transaction."Entry Status"::Posted);

            IF Transaction2.FIND('-') THEN BEGIN
                Value[1] := lText001;
                Value[2] := FORMAT(Transaction2.COUNT, 0, '<Integer>');
                OldestDate := Transaction2.Date;
                REPEAT
                    IF Transaction2.Date < OldestDate THEN
                        OldestDate := Transaction2.Date;
                UNTIL Transaction2.NEXT = 0;
                Value[1] := lText002;
                Value[2] := FORMAT(OldestDate);

                Transaction2.CALCSUMS("Gross Amount", "Discount Amount", "Total Discount", Rounded, "No. of Items");
                Value[1] := lText003;
                Value[2] := POSFunctions.FormatAmount(-Transaction2."Gross Amount" + Transaction2.Rounded);
            END;
            Transaction2.RESET;
        END;

        //eree
        if not cduSender.ClosePrinter(2) then
            exit(false);
        if Transaction."Entry Status" = Transaction."Entry Status"::Training then
            exit(true);

        case RunType of
            RunType::Z:
                begin
                    ZReportStats.Init;
                    ZReportStats."Store No." := Globals.StoreNo;
                    ZReportStats."POS Terminal No." := Globals.TerminalNo;
                    ZReportStats.Date := Today;
                    ZReportStats."Sales Amount" := ZReportStatsSalesAmount;
                    ZReportStats."Return Amount" := ZReportStatsReturnsAmount;
                    ZReportStats.Insert(true);
                end;
            RunType::Y:
                begin
                    YReportStats.Init;
                    YReportStats."Store No." := Globals.StoreNo;
                    YReportStats."POS Terminal No." := Globals.TerminalNo;
                    YReportStats.Date := Today;
                    YReportStats."Sales Amount" := YReportStatsSalesAmount;
                    YReportStats.Insert(true);
                end;
        end;

        IF (RunType = RunType::Z) OR (RunType = RunType::X) THEN BEGIN
            IF RunType = RunType::X THEN
                Staff.MODIFY;
            Terminal.MODIFY();
            PaymEntry.SETRANGE("Currency Code");
            PaymEntry.SETRANGE("Card No.");
            PaymEntry.SETRANGE("Tender Type");
            IF RunType = RunType::X THEN BEGIN
                PaymEntry.SETRANGE(PaymEntry."Staff ID", Globals.StaffID);
                PaymEntry.SETRANGE(PaymEntry."Cashier Report ID", '');
                IF PaymEntry.FIND('-') THEN
                    REPEAT
                        PaymTrans2 := PaymEntry;
                        PaymTrans2."Cashier Report ID" := XReportID;
                        PaymTrans2.MODIFY(TRUE);
                    UNTIL PaymEntry.NEXT = 0;
            END;

            PaymEntry.SETRANGE("Z-Report ID", '');
            IF PaymEntry.FIND('-') THEN
                REPEAT
                    PaymTrans2 := PaymEntry;
                    PaymTrans2."Z-Report ID" := ZReportID;
                    PaymTrans2.MODIFY(TRUE);
                UNTIL PaymEntry.NEXT = 0;

            CLEAR(TendDeclEntry);
            TendDeclEntry.SETCURRENTKEY("Statement Code", "Z-Report ID", "Tender Type", "Currency Code", "Card No.");
            IF RunType = RunType::X THEN BEGIN
                TendDeclEntry.SETRANGE(TendDeclEntry."Staff ID", Globals.StaffID);
                TendDeclEntry.SETRANGE("Cashier Report ID", '');
                IF TendDeclEntry.FIND('-') THEN
                    REPEAT
                        TendDeclEntry2 := TendDeclEntry;
                        TendDeclEntry2."Cashier Report ID" := XReportID;
                        TendDeclEntry2.MODIFY(TRUE);
                    UNTIL TendDeclEntry.NEXT = 0;
            END;

            TendDeclEntry.SETRANGE("Z-Report ID", '');
            IF TendDeclEntry.FIND('-') THEN
                REPEAT
                    TendDeclEntry2 := TendDeclEntry;
                    TendDeclEntry2."Z-Report ID" := ZReportID;
                    TendDeclEntry2.MODIFY(TRUE);
                UNTIL TendDeclEntry.NEXT = 0;

            CLEAR(IncExpEntry);
            IncExpEntry.SETCURRENTKEY("Statement Code", "Z-Report ID");
            IncExpEntry.SETRANGE("Z-Report ID", '');
            IF RunType = RunType::X THEN BEGIN
                IncExpEntry.SETRANGE(IncExpEntry."Staff ID", Globals.StaffID);
                IncExpEntry.SETRANGE("Cashier Report ID", '');
                IF IncExpEntry.FIND('-') THEN
                    REPEAT
                        IncExpEntry2 := IncExpEntry;
                        IncExpEntry2."Cashier Report ID" := XReportID;
                        IncExpEntry2.MODIFY(TRUE);
                    UNTIL IncExpEntry.NEXT = 0;
            END;

            IncExpEntry.SETRANGE("Z-Report ID", '');
            IF IncExpEntry.FIND('-') THEN
                REPEAT
                    IncExpEntry2 := IncExpEntry;
                    IncExpEntry2."Z-Report ID" := ZReportID;
                    IncExpEntry2.MODIFY(TRUE);
                UNTIL IncExpEntry.NEXT = 0;

            Transaction2.RESET;
            recRetailCalendarLine.RESET;
            recRetailCalendarLine.SETRANGE(recRetailCalendarLine."Calendar ID", POSSESSION.StoreNo);
            IF recRetailCalendarLine.FINDLAST THEN BEGIN
                IF recRetailCalendarLine."Midnight Open" THEN BEGIN
                    IF recRetailCalendarLine."Time To" > TIME THEN BEGIN
                        vDay := CALCDATE('<-1D>', TransDate);
                        Transaction2.SETFILTER(Transaction2.Date, '%1', vDay)
                    END ELSE
                        Transaction2.SETFILTER(Transaction2.Date, '%1', TransDate);
                END ELSE
                    Transaction2.SETFILTER(Transaction2.Date, '%1', TransDate);
            END ELSE BEGIN
                Transaction2.SETFILTER(Transaction2.Date, '%1', TransDate);
            END;
            Transaction2.SETRANGE("Z-Report ID", '');
            IF RunType = RunType::X THEN BEGIN
                Transaction2.SETRANGE(Transaction2."Staff ID", Globals.StaffID);
                Transaction2.SETRANGE(Transaction2."Cashier Report ID", '');
                IF Transaction2.FINDFIRST THEN
                    REPEAT
                        Transaction2."Cashier Report ID" := XReportID;
                        Transaction2.MODIFY(TRUE);
                    UNTIL Transaction2.NEXT = 0;
            END;

            IF RunType = RunType::Y THEN BEGIN
                Transaction2.SETRANGE(Transaction2."POS Terminal No.", Globals.TerminalNo);
                //Transaction2.SETRANGE(Transaction2."Y-Report ID",'');
                IF Transaction2.FINDFIRST THEN
                    REPEAT
                        Transaction2."Y-Report ID" := YReportID;
                        Transaction2.MODIFY(TRUE);
                    UNTIL Transaction2.NEXT = 0;
                YReportStats."Y-Report Id" := YReportID;
                YReportStats.MODIFY(TRUE);
                Globals.SetValue('LAST_YID', YReportID);
            END;

            IF RunType = RunType::Z THEN BEGIN
                Transaction2.SETRANGE(Transaction2."Z-Report ID", '');
                IF Transaction2.FINDFIRST THEN
                    REPEAT
                        Transaction2."Z-Report ID" := ZReportID;
                        Transaction2.MODIFY(TRUE);
                    UNTIL Transaction2.NEXT = 0;
                ZReportStats."Z-Report Id" := ZReportID;
                ZReportStats.MODIFY(TRUE);
                Globals.SetValue('LAST_ZID', ZReportID);
            END;
        END;
        IF (RunType = RunType::X) THEN BEGIN//insert x-report statistics.
            XreportStatistics.Init();
            XreportStatistics."Entry No." := XreportStatistics.GetNextEntryNo();
            XreportStatistics."POS Terminal No." := FORMAT(Globals.TerminalNo);
            XreportStatistics."Store No." := FORMAT(Globals.StoreNo);
            XreportStatistics."Staff ID" := FORMAT(Globals.StaffID);
            Evaluate(XreportStatistics."Sales Amount", Dec2Str(decLGrossSales, 1));
            XreportStatistics."Trans. Date" := TransDate;
            XreportStatistics."X-Report Id" := FORMAT(XReportID);
            XreportStatistics.Insert();
        end;
        IF (RunType = RunType::Z) THEN BEGIN
            AssignCardDetailsToArray();

            gTimeEnd := FORMAT(TIME());
            CLEAR(txtAccumSales);
            txtAccumSales[1] := FORMAT(TransDate);
            txtAccumSales[2] := FORMAT(Globals.StoreNo());
            txtAccumSales[3] := FORMAT(Globals.TerminalNo);
            txtAccumSales[4] := FORMAT(Globals.StaffID);
            txtAccumSales[5] := Dec2Str(decLGrossSales, 1);
            txtAccumSales[6] := Dec2Str(decLLineDiscount, 1);
            txtAccumSales[7] := Dec2Str(decLTotalDiscount, 1);
            txtAccumSales[8] := Dec2Str(decLRounding, 1);
            txtAccumSales[9] := Dec2Str(decLTotalNetSales, 1);
            txtAccumSales[10] := Dec2Str(decLTotalRefund, 1);    //10
            txtAccumSales[11] := Dec2Str(decLTotalVoidLineAmt, 1);
            txtAccumSales[12] := Dec2Str(decLTotalVoided, 1);
            txtAccumSales[13] := Dec2Str(ABS(TotalVATAmount), 2);
            txtAccumSales[14] := Dec2Str(TotalVATABLESALES, 2);
            txtAccumSales[15] := Dec2Str(decLNonVATSales, 2);
            txtAccumSales[16] := Dec2Str(decLServiceCharge, 2);
            // MARCUS 20251229
            // txtAccumSales[17] := FORMAT(RecCount);
            txtAccumSales[17] := FORMAT(decLTotalPayingCustomer);
            txtAccumSales[18] := FORMAT(intLNoOfTrans);
            txtAccumSales[19] := FORMAT(intLNoOfItemSold);
            txtAccumSales[20] := FORMAT(intLNoOfRefunds);    //20
            txtAccumSales[21] := FORMAT(NoSuspended);
            txtAccumSales[22] := FORMAT(intLTotalNoOfVoidLine);
            txtAccumSales[23] := FORMAT(intLNoOfVoided);
            txtAccumSales[24] := FORMAT(intLNoOfTraining);
            txtAccumSales[25] := FORMAT(intLNoOfOpenDrawer);
            txtAccumSales[26] := FORMAT(intLNoOfLogins);
            txtAccumSales[27] := FORMAT(codLBegInvNo);
            txtAccumSales[28] := FORMAT(codLEndInvNo);
            txtAccumSales[29] := Dec2Str(decLOldAccumulatedSales, 1);
            // txtAccumSales[30] := Dec2Str(decLOldAccumulatedSales + decLTotalNetSales, 1);  //30 
            txtAccumSales[30] := Dec2Str(decLNewAccumulatedSales, 1);  //30 MARCUS 20251229
            txtAccumSales[31] := FORMAT(codLFirstReceiptNo);
            txtAccumSales[32] := FORMAT(codLLastReceiptNo);

            txtAccumSales[33] := Dec2Str(decTenderAmount[1], 1);
            txtAccumSales[34] := Dec2Str(decTenderAmount[3], 1);
            txtAccumSales[35] := Dec2Str(decTenderAmount[27], 1);
            txtAccumSales[36] := Dec2Str(decTenderAmount[28], 1);

            txtAccumSales[37] := FORMAT(intNoOfTender[1]);
            txtAccumSales[38] := FORMAT(intNoOfTender[3]);
            txtAccumSales[39] := FORMAT(intNoOfTender[27]);
            txtAccumSales[40] := FORMAT(intNoOfTender[28]);           //40

            txtAccumSales[41] := Dec2Str(decLTotalWHTAmt, 1);
            txtAccumSales[42] := Dec2Str(ABS(decLTotalVATWAmt), 1);


            txtAccumSales[43] := Dec2Str(decLTotalTender, 1);
            txtAccumSales[44] := Dec2Str(decLVAT12, 1);
            txtAccumSales[45] := Dec2Str(decLVATEx, 1);
            txtAccumSales[46] := Dec2Str(Abs(decLZeroRatedSales), 1);//decLZeroRated
            txtAccumSales[47] := Dec2Str(decLOldAccumulatedSales + decLTotalNetSales, 1);
            txtAccumSales[48] := FORMAT(intLTotalNoOfCash);
            txtAccumSales[49] := FORMAT(intLTotalNoOfZero);
            txtAccumSales[50] := FORMAT(intLTotalNoOfBOI);  //50
            txtAccumSales[51] := FORMAT(intLTotalNoOfSRC);
            txtAccumSales[52] := FORMAT(intLTotalNoOfPWD);
            txtAccumSales[53] := Dec2Str(decLTotalCashTrans, 1);
            txtAccumSales[54] := Dec2Str(decLTotalZeroTrans, 1);
            txtAccumSales[55] := Dec2Str(decLTotalBOIAmount, 1);
            txtAccumSales[56] := Dec2Str(decLTotalSRCDisc, 1);
            txtAccumSales[57] := Dec2Str(decLTotalSRCTrans, 1);
            txtAccumSales[58] := Dec2Str(decLTotalPWDDisc, 1);
            txtAccumSales[59] := Dec2Str(decLTotalPWDTrans, 1);
            txtAccumSales[60] := FORMAT(TIME);  //60
            txtAccumSales[61] := FORMAT(ZReportID);
            txtAccumSales[62] := FORMAT(intLTotalNoOfSOLO);
            txtAccumSales[63] := FORMAT(ROUND(decLTotalSOLODisc, 0.01, '='), 0, '<Sign><Integer Thousand><Decimal,3>');
            txtAccumSales[64] := FORMAT(ROUND(decLTotalSOLOTrans, 0.01, '='), 0, '<Sign><Integer Thousand><Decimal,3>');
            txtAccumSales[65] := Dec2Str(-FloatTotal, 1);
            txtAccumSales[66] := Dec2Str(RemoveTotal, 1);
            txtAccumSales[67] := Dec2Str(ShortOver, 1);

            txtAccumSales[68] := FORMAT(gStaffName, 1);
            txtAccumSales[69] := FORMAT(TODAY());
            txtAccumSales[70] := FORMAT(gTimeStart); //70
            txtAccumSales[71] := FORMAT(gTimeEnd);

            txtAccumSales[72] := FORMAT(ROUND(ABS(decDeliveryCharge), 0.01, '='), 0, '<Sign><Integer Thousand><Decimal,3>');
            txtAccumSales[73] := Dec2Str(ABS(decTotalTend), 1);
            txtAccumSales[74] := Dec2Str(ABS(decNonVatNetSr), 1);

            txtAccumSales[75] := FORMAT(codLayalabegin);
            txtAccumSales[76] := FORMAT(codLayalaend);

            txtAccumSales[77] := FORMAT(TODAY);
            txtAccumSales[78] := FORMAT(TIME);

            txtAccumSales[79] := txtCardDetailsDescArr[1];
            txtAccumSales[80] := Dec2Str(decCardDetailsAmtArr[1], 1);
            txtAccumSales[81] := Format(intCardDetailsCountArr[1]);

            txtAccumSales[82] := txtCardDetailsDescArr[2];
            txtAccumSales[83] := Dec2Str(decCardDetailsAmtArr[2], 1);
            txtAccumSales[84] := Format(intCardDetailsCountArr[2]);

            txtAccumSales[85] := txtCardDetailsDescArr[3];
            txtAccumSales[86] := Dec2Str(decCardDetailsAmtArr[3], 1);
            txtAccumSales[87] := Format(intCardDetailsCountArr[3]);

            txtAccumSales[88] := txtCardDetailsDescArr[4];
            txtAccumSales[89] := Dec2Str(decCardDetailsAmtArr[4], 1);
            txtAccumSales[90] := Format(intCardDetailsCountArr[4]);

            txtAccumSales[91] := txtCardDetailsDescArr[5];
            txtAccumSales[92] := Dec2Str(decCardDetailsAmtArr[5], 1);
            txtAccumSales[93] := Format(intCardDetailsCountArr[5]);

            txtAccumSales[94] := txtCardDetailsDescArr[6];
            txtAccumSales[95] := Dec2Str(decCardDetailsAmtArr[6], 1);
            txtAccumSales[96] := Format(intCardDetailsCountArr[6]);

            txtAccumSales[97] := txtCardDetailsDescArr[7];
            txtAccumSales[98] := Dec2Str(decCardDetailsAmtArr[7], 1);
            txtAccumSales[99] := Format(intCardDetailsCountArr[7]);

            txtAccumSales[100] := txtCardDetailsDescArr[8];
            txtAccumSales[101] := Dec2Str(decCardDetailsAmtArr[8], 1);
            txtAccumSales[102] := Format(intCardDetailsCountArr[8]);

            txtAccumSales[103] := txtCardDetailsDescArr[9];
            txtAccumSales[104] := Dec2Str(decCardDetailsAmtArr[9], 1);
            txtAccumSales[105] := Format(intCardDetailsCountArr[9]);

            txtAccumSales[106] := txtCardDetailsDescArr[10];
            txtAccumSales[107] := Dec2Str(decCardDetailsAmtArr[10], 1);
            txtAccumSales[108] := Format(intCardDetailsCountArr[10]);

            txtAccumSales[109] := txtCardDetailsDescArr[11];
            txtAccumSales[110] := Dec2Str(decCardDetailsAmtArr[11], 1);
            txtAccumSales[111] := Format(intCardDetailsCountArr[11]);

            txtAccumSales[112] := txtCardDetailsDescArr[12];
            txtAccumSales[113] := Dec2Str(decCardDetailsAmtArr[12], 1);
            txtAccumSales[114] := Format(intCardDetailsCountArr[12]);

            txtAccumSales[115] := txtCardDetailsDescArr[13];
            txtAccumSales[116] := Dec2Str(decCardDetailsAmtArr[13], 1);
            txtAccumSales[117] := Format(intCardDetailsCountArr[13]);

            txtAccumSales[118] := txtCardDetailsDescArr[14];
            txtAccumSales[119] := Dec2Str(decCardDetailsAmtArr[14], 1);
            txtAccumSales[120] := Format(intCardDetailsCountArr[14]);

            txtAccumSales[121] := txtCardDetailsDescArr[15];
            txtAccumSales[122] := Dec2Str(decCardDetailsAmtArr[15], 1);
            txtAccumSales[123] := Format(intCardDetailsCountArr[15]);

            txtAccumSales[124] := txtCardDetailsDescArr[16];
            txtAccumSales[125] := Dec2Str(decCardDetailsAmtArr[16], 1);
            txtAccumSales[126] := Format(intCardDetailsCountArr[16]);

            txtAccumSales[127] := txtCardDetailsDescArr[17];
            txtAccumSales[128] := Dec2Str(decCardDetailsAmtArr[17], 1);
            txtAccumSales[129] := Format(intCardDetailsCountArr[17]);

            txtAccumSales[130] := txtCardDetailsDescArr[18];
            txtAccumSales[131] := Dec2Str(decCardDetailsAmtArr[18], 1);
            txtAccumSales[132] := Format(intCardDetailsCountArr[18]);

            txtAccumSales[133] := txtCardDetailsDescArr[19];
            txtAccumSales[134] := Dec2Str(decCardDetailsAmtArr[19], 1);
            txtAccumSales[135] := Format(intCardDetailsCountArr[19]);

            txtAccumSales[136] := txtCardDetailsDescArr[20];
            txtAccumSales[137] := Dec2Str(decCardDetailsAmtArr[20], 1);
            txtAccumSales[138] := Format(intCardDetailsCountArr[20]);

            txtAccumSales[139] := txtCardDetailsDescArr[21];
            txtAccumSales[140] := Dec2Str(decCardDetailsAmtArr[21], 1);
            txtAccumSales[141] := Format(intCardDetailsCountArr[21]);

            txtAccumSales[142] := txtCardDetailsDescArr[22];
            txtAccumSales[143] := Dec2Str(decCardDetailsAmtArr[22], 1);
            txtAccumSales[144] := Format(intCardDetailsCountArr[22]);

            txtAccumSales[145] := txtCardDetailsDescArr[23];
            txtAccumSales[146] := Dec2Str(decCardDetailsAmtArr[23], 1);
            txtAccumSales[147] := Format(intCardDetailsCountArr[23]);

            txtAccumSales[148] := txtCardDetailsDescArr[24];
            txtAccumSales[149] := Dec2Str(decCardDetailsAmtArr[24], 1);
            txtAccumSales[150] := Format(intCardDetailsCountArr[24]);

            txtAccumSales[151] := txtCardDetailsDescArr[25];
            txtAccumSales[152] := Dec2Str(decCardDetailsAmtArr[25], 1);
            txtAccumSales[153] := Format(intCardDetailsCountArr[25]);

            txtAccumSales[154] := txtCardDetailsDescArr[26];
            txtAccumSales[155] := Dec2Str(decCardDetailsAmtArr[26], 1);
            txtAccumSales[156] := Format(intCardDetailsCountArr[26]);

            txtAccumSales[157] := txtCardDetailsDescArr[27];
            txtAccumSales[158] := Dec2Str(decCardDetailsAmtArr[27], 1);
            txtAccumSales[159] := Format(intCardDetailsCountArr[27]);

            txtAccumSales[160] := txtCardDetailsDescArr[28];
            txtAccumSales[161] := Dec2Str(decCardDetailsAmtArr[28], 1);
            txtAccumSales[162] := Format(intCardDetailsCountArr[28]);

            txtAccumSales[163] := txtCardDetailsDescArr[29];
            txtAccumSales[164] := Dec2Str(decCardDetailsAmtArr[29], 1);
            txtAccumSales[165] := Format(intCardDetailsCountArr[29]);

            txtAccumSales[166] := txtCardDetailsDescArr[30];
            txtAccumSales[167] := Dec2Str(decCardDetailsAmtArr[30], 1);
            txtAccumSales[168] := Format(intCardDetailsCountArr[30]);

            txtAccumSales[169] := txtCardDetailsDescArr[31];
            txtAccumSales[170] := Dec2Str(decCardDetailsAmtArr[31], 1);
            txtAccumSales[171] := Format(intCardDetailsCountArr[31]);

            txtAccumSales[172] := txtCardDetailsDescArr[32];
            txtAccumSales[173] := Dec2Str(decCardDetailsAmtArr[32], 1);
            txtAccumSales[174] := Format(intCardDetailsCountArr[32]);

            txtAccumSales[175] := txtCardDetailsDescArr[33];
            txtAccumSales[176] := Dec2Str(decCardDetailsAmtArr[33], 1);
            txtAccumSales[177] := Format(intCardDetailsCountArr[33]);

            txtAccumSales[178] := txtCardDetailsDescArr[34];
            txtAccumSales[179] := Dec2Str(decCardDetailsAmtArr[34], 1);
            txtAccumSales[180] := Format(intCardDetailsCountArr[34]);

            txtAccumSales[181] := txtCardDetailsDescArr[35];
            txtAccumSales[182] := Dec2Str(decCardDetailsAmtArr[35], 1);
            txtAccumSales[183] := Format(intCardDetailsCountArr[35]);

            txtAccumSales[184] := txtCardDetailsDescArr[36];
            txtAccumSales[185] := Dec2Str(decCardDetailsAmtArr[36], 1);
            txtAccumSales[186] := Format(intCardDetailsCountArr[36]);

            txtAccumSales[187] := txtCardDetailsDescArr[37];
            txtAccumSales[188] := Dec2Str(decCardDetailsAmtArr[37], 1);
            txtAccumSales[189] := Format(intCardDetailsCountArr[37]);

            txtAccumSales[190] := txtCardDetailsDescArr[38];
            txtAccumSales[191] := Dec2Str(decCardDetailsAmtArr[38], 1);
            txtAccumSales[192] := Format(intCardDetailsCountArr[38]);

            txtAccumSales[193] := txtCardDetailsDescArr[39];
            txtAccumSales[194] := Dec2Str(decCardDetailsAmtArr[39], 1);
            txtAccumSales[195] := Format(intCardDetailsCountArr[39]);

            txtAccumSales[196] := txtCardDetailsDescArr[40];
            txtAccumSales[197] := Dec2Str(decCardDetailsAmtArr[40], 1);
            txtAccumSales[198] := Format(intCardDetailsCountArr[40]);

            txtAccumSales[199] := txtCardDetailsDescArr1[1];
            txtAccumSales[200] := Dec2Str(decCardDetailsAmtArr1[1], 1);
            txtAccumSales[201] := Format(intCardDetailsCountArr1[1]);

            txtAccumSales[202] := txtCardDetailsDescArr1[2];
            txtAccumSales[203] := Dec2Str(decCardDetailsAmtArr1[2], 1);
            txtAccumSales[204] := Format(intCardDetailsCountArr1[2]);

            txtAccumSales[205] := txtCardDetailsDescArr1[3];
            txtAccumSales[206] := Dec2Str(decCardDetailsAmtArr1[3], 1);
            txtAccumSales[207] := Format(intCardDetailsCountArr1[3]);

            txtAccumSales[208] := txtCardDetailsDescArr1[4];
            txtAccumSales[209] := Dec2Str(decCardDetailsAmtArr1[4], 1);
            txtAccumSales[210] := Format(intCardDetailsCountArr1[4]);

            txtAccumSales[211] := txtCardDetailsDescArr1[5];
            txtAccumSales[212] := Dec2Str(decCardDetailsAmtArr1[5], 1);
            txtAccumSales[213] := Format(intCardDetailsCountArr1[5]);

            txtAccumSales[214] := txtCardDetailsDescArr1[6];
            txtAccumSales[215] := Dec2Str(decCardDetailsAmtArr1[6], 1);
            txtAccumSales[216] := Format(intCardDetailsCountArr1[6]);

            txtAccumSales[217] := txtCardDetailsDescArr1[7];
            txtAccumSales[218] := Dec2Str(decCardDetailsAmtArr1[7], 1);
            txtAccumSales[219] := Format(intCardDetailsCountArr1[7]);

            txtAccumSales[220] := txtCardDetailsDescArr1[8];
            txtAccumSales[221] := Dec2Str(decCardDetailsAmtArr1[8], 1);
            txtAccumSales[222] := Format(intCardDetailsCountArr1[8]);

            txtAccumSales[223] := txtCardDetailsDescArr1[9];
            txtAccumSales[224] := Dec2Str(decCardDetailsAmtArr1[9], 1);
            txtAccumSales[225] := Format(intCardDetailsCountArr1[9]);

            txtAccumSales[226] := txtCardDetailsDescArr1[10];
            txtAccumSales[227] := Dec2Str(decCardDetailsAmtArr1[10], 1);
            txtAccumSales[228] := Format(intCardDetailsCountArr1[10]);

            txtAccumSales[229] := txtCardDetailsDescArr1[11];
            txtAccumSales[230] := Dec2Str(decCardDetailsAmtArr1[11], 1);
            txtAccumSales[231] := Format(intCardDetailsCountArr1[11]);

            txtAccumSales[232] := txtCardDetailsDescArr1[12];
            txtAccumSales[233] := Dec2Str(decCardDetailsAmtArr1[12], 1);
            txtAccumSales[234] := Format(intCardDetailsCountArr1[12]);

            txtAccumSales[235] := txtCardDetailsDescArr1[13];
            txtAccumSales[236] := Dec2Str(decCardDetailsAmtArr1[13], 1);
            txtAccumSales[237] := Format(intCardDetailsCountArr1[13]);

            txtAccumSales[238] := txtCardDetailsDescArr1[14];
            txtAccumSales[239] := Dec2Str(decCardDetailsAmtArr1[14], 1);
            txtAccumSales[240] := Format(intCardDetailsCountArr1[14]);

            txtAccumSales[241] := txtCardDetailsDescArr1[15];
            txtAccumSales[242] := Dec2Str(decCardDetailsAmtArr1[15], 1);
            txtAccumSales[243] := Format(intCardDetailsCountArr1[15]);

            txtAccumSales[244] := FORMAT(intLTotalNoOfATHL);
            txtAccumSales[245] := FORMAT(ROUND(decLTotalATHLDisc, 0.01, '='), 0, '<Sign><Integer Thousand><Decimal,3>');
            txtAccumSales[246] := FORMAT(ROUND(decLTotalATHLTrans, 0.01, '='), 0, '<Sign><Integer Thousand><Decimal,3>');
            txtAccumSales[247] := Format(decLZeroRatedAmount);
            txtAccumSales[248] := format(decLTotalRefund);
            txtAccumSales[249] := format(decTotalReturns);
            txtAccumSales[250] := format(l_ResetCtrInt);
            txtAccumSales[251] := format(decLTotalRefundTrans);
            txtAccumSales[252] := format(BegVoid);
            txtAccumSales[253] := format(EndVoid);
            txtAccumSales[254] := format(BegReturn);
            txtAccumSales[255] := format(EndReturn);
            if MyPOSAddiFunc.CreateEODLedgerWithArray(txtAccumSales) THEN BEGIN
                exit(false);
            END;
        END;
        COMMIT;
        EXIT(TRUE);
    end;

    procedure Dec2Str(pDecimal: Decimal; pMode: Integer): Text[1024]
    begin
        CASE pMode OF
            1:
                EXIT(FORMAT(ROUND(pDecimal, 0.01, '='), 0, '<Sign><Integer Thousand><Decimal,3>'));
            ELSE
                EXIT(FORMAT(ROUND(ABS(pDecimal), 0.01, '='), 0, '<Sign><Integer Thousand><Decimal,3>'));
        END;
    end;

    procedure PrintTenderDeclLines()
    var
        TenderType: Record "LSC Tender Type";
        TenderCard: Record "LSC Tender Type Card Setup";
        TransInfoCode: Record "LSC Trans. Infocode Entry";
        Currency: Record Currency;
        TransDiffEntry: Record "LSC Trans. Difference Entry";
        DSTR1: Text[50];
        Payment: Text[30];
        IsHandled: Boolean;
        DiffText: Label '   Difference';
    begin
        DSTR1 := '#L######## #R### #R######## #R##########';

        if TempTendDeclEntry.FindSet() then
            repeat
                LocalTotal := LocalTotal + TempTendDeclEntry."Amount Tendered";
                Payment := TempTendDeclEntry."Tender Type";
                if TenderType.Get(TempTendDeclEntry."Store No.", TempTendDeclEntry."Tender Type") then
                    Payment := TenderType.Description
                else
                    Clear(TenderType);

                Clear(Value);
                if TenderType."Foreign Currency" then begin
                    Value[1] := TempTendDeclEntry."Currency Code";
                    NodeName[1] := 'Currency Code';
                    NodeName[2] := 'x';
                    NodeName[3] := 'x';
                    if TenderType."Multiply in Tender Operations" then begin
                        Value[2] := POSFunctions.FormatQty(TempTendDeclEntry.Quantity);
                        NodeName[2] := 'Quantity';
                        Value[3] := POSFunctions.FormatAmount(TempTendDeclEntry."Amount in Currency" / TempTendDeclEntry.Quantity);
                        NodeName[3] := 'Tender Unit Value';
                    end;
                    Value[4] := POSFunctions.FormatCurrency(TempTendDeclEntry."Amount in Currency", Value[1]);
                    NodeName[4] := 'Amount In Currency';
                end else begin
                    Value[1] := Payment;
                    if (TenderType."Function" = TenderType."Function"::Card) then
                        if TenderCard.Get(TempTendDeclEntry."Store No.", TempTendDeclEntry."Tender Type", TempTendDeclEntry."Card No.") then
                            if TenderCard.Description <> '' then
                                Value[1] := TenderCard.Description;
                    NodeName[1] := 'Tender Description';
                    NodeName[2] := 'x';
                    NodeName[3] := 'x';
                    if TenderType."Multiply in Tender Operations" then begin
                        Value[2] := POSFunctions.FormatQty(TempTendDeclEntry.Quantity);
                        NodeName[2] := 'Quantity';
                        Value[3] := POSFunctions.FormatAmount(TempTendDeclEntry."Amount Tendered" / TempTendDeclEntry.Quantity);
                        NodeName[3] := 'Tender Unit Value';
                    end;
                    Value[4] := POSFunctions.FormatAmount(TempTendDeclEntry."Amount Tendered");
                    NodeName[4] := 'Amount In Tender';
                end;
                cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, false, false, false));
                AddPrintLine(700, 4, NodeName, Value, DSTR1, false, false, false, false, 2);
                TransDiffEntry.SetRange("Store No.", TempTendDeclEntry."Store No.");
                TransDiffEntry.SetRange("POS Terminal No.", TempTendDeclEntry."POS Terminal No.");
                TransDiffEntry.SetRange("Transaction No.", TempTendDeclEntry."Transaction No.");
                TransDiffEntry.SetRange("Tender Type", TempTendDeclEntry."Tender Type");
                TransDiffEntry.SetRange("Currency Code", TempTendDeclEntry."Currency Code");

                if TransDiffEntry.FindFirst then begin
                    Value[1] := DiffText;
                    NodeName[1] := 'Tender Description';
                    NodeName[2] := 'x';
                    NodeName[3] := 'x';
                    Value[4] := POSFunctions.FormatAmount(TransDiffEntry.Amount);
                    NodeName[4] := 'Amount In Tender';

                    cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, false, false, false));
                    AddPrintLine(700, 4, NodeName, Value, DSTR1, false, false, false, false, 2);
                end;
                TempTransInfoCode.SetCurrentKey("Replication Counter");
                TempTransInfoCode.SetRange("Replication Counter", TempTendDeclEntry."Line No.");
                if TempTransInfoCode.FindSet then
                    repeat
                        TransInfoCode.Get(
                          TempTransInfoCode."Store No.", TempTransInfoCode."POS Terminal No.", TempTransInfoCode."Transaction No.",
                          TempTransInfoCode."Transaction Type", TempTransInfoCode."Line No.",
                          TempTransInfoCode.Infocode, TempTransInfoCode."Entry Line No.");
                        PrintTransInfoCode(TransInfoCode, 2, false);
                    until TempTransInfoCode.Next = 0;
            until TempTendDeclEntry.Next = 0;

    end;

    procedure AssignCardDetailsToArray()
    var
        intLCtr: Integer;
        intLCtr1: Integer;
    begin
        CLEAR(intLCtr);
        recReportBuffer.RESET;
        if recReportBuffer.FINDFIRST then
            repeat
                //if recReportBuffer."Description 2" <> 'Card' then begin
                intLCtr := intLCtr + 1;
                txtCardDetailsDescArr[intLCtr] := recReportBuffer.Description; //DESCRIPTION
                decCardDetailsAmtArr[intLCtr] := recReportBuffer."Unit Price"; //AMOUNT
                intCardDetailsCountArr[intLCtr] := recReportBuffer."Price Unit Conversion";
            /* end else begin
                intLCtr1 := intLCtr1 + 1;
                txtCardDetailsDescArr1[intLCtr1] := recReportBuffer.Description; //DESCRIPTION
                decCardDetailsAmtArr1[intLCtr1] := recReportBuffer."Unit Price"; //AMOUNT
                intCardDetailsCountArr1[intLCtr1] := recReportBuffer."Price Unit Conversion"; //COUNT
            end; */
            until recReportBuffer.NEXT = 0;
    end;

    local procedure PrintTipsInfo(var TipsBufferTmp: Record "LSC Trans. Inc./Exp. Entry" temporary; Which: Option "In",Out)
    var
        Staff: Record "LSC Staff";
        NotFoundText: Label 'Not found';
        HeaderText: Label 'Tips %1';
        DSTR1: Text[80];
        DetailText: Label '%1: %2';
        TotalText: Label 'Tips %1 Total';
        IsHandled: Boolean;
    begin

        if not (TipsBufferTmp.FindSet()) then
            exit;

        //print header for the Tips Report.
        PrintSeperator(2);
        DSTR1 := '#L######################################';
        Value[1] := StrSubstNo(HeaderText, Format(Which));
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, false, false, false));
        PrintSeperator(2);

        //Print details of Tips Out
        DSTR1 := ' #L##################### #R##########';

        repeat
            if not (Staff.Get(TipsBufferTmp."Staff ID")) then
                Staff."Name on Receipt" := NotFoundText;
            Value[1] := StrSubstNo(DetailText, TipsBufferTmp."Staff ID", Staff."Name on Receipt");
            Value[2] := POSFunctions.FormatAmount(-TipsBufferTmp.Amount);
            cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, false, false, false));
        until TipsBufferTmp.Next = 0;
        PrintSeperator(2);

        //Print total line
        DSTR1 := '#L###################### #R##########';
        TipsBufferTmp.FindFirst;
        TipsBufferTmp.CalcSums(Amount);
        Value[1] := StrSubstNo(TotalText, Format(Which));
        Value[2] := POSFunctions.FormatAmount(-TipsBufferTmp.Amount);
        cduSender.PrintLine(2, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, false, false, false));
    end;

    local procedure BufferTipsInfo(var TipsBufferTmp: Record "LSC Trans. Inc./Exp. Entry" temporary; var IncExpEntry: Record "LSC Trans. Inc./Exp. Entry")
    var
        NextLineNo: Integer;
        TransHdr: Record "LSC Transaction Header";
    begin
        if not (IncExpEntry.FindSet()) then
            exit;

        NextLineNo := 10000;
        if TipsBufferTmp.FindLast then
            NextLineNo := NextLineNo + TipsBufferTmp."Line No.";

        repeat
            TipsBufferTmp.SetRange("Staff ID", IncExpEntry."Staff ID");
            if not (TipsBufferTmp.FindFirst) then begin
                TipsBufferTmp.Init;
                TipsBufferTmp."Store No." := IncExpEntry."Store No.";
                TipsBufferTmp."POS Terminal No." := IncExpEntry."POS Terminal No.";
                TipsBufferTmp."Transaction No." := 0;
                TipsBufferTmp."Line No." := NextLineNo;
                NextLineNo := NextLineNo + 10000;
                TipsBufferTmp."Staff ID" := IncExpEntry."Staff ID";
                TipsBufferTmp.Insert;
            end;
            TipsBufferTmp.Amount := TipsBufferTmp.Amount + IncExpEntry.Amount;
            TipsBufferTmp.Modify;
        until IncExpEntry.Next = 0;
    end;

    procedure BufferTendDeclEntry()
    var
        TransInfoCode: Record "LSC Trans. Infocode Entry";
    begin
        TempTendDeclEntry.Reset;
        TempTendDeclEntry.DeleteAll;
        TempTransInfoCode.Reset;
        TempTransInfoCode.DeleteAll;

        TempTendDeclEntry.SetCurrentKey("Statement Code", "Z-Report ID", "Tender Type", "Currency Code", "Card No.");
        if TendDeclEntry.FindSet() then begin
            repeat
                TempTendDeclEntry.SetRange("Statement Code", TendDeclEntry."Statement Code");
                TempTendDeclEntry.SetRange("Z-Report ID", TendDeclEntry."Z-Report ID");
                TempTendDeclEntry.SetRange("Tender Type", TendDeclEntry."Tender Type");
                TempTendDeclEntry.SetRange("Currency Code", TendDeclEntry."Currency Code");
                TempTendDeclEntry.SetRange("Card No.", TendDeclEntry."Card No.");
                if TempTendDeclEntry.Find then begin
                    TempTendDeclEntry."Amount Tendered" += TendDeclEntry."Amount Tendered";
                    TempTendDeclEntry.Quantity += TendDeclEntry.Quantity;
                    TempTendDeclEntry."Amount in Currency" += TendDeclEntry."Amount in Currency";
                    TempTendDeclEntry.Modify;
                end else begin
                    TempTendDeclEntry := TendDeclEntry;
                    TempTendDeclEntry.Insert;
                end;

                TransInfoCode.SetRange("Store No.", TendDeclEntry."Store No.");
                TransInfoCode.SetRange("POS Terminal No.", TendDeclEntry."Store No.");
                TransInfoCode.SetRange("Transaction No.", TendDeclEntry."Transaction No.");
                TransInfoCode.SetRange("Transaction Type", TransInfoCode."Transaction Type"::"Payment Entry");
                TransInfoCode.SetRange("Line No.", TendDeclEntry."Line No.");
                if TransInfoCode.FindSet() then
                    repeat
                        TempTransInfoCode := TransInfoCode;
                        TempTransInfoCode."Replication Counter" := TempTendDeclEntry."Line No.";
                        TempTransInfoCode.Insert;
                    until TransInfoCode.Next = 0;

            until TendDeclEntry.Next = 0;
        end;

        TempTendDeclEntry.Reset;
        TempTendDeclEntry.SetCurrentKey("Statement Code", "Z-Report ID", "Tender Type", "Currency Code", "Card No.");
    end;

    local procedure PrintCashDeclTotalLCYLine(TotalLCYAmount_p: Decimal)
    var
        Tray: Integer;
        DSTR1: Text[50];
        IsHandled: Boolean;
    begin

        DSTR1 := '#L######################### #R##########';
        Tray := 2;
        NodeName[1] := 'Total Text';
        NodeName[2] := 'Total Amount';
        Clear(Value);
        Value[1] := Text005 + ' ' + Globals.GetValue('CURRSYM');
        Value[2] := POSFunctions.FormatAmount(TotalLCYAmount_p);
        cduSender.PrintLine(Tray, cduSender.FormatLine(cduSender.FormatStr(Value, DSTR1), false, false, false, false));
        AddPrintLine(800, 2, NodeName, Value, DSTR1, false, false, false, false, Tray);
    end;

    local procedure GetTransactionDate(): Date
    var
        recTransactionHeader: Record "LSC Transaction Header";
    begin
        recTransactionHeader.RESET;
        recTransactionHeader.SETRANGE(recTransactionHeader."Store No.", Globals.StoreNo);
        recTransactionHeader.SETRANGE(recTransactionHeader."POS Terminal No.", Globals.TerminalNo);
        recTransactionHeader.SETRANGE(recTransactionHeader."Z-Report ID", '');
        recTransactionHeader.SETRANGE(recTransactionHeader."Transaction Type", recTransactionHeader."Transaction Type"::Sales);
        recTransactionHeader.SETFILTER("Entry Status", '<>%1', recTransactionHeader."Entry Status"::Voided);
        IF recTransactionHeader.FINDFIRST THEN BEGIN
            EXIT(recTransactionHeader.Date)
        END ELSE BEGIN
            EXIT(TODAY);
        END;
    end;

    procedure AssignTenderDetailstoBuffer(var recLPaymEntry: Record "LSC Trans. Payment Entry")
    var
        intLCtr: Integer;
        recLTenderType: Record "LSC Tender Type";
    begin
        recLTenderType.SetCurrentKey("Store No.");
        recLTenderType.SetRange("Store No.", Globals.StoreNo());
        recLTenderType.SetFilter(recLTenderType.Function, '<>%1', recLTenderType.Function::"Tender Remove/Float");
        if recLTenderType.FindFirst() then begin
            repeat
                recLPaymEntry.SetRange("Tender Type", recLTenderType.Code);
                recLPaymEntry.CalcSums("Amount Tendered");
                intLCtr += 1;
                InsertCardDetailsToBuffer(intLCtr, recLTenderType.Description, FORmat(recLTenderType.Function), recLPaymEntry."Amount Tendered", recLPaymEntry.Count);
            until recLTenderType.Next() = 0;
        end;
    end;

    procedure InsertCardDetailsToBuffer(pCounter: Integer; pDesc: Text; pDesc2: Text; pAmount: Decimal; pCount: Integer)
    begin
        recReportBuffer.INIT;
        recReportBuffer."No." := FORMAT(pCounter);
        recReportBuffer.Description := pDesc;
        recReportBuffer."Description 2" := pDesc2;
        recReportBuffer."Unit Price" := pAmount;
        recReportBuffer."Price Unit Conversion" := pCount;
        recReportBuffer.INSERT;
    end;
    //vincent12052025
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", OnBeforePrintHeader, '', false, false)]
    local procedure "LSC POS Print Utility_OnBeforePrintHeader"(var Sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; PreReceipt: Boolean; Tray: Integer; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var IsHandled: Boolean)
    var
        POSText: Record "LSC POS Terminal Receipt Text";
        Terminal: Record "LSC POS Terminal";
        ReceiptHeader: Record "LSC POS Terminal Receipt Head";
        RetailUtil: Codeunit "LSC Retail Price Utils";
        DSTR1: Text[100];
        ReceiptNo: Code[20];
    begin

        Terminal.Get(Transaction."POS Terminal No.");

        Clear(ReceiptNo);
        ReceiptHeader.Reset;
        ReceiptHeader.SetCurrentKey(Priority);

        ReceiptHeader.SetRange("Receipt Setup Location", Terminal."Receipt Setup Location");

        if ReceiptHeader.FindLast then begin
            repeat
                if RetailUtil.DiscValPerValid(ReceiptHeader."Validation Period ID", Transaction.Date, Transaction.Time) then begin
                    ReceiptNo := ReceiptHeader."No.";
                end;
            until (ReceiptHeader.Next(-1) = 0) or (ReceiptNo <> '');
        end;
        Clear(POSText);

        if (ReceiptNo <> '') then
            POSText.SetRange("No.", ReceiptNo)
        else
            POSText.SetRange("No.", '');

        if Terminal."Receipt Setup Location" = Terminal."Receipt Setup Location"::Terminal then begin
            POSText.SetRange(Relation, POSText.Relation::Terminal);
            POSText.SetRange(Number, Terminal."No.");
        end
        else begin
            POSText.SetRange(Relation, POSText.Relation::Store);
            POSText.SetRange(Number, Transaction."Store No.");
        end;
        POSText.SetRange(Type, POSText.Type::Top);

        if not POSText.FindFirst then
            POSText.SetRange("No.", '');

        if POSText.FindSet then begin
            repeat
                DSTR1 := GetDesignString(POSText);
                FieldValue[1] := POSText."Receipt Text";
                NodeName[1] := 'Header Line';

                Sender.PrintLine(Tray, Sender.FormatLine(Sender.FormatStr(FieldValue, DSTR1), POSText.Wide, POSText.Bold, POSText.High, POSText.Italic));
                Sender.AddPrintLine(100, 1, NodeName, FieldValue, DSTR1, POSText.Wide, POSText.Bold, POSText.High, POSText.Italic, Tray)
            until POSText.Next = 0;
            //VINCENT20250512

            FieldValue[1] := '';
            Sender.PrintLine(Tray, Sender.FormatLine(Sender.FormatStr(FieldValue, DSTR1), POSText.Wide, POSText.Bold, POSText.High, POSText.Italic));
            IF Transaction."Invoice No." <> '' then Begin
                FieldValue[1] := 'SALES INVOICE';
                Sender.PrintLine(Tray, Sender.FormatLine(Sender.FormatStr(FieldValue, DSTR1), POSText.Wide, POSText.Bold, POSText.High, POSText.Italic));
            End;
            /*   IF ((Transaction."Transaction Type" = Transaction."Transaction Type"::Sales) AND (Transaction."Entry Status" <> Transaction."Entry Status"::Voided)) OR
              ((Transaction."Sale Is Return Sale" = TRUE) AND (Transaction."Retrieved from Receipt No." = '')) then Begin
                  FieldValue[1] := 'SALES INVOICE';
                  Sender.PrintLine(Tray, Sender.FormatLine(Sender.FormatStr(FieldValue, DSTR1), POSText.Wide, POSText.Bold, POSText.High, POSText.Italic));
              End; */
            Sender.PrintSeperator(Tray);
        end;
        if PreReceipt then
            Sender.PrintProvisionalReceiptHeaderInfo(POSText, DSTR1, Tray, 0);

        IsHandled := true;
    end;


}
