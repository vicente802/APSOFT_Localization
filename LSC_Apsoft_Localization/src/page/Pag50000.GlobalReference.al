page 50000 "Global Reference"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Global References";

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry Type"; Rec."Entry Type")
                {
                    Caption = 'Entry Type';
                    ApplicationArea = All;
                }

                field(Code; Rec.Code)
                {
                    Caption = 'Code';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    Caption = 'Description';
                    ApplicationArea = All;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    Caption = 'Trasaction Type';
                    ApplicationArea = all;
                }
                field("Discount Type"; Rec."Discount Type")
                {
                    Caption = 'Discount Type';
                    ApplicationArea = all;
                }
                field("Tender Type Card Setup"; Rec."Tender Type Card Setup")
                {
                    ApplicationArea = all;
                }
                field("Include in Store Sales"; Rec."Include in Store Sales")
                {
                    Caption = 'Include in Store Sales';
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

}