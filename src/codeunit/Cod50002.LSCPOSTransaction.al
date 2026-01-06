codeunit 50002 "AP POS Transaction"
{
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterValidateItemLine, '', false, false)]
    // local procedure "LSC POS Transaction Events_OnAfterValidateItemLine"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Proceed: Boolean)
    // begin
    //     if POSTransLine.count > 0 then begin

    //     end;

    // end;
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeInsertItemLine, '', false, false)]
    // local procedure "LSC POS Transaction Events_OnBeforeInsertItemLine"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var CompressEntry: Boolean)
    // begin
    //     CompressEntry := false;
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeItemLine, '', false, false)]
    local procedure "LSC POS Transaction Events_OnBeforeItemLine"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    var
        item: Record Item;
        barcode: Record "LSC Barcodes";
        codLPOSTrans: Codeunit "LSC POS Transaction";
        DrawerDevice: Record "LSC POS Drawer";
        terminal: Record "LSC POS Terminal";
    begin

        if (POSTransaction."Transaction code type" = POSTransaction."Transaction code type"::NAAC) or
              (POSTransaction."Transaction code type" = POSTransaction."Transaction code type"::MOV) then begin

            /* item.Reset();
            item.SetRange("No.", CurrInput);
            if item.FindFirst() then begin
                if (item."MOV Discount %" <= 0) or (item."NAAC Discount %" <= 0) then
                    codPOSTrans.ErrorBeep('The item associated with the scanned barcode is invalid due to zero discount % settings in retail item card.');
                CurrInput := '';
                codPOSTrans.CancelPressed(true, 0);
                exit;
            end; */
        end;

        if POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::ONLINE then begin

        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", OnBeforePeriodicDiscAndAdditionalBenefitCalcOnTotalPressed, '', false, false)]
    local procedure "LSC POS Transaction_OnBeforePeriodicDiscAndAdditionalBenefitCalcOnTotalPressed"(var Sender: Codeunit "LSC POS Transaction"; POSTransaction: Record "LSC POS Transaction"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", OnBeforeProcessKeyBoardResult, '', false, false)]
    local procedure "LSC POS Transaction_OnBeforeProcessKeyBoardResult"(Payload: Text; InputValue: Text; ResultOK: Boolean; var IsHandled: Boolean)
    var
        TenderTypeCardSetup: RECORD "LSC Tender Type Card Setup";
        Rec: Record "LSC POS Transaction";
    begin
        if CopyStr(Payload, 1, 12) = '#CardHolName' then begin
            if ResultOK then begin
                if InputValue <> '' then begin

                    IF APPOSSESSION.FindFirst() then begin
                        APPOSSESSION."AP Card Name" := InputValue;

                        IF APPOSSESSION."Card type Param" <> '' THEN BEGIN
                            TenderTypeCardSetup.Reset();
                            TenderTypeCardSetup.SetRange("Card No.", APPOSSESSION."Card type Param");
                            if TenderTypeCardSetup.findfirst() then begin
                                if TenderTypeCardSetup."E-Wallet" then
                                    codPOSTrans.OpenNumericKeyboard('Reference No.', '', 81)
                                else
                                    codPOSTrans.OpenNumericKeyboard('Approval Code', '', 81);
                            end;
                        end else
                            codPOSTrans.OpenNumericKeyboard('Approval Code', '', 81);
                        APPOSSESSION.Modify();
                    end;
                end else begin
                    codPOSTrans.PosErrorBanner('The Card Holder Name cannot be blank!');
                    codPOSTrans.CancelPressed(false, 0);
                    codPOSTrans.SetPOSState('PAYMENT');
                    codPOSTrans.SetFunctionMode('PAYMENT');
                    POSGUI.OpenAlphabeticKeyboard('Card Holder Name', '', false, '#CardHolName', 100);
                end;
            end;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeAskConfirmationOnValidateCustomer, '', false, false)]
    local procedure OnBeforeAskConfirmationOnValidateCustomer(CustomerNo: code[20]; var CustConfirmOk: Boolean; var AskConfirmation: Boolean);
    var
        Customer: Record Customer;
        ConfirmCustQst: Label '\\Confirm customer?';
    begin
        AskConfirmation := false;
        if Customer.Get(CustomerNo) then begin
            if POSGUI.PosConfirm(Customer."No." + ' ' + Customer.Name + '\\ID/TIN No. :' + Customer.TIN + ConfirmCustQst, true) then
                CustConfirmOk := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterValidateCustomer', '', false, false)]
    local procedure OnAfterValidateCustomer(var POSTransaction: Record "LSC POS Transaction")
    var
        TransCodeType: Code[20];
    begin
        TransCodeType := POSSESSION.GetValue('TRANS_CODE_TYPE');

        if TransCodeType = 'SRC' then begin
            POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::"SRC";
            POSTransaction."Sale Is Return Sale" := false;
            POSTransaction.Modify();
            APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::SRC;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::SRC;
                APPOSSESSION.Insert();
            end;
            codPOSTrans.CancelPressed(true, 0);
            EXIT;
        end;
        if TransCodeType = 'PWD' then begin
            POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::PWD;
            POSTransaction."Sale Is Return Sale" := false;
            POSTransaction.Modify();
            APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::PWD;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::PWD;
                APPOSSESSION.Insert();
            end;
        end;
        if TransCodeType = 'SOLO' then begin
            POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::SOLO;
            POSTransaction."Sale Is Return Sale" := false;
            POSTransaction."Beginning Balance" := 0;
            POSTransaction."Booklet No." := '';
            POSTransaction.Modify();
            APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::SOLO;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::SOLO;
                APPOSSESSION.Insert();
            end;
        end;
        if TransCodeType = 'ATHL' then begin
            POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::ATHL;
            POSTransaction."Sale Is Return Sale" := false;
            POSTransaction."Beginning Balance" := 0;
            POSTransaction."Booklet No." := '';
            POSTransaction.Modify();
            APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::ATHL;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::ATHL;
                APPOSSESSION.Insert();
            end;
        end;
        if TransCodeType = 'WHT' then begin
            POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::WHT1;
            POSTransaction."Sale Is Return Sale" := false;
            POSTransaction."Beginning Balance" := 0;
            POSTransaction."Booklet No." := '';
            POSTransaction.Modify();
            APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::WHT1;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::WHT1;
                APPOSSESSION.Insert();
            end;
        end;
        if TransCodeType = 'VATW' then begin
            POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::VATW;
            POSTransaction."Sale Is Return Sale" := false;
            POSTransaction."Beginning Balance" := 0;
            POSTransaction."Booklet No." := '';
            POSTransaction.Modify();
            APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::VATW;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::VATW;
                APPOSSESSION.Insert();
            end;
        end;
        if TransCodeType = 'ZERO' then begin
            POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::ZERO;
            POSTransaction."Sale Is Return Sale" := false;
            POSTransaction."Beginning Balance" := 0;
            POSTransaction."Booklet No." := '';
            POSTransaction.Modify();
            APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::ZERO;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::ZERO;
                APPOSSESSION.Insert();
            end;
        end;
        if TransCodeType = 'ZRWHT' then begin
            POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::ZRWH;
            POSTransaction."Sale Is Return Sale" := false;
            POSTransaction."Beginning Balance" := 0;
            POSTransaction."Booklet No." := '';
            POSTransaction.Modify();
            APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::ZRWH;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::ZRWH;
                APPOSSESSION.Insert();
            end;
        end;
        if TransCodeType = 'NAAC' then begin
            POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::NAAC;
            POSTransaction."Sale Is Return Sale" := false;
            POSTransaction.Modify();
            APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::NAAC;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::NAAC;
                APPOSSESSION.Insert();
            end;
        end;
        if TransCodeType = 'MOV' then begin
            POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::MOV;
            POSTransaction."Sale Is Return Sale" := false;
            POSTransaction.Modify();
            APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::MOV;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::MOV;
                APPOSSESSION.Insert();
            end;
        end;
        if TransCodeType = 'ONLINECUST' then begin
            POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::ONLINE;
            POSTransaction."Sale Is Return Sale" := false;
            POSTransaction.Modify();
            APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::ONLINE;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::ONLINE;
                APPOSSESSION.Insert();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforePosConfirm, '', false, false)]
    local procedure "LSC POS Transaction Events_OnBeforePosConfirm"(var POSTransaction: Record "LSC POS Transaction"; Message: Text; var IsHandled: Boolean; var ReturnValue: Boolean)
    begin
        if Message = 'Are you sure you want to print a Y Report?' then begin
            IsHandled := true;
            ReturnValue := true;
        end;
    end;

    procedure CompressPOSTransLines(POSTransLine: Record "LSC POS Trans. Line")
    var
        POSLine: Record "LSC POS Trans. Line";
        CompressedPOSLine: Record "LSC POS Trans. Line";
        TempPOSLine: Record "LSC POS Trans. Line" temporary;
    begin
        // Step 1: Load all POS lines into a temporary table grouped by Item No. and Location Code
        // POSLine.SetRange(Number, POSTransLine.Number);
        if POSLine.FindSet() then
            repeat
                TempPOSLine.SetRange(Number, POSLine.Number);
                TempPOSLine.SetRange("Receipt No.", POSLine."Receipt No.");
                if TempPOSLine.FindFirst() then begin
                    TempPOSLine.Number := POSLine.Number;
                    TempPOSLine.Quantity += POSLine.Quantity;
                    TempPOSLine."Unit of Measure" := '';
                    TempPOSLine.Modify();
                end else begin
                    TempPOSLine := POSLine;
                    TempPOSLine."Unit of Measure" := '';
                    TempPOSLine.Insert();
                end;
            until POSLine.Next() = 0;

        // Step 2: Replace original records with compressed ones
        POSLine.DeleteAll();
        if TempPOSLine.FindSet() then
            repeat
                CompressedPOSLine := TempPOSLine;
                CompressedPOSLine."Unit of Measure" := '';
                CompressedPOSLine.Insert();
            until TempPOSLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterInsertItemLine, '', false, false)]
    local procedure "LSC POS Transaction Events_OnAfterInsertItemLine"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
        CompressPerPOSTransLines(POSTransLine);
    end;


    procedure CompressPerPOSTransLines(POSTransLine: Record "LSC POS Trans. Line")
    var
        POSLine: Record "LSC POS Trans. Line";
        CompressedPOSLine: Record "LSC POS Trans. Line";
        TempPOSLine: Record "LSC POS Trans. Line" temporary;
        Barcode: Record "LSC Barcodes";
        PosPriceUtility: Codeunit "LSC POS Price Utility";
        POSTransPeriodicDisc: Record "LSC POS Trans. Per. Disc. Type";

    begin
        // Step 1: Load all POS lines into a temporary table grouped by Item No. and Location Code

        POSLine.SetRange(Number, POSTransLine.Number);
        if POSLine.FindSet() then
            repeat
                // if POSLine."Barcode No." <> '' then begin
                //     if Barcode.Get(POSLine."Barcode No.") then
                //         if Barcode."Discount %" <> 0 then begin
                //             PosPriceUtility.InsertTransDiscPercent(POSLine, Barcode."Discount %", POSTransPeriodicDisc.DiscType::Line, '');
                //             POSLine.CalcPrices;
                //         end;
                // end;
                TempPOSLine.SetRange("Barcode No.", POSLine."Barcode No.");
                TempPOSLine.SetRange("Receipt No.", POSLine."Receipt No.");
                if TempPOSLine.FindFirst() then begin
                    //TempPOSLine := POSLine;
                    TempPOSLine.Number := POSLine.Number;
                    TempPOSLine.Quantity += POSLine.Quantity;
                    TempPOSLine.Amount += POSLine.Price;

                    TempPOSLine."Unit of Measure" := '';
                    if TempPOSLine.Modify() then;
                end else begin
                    TempPOSLine := POSLine;
                    TempPOSLine."Unit of Measure" := '';
                    TempPOSLine.Insert();
                end;
            until POSLine.Next() = 0;

        // Step 2: Replace original records with compressed ones
        POSLine.DeleteAll();
        if TempPOSLine.FindSet() then
            repeat
                CompressedPOSLine := TempPOSLine;
                CompressedPOSLine."Unit of Measure" := '';

                if CompressedPOSLine."Barcode No." <> '' then begin
                    Barcode.SetRange("Barcode No.", CompressedPOSLine."Barcode No.");
                    if Barcode.FindFirst() then
                        if Barcode."Discount %" <> 0 then begin
                            PosPriceUtility.InsertTransDiscPercent(CompressedPOSLine, Barcode."Discount %", POSTransPeriodicDisc.DiscType::Line, '');
                            CompressedPOSLine.CalcPrices;
                        end;
                end;
                CompressedPOSLine.Insert();
            until TempPOSLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterRunCommand, '', false, false)]
    local procedure "LSC POS Transaction Events_OnAfterRunCommand"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Command: Code[20]; var POSMenuLine: Record "LSC POS Menu Line")
    begin
        if POSMenuLine.Command = 'QTY' then
            POSSESSION.clearManagerID();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeSelectCustPressed, '', false, false)]
    local procedure "LSC POS Transaction Events_OnBeforeSelectCustPressed"(var CustomerMandatory: Boolean)
    begin
        CustomerMandatory := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Controller", OnPOSCommand, '', false, false)]
    local procedure "LSC POS Controller_OnPOSCommand"(var ActivePanel: Record "LSC POS Panel"; var PosMenuLine: Record "LSC POS Menu Line")
    var
        lReceiptNo: Code[20];
        lPOSTransaction: Record "LSC POS Transaction";
    begin
        if PosMenuLine.Command = 'MENU' then
            if POSMenuLine.Parameter = 'AI-TRANS-TYPE' then begin
                lReceiptNo := codPOSTrans.GetReceiptNo();
                if lPOSTransaction.Get(lReceiptNo) then begin
                    if ValidateDepositTrans(lPOSTransaction) then
                        POSMenuLine.Processed := true;
                    if lPOSTransaction."Total Pressed" then begin
                        codPOSTrans.SetPOSState('PAYMENT');
                        codPOSTrans.SetFunctionMode('PAYMENT');
                    end;
                end;
            end;
        CASE PosMenuLine.Command OF //VINCENT20251215
            'ONLINE-DEBIT':
                begin
                    codPOSTrans.OpenNumericKeyboard('Amount ', Format(codPOSTrans.GetOutstandingBalance(), 0, '<Sign><Integer Thousand><Decimal,3>'), 50);//DEBIT
                end;
            'ONLINE-CREDIT':
                begin
                    codPOSTrans.OpenNumericKeyboard('Amount ', Format(codPOSTrans.GetOutstandingBalance(), 0, '<Sign><Integer Thousand><Decimal,3>'), 51);//CREDIT
                end;
            'ONLINE-QR-PAY':
                begin
                    codPOSTrans.OpenNumericKeyboard('Amount ', Format(codPOSTrans.GetOutstandingBalance(), 0, '<Sign><Integer Thousand><Decimal,3>'), 52);//QRPAY
                end;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeRunCommand, '', false, false)]
    local procedure "LSC POS Transaction Events_OnBeforeRunCommand"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var POSMenuLine: Record "LSC POS Menu Line"; var isHandled: Boolean; TenderType: Record "LSC Tender Type"; var CusomterOrCardNo: Code[20])
    var
        POSMenuLine2: Record "LSC POS Menu Line";
        POSTransLine2: Record "LSC POS Trans. Line";
        POSTransLine_, RecLTransLine : Record "LSC POS Trans. Line";
        poscom: Record "LSC POS Command";
        POSDataTable: record "LSC POS Data Table Columns";
        userask: Boolean;
        customer: Record Customer;
        BegBal: Decimal;
        Booklet: Code[30];

        l_POSPrintUtility: Codeunit "AP POS Print Utility";
        PageDialog: Page "ReprintZDialog";
        StartDate: Date;
        EndDate: Date;
    begin
        if POSMenuLine.Command = 'QTY' then begin
            if GetOpenEOD() then begin
                isHandled := true;
                EXIT;
            end;
            if CheckifEOSrocessToday THEN begin
                isHandled := true;
                EXIT;
            end;
            if POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::DEPOSIT then begin
                codPOSTrans.PosErrorBanner('You cannot use the function Quantity in Deposit Transaction.');
                POSSESSION.clearManagerID();
                codPOSTrans.SetPOSState('PAYMENT');
                codPOSTrans.SetFunctionMode('PAYMENT');
                isHandled := true;
                EXIT;
            end;
            if POSTransaction."Total Pressed" then begin
                codPOSTrans.PosErrorBanner('You cannot add item after total.');
                codPOSTrans.CancelPressed(false, 0);
                POSSESSION.clearManagerID();
                codPOSTrans.SetPOSState('PAYMENT');
                codPOSTrans.SetFunctionMode('PAYMENT');
                isHandled := true;
                EXIT;
            end;

        end;
        if POSMenuLine.Command = 'QTYCH' then begin
            if POSTransaction."Total Pressed" then begin
                codPOSTrans.PosErrorBanner('You cannot change quantity once total pressed.');
                codPOSTrans.CancelPressed(true, 0);
                POSSESSION.clearManagerID();
                isHandled := true;
                EXIT;
            end;
        end;
        if POSMenuLine.Command = 'REASON' then begin

        end;
        if POSMenuline.Command = 'REPRINT-Z' then begin
            IF PageDialog.RunModal = Action::OK THEN BEGIN
                StartDate := PageDialog.GetStartDate;
                EndDate := PageDialog.GetEndDate;

                l_POSPrintUtility.ReprintZ(StartDate, EndDate);
                // Message('%1 %2', StartDate, EndDate);
            END;
        end;
        if POSMenuline.Command = 'PRINT_Z' then begin
            if not Checkifwithsuspendtrans(POSSESSION.StoreNo()) then begin
                codPOSTrans.PosErrorBanner('You are not allowed to print Z reading if with suspended transaction');
                codPOSTrans.CancelPressed(true, 0);
                EXIT;
            end;
            /* if not CheckifwithTransLine(POSSESSION.StoreNo()) then begin
                codPOSTrans.PosErrorBanner('Current Transaction must be finished.');
                codPOSTrans.CancelPressed(true, 0);
                POSSESSION.clearManagerID();
                isHandled := true;
                EXIT;
            end; */
        end;
        if (POSMenuLine.Command = 'PRINT_X') or (POSMenuLine.Command = 'PRINT_Y') then begin
            if not CheckifwithTransLine(POSSESSION.StoreNo()) then begin
                codPOSTrans.PosErrorBanner('Current Transaction must be finished.');
                codPOSTrans.CancelPressed(true, 0);
                POSSESSION.clearManagerID();
                isHandled := true;
                EXIT;
            end;
            if (POSMenuLine.Command = 'PRINT_Y') then begin
                if not Checkifwithsuspendtrans(POSSESSION.StoreNo()) then begin
                    codPOSTrans.PosErrorBanner('You are not allowed to perform Terminal Reading if with Suspended Transaction.');
                    codPOSTrans.CancelPressed(true, 0);
                    POSSESSION.clearManagerID();
                    isHandled := true;
                    EXIT;
                end;

                if not POSGUI.PosConfirm('Are you sure you want to print a Y Report?', false) then begin
                    POSSESSION.clearManagerID();
                    isHandled := true;
                    exit;
                end;
            end;

            if (POSMenuLine.Command = 'PRINT_X') then begin
                if not Checkifwithsuspendtrans(POSSESSION.StoreNo()) then begin
                    codPOSTrans.PosErrorBanner('You are not allowed to perform Cashier Reading if with Suspended Transaction.');
                    codPOSTrans.CancelPressed(true, 0);
                    POSSESSION.clearManagerID();
                    isHandled := true;
                    EXIT;
                end;
                if CheckifEODProcessToday() THEN begin
                    codPOSTrans.CancelPressed(true, 0);
                    POSSESSION.clearManagerID();
                    isHandled := true;
                    EXIT;
                end;
                if CheckifEOSrocessToday THEN begin
                    codPOSTrans.CancelPressed(true, 0);
                    POSSESSION.clearManagerID();
                    isHandled := true;
                    EXIT;
                end;
                if not POSGUI.PosConfirm('Are you sure you want to print a X Report?', false) then begin
                    POSSESSION.clearManagerID();
                    isHandled := true;
                    exit;
                end;
            end;
        end;
        if (POSMenuline.Command = 'AP_FLOAT_ENT') or (POSMenuline.Command = 'AP_REM_TENDER') or (POSMenuline.Command = 'AP_TENDER_D') or (POSMenuline.Command = 'SUSPEND') then begin
            if GetOpenEOD THEN   // Check if previous day is not yet perform eod
            begin
                POSSESSION.clearManagerID();
                isHandled := true;
                exit;
            end;
            if CheckifEODProcessToday THEN //if already performed EOD
                begin
                POSSESSION.clearManagerID();
                isHandled := true;
                exit;
            end;
            if CheckifEOSrocessToday THEN //if already performed Cashier Reading
                  begin
                POSSESSION.clearManagerID();
                isHandled := true;
                exit;
            end;
            if ValidateAllowedFloatEntry THEN begin
                isHandled := true;
                exit;
            end;

            if POSMenuline.Command = 'ITEMNO' then begin
                if CurrInput = '' then begin
                    isHandled := true;
                    exit;
                end;
            end;
        end;

        APOnBeforeRunCommand(POSTransaction, POSTransLine, CurrInput, POSMenuLine, isHandled, TenderType, CusomterOrCardNo);
        if isHandled then
            exit;

        Case POSMenuline.Command OF
            'CANCEL2':
                POSSESSION.SetValue('TOTALPRESSED', '');
            'AP_CLEARMGR':
                POSSESSION.clearManagerID();
            'AP_FLOAT_ENT':
                begin
                    if (not CheckifEODProcessToday) or (not CheckifEOSrocessToday) THEN begin
                        POSMenuLine2.Reset();
                        POSMenuLine2.SetRange(Command, 'FLOAT_ENT');
                        if POSMenuLine2.FindFirst() then
                            codPOSTrans.RunCommand(POSMenuLine2);
                    end else begin
                        isHandled := true;
                        exit;
                    end;
                end;
            'AP_REM_TENDER':
                begin
                    if (not CheckifEODProcessToday) or (not CheckifEOSrocessToday) THEN begin
                        POSMenuLine2.Reset();
                        POSMenuLine2.SetRange(Command, 'REM_TENDER');
                        if POSMenuLine2.FindFirst() then
                            codPOSTrans.RunCommand(POSMenuLine2);
                    end else begin
                        isHandled := true;
                        exit;
                    end;
                end;
            'AP_TENDER_D':
                begin
                    if (not CheckifEODProcessToday) or (not CheckifEOSrocessToday) THEN begin
                        POSMenuLine2.Reset();
                        POSMenuLine2.SetRange(Command, 'TENDER_D');
                        if POSMenuLine2.FindFirst() then
                            codPOSTrans.RunCommand(POSMenuLine2);
                    end else begin
                        isHandled := true;
                        exit;
                    end;
                end;
            'AP_MGRREMOVE':
                POSSESSION.ClearManagerID();
            'VOID_TRNEW':
                begin
                    CurrGuest := POSMenuLine."Current-GUEST";
                end;
            'REG':
                begin
                    //VINCENT20251209 ERASE FIXED
                    POSDataTable.Reset();
                    POSDataTable.SetRange("Data Table ID", 'CUSTOMER');
                    POSDataTable.SetRange("Field No.", 50004);
                    IF POSDataTable.FindFirst() then begin
                        POSDataTable."Fixed Filter" := 'REGULAR';
                        POSDataTable.Modify();
                    end;
                    if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::"Regular Customer") then begin
                        if not ValidateDepositTrans(POSTransaction) then begin
                            if REGTransPressed2(POSTransaction) then begin
                                POSSESSION.SetValue('TRANS_CODE_TYPE', 'REG');
                                if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) or
                                    (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG) and
                                    (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                                    if ctrbegbal_booklet = 1 then begin
                                        Updatetranstype(POSTransaction);
                                        POSMenuLine2.Reset();
                                        POSMenuLine2.SetRange(Command, 'SELECTCUST');
                                        if POSMenuLine2.FindFirst() then
                                            codPOSTrans.RunCommand(POSMenuLine2);
                                    end;
                                end else begin
                                    codPOSTrans.PosErrorBanner('You cannot change trans type after total pressed');
                                end;
                            end;
                        end;
                        // end else begin
                        //     codPOSTrans.ErrorBeep('The transaction code type is already set to Regular Customer.');
                    end;
                END;
            'NORMAL_TR':
                begin
                    if not ValidateDepositTrans(POSTransaction) then
                        if REGTransPressed(POSTransaction) then begin
                            RemoveFreeTextforREG(POSTransaction);
                            // if POSTransLine.count > 0 then
                            //     codPOSTrans.TotalPressed(false);
                            codPOSTrans.CancelPressed(true, 0);
                            codPOSTrans.ClearPOSTransaction();
                        end;
                end;
            'SRC':
                begin
                    // if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::SRC) then begin
                    // if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) or
                    //         (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG) and
                    //         (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                    if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) and
                         (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin

                        if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG) and
                            (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::"SRC") then begin
                            userask := POSGUI.PosConfirm('Do you want to reset the transaction code type and customer to change to SRC', userask);
                        end;

                        if ((userask) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG)) or
                            ((userask = false) and (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG)) then
                            if not ValidateDepositTrans(POSTransaction) then begin
                                if REGTransPressed(POSTransaction) then begin
                                    SRCTransPressed(POSTransaction);
                                    UpdateFixedFilterForCustomer(Format(customer."Customer Type"::"SRC"));
                                    POSSESSION.SetValue('TRANS_CODE_TYPE', 'SRC');
                                    POSTransaction."Beginning Balance" := 0;
                                    POSTransaction."Booklet No." := '';
                                    if ctrbegbal_booklet = 1 then begin
                                        Updatetranstype(POSTransaction);
                                        POSMenuLine2.Reset();
                                        POSMenuLine2.SetRange(Command, 'SELECTCUST');
                                        if POSMenuLine2.FindFirst() then
                                            codPOSTrans.RunCommand(POSMenuLine2);
                                    end;
                                end;
                                APPOSSESSION.Reset();
                                if APPOSSESSION.FindFirst() then begin
                                    APPOSSESSION."Beg Bal" := false;
                                    APPOSSESSION.Modify();
                                end else begin
                                    APPOSSESSION.Init();
                                    APPOSSESSION."Beg Bal" := false;
                                    APPOSSESSION.Insert();
                                end;
                            end;
                    end else begin
                        codPOSTrans.PosErrorBanner('You cannot change trans type after total pressed');
                    end;
                    // end else begin
                    //     codPOSTrans.ErrorBeep('The transaction code type is already set to SRC.');
                    // end;
                end;
            'PWD':
                begin
                    // if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::PWD) then begin

                    // if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) or
                    //                (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG) and
                    //         //  (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                    //         (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                    if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) and
                          (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin

                        if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG) and
                                       (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::PWD) then begin
                            userask := POSGUI.PosConfirm('Do you want to reset the transaction code type and customer to change to PWD', userask);
                        end;
                        if ((userask) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG)) or ((userask = false) and (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG)) then
                            if not ValidateDepositTrans(POSTransaction) then begin
                                if REGTransPressed(POSTransaction) then begin
                                    PWDTransPressed(POSTransaction);
                                    UpdateFixedFilterForCustomer(Format(customer."Customer Type"::PWD));
                                    POSSESSION.SetValue('TRANS_CODE_TYPE', 'PWD');
                                    POSTransaction."Beginning Balance" := 0;
                                    POSTransaction."Booklet No." := '';
                                    if ctrbegbal_booklet = 1 then begin
                                        Updatetranstype(POSTransaction);
                                        POSMenuLine2.Reset();
                                        POSMenuLine2.SetRange(Command, 'SELECTCUST');
                                        if POSMenuLine2.FindFirst() then begin
                                            POSMenuLine2."Post Command" := 'FILTER';
                                            POSMenuLine2."Post Parameter" := 'PWD';
                                            codPOSTrans.RunCommand(POSMenuLine2);
                                        end;
                                    end;
                                end;
                                APPOSSESSION.Reset();
                                if APPOSSESSION.FindFirst() then begin
                                    APPOSSESSION."Beg Bal" := false;
                                    APPOSSESSION.Modify();
                                end else begin
                                    APPOSSESSION.Init();
                                    APPOSSESSION."Beg Bal" := false;
                                    APPOSSESSION.Insert();
                                end;
                            end;
                    end else begin
                        codPOSTrans.PosErrorBanner('You cannot change trans type after total pressed');
                    end;
                    // end else begin
                    //     codPOSTrans.ErrorBeep('The transaction code type is already set to PWD.');
                    // end;
                end;
            'SOLO':
                begin
                    // if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::SOLO) then begin
                    if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) and
                                         (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                        if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG) and
                                              (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::SOLO) then begin
                            userask := POSGUI.PosConfirm('Do you want to reset the transaction code type and customer to change to SOLO', userask);
                        end;

                        if ((userask) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG)) or ((userask = false) and (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG)) then
                            if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) or
                                (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG) and
                                (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                                if not ValidateDepositTrans(POSTransaction) then begin
                                    if REGTransPressed(POSTransaction) then begin
                                        SOLOTransPressed(POSTransaction);
                                        UpdateFixedFilterForCustomer(Format(customer."Customer Type"::"SOLO PARENT"));
                                        POSSESSION.SetValue('TRANS_CODE_TYPE', 'SOLO');
                                        if (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) then begin
                                            // Message('All Manual discount will be remove after changing transaction type');
                                            //ZeroOutDiscount(POSTransaction);
                                        end;
                                        if ctrbegbal_booklet = 1 then begin
                                            Updatetranstype(POSTransaction);
                                            POSMenuLine2.Reset();
                                            POSMenuLine2.SetRange(Command, 'SELECTCUST');
                                            if POSMenuLine2.FindFirst() then
                                                codPOSTrans.RunCommand(POSMenuLine2);
                                        end;
                                    end;
                                end;
                            end;
                    end else begin
                        codPOSTrans.PosErrorBanner('You cannot change trans type after total pressed');
                    end;


                    // end else begin
                    // codPOSTrans.ErrorBeep('The transaction code type is already set to SOLO.');
                    // end;
                end;
            'ONLINECUST':
                begin
                    // if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::ONLINE) then begin
                    // if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) or
                    //         (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG) and
                    //         (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                    if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) and
                             (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin

                        if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG) and
                            (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::ONLINE) then begin
                            userask := POSGUI.PosConfirm('Do you want to reset the transaction code type and customer to change to ONLINE', userask);
                        end;
                        if ((userask) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG)) or
                            ((userask = false) and (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG)) then
                            if not ValidateDepositTrans(POSTransaction) then begin
                                if REGTransPressed(POSTransaction) then begin
                                    OnlineTransPressed(POSTransaction);
                                    UpdateFixedFilterForCustomer(Format(customer."Customer Type"::"ONLINE CUSTOMER"));

                                    POSSESSION.SetValue('TRANS_CODE_TYPE', 'ONLINECUST');
                                    POSTransaction."Beginning Balance" := 0;
                                    POSTransaction."Booklet No." := '';
                                    if ctrbegbal_booklet = 1 then begin
                                        Updatetranstype(POSTransaction);
                                        POSMenuLine2.Reset();
                                        POSMenuLine2.SetRange(Command, 'SELECTCUST');
                                        if POSMenuLine2.FindFirst() then
                                            codPOSTrans.RunCommand(POSMenuLine2);
                                    end;
                                end;
                                APPOSSESSION.Reset();
                                if APPOSSESSION.FindFirst() then begin
                                    APPOSSESSION."Beg Bal" := false;
                                    APPOSSESSION.Modify();
                                end else begin
                                    APPOSSESSION.Init();
                                    APPOSSESSION."Beg Bal" := false;
                                    APPOSSESSION.Insert();
                                end;
                            end;
                    end else begin
                        codPOSTrans.PosErrorBanner('You cannot change trans type after total pressed');
                    end;
                    // end else begin
                    //     codPOSTrans.ErrorBeep('The transaction code type is already set to ONLINE.');
                    // end;
                end;
            'MOV':
                begin
                    // if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::MOV) then begin
                    // if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) or
                    //         (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG) and
                    //         (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                    if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) and
                         (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin

                        if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG) and
                            (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::MOV) then begin
                            userask := POSGUI.PosConfirm('Do you want to reset the transaction code type and customer to change to MOV', userask);
                        end;
                        if ((userask) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG)) or ((userask = false) and (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG)) then
                            if not ValidateDepositTrans(POSTransaction) then begin
                                if REGTransPressed(POSTransaction) then begin
                                    MOVTransPressed(POSTransaction);
                                    UpdateFixedFilterForCustomer(Format(customer."Customer Type"::MOV));
                                    POSSESSION.SetValue('TRANS_CODE_TYPE', 'MOV');
                                    if ctrbegbal_booklet = 1 then begin
                                        Updatetranstype(POSTransaction);
                                        POSMenuLine2.Reset();
                                        POSMenuLine2.SetRange(Command, 'SELECTCUST');
                                        if POSMenuLine2.FindFirst() then
                                            codPOSTrans.RunCommand(POSMenuLine2);
                                    end;
                                end;
                                APPOSSESSION.Reset();
                                if APPOSSESSION.FindFirst() then begin
                                    APPOSSESSION."Beg Bal" := false;
                                    APPOSSESSION.Modify();
                                end else begin
                                    APPOSSESSION.Init();
                                    APPOSSESSION."Beg Bal" := false;
                                    APPOSSESSION.Insert();
                                end;
                            end;
                    end else begin
                        codPOSTrans.PosErrorBanner('You cannot change trans type after total pressed');
                    end;
                    // end else begin
                    //     codPOSTrans.ErrorBeep('The transaction code type is already set to MOV.');
                    // end;
                end;
            'NAAC':
                begin
                    // if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::NAAC) then begin
                    // if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) or
                    //         (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG) and
                    //         (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                    if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                        if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG) and
                            (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::NAAC) then begin
                            userask := POSGUI.PosConfirm('Do you want to reset the transaction code type and customer to change to NAAC', userask);
                        end;
                        if ((userask) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG)) or ((userask = false) and (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG)) then
                            if not ValidateDepositTrans(POSTransaction) then begin
                                if REGTransPressed(POSTransaction) then begin
                                    NAACTransPressed(POSTransaction);
                                    UpdateFixedFilterForCustomer(Format(customer."Customer Type"::NAAC));
                                    POSSESSION.SetValue('TRANS_CODE_TYPE', 'NAAC');
                                    if ctrbegbal_booklet = 1 then begin
                                        Updatetranstype(POSTransaction);
                                        POSMenuLine2.Reset();
                                        POSMenuLine2.SetRange(Command, 'SELECTCUST');
                                        if POSMenuLine2.FindFirst() then
                                            codPOSTrans.RunCommand(POSMenuLine2);
                                    end;
                                end;
                                APPOSSESSION.Reset();
                                if APPOSSESSION.FindFirst() then begin
                                    APPOSSESSION."Beg Bal" := false;
                                    APPOSSESSION.Modify();
                                end else begin
                                    APPOSSESSION.Init();
                                    APPOSSESSION."Beg Bal" := false;
                                    APPOSSESSION.Insert();
                                end;
                            end;
                    end else begin
                        codPOSTrans.PosErrorBanner('You cannot change trans type after total pressed');
                    end;
                    // end else begin
                    //     codPOSTrans.ErrorBeep('The transaction code type is already set to NAAC.');
                    // end;
                end;
            'ATHL':
                begin
                    // if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::ATHL) then begin
                    // if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) or
                    //               (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG) and
                    //               (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                    if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                        if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG) and
                            (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::ATHL) then begin
                            userask := POSGUI.PosConfirm('Do you want to reset the transaction code type and customer to change to Athlete', userask);
                        end;
                        if ((userask) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG)) or ((userask = false) and (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG)) then
                            if not ValidateDepositTrans(POSTransaction) then begin
                                if REGTransPressed(POSTransaction) then begin
                                    ATHLTransPressed(POSTransaction);
                                    UpdateFixedFilterForCustomer(Format(customer."Customer Type"::ATHLETE));
                                    POSSESSION.SetValue('TRANS_CODE_TYPE', 'ATHL');
                                    if ctrbegbal_booklet = 1 then begin
                                        Updatetranstype(POSTransaction);
                                        POSMenuLine2.Reset();
                                        POSMenuLine2.SetRange(Command, 'SELECTCUST');
                                        if POSMenuLine2.FindFirst() then
                                            codPOSTrans.RunCommand(POSMenuLine2);
                                    end;
                                end;
                            end;
                    end else begin
                        codPOSTrans.PosErrorBanner('You cannot change trans type after total pressed');
                    end;
                    // end else begin
                    //     codPOSTrans.ErrorBeep('The transaction code type is already set to ATHL.');
                    // end;
                end;
            'WHT':
                begin
                    // if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::WHT1) then begin

                    // if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) or
                    //        (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG) and
                    //        (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                    if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                        if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::WHT1) then begin
                            userask := POSGUI.PosConfirm('Do you want to reset the transaction code type and customer to change to WHT', userask);
                        end;
                        if ((userask) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG)) or ((userask = false) and (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG)) then
                            if not ValidateDepositTrans(POSTransaction) then begin
                                if REGTransPressed(POSTransaction) then begin
                                    WHTTransPressed(POSTransaction);
                                    UpdateFixedFilterForCustomer(Format(customer."Customer Type"::"WITHHOLDING TAX"));
                                    POSSESSION.SetValue('TRANS_CODE_TYPE', 'WHT');
                                    if ctrbegbal_booklet = 1 then begin
                                        Updatetranstype(POSTransaction);
                                        POSMenuLine2.Reset();
                                        POSMenuLine2.SetRange(Command, 'SELECTCUST');
                                        if POSMenuLine2.FindFirst() then
                                            codPOSTrans.RunCommand(POSMenuLine2);
                                    end;
                                end;
                            end;
                    end else begin
                        codPOSTrans.PosErrorBanner('You cannot change trans type after total pressed');
                    end;
                    // end else begin
                    //     codPOSTrans.ErrorBeep('The transaction code type is already set to WHT.');
                    // end;
                end;
            'VATW':
                begin
                    // if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::VATW) then begin
                    // if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) or
                    //           (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG) and
                    //           (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                    if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) and
                        (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin

                        if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::VATW) then begin
                            userask := POSGUI.PosConfirm('Do you want to reset the transaction code type and customer to change to VATWHT', userask);
                        end;
                        if ((userask) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG)) or ((userask = false) and (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG)) then
                            if not ValidateDepositTrans(POSTransaction) then begin
                                if REGTransPressed(POSTransaction) then begin
                                    VATWHTTransPressed(POSTransaction);
                                    UpdateFixedFilterForCustomer(Format(customer."Customer Type"::VATW));
                                    POSSESSION.SetValue('TRANS_CODE_TYPE', 'VATW');
                                    if ctrbegbal_booklet = 1 then begin
                                        Updatetranstype(POSTransaction);
                                        POSMenuLine2.Reset();
                                        POSMenuLine2.SetRange(Command, 'SELECTCUST');
                                        if POSMenuLine2.FindFirst() then
                                            codPOSTrans.RunCommand(POSMenuLine2);
                                    end;
                                end;
                            end;
                    end else begin
                        codPOSTrans.PosErrorBanner('You cannot change trans type after total pressed');
                    end;
                    // end else begin
                    //     codPOSTrans.ErrorBeep('The transaction code type is already set to VATW.');
                    // end;
                end;
            'ZERO':
                begin
                    // if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::ZERO) then begin
                    // if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) or
                    //       (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG) and
                    //       (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                    if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                        if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::ZERO) then begin
                            userask := POSGUI.PosConfirm('Do you want to reset the transaction code type and customer to change to Zero rated', userask);
                        end;

                        if ((userask) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG)) or ((userask = false) and (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG)) then
                            if not ValidateDepositTrans(POSTransaction) then begin
                                if REGTransPressed(POSTransaction) then begin
                                    ZeroTransPressed(POSTransaction);
                                    UpdateFixedFilterForCustomer(Format(customer."Customer Type"::"ZERO RATED"));
                                    POSSESSION.SetValue('TRANS_CODE_TYPE', 'ZERO');
                                    if ctrbegbal_booklet = 1 then begin
                                        Updatetranstype(POSTransaction);
                                        POSMenuLine2.Reset();
                                        POSMenuLine2.SetRange(Command, 'SELECTCUST');
                                        if POSMenuLine2.FindFirst() then
                                            codPOSTrans.RunCommand(POSMenuLine2);
                                    end;
                                end;
                            end;
                    end else begin
                        codPOSTrans.PosErrorBanner('You cannot change trans type after total pressed');
                    end;
                    // end else begin
                    //     codPOSTrans.ErrorBeep('The transaction code type is already set to Zerorate.');
                    // end;
                end;
            'ZRWHT':
                begin
                    // if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::ZRWH) then begin
                    // if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) or
                    //            (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG) and
                    //            (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                    if (POSTransaction."Total Pressed" = false) or (POSTransaction."Line Discount" > 0) or (POSTransaction."Total Discount" > 0) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin

                        if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::ZRWH) then begin
                            userask := POSGUI.PosConfirm('Do you want to reset the transaction code type and customer to change to Zero rate WHT', userask);
                        end;
                        if ((userask) and (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::REG)) or ((userask = false) and (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::REG)) then
                            if not ValidateDepositTrans(POSTransaction) then begin
                                if REGTransPressed(POSTransaction) then begin
                                    ZRWHTTransPressed(POSTransaction);
                                    UpdateFixedFilterForCustomer(Format(customer."Customer Type"::ZRWHT));
                                    POSSESSION.SetValue('TRANS_CODE_TYPE', 'ZRWHT');
                                    if ctrbegbal_booklet = 1 then begin
                                        Updatetranstype(POSTransaction);
                                        POSMenuLine2.Reset();
                                        POSMenuLine2.SetRange(Command, 'SELECTCUST');
                                        if POSMenuLine2.FindFirst() then
                                            codPOSTrans.RunCommand(POSMenuLine2);
                                    end;
                                end;
                            end;
                    end else begin
                        codPOSTrans.PosErrorBanner('You cannot change trans type after total pressed');
                    end;
                    // end else begin
                    //     codPOSTrans.ErrorBeep('The transaction code type is already set to ZRWHT.');
                    // end;
                end;
            'BEGBALDISC':
                begin
                    APPOSSESSION.Reset();
                    if APPOSSESSION.FindFirst() then
                        if NOT APPOSSESSION."Beg Bal" then begin
                            APPOSSESSION.reset();
                            if APPOSSESSION.FindFirst() then begin
                                if POSTransaction."Customer No." <> '' then
                                    case APPOSSESSION."Transaction Code Type" of
                                        APPOSSESSION."Transaction Code Type"::SRC, APPOSSESSION."Transaction Code Type"::PWD:
                                            begin
                                                if (POSTransaction."Beginning Balance" = 0) then begin
                                                    customer.get(POSTransaction."Customer No.");
                                                    //VINCENT20251216 GETFIRST BEGBAL
                                                    BegBal := GetBegbal(Today, POSTransaction."Customer No.");
                                                    // customer.CalcFields("Beg Bal_");
                                                    //BegBal := customer."Beg Bal_";
                                                end;
                                                codPOSTrans.OpenNumericKeyboard('Beginning Balance', Format(0.00, 0, '<Sign><Integer Thousand><Decimal,3>'), 99);
                                            end;
                                    end;
                            end;
                        end;
                end;
            'BOOKLETNO':
                begin
                    APPOSSESSION.Reset();
                    if APPOSSESSION.FindFirst() then
                        if NOT APPOSSESSION."Beg Bal" then begin
                            APPOSSESSION.reset();
                            if APPOSSESSION.FindFirst() then begin
                                if POSTransaction."Customer No." <> '' then
                                    case APPOSSESSION."Transaction Code Type" of
                                        APPOSSESSION."Transaction Code Type"::SRC, APPOSSESSION."Transaction Code Type"::PWD:
                                            begin
                                                if (POSTransaction."Booklet No." = '') then begin
                                                    customer.get(POSTransaction."Customer No.");
                                                    // customer.CalcFields("Beg Bal_");
                                                    Booklet := ''; //VINCENT20251211
                                                end;
                                                codPOSTrans.OpenNumericKeyboard('Enter Booklet No.', Format(Booklet), 98);
                                            end;
                                    end;
                            end;
                        end;
                end;
            'TOTALNEW':
                begin
                    //codPOSTrans.SetPOSState('PAYMENT');
                    POSSESSION.SetValue('TOTALPRESSED', 'YES');
                    POSTransLine2.Reset();
                    POSTransLine2.SetRange("Receipt No.", POSTransaction."Receipt No.");
                    POSTransLine2.SetRange(POSTransLine2."Entry Status", POSTransLine2."Entry Status"::" ");
                    // POSTransLine2.SetFilter("Value[4]", '<>%1', '');.
                    POSTransLine2.SetFilter("Entry Type", '%1|%2', POSTransLine2."Entry Type"::IncomeExpense, POSTransLine2."Entry Type"::Item);
                    if POSTransLine2.FindFirst() then begin
                        codPOSTrans.CalcTotals();
                        //CalcTotals(POSTransaction);
                        case POSTransaction."Transaction Code Type" OF
                            POSTransaction."Transaction Code Type"::REG, POSTransaction."Transaction Code Type"::MRS, POSTransaction."Transaction Code Type"::DEPOSIT, POSTransaction."Transaction Code Type"::"DEPOSIT REDEEM":
                                begin
                                    codPOSTrans.TotalPressed(false);
                                    POSTransaction."Total Pressed" := true;
                                    POSTransaction.modify;
                                end;

                            POSTransaction."Transaction Code Type"::"SRC", POSTransaction."Transaction Code Type"::PWD, POSTransaction."Transaction Code Type"::SOLO,
                            POSTransaction."Transaction Code Type"::ZERO, POSTransaction."Transaction Code Type"::ZRWH, POSTransaction."Transaction Code Type"::ATHL,
                            POSTransaction."Transaction Code Type"::WHT1, POSTransaction."Transaction Code Type"::VATW, POSTransaction."Transaction Code Type"::"Regular Customer",
                            POSTransaction."Transaction Code Type"::MOV, POSTransaction."Transaction Code Type"::NAAC, POSTransaction."Transaction Code Type"::ONLINE:
                                begin
                                    if POSTransaction."Customer No." = '' then begin
                                        codPOSTrans.PosErrorBanner('Please select Customer first.');
                                        codPOSTrans.SelectDefaultMenu();
                                        exit;
                                    end else
                                        if Validatecustomer(POSTransaction) then begin
                                            codPOSTrans.SelectDefaultMenu();
                                            exit;
                                        end;

                                    case POSTransaction."Transaction Code Type" of
                                        POSTransaction."Transaction Code Type"::"SRC", POSTransaction."Transaction Code Type"::PWD, POSTransaction."Transaction Code Type"::ONLINE, POSTransaction."Transaction Code Type"::SOLO, POSTransaction."Transaction Code Type"::ATHL, POSTransaction."Transaction Code Type"::MOV, POSTransaction."Transaction Code Type"::NAAC:
                                            begin
                                                POSAddFunc.VATExemptPressed(POSTransaction."Receipt No.", POSTransaction);
                                            end;
                                    end;

                                    case POSTransaction."Transaction Code Type" OF

                                        POSTransaction."Transaction Code Type"::ONLINE:
                                            begin
                                                codPOSTrans.TotalPressed(false);
                                            end;
                                        POSTransaction."Transaction Code Type"::"SRC":
                                            begin
                                                if (GetSRCDiscount(POSTransaction, POSTransLine) = 0) then begin
                                                    ValidateDiscountCode(POSTransaction, POSTransLine, CurrInput, '');
                                                    VATExemptPressedFood(POSTransaction."Receipt No.");
                                                    codPOSTrans.TotalPressed(false);
                                                end else
                                                    codPOSTrans.TotalPressed(false);
                                            end;

                                        POSTransaction."Transaction Code Type"::PWD:
                                            begin
                                                if (GetPWDDiscount(POSTransaction, POSTransLine) = 0) then begin
                                                    ValidateDiscountCode(POSTransaction, POSTransLine, CurrInput, '');
                                                    VATExemptPressedFood(POSTransaction."Receipt No.");
                                                    codPOSTrans.TotalPressed(false);
                                                end else
                                                    codPOSTrans.TotalPressed(false);
                                            end;

                                        POSTransaction."Transaction Code Type"::SOLO:
                                            begin
                                                if (GetSOLODiscount(POSTransaction, POSTransLine) = 0) then begin
                                                    ValidateDiscountCode(POSTransaction, POSTransLine, CurrInput, '');
                                                    VATExemptPressedSOLO(POSTransaction."Receipt No.");
                                                    codPOSTrans.TotalPressed(false);
                                                end else
                                                    codPOSTrans.TotalPressed(false);
                                            end;

                                        POSTransaction."Transaction Code Type"::WHT1:
                                            begin
                                                ValidateDiscountCode(POSTransaction, POSTransLine, CurrInput, '27');
                                                codPOSTrans.TotalPressed(false);
                                            end;

                                        POSTransaction."Transaction Code Type"::VATW:
                                            begin
                                                ValidateDiscountCode(POSTransaction, POSTransLine, CurrInput, '28');
                                                codPOSTrans.TotalPressed(false);
                                            end;

                                        POSTransaction."Transaction Code Type"::ZERO:
                                            begin
                                                POSAddFunc.ZeroRatedPressed(POSTransaction."Receipt No.");
                                                ZeroPressed(POSTransaction);

                                                ValidateDiscountCode(POSTransaction, POSTransLine, CurrInput, '31');
                                                codPOSTrans.TotalPressed(false);
                                            end;
                                        POSTransaction."Transaction Code Type"::ZRWH:
                                            begin
                                                POSAddFunc.ZeroRatedPressed(POSTransaction."Receipt No.");
                                                ZeroPressed(POSTransaction);
                                                ValidateDiscountCode(POSTransaction, POSTransLine, CurrInput, '30');
                                                codPOSTrans.TotalPressed(false);
                                            end;
                                        POSTransaction."Transaction Code Type"::ATHL:
                                            begin
                                                if (GetATHLDiscount(POSTransaction, POSTransLine) = 0) then begin
                                                    ValidateDiscountCode(POSTransaction, POSTransLine, CurrInput, '');
                                                    codPOSTrans.TotalPressed(false);
                                                end else
                                                    codPOSTrans.TotalPressed(false);
                                            end;
                                        POSTransaction."Transaction Code Type"::MOV:
                                            begin
                                                if (GetMOVDiscount(POSTransaction, POSTransLine) = 0) then begin
                                                    ValidateDiscountCode(POSTransaction, POSTransLine, CurrInput, '');
                                                    // VATExemptPressedMOV(POSTransaction."Receipt No.");
                                                    codPOSTrans.TotalPressed(false);
                                                end else
                                                    codPOSTrans.TotalPressed(false);
                                            end;
                                        POSTransaction."Transaction Code Type"::NAAC:
                                            begin
                                                if (GetNAACDiscount(POSTransaction, POSTransLine) = 0) then begin
                                                    ValidateDiscountCode(POSTransaction, POSTransLine, CurrInput, '');
                                                    // VATExemptPressedNAAC(POSTransaction."Receipt No.");
                                                    codPOSTrans.TotalPressed(false);
                                                end else
                                                    codPOSTrans.TotalPressed(false);
                                            end;
                                        POSTransaction."Transaction Code Type"::"Regular Customer":
                                            codPOSTrans.TotalPressed(false);

                                    end;
                                    POSTransaction."Total Pressed" := true;
                                    POSTransaction.modify;
                                end;
                        end;
                    end else
                        codPOSTrans.PosMessageBanner('No Item to total.');
                    OnAfterTotalCommand(POSTransaction, POSTransLine, CurrInput, POSMenuLine);
                end;
            'VATEXEMPT':
                begin
                    POSAddFunc.VATExemptPressed(POSTransaction."Receipt No.", POSTransaction);
                end;
            'REPRINTZ':
                begin
                    ReprintZReport(CurrInput);
                    POSSESSION.ClearManagerID();
                end;
            'VOID_NEW':
                begin
                    POSTransLine2.Reset();
                    POSTransLine2.SetRange("Receipt No.", POSTransaction."Receipt No.");
                    POSTransLine2.SetRange("Entry Type", POSTransLine2."Entry Type"::Item);
                    if POSTransLine2.FindFirst() then begin
                        if GetOpenEOD THEN   // Check if previous day is not yet perform eod
                            EXIT;
                        if CheckifEODProcessToday THEN //if already performed EOD
                            EXIT;
                        if CheckifEOSrocessToday THEN //if already performed Cashier Reading
                            EXIT;
                        if ValidateAllowedFloatEntry THEN
                            EXIT;
                        codPOSTrans.VoidPressed();
                    end else begin
                        codPOSTrans.ErrorBeep('No transaction to Void');
                        POSSESSION.ClearManagerID();
                    end;
                end;
            'AP_CARD':
                begin
                    POSTransaction.CalcFields("Gross Amount", Payment);
                    if POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::DEPOSIT then begin
                        codPOSTrans.OpenNumericKeyboard('Amount', POSFunctions.FormatAmount(POSTransaction."Income/Exp. Amount"), 82)
                    end else
                        codPOSTrans.OpenNumericKeyboard('Amount', POSFunctions.FormatAmount(POSTransaction."Gross Amount" - POSTransaction.Payment), 82);
                    APPOSSESSION.Reset();
                    if APPOSSESSION.FindFirst() then begin
                        APPOSSESSION."POST COMMAND" := POSMenuLine."Post Command";
                        APPOSSESSION."POST PARAMETER" := POSMenuLine."Post Parameter";
                        APPOSSESSION."Card type Param" := POSMenuLine.Parameter;
                        APPOSSESSION.Modify();
                    end else begin
                        APPOSSESSION.Init();
                        APPOSSESSION."POST COMMAND" := POSMenuLine."Post Command";
                        APPOSSESSION."POST PARAMETER" := POSMenuLine."Post Parameter";
                        APPOSSESSION."Card type Param" := POSMenuLine.Parameter;
                        APPOSSESSION.Insert();
                    end;
                end;
            'AP_GIFTCARD':
                begin
                    codPOSTrans.OpenNumericKeyboard('Gift Card No.', '', 70);
                end;
            'AP_CHECK':
                begin
                    codPOSTrans.OpenNumericKeyboard('Check No.', '', 60);
                end;
            'AP_VOID_TR':
                begin
                    if GetOpenEOD THEN   // Check if previous day is not yet perform eod
                        EXIT;
                    if CheckifEODProcessToday THEN //if already performed EOD
                        EXIT;
                    if CheckifEOSrocessToday THEN //if already performed Cashier Reading
                        EXIT;
                    if ValidateAllowedFloatEntry THEN
                        EXIT;
                    VoidTransaction(POSTransaction, 1);
                end;
            'CHECKTRANS':
                begin
                    if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
                        if POSTransaction."Customer No." = '' then begin
                            POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::REG;
                            POSTransaction."Sale Is Return Sale" := false;
                            //if recLPOSTrans.Modify() then;
                        end;

                    end;
                    case POSTransaction."Transaction Code Type" of
                        POSTransaction."Transaction Code Type"::"SRC", POSTransaction."Transaction Code Type"::PWD:
                            begin
                                if (POSTransaction."Beginning Balance" <= 0) and (POSTransaction."Booklet No." = '') then begin
                                    POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::REG;
                                    POSTransaction."Sale Is Return Sale" := false;
                                    POSTransaction."Customer No." := '';
                                end;
                            end;
                    end;
                    if POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::DEPOSIT then begin
                        //Message('2: %1', POSTransaction."Transaction Code Type");
                        RecLTransLine.Reset();
                        RecLTransLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
                        RecLTransLine.SetRange("Entry Type", RecLTransLine."Entry Type"::IncomeExpense);
                        if not RecLTransLine.FindFirst() then begin
                            POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::REG;
                            POSTransaction."Sale Is Return Sale" := false;
                            POSTransaction."Customer No." := '';
                            POSTransaction.Modify();
                        end;
                    end;
                    POSSESSION.clearManagerID();
                end;
            'AP_PRINT_Z':
                begin
                    if not Checkifwithsuspendtrans(POSSESSION.StoreNo()) then begin
                        codPOSTrans.PosErrorBanner('You are not allowed to print Z reading if with suspended transaction');
                        codPOSTrans.CancelPressed(true, 0);
                        POSSESSION.clearManagerID();
                        EXIT;
                    end;

                    if not CheckifwithTransLine(POSSESSION.StoreNo()) then begin
                        codPOSTrans.PosErrorBanner('Current Transaction must be finished.');
                        codPOSTrans.CancelPressed(true, 0);
                        POSSESSION.clearManagerID();
                        EXIT;
                    end;

                    POSMenuLine2.Reset();
                    POSMenuLine2.SetRange(Command, 'PRINT_Z');
                    if POSMenuLine2.FindFirst() then
                        codPOSTrans.RunCommand(POSMenuLine2);

                    POSSESSION.clearManagerID();
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeExitWhenResultNotOk', '', false, false)]
    local procedure OnBeforeExitWhenResultNotOk(var ResultOK: Boolean; var KeyboardTriggerToProcess: Integer; var IsHandled: Boolean; var Rec: Record "LSC POS Transaction")
    var
        TransCodeType: Code[20];
        customer: Record Customer;
    begin
        if (KeyboardTriggerToProcess = 99) or (KeyboardTriggerToProcess = 98) then begin
            if not ResultOK then begin

                if KeyboardTriggerToProcess = 99 then begin
                    codPOSTrans.PosErrorBanner('The Beginning Balance is required.');
                    customer.get(Rec."Customer No.");
                    // customer.CalcFields("Beg Bal_");
                    codPOSTrans.OpenNumericKeyboard('Beginning Balance', format(0.00, 0, '<Sign><Integer Thousand><Decimal,3>'), 99);
                end;
                if KeyboardTriggerToProcess = 98 then begin
                    codPOSTrans.PosErrorBanner('The booklet no. is required.');
                    codPOSTrans.OpenNumericKeyboard('Enter Booklet No.', '', 98);
                end;

            end;

        end;
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", 'OnAfterKeyboardTriggerToProcess', '', true, true)]
    local procedure OnKeyboard(var IsHandled: Boolean; InputValue: Text; var Rec: Record "LSC POS Transaction"; KeyboardTriggerToProcess: Integer)
    var
        //VINCENT20251216
        recPOSHardware: Record "LSC POS Hardware Profile";
        recEligibilityLedger: Record DiscountEligibilityLedger;

        // Dialogs and UI
        Dialog: Dialog;
        ProgressText: Text;
        Confirmed: Boolean;

        // Records
        LSCPOSFunction: Record "LSC POS Func. Profile";
        LStoreSetup: Record "LSC Store";
        POSMenuLine: Record "LSC POS Menu Line";
        POSMenuLine2: Record "LSC POS Menu Line";
        POSTransLine: Record "LSC POS Trans. Line";
        TenderTypeCardSetup: Record "LSC Tender Type Card Setup";
        Customer: Record Customer;

        // Amounts and Financials
        BegBalAmount: Decimal;
        CardTenderAmount: Decimal;
        TotalAmount: Decimal;
        CurBalance: Decimal;

        // Credit Card Info
        CreditCardNumber: BigInteger;
        ValidateCreditCardNumber: Code[20];
        CreditCardName: Code[20];
        "Card type Param", Input : Code[20];

        // Counters and Retry Logic
        TotalCount: Integer;
        CurrentCount: Integer;
        MaxAttempts: Integer;
        RetryCount: Integer;
        MaxRetries: Integer;

        // Flags
        TXTBOOL: Boolean;
        IsHandled_: Boolean;

    begin

        LStoreSetup.GET(POSSESSION.StoreNo);
        if not LSCPOSFunction.GET(POSSESSION.GetValue('LSFUNCPROFILE')) then
            LSCPOSFunction.GET(LStoreSetup."Functionality Profile");

        if KeyboardTriggerToProcess = 98 then begin
            IsHandled := true;
            if InputValue <> '' then begin
                if CheckSpecialChars(InputValue) then begin
                    codPOSTrans.PosErrorBanner(SpecialCharsErr);
                    codPOSTrans.CancelPressed(false, 0);
                    codPOSTrans.OpenNumericKeyboard('Enter Booklet No.', '', 98);
                end else begin
                    Rec."Booklet No." := InputValue;
                    Rec.Modify();
                    APPOSSESSION.Reset();
                    if APPOSSESSION.FindFirst() then begin
                        APPOSSESSION."Beg Bal" := true;
                        APPOSSESSION.Modify();
                    end else begin
                        APPOSSESSION.Init();
                        APPOSSESSION."Beg Bal" := true;
                        APPOSSESSION.Insert();
                    end;
                    Commit();
                end;
            end else begin
                codPOSTrans.PosErrorBanner('The booklet no. is required');
                codPOSTrans.OpenNumericKeyboard('Enter Booklet No.', '', 98);
            end;

        end;

        if KeyboardTriggerToProcess = 99 then begin
            IsHandled := true;
            if InputValue <> '' then begin
                if evaluate(begbalAmount, InputValue) then begin
                    if CheckSpecialChars(InputValue) then begin
                        codPOSTrans.PosErrorBanner(SpecialCharsErr);
                        // codPOSTrans.CancelPressed(false, 0);
                        //VINCENT20251216 BEGBAL
                        BegBalAmount := GetBegbal(Today, rec."Customer No.");

                        //customer.get(Rec."Customer No.");
                        // customer.CalcFields("Beg Bal_");
                        codPOSTrans.OpenNumericKeyboard('Beginning Balance', format(0.00, 0, '<Sign><Integer Thousand><Decimal,3>'), 99);
                    end else begin
                        //customer.get(Rec."Customer No.");
                        //customer.CalcFields("Beg Bal_");
                        BegBalAmount := GetBegbal(Today, rec."Customer No.");
                        codPOSTrans.SetCurrInput(InputValue);
                        ValidateBalance(Rec, InputValue, BegBalAmount);
                    end;
                end else begin
                    codPOSTrans.PosErrorBanner('Invalid Amount');
                    codPOSTrans.CancelPressed(false, 0);
                    BegBalAmount := GetBegbal(Today, rec."Customer No.");
                    //customer.get(Rec."Customer No.");
                    // customer.CalcFields("Beg Bal_");
                    codPOSTrans.OpenNumericKeyboard('Beginning Balance', format(0.00, 0, '<Sign><Integer Thousand><Decimal,3>'), 99);
                end;
            end else begin
                codPOSTrans.PosErrorBanner('The beginning balance must not be blank.');
                //codPOSTrans.CancelPressed(false, 0);
                BegBalAmount := GetBegbal(Today, rec."Customer No.");
                //customer.get(Rec."Customer No.");
                // customer.CalcFields("Beg Bal_");
                codPOSTrans.OpenNumericKeyboard('Beginning Balance', format(0.00, 0, '<Sign><Integer Thousand><Decimal,3>'), 99);

            end;
        end;

        if KeyboardTriggerToProcess = 80 then begin

            IsHandled := true;
            if CopyStr(InputValue, 1, 1) = '%' then
                ValidateCreditCardNumber := CopyStr(InputValue, 3, 16)
            else
                ValidateCreditCardNumber := CopyStr(InputValue, 1, 16);

            if not Evaluate(CreditCardNumber, ValidateCreditCardNumber) then begin
                codPOSTrans.PosErrorBanner('The Card no. cannot be blank!');
                codPOSTrans.CancelPressed(false, 0);
                codPOSTrans.SetPOSState('PAYMENT');
                codPOSTrans.SetFunctionMode('PAYMENT');
                codPOSTrans.OpenNumericKeyboard('Card no.', '', 80);
            end
            else begin
                if InputValue <> '' then begin
                    Rec."AP Credit Card Number" := ValidateCreditCardNumber;
                    Rec."AP Card Name" := CopyStr(InputValue, 20, 26);
                    Rec.Modify();

                    if Rec."AP Card Name" <> '' then begin
                        askuser2 := codPOSTrans.PosConfirm(StrSubstNo('Card Validation \ \ Card No. %1 \ Card Holder Name: %2', Rec."AP Credit Card Number", Rec."AP Card Name"), askuser2);
                        if not askuser2 then
                            askuser := codPOSTrans.PosConfirm(StrSubstNo('Card Validation \ \ Card No. %1 \ Card Holder Name: %2', Rec."AP Credit Card Number", Rec."AP Card Name"), askuser);

                        if askuser then begin
                            APPOSSESSION.Reset();//ditoo
                            IF APPOSSESSION.FindFirst() then begin
                                IF APPOSSESSION."Card type Param" <> '' THEN BEGIN
                                    TenderTypeCardSetup.Reset();
                                    TenderTypeCardSetup.SetRange("Card No.", APPOSSESSION."Card type Param");
                                    if TenderTypeCardSetup.findfirst() then begin
                                        if TenderTypeCardSetup."E-Wallet" then
                                            codPOSTrans.OpenNumericKeyboard('Reference No.', '', 81)
                                        else
                                            codPOSTrans.OpenNumericKeyboard('Approval Code', '', 81);
                                    end;
                                end else
                                    codPOSTrans.OpenNumericKeyboard('Approval Code', '', 81);
                            end;
                        end else begin
                            codPOSTrans.CancelPressed(false, 0);
                            codPOSTrans.SetPOSState('PAYMENT');
                            codPOSTrans.SetFunctionMode('PAYMENT');
                            codPOSTrans.OpenNumericKeyboard('Card no.', '', 80);
                        end;
                    end else
                        POSGUI.OpenAlphabeticKeyboard('Card Holder Name', '', false, '#CardHolName' + Rec."Receipt No.", 100);

                    //codPOSTrans.OpenNumericKeyboard('Card Holder Name', '', 84);

                end else begin
                    codPOSTrans.PosErrorBanner('The card no. cannot be blank!');
                    codPOSTrans.CancelPressed(false, 0);
                    codPOSTrans.SetPOSState('PAYMENT');
                    codPOSTrans.SetFunctionMode('PAYMENT');
                    codPOSTrans.OpenNumericKeyboard('Card no.', '', 80);
                end;
            end;
        end;

        if KeyboardTriggerToProcess = 81 then begin
            IsHandled := true;
            if CheckSpecialCharsExtended(InputValue) then begin

                APPOSSESSION.Reset();
                IF APPOSSESSION.FindFirst() then begin
                    Rec."AP Card Name" := APPOSSESSION."AP Card Name";
                    Rec.Modify();
                    IF APPOSSESSION."Card type Param" <> '' THEN BEGIN
                        TenderTypeCardSetup.Reset();
                        TenderTypeCardSetup.SetRange("Card No.", APPOSSESSION."Card type Param");
                        if TenderTypeCardSetup.findfirst() then begin
                            if TenderTypeCardSetup."E-Wallet" then
                                codPOSTrans.PosErrorBanner('Invalid reference no.')
                            else
                                codPOSTrans.PosErrorBanner('Invalid approval code.');
                        end;
                    end;
                end;
                codPOSTrans.CancelPressed(false, 0);
                codPOSTrans.SetPOSState('PAYMENT');
                codPOSTrans.SetFunctionMode('PAYMENT');
                //codPOSTrans.OpenNumericKeyboard('Approval Code', '', 81);
                APPOSSESSION.Reset();
                IF APPOSSESSION.FindFirst() then begin
                    Rec."AP Card Name" := APPOSSESSION."AP Card Name";
                    Rec.Modify();
                    IF APPOSSESSION."Card type Param" <> '' THEN BEGIN
                        TenderTypeCardSetup.Reset();
                        TenderTypeCardSetup.SetRange("Card No.", APPOSSESSION."Card type Param");
                        if TenderTypeCardSetup.findfirst() then begin
                            if TenderTypeCardSetup."E-Wallet" then
                                codPOSTrans.OpenNumericKeyboard('Reference No.', '', 81)
                            else
                                codPOSTrans.OpenNumericKeyboard('Approval Code', '', 81);
                        end;
                    end else
                        codPOSTrans.OpenNumericKeyboard('Approval Code', '', 81);
                end;
            end
            else begin
                if InputValue <> '' then begin
                    if StrLen(InputValue) <= 20 then begin
                        Rec."AP Approval Code" := InputValue;
                        Rec.Modify();
                        codPOSTrans.SetPOSState('PAYMENT');
                        codPOSTrans.SetFunctionMode('PAYMENT');
                        APPOSSESSION.Reset();
                        if APPOSSESSION.FindFirst() then begin
                            Rec."AP Card Name" := APPOSSESSION."AP Card Name";
                            Rec.Modify();
                            POSMenuLine2.Reset();
                            POSMenuLine2.SetRange(Command, 'TENDER_K');
                            if POSMenuLine2.FindFirst() then begin
                                POSMenuLine2.Parameter := '3';
                                codPOSTrans.RunCommand(POSMenuLine2);
                            end;
                        end;
                    end else begin
                        APPOSSESSION.Reset();
                        IF APPOSSESSION.FindFirst() then begin
                            Rec."AP Card Name" := APPOSSESSION."AP Card Name";
                            Rec.Modify();
                            IF APPOSSESSION."Card type Param" <> '' THEN BEGIN
                                TenderTypeCardSetup.Reset();
                                TenderTypeCardSetup.SetRange("Card No.", APPOSSESSION."Card type Param");
                                if TenderTypeCardSetup.findfirst() then begin
                                    if TenderTypeCardSetup."E-Wallet" then
                                        codPOSTrans.PosErrorBanner('The reference no. cannot be more than 20 characters!')
                                    else
                                        codPOSTrans.PosErrorBanner('The approval code cannot be more than 20 characters!');
                                end;
                            end;
                        end;
                        codPOSTrans.CancelPressed(false, 0);
                        codPOSTrans.SetPOSState('PAYMENT');
                        codPOSTrans.SetFunctionMode('PAYMENT');
                        //codPOSTrans.OpenNumericKeyboard('Approval code', '', 81);
                        APPOSSESSION.Reset();
                        IF APPOSSESSION.FindFirst() then begin
                            Rec."AP Card Name" := APPOSSESSION."AP Card Name";
                            Rec.Modify();
                            IF APPOSSESSION."Card type Param" <> '' THEN BEGIN
                                TenderTypeCardSetup.Reset();
                                TenderTypeCardSetup.SetRange("Card No.", APPOSSESSION."Card type Param");
                                if TenderTypeCardSetup.findfirst() then begin
                                    if TenderTypeCardSetup."E-Wallet" then
                                        codPOSTrans.OpenNumericKeyboard('Reference No.', '', 81)
                                    else
                                        codPOSTrans.OpenNumericKeyboard('Approval Code', '', 81);
                                end;
                            end else
                                codPOSTrans.OpenNumericKeyboard('Approval Code', '', 81);
                        end;
                    end;
                end else begin
                    APPOSSESSION.Reset();
                    IF APPOSSESSION.FindFirst() then begin
                        Rec."AP Card Name" := APPOSSESSION."AP Card Name";
                        Rec.Modify();
                        IF APPOSSESSION."Card type Param" <> '' THEN BEGIN
                            TenderTypeCardSetup.Reset();
                            TenderTypeCardSetup.SetRange("Card No.", APPOSSESSION."Card type Param");
                            if TenderTypeCardSetup.findfirst() then begin
                                if TenderTypeCardSetup."E-Wallet" then
                                    codPOSTrans.PosErrorBanner('The reference no. cannot be blank!')
                                else
                                    codPOSTrans.PosErrorBanner('The approval code cannot be blank!');
                            end;
                        end;
                    end;
                    codPOSTrans.CancelPressed(false, 0);
                    codPOSTrans.SetPOSState('PAYMENT');
                    codPOSTrans.SetFunctionMode('PAYMENT');
                    //codPOSTrans.OpenNumericKeyboard('Approval code', '', 81);
                    APPOSSESSION.Reset();
                    IF APPOSSESSION.FindFirst() then begin
                        Rec."AP Card Name" := APPOSSESSION."AP Card Name";
                        Rec.Modify();
                        IF APPOSSESSION."Card type Param" <> '' THEN BEGIN
                            TenderTypeCardSetup.Reset();
                            TenderTypeCardSetup.SetRange("Card No.", APPOSSESSION."Card type Param");
                            if TenderTypeCardSetup.findfirst() then begin
                                if TenderTypeCardSetup."E-Wallet" then
                                    codPOSTrans.OpenNumericKeyboard('Reference No.', '', 81)
                                else
                                    codPOSTrans.OpenNumericKeyboard('Approval Code', '', 81);
                            end;
                        end else
                            codPOSTrans.OpenNumericKeyboard('Approval Code', '', 81);
                    end;
                end;
            end;
        end;

        if KeyboardTriggerToProcess = 82 then begin
            IsHandled := true;
            if InputValue <> '' then begin
                if Evaluate(CardTenderAmount, InputValue) then begin
                    if not CheckSpecialChars(InputValue) then begin
                        APEventSubscriber.OnArchiveGHL(IsHandled_);
                        TotalAmount := 0;
                        Rec.CalcFields("Gross Amount", Payment);
                        if Rec."Transaction Code Type" = Rec."Transaction Code Type"::DEPOSIT then begin
                            TotalAmount := Rec."Income/Exp. Amount";
                        end else begin
                            TotalAmount := Rec."Gross Amount" - Rec.Payment
                        end;

                        if (CardTenderAmount > (TotalAmount)) then begin
                            codPOSTrans.PosErrorBanner('Over tender is not allowed in card payment');
                            codPOSTrans.CancelPressed(true, 0);
                            codPOSTrans.SetPOSState('PAYMENT');
                            codPOSTrans.SetFunctionMode('PAYMENT');
                            //codPOSTrans.OpenNumericKeyboard('Amount', '', 82);
                        end else begin
                            codPOSTrans.SetPOSState('PAYMENT');
                            codPOSTrans.SetFunctionMode('PAYMENT');
                            IF CardTenderAmount > 0 THEN begin
                                APPOSSESSION.Reset();
                                IF APPOSSESSION.FindFirst() then begin
                                    IF APPOSSESSION."Card type Param" <> '' THEN BEGIN
                                        Evaluate(APPOSSESSION."Card Tender Amount", InputValue);
                                        "Card type Param" := APPOSSESSION."Card type Param";
                                        APPOSSESSION.Modify();
                                    end;

                                    TenderTypeCardSetup.Reset();
                                    TenderTypeCardSetup.SetRange("Card No.", "Card type Param");
                                    if TenderTypeCardSetup.findfirst() then
                                        if TenderTypeCardSetup."Enable GHL" then begin

                                            APEventSubscriber.OnGHLCall(Rec."Receipt No.", Rec."POS Terminal No.", Rec."Staff ID", CardTenderAmount, "Card type Param");
                                            //  Confirmed := POSGUI.PosConfirm('Processing to GHL in progress. Once completed, please click ‘YES’ to confirm.', true);

                                            // repeat
                                            //     Confirmed := POSGUI.PosConfirm('Processing to GHL in progress. Once completed, please click YES to confirm.', false);
                                            // until Confirmed;

                                            // if not Confirmed then begin
                                            //     APEventSubscriber.OnArchiveGHL(IsHandled_);
                                            //     exit;
                                            // end;

                                            APEventSubscriber.OnProcessGHL(IsHandled_, Rec);


                                        end else begin
                                            TenderTypeCardSetup.Reset();
                                            TenderTypeCardSetup.SetRange("Card No.", APPOSSESSION."Card type Param");
                                            if TenderTypeCardSetup.findfirst() then begin
                                                if TenderTypeCardSetup."E-Wallet" then
                                                    codPOSTrans.OpenNumericKeyboard('Reference No.', '', 81)
                                                else
                                                    codPOSTrans.OpenNumericKeyboard('Card No.', '', 80);
                                            end else
                                                codPOSTrans.OpenNumericKeyboard('Card No.', '', 80);
                                        end;


                                    // end else
                                    //     codPOSTrans.OpenNumericKeyboard('Card No.', '', 80);
                                end;
                            end ELSE begin
                                codPOSTrans.PosErrorBanner('The amount must be greater than zero');
                                codPOSTrans.CancelPressed(false, 0);
                                codPOSTrans.SetPOSState('PAYMENT');
                                codPOSTrans.SetFunctionMode('PAYMENT');
                                // codPOSTrans.OpenNumericKeyboard('Amount', '', 82);
                            end;
                        end;

                    end else begin
                        codPOSTrans.PosErrorBanner('Invalid Amount');
                        codPOSTrans.CancelPressed(false, 0);
                        codPOSTrans.SetPOSState('PAYMENT');
                        codPOSTrans.SetFunctionMode('PAYMENT');
                        // codPOSTrans.OpenNumericKeyboard('Amount', '', 82);
                    end;
                end else begin
                    codPOSTrans.PosErrorBanner('Invalid Amount');
                    codPOSTrans.CancelPressed(false, 0);
                    codPOSTrans.SetPOSState('PAYMENT');
                    codPOSTrans.SetFunctionMode('PAYMENT');
                    // codPOSTrans.OpenNumericKeyboard('Amount', '', 82);
                end;
            end else begin
                codPOSTrans.PosErrorBanner('Please input a valid amount before proceeding.');
                codPOSTrans.CancelPressed(false, 0);
                codPOSTrans.SetPOSState('PAYMENT');
                codPOSTrans.SetFunctionMode('PAYMENT');
                //codPOSTrans.OpenNumericKeyboard('Amount', '', 82);
            end;
            APEventSubscriber.OnArchiveGHL(IsHandled_);
        end;
        if KeyboardTriggerToProcess = 83 then begin

        end;

        if KeyboardTriggerToProcess = 70 then begin
            IsHandled := true;
            if InputValue = '' then begin
                codPOSTrans.PosErrorBanner('The gift card no. cannot be blank!');
                codPOSTrans.CancelPressed(false, 0);
                codPOSTrans.OpenNumericKeyboard('Gift card no.', '', 70);
                codPOSTrans.SetPOSState('PAYMENT');
                codPOSTrans.SetFunctionMode('PAYMENT');
                codPOSTrans.TotalPressed(false);
            end else begin
                if Evaluate(CreditCardNumber, CopyStr(InputValue, 1, 20)) then begin
                    if CheckSpecialChars(InputValue) then begin
                        codPOSTrans.PosErrorBanner(SpecialCharsErr);
                        codPOSTrans.CancelPressed(false, 0);
                        codPOSTrans.SetPOSState('PAYMENT');
                        codPOSTrans.SetFunctionMode('PAYMENT');
                        codPOSTrans.OpenNumericKeyboard('Gift card no.', '', 70);

                    end else begin
                        Rec."AP Credit Card Number" := CopyStr(InputValue, 1, 20);
                        Rec.Modify();
                        codPOSTrans.OpenNumericKeyboard('Current balance', '', 71);
                    end;
                end ELSE begin
                    codPOSTrans.PosErrorBanner('Invalid gift no.');
                    codPOSTrans.CancelPressed(false, 0);
                    codPOSTrans.OpenNumericKeyboard('Gift card no.', '', 70);
                    codPOSTrans.TotalPressed(false);
                end;
            end;
        end;

        if (KeyboardTriggerToProcess = 71) then begin
            IsHandled := true;
            if InputValue <> '' then begin
                if CheckSpecialChars(InputValue) then begin
                    codPOSTrans.PosErrorBanner(SpecialCharsErr);
                    codPOSTrans.CancelPressed(false, 0);
                    codPOSTrans.SetPOSState('PAYMENT');
                    codPOSTrans.SetFunctionMode('PAYMENT');
                    codPOSTrans.OpenNumericKeyboard('Current balance', '', 71);
                    exit;
                end;
                TotalAmount := 0;
                if not Evaluate(CurBalance, InputValue) then begin
                    codPOSTrans.PosErrorBanner(SpecialCharsErr);
                    codPOSTrans.CancelPressed(false, 0);
                    codPOSTrans.SetPOSState('PAYMENT');
                    codPOSTrans.SetFunctionMode('PAYMENT');
                    codPOSTrans.OpenNumericKeyboard('Current balance', '', 71);
                end else begin
                    Rec.CalcFields("Gross Amount", Payment);
                    if Rec."Transaction Code Type" = Rec."Transaction Code Type"::DEPOSIT then begin
                        TotalAmount := Rec."Income/Exp. Amount";
                    end else begin
                        TotalAmount := Rec."Gross Amount" - Rec.Payment
                    end;
                    APPOSSESSION.Reset();
                    if APPOSSESSION.FindFirst() then begin
                        APPOSSESSION."Current Balance" := CurBalance;
                        APPOSSESSION."Card Tender Amount" := TotalAmount;
                        APPOSSESSION.Modify();
                    end else begin
                        APPOSSESSION.Init();
                        APPOSSESSION."Current Balance" := CurBalance;
                        APPOSSESSION."Card Tender Amount" := TotalAmount;
                        APPOSSESSION.Insert();
                    end;
                    // if (CardTenderAmount >= TotalAmount) then 
                    //if (CurBalance >= CardTenderAmount) then begin
                    IF CurBalance > 0 THEN begin
                        POSMenuLine2.Reset();
                        POSMenuLine2.SetRange(Command, 'AMOUNT_K');
                        if POSMenuLine2.FindFirst() then begin
                            if CurBalance >= TotalAmount then
                                POSMenuLine2.Parameter := Format(TotalAmount)
                            else
                                POSMenuLine2.Parameter := Format(CurBalance);
                            codPOSTrans.RunCommand(POSMenuLine2);
                        end else begin
                            POSMenuLine.Reset();
                            if POSMenuLine.FindFirst() then begin
                                POSMenuLine2.init;
                                POSMenuLine2.TransferFields(POSMenuLine2);
                                POSMenuLine2.Command := 'AMOUNT_K';
                                if CurBalance >= TotalAmount then
                                    POSMenuLine2.Parameter := Format(TotalAmount)
                                else
                                    POSMenuLine2.Parameter := Format(CurBalance);
                                POSMenuLine2.Insert();
                                codPOSTrans.RunCommand(POSMenuLine2);
                            end;
                        end;

                        POSMenuLine2.Reset();
                        POSMenuLine2.SetRange(Command, 'TENDER_K');
                        if POSMenuLine2.FindFirst() then begin
                            POSMenuLine2.Parameter := '8';
                            codPOSTrans.RunCommand(POSMenuLine2);
                        end;
                    end ELSE begin
                        codPOSTrans.PosErrorBanner('The amount must be greater than zero');
                        codPOSTrans.CancelPressed(false, 0);
                        codPOSTrans.SetPOSState('PAYMENT');
                        codPOSTrans.SetFunctionMode('PAYMENT');
                        codPOSTrans.OpenNumericKeyboard('Current balance', '', 71);
                        exit;
                    end;
                end;
            end else begin
                codPOSTrans.PosErrorBanner('The amount cannot be blank.');
                codPOSTrans.CancelPressed(false, 0);
                codPOSTrans.SetPOSState('PAYMENT');
                codPOSTrans.SetFunctionMode('PAYMENT');
                codPOSTrans.OpenNumericKeyboard('Current balance', '', 71);
                exit;
            end;
        end;

        if KeyboardTriggerToProcess = 60 then begin
            IsHandled := true;

            if InputValue = '' then begin
                codPOSTrans.PosErrorBanner('The check no. cannot be blank!');
                codPOSTrans.CancelPressed(false, 0);
                codPOSTrans.OpenNumericKeyboard('Check no.', '', 60);
                codPOSTrans.SetPOSState('PAYMENT');
                codPOSTrans.SetFunctionMode('PAYMENT');
                codPOSTrans.TotalPressed(false);
            end else begin
                if Evaluate(CreditCardNumber, CopyStr(InputValue, 1, 20)) then begin
                    if CheckSpecialChars(InputValue) then begin
                        codPOSTrans.PosErrorBanner(SpecialCharsErr);
                        codPOSTrans.CancelPressed(false, 0);
                        codPOSTrans.SetPOSState('PAYMENT');
                        codPOSTrans.SetFunctionMode('PAYMENT');
                        codPOSTrans.OpenNumericKeyboard('Check no.', '', 60);
                    end else begin
                        Rec."AP Credit Card Number" := CopyStr(InputValue, 1, 20);
                        Rec.Modify();
                        codPOSTrans.OpenNumericKeyboard('Amount', Format(POSAddFunc.CalculateBalance(Rec), 0, '<Sign><Integer Thousand><Decimal,3>'), 61);//nextt
                    end;
                end ELSE begin
                    codPOSTrans.PosErrorBanner('Invalid Check no.');
                    codPOSTrans.CancelPressed(false, 0);
                    codPOSTrans.OpenNumericKeyboard('Check no.', '', 60);
                    codPOSTrans.SetPOSState('PAYMENT');
                    codPOSTrans.SetFunctionMode('PAYMENT');
                    codPOSTrans.TotalPressed(false);
                end;
            end;
        end;


        if (KeyboardTriggerToProcess = 61) then begin
            IsHandled := true;

            TXTBOOL := false;

            if InputValue <> '' then begin
                if not Evaluate(CardTenderAmount, InputValue) then begin
                    codPOSTrans.PosErrorBanner(SpecialCharsErr);
                    codPOSTrans.CancelPressed(false, 0);
                    codPOSTrans.SetPOSState('PAYMENT');
                    codPOSTrans.SetFunctionMode('PAYMENT');
                    codPOSTrans.OpenNumericKeyboard('Amount', '', 61);
                end else begin
                    if CheckSpecialChars(InputValue) then begin
                        codPOSTrans.PosErrorBanner(SpecialCharsErr);
                        codPOSTrans.CancelPressed(false, 0);
                        codPOSTrans.SetPOSState('PAYMENT');
                        codPOSTrans.SetFunctionMode('PAYMENT');
                        codPOSTrans.OpenNumericKeyboard('Amount', '', 61);
                    end else begin
                        TotalAmount := 0;
                        Evaluate(CurBalance, InputValue);
                        Rec.CalcFields("Gross Amount", Payment);
                        if Rec."Transaction Code Type" = Rec."Transaction Code Type"::DEPOSIT then begin
                            TotalAmount := Rec."Income/Exp. Amount";
                        end else begin
                            TotalAmount := Rec."Gross Amount" - Rec.Payment
                        end;

                        IF CardTenderAmount > 0 THEN begin
                            if CardTenderAmount > TotalAmount then begin
                                codPOSTrans.PosErrorBanner('Over tender is not allowed in check payment');
                                //codPOSTrans.CancelPressed(false, 0);
                                codPOSTrans.SetPOSState('PAYMENT');
                                codPOSTrans.SetFunctionMode('PAYMENT');
                                codPOSTrans.OpenNumericKeyboard('Amount', '', 61);
                            end else
                                TXTBOOL := POSGUI.PosConfirm(StrSubstNo('CHECK INFORMATION CONFIRMATION \ \ Check No: %1 \ Amount: %2', Rec."AP Credit Card Number", POSFunctions.FormatAmount(CardTenderAmount)), TXTBOOL);

                            if TXTBOOL then begin
                                APPOSSESSION.Reset();
                                if APPOSSESSION.FindFirst() then begin
                                    APPOSSESSION."Current Balance" := CardTenderAmount;
                                    APPOSSESSION."Card Tender Amount" := TotalAmount;
                                    APPOSSESSION.Modify();
                                end else begin
                                    APPOSSESSION.Init();
                                    APPOSSESSION."Current Balance" := CardTenderAmount;
                                    APPOSSESSION."Card Tender Amount" := TotalAmount;
                                    APPOSSESSION.Insert();
                                end;
                                // if (CardTenderAmount >= TotalAmount) then 
                                //if (CurBalance >= CardTenderAmount) then begin

                                POSMenuLine2.Reset();
                                POSMenuLine2.SetRange(Command, 'AMOUNT_K');
                                if POSMenuLine2.FindFirst() then begin
                                    if CardTenderAmount >= TotalAmount then
                                        POSMenuLine2.Parameter := Format(TotalAmount)
                                    else
                                        POSMenuLine2.Parameter := Format(CardTenderAmount);
                                    codPOSTrans.RunCommand(POSMenuLine2);
                                end else begin
                                    POSMenuLine.Reset();
                                    if POSMenuLine.FindFirst() then begin
                                        POSMenuLine2.init;
                                        POSMenuLine2.TransferFields(POSMenuLine2);
                                        POSMenuLine2.Command := 'AMOUNT_K';
                                        if CurBalance >= TotalAmount then
                                            POSMenuLine2.Parameter := Format(TotalAmount)
                                        else
                                            POSMenuLine2.Parameter := Format(CurBalance);
                                        POSMenuLine2.Insert();
                                        codPOSTrans.RunCommand(POSMenuLine2);
                                    end;
                                end;

                                POSMenuLine2.Reset();
                                POSMenuLine2.SetRange(Command, 'TENDER_K');
                                if POSMenuLine2.FindFirst() then begin
                                    POSMenuLine2.Parameter := '2';
                                    codPOSTrans.RunCommand(POSMenuLine2);
                                end;
                            end;
                        end ELSE begin
                            codPOSTrans.PosErrorBanner('The amount must be greater than zero');
                            codPOSTrans.CancelPressed(false, 0);
                            codPOSTrans.SetPOSState('PAYMENT');
                            codPOSTrans.SetFunctionMode('PAYMENT');
                            codPOSTrans.OpenNumericKeyboard('Amount', '', 61);
                            //exit;
                        end;
                    end;
                    if TXTBOOL then
                        POSSESSION.clearManagerID();

                end;
            end ELSE begin
                codPOSTrans.PosErrorBanner('Please input a valid amount before proceeding.');
                codPOSTrans.CancelPressed(false, 0);
                codPOSTrans.SetPOSState('PAYMENT');
                codPOSTrans.SetFunctionMode('PAYMENT');
                //codPOSTrans.OpenNumericKeyboard('Amount', '', 61);
                //exit;
            end;
        end;
        if KeyboardTriggerToProcess = 50 then begin //VINCENT20251215 DEBIT
            IsHandled := true;
            /*  MyArray := '[';
             MyArray += '"Receipt No." => ' + Rec."Receipt No." + ',';
             MyArray += '"Amount" =>' + InputValue + ',';
             MyArray += '"Staff_ID" =>' + Rec."Staff ID" + ',';
             MyArray += '"Terminal" =>' + Rec."POS Terminal No.";
             MyArray += ']'; */
            GHLProcess(Rec, 'DEBIT');
        end;
    end;

    procedure VoidTransaction(var POSTransaction: Record "LSC POS Transaction"; pmode: Integer)
    var
        POSCtrl: Codeunit "LSC POS Control Interface";
        Transaction: Record "LSC Transaction Header";
        POSMenuLine2: Record "LSC POS Menu Line";
        RecordRefLoc: RecordRef;
        RecordIDLoc: RecordID;
        ErrorText: Text;
        ActiveLookupID: Code[20];
        MgrRequiredErr: Label 'Manager privileges are required for this function';
        NoLinesWereEligibleForRef: Label 'No lines were eligible for refund from Receipt %1';
    begin
        if not POSSESSION.MgrKey then begin
            codPOSTrans.PosErrorBanner(MgrRequiredErr);
            codPOSTrans.SetPOSState('SALES');
            codPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            codPOSTrans.CancelPressed(true, 0);
            POSSESSION.ClearManagerID();
            exit
        end;

        ActiveLookupID := POSCtrl.GetActiveLookupID();
        if ActiveLookupID = 'REGISTER' then
            if POSCtrl.GetActiveLookupRecordID(RecordIDLoc) then begin
                RecordRefLoc.Get(RecordIDLoc);
                RecordRefLoc.SetTable(Transaction);
            end;

        if (Transaction."Sale Is Return Sale") or (Transaction."Refund Receipt No." <> '') then begin
            codPOSTrans.PosMessage(StrSubstNo(NoLinesWereEligibleForRef, Transaction."Receipt No."));
            codPOSTrans.SetPOSState('SALES');
            codPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            codPOSTrans.CancelPressed(true, 0);
            POSSESSION.ClearManagerID();
            exit
        end else begin

            APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."VOID TR" := true;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."VOID TR" := true;
                APPOSSESSION.Insert();
            end;
            POSMenuLine2.Reset();
            POSMenuLine2.SetRange(Command, 'VOID_AND_COPY_TR');
            if POSMenuLine2.FindFirst() then begin
                POSMenuLine2."Post Command" := 'CANCEL';
                codPOSTrans.RunCommand(POSMenuLine2);

            end;
        end;

    end;

    procedure ChecknNumOnly(Var CustName: Text[100]): boolean;
    var
        ChecknNumOnly: Label '1|2|3|4|5|6|7|8|9|0';
        Len: Integer;
    begin
        Clear(Len);
        Len := StrLen(DelChr(CustName, '=', DelChr(CustName, '=', ChecknNumOnly)));
        if Len > 0 then begin
            exit(false)
        end else
            exit(true);
    end;

    procedure CheckSpecialCharsExtended(Var CustName: Text[100]): boolean;
    var
        SpecialChars: Label '!|@|#|$|%|&|*|(|)|_|-|+|=|?|,|.|:|;|<|>|[|]|{|}|~|`|/|\|';
        Len: Integer;
    begin
        Clear(Len);
        Len := StrLen(DelChr(CustName, '=', DelChr(CustName, '=', SpecialChars)));
        if Len > 0 then begin
            exit(true)
        end else
            exit(false);
    end;

    procedure CheckSpecialChars(Var CustName: Text[100]): boolean;
    var
        SpecialChars: Label '!|@|#|$|%|&|*|(|)|_|-|+|=|?';
        Len: Integer;
    begin
        Clear(Len);
        Len := StrLen(DelChr(CustName, '=', DelChr(CustName, '=', SpecialChars)));
        if Len > 0 then begin
            exit(true)
        end else
            exit(false);
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterFloat, '', false, false)]
    local procedure "LSC POS Transaction Events_OnAfterFloat"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    begin
        POSSESSION.ClearManagerID();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnInit_OnAfterTenderDeclOpenOnADiffPOS, '', false, false)]
    local procedure "LSC POS Transaction Events_OnInit_OnAfterTenderDeclOpenOnADiffPOS"(var IsHandled: Boolean; var ReturnValue: Boolean)
    begin
        POSSESSION.ClearManagerID();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterChangePrice, '', false, false)]
    local procedure "LSC POS Transaction Events_OnAfterChangePrice"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
        POSSESSION.ClearManagerID();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterChangeQty, '', false, false)]
    local procedure "LSC POS Transaction Events_OnAfterChangeQty"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    begin
        POSSESSION.ClearManagerID();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterVoidPostedTransaction, '', false, false)]
    local procedure "LSC POS Transaction Events_OnAfterVoidPostedTransaction"(var Rec: Record "LSC POS Transaction")
    begin
        POSSESSION.ClearManagerID();
    end;


    [EventSubscriber(ObjectType::Table, Database::"LSC POS Trans. Line", OnAfterVoidLine, '', false, false)]
    local procedure "LSC POS Trans. Line_OnAfterVoidLine"(var Rec: Record "LSC POS Trans. Line")
    begin
        POSSESSION.ClearManagerID();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Functions", OnAfterSuspend, '', false, false)]
    local procedure "LSC POS Functions_OnAfterSuspend"(SuspPOSTransaction: Record "LSC POS Transaction"; var SendPOSTransSuccess: Boolean)
    begin
        POSSESSION.ClearManagerID();
    end;

    //Start--------------------------Procedure
    procedure InitNewLine(REC: Record "LSC POS Transaction")
    var
        MenuTypeRec: Record "LSC Restaurant Menu Type";
    begin
        Clear(NewLine);
        NewLine."Store No." := REC."Store No.";
        NewLine."POS Terminal No." := REC."POS Terminal No.";
        NewLine."Receipt No." := REC."Receipt No.";
        NewLine."Guest/Seat No." := CurrGuest;
        if NewLine."Restaurant Menu Type" <> 0 then begin
            if MenuTypeRec.Get(REC."Store No.", NewLine."Restaurant Menu Type") then
                NewLine."Restaurant Menu Type Code" := MenuTypeRec."Code on POS";
        end;
    end;

    procedure LocalProcessLinePreTotal(var pPosTrans: Record "LSC POS Transaction"; var pPosTransLine: Record "LSC POS Trans. Line"; pLineDiscGroup: Code[10])
    var
        POSOfferExt: Codeunit "LSC POS Offer Ext. Utility";
    begin
        LocalProcessLinePreTotal(pPosTrans, pPosTransLine, pLineDiscGroup);
    end;

    procedure GetOpenEOD(): Boolean
    var
        recTransactionHeader: Record "LSC Transaction Header";
        POSSESSION: Codeunit "LSC POS Session";
        recRetailCalendarLine: Record "LSC Retail Calendar Line";
        vDay: Date;
        recLStore: Record "LSC Store";
        codLPOSTrans: Codeunit "LSC POS Transaction";
    begin

        recTransactionHeader.Reset();
        recTransactionHeader.SetCurrentKey("POS Terminal No.", "Z-Report ID", "Transaction Type", "Entry Status", "Date", "Time");
        recTransactionHeader.SetRange("POS Terminal No.", POSSESSION.TerminalNo());
        recTransactionHeader.SetRange("Z-Report ID", '');
        recTransactionHeader.SetRange("Transaction Type", recTransactionHeader."Transaction Type"::Sales);
        recTransactionHeader.SetRange("Store No.", POSSESSION.StoreNo());
        recTransactionHeader.SETFILTER(recTransactionHeader."Entry Status", '%1|%2|%3',
                                       recTransactionHeader."Entry Status"::" ", recTransactionHeader."Entry Status"::Posted, recTransactionHeader."Entry Status"::Voided);

        recLStore.Reset();
        recLStore.SetRange(recLStore."No.", POSSESSION.StoreNo());
        if recLStore.FINDLAST then begin
            if recLStore."Open After Midnight" then begin
                if recLStore."Store Open To" > TIME then begin
                    vDay := CALCDATE('<-1D>', TODAY);
                    recTransactionHeader.SETFILTER(recTransactionHeader.Date, '<>%1', vDay)
                end else
                    recTransactionHeader.SETFILTER(recTransactionHeader.Date, '<>%1', TODAY);
            end else
                recTransactionHeader.SETFILTER(recTransactionHeader.Date, '<>%1', TODAY);
        end else
            recTransactionHeader.SETFILTER(recTransactionHeader.Date, '<>%1', TODAY);

        if recTransactionHeader.FINDFIRST then begin
            codLPOSTrans.ErrorBeep('End of day must be performed');
            POSSESSION.SetValue('ZFIRST', 'TRUE');
            EXIT(TRUE);
        end else begin
            POSSESSION.SetValue('ZFIRST', '');
        end;
    end;

    procedure ReprintZReport(pCurrInput: text[50])
    var
        CurrInput: Text;
        codLDate: Date;

    begin
        CurrInput := pCurrInput;
        if CurrInput <> '' then begin
            EVALUATE(codLDate, CurrInput);
            //MyLSCPOSPrintUtility.RePrintXZReport(codLDate); 122524
            CurrInput := '';
        end else
            codpOSTrans.ErrorBeep('Kindly specify a Date.');
    end;

    procedure CheckifEOSrocessToday(): Boolean
    var
        LSCPOSXreportstatistics: Record "LSC POS X-report statistics";
        recLRetailCalendarLine: Record "LSC Retail Calendar Line";
        vDay: Date;
        recLStore: Record "LSC Store";
        POSSESSION: Codeunit "LSC POS Session";
    begin
        LSCPOSXreportstatistics.RESET;
        LSCPOSXreportstatistics.SETCURRENTKEY("Store No.", "POS Terminal No.", "Trans. Date");
        LSCPOSXreportstatistics.SETRANGE(LSCPOSXreportstatistics."Store No.", POSSESSION.StoreNo);
        LSCPOSXreportstatistics.SETRANGE(LSCPOSXreportstatistics."POS Terminal No.", POSSESSION.TerminalNo);
        LSCPOSXreportstatistics.SETRANGE(LSCPOSXreportstatistics."Staff ID", POSSESSION.StaffID());
        recLRetailCalendarLine.RESET;
        recLRetailCalendarLine.SETRANGE("Calendar ID", POSSESSION.StoreNo);
        if recLRetailCalendarLine.FINDLAST then begin
            if recLRetailCalendarLine."Midnight Open" then begin
                if recLRetailCalendarLine."Time To" > TIME then begin
                    vDay := CALCDATE('<-1D>', TODAY);
                    LSCPOSXreportstatistics.SETFILTER(LSCPOSXreportstatistics."Trans. Date", '%1', vDay);
                end else
                    LSCPOSXreportstatistics.SETFILTER(LSCPOSXreportstatistics."Trans. Date", '%1', TODAY);
            end else
                LSCPOSXreportstatistics.SETFILTER(LSCPOSXreportstatistics."Trans. Date", '%1', TODAY);
        end else
            LSCPOSXreportstatistics.SETFILTER(LSCPOSXreportstatistics."Trans. Date", '%1', TODAY);

        if LSCPOSXreportstatistics.FindFirst() then begin
            codPOSTrans.ErrorBeep('Transaction is not allowed after the Cashier Reading has been performed.');
            POSSESSION.SetValue('XREAD', 'TRUE');
            EXIT(TRUE);
        end else BEGIN
            POSSESSION.SetValue('XREAD', '');
            EXIT(FALSE);
        end;
    end;

    procedure CheckifEODProcessToday(): Boolean
    var
        recEODLedgerEntry: Record "End Of Day Ledger";
        recLRetailCalendarLine: Record "LSC Retail Calendar Line";
        vDay: Date;
        recLStore: Record "LSC Store";
        POSSESSION: Codeunit "LSC POS Session";
    begin
        //CheckifEODProcessToday
        recEODLedgerEntry.RESET;
        recEODLedgerEntry.SETCURRENTKEY("Store No.", "POS Terminal No.", Date);
        recEODLedgerEntry.SETRANGE(recEODLedgerEntry."Store No.", POSSESSION.StoreNo);
        recEODLedgerEntry.SETRANGE(recEODLedgerEntry."POS Terminal No.", POSSESSION.TerminalNo);

        recLRetailCalendarLine.RESET;
        recLRetailCalendarLine.SETRANGE("Calendar ID", POSSESSION.StoreNo);
        if recLRetailCalendarLine.FINDLAST then begin
            if recLRetailCalendarLine."Midnight Open" then begin
                if recLRetailCalendarLine."Time To" > TIME then begin
                    vDay := CALCDATE('<-1D>', TODAY);
                    recEODLedgerEntry.SETFILTER(recEODLedgerEntry.Date, '%1', vDay);
                end else
                    recEODLedgerEntry.SETFILTER(recEODLedgerEntry.Date, '%1', TODAY);
            end else
                recEODLedgerEntry.SETFILTER(recEODLedgerEntry.Date, '%1', TODAY);
        end else
            recEODLedgerEntry.SETFILTER(recEODLedgerEntry.Date, '%1', TODAY);

        if recEODLedgerEntry.FindFirst() then begin
            codPOSTrans.ErrorBeep('Transaction is not allowed after the End of Day has been performed.');
            POSSESSION.SetValue('ZREAD', 'TRUE');
            EXIT(true);
        end else BEGIN
            POSSESSION.SetValue('ZREAD', '');
            EXIT(FALSE);
        end;
    end;

    procedure GetTransactionDate(): Date
    var
        recLTransHeader: Record "LSC Transaction Header";
    begin
        recLTransHeader.RESET;
        recLTransHeader.SETRANGE(recLTransHeader."Z-Report ID", '');
        recLTransHeader.SETFILTER(recLTransHeader."Entry Status", '%1|%2', recLTransHeader."Entry Status"::" ", recLTransHeader."Entry Status"::Posted);
        if recLTransHeader.FINDFIRST then begin
            EXIT(recLTransHeader.Date);
        end else
            EXIT(TODAY);
    end;

    procedure ValidateDepositTrans(var recLPOSTrans: record "LSC POS Transaction"): Boolean;
    begin
        if recLPOSTrans."Transaction Code Type" = recLPOSTrans."Transaction Code Type"::DEPOSIT then begin
            codPOSTrans.ErrorBeep('Transaction code type cannot be changed');
            codPOSTrans.CancelPressed(true, 0);
            codPOSTrans.SetPOSState(STATE_SALES);
            codPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 0;
            exit(true);
        end;
        exit(false);
    end;

    procedure ValidateAllowedFloatEntry(): Boolean
    var
        RetailSetup: Record "LSC Retail Setup";
        StaffLocal: Record "LSC Staff";
        POSSESSION: Codeunit "LSC POS Session";
        recTransactionHeader: Record "LSC Transaction Header";
        recLTerminal: Record "LSC POS Terminal";
    begin
        recLTerminal.RESET;
        recLTerminal.SETRANGE(recLTerminal."Store No.", POSSESSION.StoreNo);
        recLTerminal.SETRANGE(recLTerminal."No.", POSSESSION.TerminalNo);
        if recLTerminal.FINDFIRST THEN
            if recLTerminal."Allow Float Entry" then begin
                recTransactionHeader.RESET;
                recTransactionHeader.SETCURRENTKEY("POS Terminal No.", "Z-Report ID", "Transaction Type", "Entry Status", Date, Time);
                recTransactionHeader.SETRANGE(recTransactionHeader."Store No.", POSSESSION.StoreNo);
                recTransactionHeader.SETRANGE(recTransactionHeader."POS Terminal No.", POSSESSION.TerminalNo);
                recTransactionHeader.SETRANGE(recTransactionHeader."Staff ID", POSSESSION.StaffID);
                recTransactionHeader.SETRANGE(recTransactionHeader."Transaction Type", recTransactionHeader."Transaction Type"::"Float Entry");
                recTransactionHeader.SETRANGE(recTransactionHeader."Z-Report ID", '');
                recTransactionHeader.SETRANGE(recTransactionHeader."Cashier Report ID", '');
                recTransactionHeader.SETRANGE(recTransactionHeader.Date, GetTransactionDate);
                if NOT recTransactionHeader.FINDFIRST then begin
                    codPOSTrans.ErrorBeep('Float Entry must be performed');
                    EXIT(TRUE);
                end;
            end;
    end;

    procedure CheckTrans(var recLPOSTrans: Record "LSC POS Transaction")
    var
        RecLTransLine: Record "LSC POS Trans. Line";
        POSMenuLine2: Record "LSC POS Menu Line";
    begin
        if (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::DEPOSIT) then begin
            if recLPOSTrans."Customer No." = '' then begin
                recLPOSTrans."Transaction Code Type" := recLPOSTrans."Transaction Code Type"::REG;
                recLPOSTrans."Sale Is Return Sale" := false;
                //if recLPOSTrans.Modify() then;
            end;
        end
        else begin
            RecLTransLine.Reset();
            RecLTransLine.SetRange("Receipt No.", recLPOSTrans."Receipt No.");
            if not RecLTransLine.FindFirst() then begin
                recLPOSTrans."Transaction Code Type" := recLPOSTrans."Transaction Code Type"::REG;
                recLPOSTrans."Sale Is Return Sale" := false;
                //if recLPOSTrans.Modify() then;
            end;
        end;
        case recLPOSTrans."Transaction Code Type" of
            recLPOSTrans."Transaction Code Type"::"SRC", recLpostrans."Transaction Code Type"::PWD:
                begin
                    if (recLPOSTrans."Beginning Balance" <= 0) or (recLPOSTrans."Booklet No." = '') then begin
                        recLPOSTrans."Transaction Code Type" := recLPOSTrans."Transaction Code Type"::REG;
                        recLPOSTrans."Sale Is Return Sale" := false;
                        recLPOSTrans."Customer No." := '';
                        //recLPOSTrans.Modify();
                        POSMenuLine2.Reset();
                        POSMenuLine2.SetRange(Command, 'SELECTCUST');
                        if POSMenuLine2.FindFirst() then
                            codPOSTrans.RunCommand(POSMenuLine2);
                    end;
                end;
        end;
        //codPOSTrans.CancelPressed(true, 0);
        codPOSTrans.SetPOSState(STATE_SALES);
        codPOSTrans.SetFunctionMode('ITEM');
        codPOSTrans.SelectDefaultMenu();
    end;

    // procedure CheckTransForSRC_PWD(var recLPOSTrans: Record "LSC POS Transaction")
    // var
    //     RecLTransLine: Record "LSC POS Trans. Line";
    // begin
    //     if (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::DEPOSIT) then begin
    //         if (recLPOSTrans."Customer No." = '') or (recLPOSTrans."Beginning Balance" = 0) or (recLPOSTrans."Booklet No." = '') then begin
    //             recLPOSTrans."Transaction Code Type" := recLPOSTrans."Transaction Code Type"::REG;
    //             recLPOSTrans."Sale Is Return Sale" := false;
    //             if recLPOSTrans.Modify() then;
    //         end;
    //     end
    //     else begin
    //         RecLTransLine.Reset();
    //         RecLTransLine.SetRange("Receipt No.", recLPOSTrans."Receipt No.");
    //         if not RecLTransLine.FindFirst() then begin
    //             recLPOSTrans."Transaction Code Type" := recLPOSTrans."Transaction Code Type"::REG;
    //             recLPOSTrans."Sale Is Return Sale" := false;
    //             if recLPOSTrans.Modify() then;
    //         end;
    //     end;
    // end;

    procedure
    REGTransPressed(var recLPOSTrans: Record "LSC POS Transaction"): Boolean;
    var
        codLPOSTrans: Codeunit "LSC POS Transaction";
        recLPOsTransLine: Record "LSC POS Trans. Line";
    begin
        if POSSESSION.GetValue('GLOBALDB') = 'FALSE' then
            exit(false);
        if GetOpenEOD THEN   // Check if previous day is not yet perform eod
            exit(false);
        if CheckifEODProcessToday THEN //if already performed EOD
            exit(false);
        if CheckifEOSrocessToday THEN //if already performed Cashier Reading
            exit(false);
        if ValidateAllowedFloatEntry THEN
            exit(false);

        // if ((recLPOSTrans."Total Pressed" = false) and (recLPOSTrans."Transaction Code Type" = recLPOSTrans."Transaction Code Type"::DEPOSIT)) then begin
        //     codPOSTrans.ErrorBeep('Transaction code type cannot be changed');
        //     codPOSTrans.CancelPressed(true, 0);
        //     codLPOSTrans.SetPOSState(STATE_SALES);
        //     codLPOSTrans.SetFunctionMode('ITEM');
        //     codPOSTrans.SelectDefaultMenu();
        //     ctrbegbal_booklet := 0;
        //     exit;
        // end;

        //if recLPOSTrans."Customer No." = '' then begin
        // if (recLPOSTrans."Total Pressed" = false) OR
        //   (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::DEPOSIT) or
        //   (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::"Regular Customer") then begin


        if (recLPOSTrans."Total Pressed" = false) AND (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::DEPOSIT) then begin
            if recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::REG then begin
                recLPOSTrans."Transaction Code Type" := recLPOSTrans."Transaction Code Type"::REG;
                recLPOSTrans."Sale Is Return Sale" := false;
                recLPOSTrans."Customer No." := '';
                recLPOSTrans."Beginning Balance" := 0;
                recLPOSTrans."Booklet No." := '';
                recLPOSTrans."Sale Is Copied Transaction" := false;
                recLPOSTrans."Retrieved from Receipt No." := '';
                recLPOSTrans.Modify();
            end;

            APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::REG;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::REG;
                APPOSSESSION.Insert();
            end;
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            //recLPOSTrans."Total Pressed" := false;
            // 
            Commit();
            exit(true);
        end else begin
            codPOSTrans.ErrorBeep('Transaction code type cannot be changed');
            codPOSTrans.CancelPressed(true, 0);
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 0;
            exit(false);
        end;
        // end else begin
        //     codPOSTrans.ErrorBeep('Transaction code type cannot be changed');
        //     codPOSTrans.CancelPressed(true, 0);
        //     codLPOSTrans.SetPOSState(STATE_SALES);
        //     codLPOSTrans.SetFunctionMode('ITEM');
        //     codPOSTrans.SelectDefaultMenu();
        //     ctrbegbal_booklet := 0;
        //     exit(false);
        // end;

        // if (recLPOSTrans."Total Pressed" = false) OR
        //     (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::DEPOSIT) or
        //     (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::"Regular Customer") then begin

        //     recLPOSTrans."Transaction Code Type" := recLPOSTrans."Transaction Code Type"::REG;
        //     recLPOSTrans."Sale Is Return Sale" := false;
        //     recLPOSTrans."Customer No." := '';
        //     recLPOSTrans."Beginning Balance" := 0;
        //     recLPOSTrans."Booklet No." := '';
        //     recLPOSTrans."Sale Is Copied Transaction" := false;
        //     recLPOSTrans."Retrieved from Receipt No." := '';
        //     codLPOSTrans.SetPOSState(STATE_SALES);
        //     codLPOSTrans.SetFunctionMode('ITEM');
        //     codPOSTrans.SelectDefaultMenu();
        //     recLPOSTrans."Total Pressed" := false;
        //     recLPOSTrans.Modify();
        //     Commit();
        //     exit(true);
        // end else begin
        //     codPOSTrans.ErrorBeep('Transaction code type cannot be changed');
        //     codPOSTrans.CancelPressed(true, 0);
        //     codLPOSTrans.SetPOSState(STATE_SALES);
        //     codLPOSTrans.SetFunctionMode('ITEM');
        //     codPOSTrans.SelectDefaultMenu();
        //     ctrbegbal_booklet := 0;
        //     exit(false);
        // end;
    end;

    procedure Updatetranstype(var recLPOSTrans: Record "LSC POS Transaction")
    var
        APPOSSESSION: Record "AP POSSESSIONS";
    begin
        APPOSSESSION.Reset();
        if APPOSSESSION.FindFirst() then begin
            APPOSSESSION."Trans Type" := recLPOSTrans."Transaction Code Type";
            APPOSSESSION.modify();
        end else begin
            APPOSSESSION.Init();
            APPOSSESSION."Trans Type" := recLPOSTrans."Transaction Code Type";
            APPOSSESSION.Insert();
        end;

    end;

    procedure REGTransPressed2(var recLPOSTrans: Record "LSC POS Transaction"): Boolean
    var
        codLPOSTrans: Codeunit "LSC POS Transaction";
        recLPOsTransLine: Record "LSC POS Trans. Line";
    begin
        //Message('REGTransPressed');
        if POSSESSION.GetValue('GLOBALDB') = 'FALSE' then
            exit(false);
        if GetOpenEOD THEN   // Check if previous day is not yet perform eod
            exit(false);
        if CheckifEODProcessToday THEN //if already performed EOD
            exit(false);
        if CheckifEOSrocessToday THEN //if already performed Cashier Reading
            exit(false);
        if ValidateAllowedFloatEntry THEN
            exit(false);
        //     if (recLPOSTrans."Total Pressed" = false) or (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::DEPOSIT) then begin
        if (recLPOSTrans."Total Pressed" = false) AND (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::DEPOSIT) then begin

            // recLPOSTrans."Transaction Code Type" := recLPOSTrans."Transaction Code Type"::"Regular Customer";
            // recLPOSTrans."Sale Is Return Sale" := false;
            // recLPOSTrans."Customer No." := '';
            // recLPOSTrans."Beginning Balance" := 0;
            // recLPOSTrans."Booklet No." := '';
            // recLPOSTrans."Sale Is Copied Transaction" := false;
            // recLPOSTrans."Retrieved from Receipt No." := '';
            // recLPOSTrans.Modify();
            //Commit();
            APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::"Regular Customer";
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::"Regular Customer";
                APPOSSESSION.Insert();
            end;

            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 1;
            exit(true);
        end else begin
            codPOSTrans.ErrorBeep('Transaction code type cannot be changed');
            codPOSTrans.CancelPressed(true, 0);
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 0;
            exit(false);
        end;
    end;

    procedure RemoveFreeTextforREG(var recLPOSTrans: Record "LSC POS Transaction")
    var
        recLtranLine: record "LSC POS Trans. Line";
    begin
        recLtranLine.Reset();
        recLtranLine.SetRange("Receipt No.", recLPOSTrans."Receipt No.");
        recLtranLine.SetRange("Entry Type", recLtranLine."Entry Type"::FreeText);
        if recLtranLine.FindFirst() then
            repeat
                recLtranLine.Delete();
            until recLtranLine.Next() = 0;

        // Commit();
    end;


    procedure SRCTransPressed(var recLPOSTrans: Record "LSC POS Transaction")
    var
        codLPOSTrans: Codeunit "LSC POS Transaction";
    begin

        if GetOpenEOD THEN   // Check if previous day is not yet perform eod
            EXIT;

        if CheckifEODProcessToday THEN //if already performed EOD
            EXIT;
        if CheckifEOSrocessToday THEN //if already performed Cashier Reading
            EXIT;
        if ValidateAllowedFloatEntry THEN
            EXIT;
        if (recLPOSTrans."Total Pressed" = false) and (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::DEPOSIT) then begin
            STATE_SALES := 'SALES';
            // recLPOSTrans."Transaction Code Type" := recLPOSTrans."Transaction Code Type"::SRC;
            // recLPOSTrans."Sale Is Return Sale" := false;
            // recLPOSTrans."Beginning Balance" := 0;
            // recLPOSTrans."Booklet No." := '';
            // recLPOSTrans.Modify();
            //Commit();
            /* APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::SRC;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::SRC;
                APPOSSESSION.Insert();
            end; */

            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 1;
        end else begin
            codPOSTrans.ErrorBeep('Transaction code type cannot be changed');
            codPOSTrans.CancelPressed(true, 0);
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 0;
            exit;
        end;
    end;

    procedure PWDTransPressed(var recLPOSTrans: Record "LSC POS Transaction")
    var
        codLPOSTrans: Codeunit "LSC POS Transaction";
    begin

        if GetOpenEOD THEN   // Check if previous day is not yet perform eod
            EXIT;

        if CheckifEODProcessToday THEN //if already performed EOD
            EXIT;
        if CheckifEOSrocessToday THEN //if already performed Cashier Reading
            EXIT;
        if ValidateAllowedFloatEntry THEN
            EXIT;

        //if recLPOSTrans."Customer No." = '' then
        if (recLPOSTrans."Total Pressed" = false)
            or (recLPOSTrans."Transaction Code Type" = recLPOSTrans."Transaction Code Type"::REG)
            and (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::DEPOSIT) then begin

            STATE_SALES := 'SALES';
            // recLPOSTrans."Transaction Code Type" := recLPOSTrans."Transaction Code Type"::PWD;
            // recLPOSTrans."Sale Is Return Sale" := false;
            // recLPOSTrans."Beginning Balance" := 0;
            // recLPOSTrans."Booklet No." := '';
            // recLPOSTrans.Modify();
            //Commit();
            /* APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::PWD;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::PWD;
                APPOSSESSION.Insert();
            end; */
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 1;

        end else begin
            codPOSTrans.ErrorBeep('Transaction code type cannot be changed');
            codPOSTrans.CancelPressed(true, 0);
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 0;
            exit;
        end;
    end;

    procedure MOVTransPressed(var recLPOSTrans: Record "LSC POS Transaction")
    var
        codLPOSTrans: Codeunit "LSC POS Transaction";
        POSSESSION: Codeunit "LSC POS Session";
    begin

        if GetOpenEOD THEN   // Check if previous day is not yet perform eod
            EXIT;

        if CheckifEODProcessToday THEN //if already performed EOD
            EXIT;
        if CheckifEOSrocessToday THEN //if already performed Cashier Reading
            EXIT;
        if ValidateAllowedFloatEntry THEN
            EXIT;

        // if recLPOSTrans."Customer No." = '' then
        if (recLPOSTrans."Total Pressed" = false)
            or (recLPOSTrans."Transaction Code Type" = recLPOSTrans."Transaction Code Type"::REG)
            and (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::DEPOSIT) then begin
            STATE_SALES := 'SALES';

            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 1;

        end else begin
            codPOSTrans.ErrorBeep('Transaction code type cannot be changed');
            codPOSTrans.CancelPressed(true, 0);
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 0;
            exit;
        end;
    end;

    procedure NAACTransPressed(var recLPOSTrans: Record "LSC POS Transaction")
    var
        codLPOSTrans: Codeunit "LSC POS Transaction";
        POSSESSION: Codeunit "LSC POS Session";
    begin

        if GetOpenEOD THEN   // Check if previous day is not yet perform eod
            EXIT;

        if CheckifEODProcessToday THEN //if already performed EOD
            EXIT;
        if CheckifEOSrocessToday THEN //if already performed Cashier Reading
            EXIT;
        if ValidateAllowedFloatEntry THEN
            EXIT;

        // if recLPOSTrans."Customer No." = '' then
        if (recLPOSTrans."Total Pressed" = false)
            or (recLPOSTrans."Transaction Code Type" = recLPOSTrans."Transaction Code Type"::REG)
            and (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::DEPOSIT) then begin
            STATE_SALES := 'SALES';

            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 1;

        end else begin
            codPOSTrans.ErrorBeep('Transaction code type cannot be changed');
            codPOSTrans.CancelPressed(true, 0);
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 0;
            exit;
        end;
    end;

    procedure OnlineTransPressed(var recLPOSTrans: Record "LSC POS Transaction")
    var
        codLPOSTrans: Codeunit "LSC POS Transaction";
        POSSESSION: Codeunit "LSC POS Session";
    begin

        if GetOpenEOD THEN   // Check if previous day is not yet perform eod
            EXIT;

        if CheckifEODProcessToday THEN //if already performed EOD
            EXIT;
        if CheckifEOSrocessToday THEN //if already performed Cashier Reading
            EXIT;
        if ValidateAllowedFloatEntry THEN
            EXIT;

        // if recLPOSTrans."Customer No." = '' then
        if (recLPOSTrans."Total Pressed" = false)
            or (recLPOSTrans."Transaction Code Type" = recLPOSTrans."Transaction Code Type"::REG)
            and (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::DEPOSIT) then begin
            STATE_SALES := 'SALES';

            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 1;

        end else begin
            codPOSTrans.ErrorBeep('Transaction code type cannot be changed');
            codPOSTrans.CancelPressed(true, 0);
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 0;
            exit;
        end;
    end;

    procedure SOLOTransPressed(var recLPOSTrans: Record "LSC POS Transaction")
    var
        codLPOSTrans: Codeunit "LSC POS Transaction";
        POSSESSION: Codeunit "LSC POS Session";
    begin

        if GetOpenEOD THEN   // Check if previous day is not yet perform eod
            EXIT;

        if CheckifEODProcessToday THEN //if already performed EOD
            EXIT;
        if CheckifEOSrocessToday THEN //if already performed Cashier Reading
            EXIT;
        if ValidateAllowedFloatEntry THEN
            EXIT;

        // if recLPOSTrans."Customer No." = '' then
        if (recLPOSTrans."Total Pressed" = false)
            or (recLPOSTrans."Transaction Code Type" = recLPOSTrans."Transaction Code Type"::REG)
            and (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::DEPOSIT) then begin
            STATE_SALES := 'SALES';
            // recLPOSTrans."Transaction Code Type" := recLPOSTrans."Transaction Code Type"::SOLO;
            // recLPOSTrans."Sale Is Return Sale" := false;
            // recLPOSTrans."Beginning Balance" := 0;
            // recLPOSTrans."Booklet No." := '';
            // recLPOSTrans.Modify();
            // Commit();
            /* APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::SOLO;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::SOLO;
                APPOSSESSION.Insert();
            end; */
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 1;

        end else begin
            codPOSTrans.ErrorBeep('Transaction code type cannot be changed');
            codPOSTrans.CancelPressed(true, 0);
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 0;
            exit;
        end;
    end;

    procedure WHTTransPressed(var recLPOSTrans: Record "LSC POS Transaction")
    var
        codLPOSTrans: Codeunit "LSC POS Transaction";
        POSSESSION: Codeunit "LSC POS Session";
    begin

        if GetOpenEOD THEN   // Check if previous day is not yet perform eod
            EXIT;

        if CheckifEODProcessToday THEN //if already performed EOD
            EXIT;
        if CheckifEOSrocessToday THEN //if already performed Cashier Reading
            EXIT;
        if ValidateAllowedFloatEntry THEN
            EXIT;

        //if recLPOSTrans."Customer No." = '' then
        if (recLPOSTrans."Total Pressed" = false)
            or (recLPOSTrans."Transaction Code Type" = recLPOSTrans."Transaction Code Type"::REG)
            and (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::DEPOSIT) then begin
            STATE_SALES := 'SALES';
            // recLPOSTrans."Transaction Code Type" := recLPOSTrans."Transaction Code Type"::WHT1;
            // recLPOSTrans."Sale Is Return Sale" := false;
            // recLPOSTrans."Beginning Balance" := 0;
            // recLPOSTrans."Booklet No." := '';
            // recLPOSTrans.Modify();
            // Commit();
            /* APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::WHT1;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::WHT1;
                APPOSSESSION.Insert();
            end; */
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 1;

        end else begin
            codPOSTrans.ErrorBeep('Transaction code type cannot be changed');
            codPOSTrans.CancelPressed(true, 0);
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 0;
            exit;
        end;
    end;

    procedure ATHLTransPressed(var recLPOSTrans: Record "LSC POS Transaction")
    var
        codLPOSTrans: Codeunit "LSC POS Transaction";
        POSSESSION: Codeunit "LSC POS Session";
    begin

        if GetOpenEOD THEN   // Check if previous day is not yet perform eod
            EXIT;

        if CheckifEODProcessToday THEN //if already performed EOD
            EXIT;
        if CheckifEOSrocessToday THEN //if already performed Cashier Reading
            EXIT;
        if ValidateAllowedFloatEntry THEN
            EXIT;
        //if recLPOSTrans."Customer No." = '' then
        if (recLPOSTrans."Total Pressed" = false)
        or (recLPOSTrans."Transaction Code Type" = recLPOSTrans."Transaction Code Type"::REG)
         and (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::DEPOSIT) then begin
            STATE_SALES := 'SALES';
            // recLPOSTrans."Transaction Code Type" := recLPOSTrans."Transaction Code Type"::ATHL;
            // recLPOSTrans."Sale Is Return Sale" := false;
            // recLPOSTrans."Beginning Balance" := 0;
            // recLPOSTrans."Booklet No." := '';
            // recLPOSTrans.Modify();
            // Commit();
            /* APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::ATHL;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::ATHL;
                APPOSSESSION.Insert();
            end; */
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 1;

        end else begin
            codPOSTrans.ErrorBeep('Transaction code type cannot be changed');
            codPOSTrans.CancelPressed(true, 0);
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 0;
            exit;
        end;
    end;

    procedure ZRWHTTransPressed(var recLPOSTrans: Record "LSC POS Transaction")
    var
        codLPOSTrans: Codeunit "LSC POS Transaction";
        POSSESSION: Codeunit "LSC POS Session";
    begin

        if GetOpenEOD THEN   // Check if previous day is not yet perform eod
            EXIT;

        if CheckifEODProcessToday THEN //if already performed EOD
            EXIT;
        if CheckifEOSrocessToday THEN //if already performed Cashier Reading
            EXIT;
        if ValidateAllowedFloatEntry THEN
            EXIT;

        //if recLPOSTrans."Customer No." = '' then
        if (recLPOSTrans."Total Pressed" = false) or
             (recLPOSTrans."Transaction Code Type" = recLPOSTrans."Transaction Code Type"::REG) or
             (recLPOSTrans."Transaction Code Type" = recLPOSTrans."Transaction Code Type"::ZRWH) and
             (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::DEPOSIT) then begin

            STATE_SALES := 'SALES';
            // recLPOSTrans."Transaction Code Type" := recLPOSTrans."Transaction Code Type"::ZRWH;
            // recLPOSTrans."Sale Is Return Sale" := false;
            // recLPOSTrans."Beginning Balance" := 0;
            // recLPOSTrans."Booklet No." := '';
            // recLPOSTrans.Modify();
            // Commit();
            /* APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::ZRWH;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::ZRWH;
                APPOSSESSION.Insert();
            end; */
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 1;

        end else begin
            codPOSTrans.ErrorBeep('Transaction code type cannot be changed');
            codPOSTrans.CancelPressed(true, 0);
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 0;
            exit;
        end;
    end;

    procedure VATWHTTransPressed(var recLPOSTrans: Record "LSC POS Transaction")
    var
        codLPOSTrans: Codeunit "LSC POS Transaction";
        POSSESSION: Codeunit "LSC POS Session";
    begin

        if GetOpenEOD THEN   // Check if previous day is not yet perform eod
            EXIT;
        if CheckifEODProcessToday THEN //if already performed EOD
            EXIT;

        if ValidateAllowedFloatEntry THEN
            EXIT;
        if CheckifEOSrocessToday THEN //if already performed Cashier Reading
            EXIT;


        // STATE_SALES := 'SALES';
        // recLPOSTrans."Transaction Code Type" := recLPOSTrans."Transaction Code Type"::VATW;
        // recLPOSTrans."Sale Is Return Sale" := false;
        // recLPOSTrans.Modify();
        // Commit();

        // codLPOSTrans.SetInfoTextDescription('VAT WITHHOLDING TRANSACTION...', '');

        // codLPOSTrans.SetPOSState(STATE_SALES);
        // codLPOSTrans.SetFunctionMode('ITEM');
        // codPOSTrans.SelectDefaultMenu();
        //if (recLPOSTrans."Transaction Code Type" = recLPOSTrans."Transaction Code Type"::REG) or (recLPOSTrans."Transaction Code Type" = recLPOSTrans."Transaction Code Type"::VATW) and (recLPOSTrans."Total Pressed" = false) then begin
        // if recLPOSTrans."Customer No." = '' then
        if (recLPOSTrans."Total Pressed" = false) or (recLPOSTrans."Transaction Code Type" = recLPOSTrans."Transaction Code Type"::REG)
          and (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::DEPOSIT) then begin
            STATE_SALES := 'SALES';
            // recLPOSTrans."Transaction Code Type" := recLPOSTrans."Transaction Code Type"::VATW;
            // recLPOSTrans."Sale Is Return Sale" := false;
            // recLPOSTrans."Beginning Balance" := 0;
            // recLPOSTrans."Booklet No." := '';
            // recLPOSTrans.Modify();
            // Commit();
            /* APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::VATW;
                APPOSSESSION.Modify();
            end else begin
                APPOSSESSION.Init();
                APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::VATW;
                APPOSSESSION.Insert();
            end; */
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 1;

        end else begin
            codPOSTrans.ErrorBeep('Transaction code type cannot be changed');
            codPOSTrans.CancelPressed(true, 0);
            codLPOSTrans.SetPOSState(STATE_SALES);
            codLPOSTrans.SetFunctionMode('ITEM');
            codPOSTrans.SelectDefaultMenu();
            ctrbegbal_booklet := 0;
            exit;
        end;
    end;

    procedure ZeroTransPressed(var recLPOSTrans: Record "LSC POS Transaction")
    var
        codLPOSTrans: Codeunit "LSC POS Transaction";
        POSSESSION: Codeunit "LSC POS Session";
    begin

        if GetOpenEOD THEN   // Check if previous day is not yet perform eod
            EXIT;

        if CheckifEODProcessToday THEN //if already performed EOD
            EXIT;
        if CheckifEOSrocessToday THEN //if already performed Cashier Reading
            EXIT;
        if ValidateAllowedFloatEntry THEN
            EXIT;


        // STATE_SALES := 'SALES';
        // recLPOSTrans."Transaction Code Type" := recLPOSTrans."Transaction Code Type"::ZERO;
        // recLPOSTrans."Sale Is Return Sale" := false;
        // recLPOSTrans.Modify();
        // Commit();

        // codLPOSTrans.SetInfoTextDescription('ZERO RATED TRANSACTION...', '');

        // codLPOSTrans.SetPOSState(STATE_SALES);
        // codLPOSTrans.SetFunctionMode('ITEM');
        // codPOSTrans.SelectDefaultMenu();
        //if (recLPOSTrans."Transaction Code Type" = recLPOSTrans."Transaction Code Type"::REG) or (recLPOSTrans."Transaction Code Type" = recLPOSTrans."Transaction Code Type"::ZERO) and (recLPOSTrans."Total Pressed" = false) then begin
        if recLPOSTrans."Customer No." = '' then
            if (recLPOSTrans."Total Pressed" = false) or (recLPOSTrans."Transaction Code Type" <> recLPOSTrans."Transaction Code Type"::DEPOSIT) then begin
                STATE_SALES := 'SALES';
                // recLPOSTrans."Transaction Code Type" := recLPOSTrans."Transaction Code Type"::ZERO;
                // recLPOSTrans."Sale Is Return Sale" := false;
                // recLPOSTrans."Beginning Balance" := 0;
                // recLPOSTrans."Booklet No." := '';
                // recLPOSTrans.Modify();
                // Commit();
                /* APPOSSESSION.Reset();
                if APPOSSESSION.FindFirst() then begin
                    APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::ZERO;
                    APPOSSESSION.Modify();
                end else begin
                    APPOSSESSION.Init();
                    APPOSSESSION."Transaction Code Type" := APPOSSESSION."Transaction Code Type"::ZERO;
                    APPOSSESSION.Insert();
                end; */

                codLPOSTrans.SetPOSState(STATE_SALES);
                codLPOSTrans.SetFunctionMode('ITEM');
                codPOSTrans.SelectDefaultMenu();
                ctrbegbal_booklet := 1;

            end else begin
                codPOSTrans.ErrorBeep('Transaction code type cannot be changed');
                codPOSTrans.CancelPressed(true, 0);
                codLPOSTrans.SetPOSState(STATE_SALES);
                codLPOSTrans.SetFunctionMode('ITEM');
                codPOSTrans.SelectDefaultMenu();
                ctrbegbal_booklet := 0;
                exit;
            end;
    end;

    procedure ZeroPressed(REC: Record "LSC POS Transaction");
    var
        recLPOSTransLine: Record "LSC POS Trans. Line";
        recLPOSTransLine2: Record "LSC POS Trans. Line";
        decLAmount: Decimal;
        decLZeroRatedAmt: Decimal;
        decLVZOrigAmount: Decimal;
        decLVZAmount: Decimal;
        decLVZAmountTmp: Decimal;
        declVZSalesDiff: Decimal;
        decLNetofVAT: Decimal;
        decTotalTransLineVZ: Decimal;
        decTotalTransVZAmt: Decimal;
        decVZAmtDiff: Decimal;
    begin
        codPOSTrans.CalcTotals;
        REC."Amount Before" := ABS(RealBalance);

        if POSAddFunc.ZeroRatedPressed(REC."Receipt No.") then begin

            REC."Zero Rated Applied Counter" := REC."Zero Rated Applied Counter" + 1;
            REC.MODifY;

            decLAmount := 0;
            decLZeroRatedAmt := 0;
            decLVZOrigAmount := 0;
            decLVZAmount := 0;
            decLVZAmountTmp := 0;
            declVZSalesDiff := 0;

            recLPOSTransLine.RESET;
            recLPOSTransLine.SETRANGE("Receipt No.", REC."Receipt No.");
            recLPOSTransLine.SETRANGE("Entry Type", recLPOSTransLine."Entry Type"::Item);
            recLPOSTransLine.SETRANGE("Entry Status", recLPOSTransLine."Entry Status"::" ");

            if recLPOSTransLine.FINDFIRST THEN
                REPEAT
                    if (recLPOSTransLine."VAT Code" = 'VZ') then begin
                        if (REC."Transaction Code Type" IN
                                                           [REC."Transaction Code Type"::ZERO,
                                                            REC."Transaction Code Type"::ZRWH]) then begin

                            decLNetofVAT := ROUND((recLPOSTransLine.Amount / (1 + 12 / 100)), 0.01);

                        end else
                            decLNetofVAT := ROUND((recLPOSTransLine.Amount / 1.12), 0.01);

                        decLVZOrigAmount := decLVZOrigAmount + recLPOSTransLine."Org. Price Inc. VAT";

                        recLPOSTransLine.Amount := decLNetofVAT;
                        recLPOSTransLine."Net Amount" := decLNetofVAT;
                        recLPOSTransLine."Zero Rated Amount" := ROUND((decLNetofVAT * 0.12), 0.01);
                        //recLPOSTransLine."VAT Code" := 'VZ';
                        decLVZAmount := decLVZAmount + recLPOSTransLine.Amount;
                    end else BEGIN
                        recLPOSTransLine."Zero Rated Amount" := 0;
                        recLPOSTransLine.Amount := recLPOSTransLine.Amount -
                                                recLPOSTransLine."Zero Rated Amount";
                    end;

                    recLPOSTransLine.MODifY;
                    decLZeroRatedAmt := decLZeroRatedAmt + ROUND(recLPOSTransLine."Zero Rated Amount", 0.01, '=');

                UNTIL recLPOSTransLine.NEXT = 0;

            decLVZAmountTmp := ROUND((decLVZOrigAmount / 1.12), 0.01);
            decTotalTransLineVZ := 0;

            recLPOSTransLine2.RESET;
            recLPOSTransLine2.SETRANGE("Receipt No.", REC."Receipt No.");
            recLPOSTransLine2.SETRANGE("Entry Type", recLPOSTransLine2."Entry Type"::Item);
            recLPOSTransLine2.SETRANGE("Entry Status", recLPOSTransLine2."Entry Status"::" ");
            recLPOSTransLine2.SETRANGE(recLPOSTransLine2."VAT Code", 'VZ');
            if recLPOSTransLine2.FINDFIRST THEN
                REPEAT
                    decTotalTransLineVZ := decTotalTransLineVZ + ROUND(recLPOSTransLine2.Amount, 0.01, '=');
                    decTotalTransVZAmt := decTotalTransVZAmt + ROUND(recLPOSTransLine2."Zero Rated Amount", 0.01, '=');
                UNTIL recLPOSTransLine2.NEXT = 0;
            declVZSalesDiff := decLVZAmountTmp - decTotalTransLineVZ;
            decVZAmtDiff := ROUND((decLVZOrigAmount - decLVZAmountTmp), 0.01) - decTotalTransVZAmt;

            if (declVZSalesDiff <> 0) OR (decVZAmtDiff <> 0) then begin
                recLPOSTransLine2.RESET;
                recLPOSTransLine2.SETRANGE("Receipt No.", REC."Receipt No.");
                recLPOSTransLine2.SETRANGE("Entry Type", recLPOSTransLine2."Entry Type"::Item);
                recLPOSTransLine2.SETRANGE("Entry Status", recLPOSTransLine2."Entry Status"::" ");
                recLPOSTransLine2.SETRANGE(recLPOSTransLine2."VAT Code", 'VZ');
                if recLPOSTransLine2.FINDFIRST then begin
                    if declVZSalesDiff >= 0 THEN
                        recLPOSTransLine2.Amount := recLPOSTransLine2.Amount + declVZSalesDiff
                    ELSE
                        recLPOSTransLine2.Amount := recLPOSTransLine2.Amount + declVZSalesDiff;

                    recLPOSTransLine2."Net Amount" := recLPOSTransLine2.Amount;

                    recLPOSTransLine2."Zero Rated Amount" := recLPOSTransLine2."Zero Rated Amount" + decVZAmtDiff;
                    recLPOSTransLine2.MODifY;
                end;
            end;

            REC."Zero Rated Amount" := ROUND((decLVZOrigAmount - decLVZAmountTmp), 0.01);
            REC."Zero Rated Applied Counter" += 1;
            REC.MODifY;
            Message('Zero Rated  Applied');

        end;
    end;

    procedure ValidateDiscountCode(var REC: Record "LSC POS Transaction"; var LineRec: Record "LSC POS Trans. Line"; var CurrInput: Text; TenderTypeCode: Code[20])
    var
        DiscountCode: Code[10];
        recLGlobaLRef: Record "Global References";
        txtString: Text[100];
        Discper: Text[10];
    begin
        if (REC."Transaction Code Type" IN [REC."Transaction Code Type"::"SRC", REC."Transaction Code Type"::PWD, REC."Transaction Code Type"::SOLO,
                                          REC."Transaction Code Type"::ZERO, REC."Transaction Code Type"::WHT1, REC."Transaction Code Type"::VATW,
                                          REC."Transaction Code Type"::ZRWH, REC."Transaction Code Type"::ATHL, REC."Transaction Code Type"::NAAC, REC."Transaction Code Type"::MOV]) then begin
            case REC."Transaction Code Type" OF
                REC."Transaction Code Type"::NAAC:
                    begin
                        if GetNAACDiscount(REC, LineRec) <> 0 then
                            exit;
                        if CurrInput = '' then
                            CurrInput := GetDiscountCode(REC."Transaction Code Type");
                    end;
                REC."Transaction Code Type"::MOV:
                    begin
                        if GetMOVDiscount(REC, LineRec) <> 0 then
                            exit;
                        if CurrInput = '' then
                            CurrInput := GetDiscountCode(REC."Transaction Code Type");
                    end;
                REC."Transaction Code Type"::"SRC":
                    begin
                        if GetSRCDiscount(REC, LineRec) <> 0 then
                            exit;
                        if CurrInput = '' then
                            CurrInput := GetDiscountCode(REC."Transaction Code Type");
                    end;
                REC."Transaction Code Type"::PWD:
                    begin
                        if GetPWDDiscount(REC, LineRec) <> 0 then
                            exit;
                        if CurrInput = '' then
                            CurrInput := GetDiscountCode(REC."Transaction Code Type");
                    end;
                REC."Transaction Code Type"::SOLO:
                    begin
                        if GetSOLODiscount(REC, LineRec) <> 0 then
                            exit;
                        if CurrInput = '' then
                            CurrInput := GetDiscountCode(REC."Transaction Code Type");
                    end;
                REC."Transaction Code Type"::ATHL:
                    begin
                        if GetATHLDiscount(REC, LineRec) <> 0 then
                            exit;
                        if CurrInput = '' then
                            CurrInput := GetDiscountCode(REC."Transaction Code Type");
                    end;
                REC."Transaction Code Type"::WHT1:
                    begin
                        if REC."WHT Applied Counter" > 0 then begin
                            exit;
                        end else begin
                            codPOSTrans.TotalPressed(false);
                            WHTPressed(REC, CurrInput, LineRec, TenderTypeCode);
                            exit;
                        end;
                    end;
                REC."Transaction Code Type"::VATW:
                    begin
                        if REC."VAT WHT Applied Counter" > 0 then begin
                            exit;
                        end else begin
                            codPOSTrans.TotalPressed(false);
                            VATWHTPressed(REC, CurrInput, LineRec, TenderTypeCode);
                            exit;
                        end;
                    end;
                REC."Transaction Code Type"::ZRWH:
                    begin
                        if REC."ZRWHT Applied Counter" > 0 then begin
                            exit;
                        end else begin
                            codPOSTrans.TotalPressed(false);
                            ZRWHTPressed(REC, CurrInput, LineRec, TenderTypeCode);
                            exit;
                        end;
                    end;
                REC."Transaction Code Type"::ZERO:
                    begin
                        if REC."Zero Rated Applied Counter" > 0 then begin
                            exit;
                        end else begin
                            codPOSTrans.TotalPressed(false);
                            ZeroPressed(REC, CurrInput, LineRec, TenderTypeCode);
                            exit;
                        end;
                    end;
            end;

            if CurrInput = '' then begin
                codPOSTrans.ErrorBeep(StrSubstNo('Kindly setup discount code %1 in global reference', CurrInput));
                exit;
            end else begin
                recLGlobaLRef.reset;
                recLGlobaLRef.SetRange("Entry Type", recLGlobaLRef."Entry Type"::"Discount Code");
                if not recLGlobaLRef.FindFirst() then begin
                    codPOSTrans.ErrorBeep(text90001);
                    exit;
                end;

                Evaluate(DiscountCode, CurrInput);
                CurrInput := '';

                recLGlobaLRef.Reset();
                recLGlobaLRef.SetRange("Entry Type", recLGlobaLRef."Entry Type"::"Discount Code");
                recLGlobaLRef.SetRange(Code, DiscountCode);
                if recLGlobaLRef.FindFirst() then begin
                    case recLGlobaLRef."Discount Type" of
                        recLGlobalRef."Discount Type"::SOLO, recLGlobaLRef."Discount Type"::ATHL:
                            begin
                                DiscPerItemlineAmPressed(REC);
                            end;
                        recLGlobalRef."Discount Type"::SRC:
                            begin
                                // IF NOT REC."Total Pressed" THEN
                                SeniorDiscPerPressed(REC, CurrInput, Format(GetDiscountSetup('SRC', REC)), false);
                            end;
                        recLGlobaLRef."Discount Type"::PWD:
                            begin
                                // IF NOT REC."Total Pressed" THEN
                                // PWDDiscPerPressed_(REC, CurrInput, Format(GetDiscountSetup('PWD', REC)), false);
                                PWDPerPressed(REC, CurrInput, Format(GetDiscountSetup('PWD', REC)), false);
                            end;
                        recLGlobaLRef."Discount Type"::NAAC, recLGlobaLRef."Discount Type"::MOV:
                            begin
                                MOVNAACPerItemlinePressed(REC);
                            end;

                    end
                end;
            end;
        end else begin
            codPOSTrans.ErrorBeep('(' + CurrInput + ') Discount Code does not exist!');
            exit;
        end;
    end;

    procedure WHTPressed(var POSTrans: Record "LSC POS Transaction"; var CurrInput: Text; var LineRec: Record "LSC POS Trans. Line"; var Tendertypecode: Code[20])
    var
        POSFuncProfile: Record "LSC POS Func. Profile";
        POSSESSION: Codeunit "LSC POS Session";
        StoreSetup: Record "LSC Store";
        recLPOSTransLine: Record "LSC POS Trans. Line";
        decLAmount: Decimal;
        decLVATPerc: Decimal;
        decLNetAmount: Decimal;
        decLNetOfDiscount: Decimal;
        recLItem: Record Item;
        decLVATBaseAmt: Decimal;
        decLWHTAmount: Decimal;
        decLVATWHTAmt: Decimal;
        decLVatNetAmount: Decimal;
        decLNonVatNetAmount: Decimal;
        decLWHTAmountTotal: Decimal;
        POSLines: Codeunit "LSC POS Trans. Lines";
        CustomerOrCardNo: Code[20];
    begin
        STATE_SALES := 'SALES';
        STATE_PAYMENT := 'PAYMENT';
        STATE_TENDOP := 'TENDOP';

        StoreSetup.GET(POSSESSION.StoreNo);
        if not PosFuncProfile.GET(POSSESSION.GetValue('LSFUNCPROFILE')) then
            PosFuncProfile.GET(StoreSetup."Functionality Profile");
        CalcTotals(POSTrans);
        codPOSTrans.TotalPressed(true);
        POSTrans."Amount Before" := Abs(RealBalance);
        if (POSFuncProfile."Withholding Tax Disc. %" <> 0) then begin
            POSTrans."WHT Disc. %" := POSFuncProfile."Withholding Tax Disc. %";
        end else begin
            POSTrans."WHT Disc. %" := 1;
        end;

        POSTrans.Modify();

        decLAmount := 0;
        recLPOSTransLine.Reset();
        recLPOSTransLine.SetRange("Receipt No.", POSTrans."Receipt No.");
        recLPOSTransLine.SetRange("Entry Type", recLPOSTransLine."Entry Type"::Item);
        recLPOSTransLine.SetRange("Entry Status", recLPOSTransLine."Entry Status"::" ");
        if recLPOSTransLine.FindFirst() then
            repeat
                if recLPOSTransLine."Org. Price Inc. VAT" = 0 then begin
                    recLPOSTransLine."Org. Price Inc. VAT" := recLPOSTransLine.Price;
                    recLPOSTransLine."Org. Price Exc. VAT" := recLPOSTransLine."Net Price";
                    recLPOSTransLine.Modify();
                end;

                if recLPOSTransLine."VAT %" = 0 then begin
                    if recLPOSTransLine."Price in Barcode" then begin
                        decLNetAmount := ((recLPOSTransLine.Price * recLPOSTransLine.Quantity) - recLPOSTransLine."Discount Amount" - recLPOSTransLine."Total Disc. Amount")
                    end else begin
                        if recLPOSTransLine."Org. Price Inc. VAT" <> 0 then begin
                            decLNetAmount := ((recLPOSTransLine."Org. Price Inc. VAT" * recLPOSTransLine.Quantity) - recLPOSTransLine."Discount Amount" - recLPOSTransLine."Total Disc. Amount")
                        end else begin
                            decLNetAmount := ((recLPOSTransLine.Price * recLPOSTransLine.Quantity) - recLPOSTransLine."Discount Amount" - recLPOSTransLine."Total Disc. Amount")
                        end;
                    end;
                    decLNonVatNetAmount := decLNonVatNetAmount + recLPOSTransLine.Amount;
                end else begin
                    decLVATPerc := 0;
                    decLVATPerc := (recLPOSTransLine."VAT %" / 100) + 1;

                    decLNetOfDiscount := 0;
                    if recLPOSTransLine."Price in Barcode" then
                        decLNetOfDiscount := ((recLPOSTransLine.Price * recLPOSTransLine.Quantity) - recLPOSTransLine."Discount Amount" - recLPOSTransLine."Total Disc. Amount")
                    else
                        decLNetOfDiscount := ((recLPOSTransLine."Org. Price Inc. VAT" * recLPOSTransLine.Quantity) - recLPOSTransLine."Discount Amount" - recLPOSTransLine."Total Disc. Amount");

                    decLNetAmount := 0;
                    decLNetAmount := (decLNetOfDiscount / decLVATPerc);
                    decLVATBaseAmt := decLVATBaseAmt + decLNetAmount;
                    decLVatNetAmount := decLVatNetAmount + recLPOSTransLine.Amount;
                end;

                // if POSFuncProfile."Withholding Tax Disc. %" <> 0 then begin
                //     decLNetAmount := decLNetAmount * (POSFuncProfile."Withholding Tax Disc. %" / 100)
                // end else
                //     decLNetAmount := decLNetAmount * (1 / 100);

                //decLNetAmount := decLNetAmount * (POSFuncProfile."Withholding Tax Disc. %" / 100);

                decLWHTAmount := decLWHTAmount + decLNetAmount;
            until recLPOSTransLine.Next() = 0;

        if POSFuncProfile."Withholding Tax Disc. %" <> 0 then begin
            decLWHTAmountTotal := ((decLVatNetAmount / 1.12) + decLNonVatNetAmount) * (POSFuncProfile."Withholding Tax Disc. %" / 100);
        end else
            decLWHTAmountTotal := ((decLVatNetAmount / 1.12) + decLNonVatNetAmount) * (1 / 100);
        //decLWHTAmountTotal := ((decLVatNetAmount / 1.12) + decLNonVatNetAmount) * (POSFuncProfile."Withholding Tax Disc. %" / 100);


        POSTrans."WHT Amount" := Round(decLWHTAmountTotal, 0.01);
        POSTrans."WHT Applied Counter" := POSTrans."WHT Applied Counter" + 1;
        POSTrans.Modify();

        codPOSTrans.SetPOSState(STATE_PAYMENT);
        codPOSTrans.SetFunctionMode(STATE_PAYMENT);

        Evaluate(CurrInput, Format(POSTrans."WHT Amount"));
        POSLines.GetCurrentLine(LineRec);

        if Tendertypecode = '27' then begin
            if POSTrans."Customer No." <> '' then begin
                CurrInput := '';
                Clear(recLPOSTransLine);
                recLPOSTransLine."Receipt No." := POSTrans."Receipt No.";
                recLPOSTransLine.Number := Tendertypecode;
                recLPOSTransLine."Line No." := recLPOSTransLine.GetNextLineNo2();
                recLPOSTransLine."Entry Type" := recLPOSTransLine."Entry Type"::Payment;
                recLPOSTransLine.Description := 'WHT Amount';
                recLPOSTransLine."Value[1]" := 'WHT Amount';
                recLPOSTransLine."Value[2]" := Format(POSTrans."WHT Amount");
                recLPOSTransLine."Value[3]" := '';
                recLPOSTransLine."Store No." := POSTrans."Store No.";
                recLPOSTransLine."POS Terminal No." := POSTrans."POS Terminal No.";
                recLPOSTransLine.Amount := POSTrans."WHT Amount";
                recLPOSTransLine.Quantity := 1;
                recLPOSTransLine."Parent Line" := recLPOSTransLine."Line No.";
                recLPOSTransLine."Created by Staff ID" := POSSESSION.StaffID();
                recLPOSTransLine."Lines where Line is Parent" := 1;
                recLPOSTransLine.Insert();
            end;
        end;
        /*
                codPOSTrans.SetPOSState(STATE_SALES);
                codPOSTrans.SetFunctionMode('ITEM');
                codPOSTrans.SelectDefaultMenu();
                codPOSTrans.CalcTotals();*/
        Message('WHT Applied');
    end;

    procedure ZRWHTPressed(var POSTrans: Record "LSC POS Transaction"; var CurrInput: Text; var LineRec: Record "LSC POS Trans. Line"; var Tendertypecode: Code[20])
    var
        POSFuncProfile: Record "LSC POS Func. Profile";
        POSSESSION: Codeunit "LSC POS Session";
        StoreSetup: Record "LSC Store";
        recLPOSTransLine: Record "LSC POS Trans. Line";
        decLAmount: Decimal;
        decLVATPerc: Decimal;
        decLNetAmount: Decimal;
        decLNetOfDiscount: Decimal;
        recLItem: Record Item;
        decLVATBaseAmt: Decimal;
        decLWHTAmount: Decimal;
        decLVATWHTAmt: Decimal;
        decLVatNetAmount: Decimal;
        decLNonVatNetAmount: Decimal;
        decLWHTAmountTotal, decLZRAmountTotal : Decimal;
        POSLines: Codeunit "LSC POS Trans. Lines";
        CustomerOrCardNo: Code[20];
    begin
        STATE_SALES := 'SALES';
        STATE_PAYMENT := 'PAYMENT';
        STATE_TENDOP := 'TENDOP';

        StoreSetup.GET(POSSESSION.StoreNo);
        if not PosFuncProfile.GET(POSSESSION.GetValue('LSFUNCPROFILE')) then
            PosFuncProfile.GET(StoreSetup."Functionality Profile");
        CalcTotals(POSTrans);
        codPOSTrans.TotalPressed(true);
        POSTrans."Amount Before" := Abs(RealBalance);

        if (POSFuncProfile."Withholding Tax Disc. %" <> 0) then begin
            POSTrans."WHT Disc. %" := POSFuncProfile."Withholding Tax Disc. %";
        end else begin
            POSTrans."WHT Disc. %" := 1;
        end;

        POSTrans.Modify();

        decLAmount := 0;
        recLPOSTransLine.Reset();
        recLPOSTransLine.SetRange("Receipt No.", POSTrans."Receipt No.");
        recLPOSTransLine.SetRange("Entry Type", recLPOSTransLine."Entry Type"::Item);
        recLPOSTransLine.SetRange("Entry Status", recLPOSTransLine."Entry Status"::" ");
        if recLPOSTransLine.FindFirst() then
            repeat
                if recLPOSTransLine."Org. Price Inc. VAT" = 0 then begin
                    recLPOSTransLine."Org. Price Inc. VAT" := recLPOSTransLine.Price;
                    recLPOSTransLine."Org. Price Exc. VAT" := recLPOSTransLine."Net Price";
                    recLPOSTransLine.Modify();
                end;

                if recLPOSTransLine."VAT %" = 0 then begin
                    if recLPOSTransLine."Price in Barcode" then begin
                        decLNetAmount := ((recLPOSTransLine.Price * recLPOSTransLine.Quantity) - recLPOSTransLine."Discount Amount" - recLPOSTransLine."Total Disc. Amount")
                    end else begin
                        if recLPOSTransLine."Org. Price Inc. VAT" <> 0 then begin
                            decLNetAmount := ((recLPOSTransLine."Org. Price Inc. VAT" * recLPOSTransLine.Quantity) - recLPOSTransLine."Discount Amount" - recLPOSTransLine."Total Disc. Amount")
                        end else begin
                            decLNetAmount := ((recLPOSTransLine.Price * recLPOSTransLine.Quantity) - recLPOSTransLine."Discount Amount" - recLPOSTransLine."Total Disc. Amount")
                        end;
                    end;
                    decLNonVatNetAmount := decLNonVatNetAmount + recLPOSTransLine.Amount;
                end else begin
                    decLVATPerc := 0;
                    decLVATPerc := (recLPOSTransLine."VAT %" / 100) + 1;

                    decLNetOfDiscount := 0;
                    if recLPOSTransLine."Price in Barcode" then
                        decLNetOfDiscount := ((recLPOSTransLine.Price * recLPOSTransLine.Quantity) - recLPOSTransLine."Discount Amount" - recLPOSTransLine."Total Disc. Amount")
                    else
                        decLNetOfDiscount := ((recLPOSTransLine."Org. Price Inc. VAT" * recLPOSTransLine.Quantity) - recLPOSTransLine."Discount Amount" - recLPOSTransLine."Total Disc. Amount");

                    decLNetAmount := 0;
                    decLNetAmount := (decLNetOfDiscount / decLVATPerc);
                    decLVATBaseAmt := decLVATBaseAmt + decLNetAmount;
                    decLVatNetAmount := decLVatNetAmount + recLPOSTransLine.Amount;
                end;

                // if POSFuncProfile."Withholding Tax Disc. %" <> 0 then begin
                //     decLNetAmount := decLNetAmount * (POSFuncProfile."Withholding Tax Disc. %" / 100)
                // end else
                //     decLNetAmount := decLNetAmount * (1 / 100);
                if POSFuncProfile."Withholding Tax Disc. %" <> 0 then
                    decLNetAmount := decLNetAmount * (POSFuncProfile."Withholding Tax Disc. %" / 100)
                else
                    decLNetAmount := decLNetAmount * (1 / 100);
                decLWHTAmount := decLWHTAmount + decLNetAmount;
            until recLPOSTransLine.Next() = 0;

        // if POSFuncProfile."Withholding Tax Disc. %" <> 0 then begin
        //     decLWHTAmountTotal := ((decLVatNetAmount / 1.12) + decLNonVatNetAmount) * (POSFuncProfile."Withholding Tax Disc. %" / 100);
        // end else
        //     decLWHTAmountTotal := ((decLVatNetAmount / 1.12) + decLNonVatNetAmount) * (1 / 100);
        if POSFuncProfile."Withholding Tax Disc. %" <> 0 then
            decLWHTAmountTotal := ((decLVatNetAmount / 1.12) + decLNonVatNetAmount) * (POSFuncProfile."Withholding Tax Disc. %" / 100)
        else
            decLWHTAmountTotal := ((decLVatNetAmount / 1.12) + decLNonVatNetAmount) * (1 / 100);

        recLPOSTransLine.Reset();
        recLPOSTransLine.SetRange("Receipt No.", POSTrans."Receipt No.");
        recLPOSTransLine.SetRange("VAT Code", 'VZ');
        recLPOSTransLine.SetRange("Entry Status", recLPOSTransLine."Entry Status"::" ");
        if recLPOSTransLine.FindFirst() then
            repeat
                decLZRAmountTotal += recLPOSTransLine.Quantity * (recLPOSTransLine."Org. Price Inc. VAT" - recLPOSTransLine."Org. Price Exc. VAT");
            until recLPOSTransLine.next() = 0;

        POSTrans."Zero Rated Amount" := decLZRAmountTotal;
        if POSTrans.modify then;

        POSTrans."WHT Amount" := Round(decLWHTAmountTotal, 0.01);
        POSTrans."ZRWHT Amount" := Round(decLZRAmountTotal, 0.01);
        POSTrans."ZRWHT Applied Counter" := POSTrans."ZRWHT Applied Counter" + 1;
        POSTrans.Modify();

        codPOSTrans.SetPOSState(STATE_PAYMENT);
        codPOSTrans.SetFunctionMode(STATE_PAYMENT);

        Evaluate(CurrInput, Format(POSTrans."ZRWHT Amount"));
        POSLines.GetCurrentLine(LineRec);

        if Tendertypecode = '30' then begin
            if POSTrans."Customer No." <> '' then begin
                CurrInput := '';
                CLEAR(recLPOSTransLine);
                recLPOSTransLine.Init();
                recLPOSTransLine."Receipt No." := POSTrans."Receipt No.";
                recLPOSTransLine.Number := '27';
                recLPOSTransLine."Line No." := recLPOSTransLine.GetNextLineNo2;
                recLPOSTransLine."Entry Type" := recLPOSTransLine."Entry Type"::Payment;
                recLPOSTransLine.Description := 'WHT Amount';
                recLPOSTransLine."Value[1]" := 'WHT Amount';
                recLPOSTransLine."Value[2]" := POSTrans."Customer No.";
                recLPOSTransLine."Value[3]" := '';
                recLPOSTransLine."Store No." := POSTrans."Store No.";
                recLPOSTransLine."POS Terminal No." := POSTrans."POS Terminal No.";
                recLPOSTransLine.Amount := POSTrans."WHT Amount";
                recLPOSTransLine.Quantity := 1;
                recLPOSTransLine.INSERT;

                CurrInput := '';
                Clear(recLPOSTransLine);
                recLPOSTransLine."Receipt No." := POSTrans."Receipt No.";
                recLPOSTransLine.Number := Tendertypecode;
                recLPOSTransLine."Line No." := recLPOSTransLine.GetNextLineNo2();
                recLPOSTransLine."Entry Type" := recLPOSTransLine."Entry Type"::FreeText;
                recLPOSTransLine.Description := 'Zero Rated Amount';
                recLPOSTransLine."Value[1]" := 'Zero Rated Amount';
                recLPOSTransLine."Value[2]" := POSTrans."Customer No.";
                recLPOSTransLine."Value[3]" := '';
                recLPOSTransLine."Store No." := POSTrans."Store No.";
                recLPOSTransLine."POS Terminal No." := POSTrans."POS Terminal No.";
                recLPOSTransLine.Amount := POSTrans."ZRWHT Amount";
                recLPOSTransLine.Quantity := 1;
                recLPOSTransLine.Insert();
            end;
        end;

        codPOSTrans.SetPOSState(STATE_SALES);
        codPOSTrans.SetFunctionMode('ITEM');
        codPOSTrans.SelectDefaultMenu();
        codPOSTrans.CalcTotals();
        codPOSTrans.PosMessage('ZRWHT Applied');
    end;

    procedure ZEROPressed(var POSTrans: Record "LSC POS Transaction"; var CurrInput: Text; var LineRec: Record "LSC POS Trans. Line"; var Tendertypecode: Code[20])
    var
        POSFuncProfile: Record "LSC POS Func. Profile";
        POSSESSION: Codeunit "LSC POS Session";
        StoreSetup: Record "LSC Store";
        recLPOSTransLine: Record "LSC POS Trans. Line";
        decLAmount: Decimal;
        decLVATPerc: Decimal;
        decLNetAmount: Decimal;
        decLNetOfDiscount: Decimal;
        recLItem: Record Item;
        decLVATBaseAmt: Decimal;
        decLWHTAmount: Decimal;
        decLVATWHTAmt: Decimal;
        decLVatNetAmount: Decimal;
        decLNonVatNetAmount: Decimal;
        decLWHTAmountTotal: Decimal;
        POSLines: Codeunit "LSC POS Trans. Lines";
        CustomerOrCardNo: Code[20];
        decVAtamout: decimal;
    begin
        STATE_SALES := 'SALES';
        STATE_PAYMENT := 'PAYMENT';
        STATE_TENDOP := 'TENDOP';

        StoreSetup.GET(POSSESSION.StoreNo);
        if not PosFuncProfile.GET(POSSESSION.GetValue('LSFUNCPROFILE')) then
            PosFuncProfile.GET(StoreSetup."Functionality Profile");
        CalcTotals(POSTrans);
        codPOSTrans.TotalPressed(true);

        codPOSTrans.SetPOSState(STATE_PAYMENT);
        codPOSTrans.SetFunctionMode(STATE_PAYMENT);


        recLPOSTransLine.Reset();
        recLPOSTransLine.SetRange("Receipt No.", POSTrans."Receipt No.");
        recLPOSTransLine.SetRange("VAT Code", 'VZ');
        recLPOSTransLine.SetRange("Entry Status", recLPOSTransLine."Entry Status"::" ");
        if recLPOSTransLine.FindFirst() then
            repeat
                decLAmount += recLPOSTransLine.Quantity * (recLPOSTransLine."Org. Price Inc. VAT" - recLPOSTransLine."Org. Price Exc. VAT");
            until recLPOSTransLine.next() = 0;

        POSTrans."Zero Rated Amount" := decLAmount;
        if POSTrans.modify then;

        if POSTrans."Customer No." <> '' then begin
            CurrInput := '';
            Clear(recLPOSTransLine);
            recLPOSTransLine."Receipt No." := POSTrans."Receipt No.";
            //recLPOSTransLine.Number := Tendertypecode;
            recLPOSTransLine."Line No." := recLPOSTransLine.GetNextLineNo2();
            recLPOSTransLine."Entry Type" := recLPOSTransLine."Entry Type"::FreeText;
            recLPOSTransLine.Description := 'Zero Rated Amount';
            recLPOSTransLine."Value[1]" := 'Zero Rated Amount';
            recLPOSTransLine."Value[2]" := POSTrans."Customer No.";
            recLPOSTransLine."Value[3]" := '';
            recLPOSTransLine."Store No." := POSTrans."Store No.";
            recLPOSTransLine."POS Terminal No." := POSTrans."POS Terminal No.";
            recLPOSTransLine.Amount := POSTrans."Zero Rated Amount";
            recLPOSTransLine.Quantity := 1;
            recLPOSTransLine."VAT Code" := '';
            recLPOSTransLine.Insert();
        end;
        codPOSTrans.SetPOSState(STATE_SALES);
        codPOSTrans.SetFunctionMode('ITEM');
        codPOSTrans.SelectDefaultMenu();
        codPOSTrans.CalcTotals();
        //codPOSTrans.PosMessage('ZRWHT Applied');
    end;

    procedure VATWHTPressed(var POSTrans: Record "LSC POS Transaction"; var CurrInput: Text; var LineRec: Record "LSC POS Trans. Line"; var Tendertypecode: Code[20])
    var
        POSFuncProfile: Record "LSC POS Func. Profile";
        POSSESSION: Codeunit "LSC POS Session";
        StoreSetup: Record "LSC Store";
        recLPOSTransLine: Record "LSC POS Trans. Line";
        decLAmount: Decimal;
        decLVATPerc: Decimal;
        decLNetAmount: Decimal;
        decLNetOfDiscount: Decimal;
        recLItem: Record Item;
        decLVATBaseAmt: Decimal;
        decLWHTAmount: Decimal;
        decLVATWHTAmt: Decimal;
        decLVatNetAmount: Decimal;
        decLNonVatNetAmount: Decimal;
        decLWHTAmountTotal: Decimal;
        POSLines: Codeunit "LSC POS Trans. Lines";
        CustomerOrCardNo: Code[20];
    begin
        STATE_SALES := 'SALES';
        STATE_PAYMENT := 'PAYMENT';
        STATE_TENDOP := 'TENDOP';

        StoreSetup.GET(POSSESSION.StoreNo);
        if not PosFuncProfile.GET(POSSESSION.GetValue('LSFUNCPROFILE')) then
            PosFuncProfile.GET(StoreSetup."Functionality Profile");

        CalcTotals(POSTrans);
        codPOSTrans.TotalPressed(true);
        POSTrans."Amount Before" := Abs(RealBalance);
        POSTrans."VAT WHT Applied Counter" := POSTrans."VAT WHT Applied Counter" + 1;

        // if (POSFuncProfile."Withholding Tax Disc. %" <> 0) then begin
        //     POSTrans."Withholding Tax Disc. %" := POSFuncProfile."Withholding Tax Disc. %";
        // end else begin
        //     POSTrans."Withholding Tax Disc. %" := 5;
        // end;
        if POSFuncProfile."Withholding Tax Disc. %" <> 0 then
            POSTrans."Withholding Tax Disc. %" := POSFuncProfile."Withholding Tax Disc. %"
        else
            POSTrans."Withholding Tax Disc. %" := 1;
        POSTrans."VAT Withholding" := POSFuncProfile."VAT Withholding Tax Disc. %";
        POSTrans.Modify();

        decLAmount := 0;
        decLWHTAmount := 0;
        decLVATBaseAmt := 0;
        decLVATWHTAmt := 0;
        recLPOSTransLine.RESET;
        recLPOSTransLine.SETRANGE("Receipt No.", POSTrans."Receipt No.");
        recLPOSTransLine.SETRANGE("Entry Type", recLPOSTransLine."Entry Type"::Item);
        recLPOSTransLine.SETRANGE("Entry Status", recLPOSTransLine."Entry Status"::" ");
        if recLPOSTransLine.FINDFIRST THEN
            REPEAT

                if recLPOSTransLine."Org. Price Inc. VAT" = 0 then begin
                    recLPOSTransLine."Org. Price Inc. VAT" := recLPOSTransLine.Price;
                    recLPOSTransLine."Org. Price Exc. VAT" := recLPOSTransLine."Net Price";
                    recLPOSTransLine.MODifY;
                end;

                if (recLPOSTransLine."VAT %" = 0) then begin
                    if recLPOSTransLine."Price in Barcode" then begin
                        decLNetAmount := ((recLPOSTransLine.Price * recLPOSTransLine.Quantity)
                                                 - recLPOSTransLine."Discount Amount" - recLPOSTransLine."Total Disc. Amount")
                    end else BEGIN
                        if (recLPOSTransLine."Org. Price Inc. VAT" <> 0) then begin
                            decLNetAmount := ((recLPOSTransLine."Org. Price Inc. VAT" * recLPOSTransLine.Quantity)
                                            - recLPOSTransLine."Discount Amount" - recLPOSTransLine."Total Disc. Amount");
                        end else BEGIN
                            decLNetAmount := ((recLPOSTransLine.Price * recLPOSTransLine.Quantity)
                                            - recLPOSTransLine."Discount Amount" - recLPOSTransLine."Total Disc. Amount");
                        end;
                    end;
                    //decLVATBaseAmt := decLVATBaseAmt + decLNetAmount;
                    decLNonVatNetAmount := decLNonVatNetAmount + recLPOSTransLine.Amount;
                end else BEGIN
                    decLVATPerc := 0;
                    decLVATPerc := (recLPOSTransLine."VAT %" / 100) + 1;

                    decLNetOfDiscount := 0;
                    if recLPOSTransLine."Price in Barcode" THEN
                        decLNetOfDiscount := ((recLPOSTransLine.Price * recLPOSTransLine.Quantity)
                                           - recLPOSTransLine."Discount Amount" - recLPOSTransLine."Total Disc. Amount")
                    ELSE
                        decLNetOfDiscount := ((recLPOSTransLine."Org. Price Inc. VAT" * recLPOSTransLine.Quantity)
                                           - recLPOSTransLine."Discount Amount" - recLPOSTransLine."Total Disc. Amount");

                    decLNetAmount := 0;
                    decLNetAmount := (decLNetOfDiscount / decLVATPerc);

                    decLVATBaseAmt := decLVATBaseAmt + decLNetAmount;
                end;


            // if (PosFuncProfile."Withholding Tax Disc. %" <> 0) then begin
            //     decLNetAmount := decLNetAmount * (PosFuncProfile."Withholding Tax Disc. %" / 100);
            // end else
            //     decLNetAmount := decLNetAmount * (1 / 100);
            // decLWHTAmount := decLNetAmount * (PosFuncProfile."Withholding Tax Disc. %" / 100);
            // decLNetAmount := decLNetAmount * (PosFuncProfile."VAT Withholding Tax Disc. %" / 100);

            // decLWHTAmount := decLWHTAmount + decLNetAmount;

            UNTIL recLPOSTransLine.NEXT = 0;

        if (PosFuncProfile."VAT Withholding Tax Disc. %" <> 0) then begin
            decLVATWHTAmt := decLVATBaseAmt * (PosFuncProfile."VAT Withholding Tax Disc. %" / 100);
        end else
            decLVATWHTAmt := decLVATBaseAmt * (5 / 100);

        if POSFuncProfile."Withholding Tax Disc. %" <> 0 then begin
            decLWHTAmountTotal := (decLVATBaseAmt + decLNonVatNetAmount) * (POSFuncProfile."Withholding Tax Disc. %" / 100);
        end else
            decLWHTAmountTotal := (decLVATBaseAmt + decLNonVatNetAmount) * (1 / 100);

        POSTrans."WHT Amount" := ROUND(decLWHTAmountTotal, 0.01, '=');
        POSTrans."VAT Withholding" := ROUND(decLVATWHTAmt, 0.01, '=');

        decLAmount := POSTrans."WHT Amount" + POSTrans."VAT Withholding";

        POSTrans.Modify();

        codPOSTrans.SetPOSState(STATE_PAYMENT);
        codPOSTrans.SetFunctionMode('PAYMENT');

        //EVALUATE(CurrInput, FORMAT(POSTrans."WHT Amount"));

        EVALUATE(CurrInput, FORMAT(POSTrans."VAT Withholding"));
        //TenderKeyPressed('28'); // VAT Withholding Tender


        if (Tendertypecode = '28') then begin // vatWHT
            if POSTrans."Customer No." <> '' then begin

                CurrInput := '';
                CLEAR(recLPOSTransLine);
                recLPOSTransLine.Init();
                recLPOSTransLine."Receipt No." := POSTrans."Receipt No.";
                recLPOSTransLine.Number := '27';
                recLPOSTransLine."Line No." := recLPOSTransLine.GetNextLineNo2;
                recLPOSTransLine."Entry Type" := recLPOSTransLine."Entry Type"::Payment;
                recLPOSTransLine.Description := 'WHT Amount';
                recLPOSTransLine."Value[1]" := 'WHT Amount';
                recLPOSTransLine."Value[2]" := POSTrans."Customer No.";
                recLPOSTransLine."Value[3]" := '';
                recLPOSTransLine."Store No." := POSTrans."Store No.";
                recLPOSTransLine."POS Terminal No." := POSTrans."POS Terminal No.";
                recLPOSTransLine.Amount := POSTrans."WHT Amount";
                recLPOSTransLine.Quantity := 1;
                recLPOSTransLine.INSERT;

                CurrInput := '';
                CLEAR(recLPOSTransLine);
                recLPOSTransLine.Init();
                recLPOSTransLine."Receipt No." := POSTrans."Receipt No.";
                recLPOSTransLine.Number := TenderTypeCode;
                recLPOSTransLine."Line No." := recLPOSTransLine.GetNextLineNo2;
                recLPOSTransLine."Entry Type" := recLPOSTransLine."Entry Type"::Payment;
                recLPOSTransLine.Description := 'VAT Withholding';
                recLPOSTransLine."Value[1]" := 'VAT Withholding';
                recLPOSTransLine."Value[2]" := POSTrans."Customer No.";
                recLPOSTransLine."Value[3]" := '';
                recLPOSTransLine."Store No." := POSTrans."Store No.";
                recLPOSTransLine."POS Terminal No." := POSTrans."POS Terminal No.";
                recLPOSTransLine.Amount := POSTrans."VAT Withholding";
                recLPOSTransLine.Quantity := 1;
                recLPOSTransLine.INSERT;
            end;
        end;

        POSLINES.GetCurrentLine(LineRec);

        codPOSTrans.SetPOSState(STATE_SALES);
        codPOSTrans.SetFunctionMode('ITEM');
        codPOSTrans.SelectDefaultMenu;

        CalcTotals(POSTrans);
        codPOSTrans.CalcTotals();
        codPOSTrans.SetInfoTextDescription('VAT Withholding Applied', '');
        codPOSTRans.PosMessage('VAT Withholding Applied');
    end;

    procedure VATExemptLine(pLineRec: Record "LSC POS Trans. Line")
    var
        recLPOSVAT: Record "LSC POS VAT Code";
        recLItem: Record Item;
        decLVATAdj: Decimal;
        decLOrgPrice: Decimal;
        decLPrice: Decimal;
        VATAmount: Decimal;
        POSFunc: Record "LSC POS Func. Profile";
        POSSession: Codeunit "LSC POS Session";
        recLstore: Record "LSC Store";
    begin
        if not recLStore.Get(POSSession.StoreNo()) then
            exit;
        if not POSFunc.Get(reclstore."Functionality Profile") then
            exit;

        recLPOSVAT.RESET;
        recLPOSVAT.SETRANGE(recLPOSVAT."POS Command", 'VATEXEMPT');
        if recLPOSVAT.FINDFIRST then begin
            pLineRec.SETRANGE(pLineRec."VAT Code", '<>%1', recLPOSVAT."VAT Code");
            if pLineRec.FINDFIRST THEN
                REPEAT
                    if recLItem.GET(pLineRec.Number) then begin
                        if recLItem."Discount %" > 0 then begin
                            //if (recLItem."Allow SRC Discount" AND (POSFunc."SRC Retail Disc. %" = 20)) OR (recLItem."Allow PWD Discount" AND (POSFunc."PWD Retail Disc. %" = 20)) then begin
                            if NOT (recLItem."VAT Prod. Posting Group" = 'NO VAT') then begin
                                CLEAR(VATAmount);
                                CLEAR(decLVATAdj);
                                CLEAR(decLOrgPrice);
                                decLOrgPrice := pLineRec.Price;
                                decLPrice := ROUND(decLOrgPrice / 1.12, 0.0001);
                                VATAmount := decLOrgPrice - decLPrice;
                                pLineRec.VALIDATE(pLineRec.Price, decLPrice);
                                pLineRec."VAT Adj." := ROUND(VATAmount * pLineRec.Quantity, 0.01);
                                pLineRec."VAT Code" := recLPOSVAT."VAT Code";
                                pLineRec."VAT %" := recLPOSVAT."VAT %";
                                pLineRec."Vat Prod. Posting Group" := recLPOSVAT."VAT Bus. Posting Group";
                                pLineRec.MODifY;
                            end;
                        end;
                    end;
                UNTIL pLineRec.NEXT = 0;
        end;
    end;

    procedure VATExemptPressedFood(parReceiptNo: Code[20]): Boolean
    var
        recLPOSVATCodes: Record "LSC POS VAT Code";
        recLPOSTransLine: Record "LSC POS Trans. Line";
        recLPOSTransaction: Record "LSC POS Transaction";
        decLVATAdj: Decimal;
        decLOrgPrice: Decimal;
        POSView: Codeunit "LSC POS View";
        item: record item;
    begin
        if (parReceiptNo = '') THEN
            EXIT(FALSE);

        recLPOSVATCodes.RESET;
        recLPOSVATCodes.SETRANGE("POS Command", 'VATEXEMPT');
        if recLPOSVATCodes.FindFirst() then begin
            recLPOSVATCodes.TESTFIELD("VAT Bus. Posting Group");
            recLPOSTransLine.RESET;
            recLPOSTransLine.SETFILTER("VAT Code", '<>%1', recLPOSVATCodes."VAT Code");
            recLPOSTransLine.SETRANGE("Receipt No.", parReceiptNo);
            if recLPOSTransLine.FindFirst() THEN
                REPEAT
                    item.Reset();
                    item.SetRange("No.", recLPOSTransLine.Number);
                    item.SetRange("Food Item", true);
                    if item.FindFirst() then begin
                        CLEAR(decLVATAdj);
                        CLEAR(decLOrgPrice);
                        recLPOSTransLine."VAT Code" := recLPOSVATCodes."VAT Code";
                        recLPOSTransLine."VAT %" := recLPOSVATCodes."VAT %";

                        decLOrgPrice := recLPOSTransLine.Price;
                        recLPOSTransLine."Vat Prod. Posting Group" := recLPOSVATCodes."VAT Bus. Posting Group";
                        recLPOSTransLine.VALIDATE(Price, recLPOSTransLine."Org. Price Exc. VAT");

                        decLVATAdj := decLOrgPrice - recLPOSTransLine.Price;
                        recLPOSTransLine."VAT Adj." := decLVATAdj;

                        recLPOSTransLine.Modify();
                    end;
                UNTIL recLPOSTransLine.NEXT = 0;
            EXIT(TRUE);
        end else BEGIN
            POSView.ErrorBeep('POS Command VATExempt on VAT Codes does not exist');
            EXIT(FALSE);
        end;
    end;

    procedure VATExemptPressedSOLO(parReceiptNo: Code[20]): Boolean
    var
        recLPOSVATCodes: Record "LSC POS VAT Code";
        recLPOSTransLine: Record "LSC POS Trans. Line";
        recLPOSTransaction: Record "LSC POS Transaction";
        decLVATAdj: Decimal;
        decLOrgPrice: Decimal;
        POSView: Codeunit "LSC POS View";
        item: record item;
    begin
        if (parReceiptNo = '') THEN
            EXIT(FALSE);

        recLPOSVATCodes.RESET;
        recLPOSVATCodes.SETRANGE("POS Command", 'VATEXEMPT');
        if recLPOSVATCodes.FindFirst() then begin
            recLPOSVATCodes.TESTFIELD("VAT Bus. Posting Group");
            recLPOSTransLine.RESET;
            recLPOSTransLine.SETFILTER("VAT Code", '<>%1', recLPOSVATCodes."VAT Code");
            recLPOSTransLine.SETRANGE("Receipt No.", parReceiptNo);
            if recLPOSTransLine.FindFirst() THEN
                REPEAT
                    item.Reset();
                    item.SetRange("No.", recLPOSTransLine.Number);
                    item.SetFilter("SOLO Discount %", '<>0');
                    if item.FindFirst() then begin
                        CLEAR(decLVATAdj);
                        CLEAR(decLOrgPrice);
                        recLPOSTransLine."VAT Code" := recLPOSVATCodes."VAT Code";
                        recLPOSTransLine."VAT %" := recLPOSVATCodes."VAT %";

                        decLOrgPrice := recLPOSTransLine.Price;
                        recLPOSTransLine."Vat Prod. Posting Group" := recLPOSVATCodes."VAT Bus. Posting Group";
                        recLPOSTransLine.VALIDATE(Price, recLPOSTransLine."Org. Price Exc. VAT");

                        decLVATAdj := decLOrgPrice - recLPOSTransLine.Price;
                        recLPOSTransLine."VAT Adj." := decLVATAdj;

                        recLPOSTransLine.Modify();
                    end;
                UNTIL recLPOSTransLine.NEXT = 0;
            EXIT(TRUE);
        end else BEGIN
            POSView.ErrorBeep('POS Command VATExempt on VAT Codes does not exist');
            EXIT(FALSE);
        end;
    end;

    procedure VATExemptPressedNAAC(parReceiptNo: Code[20]): Boolean
    var
        recLPOSVATCodes: Record "LSC POS VAT Code";
        recLPOSTransLine: Record "LSC POS Trans. Line";
        recLPOSTransaction: Record "LSC POS Transaction";
        decLVATAdj: Decimal;
        decLOrgPrice: Decimal;
        POSView: Codeunit "LSC POS View";
        item: record item;
    begin
        if (parReceiptNo = '') THEN
            EXIT(FALSE);

        recLPOSVATCodes.RESET;
        recLPOSVATCodes.SETRANGE("POS Command", 'VATEXEMPT');
        if recLPOSVATCodes.FindFirst() then begin
            recLPOSVATCodes.TESTFIELD("VAT Bus. Posting Group");
            recLPOSTransLine.RESET;
            recLPOSTransLine.SETFILTER("VAT Code", '<>%1', recLPOSVATCodes."VAT Code");
            recLPOSTransLine.SETRANGE("Receipt No.", parReceiptNo);
            if recLPOSTransLine.FindFirst() THEN
                REPEAT
                    item.Reset();
                    item.SetRange("No.", recLPOSTransLine.Number);
                    item.SetFilter("NAAC Discount %", '<>0');
                    if item.FindFirst() then begin
                        CLEAR(decLVATAdj);
                        CLEAR(decLOrgPrice);
                        recLPOSTransLine."VAT Code" := recLPOSVATCodes."VAT Code";
                        recLPOSTransLine."VAT %" := recLPOSVATCodes."VAT %";

                        decLOrgPrice := recLPOSTransLine.Price;
                        recLPOSTransLine."Vat Prod. Posting Group" := recLPOSVATCodes."VAT Bus. Posting Group";
                        recLPOSTransLine.VALIDATE(Price, recLPOSTransLine."Org. Price Exc. VAT");

                        decLVATAdj := decLOrgPrice - recLPOSTransLine.Price;
                        recLPOSTransLine."VAT Adj." := decLVATAdj;

                        recLPOSTransLine.Modify();
                    end;
                UNTIL recLPOSTransLine.NEXT = 0;
            EXIT(TRUE);
        end else BEGIN
            POSView.ErrorBeep('POS Command VATExempt on VAT Codes does not exist');
            EXIT(FALSE);
        end;
    end;

    procedure VATExemptPressedMOV(parReceiptNo: Code[20]): Boolean
    var
        recLPOSVATCodes: Record "LSC POS VAT Code";
        recLPOSTransLine: Record "LSC POS Trans. Line";
        recLPOSTransaction: Record "LSC POS Transaction";
        decLVATAdj: Decimal;
        decLOrgPrice: Decimal;
        POSView: Codeunit "LSC POS View";
        item: record item;
    begin
        if (parReceiptNo = '') THEN
            EXIT(FALSE);

        recLPOSVATCodes.RESET;
        recLPOSVATCodes.SETRANGE("POS Command", 'VATEXEMPT');
        if recLPOSVATCodes.FindFirst() then begin
            recLPOSVATCodes.TESTFIELD("VAT Bus. Posting Group");
            recLPOSTransLine.RESET;
            recLPOSTransLine.SETFILTER("VAT Code", '<>%1', recLPOSVATCodes."VAT Code");
            recLPOSTransLine.SETRANGE("Receipt No.", parReceiptNo);
            if recLPOSTransLine.FindFirst() THEN
                REPEAT
                    item.Reset();
                    item.SetRange("No.", recLPOSTransLine.Number);
                    item.SetFilter("MOV Discount %", '<>0');
                    if item.FindFirst() then begin
                        CLEAR(decLVATAdj);
                        CLEAR(decLOrgPrice);
                        recLPOSTransLine."VAT Code" := recLPOSVATCodes."VAT Code";
                        recLPOSTransLine."VAT %" := recLPOSVATCodes."VAT %";

                        decLOrgPrice := recLPOSTransLine.Price;
                        recLPOSTransLine."Vat Prod. Posting Group" := recLPOSVATCodes."VAT Bus. Posting Group";
                        recLPOSTransLine.VALIDATE(Price, recLPOSTransLine."Org. Price Exc. VAT");

                        decLVATAdj := decLOrgPrice - recLPOSTransLine.Price;
                        recLPOSTransLine."VAT Adj." := decLVATAdj;

                        recLPOSTransLine.Modify();
                    end;
                UNTIL recLPOSTransLine.NEXT = 0;
            EXIT(TRUE);
        end else BEGIN
            POSView.ErrorBeep('POS Command VATExempt on VAT Codes does not exist');
            EXIT(FALSE);
        end;
    end;

    procedure DiscPerItemlineAmPressed(var REC: Record "LSC POS Transaction")
    var
        Dec: Decimal;
        POSFuncProfile: Record "LSC POS Func. Profile";
        LineRec: Record "LSC POS Trans. Line";
        recLPOSTransLine: Record "LSC POS Trans. Line";
        recLTransLine: Record "LSC POS Trans. Line";
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        RecLitem: record Item;
        decDiscountpercen: Decimal;
        LDiscounteditems: Decimal;
        Ldec1: Decimal;
        Ldec2: Decimal;
        Ldec3: Decimal;
        Ldec4: Decimal;
        Ldec5: Decimal;
    begin

        recLPOSTransLine.RESET;
        recLPOSTransLine.SETRANGE("Receipt No.", REC."Receipt No.");
        recLPOSTransLine.SetRange("Entry Status", recLPOSTransLine."Entry Status"::" ");
        recLPOSTransLine.SetRange("Entry Type", recLPOSTransLine."Entry Type"::Item);
        if recLPOSTransLine.FindFirst() then
            repeat
                decDiscountpercen := 0;
                if recLPOSTransLine.Count > 0 then begin
                    if (codPOSTrans.GetPosState() = STATE_TENDOP) OR REC."New Transaction" then begin
                        codPOSTrans.MessageBeep('');
                        exit;
                    end;
                    POSFuncProfile.Get(POSSESSION.FunctionalityProfileID());
                    POSLINES.GetCurrentLine(LineRec);

                    // if LineRec.Number = '' then begin
                    //     codPOSTrans.MessageBeep('');
                    //     EXIT;
                    // end;

                    // if LineRec."Entry Status" = LineRec."Entry Status"::Voided then begin
                    //     codPOSTrans.MessageBeep('');
                    //     EXIT;
                    // end;


                    if (LineRec.Number = '') OR (LineRec."Entry Status" = LineRec."Entry Status"::Voided) then begin
                        LineRec.SETRANGE("Receipt No.", LineRec."Receipt No.");
                        LineRec.SETFILTER("Entry Status", '<>%1', LineRec."Entry Status"::Voided);
                        LineRec.SETFILTER(Number, '<>%1', '');
                        if NOT LineRec.FIND('+') THEN;
                        LineRec.SETRANGE("Receipt No.");
                        LineRec.SETRANGE("Entry Status");
                        LineRec.SETRANGE(Number);

                        recLTransLine.RESET;
                        recLTransLine.SETRANGE("Receipt No.", REC."Receipt No.");
                        recLTransLine.SETFILTER("Entry Status", '<>%1', recLTransLine."Entry Status"::Voided);
                        recLTransLine.SETFILTER(Number, '<>%1', '');
                        if recLTransLine.FINDFIRST then begin
                            POSLINES.SetCurrentLine(recLTransLine);
                            POSLINES.GetCurrentLine(LineRec);
                        end;

                    end;
                    //codPOSTrans.DiscPrPressed('5');

                    if recLPOSTransLine.Number <> '' then
                        if RecLitem.Get(recLPOSTransLine.Number) then begin
                            if REC."Transaction Code Type" = REC."Transaction Code Type"::"SRC" then
                                decDiscountpercen := RecLitem."SRC Discount %";
                            if REC."Transaction Code Type" = REC."Transaction Code Type"::PWD then
                                decDiscountpercen := RecLitem."PWD Discount %";
                            if REC."Transaction Code Type" = REC."Transaction Code Type"::SOLO then
                                decDiscountpercen := RecLitem."SOLO Discount %";
                            if REC."Transaction Code Type" = REC."Transaction Code Type"::ATHL then
                                decDiscountpercen := RecLitem."Athlete Discount %";
                            if REC."Transaction Code Type" = REC."Transaction Code Type"::MOV then
                                decDiscountpercen := RecLitem."MOV Discount %";
                            if REC."Transaction Code Type" = REC."Transaction Code Type"::NAAC then
                                decDiscountpercen := RecLitem."NAAC Discount %";
                        end;

                    if decDiscountpercen > 0 then begin
                        POSLINES.SetCurrentLine(recLPOSTransLine);
                        POSLINES.GetCurrentLine(recLPOSTransLine);
                        LDiscounteditems += recLPOSTransLine.Price * recLPOSTransLine.Quantity;
                        if (REC."Transaction Code Type" = REC."Transaction Code Type"::ATHL) or (REC."Transaction Code Type" = REC."Transaction Code Type"::SOLO)
                             or (REC."Transaction Code Type" = REC."Transaction Code Type"::MOV) or (REC."Transaction Code Type" = REC."Transaction Code Type"::NAAC) then begin
                            codPOSTrans.DiscPrPressedEx(decDiscountpercen);
                        end;

                    end;
                    InsertLinediscount(REC);
                end;

            until recLPOSTransLine.next = 0;



    end;

    procedure MOVNAACPerItemlinePressed(var REC: Record "LSC POS Transaction")
    var
        Dec: Decimal;
        POSFuncProfile: Record "LSC POS Func. Profile";
        LineRec: Record "LSC POS Trans. Line";
        recLPOSTransLine: Record "LSC POS Trans. Line";
        recLTransLine: Record "LSC POS Trans. Line";
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        RecLitem: record Item;
        decDiscountpercen: Decimal;
        LDiscounteditems: Decimal;
        Ldec1: Decimal;
        Ldec2: Decimal;
        Ldec3: Decimal;
        Ldec4: Decimal;
        Ldec5: Decimal;
    begin

        recLPOSTransLine.RESET;
        recLPOSTransLine.SETRANGE("Receipt No.", REC."Receipt No.");
        recLPOSTransLine.SetRange("Entry Status", recLPOSTransLine."Entry Status"::" ");
        recLPOSTransLine.SetRange("Entry Type", recLPOSTransLine."Entry Type"::Item);
        if recLPOSTransLine.FindFirst() then
            repeat
                decDiscountpercen := 0;
                if recLPOSTransLine.Count > 0 then begin
                    if (codPOSTrans.GetPosState() = STATE_TENDOP) OR REC."New Transaction" then begin
                        codPOSTrans.MessageBeep('');
                        exit;
                    end;
                    POSFuncProfile.Get(POSSESSION.FunctionalityProfileID());
                    POSLINES.GetCurrentLine(LineRec);

                    if (LineRec.Number = '') OR (LineRec."Entry Status" = LineRec."Entry Status"::Voided) then begin
                        LineRec.SETRANGE("Receipt No.", LineRec."Receipt No.");
                        LineRec.SETFILTER("Entry Status", '<>%1', LineRec."Entry Status"::Voided);
                        LineRec.SETFILTER(Number, '<>%1', '');
                        if NOT LineRec.FIND('+') THEN;
                        LineRec.SETRANGE("Receipt No.");
                        LineRec.SETRANGE("Entry Status");
                        LineRec.SETRANGE(Number);

                        recLTransLine.RESET;
                        recLTransLine.SETRANGE("Receipt No.", REC."Receipt No.");
                        recLTransLine.SETFILTER("Entry Status", '<>%1', recLTransLine."Entry Status"::Voided);
                        recLTransLine.SETFILTER(Number, '<>%1', '');
                        if recLTransLine.FINDFIRST then begin
                            POSLINES.SetCurrentLine(recLTransLine);
                            POSLINES.GetCurrentLine(LineRec);
                            recLTransLine."Org. Price Exc. VAT" := 2;
                        end;

                    end;

                    if recLPOSTransLine.Number <> '' then
                        if RecLitem.Get(recLPOSTransLine.Number) then begin
                            if REC."Transaction Code Type" = REC."Transaction Code Type"::MOV then
                                decDiscountpercen := RecLitem."MOV Discount %";
                            if REC."Transaction Code Type" = REC."Transaction Code Type"::NAAC then
                                decDiscountpercen := RecLitem."NAAC Discount %";
                        end;

                    if decDiscountpercen > 0 then begin
                        POSLINES.SetCurrentLine(recLPOSTransLine);
                        POSLINES.GetCurrentLine(recLPOSTransLine);
                        LDiscounteditems += recLPOSTransLine.Price * recLPOSTransLine.Quantity;
                        if (REC."Transaction Code Type" = REC."Transaction Code Type"::MOV) or (REC."Transaction Code Type" = REC."Transaction Code Type"::NAAC) then begin
                            Ldec1 := recLPOSTransLine."Org. Price Exc. VAT" * (decDiscountpercen / 100);
                            Ldec2 := Ldec1 / recLPOSTransLine."Org. Price Inc. VAT";
                            codPOSTrans.DiscPrPressedEx(Ldec2 * 100);
                        end;
                    end;

                    InsertLinediscount(REC);
                end;

            until recLPOSTransLine.next = 0;



    end;

    procedure MOVNAACPerItemlinePressed2(var REC: Record "LSC POS Transaction"; var CurrInput: Text; Value: Text[30]; TotAmount: Boolean)
    var
        OldAmount: Decimal;
        Dec: Decimal;
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        DT: Record "LSC POS Trans. Per. Disc. Type";
        LineDiscBefore: Boolean;
        LineDiscAfter: Boolean;
        LineDiscChange: Boolean;
        pLineRec: Record "LSC POS Trans. Line";
        decLBalance: Decimal;
        decLAmtOnRemBal: Decimal;
        recLPOSTransLine: Record "LSC POS Trans. Line";
        decLGrossAmount: Decimal;
        decLLineGrossAmt: Decimal;
        oldGrossAmt: Decimal;
        lDiscTotal: Decimal;
        lBegDiscount: Decimal;
        recLItem: Record Item;
        recLStore: Record "LSC Store";
        POSFunc: Record "LSC POS Func. Profile";
        POSSession: Codeunit "LSC POS Session";
        localDesc: Text;
        POSOfferExt: Codeunit "LSC POS Offer Ext. Utility";
        OposUtil: Codeunit "LSC POS OPOS Utility";
        InfoUtil: Codeunit "LSC POS Infocode Utility";
    begin
        if not recLStore.Get(POSSession.StoreNo()) then
            exit;
        if not POSFunc.Get(reclstore."Functionality Profile") then
            exit;
        Clear(decLBalance);
        Clear(decLLineGrossAmt);
        decLBalance := REC."Beginning Balance";
        pLineRec.Reset();
        pLineRec.SetCurrentKey("Receipt No.", "Entry Type", "Entry Status");
        pLineRec.SETRANGE("Receipt No.", REC."Receipt No.");
        pLineRec.SETRANGE("Entry Type", pLineRec."Entry Type"::Item);
        pLineRec.SETRANGE("Entry Status", pLineRec."Entry Status"::" ");
        pLineRec.SETFILTER("Item Disc. % Orig.", '>%1', 0);
        if pLineRec.FINDFIRST THEN
            REPEAT
                if not ValidateDisc(REC, pLineRec) then
                    exit;

                if lBegDiscount = 0 then
                    if recLItem.get(pLineRec.Number) then
                        if not recLItem."Food Item" then
                            lBegDiscount := decLBalance * (pLineRec."Item Disc. % Orig." * 0.01);

                decLLineGrossAmt := pLineRec.Amount;
                if recLItem.get(pLineRec.Number) then begin
                    if (recLItem."MOV Discount %" > 0) then begin
                        if (decLBalance > decLLineGrossAmt) or (recLItem."Food Item") then begin
                            Value := Format(pLineRec."Item Disc. % Orig.");
                            Evaluate(pLineRec."Item Disc. % Actual", Value);
                            // pLineRec."Item Disc. Type" := pLineRec."Item Disc. Type"::;
                            // pLineRec."Discount identifier" := 'S';
                            if not recLItem."Food Item" then
                                decLBalance -= decLLineGrossAmt;
                        end else begin
                            if (decLBalance > 0) or (recLItem."Food Item") then begin
                                Clear(decLAmtOnRemBal);
                                decLAmtOnRemBal := decLBalance * (pLineRec."Item Disc. % Orig." * 0.01);
                                if (lBegDiscount - lDiscTotal) <> 0 then
                                    if (lBegDiscount - lDiscTotal) <> decLAmtOnRemBal then
                                        decLAmtOnRemBal := lBegDiscount - lDiscTotal;
                                Value := Format((decLAmtOnRemBal / decLLineGrossAmt) * 100);
                                Evaluate(pLineRec."Item Disc. % Actual", Value);
                                // pLineRec."Item Disc. Type" := pLineRec."Item Disc. Type"::SRC;
                                // pLineRec."Discount identifier" := 'S';
                                if not recLItem."Food Item" then
                                    decLBalance -= decLBalance;
                            end else begin
                                Value := Format(0);
                                Evaluate(pLineRec."Item Disc. % Actual", Value);
                            end;
                        end;
                    end;
                    pLineRec.Modify();
                end;

                if Value <> '' then
                    CurrInput := Value;


                if not Evaluate(dec, CurrInput) or (Abs(Dec) > 100) then begin
                    codPOSTrans.ErrorBeep('Invalid value in percent');
                    exit;
                end;

                if not POSSession.PermissionItem('DISC', pLineRec.Number, Dec, 0, localDesc, POSSession.ManagerID(), false) then begin
                    codPOSTrans.ErrorBeep(localDesc);
                    exit;
                end;

                LineDiscBefore := PosOfferExt.TransLineDiscOfferTypeExists(pLineRec, DiscType::Line);
                PosPriceUtil.InsertTransDiscPercent(pLineRec, 0, DiscType::Line, '');
                pLineRec.Validate(pLineRec."Line Disc. %", 0);
                OldAmount := pLineRec.Amount;

                if (Dec > 0) then
                    codPOSTrans.CheckInfoCode('MARKDN')
                else
                    if Dec < 0 then
                        codPOSTrans.CheckInfoCode('MARKUP');

                PosPriceUtil.InsertTransDiscPercent(pLineRec, Dec, DiscType::Line, '');
                pLineRec.Validate("Line Disc. %", Dec);
                LineDiscAfter := POSOfferExt.TransLineDiscOfferTypeExists(pLineRec, DiscType::Line);
                if not recLItem."Food Item" then
                    lDiscTotal += pLineRec."Discount Amount";
                if LineDiscAfter then
                    POSOfferExt.ProcessLinePreTotal(REC, pLineRec, '');

                LineDiscChange := LineDiscBefore or LineDiscAfter;
                codPOSTrans.WriteMgrStatus();
                CalcTotals(REC);
                codPOSTrans.CalcTotals();
                CurrInput := '';
                if LineDiscChange then
                    codPOSTrans.SetInfoTextDescription('Discount Change', '');

                OposUtil.DisplaySalesLine('', pLineRec.Description, pLineRec.Quantity, pLineRec.Price, pLineRec.Amount, pLineRec."Unit of Measure", TRUE);

                if NOT LineDiscChange then begin //Clear Infocode MARKDN / MARKUP
                    InfoUtil.RemoveInfoCode(pLineRec, 'MARKDN');
                    InfoUtil.RemoveInfoCode(pLineRec, 'MARKUP');
                end;
            until pLineRec.Next() = 0;

        REC.CalcFields("SC Total Line Discount", "Gross Amount");

        Clear(decLGrossAmount);
        recLPOSTransLine.Reset();
        recLPOSTransLine.SetCurrentKey("Receipt No.", "Entry Type");
        recLPOSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        recLPOSTransLine.SETRANGE("Entry Type", recLPOSTransLine."Entry Type"::Item);
        recLPOSTransLine.SETRANGE("Entry Status", recLPOSTransLine."Entry Status"::" ");
        recLPOSTransLine.SETRANGE("Item Disc. Type", recLPOSTransLine."Item Disc. Type"::SRC);
        if recLPOSTransLine.FINDFIRST THEN
            REPEAT
                recLItem.Reset();
                recLItem.SetRange("No.", recLPOSTransLine.Number);
                if recLItem.FindFirst() then
                    if not recLItem."Food Item" then
                        declGrossAmount += recLPOSTransLine.Amount + recLPOSTransLine."Discount Amount";
            UNTIL recLPOSTransLine.NEXT = 0;
        EVALUATE(REC."Senior Discount %", FORMAT((REC."SC Total Line Discount" / (REC."Gross Amount" + REC."SC Total Line Discount")) * 100));

        if (REC."Beginning Balance" > declGrossAmount) then begin
            REC."Current Balance" := REC."Beginning Balance" - declGrossAmount;
        end else BEGIN
            REC."Current Balance" := 0;
        end;

        REC."SRC Applied Counter" := REC."SRC Applied Counter" + 1;
        REC.MODifY;
    end;

    procedure ZeroOutDiscount(var REC: Record "LSC POS Transaction")
    var
        Dec: Decimal;
        POSFuncProfile: Record "LSC POS Func. Profile";
        LineRec: Record "LSC POS Trans. Line";
        recLPOSTransLine: Record "LSC POS Trans. Line";
        recLTransLine: Record "LSC POS Trans. Line";
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        RecLitem: record Item;
        decDiscountpercen: Decimal;
        LDiscounteditems: Decimal;
        Ldec1: Decimal;
        Ldec2: Decimal;
        Ldec3: Decimal;
        Ldec4: Decimal;
        Ldec5: Decimal;
    begin

        recLPOSTransLine.RESET;
        recLPOSTransLine.SETRANGE("Receipt No.", REC."Receipt No.");
        recLPOSTransLine.SetRange("Entry Status", recLPOSTransLine."Entry Status"::" ");
        recLPOSTransLine.SetRange("Entry Type", recLPOSTransLine."Entry Type"::Item);
        if recLPOSTransLine.FindFirst() then
            repeat
                decDiscountpercen := 0;
                if recLPOSTransLine.Count > 0 then begin
                    if (codPOSTrans.GetPosState() = STATE_TENDOP) OR REC."New Transaction" then begin
                        codPOSTrans.MessageBeep('');
                        exit;
                    end;
                    POSFuncProfile.Get(POSSESSION.FunctionalityProfileID());
                    POSLINES.GetCurrentLine(LineRec);


                    if (LineRec.Number = '') OR (LineRec."Entry Status" = LineRec."Entry Status"::Voided) then begin
                        LineRec.SETRANGE("Receipt No.", LineRec."Receipt No.");
                        LineRec.SETFILTER("Entry Status", '<>%1', LineRec."Entry Status"::Voided);
                        LineRec.SETFILTER(Number, '<>%1', '');
                        if NOT LineRec.FIND('+') THEN;
                        LineRec.SETRANGE("Receipt No.");
                        LineRec.SETRANGE("Entry Status");
                        LineRec.SETRANGE(Number);

                        recLTransLine.RESET;
                        recLTransLine.SETRANGE("Receipt No.", REC."Receipt No.");
                        recLTransLine.SETFILTER("Entry Status", '<>%1', recLTransLine."Entry Status"::Voided);
                        recLTransLine.SETFILTER(Number, '<>%1', '');
                        if recLTransLine.FINDFIRST then begin
                            POSLINES.SetCurrentLine(recLTransLine);
                            POSLINES.GetCurrentLine(LineRec);
                        end;

                    end;
                    //codPOSTrans.DiscPrPressed('5');

                    if recLPOSTransLine.Number <> '' then
                        if RecLitem.Get(recLPOSTransLine.Number) then begin
                            if REC."Transaction Code Type" = REC."Transaction Code Type"::"SRC" then
                                decDiscountpercen := RecLitem."SRC Discount %";
                            if REC."Transaction Code Type" = REC."Transaction Code Type"::PWD then
                                decDiscountpercen := RecLitem."PWD Discount %";
                            if REC."Transaction Code Type" = REC."Transaction Code Type"::SOLO then
                                decDiscountpercen := RecLitem."SOLO Discount %";
                            if REC."Transaction Code Type" = REC."Transaction Code Type"::ATHL then
                                decDiscountpercen := RecLitem."Athlete Discount %";
                        end;

                    codPOSTrans.DiscPrPressedEx(0);
                    recLPOSTransLine."Discount Type" := recLPOSTransLine."Discount Type"::" ";
                    //recLPOSTransLine.Modify();
                end;

            until recLPOSTransLine.next = 0;



    end;

    procedure SeniorDiscPerPressed(var REC: Record "LSC POS Transaction"; var CurrInput: Text; Value: Text[30]; TotAmount: Boolean)
    var
        OldAmount: Decimal;
        Dec: Decimal;
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        DT: Record "LSC POS Trans. Per. Disc. Type";
        LineDiscBefore: Boolean;
        LineDiscAfter: Boolean;
        LineDiscChange: Boolean;
        pLineRec: Record "LSC POS Trans. Line";
        decLBalance: Decimal;
        decLAmtOnRemBal: Decimal;
        recLPOSTransLine: Record "LSC POS Trans. Line";
        decLGrossAmount: Decimal;
        decLLineGrossAmt: Decimal;
        oldGrossAmt: Decimal;
        lDiscTotal: Decimal;
        lBegDiscount: Decimal;
        recLItem: Record Item;
        recLStore: Record "LSC Store";
        POSFunc: Record "LSC POS Func. Profile";
        POSSession: Codeunit "LSC POS Session";
        localDesc: Text;
        POSOfferExt: Codeunit "LSC POS Offer Ext. Utility";
        OposUtil: Codeunit "LSC POS OPOS Utility";
        InfoUtil: Codeunit "LSC POS Infocode Utility";
    begin
        if not recLStore.Get(POSSession.StoreNo()) then
            exit;
        if not POSFunc.Get(reclstore."Functionality Profile") then
            exit;
        Clear(decLBalance);
        Clear(decLLineGrossAmt);
        decLBalance := REC."Beginning Balance";
        pLineRec.Reset();
        pLineRec.SetCurrentKey("Receipt No.", "Entry Type", "Entry Status");
        pLineRec.SETRANGE("Receipt No.", REC."Receipt No.");
        pLineRec.SETRANGE("Entry Type", pLineRec."Entry Type"::Item);
        pLineRec.SETRANGE("Entry Status", pLineRec."Entry Status"::" ");
        pLineRec.SETFILTER("Item Disc. % Orig.", '>%1', 0);
        if pLineRec.FINDFIRST THEN
            REPEAT
                if not ValidateDisc(REC, pLineRec) then
                    exit;

                if lBegDiscount = 0 then
                    if recLItem.get(pLineRec.Number) then
                        if not recLItem."Food Item" then
                            lBegDiscount := decLBalance * (pLineRec."Item Disc. % Orig." * 0.01);

                decLLineGrossAmt := pLineRec.Amount;
                if recLItem.get(pLineRec.Number) then begin
                    if (recLItem."SRC Discount %" > 0) then begin
                        if (decLBalance > decLLineGrossAmt) or (recLItem."Food Item") then begin
                            Value := Format(pLineRec."Item Disc. % Orig.");
                            Evaluate(pLineRec."Item Disc. % Actual", Value);
                            pLineRec."Item Disc. Type" := pLineRec."Item Disc. Type"::SRC;
                            pLineRec."Discount identifier" := 'S';
                            if not recLItem."Food Item" then
                                decLBalance -= decLLineGrossAmt;
                        end else begin
                            if (decLBalance > 0) or (recLItem."Food Item") then begin
                                Clear(decLAmtOnRemBal);
                                decLAmtOnRemBal := decLBalance * (pLineRec."Item Disc. % Orig." * 0.01);
                                if (lBegDiscount - lDiscTotal) <> 0 then
                                    if (lBegDiscount - lDiscTotal) <> decLAmtOnRemBal then
                                        decLAmtOnRemBal := lBegDiscount - lDiscTotal;
                                Value := Format((decLAmtOnRemBal / decLLineGrossAmt) * 100);
                                Evaluate(pLineRec."Item Disc. % Actual", Value);
                                pLineRec."Item Disc. Type" := pLineRec."Item Disc. Type"::SRC;
                                pLineRec."Discount identifier" := 'S';
                                if not recLItem."Food Item" then
                                    decLBalance -= decLBalance;
                            end else begin
                                Value := Format(0);
                                Evaluate(pLineRec."Item Disc. % Actual", Value);
                            end;
                        end;
                    end;
                    pLineRec.Modify();
                end;

                if Value <> '' then
                    CurrInput := Value;


                if not Evaluate(dec, CurrInput) or (Abs(Dec) > 100) then begin
                    codPOSTrans.ErrorBeep('Invalid value in percent');
                    exit;
                end;

                if not POSSession.PermissionItem('DISC', pLineRec.Number, Dec, 0, localDesc, POSSession.ManagerID(), false) then begin
                    codPOSTrans.ErrorBeep(localDesc);
                    exit;
                end;

                LineDiscBefore := PosOfferExt.TransLineDiscOfferTypeExists(pLineRec, DiscType::Line);
                PosPriceUtil.InsertTransDiscPercent(pLineRec, 0, DiscType::Line, '');
                pLineRec.Validate(pLineRec."Line Disc. %", 0);
                OldAmount := pLineRec.Amount;

                if (Dec > 0) then
                    codPOSTrans.CheckInfoCode('MARKDN')
                else
                    if Dec < 0 then
                        codPOSTrans.CheckInfoCode('MARKUP');

                PosPriceUtil.InsertTransDiscPercent(pLineRec, Dec, DiscType::Line, '');
                pLineRec.Validate("Line Disc. %", Dec);
                LineDiscAfter := POSOfferExt.TransLineDiscOfferTypeExists(pLineRec, DiscType::Line);
                if not recLItem."Food Item" then
                    lDiscTotal += pLineRec."Discount Amount";
                if LineDiscAfter then
                    POSOfferExt.ProcessLinePreTotal(REC, pLineRec, '');

                LineDiscChange := LineDiscBefore or LineDiscAfter;
                codPOSTrans.WriteMgrStatus();
                CalcTotals(REC);
                codPOSTrans.CalcTotals();
                CurrInput := '';
                if LineDiscChange then
                    codPOSTrans.SetInfoTextDescription('Discount Change', '');

                OposUtil.DisplaySalesLine('', pLineRec.Description, pLineRec.Quantity, pLineRec.Price, pLineRec.Amount, pLineRec."Unit of Measure", TRUE);

                if NOT LineDiscChange then begin //Clear Infocode MARKDN / MARKUP
                    InfoUtil.RemoveInfoCode(pLineRec, 'MARKDN');
                    InfoUtil.RemoveInfoCode(pLineRec, 'MARKUP');
                end;
            until pLineRec.Next() = 0;

        REC.CalcFields("SC Total Line Discount", "Gross Amount");

        Clear(decLGrossAmount);
        recLPOSTransLine.Reset();
        recLPOSTransLine.SetCurrentKey("Receipt No.", "Entry Type");
        recLPOSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        recLPOSTransLine.SETRANGE("Entry Type", recLPOSTransLine."Entry Type"::Item);
        recLPOSTransLine.SETRANGE("Entry Status", recLPOSTransLine."Entry Status"::" ");
        recLPOSTransLine.SETRANGE("Item Disc. Type", recLPOSTransLine."Item Disc. Type"::SRC);
        if recLPOSTransLine.FINDFIRST THEN
            REPEAT
                recLItem.Reset();
                recLItem.SetRange("No.", recLPOSTransLine.Number);
                if recLItem.FindFirst() then
                    if not recLItem."Food Item" then
                        declGrossAmount += recLPOSTransLine.Amount + recLPOSTransLine."Discount Amount";
            UNTIL recLPOSTransLine.NEXT = 0;
        EVALUATE(REC."Senior Discount %", FORMAT((REC."SC Total Line Discount" / (REC."Gross Amount" + REC."SC Total Line Discount")) * 100));

        if (REC."Beginning Balance" > declGrossAmount) then begin
            REC."Current Balance" := REC."Beginning Balance" - declGrossAmount;
        end else BEGIN
            REC."Current Balance" := 0;
        end;

        REC."SRC Applied Counter" := REC."SRC Applied Counter" + 1;
        REC.MODifY;
    end;

    procedure PWDPerPressed(var REC: Record "LSC POS Transaction"; var CurrInput: Text; Value: Text[30]; TotAmount: Boolean)
    var
        OldAmount: Decimal;
        Dec: Decimal;
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        DT: Record "LSC POS Trans. Per. Disc. Type";
        LineDiscBefore: Boolean;
        LineDiscAfter: Boolean;
        LineDiscChange: Boolean;
        pLineRec: Record "LSC POS Trans. Line";
        decLBalance: Decimal;
        decLAmtOnRemBal: Decimal;
        recLPOSTransLine: Record "LSC POS Trans. Line";
        decLGrossAmount: Decimal;
        decLLineGrossAmt: Decimal;
        oldGrossAmt: Decimal;
        lDiscTotal: Decimal;
        lBegDiscount: Decimal;
        recLItem: Record Item;
        recLStore: Record "LSC Store";
        POSFunc: Record "LSC POS Func. Profile";
        POSSession: Codeunit "LSC POS Session";
        localDesc: Text;
        POSOfferExt: Codeunit "LSC POS Offer Ext. Utility";
        OposUtil: Codeunit "LSC POS OPOS Utility";
        InfoUtil: Codeunit "LSC POS Infocode Utility";
    begin
        if not recLStore.Get(POSSession.StoreNo()) then
            exit;
        if not POSFunc.Get(reclstore."Functionality Profile") then
            exit;
        Clear(decLBalance);
        Clear(decLLineGrossAmt);
        decLBalance := REC."Beginning Balance";
        pLineRec.Reset();
        pLineRec.SetCurrentKey("Receipt No.", "Entry Type", "Entry Status");
        pLineRec.SETRANGE("Receipt No.", REC."Receipt No.");
        pLineRec.SETRANGE("Entry Type", pLineRec."Entry Type"::Item);
        pLineRec.SETRANGE("Entry Status", pLineRec."Entry Status"::" ");
        pLineRec.SETFILTER("Item Disc. % Orig.", '>%1', 0);
        if pLineRec.FINDFIRST THEN
            REPEAT
                if not ValidateDisc(REC, pLineRec) then
                    exit;

                if lBegDiscount = 0 then
                    if recLItem.get(pLineRec.Number) then
                        if not recLItem."Food Item" then
                            lBegDiscount := decLBalance * (pLineRec."Item Disc. % Orig." * 0.01);
                decLLineGrossAmt := pLineRec.Amount;
                if recLItem.get(pLineRec.Number) then begin
                    if (recLItem."PWD Discount %" > 0) then begin
                        if (decLBalance > decLLineGrossAmt) or (recLItem."Food Item") then begin
                            Value := Format(pLineRec."Item Disc. % Orig.");
                            Evaluate(pLineRec."Item Disc. % Actual", Value);
                            pLineRec."Item Disc. Type" := pLineRec."Item Disc. Type"::PWD;
                            pLineRec."Discount identifier" := 'S';
                            if not recLItem."Food Item" then
                                decLBalance -= decLLineGrossAmt;
                        end else begin
                            if (decLBalance > 0) or (recLItem."Food Item") then begin
                                Clear(decLAmtOnRemBal);
                                decLAmtOnRemBal := decLBalance * (pLineRec."Item Disc. % Orig." * 0.01);
                                if (lBegDiscount - lDiscTotal) <> 0 then
                                    if (lBegDiscount - lDiscTotal) <> decLAmtOnRemBal then
                                        decLAmtOnRemBal := lBegDiscount - lDiscTotal;
                                Value := Format((decLAmtOnRemBal / decLLineGrossAmt) * 100);
                                Evaluate(pLineRec."Item Disc. % Actual", Value);
                                pLineRec."Item Disc. Type" := pLineRec."Item Disc. Type"::PWD;
                                pLineRec."Discount identifier" := 'S';
                                if not recLItem."Food Item" then
                                    decLBalance -= decLBalance;
                            end else begin
                                Value := Format(0);
                                Evaluate(pLineRec."Item Disc. % Actual", Value);
                            end;
                        end;
                    end;
                    pLineRec.Modify();
                end;

                if Value <> '' then
                    CurrInput := Value;


                if not Evaluate(dec, CurrInput) or (Abs(Dec) > 100) then begin
                    codPOSTrans.ErrorBeep('Invalid value in percent');
                    exit;
                end;

                if not POSSession.PermissionItem('DISC', pLineRec.Number, Dec, 0, localDesc, POSSession.ManagerID(), false) then begin
                    codPOSTrans.ErrorBeep(localDesc);
                    exit;
                end;

                LineDiscBefore := PosOfferExt.TransLineDiscOfferTypeExists(pLineRec, DiscType::Line);
                PosPriceUtil.InsertTransDiscPercent(pLineRec, 0, DiscType::Line, '');
                pLineRec.Validate(pLineRec."Line Disc. %", 0);
                OldAmount := pLineRec.Amount;

                if (Dec > 0) then
                    codPOSTrans.CheckInfoCode('MARKDN')
                else
                    if Dec < 0 then
                        codPOSTrans.CheckInfoCode('MARKUP');

                PosPriceUtil.InsertTransDiscPercent(pLineRec, Dec, DiscType::Line, '');
                pLineRec.Validate("Line Disc. %", Dec);
                LineDiscAfter := POSOfferExt.TransLineDiscOfferTypeExists(pLineRec, DiscType::Line);
                if not recLItem."Food Item" then
                    lDiscTotal += pLineRec."Discount Amount";
                if LineDiscAfter then
                    POSOfferExt.ProcessLinePreTotal(REC, pLineRec, '');

                LineDiscChange := LineDiscBefore or LineDiscAfter;
                codPOSTrans.WriteMgrStatus();
                CalcTotals(REC);
                codPOSTrans.CalcTotals();
                CurrInput := '';
                if LineDiscChange then
                    codPOSTrans.SetInfoTextDescription('Discount Change', '');

                OposUtil.DisplaySalesLine('', pLineRec.Description, pLineRec.Quantity, pLineRec.Price, pLineRec.Amount, pLineRec."Unit of Measure", TRUE);

                if NOT LineDiscChange then begin //Clear Infocode MARKDN / MARKUP
                    InfoUtil.RemoveInfoCode(pLineRec, 'MARKDN');
                    InfoUtil.RemoveInfoCode(pLineRec, 'MARKUP');
                end;
            until pLineRec.Next() = 0;

        REC.CalcFields("SC Total Line Discount", "Gross Amount");

        Clear(decLGrossAmount);
        recLPOSTransLine.Reset();
        recLPOSTransLine.SetCurrentKey("Receipt No.", "Entry Type");
        recLPOSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        recLPOSTransLine.SETRANGE("Entry Type", recLPOSTransLine."Entry Type"::Item);
        recLPOSTransLine.SETRANGE("Entry Status", recLPOSTransLine."Entry Status"::" ");
        recLPOSTransLine.SETRANGE("Item Disc. Type", recLPOSTransLine."Item Disc. Type"::PWD);
        if recLPOSTransLine.FINDFIRST THEN
            REPEAT
                recLItem.Reset();
                recLItem.SetRange("No.", recLPOSTransLine.Number);
                if recLItem.FindFirst() then
                    if not recLItem."Food Item" then
                        declGrossAmount += recLPOSTransLine.Amount + recLPOSTransLine."Discount Amount";
            UNTIL recLPOSTransLine.NEXT = 0;
        EVALUATE(REC."Senior Discount %", FORMAT((REC."SC Total Line Discount" / (REC."Gross Amount" + REC."SC Total Line Discount")) * 100));

        if (REC."Beginning Balance" > declGrossAmount) then begin
            REC."Current Balance" := REC."Beginning Balance" - declGrossAmount;
        end else BEGIN
            REC."Current Balance" := 0;
        end;

        REC."SRC Applied Counter" := REC."SRC Applied Counter" + 1;
        REC.MODifY;
    end;

    procedure PWDDiscPerPressed_(var REC: Record "LSC POS Transaction"; var CurrInput: Text; Value: Text[30]; TotAmount: Boolean)
    var
        OldAmount: Decimal;
        Dec: Decimal;
        PosPriceUtil: Codeunit "LSC POS Price Utility";
        DT: Record "LSC POS Trans. Per. Disc. Type";
        LineDiscBefore: Boolean;
        LineDiscAfter: Boolean;
        LineDiscChange: Boolean;
        pLineRec: Record "LSC POS Trans. Line";
        decLBalance: Decimal;
        decLAmtOnRemBal: Decimal;
        recLPOSTransLine: Record "LSC POS Trans. Line";
        decLGrossAmount: Decimal;
        decLLineGrossAmt: Decimal;
        oldGrossAmt: Decimal;
        recLItem: Record Item;
        recLStore: Record "LSC Store";
        POSFunc: Record "LSC POS Func. Profile";
        POSSession: Codeunit "LSC POS Session";
        localDesc: Text;
        POSOfferExt: Codeunit "LSC POS Offer Ext. Utility";
        OposUtil: Codeunit "LSC POS OPOS Utility";
        InfoUtil: Codeunit "LSC POS Infocode Utility";
    begin
        if not recLStore.Get(POSSession.StoreNo()) then
            exit;
        if not POSFunc.Get(reclstore."Functionality Profile") then
            exit;
        Clear(decLBalance);
        Clear(decLLineGrossAmt);
        decLBalance := REC."Beginning Balance";
        pLineRec.Reset();
        pLineRec.SetCurrentKey("Receipt No.", "Entry Type", "Entry Status");
        pLineRec.SETRANGE("Receipt No.", REC."Receipt No.");
        pLineRec.SETRANGE("Entry Type", pLineRec."Entry Type"::Item);
        pLineRec.SETRANGE("Entry Status", pLineRec."Entry Status"::" ");
        pLineRec.SETFILTER("Item Disc. % Orig.", '>%1', 0);
        if pLineRec.FINDFIRST THEN
            REPEAT
                if not ValidateDisc(REC, pLineRec) then
                    exit;

                decLLineGrossAmt := pLineRec.Amount;
                if recLItem.get(pLineRec.Number) then begin
                    // if (recLItem."Allow SRC Discount" AND (POSFunc."SRC Retail Disc. %" = 20)) then begin
                    //     Value := Format(pLineRec."Item Disc. % Orig.");
                    //     Evaluate(pLineRec."Item Disc. % Actual", Value);
                    //     pLineRec."Item Disc. Type" := pLineRec."Item Disc. Type"::SRC;
                    // end else begin
                    //     if decLBalance > decLLineGrossAmt then begin
                    //         Value := Format(pLineRec."Item Disc. % Orig.");
                    //         Evaluate(pLineRec."Item Disc. % Actual", Value);
                    //         pLineRec."Item Disc. Type" := pLineRec."Item Disc. Type"::SRC;
                    //         decLBalance -= decLLineGrossAmt;
                    //     end else begin
                    //         if decLBalance > 0 then begin
                    //             Clear(decLAmtOnRemBal);
                    //             decLAmtOnRemBal := decLBalance * (pLineRec."Item Disc. % Orig." * 0.01);
                    //             Value := Format((decLAmtOnRemBal / decLLineGrossAmt) * 100);
                    //             Evaluate(pLineRec."Item Disc. % Actual", Value);
                    //             pLineRec."Item Disc. Type" := pLineRec."Item Disc. Type"::SRC;
                    //             decLBalance -= decLBalance;
                    //         end else begin
                    //             Value := Format(0);
                    //             Evaluate(pLineRec."Item Disc. % Actual", Value);
                    //         end;
                    //     end;
                    // end;
                    if (recLItem."PWD Discount %" > 0) and (not recLItem."Food Item") then begin
                        if (decLBalance > decLLineGrossAmt) then begin
                            Value := Format(pLineRec."Item Disc. % Orig.");
                            Evaluate(pLineRec."Item Disc. % Actual", Value);
                            pLineRec."Item Disc. Type" := pLineRec."Item Disc. Type"::PWD;
                            pLineRec."Discount identifier" := 'S';
                            decLBalance -= decLLineGrossAmt;
                        end else begin
                            if (decLBalance > 0) then begin
                                Clear(decLAmtOnRemBal);
                                decLAmtOnRemBal := decLBalance * (pLineRec."Item Disc. % Orig." * 0.01);
                                Value := Format((decLAmtOnRemBal / decLLineGrossAmt) * 100);
                                Evaluate(pLineRec."Item Disc. % Actual", Value);
                                pLineRec."Item Disc. Type" := pLineRec."Item Disc. Type"::PWD;
                                pLineRec."Discount identifier" := 'S';
                                decLBalance -= decLBalance;
                            end else begin
                                Value := Format(0);
                                Evaluate(pLineRec."Item Disc. % Actual", Value);
                            end;
                        end;
                    end;
                    pLineRec.Modify();
                end;

                if Value <> '' then
                    CurrInput := Value;


                if not Evaluate(dec, CurrInput) or (Abs(Dec) > 100) then begin
                    codPOSTrans.ErrorBeep('Invalid value in percent');
                    exit;
                end;

                if not POSSession.PermissionItem('DISC', pLineRec.Number, Dec, 0, localDesc, POSSession.ManagerID(), false) then begin
                    codPOSTrans.ErrorBeep(localDesc);
                    exit;
                end;

                LineDiscBefore := PosOfferExt.TransLineDiscOfferTypeExists(pLineRec, DiscType::Line);
                PosPriceUtil.InsertTransDiscPercent(pLineRec, 0, DiscType::Line, '');
                pLineRec.Validate(pLineRec."Line Disc. %", 0);
                OldAmount := pLineRec.Amount;

                if (Dec > 0) then
                    codPOSTrans.CheckInfoCode('MARKDN')
                else
                    if Dec < 0 then
                        codPOSTrans.CheckInfoCode('MARKUP');

                PosPriceUtil.InsertTransDiscPercent(pLineRec, Dec, DiscType::Line, '');
                pLineRec.Validate("Line Disc. %", Dec);
                LineDiscAfter := POSOfferExt.TransLineDiscOfferTypeExists(pLineRec, DiscType::Line);
                if LineDiscAfter then
                    POSOfferExt.ProcessLinePreTotal(REC, pLineRec, '');

                LineDiscChange := LineDiscBefore or LineDiscAfter;
                codPOSTrans.WriteMgrStatus();
                CalcTotals(REC);
                codPOSTrans.CalcTotals();
                CurrInput := '';
                if LineDiscChange then
                    codPOSTrans.SetInfoTextDescription('Discount Change', '');

                OposUtil.DisplaySalesLine('', pLineRec.Description, pLineRec.Quantity, pLineRec.Price, pLineRec.Amount, pLineRec."Unit of Measure", TRUE);

                if NOT LineDiscChange then begin //Clear Infocode MARKDN / MARKUP
                    InfoUtil.RemoveInfoCode(pLineRec, 'MARKDN');
                    InfoUtil.RemoveInfoCode(pLineRec, 'MARKUP');
                end;
            until pLineRec.Next() = 0;

        REC.CalcFields("SC Total Line Discount", "Gross Amount");

        Clear(decLGrossAmount);
        recLPOSTransLine.Reset();
        recLPOSTransLine.SetCurrentKey("Receipt No.", "Entry Type");
        recLPOSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        recLPOSTransLine.SETRANGE("Entry Type", recLPOSTransLine."Entry Type"::Item);
        recLPOSTransLine.SETRANGE("Entry Status", recLPOSTransLine."Entry Status"::" ");
        recLPOSTransLine.SETRANGE("Item Disc. Type", recLPOSTransLine."Item Disc. Type"::PWD);
        if recLPOSTransLine.FINDFIRST THEN
            repeat
                recLItem.Reset();
                recLItem.SetRange("No.", recLPOSTransLine.Number);
                if recLItem.FindFirst() then
                    if not recLItem."Food Item" then
                        declGrossAmount += recLPOSTransLine.Amount + recLPOSTransLine."Discount Amount";
            until recLPOSTransLine.NEXT = 0;
        EVALUATE(REC."PWD Discount %", FORMAT((REC."PWD Total Line Discount" / (REC."Gross Amount" + REC."PWD Total Line Discount")) * 100));

        if (REC."Beginning Balance" > declGrossAmount) then begin
            REC."Current Balance" := REC."Beginning Balance" - declGrossAmount;
        end else BEGIN
            REC."Current Balance" := 0;
        end;

        REC."PWD Applied Counter" := REC."PWD Applied Counter" + 1;
        REC.MODifY;
    end;

    procedure GetDiscountSetup(pDiscCode: Code[20]; var REC: Record "LSC POS Transaction"): Decimal
    var
        recLPOSFuncProf: Record "LSC POS Func. Profile";
        POSSESSION: Codeunit "LSC POS Session";
    begin
        if recLPOSFuncProf.Get(POSSESSION.FunctionalityProfileID()) then begin

            case pDiscCode of
                'SRC':
                    begin
                        GetTotalDiscountByItem('SRC', REC);
                        exit(0);
                    end;
                'PWD':
                    begin
                        GetTotalDiscountByItem('PWD', REC);
                        exit(0);
                    end;
            end;


        end;
    end;

    procedure ValidateDisc(REC: Record "LSC POS Transaction"; LineRec: Record "LSC POS Trans. Line"): Boolean
    var
        POSLINES: Codeunit "LSC POS Trans. Lines";
    begin
        if (codPOSTrans.GetPosState() = STATE_TENDOP) OR REC."New Transaction" then begin
            codPOSTrans.MessageBeep('');
            EXIT(FALSE);
        end;

        //POSLINES.GetCurrentLine(LineRec);

        // if (LineRec.Number = '') OR (LineRec."Entry Status" = LineRec."Entry Status"::Voided) OR LineRec."Deal Line" then begin
        //     codPOSTrans.MessageBeep('');
        //     EXIT(FALSE);
        // end;
        if LineRec."Entry Type" <> LineRec."Entry Type"::Item then begin
            codPOSTrans.ErrorBeep('Discount can only be given on sales line');
            EXIT(FALSE);
        end;
        if LineRec."System-Block Manual Discount" then begin
            codPOSTrans.ErrorBeep('Discount is not allowed on this item');
            EXIT(FALSE);
        end;
        EXIT(TRUE);
    end;

    procedure GetTotalDiscountByItem(DiscountType: Code[20]; var REC: Record "LSC POS Transaction"): Decimal
    var
        recLPOSTransLine: Record "LSC POS Trans. Line";
        decLAmount: Decimal;
        recLItem: Record Item;
        decLLineDiscAmt: Decimal;
        decLTotalDiscAmt: Decimal;
        decLTotalDiscPer: Decimal;
        decLTotalLineDiscAmt: Decimal;
        recLPOSTransaction: Record "LSC POS Transaction";
        recLPOSTransLine1: Record "LSC POS Trans. Line";
        recLStore: Record "LSC Store";
        POSSession: Codeunit "LSC POS Session";
        POSFunc: Record "LSC POS Func. Profile";
        Direction: Text;
        Precision: decimal;
    begin

        CLEAR(decLAmount);
        CLEAR(decLLineDiscAmt);
        CLEAR(decLTotalLineDiscAmt);
        CLEAR(decLTotalDiscPer);
        CLEAR(decLTotalDiscAmt);

        if not recLStore.Get(POSSession.StoreNo()) then
            exit;
        if not POSFunc.Get(reclstore."Functionality Profile") then
            exit;

        recLPOSTransLine.SETCURRENTKEY("Receipt No.", "Entry Type", "Entry Status");
        recLPOSTransLine.SETRANGE("Receipt No.", REC."Receipt No.");
        recLPOSTransLine.SETRANGE("Entry Type", recLPOSTransLine."Entry Type"::Item);
        recLPOSTransLine.SETRANGE("Entry Status", recLPOSTransLine."Entry Status"::" ");
        if recLPOSTransLine.FINDFIRST THEN
            REPEAT
                decLAmount += recLPOSTransLine."Org. Price Inc. VAT";
                if recLItem.GET(recLPOSTransLine.Number) then begin
                    CASE DiscountType OF
                        'SRC':
                            BEGIN
                                if recLItem."SRC Discount %" > 0 then begin
                                    recLPOSTransLine."Item Disc. % Orig." := recLItem."SRC Discount %";
                                    recLPOSTransLine.MODifY;
                                    Direction := '<';
                                    Precision := 0.01;
                                    decLLineDiscAmt := recLPOSTransLine."Org. Price Inc. VAT" * (recLItem."SRC Discount %" * 0.01);
                                    decLLineDiscAmt := ROUND(decLLineDiscAmt, Precision, Direction);
                                    decLTotalDiscAmt += decLLineDiscAmt;
                                end;
                            end;
                        'PWD':
                            BEGIN
                                if recLItem."PWD Discount %" > 0 then begin
                                    recLPOSTransLine."Item Disc. % Orig." := recLItem."PWD Discount %";
                                    recLPOSTransLine.MODifY;
                                    Direction := '<';
                                    Precision := 0.01;
                                    decLLineDiscAmt := recLPOSTransLine."Org. Price Inc. VAT" * (recLItem."PWD Discount %" * 0.01);
                                    decLLineDiscAmt := ROUND(decLLineDiscAmt, Precision, Direction);
                                    decLTotalDiscAmt += decLLineDiscAmt;
                                end;
                            end;
                    end;
                end;
            UNTIL recLPOSTransLine.NEXT = 0;

        decLTotalDiscAmt := ROUND(decLTotalDiscAmt, 0.01, '>');
        if decLTotalDiscAmt <> 0 then begin
            if (decLAmount >= REC."Beginning Balance") and (REC."Beginning Balance" > 0) then begin
                decLTotalDiscPer := (decLTotalDiscAmt / REC."Beginning Balance") * 100;
            end else BEGIN
                decLTotalDiscPer := (decLTotalDiscAmt / decLAmount) * 100;
            end;
        end else BEGIN
            decLTotalDiscPer := 0;
        end;
        EXIT(decLTotalDiscPer);
    end;

    procedure CalcTotals(POSTrans: Record "LSC POS Transaction")
    begin
        POSTrans.CalcFields("Income/Exp. Amount", Prepayment, "Total Discount", Payment, "Net Amount", "Gross Amount", "Line Discount");
        Balance := POSTrans."Gross Amount" + POSTrans."Income/Exp. Amount" - POSTrans.Payment;
        if POSTrans."Sale Is Return Sale" then
            RealBalance := -Balance
        else
            RealBalance := Balance;
    end;

    procedure GetSRCDiscount(REC: Record "LSC POS Transaction"; LineRec: Record "LSC POS Trans. Line"): Integer
    begin
        LineRec.reset;
        LineRec.SetRange("Receipt No.", REC."Receipt No.");
        LineRec.SetRange("Entry Type", LineRec."Entry Type"::TotalDiscount);
        LineRec.SetRange("Entry Status", LineRec."Entry Status"::" ");
        LineRec.SetRange("Discount Type", LineRec."Discount Type"::SRC);
        if LineRec.FindFirst() then begin
            exit(LineRec.Count);
        end;
        exit(0);
    end;

    procedure GetPWDDiscount(REC: Record "LSC POS Transaction"; LineRec: Record "LSC POS Trans. Line"): Integer
    begin
        LineRec.reset;
        LineRec.SetRange("Receipt No.", REC."Receipt No.");
        LineRec.SetRange("Entry Type", LineRec."Entry Type"::TotalDiscount);
        LineRec.SetRange("Entry Status", LineRec."Entry Status"::" ");
        LineRec.SetRange("Discount Type", LineRec."Discount Type"::PWD);
        if LineRec.FindFirst() then begin
            exit(LineRec.Count);
        end;
        exit(0);
    end;

    procedure GetSOLODiscount(REC: Record "LSC POS Transaction"; LineRec: Record "LSC POS Trans. Line"): Integer
    begin
        LineRec.reset;
        LineRec.SetRange("Receipt No.", REC."Receipt No.");
        LineRec.SetRange("Entry Type", LineRec."Entry Type"::TotalDiscount);
        LineRec.SetRange("Entry Status", LineRec."Entry Status"::" ");
        LineRec.SetRange("Discount Type", LineRec."Discount Type"::SOLO);
        if LineRec.FindFirst() then begin
            exit(LineRec.Count);
        end;
        exit(0);
    end;

    procedure GetATHLDiscount(REC: Record "LSC POS Transaction"; LineRec: Record "LSC POS Trans. Line"): Integer
    begin
        LineRec.reset;
        LineRec.SetRange("Receipt No.", REC."Receipt No.");
        LineRec.SetRange("Entry Type", LineRec."Entry Type"::TotalDiscount);
        LineRec.SetRange("Entry Status", LineRec."Entry Status"::" ");
        LineRec.SetRange("Discount Type", LineRec."Discount Type"::ATHL);
        if LineRec.FindFirst() then begin
            exit(LineRec.Count);
        end;
        exit(0);
    end;

    procedure GetNAACDiscount(REC: Record "LSC POS Transaction"; LineRec: Record "LSC POS Trans. Line"): Integer
    begin
        LineRec.reset;
        LineRec.SetRange("Receipt No.", REC."Receipt No.");
        LineRec.SetRange("Entry Type", LineRec."Entry Type"::TotalDiscount);
        LineRec.SetRange("Entry Status", LineRec."Entry Status"::" ");
        LineRec.SetRange("Discount Type", LineRec."Discount Type"::NAAC);
        if LineRec.FindFirst() then begin
            exit(LineRec.Count);
        end;
        exit(0);
    end;

    procedure GetMOVDiscount(REC: Record "LSC POS Transaction"; LineRec: Record "LSC POS Trans. Line"): Integer
    begin
        LineRec.reset;
        LineRec.SetRange("Receipt No.", REC."Receipt No.");
        LineRec.SetRange("Entry Type", LineRec."Entry Type"::TotalDiscount);
        LineRec.SetRange("Entry Status", LineRec."Entry Status"::" ");
        LineRec.SetRange("Discount Type", LineRec."Discount Type"::MOV);
        if LineRec.FindFirst() then begin
            exit(LineRec.Count);
        end;
        exit(0);
    end;

    procedure CalcDiscount(REC: Record "LSC POS Transaction"; LineRec: Record "LSC POS Trans. Line"): Integer
    var
        Litems: Record Item;
        LDiscounteditems: Decimal;
    begin
        LineRec.reset;
        LineRec.SetRange("Receipt No.", REC."Receipt No.");
        LineRec.SetRange("Entry Status", LineRec."Entry Status"::" ");
        if LineRec.FindSet() then begin
            repeat
                if Litems.Get(LineRec.Number) then
                    if (Litems."SRC Discount %" > 0) or (Litems."PWD Discount %" > 0) or (Litems."SOLO Discount %" > 0) then
                        LDiscounteditems += LineRec.Price;
            until LineRec.Next() = 0;
            if LDiscounteditems > REC."Beginning Balance" then begin

            end;
        end;
        exit(0);
    end;

    procedure GetDiscountCode("pDiscount Type": option "REG","SRC","ZERO","PWD","SOLO","WHT1","VATW","ZRWH","ATHL","Regular Customer",DEPOSIT,"DEPOSIT REDEEM","MRS","BRS","CCM","NAAC","MOV","ONLINE"): Code[10]
    var
        recLGlobalRef: Record "Global References";
    begin
        recLGlobalRef.Reset();
        recLGlobalRef.SetRange("Entry Type", recLGlobalRef."Entry Type"::"Discount Code");

        if "pDiscount Type" = "pDiscount Type"::ATHL then
            recLGlobalRef.SetRange("Discount Type", recLGlobalRef."Discount Type"::ATHL);

        if "pDiscount Type" = "pDiscount Type"::SRC then
            recLGlobalRef.SetRange("Discount Type", recLGlobalRef."Discount Type"::SRC);

        if "pDiscount Type" = "pDiscount Type"::SOLO then
            recLGlobalRef.SetRange("Discount Type", recLGlobalRef."Discount Type"::SOLO);

        if "pDiscount Type" = "pDiscount Type"::PWD then
            recLGlobalRef.SetRange("Discount Type", recLGlobalRef."Discount Type"::PWD);

        if "pDiscount Type" = "pDiscount Type"::MOV then
            recLGlobalRef.SetRange("Discount Type", recLGlobalRef."Discount Type"::MOV);

        if "pDiscount Type" = "pDiscount Type"::NAAC then
            recLGlobalRef.SetRange("Discount Type", recLGlobalRef."Discount Type"::NAAC);

        if recLGlobalRef.FindFirst() then
            repeat
                exit(recLGlobalRef.Code)
            until recLGlobalRef.Next = 0;
        exit('')
    end;

    //--------------------------Procedure
    procedure GetPosState(): Code[10]
    begin
        exit(STATE);
    end;

    procedure Checkifwithsuspendtrans("Store No.": code[20]): Boolean
    var
        SuspTrans: Record "LSC POS Transaction";
        retailSetup: Record "LSC Retail Setup";
    begin
        retailSetup.Get();
        SuspTrans.SETRANGE("Store No.", "Store No.");
        SuspTrans.SETRANGE("Entry Status", SuspTrans."Entry Status"::Suspended);
        if SuspTrans.FindFirst then begin
            if retailSetup."Allow Y Read With Susp Trans" then begin
                exit(true);
            end else
                exit(false);
        end else
            exit(true);
    end;

    procedure CheckifwithTransLine("Store No.": code[20]): Boolean
    var
        POSTrans: Record "LSC POS Transaction";
        POSTransLine: Record "LSC POS Trans. Line";
        retailSetup: Record "LSC Retail Setup";
    begin
        retailSetup.Get();
        POSTrans.SETRANGE("Store No.", "Store No.");
        POSTrans.SetRange("Transaction Type", POSTrans."Transaction Type"::Sales);
        POSTrans.SetFilter("Entry Status", '<>%1', POSTrans."Entry Status"::Suspended);
        if POSTrans.FindFirst then begin
            POSTransLine.Reset();
            POSTransLine.SetRange("Receipt No.", POSTrans."Receipt No.");
            if POSTransLine.FindFirst() then
                exit(false)
            else
                exit(true);
        end else
            exit(true);
    end;

    procedure Validatecustomer(var POSTransaction: Record "LSC POS Transaction"): boolean
    var
        customer: Record Customer;
        TransactionType: Code[20];
    begin
        TransactionType := POSSESSION.GetValue('TRANS_CODE_TYPE');
        APPOSSESSION.Reset();
        IF APPOSSESSION.FINDFIRST() THEN BEGIN
            //if APPOSSESSION."Transaction Code Type" = APPOSSESSION."Transaction Code Type"::SRC then begin

            if TransactionType = 'SRC' then begin
                customer.Reset();
                customer.SetRange("No.", POSTransaction."Customer No.");
                customer.SetRange("Customer Type", customer."Customer Type"::"SRC");
                if not customer.FindFirst() then begin
                    POSTransaction."Customer No." := '';
                    POSTransaction.modify();
                    codPOSTrans.ErrorBeep('Incorrect Customer Type: Senior Customer Only!');
                    //CheckTrans(POSTransaction);
                    exit(true);
                end ELSE BEGIN
                    /* POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::SRC;
                    POSTransaction."Sale Is Return Sale" := false; */
                    // POSTransaction."Beginning Balance" := 0;
                    //POSTransaction."Booklet No." := '';
                    // POSTransaction.modify();
                end;
            end;
            //if APPOSSESSION."Transaction Code Type" = APPOSSESSION."Transaction Code Type"::PWD then begin
            if TransactionType = 'PWD' then begin
                customer.Reset();
                customer.SetRange("No.", POSTransaction."Customer No.");
                customer.SetRange("Customer Type", customer."Customer Type"::PWD);
                if not customer.FindFirst() then begin
                    POSTransaction."Customer No." := '';
                    POSTransaction.modify();
                    codPOSTrans.ErrorBeep('Incorrect Customer Type: PWD Customer Only!');
                    //CheckTrans(POSTransaction);
                    exit(true);
                end ELSE BEGIN
                    /* POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::PWD;
                    POSTransaction."Sale Is Return Sale" := false; */
                    // POSTransaction."Beginning Balance" := 0;
                    // POSTransaction."Booklet No." := '';
                    // POSTransaction.modify();
                end;
            end;
            //if APPOSSESSION."Transaction Code Type" = APPOSSESSION."Transaction Code Type"::SOLO then begin
            if TransactionType = 'SOLO' then begin
                customer.Reset();
                customer.SetRange("No.", POSTransaction."Customer No.");
                customer.SetRange("Customer Type", customer."Customer Type"::"Solo Parent");
                if not customer.FindFirst() then begin
                    POSTransaction."Customer No." := '';
                    POSTransaction.modify();
                    codPOSTrans.ErrorBeep('Incorrect Customer Type: Solo Parent Customer Only!');
                    //CheckTrans(POSTransaction);
                    exit(true);
                end ELSE BEGIN
                    /* POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::SOLO;
                    POSTransaction."Sale Is Return Sale" := false; 
                    POSTransaction."Beginning Balance" := 0;
                    POSTransaction."Booklet No." := '';*/
                    // POSTransaction.modify();
                end;
            end;
            //if APPOSSESSION."Transaction Code Type" = APPOSSESSION."Transaction Code Type"::ATHL then begin
            if TransactionType = 'ATHL' then begin
                customer.Reset();
                customer.SetRange("No.", POSTransaction."Customer No.");
                customer.SetRange("Customer Type", customer."Customer Type"::Athlete);
                if not customer.FindFirst() then begin
                    POSTransaction."Customer No." := '';
                    POSTransaction.modify();
                    codPOSTrans.ErrorBeep('Incorrect Customer Type: Athlete Customer Only!');
                    //CheckTrans(POSTransaction);
                    exit(true);
                end ELSE BEGIN
                    /* POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::ATHL;
                    POSTransaction."Sale Is Return Sale" := false;
                    POSTransaction."Beginning Balance" := 0;
                    POSTransaction."Booklet No." := ''; */
                    // POSTransaction.modify();
                end;
            end;
            //if APPOSSESSION."Transaction Code Type" = APPOSSESSION."Transaction Code Type"::"Regular Customer" then begin
            if TransactionType = 'REG' then begin
                customer.Reset();
                customer.SetRange("No.", POSTransaction."Customer No.");
                customer.SetRange("Customer Type", customer."Customer Type"::Regular);
                if not customer.FindFirst() then begin
                    POSTransaction."Customer No." := '';
                    //POSTransaction.modify();
                    codPOSTrans.ErrorBeep('Incorrect Customer Type: Regular Customer Only!');
                    //CheckTrans(POSTransaction);
                    exit(true);
                end ELSE BEGIN
                    POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::"Regular Customer";
                    POSTransaction."Sale Is Return Sale" := false;
                    POSTransaction."Beginning Balance" := 0;
                    POSTransaction."Booklet No." := '';
                    // POSTransaction.modify();
                end;
            end;
            //if APPOSSESSION."Transaction Code Type" = APPOSSESSION."Transaction Code Type"::ZERO then begin
            if TransactionType = 'ZERO' then begin
                customer.Reset();
                customer.SetRange("No.", POSTransaction."Customer No.");
                customer.SetRange("Customer Type", customer."Customer Type"::"Zero Rated");
                if not customer.FindFirst() then begin
                    POSTransaction."Customer No." := '';
                    POSTransaction.modify();
                    codPOSTrans.ErrorBeep('Incorrect Customer Type: Zero Rated Customer Only!');
                    //CheckTrans(POSTransaction);
                    exit(true);
                end ELSE BEGIN
                    /* POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::ZERO;
                    POSTransaction."Sale Is Return Sale" := false;
                    POSTransaction."Beginning Balance" := 0;
                    POSTransaction."Booklet No." := ''; */
                    // POSTransaction.modify();
                end;
            end;
            //if APPOSSESSION."Transaction Code Type" = APPOSSESSION."Transaction Code Type"::ZRWH then begin
            if TransactionType = 'ZRWHT' then begin
                customer.Reset();
                customer.SetRange("No.", POSTransaction."Customer No.");
                customer.SetRange("Customer Type", customer."Customer Type"::ZRWHT);
                if not customer.FindFirst() then begin
                    POSTransaction."Customer No." := '';
                    POSTransaction.modify();
                    codPOSTrans.ErrorBeep('Incorrect Customer Type: Zero Rated WHT Customer Only!');
                    //CheckTrans(POSTransaction);
                    exit(true);
                end ELSE BEGIN
                    /* POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::ZRWH;
                    POSTransaction."Sale Is Return Sale" := false;
                    POSTransaction."Beginning Balance" := 0;
                    POSTransaction."Booklet No." := ''; */
                    // POSTransaction.modify();
                end;
            end;
            //if APPOSSESSION."Transaction Code Type" = APPOSSESSION."Transaction Code Type"::VATW then begin
            if TransactionType = 'VATW' then begin
                customer.Reset();
                customer.SetRange("No.", POSTransaction."Customer No.");
                customer.SetRange("Customer Type", customer."Customer Type"::VATW);
                if not customer.FindFirst() then begin
                    POSTransaction."Customer No." := '';
                    POSTransaction.modify();
                    codPOSTrans.ErrorBeep('Incorrect Customer Type: VATWHT Customer Only!');
                    //CheckTrans(POSTransaction);
                    exit(true);
                end ELSE BEGIN
                    /* POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::VATW;
                    POSTransaction."Sale Is Return Sale" := false;
                    POSTransaction."Beginning Balance" := 0;
                    POSTransaction."Booklet No." := ''; */
                    // POSTransaction.modify();
                end;
            end;
            //if APPOSSESSION."Transaction Code Type" = APPOSSESSION."Transaction Code Type"::WHT1 then begin
            if TransactionType = 'WHT' then begin
                customer.Reset();
                customer.SetRange("No.", POSTransaction."Customer No.");
                customer.SetRange("Customer Type", customer."Customer Type"::"Withholding Tax");
                if not customer.FindFirst() then begin
                    POSTransaction."Customer No." := '';
                    POSTransaction.modify();
                    codPOSTrans.ErrorBeep('Incorrect Customer Type: WHT Customer Only!');
                    //CheckTrans(POSTransaction);
                    exit(true);
                end ELSE BEGIN
                    /* POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::WHT1;
                    POSTransaction."Sale Is Return Sale" := false;
                    POSTransaction."Beginning Balance" := 0;
                    POSTransaction."Booklet No." := ''; */
                    // POSTransaction.modify();
                end;
            end;
            if TransactionType = 'MOV' then begin
                customer.Reset();
                customer.SetRange("No.", POSTransaction."Customer No.");
                customer.SetRange("Customer Type", customer."Customer Type"::MOV);
                if not customer.FindFirst() then begin
                    POSTransaction."Customer No." := '';
                    POSTransaction.modify();
                    codPOSTrans.ErrorBeep('Incorrect Customer Type: MOV Customer Only!');
                    //CheckTrans(POSTransaction);
                    exit(true);
                end ELSE BEGIN
                    /* POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::VATW;
                    POSTransaction."Sale Is Return Sale" := false;
                    POSTransaction."Beginning Balance" := 0;
                    POSTransaction."Booklet No." := ''; */
                    // POSTransaction.modify();
                end;
            end;
            if TransactionType = 'NAAC' then begin
                customer.Reset();
                customer.SetRange("No.", POSTransaction."Customer No.");
                customer.SetRange("Customer Type", customer."Customer Type"::NAAC);
                if not customer.FindFirst() then begin
                    POSTransaction."Customer No." := '';
                    POSTransaction.modify();
                    codPOSTrans.ErrorBeep('Incorrect Customer Type: NAAC Customer Only!');
                    //CheckTrans(POSTransaction);
                    exit(true);
                end ELSE BEGIN
                    /* POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::VATW;
                    POSTransaction."Sale Is Return Sale" := false;
                    POSTransaction."Beginning Balance" := 0;
                    POSTransaction."Booklet No." := ''; */
                    // POSTransaction.modify();
                end;
            end;
        END;

        exit(false);
    end;

    procedure ValidateBalance(var REC: Record "LSC POS Transaction"; pCurrInput: text[50]; "Beg Bal Allowance": Decimal)
    var
        begbal: Text;
        begbalAmount: Decimal;
        recLPOSTransLine: Record "LSC POS Trans. Line";
        LSCPOSFunction: Record "LSC POS Func. Profile";
        LStoreSetup: Record "LSC Store";
        POSMenuLine2: Record "LSC POS Menu Line";
        customer: Record Customer;
    begin
        LStoreSetup.GET(POSSESSION.StoreNo);
        if not LSCPOSFunction.GET(POSSESSION.GetValue('LSFUNCPROFILE')) then
            LSCPOSFunction.GET(StoreSetup."Functionality Profile");
        if pCurrInput <> '' then
            Evaluate(begbalAmount, pCurrInput);

        if (begbalAmount > 0) then begin
            // if (not (begbalAmount <= 1) and not (begbalAmount > LSCPOSFunction."Beg Bal Allowance") and (begbalAmount <> 0)) then begin
            if ("Beg Bal Allowance" >= begbalAmount) AND ("Beg Bal Allowance" <> 0) then begin
                REC."Beginning Balance" := begbalAmount;
                recLpostransLine.RESET;
                recLpostransLine.SETRANGE("Receipt No.", REC."Receipt No.");
                if recLpostransLine.FINDFIRST THEN
                    REPEAT
                        if (recLPOSTransLine."Orig. Total Disc. %" <> 0) AND (recLPOSTransLine."Discount Amount" <> 0) THEN
                            begbalAmount := begbalAmount - (recLpostransLine.Amount + recLPOSTransLine."Discount Amount");
                    UNTIL recLpostransLine.NEXT = 0;
                if begbalAmount < 0 then
                    REC."Current Balance" := 0
                else
                    REC."Current Balance" := begbalAmount;
                APPOSSESSION.Reset();
                if APPOSSESSION.FindFirst() then begin
                    APPOSSESSION."Beg Bal" := true;
                    APPOSSESSION.Modify();
                end else begin
                    APPOSSESSION.Init();
                    APPOSSESSION."Beg Bal" := true;
                    APPOSSESSION.Insert();
                end;
                customer.get(Rec."Customer No.");
                customer.CalcFields("Beg Bal_");
                // if customer."Beg Bal_" < begbalAmount then begin
                //     codPOSTrans.PosErrorBanner(StrSubstNo('Invalid amount the remaining allowance is %1', customer."Beg Bal_"));
                //     codPOSTrans.OpenNumericKeyboard('Beginning Balance', format(customer."Beg Bal_", 0, '<Sign><Integer Thousand><Decimal,3>'), 99);
                // end else begin
                REC.MODifY;
                codPOSTrans.OpenNumericKeyboard('Enter Booklet No.', '', 98);
                // end;

                // end else begin
                //     codPOSTrans.PosErrorBanner(StrSubstNo('Invalid amount the maximum allowance is %1', LSCPOSFunction."Beg Bal Allowance"));
                //     customer.get(Rec."Customer No.");
                //     // customer.CalcFields("Beg Bal_");
                //     codPOSTrans.OpenNumericKeyboard('Beginning Balance', format(customer."Beg Bal_", 0, '<Sign><Integer Thousand><Decimal,3>'), 99);
            end else begin
                if "Beg Bal Allowance" > 0 then begin
                    REC."Current Balance" := 0;
                    REC.MODifY;
                    codPOSTrans.PosErrorBanner(StrSubstNo('Invalid amount the maximum allowance is %1', "Beg Bal Allowance"));
                    //codPOSTrans.CancelPressed(false, 0);
                    "Beg Bal Allowance" := GetBegbal(Today, rec."Customer No.");
                    codPOSTrans.OpenNumericKeyboard('Beginning Balance', format(0.00, 0, '<Sign><Integer Thousand><Decimal,3>'), 99);
                    // POSMenuLine2.Reset();
                    // POSMenuLine2.SetRange(Command, 'BEGBALDISC');
                    // if POSMenuLine2.FindFirst() then
                    //     codPOSTrans.RunCommand(POSMenuLine2);
                end else begin
                    APPOSSESSION."Beg Bal" := True;
                    APPOSSESSION.Modify();
                    codPOSTrans.PosErrorBanner(StrSubstNo('Amount reach the maximum allowance'));
                    //codPOSTrans.CancelPressed(false, 0);
                end;
            end;
        end
        else begin
            APPOSSESSION."Beg Bal" := True;
            APPOSSESSION.Modify();
            codPOSTrans.PosErrorBanner(StrSubstNo('Beginning Balance is required'));
            codPOSTrans.OpenNumericKeyboard('Beginning Balance', format(0.00, 0, '<Sign><Integer Thousand><Decimal,3>'), 99);
        end;

        begbal := '';
        REC.MODifY;
        Commit();
        codPOSTrans.SetCurrInput(begbal);
    end;


    local procedure UpdateDiscount(var REC: Record "LSC POS Transaction")
    var
        recLPOSTransLine: Record "LSC POS Trans. Line";
        Disc_Amount: Decimal;
    begin
        recLpostransLine.RESET;
        recLpostransLine.SETRANGE("Receipt No.", REC."Receipt No.");
        if recLpostransLine.FINDFIRST then
            repeat
                Disc_Amount := Disc_Amount + (recLpostransLine.Amount + recLPOSTransLine."Discount Amount");
            until recLPOSTransLine.next = 0;

        if REC."Transaction Code Type" in [REC."Transaction Code Type"::SOLO, REC."Transaction Code Type"::PWD, REC."Transaction Code Type"::"SRC"] then
            if REC."Current Balance" < Disc_Amount then begin

            end;
    end;

    procedure InsertLinediscount(REC: Record "LSC POS Transaction")
    var
        recLPOSTransLine: Record "LSC POS Trans. Line";
        RecLitem: Record Item;
    begin
        recLPOSTransLine.SetRange("Receipt No.", REC."Receipt No.");
        recLPOSTransLine.SetRange("Entry Type", recLPOSTransLine."Entry Type"::Item);
        recLPOSTransLine.SetFilter("Entry Status", '<>%1', recLPOSTransLine."Entry Status"::Voided);

        if recLPOSTransLine.FindSet() then
            repeat
                if RecLitem.Get(recLPOSTransLine.Number) and (RecLitem."Discount %" > 0) then begin
                    case REC."Transaction Code Type" of
                        REC."Transaction Code Type"::"SRC":
                            recLPOSTransLine."Discount Type" := recLPOSTransLine."Discount Type"::SRC;
                        REC."Transaction Code Type"::PWD:
                            recLPOSTransLine."Discount Type" := recLPOSTransLine."Discount Type"::PWD;
                        REC."Transaction Code Type"::SOLO:
                            recLPOSTransLine."Discount Type" := recLPOSTransLine."Discount Type"::SOLO;
                        REC."Transaction Code Type"::ATHL:
                            recLPOSTransLine."Discount Type" := recLPOSTransLine."Discount Type"::ATHL;
                        REC."Transaction Code Type"::MOV:
                            recLPOSTransLine."Discount Type" := recLPOSTransLine."Discount Type"::MOV;
                        REC."Transaction Code Type"::NAAC:
                            recLPOSTransLine."Discount Type" := recLPOSTransLine."Discount Type"::NAAC;
                    end;
                    recLPOSTransLine.Modify();
                end;
            until recLPOSTransLine.Next() = 0;
    end;

    internal procedure UpdateFixedFilterForCustomer(NewFilter: Text[30])
    var
        POSDataTable: Record "LSC POS Data Table Columns";
    begin
        POSDataTable.reset;
        POSDataTable.SetRange("Data Table ID", 'CUSTOMER');
        POSDataTable.SetRange("Field No.", 50004);

        if POSDataTable.FindFirst() then
            repeat
                POSDataTable."Fixed Filter" := NewFilter;
                POSDataTable.Modify();
            until POSDataTable.Next() = 0;
    end;

    [IntegrationEvent(true, false)]
    internal procedure APOnBeforeValidateChangeQty(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Proceed: Boolean; var ErrorText: Text[250])
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    internal procedure OnAfterTotalCommand(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var POSMenuLine: Record "LSC POS Menu Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure APOnBeforeRunCommand(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var POSMenuLine: Record "LSC POS Menu Line"; var isHandled: Boolean; TenderType: Record "LSC Tender Type"; var CusomterOrCardNo: Code[20])
    begin
    end;
    //VINCENT20251209 NO CANCEL IF CUSTOMER ALREADY SELECTED
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeCancel, '', false, false)]
    local procedure "LSC POS Transaction Events_OnBeforeCancel"(var POSTransaction: Record "LSC POS Transaction"; var CurrInput: Text; var Hard: Boolean)
    begin
        //20251211
        IF format(POSTransaction."Transaction Code Type") <> 'REG' THEN begin
            CurrInput := 'NOT PROCEED';
            Hard := false;
        end;
    end;
    //VINCENT20251215 PROCESSING GHL TO API
    procedure GHLProcess(RecPOSTrans: Record "LSC POS Transaction"; Type: Text[30])
    var
        LClient: HttpClient;
        LContent: HttpContent;
        LHeaders: HttpHeaders;
        LResponse: HttpResponseMessage;
        LResponseText: Text[99];
    begin
        LContent.WriteFrom('{"Receipt No.": ' + Format(RecPOSTrans."Receipt No.") + '}');
        LClient.Post('http://localhost:8000/fetch-api.php?function=' + Type, LContent, LResponse);
        if LResponse.IsSuccessStatusCode() then begin
            LResponse.Content.ReadAs(LResponseText);
            Message('%1', LResponseText);
        end
    end;
    //VINCENT20251216 GET AND CHECK BEGBAL
    procedure GetBegbal(TransDate: Date; CustomerNo: Code[50]) Val: Decimal
    var
        recEligibilityLedger: Record DiscountEligibilityLedger;
        recPOSFunctionality: Record "LSC POS Func. Profile";
    begin
        /*  recEligibilityLedger.Reset();
         recEligibilityLedger.SetRange(recEligibilityLedger."Customer No.", CustomerNo);
         recEligibilityLedger.SetFilter(
             recEligibilityLedger."Transaction Date",
             '%1..%2',
             CalcDate('<-CM>', TransDate),
             CalcDate('<CM>', TransDate)
         );
         if recEligibilityLedger.FindFirst() then begin
             recEligibilityLedger.CalcSums(Amount);
             recPOSFunctionality.Reset();
             recPOSFunctionality.SetFilter(recPOSFunctionality."Profile ID", '%1', '#AI-RETAIL');
             if recPOSFunctionality.FindFirst() then
                 exit(abs(recEligibilityLedger.Amount - recPOSFunctionality."Beg Bal Allowance"));
         end else begin */
        recPOSFunctionality.Reset();
        recPOSFunctionality.SetFilter(recPOSFunctionality."Profile ID", '%1', '#AI-RETAIL');
        if recPOSFunctionality.FindFirst() then
            exit(recPOSFunctionality."Beg Bal Allowance");
        //end;

    end;
    //VINCENT20251216 INSERTING PAYMENT LINE
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterInsertPaymentLine, '', false, false)]
    local procedure "LSC POS Transaction Events_OnAfterInsertPaymentLine"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; var SkipCommit: Boolean)
    var
        recLEligibilityLedger: Record DiscountEligibilityLedger;
    begin
        CASE POSTransaction."Transaction Code Type" OF
            POSTransaction."Transaction Code Type"::"SRC", POSTransaction."Transaction Code Type"::PWD:
                begin
                    recLEligibilityLedger.Init();
                    recLEligibilityLedger."Receipt No." := POSTransaction."Receipt No.";
                    recLEligibilityLedger."Customer No." := POSTransaction."Customer No.";
                    recLEligibilityLedger."Customer Type" := POSTransaction."Transaction Code Type";
                    recLEligibilityLedger.Amount := POSTransaction."Beginning Balance";
                    recLEligibilityLedger.Store := POSTransaction."Store No.";
                    recLEligibilityLedger.Terminal := POSTransaction."POS Terminal No.";
                    recLEligibilityLedger."Entry Type" := recLEligibilityLedger."Entry Type"::Sales;
                    recLEligibilityLedger."Transaction Date" := POSTransaction."Trans. Date";
                    recLEligibilityLedger."Transaction Time" := POSTransaction."Trans Time";
                    recLEligibilityLedger.Insert(true);
                end;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnProcessOtherInfoTrigger, '', false, false)]
    local procedure "LSC POS Transaction Events_OnProcessOtherInfoTrigger"(SubInfo: Record "LSC Information Subcode"; Info: Record "LSC Infocode"; var POSTr: Record "LSC POS Transaction"; POSTerminal: Record "LSC POS Terminal"; CurrInput: Text; var isHandled: Boolean)
    var
        IntCurrInput: Integer;
    begin
        // POSTransactionHeader.Get(POSTr."Receipt No."); 
        EVALUATE(IntCurrInput, CurrInput);
        POSTr."Refund Reason" := IntCurrInput;
        POSTr.MODIFY;
        // POSTransactionHeader."Refund Reason" := IntCurrInput;
    end;

    var
        POSSESSION: Codeunit "LSC POS Session";
        APPOSSESSION, APPOSSESSION_ : Record "AP POSSESSIONS";
        POSGUI: Codeunit "LSC POS GUI";
        codPOSTrans: Codeunit "LSC POS Transaction";
        STATE: Code[10];
        Balance: Decimal;
        RealBalance: Decimal;
        STATE_SALES: Code[10];
        STATE_PAYMENT: Code[10];
        STATE_TENDOP: Code[10];
        POSAddFunc: Codeunit "LSC POS Additional Functions";
        text90001: Label 'There are no configuration for discount codes.\Kindly contact your administrator.';
        SpecialCharsErr: Label 'Invalid value in Amount';
        StoreSetup: Record "LSC Store";
        DiscType: Enum "LSC POS Trans. Per. Disc. Type";
        POSFunctions: Codeunit "LSC POS Functions";
        POSLINES: Codeunit "LSC POS Trans. Lines";
        ctrbegbal_booklet: Integer;
        NewLine: Record "LSC POS Trans. Line";
        CurrGuest, CurrMenuType, CurrMenuTypeDeal : Integer;
        askuser, askuser2 : Boolean;
        APEventSubscriber: Codeunit APEventSubscriber;
        g_balance: decimal;
}