tableextension 50005 "LSCPOSFunctionalityProfile" extends "LSC POS Func. Profile"
{
    fields
    {
        field(50001; "WHT/BOI Must Be Register"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        // field(50002; "WHT1 Discount %"; Decimal)
        // {
        //     DataClassification = CustomerContent;
        // }
        field(50003; "Additional Item on VAT WHT"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(50004; "VAT Withholding Tax Disc. %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50005; "Withholding Tax Disc. %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50006; "VAT WHT Must Be Register"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(50007; "Beginning Balance % Trigger"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50008; "Athelete Disc. %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50009; "Beg Bal Allowance"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        /*
        field(50007; "SRC Retail Disc. %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50008; "PWD Retail Disc. %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50009; "SRC Hosp. Disc. %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50010; "PWD Hosp. Disc. %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50011; "SOLO Disc. %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50012; "Athlete Retail Disc. %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50013; "Athlete Hosp. Disc. %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        */


    }

    var
        myInt: Integer;
}