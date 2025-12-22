tableextension 50014 "Income/ExpenseAccountExt" extends "LSC Income/Expense Account"
{
    fields
    {
        field(50001; "Service Charge %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
    }
}