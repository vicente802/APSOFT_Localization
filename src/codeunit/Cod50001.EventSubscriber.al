codeunit 50001 "APEventSubscriber"
{
    [IntegrationEvent(false, false)]
    internal procedure OnGHLCall(var Reciept: Code[20]; var Terminal: Code[20]; var Staffid: Code[20]; var PaymentAmount: Decimal; var Cardcode: Code[10])
    begin

    end;
    //OnBeforeInsertPaymentLine
    [IntegrationEvent(false, false)]
    internal procedure OnAPBeforeInsertPaymentLine(var "Acquirer Code": Code[20])
    begin

    end;

    [IntegrationEvent(false, false)]
    internal procedure OnProcessGHL(var IsHandled: Boolean; var Rec: Record "LSC POS Transaction")
    begin

    end;

    [IntegrationEvent(false, false)]
    internal procedure OnArchiveGHL(var IsHandled: Boolean)
    begin

    end;

    trigger OnRun()
    begin

    end;

    var //Global Variable
        AmountDisplayFormat: Text[80];
        QtyDisplayFormat: Text[80];
        PriceDisplayFormat: Text[80];
        WeightDisplayFormat: Text[80];
        AppMan: Codeunit "LSC AutoFormatMgt Ext.";
        POSSESSION: Codeunit "LSC POS Session";
        StoreSetup: Record "LSC Store";
        PosFuncProfile: Record "LSC POS Func. Profile";
        codPOSTrans: Codeunit "LSC POS Transaction";
        APPOSTransaction: Codeunit "AP POS Transaction";
        APPOSSESSION: Record "AP POSSESSIONS";
        DiscType: Enum "LSC POS Trans. Per. Disc. Type";
    //Start Local Procedure

    procedure FormatWeight(Dec: Decimal; UOM: Code[10]): Text[30]
    begin
        if WeightDisplayFormat = '' then
            WeightDisplayFormat := AppMan.DoAutoFormatTranslateExt(99001450, UOM);
        exit(Format(Dec, 0, WeightDisplayFormat) + LowerCase(UOM));
    end;


    procedure FormatPricePrUnit(Dec: Decimal; UOM: Code[10]): Text[30]
    begin
        if POSSESSION.PlacementOfLCYInWeightAfterAmount then
            exit(FormatPrice(Dec) + POSSESSION.GetValue('CURRSYM') + '/' + LowerCase(UOM))
        else
            exit(POSSESSION.GetValue('CURRSYM') + FormatPrice(Dec) + '/' + LowerCase(UOM));
    end;


    procedure FormatPrice(Dec: Decimal): Text[30]
    begin
        if PriceDisplayFormat = '' then
            PriceDisplayFormat := AppMan.DoAutoFormatTranslateExt(99001452, StoreSetup."No.");
        exit(Format(Dec, 0, PriceDisplayFormat));
    end;


    procedure AdjustAmount(var Value: Decimal)
    var
        TmpInt: Integer;
    begin
        OnBeforeAdjustAmount(Value);
        if PosFuncProfile."Decimals in Entry" > 0 then begin
            TmpInt := PosFuncProfile."Decimals in Entry";
            Value := Round(Value * Power(10, -TmpInt));
        end;
    end;


    procedure RoundAmount(Dec: Decimal): Decimal
    begin
        exit(Round(Dec, PosFuncProfile."Amount Rounding to"));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAdjustAmount(var Value: Decimal)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeVoidAndCopyTransaction, '', false, false)]
    local procedure "LSC POS Transaction Events_OnBeforeVoidAndCopyTransaction"(var Transaction: Record "LSC Transaction Header"; var IsHandled: Boolean)
    var
        APPOSSESSION: Record "AP POSSESSIONS";
    begin
        APPOSSESSION.Reset();
        if APPOSSESSION.FindFirst() then begin
            APPOSSESSION."Trans Type" := Transaction."Transaction Code Type";
            APPOSSESSION.modify();
        end else begin
            APPOSSESSION.Init();
            APPOSSESSION."Trans Type" := Transaction."Transaction Code Type";
            APPOSSESSION.Insert();
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterInsertPaymentLine', '', true, true)]
    local procedure OnAfterInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10])
    begin
        if (POSTransLine.Number IN ['23', '24']) then
            POSTransLine."Value[1]" := '  ' + POSTransLine.Description
        else
            POSTransLine."Value[1]" := POSTransLine.Description;

        if (POSTransLine."Return Slip No." <> '') then begin
            if (POSTransLine.Number IN ['23', '24']) then
                POSTransLine."Value[2]" := Format(Abs(POSTransLine.Amount), 0, '<Sign><Integer Thousand><Decimals,3>')
            else
                POSTransLine."Value[2]" := '-' + Format(Abs(POSTransLine.Amount), 0, '<Sign><Integer Thousand><Decimals,3>');
        end else begin
            if (POSTransLine.Number IN ['23', '24']) and (POSTransaction."Transaction Code Type" = POSTransaction."Transaction Code Type"::WHT1) then
                POSTransLine."Value[2]" := Format(Abs(POSTransLine.Amount), 0, '<Sign><Integer Thousand><Decimals,3>')
            else
                POSTransLine."Value[2]" := '-' + Format(Abs(POSTransLine.Amount), 0, '<Sign><Integer Thousand><Decimals,3>');
        end;

        POSTransLine."Value[3]" := ' ';
        POSTransLine.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", OnAfterInsertTenderDeclTransaction, '', false, false)]
    local procedure "LSC POS Post Utility_OnAfterInsertTenderDeclTransaction"(ReceiptNo: Code[20])
    begin
        POSSESSION.ClearManagerID();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterOpenDrawerPressed, '', false, false)]
    local procedure "LSC POS Transaction Events_OnAfterOpenDrawerPressed"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var RoleID: Code[10])
    begin
        POSSESSION.ClearManagerID();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Refund Mgt.", OnCopyTransRefundInfoBeforeModifyPOSTransaction, '', false, false)]
    local procedure "LSC POS Refund Mgt._OnCopyTransRefundInfoBeforeModifyPOSTransaction"(var POSTransaction: Record "LSC POS Transaction"; TransactionHeader: Record "LSC Transaction Header")
    VAR
        Transaction2: RECORD "LSC Transaction Header";
    begin
        Transaction2.Reset();
        Transaction2.SetRange("Receipt No.", TransactionHeader."Receipt No.");
        if Transaction2.FindFirst() then begin
            POSTransaction."Transaction Code Type" := Transaction2."Transaction Code Type";
            POSTransaction."Zero Rated Amount" := -1 * Transaction2."Zero Rated Amount";
            POSTransaction.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction", OnProcessRefundSelection, '', false, false)]
    local procedure "LSC POS Transaction_OnProcessRefundSelection"(OriginalTransaction: Record "LSC Transaction Header"; var POSTransaction: Record "LSC POS Transaction"; isPostVoid: Boolean)
    var
        POSTransLine_: Record "LSC POS Trans. Line";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
    begin
        TransSalesEntry.Reset();
        TransSalesEntry.SetRange("Receipt No.", OriginalTransaction."Receipt No.");
        if TransSalesEntry.FindFirst() then
            repeat
                POSTransLine_.Reset();
                POSTransLine_.SetRange("Receipt No.", POSTransaction."Receipt No.");
                POSTransLine_.SetRange("Entry Type", POSTransLine_."Entry Type"::Item);
                POSTransLine_.SetRange(Number, TransSalesEntry."Item No.");
                POSTransLine_.SetRange(POSTransLine_."VAT Code", 'VZ');
                if POSTransLine_.FindFirst() then begin
                    // POSTransLine.Price := Abs(TransSalesEntry."Orig. Cost Price") * Abs(TransSalesEntry.Quantity);
                    // POSTransLine.Amount := Abs(TransSalesEntry."Net Price") * Abs(TransSalesEntry.Quantity);
                    // POSTransLine."Net Price" := TransSalesEntry."Net Price";
                    // POSTransLine_."Net Amount" := Abs(TransSalesEntry."Orig. Cost Price") * Abs(TransSalesEntry.Quantity);
                    POSTransLine_."VAT Amount" := 0;
                    POSTransLine_."VAT %" := 0;
                    POSTransLine_.Modify();
                end;
            //  codPOSTrans.CalcTotals();
            until TransSalesEntry.next() = 0;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterItemLine, '', false, false)]
    local procedure "LSC POS Transaction Events_OnAfterItemLine"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    var
        PosPriceUtil: Codeunit "LSC POS Price Utility";
    begin
        /* PosPriceUtil.InsertTransDiscPercent(POSTransLine, 0, DiscType::Line, '');
        POSTransLine.Validate(POSTransLine."Line Disc. %", 0); */
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeItemLine, '', false, false)]
    local procedure "LSC POS Transaction Events_OnBeforeItemLine"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    var
        POSTransLine_: Record "LSC POS Trans. Line";
    begin

        if (POSTransaction."SRC Applied Counter" > 0) or (POSTransaction."PWD Applied Counter" > 0) then begin
            codPOSTrans.SetInfoTextDescription('Disc. alredy applied', 'Please remove Discount first');
            codPOSTrans.CancelPressed(false, 0);
            exit;
        end;

        APPOSSESSION.Reset();
        if APPOSSESSION.FindFirst() then begin
            APPOSSESSION."POST COMMAND" := '';
            APPOSSESSION."POST PARAMETER" := '';
            APPOSSESSION."Card type Param" := '';
            APPOSSESSION."VOID TR" := false;
            APPOSSESSION.Modify();
        end else begin
            APPOSSESSION.Init();
            APPOSSESSION."POST COMMAND" := '';
            APPOSSESSION."POST PARAMETER" := '';
            APPOSSESSION."Card type Param" := '';
            APPOSSESSION."VOID TR" := false;
            APPOSSESSION.Insert();
        end;

        POSTransLine_.Reset();
        POSTransLine_.SetRange(POSTransLine_."Text Type", POSTransLine_."Text Type"::"Cust. Text");
        if POSTransLine_.FindFirst() then
            repeat
                POSTransLine_.Delete();
            until POSTransLine_.Next() = 0;

        if APPOSTransaction.GetOpenEOD THEN   // Check if previous day is not yet perform eod
            EXIT;

        if APPOSTransaction.CheckifEODProcessToday THEN //if already performed EOD
            EXIT;
        if APPOSTransaction.CheckifEOSrocessToday THEN //if already performed Cashier Reading
            EXIT;
        if APPOSTransaction.ValidateAllowedFloatEntry THEN
            EXIT;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeTenderDecl', '', false, false)]
    local procedure OnBeforeTenderDecl(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line");
    begin
        if APPOSTransaction.GetOpenEOD THEN   // Check if previous day is not yet perform eod
                 begin
            codPOSTrans.CancelPressed(true, 0);
            exit;
        end;
        if APPOSTransaction.CheckifEODProcessToday THEN //if already performed EOD
                begin
            codPOSTrans.CancelPressed(true, 0);
            exit;
        end;
        if APPOSTransaction.CheckifEOSrocessToday THEN //if already performed Cashier Reading
                begin
            codPOSTrans.CancelPressed(true, 0);
            exit;
        end;
        if APPOSTransaction.ValidateAllowedFloatEntry THEN begin
            codPOSTrans.CancelPressed(true, 0);
            exit;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeTenderOp', '', false, false)]
    local procedure OnBeforeTenderOp(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line");
    begin
        if APPOSTransaction.GetOpenEOD THEN   // Check if previous day is not yet perform eod
         begin
            codPOSTrans.CancelPressed(true, 0);
            exit;
        end;
        if APPOSTransaction.CheckifEODProcessToday THEN //if already performed EOD
                 begin
            codPOSTrans.CancelPressed(true, 0);
            exit;
        end;
        if APPOSTransaction.CheckifEOSrocessToday THEN //if already performed Cashier Reading
                  begin
            codPOSTrans.CancelPressed(true, 0);
            exit;
        end;
        if APPOSTransaction.ValidateAllowedFloatEntry THEN begin
            codPOSTrans.CancelPressed(true, 0);
            exit;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeRemoveTender, '', false, false)]
    local procedure "LSC POS Transaction Events_OnBeforeRemoveTender"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    begin
        if APPOSTransaction.GetOpenEOD THEN   // Check if previous day is not yet perform eod
      begin
            codPOSTrans.CancelPressed(true, 0);
            exit;
        end;
        if APPOSTransaction.CheckifEODProcessToday THEN //if already performed EOD
                begin
            codPOSTrans.CancelPressed(true, 0);
            exit;
        end;
        if APPOSTransaction.CheckifEOSrocessToday THEN //if already performed Cashier Reading
          begin
            codPOSTrans.CancelPressed(true, 0);
            exit;
        end;
        if APPOSTransaction.ValidateAllowedFloatEntry THEN begin
            codPOSTrans.CancelPressed(true, 0);
            exit;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeFloat, '', false, false)]
    local procedure "LSC POS Transaction Events_OnBeforeFloat"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    begin
        if APPOSTransaction.GetOpenEOD THEN   // Check if previous day is not yet perform eod
                 begin
            codPOSTrans.CancelPressed(true, 0);
            exit;
        end;
        if APPOSTransaction.CheckifEODProcessToday THEN //if already performed EOD
                begin
            codPOSTrans.CancelPressed(true, 0);
            exit;
        end;
        if APPOSTransaction.CheckifEOSrocessToday THEN //if already performed Cashier Reading
                 begin
            codPOSTrans.CancelPressed(true, 0);
            exit;
        end;
        if APPOSTransaction.ValidateAllowedFloatEntry THEN begin
            codPOSTrans.CancelPressed(true, 0);
            exit;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeInsertPaymentLine, '', false, false)]
    local procedure "LSC POS Transaction Events_OnBeforeInsertPaymentLine"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; Balance: Decimal; PaymentAmount: Decimal; STATE: Code[10]; var isHandled: Boolean)
    var
        tempPaymentAmount: Decimal;
        TenderTypeCardSetup: record "LSC Tender Type Card Setup";
        "Acquirer Code": Code[20];
        GlobalRef: Record "Global References";
    begin
        OnAPBeforeInsertPaymentLine("Acquirer Code");//, POSTransLine, CurrInput, TenderTypeCode, Balance, PaymentAmount, STATE, isHandled);
        if "Acquirer Code" <> '' then begin
            GlobalRef.Reset();
            GlobalRef.SetRange("Entry Type", GlobalRef."Entry Type"::"GHL Acquirer");
            GlobalRef.SetRange(Code, "Acquirer Code");
            if GlobalRef.FindFirst() then begin
                APPOSSESSION.Reset();
                if APPOSSESSION.FindFirst() then begin
                    APPOSSESSION."Card type Param" := GlobalRef."Tender Type Card Setup";
                    APPOSSESSION.Modify();
                end else begin
                    APPOSSESSION.Init();
                    APPOSSESSION."Card type Param" := GlobalRef."Tender Type Card Setup";
                    APPOSSESSION.Insert();
                end;
            end;
        end;

        if TenderTypeCode = '3' then begin
            APPOSSESSION.Reset();
            IF APPOSSESSION.FindFirst() then begin
                IF APPOSSESSION."Card type Param" <> '' THEN BEGIN
                    TenderTypeCardSetup.Reset();
                    TenderTypeCardSetup.SetRange("Card No.", APPOSSESSION."Card type Param");
                    if TenderTypeCardSetup.findfirst() then begin
                        POSTransLine.Description := TenderTypeCardSetup.Description;
                    end;
                end;
            end;
        end;
        if Abs(PaymentAmount) <= 0 then begin
            codPOSTrans.ErrorBeep('Payment must be greater than zero!');
            isHandled := true;
            codPOSTrans.CancelPressed(true, 0);
            codPOSTrans.SetPOSState('PAYMENT');
            codPOSTrans.SetFunctionMode('PAYMENT');
            exit;
        end;

        if Format(PaymentAmount) = '' then begin
            codPOSTrans.ErrorBeep('Invalid amount');
            isHandled := true;
            codPOSTrans.CancelPressed(true, 0);
            codPOSTrans.SetPOSState('PAYMENT');
            codPOSTrans.SetFunctionMode('PAYMENT');
            exit;
        end;

        if not Evaluate(PaymentAmount, Format(PaymentAmount)) then begin
            codPOSTrans.ErrorBeep('Invalid amount');
            isHandled := true;
            codPOSTrans.CancelPressed(true, 0);
            codPOSTrans.SetPOSState('PAYMENT');
            codPOSTrans.SetFunctionMode('PAYMENT');
            exit;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeCancel, '', false, false)]
    local procedure "LSC POS Transaction Events_OnBeforeCancel"(var POSTransaction: Record "LSC POS Transaction"; var CurrInput: Text; var Hard: Boolean)
    var
        RecLTransLine: Record "LSC POS Trans. Line";
        POSMenuLine2: Record "LSC POS Menu Line";
    begin
        if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::DEPOSIT) then begin
            if POSTransaction."Customer No." = '' then begin
                POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::REG;
                POSTransaction."Sale Is Return Sale" := false;
            end;
        end
        else begin
            RecLTransLine.Reset();
            RecLTransLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
            if not RecLTransLine.FindFirst() then begin
                POSTransaction."Transaction Code Type" := POSTransaction."Transaction Code Type"::REG;
                POSTransaction."Sale Is Return Sale" := false;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterSelectCustomer, '', false, false)]
    local procedure "LSC POS Transaction Events_OnAfterSelectCustomer"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text)
    var
        POSTransLine_: Record "LSC POS Trans. Line";
        customer: Record Customer;
        POSMenuLine2: Record "LSC POS Menu Line";

    begin
        POSTransLine_.Reset();
        POSTransLine_.SetRange(POSTransLine_."Text Type", POSTransLine_."Text Type"::"Cust. Text");
        if POSTransLine_.FindFirst() then
            repeat
                POSTransLine_.Delete();
            until POSTransLine_.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnBeforeValidateCustomer, '', false, false)]
    local procedure "LSC POS Transaction Events_OnBeforeValidateCustomer"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var CustomerOrCardNo: Code[20]; var IsHandled: Boolean)
    var
        customer: Record Customer;
        TransactionType: Code[20];
    begin
        TransactionType := POSSESSION.GetValue('TRANS_CODE_TYPE');
        if APPOSTransaction.validatecustomer(POSTransaction) then begin
            APPOSTransaction.CheckTrans(POSTransaction);
            IsHandled := true;
        end;
        APPOSSESSION.Reset();
        IF APPOSSESSION.FINDFIRST() THEN BEGIN
            //if APPOSSESSION."Transaction Code Type" <> APPOSSESSION."Transaction Code Type"::REG then begin
            if TransactionType <> 'REG' then begin

            end;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterInsertPaymentLine, '', false, false)]
    local procedure "LSC POS Transaction Events_OnAfterInsertPaymentLine"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10]; var SkipCommit: Boolean)
    var
        tmpStr: Text[50];
        i, cardlen : Integer;
    begin
        tmpStr := postransaction."AP Credit Card Number";
        // for i := 1 to StrLen(tmpStr) - 4 do
        //     tmpStr[i] := '*';

        if (POSTransLine."Entry Type" = POSTransLine."Entry Type"::Payment) and (POSTransLine.Number = '3') then begin
            POSTransLine."Card/Customer/Coup.Item No" := CopyStr(tmpStr, 1, 3) + '*********' + CopyStr(tmpStr, 13, 4);// postransaction."AP Credit Card Number";

            if tmpStr <> '' then begin
                cardlen := StrLen(tmpStr) - 4;
                if StrLen(tmpStr) > 4 then
                    POSTransLine."Card/Customer/Coup.Item No" := CopyStr(tmpStr, 1, 3) + '*********' + CopyStr(tmpStr, Abs(cardlen), 5);// postransaction."AP Credit Card Number";

                if StrLen(tmpStr) <= 4 then
                    POSTransLine."Card/Customer/Coup.Item No" := '************' + CopyStr(tmpStr, 1, 4);// postransaction."AP Credit Card Number";
            end;

            POSTransLine."Card Approval Code" := CopyStr(postransaction."AP Approval Code", 1, 20);
            APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then begin
                POSTransLine.Validate(Amount, APPOSSESSION."Card Tender Amount");
                POSTransLine."Card Type" := APPOSSESSION."Card type Param";
            end;
        end;

        if (POSTransLine."Entry Type" = POSTransLine."Entry Type"::Payment) and (POSTransLine.Number = '2') or
            (POSTransLine."Entry Type" = POSTransLine."Entry Type"::Payment) and (POSTransLine.Number = '8') then begin

            POSTransLine."Card/Customer/Coup.Item No" := tmpStr;
            APPOSSESSION.Reset();
            if APPOSSESSION.FindFirst() then
                if (POSTransLine.Number = '8') then
                    POSTransLine."Current Balance" := APPOSSESSION."Current Balance";

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterTransactionTendered2, '', false, false)]
    local procedure "LSC POS Transaction Events_OnAfterTransactionTendered2"(var IsHandled: Boolean)

    begin
        APPOSSESSION.Reset();
        if APPOSSESSION.FindFirst() then
            if APPOSSESSION."VOID TR" then
                IsHandled := true;

        codPOSTrans.SetPOSState('SALES');
        codPOSTrans.SetFunctionMode('ITEM');
        codPOSTrans.SelectDefaultMenu();
        codPOSTrans.CancelPressed(true, 0);
        exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", OnAfterValidateItemLine, '', false, false)]
    local procedure "LSC POS Transaction Events_OnAfterValidateItemLine"(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var Proceed: Boolean)
    var
    begin
        //POSTransLine."Line Disc. %" := 0;
        if ((POSTransaction."Transaction code type" = POSTransaction."Transaction code type"::PWD) or (POSTransaction."Transaction code type" = POSTransaction."Transaction code type"::SRC)) and (POSTransaction."Total Pressed") then begin
            Proceed := false;
            codPOSTrans.ErrorBeep('You cannot Scan item in after total press.');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Controller", OnLoadMenu, '', false, false)]
    local procedure OnLoadMenu(var MenuID: Code[20]; var Handled: Boolean)
    begin
        if MenuID = 'AI-TRANS-TYPE' then begin
            if POSSESSION.GetValue('XREAD') = 'TRUE' then
                Handled := true;
            if POSSESSION.GetValue('ZFIRST') = 'TRUE' then
                Handled := true;
            if POSSESSION.GetValue('ZREAD') = 'TRUE' then
                Handled := true;
        end;
    end;
}