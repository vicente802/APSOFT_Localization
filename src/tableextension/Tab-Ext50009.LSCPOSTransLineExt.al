tableextension 50009 "LSCPOSTransLineExt" extends "LSC POS Trans. Line"
{
    fields
    {
        field(50001; "Value[1]"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(50002; "Value[2]"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(50003; "Value[3]"; Text[2])
        {
            DataClassification = CustomerContent;
        }
        field(50004; "Value[4]"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(50005; "Return Slip No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(50006; "Local VAT Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(50007; "Discount Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ",SRC,ZERO,PWD,SOLO,WHT1,VATW,ATHL,ZRWH,MOV,NAAC;
        }
        field(50008; "Orig. Total Disc. %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50009; "Item Disc. % Orig."; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50010; "Item Disc. % Actual"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50011; "Item Disc. Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ",SRC,PWD;
        }
        field(50012; "VAT Adj."; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50013; "Zero Rated Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50014; "Original Price Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 2;
        }
        field(50015; "Discount identifier"; Code[1])
        {
            DataClassification = CustomerContent;
            TableRelation = "LSC POS Trans. Line".Price WHERE("Line No." = FIELD("Line No."), "Receipt No." = FIELD("Receipt No."));
        }
        field(50016; "Card Approval Code"; code[20])
        {
            DataClassification = CustomerContent;
        }
        field(50017; "Current Balance"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50018; "Card Holder Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
    }
    trigger OnAfterInsert()

    begin
        Rec."Original Price Amount" := Rec.Price;
    end;

    trigger OnAfterModify()
    begin
        Rec."Original Price Amount" := Rec.Price;
    end;

    var
        MyPosPrice: Codeunit LSCPOSPriceUtilityExt;

    procedure GetNextLineNo2(): Integer
    var
        recLPOSTransLine: Record "LSC POS Trans. Line";
    begin
        recLPOSTransLine.Reset();
        recLPOSTransLine.SetRange("Receipt No.", Rec."Receipt No.");
        if recLPOSTransLine.FindLast() then begin
            exit(recLPOSTransLine."Line No." + 10000);
        end else begin
            exit(10000);
        end;
    end;

    procedure NewCalcTotalDiscAmt(PosFunction: Boolean; DiscAmount: Decimal; pPaymentState: Boolean): Boolean
    begin
        exit(MyPosPrice.CalcTotalDiscAmt(Rec, PosFunction, DiscAmount, pPaymentState));
    end;
}