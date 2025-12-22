codeunit 50003 "LSCPOSPriceUtilityExt"
{
    trigger OnRun()
    begin

    end;

    var
        Item: Record Item;
        PosFunctions: Codeunit "LSC POS Functions";
        LocalizationExt: Codeunit "LSC Retail Localization Ext.";
        POSPriceUtility: Codeunit "LSC POS Price Utility";
        POSOfferExtUtility: Codeunit "LSC POS Offer Ext. Utility";
        RetailSetup: Record "LSC Retail Setup";
        PosTrans: Record "LSC POS Transaction";
        PosFuncProfile: Record "LSC POS Func. Profile";
        MyPosFunctions: Codeunit APEventSubscriber;
        MyPOSOfferExtUtility: codeunit LSCPOSOfferExtUtilityExt;
        Text001: Label 'Total Discount';

    procedure GetTransDisc(var POSTransLine: Record "LSC POS Trans. Line"; AllDisc: Boolean; DiscType: Enum "LSC POS Trans. Per. Disc. Type") PerDisc: Code[20]
    var
        POSTransPerDisc: Record "LSC POS Trans. Per. Disc. Type";
        PeriDiscPer: Decimal;
        PeriDiscAmo: Decimal;
        CustDiscPer: Decimal;
        InfoDiscPer: Decimal;
        TotaDiscPer: Decimal;
        TotaDiscAmo: Decimal;
        LineDiscPer: Decimal;
    begin
        Clear(PerDisc);

        if POSTransLine."Entry Type" <> POSTransLine."Entry Type"::Item then
            exit('');

        PeriDiscPer := 0;
        PeriDiscAmo := 0;
        CustDiscPer := 0;
        InfoDiscPer := 0;
        TotaDiscPer := 0;
        TotaDiscAmo := 0;
        LineDiscPer := 0;

        Clear(POSTransPerDisc);

        if not AllDisc then begin
            POSTransPerDisc.SetCurrentKey(DiscType);
            POSTransPerDisc.SetRange(DiscType, DiscType);
        end;

        POSTransPerDisc.SetRange("Receipt No.", POSTransLine."Receipt No.");
        POSTransPerDisc.SetRange("Line No.", POSTransLine."Line No.");
        PosFunctions.PosTransDiscSetTableFilter(4, POSTransPerDisc);
        if PosFunctions.PosTransDiscFindSetRec(4, POSTransPerDisc) then
            repeat
                case POSTransPerDisc.DiscType of
                    POSTransPerDisc.DiscType::"Periodic Disc.":
                        begin
                            PeriDiscPer := PeriDiscPer + POSTransPerDisc."Discount %";
                            PeriDiscAmo := PeriDiscAmo + POSTransPerDisc."Discount Amount";
                            POSTransLine."Periodic Disc. %" := PeriDiscPer;
                            POSTransLine."Periodic Discount Amount" := PeriDiscAmo;
                            PerDisc := POSTransPerDisc."Periodic Disc. Group";
                        end;
                    POSTransPerDisc.DiscType::Customer:
                        begin
                            CustDiscPer := CustDiscPer + POSTransPerDisc."Discount %";
                            POSTransLine."Customer Disc. %" := CustDiscPer;
                        end;
                    POSTransPerDisc.DiscType::InfoCode:
                        begin
                            InfoDiscPer := InfoDiscPer + POSTransPerDisc."Discount %";
                            POSTransLine."InfoCode Disc. %" := InfoDiscPer;
                        end;
                    POSTransPerDisc.DiscType::Total:
                        begin
                            TotaDiscPer := TotaDiscPer + POSTransPerDisc."Discount %";
                            TotaDiscAmo := TotaDiscAmo + POSTransPerDisc."Discount Amount";
                            POSTransLine."Total Disc. %" := TotaDiscPer;
                            POSTransLine."Total Disc. Amount" := TotaDiscAmo;
                        end;
                    POSTransPerDisc.DiscType::Line:
                        begin
                            LineDiscPer := LineDiscPer + POSTransPerDisc."Discount %";
                            POSTransLine."Line Disc. %" := LineDiscPer;
                        end;
                end;
            until PosFunctions.PosTransDiscNextRec(4, 1, POSTransPerDisc) = 0;

        exit(PerDisc);
    end;

    procedure CalcTotalDiscAmt(var CurrLine: Record "LSC POS Trans. Line"; PosFunc: Boolean; DiscAmount: Decimal; PPaymentState: Boolean): Boolean
    var
        PosTransLine2: Record "LSC POS Trans. Line";
        DiscTrans: Record "LSC POS Trans. Line";
        DiscTransLoc: Record "LSC POS Trans. Line";
        PerDiscType: Record "LSC POS Trans. Per. Disc. Type";
        DealHeaderPOSTransLineTmp: Record "LSC POS Trans. Line" temporary;
        TotalAmount: Decimal;
        TotDiscAmount: Decimal;
        TmpDec: Decimal;
        MaxAmount: Decimal;
        TotalRounded: Decimal;
        PTotDiscAmo: Decimal;
        MaxLineNo: Integer;
    begin
        clear(DealHeaderPOSTransLineTmp);
        DealHeaderPOSTransLineTmp.DeleteAll();

        if (CurrLine."Tot. Disc Info Line No." = 0) and (DiscAmount = 0) then
            exit;

        PosTransLine2.SetCurrentKey("Receipt No.", "Entry Type");
        PosTransLine2.SetRange("Receipt No.", CurrLine."Receipt No.");
        PosTransLine2.SetRange("Entry Type", PosTransLine2."Entry Type"::Item);
        PosTransLine2.SetRange("Entry Status", PosTransLine2."Entry Status"::" ");
        PosTransLine2.SetRange("Tot. Disc Info Line No.", CurrLine."Tot. Disc Info Line No.");
        PosTransLine2.SetRange("System-Block Manual Discount", false);
        if PosTransLine2.FindSet then begin
            if CurrLine."Tot. Disc Info Line No." = 0 then begin
                DiscTrans."Receipt No." := CurrLine."Receipt No.";
                DiscTrans."Entry Type" := DiscTrans."Entry Type"::TotalDiscount;
                DiscTrans.Description := Text001;
                DiscTrans."Discount %" := CurrLine."Total Disc. %";
                DiscTrans."Store No." := CurrLine."Store No.";
                DiscTrans."POS Terminal No." := CurrLine."POS Terminal No.";
                DiscTrans.InsertLine;
                TotDiscAmount := DiscAmount;
            end
            else begin
                DiscTrans.Get(PosTransLine2."Receipt No.", PosTransLine2."Tot. Disc Info Line No.");
                if PosFunc then
                    TotDiscAmount := DiscAmount
                else
                    TotDiscAmount := -DiscTrans.Amount;
            end;
            repeat
                GetTransDisc(PosTransLine2, true, Enum::"LSC POS Trans. Per. Disc. Type"::"Periodic Disc.");
                TotalAmount := TotalAmount + (PosTransLine2.Amount + PosTransLine2."Total Disc. Amount");
                if PosTransLine2."Tot. Disc Info Line No." <> DiscTrans."Line No." then begin
                    PosTransLine2."Tot. Disc Info Line No." := DiscTrans."Line No.";
                    PosTransLine2.Modify(true);
                end;
                if PosTransLine2."Deal Line" then begin
                    DealHeaderPOSTransLineTmp."Receipt No." := PosTransLine2."Receipt No.";
                    DealHeaderPOSTransLineTmp."Line No." := PosTransLine2."Disc. Info Line No.";
                    if DealHeaderPOSTransLineTmp.insert then;
                end;
            until PosTransLine2.Next = 0;

            DiscTransLoc := DiscTrans;

            DiscTrans.Amount := -TotDiscAmount;
            if LocalizationExt.IsNALocalizationEnabled then
                DiscTrans."Net Amount" := -TotDiscAmount;
            DiscTrans."Discount %" := Abs(DiscTrans.Amount / TotalAmount * 100);
            DiscTrans."Entry Status" := DiscTrans."Entry Status"::" ";
            DiscTrans.Modify(true);
            PosTransLine2.SetRange("Tot. Disc Info Line No.", DiscTrans."Line No.");
            if PosTransLine2.FindSet then
                repeat
                    TmpDec := PosTransLine2.Amount;
                    GetTransDisc(PosTransLine2, true, Enum::"LSC POS Trans. Per. Disc. Type"::"Periodic Disc.");
                    PosTransLine2.Amount += PosTransLine2."Total Disc. Amount";
                    PTotDiscAmo := MyPosFunctions.RoundAmount(TotDiscAmount * PosTransLine2.Amount / TotalAmount);
                    POSPriceUtility.InsertTransDiscAmount(PosTransLine2, PTotDiscAmo, PerDiscType.DiscType::Total, '');
                    UpdateTotalAmtDiscPercent(PosTransLine2, DiscTrans."Discount %");
                    PosTransLine2.Amount -= PosTransLine2."Total Disc. Amount";
                    if MaxAmount < PosTransLine2."Total Disc. Amount" then begin
                        MaxAmount := PosTransLine2."Total Disc. Amount";
                        MaxLineNo := PosTransLine2."Line No.";
                    end;
                    if TmpDec <> PosTransLine2.Amount then begin
                        PosTransLine2.CalcPrices;
                        PosTransLine2.Modify(true);
                        GetTransDisc(PosTransLine2, false, PerDiscType.DiscType::Total);
                    end;
                    TotalRounded += PosTransLine2."Total Disc. Amount";
                until PosTransLine2.Next = 0;

            if TotalRounded <> TotDiscAmount then begin
                PosTransLine2.Get(CurrLine."Receipt No.", MaxLineNo);
                GetTransDisc(PosTransLine2, true, Enum::"LSC POS Trans. Per. Disc. Type"::"Periodic Disc.");
                PTotDiscAmo := PosTransLine2."Total Disc. Amount";
                PTotDiscAmo += TotDiscAmount - TotalRounded;
                POSPriceUtility.InsertTransDiscAmount(PosTransLine2, PTotDiscAmo, PerDiscType.DiscType::Total, '');
                PosTransLine2.Amount -= TotDiscAmount - TotalRounded;
                PosTransLine2.CalcPrices;
                PosTransLine2.Modify(true);
            end;

            DealHeaderPOSTransLineTmp.reset;
            DealRecalcOnTotalDiscount(DealHeaderPOSTransLineTmp);

            if DiscTrans.Amount = 0 then begin
                DiscTrans.Get(DiscTrans."Receipt No.", DiscTrans."Line No.");
                DiscTrans.TransferFields(DiscTransLoc, false);
                DiscTrans.Modify;
                DiscTrans.VoidLine;
            end;
        end else
            exit(false);

        if PPaymentState then
            POSOfferExtUtility.ReCalcOfferSeq(PosTrans, PerDiscType.DiscType::Total)
        else
            MyPOSOfferExtUtility.ReCalcLinePreTotal(PosTrans);

        CurrLine.Get(CurrLine."Receipt No.", CurrLine."Line No.");

        exit(MyPOSOfferExtUtility.TransLineDiscOfferTypeExists(CurrLine, PerDiscType.DiscType::Total));
    end;


    procedure UpdateTotalAmtDiscPercent(var PosTransLine: Record "LSC POS Trans. Line"; pCalcTotalDiscPercent: Decimal)
    var
        PosTransPerDisc: Record "LSC POS Trans. Per. Disc. Type";
    begin
        POSPriceUtility.InitGlobals(PosTransLine, false);

        PosTransPerDisc.Reset;
        PosTransPerDisc.SetCurrentKey(DiscType);
        PosTransPerDisc.SetRange(DiscType, PosTransPerDisc.DiscType::Total);
        PosTransPerDisc.SetRange("Receipt No.", PosTransLine."Receipt No.");
        PosTransPerDisc.SetRange("Line No.", PosTransLine."Line No.");
        PosFunctions.PosTransDiscSetTableFilter(5, PosTransPerDisc);
        if PosFunctions.PosTransDiscFindFirstRec(5, PosTransPerDisc) then begin
            PosTransPerDisc."Total Disc. %" := pCalcTotalDiscPercent;
            PosTransPerDisc."Sequence Code" := RetailSetup."Total Disc. Manual Sequence";
            PosTransPerDisc."Sequence Function" := RetailSetup."Total Disc. Manual Function";
            PosTransPerDisc."Manual Selection" := true;
            if (PosTransPerDisc."Discount %" = 0) and (PosTransPerDisc."Discount Amount" = 0) then
                PosTransPerDisc."Entry Status" := PosTransPerDisc."Entry Status"::Voided;
            PosFunctions.PosTransDiscUpdateRec(PosTransPerDisc);
        end;
    end;

    procedure DealRecalcOnTotalDiscount(var DealHeaderPOSTransLineTmp: Record "LSC POS Trans. Line" temporary)
    var
        DealPOSTransLine: Record "LSC POS Trans. Line";
        DealLineDiscount: Decimal;
    begin
        if DealHeaderPOSTransLineTmp.findset then
            repeat
                if DealPOSTransLine.get(DealHeaderPOSTransLineTmp."Receipt No.", DealHeaderPOSTransLineTmp."Line No.") then begin
                    DealLineDiscount := DealPOSTransLine."Discount Amount" - DealPOSTransLine."Total Disc. Amount";
                    DealPOSTransLine.CalcFields("Deal Total Disc. Amt.");
                    DealPOSTransLine."Total Disc. Amount" := DealPOSTransLine."Deal Total Disc. Amt.";
                    DealPOSTransLine."Discount Amount" := DealLineDiscount + DealPOSTransLine."Total Disc. Amount";
                    DealPOSTransLine.Amount := (DealPOSTransLine.Quantity * DealPOSTransLine.Price) - DealPOSTransLine."Discount Amount";
                    if LocalizationExt.IsNALocalizationEnabled then
                        DealPOSTransLine."Net Amount" := (DealPOSTransLine.Quantity * DealPOSTransLine."net price") - DealPOSTransLine."Discount Amount";
                    DealPOSTransLine.Modify(true);
                end;
            until DealHeaderPOSTransLineTmp.next = 0;
    end;
}