tableextension 50007 "ItemExt" extends Item
{
    fields
    {
        field(50001; "Discount %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50002; "Enable Vat Exempt"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(50003; "Food Item"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(50004; "SRC Discount %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50005; "PWD Discount %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50016; "SOLO Discount %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50007; "Athlete Discount %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50008; "Unit Price Incl. VAT"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price Including VAT';
            Description = 'LS';
            Editable = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                VATPostingSetupRec: Record "VAT Posting Setup";
                GeneralLedgerSetup: Record "General Ledger Setup";
                PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
                Text99001507: Label '%1 cannot be calculated when %2 is %3.';
            begin
                if PriceCalculationMgt.IsExtendedPriceCalculationEnabled() then
                    exit;
                if not "Price Includes VAT" then begin
                    if not VATPostingSetupRec.Get("VAT Bus. Posting Gr. (Price)", "VAT Prod. Posting Group") then
                        VATPostingSetupRec.Init;
                    case VATPostingSetupRec."VAT Calculation Type" of
                        VATPostingSetupRec."VAT Calculation Type"::"Reverse Charge VAT":
                            VATPostingSetupRec."VAT %" := 0;
                        VATPostingSetupRec."VAT Calculation Type"::"Sales Tax":
                            Error(
                              Text99001507,
                              FieldCaption("Unit Price Incl. VAT"),
                              VATPostingSetupRec.FieldCaption("VAT Calculation Type"),
                              VATPostingSetupRec."VAT Calculation Type");
                    end;
                    if not GeneralLedgerSetup.Get then
                        Clear(GeneralLedgerSetup);
                    "Unit Price" := Round("Unit Price Incl. VAT" / (1 + (VATPostingSetupRec."VAT %" / 100)), GeneralLedgerSetup."Unit-Amount Rounding Precision");
                end else
                    "Unit Price" := "Unit Price Incl. VAT";

                Validate("Price/Profit Calculation");
            end;
#pragma warning restore AL0432
        }
        field(50009; "NAAC Discount %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50010; "MOV Discount %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
    }
    var
        myInt: Integer;
}