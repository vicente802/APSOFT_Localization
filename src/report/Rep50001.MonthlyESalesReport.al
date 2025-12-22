report 50001 "Monthly E-Sales Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem("POS Terminal"; "LSC POS Terminal")
        {
            column(TIN_Number; "POS Terminal"."TIN Number")
            {

            }
            column(Permit_Number; "POS Permit Number")
            {

            }
            column(Machine_Number; "MIN Number")
            {

            }
            column(Serial_Number; "Serial Number")
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
            column(codStore; codStore)
            {

            }
            column(vDateFilterDesc; vDateFilterDesc)
            {

            }
            column(USERID; USERID)
            {

            }
            column(EndInvoice; GetBegNEndInvoice(codStore, "POS Terminal"."No.", vDateFilter, 2))
            {

            }
            column(GrossSales; GetValuesByIndex(codStore, "POS Terminal"."No.", vDateFilter, 1))
            {

            }
            column(ZeroRated; abs(GetValuesByIndex(codStore, "POS Terminal"."No.", vDateFilter, 2)))
            {

            }
            column(VatExempt; GetValuesByIndex(codStore, "POS Terminal"."No.", vDateFilter, 3))
            {

            }
            column(Vatable; GetValuesByIndex(codStore, "POS Terminal"."No.", vDateFilter, 4))
            {

            }
            column(TotalNetSalesOfVat; GetValuesByIndex(codStore, "POS Terminal"."No.", vDateFilter, 5))
            {

            }
            column(OutputVAT; GetValuesByIndex(codStore, "POS Terminal"."No.", vDateFilter, 6))
            {

            }
            trigger OnPreDataItem()
            begin
                IF (codStore <> '') THEN
                    SETRANGE("Store No.", codStore);

                IF (codTerminal <> '') THEN
                    SETRANGE("No.", codTerminal);

                vDateFilter := '';
                IF (vFromDate <> 0D) AND (vToDate <> 0D) THEN
                    vDateFilter := FORMAT(vFromDate) + '..' + FORMAT(vToDate);

                IF (vFromDate <> 0D) AND (vToDate <> 0D) THEN
                    vDateFilter := '..' + FORMAT(vToDate);
            end;

            trigger OnPostDataItem()
            begin

                IF bolShowOnlyWithSales THEN BEGIN
                    IF (GetValuesByIndex(codStore, "POS Terminal"."No.", vDateFilter, 1) = 0) THEN
                        CurrReport.SKIP;
                END;
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
                    Caption = 'Filter Options';
                    field("Store Filter:"; codStore)
                    {
                        ApplicationArea = All;
                        TableRelation = "LSC Store"."No.";
                    }
                    field("Terminal FIlter:"; codTerminal)
                    {
                        ApplicationArea = All;
                        TableRelation = "LSC POS Terminal"."No.";
                    }
                    field("Month Filter:"; optMonth)
                    {
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            SetDateFilter();
                        end;
                    }
                    field("Year Filter:"; intYear)
                    {
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin

                            SetDateFilter();
                        end;
                    }
                    field("Date Filter:"; vDateFilterDesc)
                    {
                        ApplicationArea = All;
                    }
                    field("Show Only With Sales"; bolShowOnlyWithSales)
                    {
                        ApplicationArea = All;
                    }
                    field("Create CSV File"; bolCreateCSVFile)
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
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'src\report\Layout\Monthly E-Sales Report.rdl';
        }
    }

    var
        recCompanyInfo: Record "Company Information";
        codStore: Code[10];
        codTerminal: Code[10];
        optMonth: Option January,February,March,April,May,June,July,August,September,October,November,December;
        intYear: integer;
        vDateFilter: Text[30];
        vDateFilterDesc: Text[50];
        bolShowOnlyWithSales: Boolean;
        bolCreateCSVFile: Boolean;
        cduPOSAdditionalFunctions: Codeunit "LSC POS Additional Functions";
        vToDate: Date;
        vFromDate: Date;

    trigger OnInitReport()
    begin
        recCompanyInfo.GET();
        recCompanyInfo.CALCFIELDS(Picture);

        intYear := DATE2DMY(TODAY, 3);
        SetDateFilter();
    end;

    trigger OnPreReport()
    begin
        IF (codStore = '') THEN
            ERROR('Kindly specify a Store Number!');
    end;

    trigger OnPostReport()
    begin
        IF bolCreateCSVFile THEN
            cduPOSAdditionalFunctions.CreateMonthlySalesCSVFile(codStore, codTerminal, vFromDate, vToDate, FORMAT(optMonth));
    end;

    local procedure SetDateFilter()
    begin
        vDateFilter := '';
        vDateFilterDesc := '';

        CASE optMonth OF
            optMonth::January:
                BEGIN
                    EVALUATE(vFromDate, FORMAT(1) + '/01/' + FORMAT(intYear));

                    vToDate := CALCDATE('CM', vFromDate);
                    vDateFilter := FORMAT(vFromDate) + '..' + FORMAT(vToDate);
                    vDateFilterDesc := FORMAT(vFromDate, 0, '<Closing><Day> <Month Text> <Year4>') + '..' + FORMAT(vToDate, 0, '<Closing><Day> <Month Text> <Year4>');
                END;

            optMonth::February:
                BEGIN
                    EVALUATE(vFromDate, FORMAT(2) + '/01/' + FORMAT(intYear));
                    vToDate := CALCDATE('CM', vFromDate);
                    vDateFilter := FORMAT(vFromDate) + '..' + FORMAT(vToDate);
                    vDateFilterDesc := FORMAT(vFromDate, 0, '<Closing><Day> <Month Text> <Year4>') + '..' + FORMAT(vToDate, 0, '<Closing><Day> <Month Text> <Year4>');
                END;

            optMonth::March:
                BEGIN
                    EVALUATE(vFromDate, FORMAT(3) + '/01/' + FORMAT(intYear));
                    vToDate := CALCDATE('CM', vFromDate);
                    vDateFilter := FORMAT(vFromDate) + '..' + FORMAT(vToDate);
                    vDateFilterDesc := FORMAT(vFromDate, 0, '<Closing><Day> <Month Text> <Year4>') + '..' + FORMAT(vToDate, 0, '<Closing><Day> <Month Text> <Year4>');
                END;

            optMonth::April:
                BEGIN
                    EVALUATE(vFromDate, FORMAT(4) + '/01/' + FORMAT(intYear));
                    vToDate := CALCDATE('CM', vFromDate);
                    vDateFilter := FORMAT(vFromDate) + '..' + FORMAT(vToDate);
                    vDateFilterDesc := FORMAT(vFromDate, 0, '<Closing><Day> <Month Text> <Year4>') + '..' + FORMAT(vToDate, 0, '<Closing><Day> <Month Text> <Year4>');
                END;

            optMonth::May:
                BEGIN
                    EVALUATE(vFromDate, FORMAT(5) + '/01/' + FORMAT(intYear));
                    vToDate := CALCDATE('CM', vFromDate);
                    vDateFilter := FORMAT(vFromDate) + '..' + FORMAT(vToDate);
                    vDateFilterDesc := FORMAT(vFromDate, 0, '<Closing><Day> <Month Text> <Year4>') + '..' + FORMAT(vToDate, 0, '<Closing><Day> <Month Text> <Year4>');
                END;

            optMonth::June:
                BEGIN
                    EVALUATE(vFromDate, FORMAT(6) + '/01/' + FORMAT(intYear));
                    vToDate := CALCDATE('CM', vFromDate);
                    vDateFilter := FORMAT(vFromDate) + '..' + FORMAT(vToDate);
                    vDateFilterDesc := FORMAT(vFromDate, 0, '<Closing><Day> <Month Text> <Year4>') + '..' + FORMAT(vToDate, 0, '<Closing><Day> <Month Text> <Year4>');
                END;

            optMonth::July:
                BEGIN
                    EVALUATE(vFromDate, FORMAT(7) + '/01/' + FORMAT(intYear));
                    vToDate := CALCDATE('CM', vFromDate);
                    vDateFilter := FORMAT(vFromDate) + '..' + FORMAT(vToDate);
                    vDateFilterDesc := FORMAT(vFromDate, 0, '<Closing><Day> <Month Text> <Year4>') + '..' + FORMAT(vToDate, 0, '<Closing><Day> <Month Text> <Year4>');
                END;

            optMonth::August:
                BEGIN
                    EVALUATE(vFromDate, FORMAT(8) + '/01/' + FORMAT(intYear));
                    vToDate := CALCDATE('CM', vFromDate);
                    vDateFilter := FORMAT(vFromDate) + '..' + FORMAT(vToDate);
                    vDateFilterDesc := FORMAT(vFromDate, 0, '<Closing><Day> <Month Text> <Year4>') + '..' + FORMAT(vToDate, 0, '<Closing><Day> <Month Text> <Year4>');
                END;

            optMonth::September:
                BEGIN
                    EVALUATE(vFromDate, FORMAT(9) + '/01/' + FORMAT(intYear));
                    vToDate := CALCDATE('CM', vFromDate);
                    vDateFilter := FORMAT(vFromDate) + '..' + FORMAT(vToDate);
                    vDateFilterDesc := FORMAT(vFromDate, 0, '<Closing><Day> <Month Text> <Year4>') + '..' + FORMAT(vToDate, 0, '<Closing><Day> <Month Text> <Year4>');
                END;

            optMonth::October:
                BEGIN
                    EVALUATE(vFromDate, FORMAT(10) + '/01/' + FORMAT(intYear));
                    vToDate := CALCDATE('CM', vFromDate);
                    vDateFilter := FORMAT(vFromDate) + '..' + FORMAT(vToDate);
                    vDateFilterDesc := FORMAT(vFromDate, 0, '<Closing><Day> <Month Text> <Year4>') + '..' + FORMAT(vToDate, 0, '<Closing><Day> <Month Text> <Year4>');
                END;

            optMonth::November:
                BEGIN
                    EVALUATE(vFromDate, FORMAT(11) + '/01/' + FORMAT(intYear));
                    vToDate := CALCDATE('CM', vFromDate);
                    vDateFilter := FORMAT(vFromDate) + '..' + FORMAT(vToDate);
                    vDateFilterDesc := FORMAT(vFromDate, 0, '<Closing><Day> <Month Text> <Year4>') + '..' + FORMAT(vToDate, 0, '<Closing><Day> <Month Text> <Year4>');
                END;

            optMonth::December:
                BEGIN
                    EVALUATE(vFromDate, FORMAT(12) + '/01/' + FORMAT(intYear));
                    vToDate := CALCDATE('CM', vFromDate);
                    vDateFilter := FORMAT(vFromDate) + '..' + FORMAT(vToDate);
                    vDateFilterDesc := FORMAT(vFromDate, 0, '<Closing><Day> <Month Text> <Year4>') + '..' + FORMAT(vToDate, 0, '<Closing><Day> <Month Text> <Year4>');
                END;
        END;
    end;

    local procedure GetBegNEndInvoice(pStore: Code[10]; pTerminal: Code[10]; pDateFilter: Text; pMode: Integer): Code[20]
    var
        recLEODLdgEntry: Record "End Of Day Ledger";
    begin

        recLEODLdgEntry.RESET;
        recLEODLdgEntry.SETCURRENTKEY("Store No.", "POS Terminal No.", Date);

        IF (pStore <> '') THEN
            recLEODLdgEntry.SETRANGE("Store No.", pStore);

        IF (pTerminal <> '') THEN
            recLEODLdgEntry.SETRANGE("POS Terminal No.", pTerminal);

        IF (pDateFilter <> '') THEN
            recLEODLdgEntry.SetFilter(Date, pDateFilter);

        CASE pMode OF
            1:
                BEGIN
                    IF recLEODLdgEntry.FINDFIRST THEN
                        EXIT(recLEODLdgEntry."Beginning Invoice No.")
                    ELSE
                        EXIT('');
                END;
            2:
                BEGIN
                    IF recLEODLdgEntry.FINDLAST THEN
                        EXIT(recLEODLdgEntry."Ending Invoice No.")
                    ELSE
                        EXIT('');
                END;
        END;
    end;

    local procedure GetValuesByIndex(pStore: Code[10]; pTerminal: Code[10]; pDateFilter: Text; pMode: Integer): Decimal
    var
        recLEODLdgEntry: Record "End Of Day Ledger";
    begin
        //GetValuesByIndex //20160414#AA
        //MODE: 1 - GROSS SALES
        //MODE: 2 - ZERO RATED
        //MODE: 3 - VAT EXEMPT
        //MODE: 4 - VATABLE
        //MODE: 5 - TOTAL NET SALES OF VAT
        //MODE: 6 - OUTPUT VAT
        recLEODLdgEntry.RESET;
        recLEODLdgEntry.SETCURRENTKEY("Store No.", "POS Terminal No.", Date);
        IF (pStore <> '') THEN
            recLEODLdgEntry.SETRANGE("Store No.", pStore);

        IF (pTerminal <> '') THEN
            recLEODLdgEntry.SETRANGE("POS Terminal No.", pTerminal);

        IF (pDateFilter <> '') THEN
            recLEODLdgEntry.SetFilter(Date, pDateFilter);

        IF recLEODLdgEntry.FINDFIRST THEN BEGIN
            recLEODLdgEntry.CALCSUMS("Adjusted Sales", "Total Net Sales", "Zero Rated Sales",
                     "VAT Exempt Sales", "Vatable Sales", "VAT 12% Sales");

            CASE pMode OF
                1:
                    EXIT(recLEODLdgEntry."Total Net Sales");
                2:
                    EXIT(recLEODLdgEntry."Zero Rated Sales");
                3:
                    EXIT(recLEODLdgEntry."VAT Exempt Sales");
                4:
                    EXIT(recLEODLdgEntry."Vatable Sales");
                5:
                    EXIT(recLEODLdgEntry."Zero Rated Sales" + recLEODLdgEntry."VAT Exempt Sales" + recLEODLdgEntry."Vatable Sales"); //TOTAL SALES NET OF VAT
                6:
                    EXIT(recLEODLdgEntry."VAT 12% Sales");
            END;
        END;

    end;
}