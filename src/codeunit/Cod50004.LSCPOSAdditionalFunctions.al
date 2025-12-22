codeunit 50004 "LSC POS Additional Functions"
{
    trigger OnRun()
    begin

    end;

    var
        POSView: Codeunit "LSC POS View";
        Text004: Label 'POS Command VATExempt on VAT Codes does not exist!';
        text005: Label 'POS Command ZeroRated on VAT Codes does not exist!';
        recEODLedger: Record "End Of Day Ledger";
        recAccumSalesDetails: Record "End Of Day Ledger Details";
        vFile: File;
        vOutstream: OutStream;
        ////////////String Library variable
        ictr: Integer;
        commaCtr: Integer;
        quoteCtr: Integer;
        vChar: Text;
        vTabChar: Text;
        xChar: Char;
    ////////////String Library variable
    ///////////Start----------------------  Pos Additional functions----------------------------

    internal procedure CalculateBalance(var postransaction: Record "LSC POS Transaction"): decimal;
    var
        postranline: Record "LSC POS Trans. Line";
        balance: Decimal;
    begin
        postranline.SetRange("Receipt No.", postransaction."Receipt No.");
        postranline.SetRange("Entry Type", postranline."Entry Type"::Payment);
        if postranline.FindSet() then
            repeat
                balance += postranline.Amount;
            until postranline.Next() = 0;
        exit(Abs(postransaction."Gross Amount") - Abs(balance));
    end;

    internal procedure VATExemptPressed(parReceiptNo: Code[20]; var POSTransaction: Record "LSC POS Transaction"): Boolean
    var
        recLPOSVATCodes: Record "LSC POS VAT Code";
        recLPOSTransLine: Record "LSC POS Trans. Line";
        recLPOSTransaction: Record "LSC POS Transaction";
        recLItem: Record Item;
    begin
        EXIT(true);
        IF (parReceiptNo = '') THEN
            EXIT(FALSE);

        // recLPOSVATCodes.RESET;
        // recLPOSVATCodes.SETRANGE("POS Command", 'VATEXEMPT');
        // IF recLPOSVATCodes.FindFirst() THEN BEGIN
        //     recLPOSVATCodes.TESTFIELD("VAT Bus. Posting Group");
        //     recLPOSTransLine.RESET;
        //     recLPOSTransLine.SETRANGE("Receipt No.", parReceiptNo);
        //     IF recLPOSTransLine.FindFirst THEN
        //         REPEAT
        //             //recLPOSTransaction.Reset();
        //             //recLPOSTransaction.SetRange(recLPOSTransaction."Receipt No.", POSTransaction.);

        //             case
        //                 POSTransaction."Transaction Code Type" of
        //                 POSTransaction."Transaction Code Type"::SRC,
        //                 POSTransaction."Transaction Code Type"::PWD,
        //                 POSTransaction."Transaction Code Type"::ATHL,
        //                 POSTransaction."Transaction Code Type"::SOLO:
        //                     begin
        //                         recLItem.Reset();
        //                         recLItem.SetRange("No.", recLPOSTransLine.Number);
        //                         if recLItem.FindFirst() then begin
        //                             if recLItem."Food Item" then begin
        //                                 if recLItem."Enable Vat Exempt" then begin
        //                                     recLPOSTransLine."VAT Code" := recLPOSVATCodes."VAT Code";
        //                                     recLPOSTransLine."VAT %" := recLPOSVATCodes."VAT %";
        //                                     recLPOSTransLine."Vat Prod. Posting Group" := recLPOSVATCodes."VAT Bus. Posting Group";
        //                                     recLPOSTransLine.VALIDATE(Price, recLPOSTransLine."Org. Price Exc. VAT");
        //                                     recLPOSTransLine.MODIFY;
        //                                 end
        //                             end else begin
        //                                 if recLItem."Enable Vat Exempt" then begin
        //                                     recLPOSTransLine."VAT Code" := recLPOSVATCodes."VAT Code";
        //                                     recLPOSTransLine."VAT %" := recLPOSVATCodes."VAT %";
        //                                     recLPOSTransLine."Vat Prod. Posting Group" := recLPOSVATCodes."VAT Bus. Posting Group";
        //                                     recLPOSTransLine.VALIDATE(Price, recLPOSTransLine."Org. Price Exc. VAT");
        //                                     recLPOSTransLine.MODIFY;
        //                                 end
        //                             end;
        //                         end;
        //                     end;
        //             end;
        //             case
        //                 POSTransaction."Transaction Code Type" of
        //                 POSTransaction."Transaction Code Type"::CASH,
        //                 POSTransaction."Transaction Code Type"::ZERO,
        //                 POSTransaction."Transaction Code Type"::ZRWH:
        //                     begin
        //                         recLPOSTransLine."VAT Code" := recLPOSVATCodes."VAT Code";
        //                         recLPOSTransLine."VAT %" := recLPOSVATCodes."VAT %";
        //                         recLPOSTransLine."Vat Prod. Posting Group" := recLPOSVATCodes."VAT Bus. Posting Group";
        //                         recLPOSTransLine.VALIDATE(Price, recLPOSTransLine."Org. Price Exc. VAT");
        //                         recLPOSTransLine.MODIFY;
        //                     end;
        //             end;

        //         // if (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::SRC) or
        //         //     (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::PWD) or
        //         //     (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::ATHL) or
        //         //     (POSTransaction."Transaction Code Type" <> POSTransaction."Transaction Code Type"::SOLO)
        //         //   then begin
        //         //     recLPOSTransLine."VAT Code" := recLPOSVATCodes."VAT Code";
        //         //     recLPOSTransLine."VAT %" := recLPOSVATCodes."VAT %";
        //         //     recLPOSTransLine."Vat Prod. Posting Group" := recLPOSVATCodes."VAT Bus. Posting Group";
        //         //     recLPOSTransLine.VALIDATE(Price, recLPOSTransLine."Org. Price Exc. VAT");
        //         //     recLPOSTransLine.MODIFY;
        //         // end else begin
        //         //     recLItem.Reset();
        //         //     recLItem.SetRange("No.", recLPOSTransLine.Number);
        //         //     if recLItem.FindFirst() then begin
        //         //         if recLItem."Food Item" then begin
        //         //             if recLItem."Enable Vat Exempt" then begin
        //         //                 recLPOSTransLine."VAT Code" := recLPOSVATCodes."VAT Code";
        //         //                 recLPOSTransLine."VAT %" := recLPOSVATCodes."VAT %";
        //         //                 recLPOSTransLine."Vat Prod. Posting Group" := recLPOSVATCodes."VAT Bus. Posting Group";
        //         //                 recLPOSTransLine.VALIDATE(Price, recLPOSTransLine."Org. Price Exc. VAT");
        //         //                 recLPOSTransLine.MODIFY;
        //         //             end
        //         //         end else begin
        //         //             if recLItem."Enable Vat Exempt" then begin
        //         //                 recLPOSTransLine."VAT Code" := recLPOSVATCodes."VAT Code";
        //         //                 recLPOSTransLine."VAT %" := recLPOSVATCodes."VAT %";
        //         //                 recLPOSTransLine."Vat Prod. Posting Group" := recLPOSVATCodes."VAT Bus. Posting Group";
        //         //                 recLPOSTransLine.VALIDATE(Price, recLPOSTransLine."Org. Price Exc. VAT");
        //         //                 recLPOSTransLine.MODIFY;
        //         //             end
        //         //         end;
        //         //     end;
        //         // end;
        //         /*
        //         recLPOSTransLine."VAT Code" := recLPOSVATCodes."VAT Code";
        //         recLPOSTransLine."VAT %" := recLPOSVATCodes."VAT %";
        //         recLPOSTransLine."Vat Prod. Posting Group" := recLPOSVATCodes."VAT Bus. Posting Group";
        //         recLPOSTransLine.VALIDATE(Price, recLPOSTransLine."Org. Price Exc. VAT");
        //         recLPOSTransLine.MODIFY;*/
        //         UNTIL recLPOSTransLine.NEXT = 0;
        //     EXIT(TRUE);
        // END ELSE BEGIN
        //     POSView.ErrorBeep(Text004);
        //     EXIT(FALSE);
        // END;
    end;

    internal procedure ZeroRatedPressed(parReceiptNo: Code[20]): Boolean
    var
        recLPOSVATCodes: Record "LSC POS VAT Code";
        recLPOSTransLine: Record "LSC POS Trans. Line";
        recLPOSTransaction: Record "LSC POS Transaction";
    begin
        IF (parReceiptNo = '') THEN
            EXIT(FALSE);

        recLPOSVATCodes.RESET;
        recLPOSVATCodes.SETRANGE("POS Command", 'VATEXEMPT');
        IF recLPOSVATCodes.FIND('-') THEN BEGIN
            recLPOSVATCodes.TESTFIELD("VAT Bus. Posting Group");
            recLPOSTransLine.RESET;
            recLPOSTransLine.SetRange("Entry Status", recLPOSTransLine."Entry Status"::" ");
            recLPOSTransLine.SETRANGE("Receipt No.", parReceiptNo);
            IF recLPOSTransLine.FIND('-') THEN
                REPEAT
                    IF recLPOSTransLine."Org. Price Inc. VAT" = 0 THEN BEGIN
                        recLPOSTransLine."Org. Price Inc. VAT" := ROUND(recLPOSTransLine.Price, 0.01, '>');
                        recLPOSTransLine."Org. Price Exc. VAT" := ROUND(recLPOSTransLine."Net Price", 0.01, '>');
                    END;

                    IF NOT (recLPOSTransLine."VAT Code" IN ['VE', 'NV']) THEN BEGIN
                        recLPOSTransLine."VAT Code" := recLPOSVATCodes."VAT Code";
                        recLPOSTransLine."Local VAT Code" := 'VZ';
                        recLPOSTransLine."VAT Code" := 'VZ';
                        recLPOSTransLine."VAT %" := recLPOSVATCodes."VAT %";
                        recLPOSTransLine."Vat Prod. Posting Group" := recLPOSVATCodes."VAT Bus. Posting Group";
                        IF (recLPOSTransLine."Org. Price Exc. VAT" <> 0) THEN
                            recLPOSTransLine.VALIDATE(Price, ROUND(recLPOSTransLine."Org. Price Exc. VAT", 0.01, '>'))
                        ELSE
                            recLPOSTransLine.VALIDATE(Price, recLPOSTransLine.Price);
                        recLPOSTransLine.MODIFY;
                    END
                UNTIL recLPOSTransLine.NEXT = 0;
            EXIT(TRUE);
        END ELSE BEGIN
            POSView.ErrorBeep(Text005);
            EXIT(FALSE);
        END;
    end;

    internal procedure CreateEODLedgerDetails(EntryNo: Integer; decAmount: Decimal; intCount: Integer; codCode: Code[20]; txtEntryType: Text[150])
    var
        EndOfDayLedgerDetails: Record "End Of Day Ledger Details";
        intLLineNo: Integer;
    begin
        recAccumSalesDetails.RESET;
        recAccumSalesDetails.SETRANGE("Entry No.", EntryNo);
        IF NOT recAccumSalesDetails.FINDLAST THEN
            intLLineNo := 10000
        ELSE
            intLLineNo := recAccumSalesDetails."Line No." + 10000;

        EndOfDayLedgerDetails.RESET;
        EndOfDayLedgerDetails."Entry No." := EntryNo;
        EndOfDayLedgerDetails."Line No." := intLLineNo;
        IF txtEntryType = 'Tenders' THEN
            EndOfDayLedgerDetails."Entry Type" := EndOfDayLedgerDetails."Entry Type"::Tenders;
        IF txtEntryType = 'Tender Declare' THEN
            EndOfDayLedgerDetails."Entry Type" := EndOfDayLedgerDetails."Entry Type"::"Tender Declare";
        IF txtEntryType = 'Income/Expense' THEN
            EndOfDayLedgerDetails."Entry Type" := EndOfDayLedgerDetails."Entry Type"::"Income/Expense";
        EndOfDayLedgerDetails.Code := codCode;
        EndOfDayLedgerDetails.Amount := decAmount;
        EndOfDayLedgerDetails.Count := intCount;
        EndOfDayLedgerDetails.INSERT;
    end;

    internal procedure CreateEODLedgerWithArray(parString: ARRAY[500] OF Text): Boolean
    var
        decLTemp: Decimal;
    begin
        //CreateEODLedger 
        CLEAR(recEODLedger);
        recEODLedger.INIT;

        EVALUATE(recEODLedger.Date, parString[1]);
        EVALUATE(recEODLedger."Store No.", parString[2]);
        EVALUATE(recEODLedger."POS Terminal No.", parString[3]);
        EVALUATE(recEODLedger."Staff ID", parString[4]);

        EVALUATE(recEODLedger."Gross Sales Amount", parString[5]);
        EVALUATE(recEODLedger."Line Discount Amount", parString[6]);
        EVALUATE(recEODLedger."Total Discount Amount", parString[7]);
        EVALUATE(recEODLedger.Rounding, parString[8]);
        EVALUATE(recEODLedger."Total Net Sales", parString[9]);

        EVALUATE(recEODLedger."Total Return Amount", parString[10]);
        EVALUATE(recEODLedger."Total Voided Line Amount", parString[11]);
        EVALUATE(recEODLedger."Total Voided Transaction", parString[12]);

        EVALUATE(recEODLedger."Total VAT Amount", parString[13]);
        EVALUATE(recEODLedger."Vatable Sales", parString[14]);
        EVALUATE(recEODLedger."Non Vatable Sales", parString[15]);
        EVALUATE(recEODLedger."Service Charge", parString[16]);

        EVALUATE(recEODLedger."No. of Paying Customers", parString[17]);
        EVALUATE(recEODLedger."No. of Transactions", parString[18]);
        EVALUATE(recEODLedger."No. of Item Sold", parString[19]);
        EVALUATE(recEODLedger."No. of Returns", parString[20]);
        EVALUATE(recEODLedger."No. of Suspended", parString[21]);
        EVALUATE(recEODLedger."No. of Voided Line", parString[22]);

        IF parString[23] <> '' THEN BEGIN
            EVALUATE(recEODLedger."No. of Voided Transaction", parString[23]);
        END;

        IF parString[24] <> '' THEN BEGIN
            EVALUATE(recEODLedger."No. of Training", parString[24]);
        END;

        IF parString[25] <> '' THEN BEGIN
            EVALUATE(decLTemp, parString[25]);
            recEODLedger."No. of Open Drawer" := ROUND(decLTemp, 1);
        END;

        IF parString[26] <> '' THEN BEGIN
            EVALUATE(decLTemp, parString[26]);
            recEODLedger."No. of Logins" := ROUND(decLTemp, 1);
        END;

        IF parString[27] <> '' THEN BEGIN
            EVALUATE(recEODLedger."Beginning Invoice No.", parString[27]);
        END;
        IF parString[28] <> '' THEN BEGIN
            EVALUATE(recEODLedger."Ending Invoice No.", parString[28]);
        END;

        IF parString[29] <> '' THEN BEGIN
            EVALUATE(recEODLedger."Old Accumulated Sales", parString[29]);
        END;

        IF parString[30] <> '' THEN BEGIN
            EVALUATE(recEODLedger."New Accumulated Sales", parString[30]);
        END;

        IF parString[31] <> '' THEN BEGIN
            EVALUATE(recEODLedger."First Receipt No.", parString[31]);
        END;

        IF parString[32] <> '' THEN BEGIN
            EVALUATE(recEODLedger."Last Receipt No.", parString[32]);
        END;

        EVALUATE(recEODLedger."Cash Tender Amount", parString[33]);
        EVALUATE(recEODLedger."Bankard Tender Amount", parString[34]);
        EVALUATE(recEODLedger."WHT Tender Amount", parString[35]);
        EVALUATE(recEODLedger."VATW Tender Amount", parString[36]);

        EVALUATE(recEODLedger."No. of Cash Tender", parString[37]);
        EVALUATE(recEODLedger."No. of Bankard Tender", parString[38]);
        EVALUATE(recEODLedger."No. of WHT Tender", parString[39]);
        EVALUATE(recEODLedger."No. of VATW Tender", parString[40]);

        EVALUATE(recEODLedger."WHT Amount", parString[41]);
        EVALUATE(recEODLedger."VAT Withholding", parString[42]);

        EVALUATE(recEODLedger."Total Tender Amount", parString[43]);
        EVALUATE(recEODLedger."VAT 12% Sales", parString[44]);
        EVALUATE(recEODLedger."VAT Exempt Sales", parString[45]);
        EVALUATE(recEODLedger."Zero Rated Sales", parString[46]);

        EVALUATE(recEODLedger."Adjusted Sales", parString[47]);

        EVALUATE(recEODLedger."No. of Cash Transaction", parString[48]);
        EVALUATE(recEODLedger."No. of Zero Rated Trans.", parString[49]);
        EVALUATE(recEODLedger."No. of BOI Transaction", parString[50]);
        EVALUATE(recEODLedger."No. of Senior Citizen", parString[51]);
        EVALUATE(recEODLedger."No. of PWD Trans.", parString[52]);

        EVALUATE(recEODLedger."Cash Transaction Amount", parString[53]);
        EVALUATE(recEODLedger."Zero Rated Transaction Sales", parString[54]);
        EVALUATE(recEODLedger."BOI Transaction Amount", parString[55]);
        EVALUATE(recEODLedger."Senior Citizen Discount", parString[56]);
        EVALUATE(recEODLedger."SRC Transaction Sales", parString[57]);
        EVALUATE(recEODLedger."PWD Discount", parString[58]);
        EVALUATE(recEODLedger."PWD Transaction Sales", parString[59]);

        EVALUATE(recEODLedger.Time, parString[60]);
        EVALUATE(recEODLedger."Z-Report ID", parString[61]);
        EVALUATE(recEODLedger."No. of Solo Parent Trans.", parString[62]);
        EVALUATE(recEODLedger."Solo Parent Discount", parString[63]);
        EVALUATE(recEODLedger."SOLO Transaction Sales", parString[64]);

        EVALUATE(recEODLedger."Float Entry", parString[65]);
        EVALUATE(recEODLedger."Remove Tender", parString[66]);
        EVALUATE(recEODLedger.ShortOver, parString[67]);

        EVALUATE(recEODLedger."Processed By", parString[68]);
        EVALUATE(recEODLedger."Date Processed", parString[69]);
        EVALUATE(recEODLedger."Starting Time", parString[70]);
        EVALUATE(recEODLedger."Ending Time", parString[71]);

        EVALUATE(recEODLedger."Delivery Charge", parString[72]);
        EVALUATE(recEODLedger."Tender Declaration Amount", parString[73]);
        EVALUATE(recEODLedger."NonVat Net Sales Src", parString[74]);

        EVALUATE(recEODLedger."Beginning Ayala OR", parString[75]);
        EVALUATE(recEODLedger."Ending Ayala OR", parString[76]);

        EVALUATE(recEODLedger."Date Printed", parString[77]);
        EVALUATE(recEODLedger."Time Printed", parString[78]);

        Evaluate(recEODLedger."Bankard 1 Description", parString[79]);
        Evaluate(recEODLedger."Bankard 1 Amount", parString[80]);
        Evaluate(recEODLedger."Bankard 1 Count", parString[81]);

        Evaluate(recEODLedger."Bankard 2 Description", parString[82]);
        Evaluate(recEODLedger."Bankard 2 Amount", parString[83]);
        Evaluate(recEODLedger."Bankard 2 Count", parString[84]);

        Evaluate(recEODLedger."Bankard 3 Description", parString[85]);
        Evaluate(recEODLedger."Bankard 3 Amount", parString[86]);
        Evaluate(recEODLedger."Bankard 3 Count", parString[87]);

        Evaluate(recEODLedger."Bankard 4 Description", parString[88]);
        Evaluate(recEODLedger."Bankard 4 Amount", parString[89]);
        Evaluate(recEODLedger."Bankard 4 Count", parString[90]);

        Evaluate(recEODLedger."Bankard 5 Description", parString[91]);
        Evaluate(recEODLedger."Bankard 5 Amount", parString[92]);
        Evaluate(recEODLedger."Bankard 5 Count", parString[93]);

        Evaluate(recEODLedger."Bankard 6 Description", parString[94]);
        Evaluate(recEODLedger."Bankard 6 Amount", parString[95]);
        Evaluate(recEODLedger."Bankard 6 Count", parString[96]);

        Evaluate(recEODLedger."Bankard 7 Description", parString[97]);
        Evaluate(recEODLedger."Bankard 7 Amount", parString[98]);
        Evaluate(recEODLedger."Bankard 7 Count", parString[99]);

        Evaluate(recEODLedger."Bankard 8 Description", parString[100]);
        Evaluate(recEODLedger."Bankard 8 Amount", parString[101]);
        Evaluate(recEODLedger."Bankard 8 Count", parString[102]);

        Evaluate(recEODLedger."Bankard 9 Description", parString[103]);
        Evaluate(recEODLedger."Bankard 9 Amount", parString[104]);
        Evaluate(recEODLedger."Bankard 9 Count", parString[105]);

        Evaluate(recEODLedger."Bankard 10 Description", parString[106]);
        Evaluate(recEODLedger."Bankard 10 Amount", parString[107]);
        Evaluate(recEODLedger."Bankard 10 Count", parString[108]);

        Evaluate(recEODLedger."Bankard 11 Description", parString[109]);
        Evaluate(recEODLedger."Bankard 11 Amount", parString[110]);
        Evaluate(recEODLedger."Bankard 11 Count", parString[111]);

        Evaluate(recEODLedger."Bankard 12 Description", parString[112]);
        Evaluate(recEODLedger."Bankard 12 Amount", parString[113]);
        Evaluate(recEODLedger."Bankard 12 Count", parString[114]);

        Evaluate(recEODLedger."Bankard 13 Description", parString[115]);
        Evaluate(recEODLedger."Bankard 13 Amount", parString[116]);
        Evaluate(recEODLedger."Bankard 13 Count", parString[117]);

        Evaluate(recEODLedger."Bankard 14 Description", parString[118]);
        Evaluate(recEODLedger."Bankard 14 Amount", parString[119]);
        Evaluate(recEODLedger."Bankard 14 Count", parString[120]);

        Evaluate(recEODLedger."Bankard 15 Description", parString[121]);
        Evaluate(recEODLedger."Bankard 15 Amount", parString[122]);
        Evaluate(recEODLedger."Bankard 15 Count", parString[123]);

        Evaluate(recEODLedger."Bankard 16 Description", parString[124]);
        Evaluate(recEODLedger."Bankard 16 Amount", parString[125]);
        Evaluate(recEODLedger."Bankard 16 Count", parString[126]);

        Evaluate(recEODLedger."Bankard 17 Description", parString[127]);
        Evaluate(recEODLedger."Bankard 17 Amount", parString[128]);
        Evaluate(recEODLedger."Bankard 17 Count", parString[129]);

        Evaluate(recEODLedger."Bankard 18 Description", parString[130]);
        Evaluate(recEODLedger."Bankard 18 Amount", parString[131]);
        Evaluate(recEODLedger."Bankard 18 Count", parString[132]);

        Evaluate(recEODLedger."Bankard 19 Description", parString[133]);
        Evaluate(recEODLedger."Bankard 19 Amount", parString[134]);
        Evaluate(recEODLedger."Bankard 19 Count", parString[135]);

        Evaluate(recEODLedger."Bankard 20 Description", parString[136]);
        Evaluate(recEODLedger."Bankard 20 Amount", parString[137]);
        Evaluate(recEODLedger."Bankard 20 Count", parString[138]);

        Evaluate(recEODLedger."Bankard 21 Description", parString[139]);
        Evaluate(recEODLedger."Bankard 21 Amount", parString[140]);
        Evaluate(recEODLedger."Bankard 21 Count", parString[141]);

        Evaluate(recEODLedger."Bankard 22 Description", parString[142]);
        Evaluate(recEODLedger."Bankard 22 Amount", parString[143]);
        Evaluate(recEODLedger."Bankard 22 Count", parString[144]);

        Evaluate(recEODLedger."Bankard 23 Description", parString[145]);
        Evaluate(recEODLedger."Bankard 23 Amount", parString[146]);
        Evaluate(recEODLedger."Bankard 23 Count", parString[147]);

        Evaluate(recEODLedger."Bankard 24 Description", parString[148]);
        Evaluate(recEODLedger."Bankard 24 Amount", parString[149]);
        Evaluate(recEODLedger."Bankard 24 Count", parString[150]);

        Evaluate(recEODLedger."Bankard 25 Description", parString[151]);
        Evaluate(recEODLedger."Bankard 25 Amount", parString[152]);
        Evaluate(recEODLedger."Bankard 25 Count", parString[153]);

        Evaluate(recEODLedger."Bankard 26 Description", parString[154]);
        Evaluate(recEODLedger."Bankard 26 Amount", parString[155]);
        Evaluate(recEODLedger."Bankard 26 Count", parString[156]);

        Evaluate(recEODLedger."Bankard 27 Description", parString[157]);
        Evaluate(recEODLedger."Bankard 27 Amount", parString[158]);
        Evaluate(recEODLedger."Bankard 27 Count", parString[159]);

        Evaluate(recEODLedger."Bankard 28 Description", parString[160]);
        Evaluate(recEODLedger."Bankard 28 Amount", parString[161]);
        Evaluate(recEODLedger."Bankard 28 Count", parString[162]);

        Evaluate(recEODLedger."Bankard 29 Description", parString[163]);
        Evaluate(recEODLedger."Bankard 29 Amount", parString[164]);
        Evaluate(recEODLedger."Bankard 29 Count", parString[165]);

        Evaluate(recEODLedger."Bankard 30 Description", parString[166]);
        Evaluate(recEODLedger."Bankard 30 Amount", parString[167]);
        Evaluate(recEODLedger."Bankard 30 Count", parString[168]);

        Evaluate(recEODLedger."Bankard 31 Description", parString[169]);
        Evaluate(recEODLedger."Bankard 31 Amount", parString[170]);
        Evaluate(recEODLedger."Bankard 31 Count", parString[171]);

        Evaluate(recEODLedger."Bankard 32 Description", parString[172]);
        Evaluate(recEODLedger."Bankard 32 Amount", parString[173]);
        Evaluate(recEODLedger."Bankard 32 Count", parString[174]);

        Evaluate(recEODLedger."Bankard 33 Description", parString[175]);
        Evaluate(recEODLedger."Bankard 33 Amount", parString[176]);
        Evaluate(recEODLedger."Bankard 33 Count", parString[177]);

        Evaluate(recEODLedger."Bankard 34 Description", parString[178]);
        Evaluate(recEODLedger."Bankard 34 Amount", parString[179]);
        Evaluate(recEODLedger."Bankard 34 Count", parString[180]);

        Evaluate(recEODLedger."Bankard 35 Description", parString[181]);
        Evaluate(recEODLedger."Bankard 35 Amount", parString[182]);
        Evaluate(recEODLedger."Bankard 35 Count", parString[183]);

        Evaluate(recEODLedger."Bankard 36 Description", parString[184]);
        Evaluate(recEODLedger."Bankard 36 Amount", parString[185]);
        Evaluate(recEODLedger."Bankard 36 Count", parString[186]);

        Evaluate(recEODLedger."Bankard 37 Description", parString[187]);
        Evaluate(recEODLedger."Bankard 37 Amount", parString[188]);
        Evaluate(recEODLedger."Bankard 37 Count", parString[189]);

        Evaluate(recEODLedger."Bankard 38 Description", parString[190]);
        Evaluate(recEODLedger."Bankard 38 Amount", parString[191]);
        Evaluate(recEODLedger."Bankard 38 Count", parString[192]);

        Evaluate(recEODLedger."Bankard 39 Description", parString[193]);
        Evaluate(recEODLedger."Bankard 39 Amount", parString[194]);
        Evaluate(recEODLedger."Bankard 39 Count", parString[195]);

        Evaluate(recEODLedger."Bankard 40 Description", parString[196]);
        Evaluate(recEODLedger."Bankard 40 Amount", parString[197]);
        Evaluate(recEODLedger."Bankard 40 Count", parString[198]);

        Evaluate(recEODLedger."Card 1 Description", parString[199]);
        Evaluate(recEODLedger."Card 1 Amount", parString[200]);
        Evaluate(recEODLedger."Card 1 Count", parString[201]);

        Evaluate(recEODLedger."Card 2 Description", parString[202]);
        Evaluate(recEODLedger."Card 2 Amount", parString[203]);
        Evaluate(recEODLedger."Card 2 Count", parString[204]);

        Evaluate(recEODLedger."Card 3 Description", parString[205]);
        Evaluate(recEODLedger."Card 3 Amount", parString[206]);
        Evaluate(recEODLedger."Card 3 Count", parString[207]);

        Evaluate(recEODLedger."Card 4 Description", parString[208]);
        Evaluate(recEODLedger."Card 4 Amount", parString[209]);
        Evaluate(recEODLedger."Card 4 Count", parString[210]);

        Evaluate(recEODLedger."Card 5 Description", parString[211]);
        Evaluate(recEODLedger."Card 5 Amount", parString[212]);
        Evaluate(recEODLedger."Card 5 Count", parString[213]);

        Evaluate(recEODLedger."Card 6 Description", parString[214]);
        Evaluate(recEODLedger."Card 6 Amount", parString[215]);
        Evaluate(recEODLedger."Card 6 Count", parString[216]);

        Evaluate(recEODLedger."Card 7 Description", parString[217]);
        Evaluate(recEODLedger."Card 7 Amount", parString[218]);
        Evaluate(recEODLedger."Card 7 Count", parString[219]);

        Evaluate(recEODLedger."Card 8 Description", parString[220]);
        Evaluate(recEODLedger."Card 8 Amount", parString[221]);
        Evaluate(recEODLedger."Card 8 Count", parString[222]);

        Evaluate(recEODLedger."Card 9 Description", parString[223]);
        Evaluate(recEODLedger."Card 9 Amount", parString[224]);
        Evaluate(recEODLedger."Card 9 Count", parString[225]);

        Evaluate(recEODLedger."Card 10 Description", parString[226]);
        Evaluate(recEODLedger."Card 10 Amount", parString[227]);
        Evaluate(recEODLedger."Card 10 Count", parString[228]);

        Evaluate(recEODLedger."Card 11 Description", parString[229]);
        Evaluate(recEODLedger."Card 11 Amount", parString[230]);
        Evaluate(recEODLedger."Card 11 Count", parString[231]);

        Evaluate(recEODLedger."Card 12 Description", parString[232]);
        Evaluate(recEODLedger."Card 12 Amount", parString[233]);
        Evaluate(recEODLedger."Card 12 Count", parString[234]);

        Evaluate(recEODLedger."Card 13 Description", parString[235]);
        Evaluate(recEODLedger."Card 13 Amount", parString[236]);
        Evaluate(recEODLedger."Card 13 Count", parString[237]);

        Evaluate(recEODLedger."Card 14 Description", parString[238]);
        Evaluate(recEODLedger."Card 14 Amount", parString[239]);
        Evaluate(recEODLedger."Card 14 Count", parString[240]);

        Evaluate(recEODLedger."Card 15 Description", parString[241]);
        Evaluate(recEODLedger."Card 15 Amount", parString[242]);
        Evaluate(recEODLedger."Card 15 Count", parString[243]);

        EVALUATE(recEODLedger."No. of Athl Trans.", parString[244]);
        EVALUATE(recEODLedger."Athl Discount", parString[245]);
        EVALUATE(recEODLedger."Athlete Transaction Sales", parString[246]);
        EVALUATE(recEODLedger."Zero Rated Amount", parString[247]);
        EVALUATE(recEODLedger."Total Refund Amount", parString[248]);
        EVALUATE(recEODLedger."Total Return Amount", parString[249]);

        IF recEODLedger.INSERT(TRUE) THEN
            EXIT(TRUE);
        EXIT(FALSE);
    end;

    internal procedure CreateMonthlySalesCSVFile(pStore: Code[20]; pTerminal: Code[20]; pDateFrom: Date; pDateTo: Date; pMonth: Code[20])
    var
        txtlFileName: Text[1024];
        recLEODLedg: Record "End Of Day Ledger";
        recLPOSTerminal: Record "LSC POS Terminal";
    begin
        // txtLFileName := '';// GetFilePath(pStore) + '\' + 'POS SALES' + pMonth + FORMAT(DATE2DMY(pDateTo, 3)) + '.csv';

        // IF NOT EXISTS(txtLFileName) THEN
        //     vFile.CREATE(txtLFileName)
        // ELSE BEGIN
        //     ERASE(txtLFileName);
        //     vFile.CREATE(txtLFileName);
        // END;

        // vFile.CREATEOUTSTREAM(vOutstream);

        // WITH recLPOSTerminal DO BEGIN
        //     RESET;
        //     IF (pStore <> '') THEN
        //         SETRANGE("Store No.", pStore);
        //     IF (pTerminal <> '') THEN
        //         SETRANGE("No.", pTerminal);

        //     IF FINDFIRST THEN
        //         REPEAT
        //             //HEADER
        //             vOutstream.WRITETEXT('TIN' + ',' +
        //                                  'Serial' + ',' +
        //                                  'Month' + ',' +
        //                                  'Year' + ',' +
        //                                  'MIN' + ',' +
        //                                  'LAST OR' + ',' +
        //                                  'Vatable Sales' + ',' +
        //                                  'Zero Rated Sales' + ',' +
        //                                  'VAT Exempt Sales' + ',' +
        //                                  'Other Taxes');
        //             vOutstream.WRITETEXT();

        //             //BODY
        //             vOutstream.WRITETEXT("MIN Number" + ',' + //TIN dapat MIN muna habang wala pa format
        //                                  "Serial Number" + ',' +
        //                                  pMonth + ',' +
        //                                  FORMAT(DATE2DMY(pDateTo, 3)) + ',' +
        //                                  "MIN Number" + ',' +
        //                                  GetSalesValue(pStore, "No.", pDateFrom, pDateTo, 5) + ',' +
        //                                  GetSalesValue(pStore, "No.", pDateFrom, pDateTo, 1) + ',' +
        //                                  GetSalesValue(pStore, "No.", pDateFrom, pDateTo, 2) + ',' +
        //                                  GetSalesValue(pStore, "No.", pDateFrom, pDateTo, 3) + ',' +
        //                                  Dec2Str(0.0, 1));
        //             vOutstream.WRITETEXT();

        //         UNTIL NEXT = 0;
        // END;

        // vFile.CLOSE();
    end;




    /*
        internal procedure GetFilePath(pStore: Code[20]): Text[1024]
        var
            recLStore: Record "LSC Store";
            Error001: Label 'No %1 Setup Found on %2. ';
        begin
            IF recLStore.GET(pStore) THEN BEGIN
                IF recLStore."NAV Reports File Path" <> '' THEN
                    EXIT(recLStore."NAV Reports File Path")
                ELSE
                    ERROR(Error001, recLStore.FIELDCAPTION("NAV Reports File Path"), 'Store Card');
            END;
        end;
    */

    internal procedure GetSalesValue(pStore: Code[20]; pTerminal: Code[20]; pDateFrom: Date; pDateTo: Date; pMode: Integer): Text
    var
        recLEODLedg: Record "End Of Day Ledger";
    begin
        recLEODLedg.RESET;
        recLEODLedg.SETCURRENTKEY("Store No.", "POS Terminal No.", Date);
        recLEODLedg.SETRANGE("Store No.", pStore);
        recLEODLedg.SETRANGE("POS Terminal No.", pTerminal);
        recLEODLedg.SETRANGE(Date, pDateFrom, pDateTo);
        recLEODLedg.CALCSUMS("Vatable Sales", "Zero Rated Sales", "VAT Exempt Sales", "VAT 12% Sales");
        IF recLEODLedg.FINDFIRST THEN BEGIN
            CASE pMode OF
                1:
                    EXIT(Dec2Str(recLEODLedg."Vatable Sales", 1));
                2:
                    EXIT(Dec2Str(recLEODLedg."Zero Rated Sales", 1));
                3:
                    EXIT(Dec2Str(recLEODLedg."VAT Exempt Sales", 1));
                4:
                    EXIT(Dec2Str(recLEODLedg."VAT 12% Sales", 1));
                5:
                    EXIT(recLEODLedg."Ending Invoice No.");
            END;
        END ELSE
            EXIT('0');
    end;

    internal procedure Dec2Str(Value: Decimal; Mode: Integer): Text
    //Dec2Str
    begin
        CASE Mode OF
            1:
                EXIT(DELCHR(FORMAT(Value, 0, '<Sign><Integer Thousand><Decimal,3>'), '=', ','));
        END;
    end;
    ///////////Ending----/Start  Pos Additional functions----------------------------


    ///////////Start----/String Library internal procedure----------------------------Copy from LS NAV
    internal procedure clistcount(VStrList: Text[500]): Integer
    var
        vretval: Integer;
        vStrLen: Integer;
    begin
        vretval := 0;
        commaCtr := 0;
        quoteCtr := 0;

        vStrLen := STRLEN(VStrList);
        FOR ictr := 1 TO vStrLen DO BEGIN
            vChar := COPYSTR(VStrList, ictr, 1);

            //--- if comma count it --------
            IF ((vChar = ',') AND (quoteCtr = 0)) THEN BEGIN
                commaCtr := commaCtr + 1;
            END;
            //--- if quote ---
            IF vChar = '"' THEN BEGIN
                IF quoteCtr = 0 THEN
                    quoteCtr := quoteCtr + 1
                ELSE
                    quoteCtr := 0;
            END;

        END;

        EXIT(commaCtr + 1);
    end;

    internal procedure tablistcount(VStrList: Text[500]): Integer
    var
        vretval: Integer;
        vStrLen: Integer;
    begin
        vretval := 0;
        commaCtr := 0;
        quoteCtr := 0;

        //--- Tab ---
        xChar := 9;
        vTabChar := FORMAT(xChar);

        vStrLen := STRLEN(VStrList);
        FOR ictr := 1 TO vStrLen DO BEGIN
            vChar := COPYSTR(VStrList, ictr, 1);

            //--- if comma count it --------
            IF ((vChar = vTabChar) AND (quoteCtr = 0)) THEN BEGIN
                commaCtr := commaCtr + 1;
            END;
            //--- if quote ---
            IF vChar = '"' THEN BEGIN
                IF quoteCtr = 0 THEN
                    quoteCtr := quoteCtr + 1
                ELSE
                    quoteCtr := 0;
            END;

        END;

        EXIT(commaCtr + 1);
    end;

    internal procedure clistentry3(VStrList: text[1024]; VIndex: Integer): Text[1024]
    var
        vRetVal: Text;
        LCnt: Integer;
    begin
        LCnt := clistcount(VStrList);

        IF VIndex > LCnt THEN BEGIN
            vRetVal := '';
        END
        ELSE BEGIN
            vRetVal := SELECTSTR(VIndex, VStrList);
        END;

        EXIT(vRetVal);
    end;

    internal procedure clistentry(VStrList: text[1024]; VIndex: Integer): Text[1024]
    var
        vretVal: Integer;
        vStrLen: Integer;
        valueStr: Text[1000];
    begin
        vretval := 0;
        commaCtr := 0;
        quoteCtr := 0;
        valueStr := '';

        vStrLen := STRLEN(VStrList);
        FOR ictr := 1 TO vStrLen DO BEGIN
            vChar := COPYSTR(VStrList, ictr, 1);
            valueStr := valueStr + vChar;

            //--- if comma count it --------
            IF ((vChar = ',') AND (quoteCtr = 0)) THEN BEGIN
                commaCtr := commaCtr + 1;

                IF commaCtr = VIndex THEN BEGIN
                    EXIT(COPYSTR(valueStr, 1, STRLEN(valueStr) - 1));
                END
                ELSE
                    valueStr := '';
            END;
            //--- if quote ---
            IF vChar = '"' THEN BEGIN
                IF quoteCtr = 0 THEN
                    quoteCtr := quoteCtr + 1
                ELSE
                    quoteCtr := 0;
            END;

        END;

        IF (commaCtr + 1) = VIndex THEN BEGIN
            EXIT(valueStr);
        END
        ELSE
            valueStr := '';
    end;

    internal procedure clistentry2(VStrList: text[1024]; VIndex: Integer; pSeparator: Text[1]): Text[1024]
    var
        vretVal: Integer;
        vStrLen: Integer;
        valueStr: Text[1000];
    begin
        IF pSeparator = '' THEN
            pSeparator := ',';

        vretval := 0;
        commaCtr := 0;
        quoteCtr := 0;
        valueStr := '';

        vStrLen := STRLEN(VStrList);
        FOR ictr := 1 TO vStrLen DO BEGIN
            vChar := COPYSTR(VStrList, ictr, 1);
            valueStr := valueStr + vChar;

            //--- if comma count it --------
            IF ((vChar = pSeparator) AND (quoteCtr = 0)) THEN BEGIN
                commaCtr := commaCtr + 1;

                IF commaCtr = VIndex THEN BEGIN
                    EXIT(COPYSTR(valueStr, 1, STRLEN(valueStr) - 1));
                END
                ELSE
                    valueStr := '';
            END;
            //--- if quote ---
            IF vChar = '"' THEN BEGIN
                IF quoteCtr = 0 THEN
                    quoteCtr := quoteCtr + 1
                ELSE
                    quoteCtr := 0;
            END;

        END;

        IF (commaCtr + 1) = VIndex THEN BEGIN
            EXIT(valueStr);
        END
        ELSE
            valueStr := '';
    end;

    internal procedure clistentry2B(VStrList: text[1024]; VIndex: Integer; pSeparator: Text[3]): Text[1024]
    var
        vretVal: Integer;
        vStrLen: Integer;
        valueStr: Text[1000];
        vCharSep: Text[3];
        vSepLen: Integer;
    begin
        //--- with values delimited by a max of 3 characters ----------------------

        IF pSeparator = '' THEN
            pSeparator := ',';
        vSepLen := STRLEN(pSeparator);

        vretval := 0;
        commaCtr := 0;
        quoteCtr := 0;
        valueStr := '';

        vStrLen := STRLEN(VStrList);
        FOR ictr := 1 TO vStrLen DO BEGIN
            vChar := COPYSTR(VStrList, ictr, 1);
            vCharSep := COPYSTR(VStrList, ictr, vSepLen);
            valueStr := valueStr + vChar;

            //--- if comma count it --------
            //---disregard QUOTE--->IF ((vCharSep = pSeparator) AND (quoteCtr = 0)) THEN BEGIN
            IF (vCharSep = pSeparator) THEN BEGIN
                commaCtr := commaCtr + 1;

                IF commaCtr = VIndex THEN BEGIN
                    IF VIndex = 1 THEN BEGIN
                        EXIT(COPYSTR(valueStr, 1, STRLEN(valueStr) - 1));
                    END ELSE BEGIN
                        EXIT(COPYSTR(valueStr, vSepLen, STRLEN(valueStr) - vSepLen));
                    END;
                END
                ELSE
                    valueStr := '';
            END;

        END;

        IF (commaCtr + 1) = VIndex THEN BEGIN
            EXIT(COPYSTR(valueStr, vSepLen));
        END
        ELSE
            valueStr := '';

    end;

    internal procedure clistentry2C(VStrList: text[1024]; VIndex: Integer; pSeparator: Text[5]): Text[1024]
    var
        vretVal: Integer;
        vStrLen: Integer;
        valueStr: Text[1000];
        vCharSep: Text[5];
        vSepLen: Integer;
    begin
        //--- with values delimited by a max of 3 characters ----------------------

        IF pSeparator = '' THEN
            pSeparator := '|';
        vSepLen := STRLEN(pSeparator);

        vretval := 0;
        commaCtr := 0;
        quoteCtr := 0;
        valueStr := '';

        vStrLen := STRLEN(VStrList);
        FOR ictr := 1 TO vStrLen DO BEGIN
            vChar := COPYSTR(VStrList, ictr, 1);
            vCharSep := COPYSTR(VStrList, ictr, vSepLen);
            valueStr := valueStr + vChar;

            //--- if comma count it --------
            //---disregard QUOTE--->IF ((vCharSep = pSeparator) AND (quoteCtr = 0)) THEN BEGIN
            IF (vCharSep = pSeparator) THEN BEGIN
                commaCtr := commaCtr + 1;

                IF commaCtr = VIndex THEN BEGIN
                    IF VIndex = 1 THEN BEGIN
                        EXIT(COPYSTR(valueStr, 1, STRLEN(valueStr) - 1));
                    END ELSE BEGIN
                        EXIT(COPYSTR(valueStr, vSepLen, STRLEN(valueStr) - vSepLen));
                    END;
                END
                ELSE
                    valueStr := '';
            END;

        END;

        IF (commaCtr + 1) = VIndex THEN BEGIN
            EXIT(COPYSTR(valueStr, vSepLen));
        END
        ELSE
            valueStr := '';
    end;

    internal procedure tablistentry(VStrList: text[1024]; VIndex: Integer): Text[1024]
    var
        vretVal: Integer;
        vStrLen: Integer;
        valueStr: Text[1000];
    begin
        vretval := 0;
        commaCtr := 0;
        quoteCtr := 0;
        valueStr := '';
        //--- Tab ---
        xChar := 9;
        vTabChar := FORMAT(xChar);

        vStrLen := STRLEN(VStrList);
        FOR ictr := 1 TO vStrLen DO BEGIN
            vChar := COPYSTR(VStrList, ictr, 1);
            valueStr := valueStr + vChar;

            //--- if comma count it --------
            IF ((vChar = vTabChar) AND (quoteCtr = 0)) THEN BEGIN
                commaCtr := commaCtr + 1;

                IF commaCtr = VIndex THEN BEGIN
                    EXIT(COPYSTR(valueStr, 1, STRLEN(valueStr) - 1));
                END
                ELSE
                    valueStr := '';
            END;
            //--- if quote ---
            IF vChar = '"' THEN BEGIN
                IF quoteCtr = 0 THEN
                    quoteCtr := quoteCtr + 1
                ELSE
                    quoteCtr := 0;
            END;

        END;

        IF (commaCtr + 1) = VIndex THEN BEGIN
            EXIT(valueStr);
        END
        ELSE
            valueStr := '';
    end;

    internal procedure clistlookup(VStr: Text[100]; VStrList: Text[500]; VCSensitive: Boolean; VSSensitive: Boolean): Integer
    var
        vRetVal: Integer;
        LCnt: Integer;
        LCtr: Integer;
        VCmp: Text[500];
    begin
        IF VCSensitive THEN
            VStr := UPPERCASE(VStr);

        IF VSSensitive THEN
            VStr := alltrim(VStr);

        vRetVal := 0;
        LCnt := clistcount(VStrList);

        FOR LCtr := 1 TO LCnt DO BEGIN

            IF VCSensitive THEN
                VCmp := UPPERCASE(clistentry(VStrList, LCtr))
            ELSE
                VCmp := clistentry(VStrList, LCtr);

            IF VSSensitive THEN
                VCmp := alltrim(VCmp);

            IF VCmp = VStr THEN
                vRetVal := LCtr;

        END;

        EXIT(vRetVal);
    end;

    internal procedure alltrim(VStr: Text[500]): Text[500]
    var
        VLen: Integer;
        vchar: Text[1];
        retStr: Text[500];
        vsctr: Integer;
    begin
        VLen := STRLEN(VStr);
        vsctr := 0;

        FOR ictr := 1 TO VLen DO BEGIN
            vchar := COPYSTR(VStr, ictr, 1);

            IF vchar = ' ' THEN BEGIN
                vsctr := vsctr + 1;
            END
            ELSE BEGIN
                ictr := VLen * 2;
            END;
        END;

        VStr := COPYSTR(VStr, vsctr + 1, 1000);
        VLen := STRLEN(VStr);
        vsctr := 0;

        FOR ictr := 1 TO VLen DO BEGIN
            vchar := COPYSTR(VStr, VLen - ictr + 1, 1);

            IF vchar = ' ' THEN BEGIN
                vsctr := vsctr + 1;
            END
            ELSE BEGIN
                ictr := VLen * 2;
            END;
        END;

        VStr := COPYSTR(VStr, 1, VLen - vsctr);

        EXIT(VStr);
    end;

    internal procedure NoQuotes(vstr: Text[1024]): Text[1024]
    var
        tlen: Integer;
        newstr: Text[1000];
    begin

        tlen := STRLEN(vstr);

        IF tlen > 0 THEN BEGIN

            IF COPYSTR(vstr, 1, 1) = '"' THEN
                newstr := COPYSTR(vstr, 2, tlen)
            ELSE
                newstr := vstr;

            tlen := STRLEN(newstr);

            IF COPYSTR(newstr, tlen, 1) = '"' THEN
                newstr := COPYSTR(newstr, 1, tlen - 1);

            EXIT(newstr);

        END
        ELSE
            EXIT('');
    end;

    internal procedure padl(pString: Text[200]; plength: Integer; pChar: Text[1]): Text[200]
    var
        vLen: Integer;
        retStr: Text[200];
    begin
        vLen := STRLEN(pString);

        //--- truncate the string --------------
        IF vLen > pLength THEN
            EXIT(COPYSTR(pString, 1, pLength));

        //--- pad it ---
        retStr := replicate(pChar, pLength - vLen) + pString;

        EXIT(retStr);
    end;

    internal procedure padr(pString: Text[200]; pLength: Integer; pChar: Text[1]): Text[200]
    var
        vLen: Integer;
        retStr: Text[200];
    begin
        vLen := STRLEN(pString);

        //--- truncate the string --------------
        IF vLen > pLength THEN
            EXIT(COPYSTR(pString, 1, pLength));

        //--- pad it ---
        retStr := pString + replicate(pChar, pLength - vLen);

        EXIT(retStr);
    end;

    internal procedure replicate(pChar: Text[1]; pLength: Integer): Text[200]
    var
        ictr: Integer;
        repStr: Text[200];
    begin
        IF pLength > 200 THEN
            pLength := 200;
        repStr := '';
        FOR ictr := 1 TO pLength DO BEGIN
            repStr := repStr + pChar;
        END;

        EXIT(repStr);
    end;

    internal procedure dtoc(vDate: Date): Text[10]
    var
        strDate: Text[10];
    begin
        strDate := FORMAT(vDate, 0, '<Month,2>/<Day,2>/20<Year>');

        EXIT(strDate);
    end;

    internal procedure ConvertAsciiStr(pString: Text[1024]): Text[1024]
    var
        ctr: Integer;
        PairCnt: Integer;
        ctr2: Integer;
        aSavedParam: text[30];
        vTrimStr: Text[1024];
        vAsciiCode: Integer;
        vFile: File;
    begin
        FOR ctr := 1 TO STRLEN(pString) DO BEGIN
            IF COPYSTR(pString, ctr, 1) = '<' THEN BEGIN
                FOR ctr2 := ctr TO STRLEN(pString) DO BEGIN
                    IF COPYSTR(pString, ctr2, 1) = '>' THEN BEGIN
                        PairCnt := PairCnt + 1;
                        aSavedParam := COPYSTR(pString, ctr + 1, (ctr2 - (ctr + 1)));
                        EVALUATE(vAsciiCode, aSavedParam);
                        vTrimStr := vTrimStr + GenerateChr(vAsciiCode);
                        ctr := ctr2;
                        ctr2 := STRLEN(pString) + 1;
                    END;
                END;
            END ELSE
                vTrimStr := vTrimStr + COPYSTR(pString, ctr, 1);
        END;

        EXIT(vTrimStr);
    end;

    internal procedure GenerateChr(pAsciiCode: Integer): Text[30]
    var
        retVal: Integer;
    begin
        retVal := pAsciiCode;
        EXIT(FORMAT(retVal));
    end;

    internal procedure RAT(StrSearch: Text[10]; StrList: Text[100]): Integer
    var
        NewString: Text[30];
        LenNewStr: Integer;
        cLen: Integer;
        slashctr: Integer;
        strcopy: Text[100];
    begin
        //RAT
        CLEAR(cLen);
        cLen := STRLEN(StrList);
        FOR ictr := 1 TO cLen DO BEGIN
            IF ictr = cLen THEN
                StrList := DELSTR(StrList, cLen, 1);

            strcopy := COPYSTR(StrList, ictr, 1);
            NewString := NewString + strcopy;
            IF strcopy = StrSearch THEN BEGIN
                slashctr := slashctr + 1;
                LenNewStr := STRLEN(NewString);
            END ELSE
                slashctr := 0;

        END;
        NewString := '';
        EXIT(LenNewStr)
    end;

    internal procedure AT(strSearch: Text[10]; strList: Text[100]; nOccurence: Integer): Integer
    var
        clen: Integer;
        strcopy: Text[100];
        NewString: Text[30];
        slashctr: Integer;
        lennewstr1: integer;
        lennewstr2: Integer;
        lennewstr3: Integer;
    begin
        //AT
        CLEAR(clen);
        clen := STRLEN(strList);
        FOR ictr := 1 TO clen DO BEGIN
            strcopy := COPYSTR(strList, ictr, 1);
            NewString := NewString + strcopy;
            IF strcopy = strSearch THEN
                slashctr := slashctr + 1;

            CASE slashctr OF
                1:
                    BEGIN
                        lennewstr1 := STRLEN(NewString);
                        IF nOccurence = 1 THEN
                            EXIT(lennewstr1);
                    END;
                2:
                    BEGIN
                        lennewstr2 := STRLEN(NewString);
                        IF nOccurence = 2 THEN
                            EXIT(lennewstr2);
                    END;
                3:
                    BEGIN
                        lennewstr3 := STRLEN(NewString);
                        IF nOccurence = 3 THEN
                            EXIT(lennewstr3);
                    END;
            END;
        END;
        NewString := '';
    end;
    ///////////Ending---/String Library internal procedure----------------------------    
}