tableextension 50010 "CustomerExt" extends customer
{
    fields
    {
        field(50001; TIN; Code[50])
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if StrLen(Rec.TIN) > 20 then
                    Error('TIN/ID must be lessthan 20 characters');
            end;
        }
        field(50002; Company; Code[50])
        {
            DataClassification = CustomerContent;
        }
        field(50003; "Business Style"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(50004; "Customer Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ","REGULAR","SRC","PWD","SOLO PARENT","ATHLETE","ZERO RATED","WITHHOLDING TAX","VATW","ZRWHT","NAAC","MOV","ONLINE CUSTOMER";
            trigger OnValidate()
            begin
                Rec."Text Type" := Format(Rec."Customer Type");
            end;
        }
        field(50005; Active; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(50006; "Text Type"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(50007; "Birthdate of Child"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(50008; "Name of Child"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(50009; "VEC Expiry Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(50010; "Reference ID"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(50011; "Reference ID Expiry Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(50012; "Beg Bal_"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum(DiscountEligibilityLedger.Amount WHERE("Customer No." = field("No.")));
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
        field(51001; "Retail Price Group"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Customer Price Group".Code;
        }
    }

    keys
    {
        key(NPK1; "Customer Type")
        { }
    }

    var
        myInt: Integer;
}