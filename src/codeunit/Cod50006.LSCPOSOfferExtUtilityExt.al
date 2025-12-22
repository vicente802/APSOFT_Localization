codeunit 50006 "LSCPOSOfferExtUtilityExt"
{
    trigger OnRun()
    begin

    end;

    var
        RetailSetup: Record "LSC Retail Setup";
        Store: Record "LSC Store";
        PosFuncProfile: Record "LSC POS Func. Profile";
        CurrencyExchRate: Record "Currency Exchange Rate";
        rboPriceUtil: Codeunit "LSC Retail Price Utils";
        PosFunc: Codeunit "LSC POS Functions";
        PosPriceUtility: Codeunit "LSC POS Price Utility";
        Global: Codeunit "LSC POS Session";
        LocalizationExt: Codeunit "LSC Retail Localization Ext.";
        MyPosPriceUtility: Codeunit LSCPOSPriceUtilityExt;
        POSOfferExtUtility: Codeunit "LSC POS Offer Ext. Utility";

    procedure InitFunc(var pPosTrans: Record "LSC POS Transaction")
    begin
        RetailSetup.Get;

        if pPosTrans."Store No." <> Store."No." then begin
            Store.Get(pPosTrans."Store No.");
            PosFuncProfile.Get(Global.FunctionalityProfileID);
        end;
    end;

    procedure TransLineDiscOfferTypeExists(var pPosTransLine: Record "LSC POS Trans. Line"; pOfferType: Enum "LSC POS Trans. Per. Disc. Type"): Boolean
    var
        POSTransPeriodicDisc: Record "LSC POS Trans. Per. Disc. Type";
    begin
        POSTransPeriodicDisc.Reset;
        POSTransPeriodicDisc.SetRange("Receipt No.", pPosTransLine."Receipt No.");
        POSTransPeriodicDisc.SetRange("Line No.", pPosTransLine."Line No.");
        POSTransPeriodicDisc.SetRange(DiscType, pOfferType);
        PosFunc.PosTransDiscSetTableFilter(4, POSTransPeriodicDisc);
        exit(not PosFunc.PosTransDiscIsEmptyRec(4));
    end;


    procedure ReCalcLinePreTotal(var pPosTrans: Record "LSC POS Transaction")
    var
        PosTransLine: Record "LSC POS Trans. Line";
    begin
        InitFunc(pPosTrans);

        if (pPosTrans."Retrieved from Receipt No." <> '') or
           (PosPriceUtility.IsTransUnchangableDiscounts(pPosTrans))
        then
            exit;

        PosTransLine.Reset;
        PosTransLine.SetCurrentKey("Receipt No.", "Entry Type", "Entry Status");
        PosTransLine.SetRange("Receipt No.", pPosTrans."Receipt No.");
        PosTransLine.SetRange("Entry Type", PosTransLine."Entry Type"::Item);
        PosTransLine.SetRange("Entry Status", PosTransLine."Entry Status"::" ");
        if PosTransLine.FindSet then
            repeat
                POSOfferExtUtility.ProcessLinePreTotal(pPosTrans, PosTransLine, '');
            until PosTransLine.Next = 0;
    end;


}