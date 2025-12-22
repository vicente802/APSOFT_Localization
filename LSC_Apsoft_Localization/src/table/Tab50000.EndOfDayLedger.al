table 50000 "End Of Day Ledger"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(3; "Store No."; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(4; "POS Terminal No."; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(5; "Staff ID"; Code[50])
        {
            DataClassification = CustomerContent;
        }
        field(6; "Gross Sales Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(7; "Line Discount Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(8; "Total Discount Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(9; Rounding; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(10; "Total Net Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(11; "Total Return Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(12; "Total Voided Transaction"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(13; "Total Voided Line Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(14; "Total VAT Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(15; "Vatable Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(16; "Non Vatable Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(17; "Service Charge"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(18; "Senior Citizen Discount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(19; "No. of Senior Citizen"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(20; "PWD Discount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(21; "No. of PWD Trans."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(22; "Solo Parent Discount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(23; "No. of Solo Parent Trans."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(24; "Zero Rated Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(25; "No. of Zero Rated Trans."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(26; "WHT Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(27; "No. of WHT Transaction"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(28; "Cash Transaction Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(29; "No. of Cash Transaction"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(30; "MRS Transaction Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(31; "No. of MRS Transaction"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(32; "CCM Transaction Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(33; "No. of CCM Transaction"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(34; "BRS Transaction Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(35; "No. of BRS Transaction"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(36; "No. of Paying Customers"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(37; "No. of Transactions"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(38; "No. of Item Sold"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(39; "No. of Returns"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(40; "No. of Suspended"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(41; "No. of Voided Transaction"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(42; "No. of Training"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(43; "No. of Open Drawer"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(44; "No. of Logins"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(45; "No. of Voided Line"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(46; "Beginning Invoice No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(47; "Ending Invoice No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(48; "Old Accumulated Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(49; "New Accumulated Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50; "Z-Report ID"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(51; "GGC Transaction Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(52; "No. of GGC Transaction"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(53; "Deposit Transaction Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(54; "No. of Deposit Transaction"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(55; "SRC Transaction Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(56; "PWD Transaction Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(57; "SOLO Transaction Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(58; "Zero Rated Transaction Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(59; "WHT1 Transaction Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(60; "VAT Exempt Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(61; "Zero Rated Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(62; "VAT 12% Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(63; "Handling Fee"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(64; "Cash Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(65; "Check Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(66; "Bankard Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(67; "Gift Check Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(68; "Store Coupon Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(69; "Personal Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(70; "House Card Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(71; "SPO Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(72; "Miscellaneous Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(73; "Coupon/Discount Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(74; "MRS Creation Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(75; "CCM Creation Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(76; "BRS Creation Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(77; "MRS Redemption Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(78; "CCM Redemption Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(79; "BRS Redemption Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(80; "Deposit Redemption Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(81; "Total Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(82; "Remove Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(83; "Cash (Short/Over) Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(84; "No. of Cash Tender"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(85; "No. of Check Tender"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(86; "No. of Bankard Tender"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(87; "No. of Gift Check Tender"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(88; "No. of Store Coupon Tender"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(89; "No. of Personal Tender"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(90; "No. of House Card Tender"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(91; "No. of SPO Tender"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(92; "No. of Misc. Tender"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(93; "No. of DC Tender"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(94; "No. of MRS Creation Tender"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(95; "No. of CCM Creation Tender"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(96; "No. of BRS Creation Tender"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(97; "No. of MRS Redeemed Tender"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(98; "No. of CCM Redeemed Tender"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(99; "No. of BRS Redeemed Tender"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(100; "No. of Deposit Redeemed Tender"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(101; "No. of Remove Tender"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(102; "Processed By"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(103; "Date Processed"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(104; "Starting Time"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(105; "Ending Time"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(106; "Duration"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(107; "Discount Coupon Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(108; "VAT Withholding"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(109; "VAT WHT Trans. Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(110; "No. of VAT WHT Trans."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(111; "Adjusted Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(112; "WHT Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(113; "No. of WHT Tender"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(114; "VATW Tender Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(115; "No. of VATW Tender"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(116; "Last Receipt No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(117; "First Receipt No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(118; "No. of Printed Copy"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(119; "BOI Transaction Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(120; "No. of BOI Transaction"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(121; "Replication Counter"; Integer)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateReplicationCounter;
            end;
        }
        field(122; "Posted"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(123; "POS Voided Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(124; "POS Voided Qty"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(125; "Time"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(126; "Float Entry"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(127; "Remove Tender"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(128; "ShortOver"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(129; "NonVat Net Sales Src"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(130; "Delivery Charge"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(131; "Tender Declaration Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(132; "Beginning Ayala OR"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(134; "Ending Ayala OR"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(135; "Mall Old Accum. Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(136; "Mall Old Accum. Sales NV"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(137; "Date Printed"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(138; "Time Printed"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(139; "Bankard 1 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(140; "Bankard 1 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(141; "Bankard 1 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(142; "Bankard 2 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(143; "Bankard 2 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(144; "Bankard 2 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(145; "Bankard 3 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(146; "Bankard 3 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(147; "Bankard 3 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(148; "Bankard 4 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(149; "Bankard 4 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(150; "Bankard 4 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(151; "Bankard 5 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(152; "Bankard 5 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(153; "Bankard 5 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(154; "Bankard 6 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(155; "Bankard 6 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(156; "Bankard 6 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(157; "Bankard 7 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(158; "Bankard 7 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(159; "Bankard 7 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(160; "Bankard 8 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(161; "Bankard 8 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(162; "Bankard 8 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(163; "Bankard 9 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(164; "Bankard 9 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(165; "Bankard 9 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(166; "Bankard 10 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(167; "Bankard 10 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(168; "Bankard 10 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(169; "Bankard 11 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(170; "Bankard 11 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(171; "Bankard 11 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(172; "Bankard 12 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(173; "Bankard 12 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(174; "Bankard 12 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(175; "Bankard 13 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(176; "Bankard 13 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(177; "Bankard 13 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(178; "Bankard 14 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(179; "Bankard 14 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(180; "Bankard 14 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(181; "Bankard 15 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(182; "Bankard 15 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(183; "Bankard 15 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(184; "Bankard 16 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(185; "Bankard 16 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(186; "Bankard 16 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(187; "Bankard 17 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(188; "Bankard 17 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(189; "Bankard 17 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(190; "Bankard 18 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(191; "Bankard 18 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(192; "Bankard 18 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(193; "Bankard 19 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(194; "Bankard 19 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(195; "Bankard 19 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(196; "Bankard 20 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(197; "Bankard 20 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(198; "Bankard 20 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(199; "Bankard 21 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(200; "Bankard 21 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(201; "Bankard 21 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(202; "Bankard 23 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(203; "Bankard 23 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(204; "Bankard 23 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(205; "Bankard 24 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(206; "Bankard 24 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(207; "Bankard 24 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(208; "Bankard 25 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(209; "Bankard 25 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(210; "Bankard 25 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(211; "Bankard 26 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(212; "Bankard 26 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(213; "Bankard 26 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(214; "Bankard 27 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(215; "Bankard 27 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(216; "Bankard 27 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(217; "Bankard 28 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(218; "Bankard 28 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(219; "Bankard 28 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(220; "Bankard 29 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(221; "Bankard 29 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(222; "Bankard 29 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(223; "Bankard 30 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(224; "Bankard 30 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(225; "Bankard 30 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(226; "Bankard 31 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(227; "Bankard 31 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(228; "Bankard 31 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(229; "Bankard 32 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(230; "Bankard 32 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(231; "Bankard 32 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(232; "Bankard 33 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(234; "Bankard 33 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(235; "Bankard 33 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(236; "Bankard 34 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(237; "Bankard 34 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(238; "Bankard 34 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(239; "Bankard 35 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(240; "Bankard 35 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(241; "Bankard 35 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(242; "Bankard 36 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(243; "Bankard 36 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(244; "Bankard 36 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(245; "Bankard 37 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(246; "Bankard 37 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(247; "Bankard 37 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(248; "Bankard 38 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(249; "Bankard 38 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(250; "Bankard 38 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(251; "Bankard 39 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(252; "Bankard 39 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(253; "Bankard 39 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(254; "Bankard 40 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(255; "Bankard 40 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(256; "Bankard 40 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(257; "Bankard 22 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(258; "Bankard 22 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(259; "Bankard 22 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(260; "Card 1 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(261; "Card 1 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(262; "Card 1 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(263; "Card 2 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(264; "Card 2 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(265; "Card 2 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(266; "Card 3 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(267; "Card 3 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(268; "Card 3 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(269; "Card 4 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(270; "Card 4 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(271; "Card 4 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(272; "Card 5 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(273; "Card 5 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(274; "Card 5 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(275; "Card 6 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(276; "Card 6 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(277; "Card 6 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(278; "Card 7 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(279; "Card 7 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(280; "Card 7 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(281; "Card 8 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(282; "Card 8 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(283; "Card 8 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(284; "Card 9 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(285; "Card 9 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(286; "Card 9 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(287; "Card 10 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(288; "Card 10 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(289; "Card 10 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(290; "Card 11 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(291; "Card 11 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(292; "Card 11 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(293; "Card 12 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(294; "Card 12 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(295; "Card 12 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(296; "Card 13 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(297; "Card 13 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(298; "Card 13 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(299; "Card 14 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(300; "Card 14 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(301; "Card 14 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(302; "Card 15 Description"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(303; "Card 15 Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(304; "Card 15 Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(305; "Athl Discount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(306; "No. of Athl Trans."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(307; "Athlete Transaction Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(308; "Athlete Discount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(309; "Total Refund Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin
        Rec."Entry No." := GetNextEntryNo();
        UpdateReplicationCounter;
    end;

    trigger OnModify()
    begin
        UpdateReplicationCounter;
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin
        UpdateReplicationCounter;
    end;

    local procedure GetNextEntryNo(): Integer
    var
        recEndOfDayLedger: Record "End Of Day Ledger";
    begin
        recEndOfDayLedger.RESET;
        IF recEndOfDayLedger.FINDLAST THEN
            EXIT(recEndOfDayLedger."Entry No." + 1)
        ELSE
            EXIT(1);
    end;

    local procedure UpdateReplicationCounter()
    var
        recLEODLdgEntry: Record "End Of Day Ledger";
    begin
        recLEODLdgEntry.RESET;
        recLEODLdgEntry.SETCURRENTKEY("Replication Counter");
        IF recLEODLdgEntry.FINDLAST THEN
            Rec."Replication Counter" := recLEODLdgEntry."Replication Counter" + 1
        ELSE
            Rec."Replication Counter" := 1;
    end;

}