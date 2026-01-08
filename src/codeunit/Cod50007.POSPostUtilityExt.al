codeunit 50007 "POSPostUtilityExt"
{
    EventSubscriberInstance = StaticAutomatic;

    var
        RetailSetup: Record "LSC Retail Setup";
        IniFileSection: Text[80];
        IniFilePath: Text[250];
        IniFileName: Label 'LSRETAIL.INI';
        POSSESSION: Codeunit "LSC POS Session";
        POSFunc: Codeunit "LSC POS Functions";

    [IntegrationEvent(false, false)]
    local procedure APOnBeforeInsertPaymentEntryV2(var POSTransaction: Record "LSC POS Transaction"; var POSTransLineTemp: Record "LSC POS Trans. Line" temporary; var TransPaymentEntry: Record "LSC Trans. Payment Entry")
    begin
    end;

    local procedure UpdatePosInfoTexts()
    var
        TenderType: Record "LSC Tender Type";
        POSTransaction: Record "LSC POS Transaction";
        Description: Text;
        Description2: Text;
        ChangeBackText: Label 'Change back in last transaction is ';
    begin
        // if TenderType.Get(PosTransaction."Store No.", PosTransaction."Tender Type Code") then;
        // if (PosTransaction.Remaining <> 0) or (PosTransaction.RemainingFCY <> 0) then begin
        //     Description := '';
        //     if PosTransaction.Remaining <> 0 then
        //         Description := ChangeBackText + ' ' + TenderType.Description + ' ' + FormatAmount(PosTransaction.Remaining);
        //     Description2 := '';
        //     if PosTransaction.RemainingFCY <> 0 then
        //         Description2 := PosTransaction."Last Currency Code" + ' ' + ChangeBackText + ' ' + FormatAmount(PosTransaction.RemainingFCY);

        //     POSTransactionGlob.GetPOSTransaction(POSTransaction);
        //     if abs(PosTransaction.Remaining) = abs(POSTransaction."Rounding Amount") then begin
        //         clear(Description);
        //         clear(Description2);
        //     end;

        //     POSGUI.UpdatePosInfoTexts(Description, Description2);
        //     POSTransactionGlob.SetPosInfoText1(Description);
        //     POSTransactionGlob.SetPosInfoText2(Description2);
        // end;
    end;

    local procedure GetTextValue(var POSTrans: Record "LSC POS Transaction"; FieldID: Integer): Code[20]
    var
        LRecRef: RecordRef;
        LFldRef: FieldRef;
    begin
        LRecRef.Open(99008980);
        LRecRef.Copy(POSTrans);
        if LRecRef.FindFirst() then begin
            LFldRef := LRecRef.Field(FieldID);
            if LRecRef.FindSet() then begin
                exit(Format(LFldRef.Value));
            end;
        end;
    end;
    //VINCENT20260108
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", OnAfterCompressSalesTrans, '', false, false)]
    local procedure "LSC POS Post Utility_OnAfterCompressSalesTrans"(TmpComprPOSTrLine: Record "LSC POS Trans. Line" temporary; var POSTransLineTmp: Record "LSC POS Trans. Line" temporary)
    var
        decVat: Decimal;
        POSTransaction: Record "LSC POS Transaction";
    begin
        POSTransaction.Get(POSTransLineTmp."Receipt No.");
        if POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::WHT1 THEN begin
            decVat := POSTransLineTmp.Amount - (POSTransLineTmp.Amount / (1 + (POSTransLineTmp."VAT %" / 100)));
            POSTransLineTmp."Net Amount" := Round(POSTransLineTmp.Amount / (1 + (POSTransLineTmp."VAT %" / 100)), 0.01);
            POSTransLineTmp."VAT Amount" := Round(decVat, 0.01);
            POSTransLineTmp.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnAfterInsertTransHeader', '', true, true)]
    local procedure OnAfterInsertTransHeader(var POSTrans: Record "LSC POS Transaction"; var Transaction: Record "LSC Transaction Header")
    var
        POSFunc: Codeunit "LSC POS Functions";
        recLPOSTerminal: Record "LSC POS Terminal";
        codLLastInvoiceNo: Code[20];
        codLInvoiceCounter: Code[10];
        txtLCustomerType: Text[50];
        intLLength: Integer;
        recLPOSTerminal2: Record "LSC POS Terminal";
        recLTH, Transaction2, TransHeaderNoSeries : Record "LSC Transaction Header";
        recCus: Record "Customer";
        Globals: Codeunit "LSC POS Session";
        APPOSSESSION: Record "AP POSSESSIONS";
        DepositSlip: Code[20];
        decLPostVoidSeries: Text[12];
        decLReturnSeries: Text[12];
    begin
        //Evaluate(Transaction."Transaction Code Type", Format(POSTrans."Transaction Code Type"));

        //Invoice Counter Features

        case POSTrans."Entry Status" of
            POSTrans."Entry Status"::" ":
                Transaction."Entry Status" := Transaction."Entry Status"::" ";
            POSTrans."Entry Status"::Voided:
                Transaction."Entry Status" := Transaction."Entry Status"::Voided;
            POSTrans."Entry Status"::Training:
                Transaction."Entry Status" := Transaction."Entry Status"::Training;
        end;
        if (Transaction."Transaction Code Type" = Transaction."Transaction Code Type"::DEPOSIT) or (Transaction."Transaction Code Type" = Transaction."Transaction Code Type"::"DEPOSIT REDEEM") then
            DepositSlip := GetTextValue(POSTrans, 50104);
        if DepositSlip = '' then
            if (Transaction."Transaction Type" = Transaction."Transaction Type"::Sales) then begin
                if (Transaction."Sale Is Return Sale" = false) and (Transaction."Entry Status" = Transaction."Entry Status"::" ") then begin
                    ReadLocalVarNavPH(codLLastInvoiceNo);
                    if (DelStr(codLLastInvoiceNo, 1, 3) = POSFunc.NumberPad('12', 12)) then begin
                        codLLastInvoiceNo := IncStr(codLLastInvoiceNo);
                        recLPOSTerminal.Reset();
                        recLPOSTerminal.SetRange("Store No.", Globals.StoreNo());
                        recLPOSTerminal.SetRange("No.", Globals.TerminalNo());
                        if recLPOSTerminal.FindFirst() then begin
                            // if (recLPOSTerminal."Invoice Counter" = '') then
                            //     recLPOSTerminal."Invoice Counter" := '00-';

                            recLPOSTerminal."Invoice Counter" := IncStr(recLPOSTerminal."Invoice Counter");
                            recLPOSTerminal.Modify();
                        end;
                    end;

                    codLLastInvoiceNo := IncStr(codLLastInvoiceNo);

                    recLPOSTerminal.Reset();
                    recLPOSTerminal.SetRange("Store No.", Globals.StoreNo());
                    recLPOSTerminal.SetRange("No.", Globals.TerminalNo());
                    if recLPOSTerminal.FindFirst() then begin
                        // if (recLPOSTerminal."Invoice Counter" = '') then
                        //     recLPOSTerminal."Invoice Counter" := '00-';

                        codLInvoiceCounter := recLPOSTerminal."Invoice Counter";
                    end;

                    Transaction."Invoice No." := codLInvoiceCounter + POSFunc.ZeroPad(codLLastInvoiceNo, 12);
                    WriteLocalVarLSNavPh(Transaction."Invoice No.");
                end;
            end;

        txtLCustomerType := Format(POSTrans."Transaction Code Type");
        Transaction."Zero Rated Amount" := POSTrans."Zero Rated Amount";

        if txtLCustomerType = 'Regular Customer' then begin
            Transaction."Customer Type" := Transaction."Customer Type"::"Regular Customer";
            Transaction."Transaction Code Type" := Transaction."Transaction Code Type"::"Regular Customer";
        end;
        if txtLCustomerType = 'SRC' then begin
            Transaction."Customer Type" := Transaction."Customer Type"::"Senior Citizen";
            Transaction."Transaction Code Type" := Transaction."Transaction Code Type"::"SC";
            Transaction."Beginning Balance" := POSTrans."Beginning Balance";
            Transaction."Current Balance" := POSTrans."Current Balance";
        end;
        if txtLCustomerType = 'PWD' then begin
            Transaction."Customer Type" := Transaction."Customer Type"::PWD;
            Transaction."Transaction Code Type" := Transaction."Transaction Code Type"::PWD;
            Transaction."Beginning Balance" := POSTrans."Beginning Balance";
            Transaction."Current Balance" := POSTrans."Current Balance";
        end;
        if txtLCustomerType = 'SOLO' then begin
            Transaction."Customer Type" := Transaction."Customer Type"::"Solo Parent";
            Transaction."Transaction Code Type" := Transaction."Transaction Code Type"::SOLO;
            Transaction."Beginning Balance" := POSTrans."Beginning Balance";
            Transaction."Current Balance" := POSTrans."Current Balance";
        end;
        if txtLCustomerType = 'WHT1' then begin
            Transaction."Customer Type" := Transaction."Customer Type"::"Withholding Tax";
            Transaction."Transaction Code Type" := Transaction."Transaction Code Type"::WHT1;
            Transaction."WHT Amount" := POSTrans."WHT Amount";
        end;
        if txtLCustomerType = 'VATW' then begin
            Transaction."Customer Type" := Transaction."Customer Type"::"VAT Withholding Tax";
            Transaction."Transaction Code Type" := Transaction."Transaction Code Type"::VATW;
            Transaction."VAT Withholding" := POSTrans."VAT Withholding";
        end;
        if txtLCustomerType = 'ZERO' then begin
            Transaction."Customer Type" := Transaction."Customer Type"::"Zero Rated";
            Transaction."Transaction Code Type" := Transaction."Transaction Code Type"::ZERO;
            Transaction."Zero Rated Amount" := POSTrans."Zero Rated Amount";
        end;
        if txtLCustomerType = 'ZRWH' then begin
            Transaction."Customer Type" := Transaction."Customer Type"::ZRWH;
            Transaction."Transaction Code Type" := Transaction."Transaction Code Type"::ZRWH;
            Transaction."ZRWHT Amount" := POSTrans."ZRWHT Amount";
        end;
        if txtLCustomerType = 'ATHL' then begin
            Transaction."Customer Type" := Transaction."Customer Type"::ATHL;
            Transaction."Transaction Code Type" := Transaction."Transaction Code Type"::ATHL;
            Transaction."Beginning Balance" := POSTrans."Beginning Balance";
            Transaction."Current Balance" := POSTrans."Current Balance";
        end;
        if txtLCustomerType = 'MOV' then begin
            Transaction."Customer Type" := Transaction."Customer Type"::MOV;
            Transaction."Transaction Code Type" := Transaction."Transaction Code Type"::ATHL;
            Transaction."Beginning Balance" := POSTrans."Beginning Balance";
            Transaction."Current Balance" := POSTrans."Current Balance";
        end;
        if txtLCustomerType = 'NAAC' then begin
            Transaction."Customer Type" := Transaction."Customer Type"::NAAC;
            Transaction."Transaction Code Type" := Transaction."Transaction Code Type"::NAAC;
            Transaction."Beginning Balance" := POSTrans."Beginning Balance";
            Transaction."Current Balance" := POSTrans."Current Balance";
        end;
        APPOSSESSION.Reset();
        if APPOSSESSION.FindFirst() then begin
            // APPOSSESSION."POST COMMAND" := '';
            // APPOSSESSION."POST PARAMETER" := '';
            //APPOSSESSION."Card type Param" := '';
            APPOSSESSION."Entry No." := '';
            APPOSSESSION."Beg Bal" := false;
            //APPOSSESSION."VOID TR" := false;
            APPOSSESSION.Modify();
        end else begin
            APPOSSESSION.Init();
            // APPOSSESSION."POST COMMAND" := '';
            // APPOSSESSION."POST PARAMETER" := '';
            //APPOSSESSION."Card type Param" := '';
            APPOSSESSION."Entry No." := '';
            APPOSSESSION."Beg Bal" := false;
            //APPOSSESSION."VOID TR" := false;
            APPOSSESSION.Insert();
        end;
        POSSESSION.ClearManagerID();
        // POST VOID
        IF Transaction."Transaction Type" = Transaction."Transaction Type"::Sales THEN BEGIN
            if (Transaction."Sale Is Return Sale") AND (Transaction."Retrieved from Receipt No." <> '') AND (Transaction."Transaction Code Type" <> Transaction."Transaction Code Type"::DEPOSIT) then begin
                Transaction2.Reset();
                Transaction2.SetRange("Receipt No.", Transaction."Retrieved from Receipt No.");
                if Transaction2.FindFirst() then begin
                    Transaction."Transaction Code Type" := Transaction2."Transaction Code Type";
                    // MARCUS 20251230
                    TransHeaderNoSeries.SetCurrentKey("Post Void No. Series");
                    TransHeaderNoSeries.SetFilter("Post Void No. Series", '<>%1', '');
                    IF TransHeaderNoSeries.FINDLAST THEN BEGIN
                        decLPostVoidSeries := TransHeaderNoSeries."Post Void No. Series";
                    END ELSE BEGIN
                        decLPostVoidSeries := '000000000000';
                    END;

                    Transaction2."Post Void No. Series" := POSFunc.ZeroPad(INCSTR(decLPostVoidSeries), 12);
                    Transaction2.MODIFY;
                end;
            end;
            // Return
            if (Transaction."Sale Is Return Sale") AND (Transaction."Retrieved from Receipt No." = '') AND (Transaction."Transaction Code Type" <> Transaction."Transaction Code Type"::DEPOSIT) then begin
                Transaction."Transaction Code Type" := Transaction2."Transaction Code Type";
                TransHeaderNoSeries.SetCurrentKey("Return No. Series");
                TransHeaderNoSeries.SetFilter("Return No. Series", '<>%1', '');
                IF TransHeaderNoSeries.FINDLAST THEN BEGIN
                    decLReturnSeries := TransHeaderNoSeries."Return No. Series";
                END ELSE BEGIN
                    decLReturnSeries := '000000000000';
                END;

                Transaction."Refund Reason" := POSTrans."Refund Reason";

                Transaction."Return No. Series" := POSFunc.ZeroPad(INCSTR(decLReturnSeries), 12);
            end;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'SalesEntryOnBeforeInsertV2', '', true, true)]
    local procedure SalesEntryOnBeforeInsertV2(var pPOSTransLineTemp: Record "LSC POS Trans. Line" temporary; var pTransSalesEntry: Record "LSC Trans. Sales Entry"; var Transaction: Record "LSC Transaction Header"; Sign: Integer)//(var pPOSTransLine: Record "LSC POS Trans. Line"; var pTransSalesEntry: Record "LSC Trans. Sales Entry")
    var
        Item: Record Item;
        PriceListLine: Record "Price List Line";
        PriceListHeader: Record "Price List Header";
    begin
        pTransSalesEntry."Local VAT Code" := pPOSTransLineTemp."Local VAT Code";
        Item.RESET;
        Item.SETRANGE("No.", pPOSTransLineTemp.Number);
        IF Item.FINDFIRST THEN BEGIN
            PriceListLine.RESET;
            PriceListLine.SETRANGE("Product No.", Item."No.");
            PriceListLine.SETRANGE(Status, PriceListLine.Status::Active);

            IF PriceListLine.FINDLAST THEN BEGIN
                pTransSalesEntry."Original Price Amount" := PriceListLine."LSC Unit Price Including VAT";
            END ELSE BEGIN
                pTransSalesEntry."Original Price Amount" := Item."Unit Price";
            END;
        END;
        pTransSalesEntry."Item Disc. % Orig." := pPOSTransLineTemp."Item Disc. % Orig.";
        //Message('%1', pPOSTransLineTemp."Vat Amount");
        if Transaction."Sale Is Return Sale" then
            pTransSalesEntry."Net Amount" := pPOSTransLineTemp."Net Amount";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", OnBeforeInsertPaymentEntryV2, '', false, false)]
    local procedure "LSC POS Post Utility_OnBeforeInsertPaymentEntryV2"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLineTemp: Record "LSC POS Trans. Line" temporary; var TransPaymentEntry: Record "LSC Trans. Payment Entry")
    var
        RetTransPaymentEntry: Record "LSC Trans. Payment Entry";
    begin
        TransPaymentEntry."Card Approval Code" := POSTransLineTemp."Card Approval Code";
        TransPaymentEntry."Card Type" := POSTransLineTemp."Card Type";
        TransPaymentEntry."Current Balance" := POSTransLineTemp."Current Balance";
        TransPaymentEntry."Card holder Name" := POSTransLineTemp."Card Holder Name";

        if POSTransaction."Sale Is Return Sale" then begin
            RetTransPaymentEntry.Reset();
            RetTransPaymentEntry.SetRange("Receipt No.", POSTransaction."Retrieved from Receipt No.");
            RetTransPaymentEntry.SetRange("Tender Type", TransPaymentEntry."Tender Type");
            if RetTransPaymentEntry.FindFirst() then begin
                TransPaymentEntry."Card Approval Code" := RetTransPaymentEntry."Card Approval Code";
                TransPaymentEntry."Card Type" := RetTransPaymentEntry."Card Type";
                TransPaymentEntry."Card or Account" := RetTransPaymentEntry."Card or Account";
            end;
        end;
        APOnBeforeInsertPaymentEntryV2(POSTransaction, POSTransLineTemp, TransPaymentEntry);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", OnAfterPostTransaction, '', false, false)]
    local procedure "LSC POS Post Utility_OnAfterPostTransaction"(var TransactionHeader_p: Record "LSC Transaction Header")
    begin
        // Check if the transaction code type matches specific types
        if TransactionHeader_p."Transaction Code Type" in [
            TransactionHeader_p."Transaction Code Type"::"SC",
            TransactionHeader_p."Transaction Code Type"::PWD,
            TransactionHeader_p."Transaction Code Type"::SOLO,
            TransactionHeader_p."Transaction Code Type"::NAAC,
            TransactionHeader_p."Transaction Code Type"::MOV
        ] then
            AdjustTransactionVATDetails(TransactionHeader_p);
    end;


    local procedure GetIniFileInfo()
    begin
        if RetailSetup.Get then begin
            if RetailSetup."IniFile Section Identifier" = RetailSetup."IniFile Section Identifier"::Company_Userid then
                IniFileSection := UpperCase(CompanyName + UserId)
            else
                IniFileSection := UpperCase(CompanyName);

            IniFilePath := RetailSetup."IniFile Path" + IniFileName;
        end
        else begin
            IniFileSection := UpperCase(CompanyName);
            IniFilePath := IniFileName;
        end;
    end;

    procedure ReadLocalVarNavPH(var LastInvoiceNo: Code[20])
    //readlocalvarnavph  --from posfunc
    var
        Transaction: Record "LSC Transaction Header";
        TmpLastInvoice: Text[30];
        FilterFrom: Text[30];
        FilterTo: Text[30];
        ExistingReceiptNo: Code[20];
        recLPosTerminal: Record "LSC POS Terminal";
    begin
        if recLPosTerminal.Get(POSSESSION.TerminalNo()) then begin
            LastInvoiceNo := recLPosTerminal."Invoice No.";
        end;

        if LastInvoiceNo = '' then
            LastInvoiceNo := '0';

        TmpLastInvoice := POSFunc.ZeroPad(POSSESSION.TerminalNo(), 10) + POSFunc.ZeroPad(LastInvoiceNo, 15);
        Transaction.SetCurrentKey("Invoice No.");
        FilterFrom := POSFunc.ZeroPad(POSSESSION.TerminalNo(), 8) + POSFunc.ZeroPad('0', 7);
        FilterTo := POSFunc.ZeroPad(POSSESSION.TerminalNo(), 8) + POSFunc.NumberPad('15', 7);
        Transaction.SetRange("Invoice No.", FilterFrom, FilterTo);
        Transaction.SetRange("POS Terminal No.", recLPosTerminal."No.");

        ExistingReceiptNo := '';
        If Transaction.FindLast() then
            if Transaction."Invoice No." > TmpLastInvoice then
                ExistingReceiptNo := Transaction."Invoice No.";

        if ExistingReceiptNo <> '' then
            LastInvoiceNo := ExistingReceiptNo;
    end;

    procedure WriteLocalVarLSNavPh(LastInvoiceNo: Code[20])
    //writelocalvarnavph  --from posfunc
    var
        recLPOSTerminal: Record "LSC POS Terminal";
    begin
        if recLPOSTerminal.Get(POSSESSION.TerminalNo()) then begin
            recLPOSTerminal."Invoice No." := LastInvoiceNo;
            recLPOSTerminal.Modify();
        end;
    end;


    procedure AdjustTransactionVATDetails(pRec: Record "LSC Transaction Header")
    var
        recLTransSales: Record "LSC Trans. Sales Entry";
    begin


        // Filter transaction lines based on header details
        recLTransSales.Reset;
        recLTransSales.SetRange("Store No.", pRec."Store No.");
        recLTransSales.SetRange("POS Terminal No.", pRec."POS Terminal No.");
        recLTransSales.SetRange("Receipt No.", pRec."Receipt No.");
        if recLTransSales.FindFirst then begin
            repeat
                case recLTransSales."VAT Code" of
                    'V', 'VAT12':
                        begin
                            // recLTransSales."Net Amount" := POSAdditionalFunction.RoundLocal(
                            recLTransSales."Net Amount" := Round(((recLTransSales."Total Rounded Amt." - recLTransSales."Total Discount")
                                                                + (recLTransSales."Line Discount" * -1)) / 1.12, 0.0001, '=');
                            // );
                            recLTransSales."VAT Amount" := ((recLTransSales."Total Rounded Amt." - recLTransSales."Total Discount") + (recLTransSales."Line Discount" * -1)) - recLTransSales."Net Amount";
                            recLTransSales."Net Amount" := recLTransSales."Total Rounded Amt.";
                            recLTransSales.Modify;
                        end;
                    'VE':
                        begin
                            recLTransSales."Net Amount" := (recLTransSales."Total Rounded Amt." - recLTransSales."Total Discount");// + (recLTransSales."Line Discount" * -1);
                            recLTransSales.Modify;
                        end;
                end;
            until recLTransSales.Next = 0;
        end;
    end;
}