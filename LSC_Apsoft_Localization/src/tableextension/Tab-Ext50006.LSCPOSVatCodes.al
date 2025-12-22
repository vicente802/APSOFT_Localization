tableextension 50006 "LSCPOSVatCodes" extends "LSC POS VAT Code"
{
    fields
    {
        field(50001; "VAT Bus. Posting Group"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(50002; "POS Command"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "LSC POS Command";
            trigger OnValidate()
            var
                POSVATCode: Record "LSC POS VAT Code";
                VATPostingSetup: Record "VAT Posting Setup";
                Text001: Label 'POS Command %1 is already used by VAT Code %2.';
            begin
                IF ("POS Command" <> '') THEN BEGIN
                    POSVATCode.SETFILTER("POS Command", '=%1', "POS Command");
                    IF POSVATCode.FindFirst() THEN BEGIN
                        ERROR(Text001, "POS Command", POSVATCode."VAT Code")
                    END;
                END;
            end;
        }
    }

    var
        myInt: Integer;
}