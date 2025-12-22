report 50000 "Cust. Report Transaction"
{
    ApplicationArea = All;
    Caption = 'Cust. Report Transaction';
    UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = LayoutName;
    dataset
    {
        dataitem(LSCTransactionHeader; "LSC Transaction Header")
        {
            DataItemTableView = sorting("Receipt No.", Date) order(ascending);
            column(transDate; LSCTransactionHeader.Date) { }
            column(InvoiceNo; LSCTransactionHeader."Invoice No.") { }
            column(decVATable; decVATable) { }
            column(decNonVAT; decNonVAT) { }
            column(decVATEx; decVATEx) { }
            column(decVAT12; decVAT12) { }
            column(decZero; decZero) { }
            column(decGross; decGross) { }
            column(vDateFrom; vDateFrom) { }
            column(vDateTo; vDateTo) { }
            column(codCustType; LSCTransactionHeader."Customer Type") { }
            column(codCustType2; codCustType) { }
            column(codCustID; LSCTransactionHeader."Customer No.") { }
            column(recCompanyInfoName; recCompanyInfo.Name) { }
            column(recCompanyInfoAddress; recCompanyInfo.Address + ' ' + recCompanyInfo."Address 2") { }
            column(companypic; recCompanyInfo.Picture) { }
            column(TINNumber_POSTerminal; recCompanyInfo."VAT Registration No.") { }

            column(CustName; RecCustomer.Name) { }

            trigger OnPreDataItem()
            begin
                IF (vDateFrom <> 0D) AND (vDateTo <> 0D) THEN
                    SETRANGE(Date, vDateFrom, vDateTo);
                if codCustType <> codCustType::All then begin
                    if codCustType = codCustType::"Regular Customer" then
                        SetRange("Customer Type", "Customer Type"::"Regular Customer")
                    else
                        SetRange("Customer Type", codCustType)
                end else
                    SetFilter("Customer Type", '<>%1', "Customer Type"::" ");
                SETFILTER("Entry Status", '<>Voided');
            end;

            trigger OnAfterGetRecord()
            begin
                GetVATDetails(LSCTransactionHeader, LSCTransactionHeader."Customer No.");
                IF LSCTransactionHeader."Customer No." <> '' then
                    RecCustomer.GET(LSCTransactionHeader."Customer No.")
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
                    field("Date From "; vDateFrom)
                    {
                        ApplicationArea = All;
                    }
                    field("Date To:"; vDateTo)
                    {
                        ApplicationArea = All;
                    }
                    field("Customer Type:"; codCustType)
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
            LayoutFile = 'src\report\Layout\Cust Transaction Report_new.rdl';
        }
    }

    trigger OnInitReport()
    begin
        recCompanyInfo.GET();
        recCompanyInfo.CALCFIELDS(Picture);
    end;

    var
        decVAT12: Decimal;
        decVATable: Decimal;
        decVATEx: Decimal;
        decNonVAT: Decimal;
        decZero: Decimal;
        decGross: Decimal;
        vDateFrom: Date;
        vDateTo: Date;
        codCustType: Option "All","Senior Citizen","Zero Rated","Solo Parent","Withholding Tax","PWD","VAT Withholding Tax","Regular Customer","ZRWH",Athlete,"Regular";//"All",,"SRC","PWD","Solo Parent","Athlete","Zero Rated","Withholding Tax","VATW","ZRWHT";
        codCustID: Code[20];
        RecCustomer: Record Customer;
        recCompanyInfo: Record "Company Information";

    PROCEDURE GetVATDetails(pTransaction: Record "LSC Transaction Header"; pCustId: Code[20]);
    VAR
        recLTransHeader: Record "LSC Transaction Header";
        recLTransSales: Record "LSC Trans. Sales Entry";
    BEGIN
        //GetVATDetails //20160429#AA
        CLEAR(decVAT12);
        CLEAR(decVATable);
        CLEAR(decVATEx);
        CLEAR(decNonVAT);
        CLEAR(decZero);
        CLEAR(decGross);

        recLTransSales.RESET;
        recLTransSales.SETRANGE("Receipt No.", pTransaction."Receipt No.");
        IF recLTransSales.FINDFIRST THEN
            REPEAT
                CASE recLTransSales."VAT Code" OF
                    'V':
                        BEGIN
                            decVATable += ABS(ROUND(recLTransSales."Net Amount", 0.01, '='));
                            decVAT12 += ABS(ROUND(recLTransSales."VAT Amount", 0.01, '='));
                        END;
                    'VE':
                        BEGIN
                            decVATEx += ABS(ROUND(recLTransSales."Net Amount", 0.01, '='));
                            decNonVAT += ABS(ROUND(recLTransSales."Net Amount", 0.01, '='));
                        END;
                END;
            UNTIL recLTransSales.NEXT = 0;
        decZero := pTransaction."Zero Rated Amount";
        decGross := decVATable + decVATEx + decZero + decVAT12;
    END;

    PROCEDURE CheckIfCustomerHasSales(pLSCustomer: Record Customer): Boolean;
    VAR
        recLTransHeader: Record "LSC Transaction Header";
    BEGIN
        recLTransHeader.RESET;
        recLTransHeader.SETRANGE("Identification Number", pLSCustomer."No.");
        recLTransHeader.SETRANGE("Entry Status", recLTransHeader."Entry Status"::" ");
        recLTransHeader.SETRANGE("Customer Type", pLSCustomer."Customer Type");

        IF (vDateFrom <> 0D) AND (vDateTo <> 0D) THEN
            recLTransHeader.SETRANGE(Date, vDateFrom, vDateTo);

        IF recLTransHeader.FINDFIRST THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE)
    END;
}
