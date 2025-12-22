report 50002 "BIR SALES SUMMARY REPORT"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;
    Caption = 'BIR SALES SUMMARY REPORT';
    //'Termial E-Sales Report';
    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending) WHERE(Number = CONST(1));
            dataitem("POS Terminal"; "LSC POS Terminal")
            {
                DataItemTableView = SORTING("No.") ORDER(Ascending);
                column(No_POSTerminal; "POS Terminal"."No.")
                {

                }
                column(MachineNumber_POSTerminal; "POS Terminal"."MIN Number")
                {

                }
                column(SerialNumber_POSTerminal; "POS Terminal"."Serial Number")
                {

                }
                column(PermitNumber_POSTerminal; "POS Terminal"."POS Permit Number")
                {

                }
                column(AccreditationNumber_POSTerminal; "POS Terminal"."Accreditation Number")
                {

                }
                column(TINNumber_POSTerminal; recCompanyInfo."VAT Registration No.")
                {

                }
                column(recCompanyInfoName; recCompanyInfo.Name)
                {

                }
                column(recCompanyInfoAddress; recCompanyInfo.Address + ' ' + recCompanyInfo."Address 2")
                {

                }
                column(USERID; USERID)
                {

                }
                dataitem(_Date; Date)
                {
                    column(codPOSTerminal; codPOSTerminal)
                    {

                    }
                    column(vDateFrom; vDateFrom)
                    {

                    }
                    column(vDateTo; vDateTo)
                    {

                    }
                    column(PeriodStart_Date; _Date."Period Start")
                    {

                    }
                    column(decOLDAccumulated; decOLDAccumulated)
                    {

                    }
                    column(decNEWAccumulated; decNEWAccumulated)
                    {

                    }
                    column(decGrossSales; decGrossSales)
                    {

                    }
                    column(decVatable; decVatable)
                    {

                    }
                    column(decZeroRated; abs(decZeroRated))
                    {

                    }
                    column(decVATEx; decVATEx)
                    {

                    }
                    column(decVATAmount; decVATAmount)
                    {

                    }
                    column(decDiscounts; decDiscounts)
                    {

                    }
                    column(decVoid; decVoid)
                    {

                    }
                    column(codBegInvoice; codBegInvoice)
                    {

                    }
                    column(codEndInvoice; codEndInvoice)
                    {

                    }
                    column(codZID; codZID)
                    {

                    }
                    column(txtPOSTerminal; txtPOSTerminal)
                    {

                    }
                    column(txtPOSTerminalDetails; txtPOSTerminalDetails)
                    {

                    }
                    column(decTotalGrossSales; decTempValueTotal[1])
                    {

                    }
                    column(decTotalVatable; decTempValueTotal[2])
                    {

                    }
                    column(decTotalZeroRated; decTempValueTotal[3])
                    {

                    }
                    column(decTotalVATEx; decTempValueTotal[4])
                    {

                    }
                    column(decTotalVATAmount; decTempValueTotal[5])
                    {

                    }
                    column(decTotalDiscounts; decTempValueTotal[6])
                    {

                    }
                    column(decTotalVoid; decTempValueTotal[7])
                    {

                    }
                    column(decSCDisc; decSCDisc)
                    {

                    }
                    column(decPWDDisc; decPWDDisc)
                    {

                    }
                    column(decSC20; decSC20)
                    {

                    }
                    column(decSC5; decSC5)
                    {

                    }
                    column(decPWD20; decPWD20)
                    {

                    }
                    column(decPWD5; decPWD5)
                    {

                    }
                    column(decShortOver; decShortOver)
                    {

                    }
                    trigger OnPreDataItem()

                    begin
                        vDateTo := CALCDATE('CM', vDateFrom);
                        IF (vDateFrom <> 0D) AND (vDateTo <> 0D) THEN
                            SETRANGE("Period Start", vDateFrom, vDateTo)
                        ELSE
                            SETRANGE("Period Start", TODAY, CALCDATE('+CM', TODAY));
                        // ifvDate := _Date."Period Start";
                    end;


                    trigger OnAfterGetRecord()

                    begin
                        skipReport := false;
                        ctr += 1;
                        i := 0;
                        while i < 31 do begin
                            i += 1;
                            if ifvDate[i] = _Date."Period Start" then
                                skipReport := true;
                        end;

                        if skipReport then
                            CurrReport.Skip();

                        txtPOSTerminal := "POS Terminal"."No.";
                        // CLEAR(decTempValueTotal);
                        // CLEAR(decOLDAccumulated);
                        // CLEAR(decNEWAccumulated);
                        // CLEAR(decTempValue);

                        decTempValue[1] := GetSalesValue2(1, "POS Terminal"."No.", "Period Start");
                        decTempValue[2] := GetSalesValue2(2, "POS Terminal"."No.", "Period Start");
                        //Message(Format(decTempValue[2]));
                        if decTempValue[2] = 0 then begin
                            decTempValue[2] := decNEWAccumulated;//GetSalesValue2(2, "POS Terminal"."No.", "Period Start" - ctr);
                            decTempValue[1] := decNEWAccumulated;// GetSalesValue2(2, "POS Terminal"."No.", "Period Start" - ctr);
                            //Message('1: ' + Format(decNEWAccumulated));
                        end;

                        decGrossSales := GetSalesValue2(13, "POS Terminal"."No.", "Period Start");// - (decSCDisc + decPWDDisc + decPWD20 + decPWD5 + decSC20 + decSC5 + decDiscounts);
                        decVatable := GetSalesValue2(4, "POS Terminal"."No.", "Period Start");
                        decZeroRated := GetSalesValue2(5, "POS Terminal"."No.", "Period Start");
                        decVATEx := GetSalesValue2(6, "POS Terminal"."No.", "Period Start");
                        decVATAmount := GetSalesValue2(7, "POS Terminal"."No.", "Period Start");
                        decDiscounts := GetSalesValue2(8, "POS Terminal"."No.", "Period Start");
                        decVoid := GetSalesValue2(9, "POS Terminal"."No.", "Period Start");
                        decSCDisc := GetSalesValue2(10, "POS Terminal"."No.", "Period Start");
                        decPWDDisc := GetSalesValue2(11, "POS Terminal"."No.", "Period Start");
                        codBegInvoice := GetValue(1, "POS Terminal"."No.", "Period Start");
                        codEndInvoice := GetValue(2, "POS Terminal"."No.", "Period Start");
                        codZID := GetValue(3, "POS Terminal"."No.", "Period Start");
                        decPWD20 := GetSalesValue2(18, "POS Terminal"."No.", "Period Start");
                        decPWD5 := GetSalesValue2(17, "POS Terminal"."No.", "Period Start");
                        decSC20 := GetSalesValue2(15, "POS Terminal"."No.", "Period Start");
                        decSC5 := GetSalesValue2(16, "POS Terminal"."No.", "Period Start");
                        decShortOver := GetSalesValue2(12, "POS Terminal"."No.", "Period Start");
                        IF (decTempValue[1] <> 0) THEN
                            decOLDAccumulated := decTempValue[1];

                        IF (decTempValue[2] <> 0) THEN
                            decNEWAccumulated := decTempValue[2];

                        decTempValueTotal[1] += decGrossSales;
                        decTempValueTotal[2] += decVatable;
                        decTempValueTotal[3] += decZeroRated;
                        decTempValueTotal[4] += decVATEx;
                        decTempValueTotal[5] += decVATAmount;
                        decTempValueTotal[6] += decDiscounts;
                        decTempValueTotal[7] += decVoid;

                        ifvDate[ctr] := _Date."Period Start";
                    end;
                }
                trigger OnPreDataItem()

                begin
                    IF (codPOSTerminal <> '') THEN
                        SETRANGE("No.", codPOSTerminal);


                end;

                trigger OnAfterGetRecord()

                begin
                    txtPOSTerminal := "POS Terminal"."No.";
                    CLEAR(decTempValueTotal);
                    CLEAR(decNEWAccumulated);
                    skipReport := false;
                    i := 0;
                    while i < 31 do begin
                        i += 1;
                        if ifvDate[i] = _Date."Period Start" then
                            skipReport := true;

                    end;

                end;
            }
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
                    field("POS Terminal No"; codPOSTerminal)
                    {
                        ApplicationArea = All;
                        TableRelation = "LSC POS Terminal"."No.";
                    }
                    field("Date From"; vDateFrom)
                    {
                        ApplicationArea = All;
                    }
                    field("Date To"; vDateTo)
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    rendering
    {
        //BIR SALES SUMMARY REPORT
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'src\report\Layout\BIR Sales summarry report.rdl'; // 'src\report\Layout\Termial E-Sales Report.rdl';
        }
    }

    var
        ctr, i : Integer;
        skipReport: Boolean;
        codPOSTerminal: Code[20];
        vDateFrom, vDateTo : date;
        ifvDate: array[31] of Date;
        _Date2: Record Date;
        recCompanyInfo: Record "Company Information";
        decOLDAccumulated, decNEWAccumulated : decimal;
        decNEWAccumulated2, decOLDAccumulated2 : decimal;
        decGrossSales: decimal;
        decVatable: decimal;
        decZeroRated: decimal;
        decVATEx: decimal;
        decVATAmount: decimal;
        decDiscounts: decimal;
        decVoid: decimal;
        codBegInvoice: Code[20];
        codEndInvoice: Code[20];
        codZID: Code[20];
        decTempValue: array[100] of decimal;
        decTempValueTotal: array[100] of decimal;
        txtPOSTerminal: Text;
        txtPOSTerminalDetails: Text;
        decSCDisc: decimal;
        decPWDDisc: decimal;
        decSC20: decimal;
        decSC5: decimal;
        decPWD5: decimal;
        decPWD20: decimal;
        decShortOver: decimal;

    trigger OnInitReport()

    begin
        recCompanyInfo.GET();
    end;

    procedure GetSalesValue2(pMode: Integer; pTerminal: Code[10]; pDate: Date): Decimal
    var
        recLEODLedg: Record "End Of Day Ledger";
        recLTransaction: Record "LSC Transaction Header";
        decLTempValue: Decimal;
    begin
        CLEAR(decLTempValue);
        recLEODLedg.RESET;
        recLEODLedg.SETRANGE("POS Terminal No.", pTerminal);
        recLEODLedg.SETRANGE(Date, pDate);
        IF recLEODLedg.FINDFIRST THEN BEGIN
            CASE pMode OF
                1:
                    EXIT(recLEODLedg."Old Accumulated Sales");
                2:
                    EXIT(recLEODLedg."New Accumulated Sales");
                //3: EXIT("Adjusted Sales");
                3:
                    EXIT(recLEODLedg."Gross Sales Amount");
                4:
                    EXIT(recLEODLedg."Vatable Sales");
                5:
                    EXIT(recLEODLedg."Zero Rated Sales");
                6:
                    EXIT(recLEODLedg."VAT Exempt Sales");
                7:
                    EXIT(recLEODLedg."Total VAT Amount");
                //8: EXIT("Total Discount Amount");
                8:
                    EXIT(recLEODLedg."Line Discount Amount" + recLEODLedg."Solo Parent Discount" + recLEODLedg."Athl Discount");
                9:
                    EXIT(recLEODLedg."Total Voided Transaction");
                10:
                    EXIT(recLEODLedg."Senior Citizen Discount");
                11:
                    EXIT(recLEODLedg."PWD Discount");
                12:
                    EXIT(recLEODLedg.ShortOver);
                13:
                    exit(recLEODLedg."Total Net Sales");
            //     1:
            //         EXIT("Old Accumulated Sales");
            //     2:
            //         EXIT("New Accumulated Sales");
            //     3:
            //         EXIT("Gross Sales Amount");
            //     4:
            //         EXIT("Vatable Sales");
            //     5:
            //         EXIT("Zero Rated Sales");
            //     6:
            //         EXIT("VAT Exempt Sales");
            //     7:
            //         EXIT("Total VAT Amount");
            //     8:
            //         EXIT("Line Discount Amount");
            //     9:
            //         EXIT("Total Voided Transaction");
            //     10:
            //         EXIT("Senior Citizen Discount");
            //     11:
            //         EXIT("PWD Discount");
            //     12:
            //         EXIT(ShortOver);

            // /*15: EXIT("Senior Citizen Discount 20%");
            // 16: EXIT("Senior Citizen Discount 5%");
            // 17: EXIT("PWD Discount 5%");
            // 18: EXIT("PWD Discount 20%");*/

            END;
        END;
    end;

    procedure GetValue(pMode: Integer; pTerminal: Code[10]; pDate: Date): Text
    var
        recLEODLedg: Record "End Of Day Ledger";
        //recLTransaction: Record "LSC Transaction Header";
        decLTempValue: Decimal;
    begin
        CLEAR(decLTempValue);
        recLEODLedg.RESET;
        recLEODLedg.SETRANGE("POS Terminal No.", pTerminal);
        recLEODLedg.SETRANGE(Date, pDate);
        IF recLEODLedg.FINDFIRST THEN BEGIN
            CASE pMode OF
                1:
                    EXIT(recLEODLedg."Beginning Invoice No.");
                2:
                    EXIT(recLEODLedg."Ending Invoice No.");
                3:
                    EXIT(recLEODLedg."Z-Report ID");
            END;
        END;
    end;
}