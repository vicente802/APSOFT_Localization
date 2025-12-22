report 50003 "Terminal Accountability Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;
    Caption = 'Terminal Accountability Report';
    dataset
    {
        dataitem(POSTerminal; "LSC POS Terminal")
        {
            column(TerminalID; POSTerminal."No.")
            {
            }
            column(Store; POSTerminal."Store No.")
            {
            }
            column(TransactionDate; vDateFilter)
            {
            }
            column(recCompanyInfoName; recCompanyInfo.Name) { }
            dataitem(TenderType; "LSC Tender Type")
            {
                DataItemTableView = sorting(code);
                column(tenderCode; TenderType.Code)
                {
                }
                column(tenderDescription; TenderType.Description)
                {
                }
                column(TransactionCount; Gettransactioncount(2, TenderType, vDateFilter, codTerminal))
                {
                }
                column(GrossAmount; GrossAmount)
                {
                }
                column(LineDiscountAmount; Abs(LineDiscountAmount) + Abs(TotalDiscountAmount)) //Line Disc./Total Disc.
                {
                }
                column(TotalDiscountAmount; TotalDiscountAmount)
                {
                }
                column(TotalNetSales; TotalNetSales)
                {
                }
                column(NoofItems; NoofItems)
                {
                }
                column(Refundcount; Refundcount)
                {
                }
                column(Voidedcount; Voidedcount)
                {
                }

                column(transactionCountperdate; transactionCountperdate)
                {
                }
                column(RefundAmount; RefundAmount)
                {
                }
                column(TransactionAmount; Gettransactioncount(1, TenderType, vDateFilter, codTerminal))
                {
                }
                column(Noofpayingcustomer; Noofpayingcustomer)
                {
                }
                column(SuspQuantity; SuspQuantity)
                {
                }
                column(intLTotalNoOfVoidLine; intLTotalNoOfVoidLine)
                {
                }
                column(decLTotalVoidLineAmt; decLTotalVoidLineAmt)
                {
                }
                column(ATHLdisc; ATHLdisc)
                {
                }
                column(SRCdisc; SRCdisc)
                {
                }
                column(PWDDisc; PWDDisc)
                {
                }
                column(SOLOdisc; SOLOdisc)
                {
                }
                column(codLBegInvNo; codLBegInvNo)
                {
                }
                column(codLEndInvNo; codLEndInvNo)
                {
                }
                column(TotalDiscounts; TotalDiscounts)
                {
                }
                column(TimePrinted; Format(Time))
                {
                }
                column(DatePrinted; FORMAT(Today, 10, '<Month,2>/<Day,2>/<Year4>') + ' ')
                {
                }
                column(DrawerAccountability; DrawerAccountability(vDateFilter, codTerminal))
                {
                }
                column(NoofOpenDrawer; NoofOpenDrawer)
                {
                }
                column(ZeroratedSales; ZeroratedSales)
                {
                }
                column(ZeroRatedAmount; ZeroRatedAmount)
                {
                }
                column(VatableSales; VatableSales)
                {
                }
                column(VATAmount; VATAmount)
                {
                }
                column(VATExemptSales; VATExemptSales)
                {
                }
                column(FloatEntry; FloatEntry)
                {
                }
                column(RemoveTender; RemoveTender)
                {
                }
                column(TotalVatDetails; TotalVatDetails)
                {
                }
                column(OldAccumulatedSales; OldAccumulatedSales)
                {
                }
                column(NewAccumulatedSales; NewAccumulatedSales)
                {

                }

                trigger OnPreDataItem()
                begin
                    TenderType.SetRange("Store No.", POSTerminal."Store No.");
                    // transactionAmount := Gettransactioncount(1, TenderType.Code, vDateFilter, codTerminal);
                end;

                // trigger OnPostDataItem()

                // begin
                //     transactionAmount := Gettransactioncount(1, TenderType.Code, vDateFilter, codTerminal);
                // end;


                trigger OnAfterGetRecord()
                var
                    Terminal: Record "LSC POS Terminal";
                    EODLedger: Record "End Of Day Ledger";
                begin
                    codLBegInvNo := GetInvs(1);
                    codLEndInvNo := GetInvs(2);
                    ATHLdisc := GetDiscounts(1);
                    SRCdisc := GetDiscounts(2);
                    PWDDisc := GetDiscounts(3);
                    SOLOdisc := GetDiscounts(4);
                    //transactionAmount := Gettransactioncount(1, TenderType.Code, vDateFilter, codTerminal);
                    //TransactionCount := Gettransactioncount(2, TenderType, vDateFilter, codTerminal);
                    //CustomerSalescount := getsales(9, vDateFilter, codTerminal);
                    LineDiscountAmount := getsales(2, vDateFilter, codTerminal);
                    TotalDiscountAmount := getsales(3, vDateFilter, codTerminal);
                    TotalNetSales := getsales(4, vDateFilter, codTerminal);
                    transactionCountperdate := getsales(5, vDateFilter, codTerminal);
                    NoofItems := getsales(6, vDateFilter, codTerminal);
                    Refundcount := getsales(7, vDateFilter, codTerminal);
                    Voidedcount := getsales(8, vDateFilter, codTerminal);
                    RefundAmount := getsales(10, vDateFilter, codTerminal);
                    Noofpayingcustomer := getsales(11, vDateFilter, codTerminal);
                    SuspQuantity := getsales(12, vDateFilter, codTerminal);
                    intLTotalNoOfVoidLine := getsales(13, vDateFilter, codTerminal);
                    decLTotalVoidLineAmt := getsales(14, vDateFilter, codTerminal);
                    GrossAmount := getsales(4, vDateFilter, codTerminal) + abs(ATHLdisc) + abs(SRCdisc) + abs(PWDDisc) + abs(SOLOdisc) + Abs(TotalDiscountAmount) + Abs(LineDiscountAmount);
                    TotalDiscounts := abs(ATHLdisc) + abs(SRCdisc) + abs(PWDDisc) + abs(SOLOdisc) + Abs(TotalDiscountAmount) + Abs(LineDiscountAmount);
                    NoofOpenDrawer := getsales(15, vDateFilter, codTerminal);
                    RemoveTender := Float_Remove(2, vDateFilter, codTerminal);
                    FloatEntry := Float_Remove(1, vDateFilter, codTerminal);
                    ZeroRatedAmount := GetVatDetails(1);
                    VatableSales := GetVatDetails(2);
                    VATAmount := GetVatDetails(3);
                    VATExemptSales := GetVatDetails(4);
                    ZeroratedSales := GetVatDetails(5);
                    TotalVatDetails := VatableSales + VATAmount + VATExemptSales + ZeroratedSales;
                    EODLedger.Reset();
                    EODLedger.SetRange(EODLedger."POS Terminal No.", codTerminal);
                    EODLedger.SetRange(Date, vDateFilter - 1);
                    if EODLedger.FindLast() then
                        OldAccumulatedSales := EODLedger."New Accumulated Sales";
                    NewAccumulatedSales := OldAccumulatedSales + TotalNetSales;

                end;
            }
            trigger OnPreDataItem()
            begin
                POSTerminal.SetRange("No.", codTerminal);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group("Filter Options")
                {
                    field("POS Terminal No"; codTerminal)
                    {
                        ApplicationArea = All;
                        TableRelation = "LSC POS Terminal"."No.";
                    }
                    field("Date Filter"; vDateFilter)
                    {
                        ApplicationArea = All;
                    }

                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }
    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'src\report\Layout\Terminal Accountability Report.rdl';
        }
    }
    procedure GetVatDetails(Mode: Integer): Decimal
    var
        Transheader: Record "LSC Transaction Header";
        salesEntry: Record "LSC Trans. Sales Entry";
    begin
        case Mode of
            1://ZeroRatedAmount
                begin
                    Transheader.RESET;
                    Transheader.SETFILTER("VAT Code Filter", 'VE');
                    Transheader.SetFilter("Local VAT Code Filter", 'VZ');
                    Transheader.SetRange(Date, vDateFilter);
                    Transheader.SetRange("POS Terminal No.", codTerminal);
                    if Transheader.FindSet() then begin
                        Transheader.CalcSums("Zero Rated Amount");
                        ZeroRatedAmount := Transheader."Zero Rated Amount";
                        exit(ZeroRatedAmount);
                    end;
                end;
            2://VatableSales
                begin
                    // Transheader.RESET;
                    // Transheader.SETCURRENTKEY(Transheader.Date, Transheader."Transaction No.",
                    //         Transheader."Statement Code", Transheader."Staff ID", Transheader."Store No.");
                    // Transheader.SetRange(Date, vDateFilter);
                    // Transheader.SetRange("POS Terminal No.", codTerminal);
                    // if Transheader.FindSet() then begin
                    salesEntry.Reset();
                    salesEntry.SetRange(Date, vDateFilter);
                    salesEntry.SetRange("POS Terminal No.", codTerminal);

                    //salesEntry.SetRange("Receipt No.", Transheader."Receipt No.");
                    salesEntry.SetRange("VAT Code", 'V');
                    if salesEntry.findfirst() then
                        repeat
                            VatableSales += (salesEntry."Net Amount");
                        until salesEntry.next() = 0;
                    exit(-VatableSales);
                end;
            // end;
            3://VATAmount
                begin
                    // Transheader.RESET;
                    // Transheader.SETCURRENTKEY(Transheader.Date, Transheader."Transaction No.",
                    //         Transheader."Statement Code", Transheader."Staff ID", Transheader."Store No.");
                    // Transheader.SetRange(Date, vDateFilter);
                    // Transheader.SetRange("POS Terminal No.", codTerminal);
                    // if Transheader.FindSet() then begin
                    salesEntry.Reset();
                    salesEntry.SetRange(Date, vDateFilter);
                    salesEntry.SetRange("POS Terminal No.", codTerminal);
                    //salesEntry.SetRange("Receipt No.", Transheader."Receipt No.");
                    salesEntry.SetRange("VAT Code", 'V');
                    if salesEntry.findfirst() then
                        repeat
                            VATAmount += (salesEntry."VAt Amount");
                        until salesEntry.next() = 0;
                    exit(-VATAmount);
                end;
            //end;
            4://VATExemptSales
                begin
                    Transheader.RESET;
                    Transheader.SETCURRENTKEY(Transheader.Date, Transheader."Transaction No.",
                     Transheader."Statement Code", Transheader."Staff ID", Transheader."Store No.");
                    Transheader.SETFILTER("VAT Code Filter", 'VE');
                    Transheader.SetFilter("Local VAT Code Filter", '<>%1', 'VZ');
                    Transheader.SetRange(Date, vDateFilter);
                    Transheader.SetRange("POS Terminal No.", codTerminal);
                    if Transheader.FindSet() then begin
                        REPEAT
                            Transheader.CALCFIELDS("Total Net Amount");
                            VATExemptSales += Transheader."Total Net Amount";
                        UNTIL Transheader.NEXT = 0;
                        exit(-VATExemptSales);
                    end;
                end;
            5://Zero-rated Sales
                begin
                    salesEntry.Reset();
                    salesEntry.SetRange(Date, vDateFilter);
                    salesEntry.SetRange("POS Terminal No.", codTerminal);
                    //salesEntry.SetRange("Receipt No.", Transheader."Receipt No.");
                    salesEntry.SetRange("VAT Code", 'VZ');
                    if salesEntry.findfirst() then
                        repeat
                            ZeroratedSales += (salesEntry."Net Amount");
                        until salesEntry.next() = 0;
                    exit(-ZeroratedSales);

                    // Transheader.RESET;
                    // Transheader.SETCURRENTKEY(Transheader.Date, Transheader."Transaction No.",
                    //         Transheader."Statement Code", Transheader."Staff ID", Transheader."Store No.");
                    // Transheader.SetRange(Date, vDateFilter);
                    // Transheader.SetRange("POS Terminal No.", codTerminal);
                    // if Transheader.FindSet() then begin
                    //     salesEntry.Reset();
                    //     salesEntry.SetRange("Receipt No.", Transheader."Receipt No.");
                    //     salesEntry.SetRange("VAT Code", 'VZ');
                    //     if salesEntry.findfirst() then
                    //         repeat
                    //             ZeroratedSales += (salesEntry."Net Amount");
                    //         until salesEntry.next() = 0;
                    //     exit(ZeroratedSales);
                    // end;
                end;
        end;
    end;

    procedure GetDiscounts(Mode: Integer): Decimal
    var
        recLTransaction: Record "LSC Transaction Header";
    begin
        case Mode of
            1:
                begin
                    recLTransaction.RESET;
                    recLTransaction.SetRange("Transaction Code Type", recLTransaction."Transaction Code Type"::ATHL);
                    recLTransaction.SetRange("Original Date", vDateFilter);
                    recLTransaction.SetRange("POS Terminal No.", codTerminal);
                    if recLTransaction.FindSet() then begin
                        recLTransaction.CalcSums("Discount Amount");
                        exit(Round(ABS(recLTransaction."Discount Amount")));
                    end;
                end;
            2:
                begin
                    recLTransaction.RESET;
                    recLTransaction.SetRange("Transaction Code Type", recLTransaction."Transaction Code Type"::SRC);
                    recLTransaction.SetRange("Original Date", vDateFilter);
                    recLTransaction.SetRange("POS Terminal No.", codTerminal);
                    if recLTransaction.FindSet() then begin
                        recLTransaction.CalcSums("Discount Amount");
                        exit(Round(ABS(recLTransaction."Discount Amount")));
                    end;
                end;
            3:
                begin
                    recLTransaction.RESET;
                    recLTransaction.SetRange("Transaction Code Type", recLTransaction."Transaction Code Type"::PWD);
                    recLTransaction.SetRange("Original Date", vDateFilter);
                    recLTransaction.SetRange("POS Terminal No.", codTerminal);
                    if recLTransaction.FindSet() then begin
                        recLTransaction.CalcSums("Discount Amount");
                        exit(Round(ABS(recLTransaction."Discount Amount")));
                    end;
                end;
            4:
                begin
                    recLTransaction.RESET;
                    recLTransaction.SetRange("Transaction Code Type", recLTransaction."Transaction Code Type"::SOLO);
                    recLTransaction.SetRange("Original Date", vDateFilter);
                    recLTransaction.SetRange("POS Terminal No.", codTerminal);
                    if recLTransaction.FindSet() then begin
                        recLTransaction.CalcSums("Discount Amount");
                        exit(Round(ABS(recLTransaction."Discount Amount")));
                    end;
                end;
        end;
    end;

    procedure Gettransactioncount(pMode: Integer; TenderTypes: Record "LSC Tender Type"; transDate: date; TerminalID: Code[20]): Decimal
    var
        PaymEntry: Record "LSC Trans. Payment Entry";

    begin
        // Message(Format(TenderTypes.Code));
        CASE pMode OF
            1:
                begin
                    PaymEntry.Reset();
                    PaymEntry.SetRange("Tender Type", TenderTypes.Code);
                    PaymEntry.SetRange("POS Terminal No.", TerminalID);
                    PaymEntry.SetRange(date, transDate);
                    //PaymEntry.SetRange("Change Line", false);
                    if PaymEntry.FindSet() then begin
                        PaymEntry.CalcSums("Amount Tendered");
                        EXIT(PaymEntry."Amount Tendered");
                    end;
                end;
            2:
                begin
                    PaymEntry.Reset();
                    PaymEntry.SetRange("Tender Type", TenderTypes.Code);
                    PaymEntry.SetRange("POS Terminal No.", TerminalID);
                    PaymEntry.SetRange(date, transDate);
                    PaymEntry.SetRange("Change Line", false);
                    if PaymEntry.FindSet() then begin
                        EXIT(PaymEntry.Count);

                    end;
                end;
        end;
        PaymEntry.Reset();
        PaymEntry.SetRange("Tender Type", TenderTypes.Code);
        PaymEntry.SetRange("POS Terminal No.", TerminalID);
        PaymEntry.SetRange(date, transDate);
        PaymEntry.SetRange("Change Line", false);
        if PaymEntry.FindSet() then begin
            PaymEntry.CalcSums("Amount Tendered");
            CASE pMode OF
                1:
                    EXIT(PaymEntry."Amount Tendered");
                2:
                    EXIT(PaymEntry.Count);
            end;
        end;
    end;

    procedure Float_Remove(pMode: Integer; transDate: date; TerminalID: Code[20]): Decimal
    var
        PaymEntry: Record "LSC Trans. Payment Entry";
        transheader: Record "LSC Transaction Header";
        AmountTendered: Decimal;
    begin
        CASE pMode OF
            1://float entry
                begin
                    transheader.Reset();
                    transheader.SetRange("Transaction Type", transheader."Transaction Type"::"Float Entry");
                    transheader.SetRange("POS Terminal No.", TerminalID);
                    transheader.SetRange(date, transDate);
                    if transheader.FindSet() then
                        repeat
                            PaymEntry.Reset();
                            PaymEntry.SetRange("Store No.", transheader."Store No.");
                            PaymEntry.SetRange("POS Terminal No.", TerminalID);
                            PaymEntry.SetFilter("Tender Type", '<>9');
                            PaymEntry.SetRange(PaymEntry."Transaction No.", transheader."Transaction No.");
                            if PaymEntry.FindSet() then
                                repeat
                                    AmountTendered += PaymEntry."Amount Tendered";
                                until PaymEntry.Next() = 0;
                        until transheader.Next() = 0;
                    exit(AmountTendered);
                end;
            2://remove tender
                begin
                    transheader.Reset();
                    transheader.SetRange("Transaction Type", transheader."Transaction Type"::"Remove Tender");
                    transheader.SetRange("POS Terminal No.", TerminalID);
                    transheader.SetRange(date, transDate);
                    if transheader.FindSet() then
                        repeat
                            PaymEntry.Reset();
                            PaymEntry.SetRange("Store No.", transheader."Store No.");
                            PaymEntry.SetRange("POS Terminal No.", TerminalID);
                            PaymEntry.SetFilter("Tender Type", '<>9');
                            PaymEntry.SetRange(PaymEntry."Transaction No.", transheader."Transaction No.");
                            if PaymEntry.FindSet() then
                                repeat
                                    AmountTendered += PaymEntry."Amount Tendered";
                                until PaymEntry.Next() = 0;
                        until transheader.Next() = 0;
                    exit(AmountTendered);
                end;
        end;

    end;

    procedure DrawerAccountability(transDate: date; TerminalID: Code[20]): Decimal
    var
        PaymEntry: Record "LSC Trans. Payment Entry";

    begin
        //Drawer Accountability
        PaymEntry.Reset();
        PaymEntry.SetRange("Tender Type", '1');
        PaymEntry.SetRange("POS Terminal No.", TerminalID);
        PaymEntry.SetRange(date, transDate);
        if PaymEntry.FindFirst() then begin
            PaymEntry.CalcSums("Amount Tendered");
            EXIT(PaymEntry."Amount Tendered");
        end;

    end;

    procedure getsales(pMode: Integer; transDate: date; TerminalID: Code[20]): Decimal
    var
        transactionheader: Record "LSC Transaction Header";
        PaymentEntry: Record "LSC Trans. Payment Entry";
        SuspTrans: Record "LSC POS Transaction";
        POSVoidedLine: Record "LSC POS Voided Trans. Line";
    begin
        CASE pMode OF
            1://Gross Sales
                begin
                    transactionheader.Reset();
                    transactionheader.SetRange("POS Terminal No.", TerminalID);
                    transactionheader.SetRange("Original Date", transDate);
                    if transactionheader.FindSet() then begin
                        transactionheader.CalcSums("Gross Amount");
                        exit(Abs(transactionheader."Gross Amount"));
                    end;
                end;
            2://Line Discount
                begin
                    transactionheader.Reset();
                    transactionheader.SetRange("POS Terminal No.", TerminalID);
                    transactionheader.SetRange("Original Date", transDate);
                    transactionheader.SetRange("Transaction Code Type", transactionheader."Transaction Code Type"::REG);
                    if transactionheader.FindSet() then begin
                        transactionheader.CalcSums("Discount Amount");
                        exit(-transactionheader."Discount Amount");
                    end;
                end;
            3://Total Discount
                begin
                    transactionheader.Reset();
                    transactionheader.SetRange("POS Terminal No.", TerminalID);
                    transactionheader.SetRange("Original Date", transDate);
                    if transactionheader.FindSet() then begin
                        transactionheader.CalcSums("Total Discount");
                        exit(-transactionheader."Total Discount");
                    end;
                end;
            4://Total Net Sales
                begin
                    transactionheader.Reset();
                    transactionheader.SetRange("POS Terminal No.", TerminalID);
                    transactionheader.SetRange("Original Date", transDate);
                    if transactionheader.FindSet() then begin
                        transactionheader.CalcSums("Gross Amount");
                        exit(Abs(transactionheader."Gross Amount"));
                    end;
                end;
            5://Transaction count
                begin
                    transactionheader.Reset();
                    transactionheader.SetRange("POS Terminal No.", TerminalID);
                    transactionheader.SetRange("Original Date", transDate);
                    if transactionheader.FindSet() then
                        exit(transactionheader.Count);
                end;
            6://No. of Items
                begin
                    transactionheader.Reset();
                    transactionheader.SetRange("POS Terminal No.", TerminalID);
                    transactionheader.SetRange("Original Date", transDate);
                    if transactionheader.FindSet() then begin
                        transactionheader.CalcSums("No. of Items");
                        exit(transactionheader."No. of Items");
                    end;
                end;
            7://Refund count
                begin
                    transactionheader.Reset();
                    transactionheader.SetRange("POS Terminal No.", TerminalID);
                    transactionheader.SetRange("Original Date", transDate);
                    transactionheader.SetRange(transactionheader."Sale Is Return Sale", TRUE);
                    //transactionheader.SetFilter(transactionheader."Retrieved from Receipt No.", '%1', '');
                    if transactionheader.FindSet() then
                        exit(transactionheader.Count);
                end;
            8://Voided count
                begin
                    transactionheader.Reset();
                    transactionheader.SetRange("POS Terminal No.", TerminalID);
                    transactionheader.SetRange("Original Date", transDate);
                    //transactionheader.SETRANGE(transactionheader."Z-Report ID", '');
                    transactionheader.SETRANGE("Entry Status", transactionheader."Entry Status"::Voided);
                    if transactionheader.FindFirst() then
                        exit(transactionheader.Count);
                end;
            9://Customer Sales count
                begin
                    transactionheader.Reset();
                    transactionheader.SetRange("POS Terminal No.", TerminalID);
                    transactionheader.SetRange("Original Date", transDate);
                    transactionheader.SetFilter("Transaction Code Type", '<>%1', transactionheader."Transaction Code Type"::REG);
                    if transactionheader.FindSet() then
                        exit(transactionheader.Count);

                end;
            10://Refund Amount
                begin
                    transactionheader.Reset();
                    transactionheader.SetRange("POS Terminal No.", TerminalID);
                    transactionheader.SetRange("Original Date", transDate);
                    transactionheader.SetRange(transactionheader."Sale Is Return Sale", TRUE);
                    //transactionheader.SetFilter(transactionheader."Retrieved from Receipt No.", '%1', '');
                    if transactionheader.FindSet() then begin
                        transactionheader.CalcSums("Gross Amount");
                        exit(transactionheader."Gross Amount");
                    end;
                end;
            11://No. of paying customer
                begin

                    transactionheader.Reset();
                    transactionheader.SetRange("POS Terminal No.", TerminalID);
                    transactionheader.SetRange("Original Date", transDate);
                    transactionheader.SetFilter("Invoice No.", '<>%1', '');
                    transactionheader.SetRange(transactionheader."Transaction Type", transactionheader."Transaction Type"::Sales);
                    if transactionheader.FindSet() then
                        exit(transactionheader.Count);

                end;
            12://No. of Suspended
                begin
                    SuspTrans.Reset();
                    SuspTrans.SetRange("POS Terminal No.", TerminalID);
                    SuspTrans.SetRange("Trans. Date", transDate);
                    SuspTrans.SetRange("Entry Status", SuspTrans."Entry Status"::Suspended);
                    if SuspTrans.FindSet then
                        exit(SuspTrans.Count);
                end;
            13://intLTotalNoOfVoidLine
                begin
                    POSVoidedLine.Reset();
                    POSVoidedLine.SETCURRENTKEY("Receipt No.", "Entry Type", "Entry Status");
                    POSVoidedLine.SetRange("POS Terminal No.", TerminalID);
                    POSVoidedLine.SETRANGE("Entry Type", POSVoidedLine."Entry Type"::Item);
                    POSVoidedLine.SETRANGE("Entry Status", POSVoidedLine."Entry Status"::Voided);
                    POSVoidedLine.SetRange("Trans. Date", transDate);
                    IF POSVoidedLine.FindSet() THEN
                        exit(POSVoidedLine.Count);
                end;

            14://decLTotalVoidLineAmt
                begin
                    POSVoidedLine.Reset();
                    POSVoidedLine.SETCURRENTKEY("Receipt No.", "Entry Type", "Entry Status");
                    POSVoidedLine.SetRange("POS Terminal No.", TerminalID);
                    POSVoidedLine.SETRANGE("Entry Type", POSVoidedLine."Entry Type"::Item);
                    POSVoidedLine.SETRANGE("Entry Status", POSVoidedLine."Entry Status"::Voided);
                    POSVoidedLine.SetRange("Trans. Date", transDate);
                    IF POSVoidedLine.FindSet() THEN BEGIN
                        POSVoidedLine.CalcSums(POSVoidedLine.Amount);
                        exit(POSVoidedLine.Amount);
                    END;
                end;
            15://No. of Open Drawer
                begin
                    transactionheader.Reset();
                    transactionheader.SETCURRENTKEY(transactionheader.Date, transactionheader."Transaction No.", transactionheader."Statement Code", transactionheader."Staff ID", transactionheader."Store No.");
                    //transactionheader.SETRANGE(transactionheader."Z-Report ID", '');
                    transactionheader.SetRange("POS Terminal No.", TerminalID);
                    transactionheader.SetRange(transactionheader.Date, transDate);
                    transactionheader.SETFILTER("Transaction Type", '%1|%2|%3|%4|%5', transactionheader."Transaction Type"::Sales,
                            transactionheader."Transaction Type"::"Open Drawer", transactionheader."Transaction Type"::"Tender Decl.",
                            transactionheader."Transaction Type"::"Float Entry", transactionheader."Transaction Type"::"Remove Tender");

                    transactionheader.SETFILTER("Entry Status", '<>%1', transactionheader."Entry Status"::Voided);
                    if transactionheader.FindFirst() then
                        exit(transactionheader.Count);
                end;

        end;
    end;

    procedure GetInvs(Mode: Integer): Code[20]
    var
        recLTransaction: Record "LSC Transaction Header";
    begin
        case Mode of
            1:
                begin
                    recLTransaction.RESET;
                    recLTransaction.SetRange("Original Date", vDateFilter);
                    recLTransaction.SetRange("POS Terminal No.", codTerminal);
                    recLTransaction.SetFilter("Invoice No.", '<>%1', '');
                    if recLTransaction.FindFirst() then
                        exit(recLTransaction."Invoice No.");
                end;
        end;
        case Mode of
            2:
                begin
                    recLTransaction.RESET;
                    recLTransaction.SetRange("Original Date", vDateFilter);
                    recLTransaction.SetRange("POS Terminal No.", codTerminal);
                    recLTransaction.SetFilter("Invoice No.", '<>%1', '');
                    if recLTransaction.FindLast() then
                        exit(recLTransaction."Invoice No.");
                end;
        end;

    end;

    trigger OnInitReport()
    begin
        recCompanyInfo.GET();
        recCompanyInfo.CALCFIELDS(Picture);
    end;


    var
        recCompanyInfo: Record "Company Information";
        codStore, codLBegInvNo, codLEndInvNo : Code[20];
        codTerminal: Code[20];
        vDateFilter: Date;
        transactionAmount: Decimal;
        GrossAmount: Decimal;
        LineDiscountAmount: Decimal;
        TotalDiscountAmount, TotalDiscounts : Decimal;
        TotalNetSales, decLTotalVoidLineAmt : Decimal;
        RefundAmount: Decimal;
        NoofItems, NoofItems_, Refundcount, Voidedcount, Noofpayingcustomer, draweropencount : integer;
        transactionCount, transactionCountperdate, SuspQuantity, intLTotalNoOfVoidLine, NoofOpenDrawer : Integer;
        SRCdisc, PWDDisc, SOLOdisc, ATHLdisc : decimal;
        FloatEntry, RemoveTender, ZeroRatedAmount, VatableSales, VATAmount, VATExemptSales, ZeroratedSales, TotalVatDetails, OldAccumulatedSales, NewAccumulatedSales : decimal;

}
