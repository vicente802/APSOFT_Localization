table 50009 "Cashier Reading Ledger Entry"
{
    Caption = 'Cashier Reading Ledger Entry';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; }
        field(2; "Date"; Date) { Caption = 'Date'; }
        field(3; "Store No."; Code[10]) { Caption = 'Store No.'; }
        field(4; "POS Terminal No."; Code[10]) { Caption = 'POS Terminal No.'; }
        field(5; "Staff ID"; Code[50]) { Caption = 'Staff ID'; }
        field(20; "Gross Sales Amount"; Decimal) { Caption = 'Gross Sales Amount'; }
        field(21; "Line Discount Amount"; Decimal) { Caption = 'Line Discount Amount'; }
        field(22; "Total Discount Amount"; Decimal) { Caption = 'Total Discount Amount'; }
        field(23; "Rounding"; Decimal) { Caption = 'Rounding'; }
        field(24; "Total Net Sales"; Decimal) { Caption = 'Total Net Sales'; }
        field(25; "Total Return Amount"; Decimal) { Caption = 'Total Return Amount'; }
        field(26; "Total Voided Transaction"; Decimal) { Caption = 'Total Voided Transaction'; }
        field(27; "Total Voided Line Amount"; Decimal) { Caption = 'Total Voided Line Amount'; }
        field(28; "Total VAT Amount"; Decimal) { Caption = 'Total VAT Amount'; }
        field(29; "Vatable Sales"; Decimal) { Caption = 'Vatable Sales'; }
        field(30; "Non Vatable Sales"; Decimal) { Caption = 'Non Vatable Sales'; }
        field(31; "Service Charge"; Decimal) { Caption = 'Service Charge'; }
        field(32; "Senior Citizen Discount"; Decimal) { Caption = 'Senior Citizen Discount'; }
        field(33; "No. of Senior Citizen"; Integer) { Caption = 'No. of Senior Citizen'; }
        field(34; "PWD Discount"; Decimal) { Caption = 'PWD Discount'; }
        field(35; "No. of PWD Trans."; Integer) { Caption = 'No. of PWD Trans.'; }
        field(36; "Solo Parent Discount"; Decimal) { Caption = 'Solo Parent Discount'; }
        field(37; "No. of Solo Parent Trans."; Integer) { Caption = 'No. of Solo Parent Trans.'; }
        field(38; "Zero Rated Amount"; Decimal) { Caption = 'Zero Rated Amount'; }
        field(39; "No. of Zero Rated Trans."; Integer) { Caption = 'No. of Zero Rated Trans.'; }
        field(40; "WHT Amount"; Decimal) { Caption = 'WHT Amount'; }
        field(41; "No. of WHT Transaction"; Integer) { Caption = 'No. of WHT Transaction'; }
        field(42; "Cash Transaction Amount"; Decimal) { Caption = 'Cash Transaction Amount'; }
        field(43; "No. of Cash Transaction"; Integer) { Caption = 'No. of Cash Transaction'; }
        field(44; "MRS Transaction Amount"; Decimal) { Caption = 'MRS Transaction Amount'; }
        field(45; "No. of MRS Transaction"; Integer) { Caption = 'No. of MRS Transaction'; }
        field(46; "CCM Transaction Amount"; Decimal) { Caption = 'CCM Transaction Amount'; }
        field(47; "No. of CCM Transaction"; Integer) { Caption = 'No. of CCM Transaction'; }
        field(48; "BRS Transaction Amount"; Decimal) { Caption = 'BRS Transaction Amount'; }
        field(49; "No. of BRS Transaction"; Integer) { Caption = 'No. of BRS Transaction'; }
        field(50; "No. of Paying Customers"; Integer) { Caption = 'No. of Paying Customers'; }
        field(51; "No. of Transactions"; Integer) { Caption = 'No. of Transactions'; }
        field(52; "No. of Item Sold"; Decimal) { Caption = 'No. of Item Sold'; }
        field(53; "No. of Returns"; Decimal) { Caption = 'No. of Returns'; }
        field(54; "No. of Suspended"; Decimal) { Caption = 'No. of Suspended'; }
        field(55; "No. of Voided Transaction"; Decimal) { Caption = 'No. of Voided Transaction'; }
        field(56; "No. of Training"; Integer) { Caption = 'No. of Training'; }
        field(57; "No. of Open Drawer"; Integer) { Caption = 'No. of Open Drawer'; }
        field(58; "No. of Logins"; Integer) { Caption = 'No. of Logins'; }
        field(59; "No. of Voided Line"; Decimal) { Caption = 'No. of Voided Line'; }
        field(63; "Beginning Invoice No."; Code[20]) { Caption = 'Beginning Invoice No.'; }
        field(64; "Ending Invoice No."; Code[20]) { Caption = 'Ending Invoice No.'; }
        field(67; "Old Accumulated Sales"; Decimal) { Caption = 'Old Accumulated Sales'; }
        field(68; "New Accumulated Sales"; Decimal) { Caption = 'New Accumulated Sales'; }
        field(70; "Z-Report ID"; Code[10]) { Caption = 'Z-Report ID'; }
        field(71; "GGC Transaction Amount"; Decimal) { Caption = 'GGC Transaction Amount'; }
        field(72; "No. of GGC Transaction"; Integer) { Caption = 'No. of GGC Transaction'; }
        field(73; "Deposit Transaction Amount"; Decimal) { Caption = 'Deposit Transaction Amount'; }
        field(74; "No. of Deposit Transaction"; Integer) { Caption = 'No. of Deposit Transaction'; }
        field(75; "SRC Transaction Sales"; Decimal) { Caption = 'SRC Transaction Sales'; }
        field(76; "PWD Transaction Sales"; Decimal) { Caption = 'PWD Transaction Sales'; }
        field(77; "SOLO Transaction Sales"; Decimal) { Caption = 'SOLO Transaction Sales'; }
        field(78; "Zero Rated Transaction Sales"; Decimal) { Caption = 'Zero Rated Transaction Sales'; }
        field(79; "WHT1 Transaction Sales"; Decimal) { Caption = 'WHT1 Transaction Sales'; }
        field(80; "VAT Exempt Sales"; Decimal) { Caption = 'VAT Exempt Sales'; }
        field(81; "Zero Rated Sales"; Decimal) { Caption = 'Zero Rated Sales'; }
        field(82; "VAT 12% Sales"; Decimal) { Caption = 'VAT 12% Sales'; }
        field(83; "Handling Fee"; Decimal) { Caption = 'Handling Fee'; }
        field(84; "Cash Tender Amount"; Decimal) { Caption = 'Cash Tender Amount'; }
        field(85; "Check Tender Amount"; Decimal) { Caption = 'Check Tender Amount'; }
        field(86; "Bankard Tender Amount"; Decimal) { Caption = 'Bankard Tender Amount'; }
        field(87; "Gift Check Tender Amount"; Decimal) { Caption = 'Gift Check Tender Amount'; }
        field(88; "Store Coupon Tender Amount"; Decimal) { Caption = 'Store Coupon Tender Amount'; }
        field(89; "Personal Tender Amount"; Decimal) { Caption = 'Personal Tender Amount'; }
        field(90; "House Card Tender Amount"; Decimal) { Caption = 'House Card Tender Amount'; }
        field(91; "SPO Tender Amount"; Decimal) { Caption = 'SPO Tender Amount'; }
        field(92; "Miscellaneous Tender Amount"; Decimal) { Caption = 'Miscellaneous Tender Amount'; }
        field(93; "Coupon/Discount Tender Amount"; Decimal) { Caption = 'Coupon/Discount Tender Amount'; }
        field(94; "MRS Creation Tender Amount"; Decimal) { Caption = 'MRS Creation Tender Amount'; }
        field(95; "CCM Creation Tender Amount"; Decimal) { Caption = 'CCM Creation Tender Amount'; }
        field(96; "BRS Creation Tender Amount"; Decimal) { Caption = 'BRS Creation Tender Amount'; }
        field(97; "MRS Redemption Amount"; Decimal) { Caption = 'MRS Redemption Amount'; }
        field(98; "CCM Redemption Amount"; Decimal) { Caption = 'CCM Redemption Amount'; }
        field(99; "BRS Redemption Amount"; Decimal) { Caption = 'BRS Redemption Amount'; }
        field(100; "Deposit Redemption Amount"; Decimal) { Caption = 'Deposit Redemption Amount'; }
        field(101; "Total Tender Amount"; Decimal) { Caption = 'Total Tender Amount'; }
        field(102; "Remove Tender Amount"; Decimal) { Caption = 'Remove Tender Amount'; }
        field(103; "Cash (Short/Over) Amount"; Decimal) { Caption = 'Cash (Short/Over) Amount'; }

        field(104; "No. of Cash Tender"; Integer) { Caption = 'No. of Cash Tender'; }
        field(105; "No. of Check Tender"; Integer) { Caption = 'No. of Check Tender'; }
        field(106; "No. of Bankard Tender"; Integer) { Caption = 'No. of Bankard Tender'; }
        field(107; "No. of Gift Check Tender"; Integer) { Caption = 'No. of Gift Check Tender'; }
        field(108; "No. of Store Coupon Tender"; Integer) { Caption = 'No. of Store Coupon Tender'; }
        field(109; "No. of Personal Tender"; Integer) { Caption = 'No. of Personal Tender'; }
        field(110; "No. of House Card Tender"; Integer) { Caption = 'No. of House Card Tender'; }
        field(111; "No. of SPO Tender"; Integer) { Caption = 'No. of SPO Tender'; }
        field(112; "No. of Misc. Tender"; Integer) { Caption = 'No. of Misc. Tender'; }
        field(113; "No. of DC Tender"; Integer) { Caption = 'No. of DC Tender'; }
        field(114; "No. of MRS Creation Tender"; Integer) { Caption = 'No. of MRS Creation Tender'; }
        field(115; "No. of CCM Creation Tender"; Integer) { Caption = 'No. of CCM Creation Tender'; }
        field(116; "No. of BRS Creation Tender"; Integer) { Caption = 'No. of BRS Creation Tender'; }
        field(117; "No. of MRS Redeemed Tender"; Integer) { Caption = 'No. of MRS Redeemed Tender'; }
        field(118; "No. of CCM Redeemed Tender"; Integer) { Caption = 'No. of CCM Redeemed Tender'; }
        field(119; "No. of BRS Redeemed Tender"; Integer) { Caption = 'No. of BRS Redeemed Tender'; }
        field(120; "No. of Deposit Redeemed Tender"; Integer) { Caption = 'No. of Deposit Redeemed Tender'; }
        field(121; "No. of Remove Tender"; Integer) { Caption = 'No. of Remove Tender'; }

        field(122; "Processed By"; Text[30]) { Caption = 'Processed By'; }
        field(123; "Date Processed"; Date) { Caption = 'Date Processed'; }
        field(124; "Starting Time"; Time) { Caption = 'Starting Time'; }
        field(125; "Ending Time"; Time) { Caption = 'Ending Time'; }
        field(126; "Duration"; Duration) { Caption = 'Duration'; }
        field(127; "Staff Name"; Text[60]) { Caption = 'Staff Name'; }
        field(128; "Discount Coupon Amount"; Decimal) { Caption = 'Discount Coupon Amount'; }

        // Bankard Description and Amounts
        field(135; "Bankard 1 Description"; Text[30]) { Caption = 'Bankard 1 Description'; }
        field(136; "Bankard 1 Amount"; Decimal) { Caption = 'Bankard 1 Amount'; }
        field(137; "Bankard 2 Description"; Text[30]) { Caption = 'Bankard 2 Description'; }
        field(138; "Bankard 2 Amount"; Decimal) { Caption = 'Bankard 2 Amount'; }
        field(139; "Bankard 3 Description"; Text[30]) { Caption = 'Bankard 3 Description'; }
        field(140; "Bankard 3 Amount"; Decimal) { Caption = 'Bankard 3 Amount'; }
        field(141; "Bankard 4 Description"; Text[30]) { Caption = 'Bankard 4 Description'; }
        field(142; "Bankard 4 Amount"; Decimal) { Caption = 'Bankard 4 Amount'; }
        field(143; "Bankard 5 Description"; Text[30]) { Caption = 'Bankard 5 Description'; }
        field(144; "Bankard 5 Amount"; Decimal) { Caption = 'Bankard 5 Amount'; }
        field(145; "Bankard 6 Description"; Text[30]) { Caption = 'Bankard 6 Description'; }
        field(146; "Bankard 6 Amount"; Decimal) { Caption = 'Bankard 6 Amount'; }
        field(147; "Bankard 7 Description"; Text[30]) { Caption = 'Bankard 7 Description'; }
        field(148; "Bankard 7 Amount"; Decimal) { Caption = 'Bankard 7 Amount'; }
        field(149; "Bankard 8 Description"; Text[30]) { Caption = 'Bankard 8 Description'; }
        field(150; "Bankard 8 Amount"; Decimal) { Caption = 'Bankard 8 Amount'; }
        field(151; "Bankard 9 Description"; Text[30]) { Caption = 'Bankard 9 Description'; }
        field(152; "Bankard 9 Amount"; Decimal) { Caption = 'Bankard 9 Amount'; }
        field(153; "Bankard 10 Description"; Text[30]) { Caption = 'Bankard 10 Description'; }
        field(154; "Bankard 10 Amount"; Decimal) { Caption = 'Bankard 10 Amount'; }
        field(155; "Bankard 11 Description"; Text[30]) { Caption = 'Bankard 11 Description'; }
        field(156; "Bankard 11 Amount"; Decimal) { Caption = 'Bankard 11 Amount'; }
        field(157; "Bankard 12 Description"; Text[30]) { Caption = 'Bankard 12 Description'; }
        field(158; "Bankard 12 Amount"; Decimal) { Caption = 'Bankard 12 Amount'; }
        field(159; "Bankard 13 Description"; Text[30]) { Caption = 'Bankard 13 Description'; }
        field(160; "Bankard 13 Amount"; Decimal) { Caption = 'Bankard 13 Amount'; }
        field(161; "Bankard 14 Description"; Text[30]) { Caption = 'Bankard 14 Description'; }
        field(162; "Bankard 14 Amount"; Decimal) { Caption = 'Bankard 14 Amount'; }
        field(163; "Bankard 15 Description"; Text[30]) { Caption = 'Bankard 15 Description'; }
        field(164; "Bankard 15 Amount"; Decimal) { Caption = 'Bankard 15 Amount'; }
        field(165; "Bankard 16 Description"; Text[30]) { Caption = 'Bankard 16 Description'; }
        field(166; "Bankard 16 Amount"; Decimal) { Caption = 'Bankard 16 Amount'; }
        field(167; "Bankard 17 Description"; Text[30]) { Caption = 'Bankard 17 Description'; }
        field(168; "Bankard 17 Amount"; Decimal) { Caption = 'Bankard 17 Amount'; }
        field(169; "Bankard 18 Description"; Text[30]) { Caption = 'Bankard 18 Description'; }
        field(170; "Bankard 18 Amount"; Decimal) { Caption = 'Bankard 18 Amount'; }
        field(171; "Bankard 19 Description"; Text[30]) { Caption = 'Bankard 19 Description'; }
        field(172; "Bankard 19 Amount"; Decimal) { Caption = 'Bankard 19 Amount'; }
        field(173; "Bankard 20 Description"; Text[30]) { Caption = 'Bankard 20 Description'; }
        field(174; "Bankard 20 Amount"; Decimal) { Caption = 'Bankard 20 Amount'; }
        field(175; "Bankard 21 Description"; Text[30]) { Caption = 'Bankard 21 Description'; }
        field(176; "Bankard 21 Amount"; Decimal) { Caption = 'Bankard 21 Amount'; }
        field(177; "Bankard 22 Description"; Text[30]) { Caption = 'Bankard 22 Description'; }
        field(178; "Bankard 22 Amount"; Decimal) { Caption = 'Bankard 22 Amount'; }
        field(179; "Bankard 23 Description"; Text[30]) { Caption = 'Bankard 23 Description'; }
        field(180; "Bankard 23 Amount"; Decimal) { Caption = 'Bankard 23 Amount'; }

        // Bankard Counts
        field(181; "Bankard 1 Count"; Integer) { Caption = 'Bankard 1 Count'; }
        field(182; "Bankard 2 Count"; Integer) { Caption = 'Bankard 2 Count'; }
        field(183; "Bankard 3 Count"; Integer) { Caption = 'Bankard 3 Count'; }
        field(184; "Bankard 4 Count"; Integer) { Caption = 'Bankard 4 Count'; }
        field(185; "Bankard 5 Count"; Integer) { Caption = 'Bankard 5 Count'; }
        field(186; "Bankard 6 Count"; Integer) { Caption = 'Bankard 6 Count'; }
        field(187; "Bankard 7 Count"; Integer) { Caption = 'Bankard 7 Count'; }
        field(188; "Bankard 8 Count"; Integer) { Caption = 'Bankard 8 Count'; }
        field(189; "Bankard 9 Count"; Integer) { Caption = 'Bankard 9 Count'; }
        field(190; "Bankard 10 Count"; Integer) { Caption = 'Bankard 10 Count'; }
        field(191; "Bankard 11 Count"; Integer) { Caption = 'Bankard 11 Count'; }
        field(192; "Bankard 12 Count"; Integer) { Caption = 'Bankard 12 Count'; }
        field(193; "Bankard 13 Count"; Integer) { Caption = 'Bankard 13 Count'; }
        field(194; "Bankard 14 Count"; Integer) { Caption = 'Bankard 14 Count'; }
        field(195; "Bankard 15 Count"; Integer) { Caption = 'Bankard 15 Count'; }
        field(196; "Bankard 16 Count"; Integer) { Caption = 'Bankard 16 Count'; }
        field(197; "Bankard 17 Count"; Integer) { Caption = 'Bankard 17 Count'; }
        field(198; "Bankard 18 Count"; Integer) { Caption = 'Bankard 18 Count'; }
        field(199; "Bankard 19 Count"; Integer) { Caption = 'Bankard 19 Count'; }
        field(200; "Bankard 20 Count"; Integer) { Caption = 'Bankard 20 Count'; }
        field(201; "Bankard 21 Count"; Integer) { Caption = 'Bankard 21 Count'; }
        field(202; "Bankard 22 Count"; Integer) { Caption = 'Bankard 22 Count'; }
        field(203; "Bankard 23 Count"; Integer) { Caption = 'Bankard 23 Count'; }

        field(204; "VAT Withholding"; Decimal) { Caption = 'VAT Withholding'; }
        field(205; "VAT WHT Trans. Amount"; Decimal) { Caption = 'VAT WHT Trans. Amount'; }
        field(206; "No. of VAT WHT Trans."; Integer) { Caption = 'No. of VAT WHT Trans.'; }
        field(207; "Adjusted Sales"; Decimal) { Caption = 'Adjusted Sales'; }
        field(208; "DC% Coupon Amount"; Decimal) { Caption = 'DC% Coupon Amount'; }
        field(209; "WHT Tender Amount"; Decimal) { Caption = 'WHT Tender Amount'; }
        field(210; "No. of WHT Tender"; Integer) { Caption = 'No. of WHT Tender'; }
        field(211; "VATW Tender Amount"; Decimal) { Caption = 'VATW Tender Amount'; }
        field(212; "No. of VATW Tender"; Integer) { Caption = 'No. of VATW Tender'; }
        field(213; "No. of Printed Copy"; Integer) { Caption = 'No. of Printed Copy'; }
        field(214; "BOI Transaction Amount"; Decimal) { Caption = 'BOI Transaction Amount'; }
        field(215; "No. of BOI Transaction"; Integer) { Caption = 'No. of BOI Transaction'; }
        field(216; "Replication Counter"; Integer) { Caption = 'Replication Counter'; }
        field(217; "POS Voided Amount"; Decimal) { Caption = 'POS Voided Amount'; }
        field(218; "POS Voided Qty"; Integer) { Caption = 'POS Voided Qty'; }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
