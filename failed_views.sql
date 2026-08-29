

-- ERROR IN: vwDailySells
CREATE VIEW vwDailySells AS 
SELECT guid , billdated, mat, SUM(Qty) As Qty , CAST(SUM(TotalSellPrice) as float) as TotalSellPrice ,   CAST(SUM(TotalProfitsOut) as float) as TotalProfits  FROM vwDailySellsRaw
GROUP BY guid , billdated , mat
-- MSG: There is already an object named 'vwDailySells' in the database.

-- ERROR IN: vwBarCodeRpt
CREATE VIEW vwBarCodeRpt AS 
SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , tbMat.SellPrice , CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END  as CurrentQty,  tbMat.BarCode , 0 as Qty FROM tbMat
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRpt' in the database.

-- ERROR IN: vwBillProfitsRAW
CREATE VIEW vwBillProfitsRAW AS 
SELECT Guid as Guid , number, billtype, BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name ,0 as SellCost,   vwBillsProfitsRawBuy.Amount / vwBillsProfitsRawBuy.Qty  as BuyCost , 0 as TotalSellQty , vwBillsProfitsRawBuy.Qty  as TotalBuyQty  , 0 as TotalSell ,  vwBillsProfitsRawBuy.Amount  as TotalBuy  ,  0 as TotalSellCost, SellCost as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell,  0 as  NetBuy , Percentt  as BuyPrecent , 0 as SellPrecent FROM vwBillsProfitsRawBuy 
UNION ALL
SELECT Guid as Guid ,  number,   billtype,BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name , vwBillsProfitsRawSell.Amount  /  vwBillsProfitsRawSell.Qty  as SellCost , 0 as BuyCost ,  vwBillsProfitsRawSell.Qty  as TotalSellQty , 0 as TotalBuyQty , vwBillsProfitsRawSell.Amount  as TotalSell  , 0 as TotalBuy,  SellCost as TotalSellCost, 0 as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell , 0 as NetBuy ,   0 as BuyPrecent ,  Percentt  as SellPrecent FROM vwBillsProfitsRawSell
-- MSG: There is already an object named 'vwBillProfitsRAW' in the database.

-- ERROR IN: vwBillProfitsBills
CREATE VIEW vwBillProfitsBills AS 
SELECT guid, number, billtype , billdate, billdated , SUM(TotalSellCost) as TotalSellCost, SUM(TotalBuyCost) as TotalBuyCost  , SUM(TotalProfits) as TotalProfits from vwBillProfitsBillsRaw
GROUP BY  guid, number, billtype
-- MSG: Invalid object name 'vwBillProfitsBillsRaw'.

-- ERROR IN: vwBillProfitsBillsRaw
CREATE VIEW vwBillProfitsBillsRaw AS 
SELECT    vwBillProfitsRAW.guid ,vwBillProfitsRAW.Number, vwBillProfitsRAW.billType,  billdate , billdated , matguid , tbMat.code, tbMat.name ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost ,  TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) as  TotalBuyCost ,    TotalSellCost -  (TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) )  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = matguid   WHERE billtype ='مبيعات'
GROUP BY vwBillProfitsRAW.guid  ,vwBillProfitsRAW.Number  ,vwBillProfitsRAW.billType, matguid
-- MSG: Column 'vwBillProfitsRAW.BillDate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
Invalid object name 'vwBillProfits'.

-- ERROR IN: vwMatEndDateRaw
CREATE VIEW vwMatEndDateRaw AS 
SELECT tbMat.guid,tbBillHeader.guid as billguid, tbMat.code || '-' || tbMat.Name as mat, SUM(tbBillBody.Qty) as qty , tbBillBody.EndDate FROM tbBillHeader JOIN tbBillBody 
ON tbBillHeader.guid = tbBillBody.ParentGuid 
JOIN tbMat ON tbBillBody.matguid = tbMat.guid 
JOIN vwMatQty ON tbMat.guid = vwMatQty.guid
WHERE (tbBillheader.billtype = 0 OR tbBillheader.billtype = 3) AND vwMatQty.Qty > 0
AND tbBillBody.endDate > ('1913-01-02 00:00:00')
GROUP BY tbMat.guid, tbmat.code, tbBillHeader.guid, tbmat.name, tbBillBody.EndDate
-- MSG: Invalid column name 'endDate'.
Invalid column name 'EndDate'.
Invalid column name 'EndDate'.

-- ERROR IN: vwMatEndDate
CREATE VIEW vwMatEndDate AS 
SELECT Guid,billguid, Mat,SUM(Qty) as Qty ,vwMatEndDateRaw.endDate, Round(julianday(enddate) - julianday('now')) as days, '' as Status FROM vwMatEndDateRaw
GROUP BY guid, Mat,Qty , vwMatEndDateRaw.EndDate,Days 
ORDER BY  guid, billguid, enddate ASC
-- MSG: The round function requires 2 to 3 arguments.

-- ERROR IN: vwAccountsBalance
CREATE VIEW vwAccountsBalance AS 
SELECT guid ,name, acctype , billdated , CAST(SUM(Payin) as FLOAT) as PayIn ,  CAST(SUM(payOut) as FLOAT) as payout, CAST(CAST(SUM(Payin) AS FLOAT) - CAST(SUM(PayOut) as FLOAT) as FLOAT) as balance FROM vwAccountsBalanceRaw
GROUP BY guid,  acctype , name
-- MSG: Column 'vwAccountsBalanceRaw.BillDateD' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwPay
CREATE VIEW vwPay AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate ,tbpay.paydated ,  CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code || '-' || tbaccount.name as account, CASE tbPay.paytype WHEN 0 THEN amount WHEN 1 THEN 0 END as amountin, CASE tbPay.paytype WHEN 0 THEN 0 WHEN 1 THEN amount END as amountout ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE tbpay.PayType = 1 OR tbPay.PayType = 0
ORDER by paydate, number
-- MSG: There is already an object named 'vwPay' in the database.

-- ERROR IN: vwPayPrint
CREATE VIEW vwPayPrint AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate , CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code , tbaccount.name as account, amount ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE paytype = 0 OR PayType = 1
-- MSG: There is already an object named 'vwPayPrint' in the database.

-- ERROR IN: vwBillsDelay
CREATE VIEW vwBillsDelay AS 
SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillheader.BillDate  ,tbBillheader.BillDated  , tbAccount.code|| '-' ||  tbAccount.name  as account,tbaccount.Mobile , tbAccount.Email ,    tbBillHeader.Paytype  as paytype  , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra 
, tbBillheader.discount FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid  WHERE IsDelay = 1
ORDER BY tbBillheader.NUMBER , billdate
-- MSG: There is already an object named 'vwBillsDelay' in the database.

-- ERROR IN: vwService
CREATE VIEW vwService AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwService' in the database.

-- ERROR IN: vwNotify
CREATE VIEW vwNotify AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwNotify' in the database.

-- ERROR IN: vwCash
CREATE VIEW vwCash AS 
SELECT  guid , billtype, billdated , SUM(amountin) as amountin, SUM(amountout) as amountout    FROM vwcashRaw
-- MSG: Column 'vwcashRaw.guid' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatInCash
CREATE VIEW vwMatInCash AS 
SELECT tbMat.Guid,tbMat.GroupName,tbMat.code,tbMat.name,tbMat.BuyPrice,tbMat.SellPrice, tbMat.DiscountVal ,tbMat.DiscountPercent ,   tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent,tbMat.Barcode,tbMat.MinQty,tbMat.MinPrice,tbMat.CurrentQty, tbMat.ShowInCash , tbPicture.Pic FROM tbMat JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid    
WHERE ShowInCash = 1
-- MSG: There is already an object named 'vwMatInCash' in the database.

-- ERROR IN: vwMat
CREATE VIEW vwMat AS  
SELECT tbMat.Guid , tbMat.GroupName , tbMat.Code , tbMat.Name ,tbMat.BuyPrice , tbMat.SellPrice ,tbMat.DiscountVal ,tbMat.DiscountPercent , tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent , tbMat.Barcode , tbMat.MinQty , tbMat.MinPrice , CASE WHEN vwMatQty.qty IS NULL THEN 0 ELSE  vwMatQty.qty END as CurrentQty , tbMat.EndDate , tbMat.ShowInCash FROM tbMat 
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwMat' in the database.

-- ERROR IN: vwMaintenaceBody
CREATE VIEW vwMaintenaceBody AS 
SELECT tbMaintenaceBody.guid, tbMaintenaceBody.matguid, tbMaintenaceBody.parentguid, tbMaintenaceBody.number, tbmat.code || '-' || tbMat.name as mat, tbMaintenaceBody.[qty] , tbMaintenaceBody.[price] , (tbMaintenaceBody.[qty] * tbMaintenaceBody.[price]) as total , tbMaintenaceBody.note   
FROM tbMaintenaceBody JOIN tbMaintenance ON tbMaintenaceBody.parentguid = tbMaintenance.guid 
JOIN tbmat on tbMaintenaceBody.matguid = tbMat.guid ORDER BY tbMaintenaceBody.number
-- MSG: There is already an object named 'vwMaintenaceBody' in the database.

-- ERROR IN: vwAccoutnSelect
CREATE VIEW vwAccoutnSelect AS 
SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note,  CAST( CASE WHEN (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) IS NULL THEN 0 ELSE (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) END as FLOAT) as balance FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelect' in the database.

-- ERROR IN: vwAccountsBalanceRaw
CREATE VIEW vwAccountsBalanceRaw AS 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbBillHeader.BillDateD, 0 as payin,  CAST(tbBillHeader.totalnet as FLOAT) as payout FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2) 
UNION ALL 
SELECT tbAccount.guid, tbaccount.name,  tbAccount.AccType , tbBillHeader.BillDateD, CAST(tbBillHeader.totalnet as FLOAT) as payin, 0 as payout  FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3) 
UNION ALL 
SELECT tbAccount.guid,tbaccount.name,  tbAccount.AccType , tbPay.PayDateD, CAST(tbpay.amount  as FLOAT) as payin,  0 as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 0
UNION ALL 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbPay.PayDateD, 0 as payin, CAST(tbpay.amount as FLOAT) as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 1
UNION ALL 
SELECT tbAccount.guid,tbaccount.name ,  tbAccount.AccType ,  tbMaintenance.MainDateD as paydated,   0 as amountin,  CAST(tbMaintenance.Remain as FLOAT) as amountout  FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL 
SELECT tbaccount.guid ,  tbaccount.name ,  tbAccount.AccType ,tbAccount.CashDateD as paydated,  tbAccount.amountin  ,  tbAccount.amountout    FROM tbaccount WHERE StartCash = 1
-- MSG: There is already an object named 'vwAccountsBalanceRaw' in the database.

-- ERROR IN: vwMaintenance
CREATE VIEW vwMaintenance AS 
SELECT tbMaintenance.GUID  , tbMaintenance.OrderNo ,  tbMaintenance.Model , tbMaintenance.accountguid , tbAccount.Code || '-' || tbaccount.Name as account , tbAccount.Mobile ,   tbMaintenance.Operator , tbMaintenance.MainDate  , tbMaintenance.MainDateD ,tbMaintenance.MainEndDate  , tbMaintenance.MainEndDateD ,      tbMaintenance.Cost,  tbMaintenance.PcCost,   tbMaintenance.Payment , tbMaintenance.Remain,  tbMaintenance.Note ,   tbMaintenance.MainState  , tbMaintenance.UserGuid FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid
-- MSG: There is already an object named 'vwMaintenance' in the database.

-- ERROR IN: vwMatQtyStore
CREATE VIEW vwMatQtyStore AS 
SELECT  guid, storeGuid, mat, SUM(StartQty) as StartQty, SUM(StartQtyPrice)as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice ,  SUM(QtyOut)  as qtyout ,  SUM(QtyOutPrice) as QtyOutPrice,    SUM(StartQty + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRawStore
GROUP BY  guid, storeGuid, mat
-- MSG: Invalid object name 'vwMatQtyRawStore'.

-- ERROR IN: vwMatQty
CREATE VIEW vwMatQty AS 
SELECT  guid, groupname, mat, SUM(StartQty) as StartQty , SUM(StartQtyPrice) as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice,  SUM(QtyOut)  as qtyout , SUM(QtyOutPrice) as QtyOutPrice,  SUM(StartQty  + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRaw
GROUP BY  guid, groupname, mat
-- MSG: There is already an object named 'vwMatQty' in the database.

-- ERROR IN: vwCashRAW
CREATE VIEW vwCashRAW AS 
SELECT tbBillHeader.guid,  CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] ,   0 as amountin,tbBillheader.[totalnet] as amountout   FROM tbBillHeader
WHERE paytype <> 'آجل' AND isDelay = 0 AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3)  
UNION ALL
SELECT tbBillHeader.guid, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] , tbBillheader.[totalnet] as amountin,0 as amountout  FROM tbBillHeader
WHERE paytype <> 'آجل'  AND isDelay = 0 AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2)
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  0 as amountin, tbpay.amount as amountout   FROM tbPay 
WHERE paytype = 1  
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  tbpay.amount as amountin,  0 as amountout  FROM tbPay 
WHERE paytype = 0
UNION ALL
SELECT tbMaintenance.Guid, 'صيانة' as paytype , tbMaintenance.MainDated as Paydated ,tbMaintenance.Payment as amountin , 0 as amountout   FROM tbMaintenance WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL
SELECT tbaccount.guid , ('رصيد إفتتاحي' || '-' || tbaccount.name) as paytype, tbAccount.CashDateD as paydated,   tbAccount.amountin  ,  tbAccount.amountout   FROM tbaccount WHERE StartCash = 1
UNION ALL 
SELECT tbmat.guid , ('رصيد إبتدائي') as paytype, tbMat.StartDateD as paydated,    0 as  amountin ,    SUM(tbMat.StartQty * tbMat.BuyPrice)  as amountout   FROM tbMat  WHERE tbMat.IsStartQty = 1  GROUP BY paytype
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwBillProfits
CREATE VIEW "vwBillProfits" AS SELECT vwBillProfitsRAW.guid , billdate , billdated , matguid , tbMat.code, tbMat.name , tbMat.GroupName ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost , CASE WHEN (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty)  ELSE (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) END as TotalBuyCost ,  CASE WHEN (SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) ELSE SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty) END  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = vwBillProfitsRAW.matGuid  
GROUP BY  DATE(billdate) , billdated , matguid , tbMat.code, tbMat.name
-- MSG: An expression of non-boolean type specified in a context where a condition is expected, near 'THEN'.

-- ERROR IN: vwAccoutnSelectNew
CREATE VIEW vwAccoutnSelectNew AS SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note, tbAccount.StartCash AS balance  FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelectNew' in the database.

-- ERROR IN: vwBillBody
CREATE VIEW vwBillBody AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeader ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBody' in the database.

-- ERROR IN: vwProductSalesInSession
CREATE VIEW vwProductSalesInSession AS SELECT b.matguid AS ProductID, m.name AS ProductName, b.qty AS Quantity, b.price AS UnitPrice, (b.qty * b.price) AS TotalPrice, r.uid AS SessionID, r.user AS UserName, r.invoice_num AS InvoiceNumber, r.total AS InvoiceTotal FROM tbBillBodyNew b INNER JOIN cash_drawer_report_new r ON b.parentguid = r.parentGuid INNER JOIN tbMat m ON b.matguid = m.guid
-- MSG: There is already an object named 'vwProductSalesInSession' in the database.

-- ERROR IN: vwBillsFee
CREATE VIEW vwBillsFee AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valin , CAST(0 as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 1 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 2 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 0 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1 ) as valin , 0 as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 3 UNION ALL SELECT tbpay.guid,tbpay.number, 'سند صرف' as billtype, tbpay.paydate as BillDate ,tbpay.paydated as BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbpay.notes as note , tbpay.[amount] as total, tbpay.amount as totalnet, 0 as Extra , 0 as discount , 0 as extraval , 0 as discountval , 0 as valin , CAST(tbpay.amount AS Float) as valout FROM tbpay JOIN tbAccount ON tbpay.accountguid = tbAccount.guid WHERE tbaccount.Code = 3 UNION ALL SELECT tbMaintenance.Guid, tbMaintenance.OrderNo as number, 'صيانة' as billtype ,tbMaintenance.MainDate as BillDate, tbMaintenance.MainDated as BillDateD , tbaccount.code || '-' || tbAccount.name as account, tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbMaintenance.Note , tbMaintenance.Cost as total, tbMaintenance.Cost + tbMaintenance.ExtraVal as Totalnet , 0 as Extra , 0 as discount , tbMaintenance.ExtraVal as extraval , 0 as discountval , tbMaintenance.ExtraVal as valin , CAST(0 as FLOAT) as valout FROM tbMaintenance JOIN tbAccount ON tbMaintenance.accountguid = tbAccount.guid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwDailySellsRAW
CREATE VIEW vwDailySellsRAW AS SELECT tbMat.guid, tbBillHeader.BillDated, tbMat.code || '-' || tbMat.name as mat, SUM(tbBillBodyNew.qty) as Qty , CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) as float) - (Total - TotalNet) as TotalSellPrice, CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) - SUM(tbBillBodyNew.Qty * tbMat.BuyPrice) as float) - (Total - TotalNet) as TotalProfitsOut FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 AND isDelay = 0 GROUP BY tbBillHeader.BillDated ,tbMat.guid,tbMat.code, tbMat.[name]
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.
Column 'tbBillHeader.total' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
Column 'tbBillHeader.totalnet' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatSellsPic
CREATE VIEW vwMatSellsPic AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype ,tbBillheader.BillDate , tbBillheader.BillDated , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount , tbMat.[GroupName], tbMat.[code] as matcode , tbMat.name as matname, tbBillBodyNew.qty , tbBillbodyNew.price , tbBillBodyNew.qty * tbBillbodyNew.price as bodytotal, tbBillBodyNew.note as bodynote , tbPicture.Pic FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwMatSellsPic' in the database.

-- ERROR IN: vwBillBodyNew
CREATE VIEW vwBillBodyNew AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeaderNew ON tbBillBodyNew.parentguid = tbBillHeaderNew.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBodyNew' in the database.

-- ERROR IN: vwMatQtyRaw
CREATE VIEW vwMatQtyRaw AS SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice , 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, tbmat.startQty, SUM(tbmat.StartQtyPrice) as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat WHERE tbMat.IsStartQty = 1 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name]
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillsProfitsRawSell
CREATE VIEW vwBillsProfitsRawSell as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , CASE tbBillHeader.billtype WHEN 1 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) WHEN 3 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) END as SellCost, (100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwBillsProfitsRawBuy
CREATE VIEW vwBillsProfitsRawBuy as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , tbBillBodyNew.Qty* tbBillBodyNew.Price as SellCost ,(100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwMatQtyRawStore
CREATE VIEW vwMatQtyRawStore AS SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty , 0 as StartQtyPrice, 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] ,tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty, 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.Price ) as QtyInPrice , 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbMat.StoreGuid, tbMat.StartQty , tbMat.StartQtyPrice as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbMat.StoreGuid
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBarCodeRptwithTax
CREATE VIEW vwBarCodeRptwithTax AS SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , ROUND(tbMat.SellPrice+(tbMat.SellPrice*(tbMat.FeePercent*0.01)),2) as SellPrice, CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END as CurrentQty, tbMat.BarCode , 0 as Qty FROM tbMat LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRptwithTax' in the database.

-- ERROR IN: vwUserBills
CREATE VIEW vwUserBills AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , CAST(tbBillheader.totalnet as FLOAT) as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 1 OR BillType = 2) UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , 0 as AmountIn , tbBillheader.totalnet as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 0 OR BillType = 3) UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype ,tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 0 UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated ,0 as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 1 UNION ALL SELECT guid, 0 as number , 'صيانة' as billtype, 'نقدي' as paytype , tbMaintenance.MainDate as BillDate ,tbMaintenance.MainDateD as BillDated ,tbMaintenance.Payment as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbMaintenance WHERE tbMaintenance.MainState = 'جاهزة' UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 2 THEN 'تحويل' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 2
-- MSG: There is already an object named 'vwUserBills' in the database.

-- ERROR IN: vwBillPrint
CREATE VIEW vwBillPrint AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' WHEN 4 THEN 'عرض سعر' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype as paytype ,tbBillheader.BillDate , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount ,tbBillheader.extraval, tbBillheader.discountval, tbMat.[code] as matcode, tbMat.[unite] as matunite , tbMat.name as matname, tbBillBodyNew.qty , tbBillBodyNew.price , tbBillBodyNew.qty * tbBillBodyNew.price as bodytotal,tbBillBodyNew.price/100.00*tbBillBodyNew.TaxValue as totalwithtax, tbBillBodyNew.note as bodynote FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwBillPrint' in the database.

-- ERROR IN: vwBills
CREATE VIEW vwBills AS 
SELECT
    tbBillheader.guid,
    tbBillHeader.number, 
    CASE tbBillHeader.billtype
        WHEN 0 THEN 'مشتريات'
        WHEN 1 THEN 'مبيعات'
        WHEN 2 THEN 'مرتجع مشتريات'
        WHEN 3 THEN 'مرتجع مبيعات'
        WHEN 4 THEN 'عرض سعر'
        WHEN 5 THEN 'إدخال'
        WHEN 6 THEN 'إخراج'
    END AS billtype, 
    --إضافة شرط الـ QR Code
   
    tbBillheader.BillDate,
    tbBillheader.BillDated, 
    tbAccount.code || '-' || tbAccount.name AS account,
    tbaccount.Mobile, 
    tbAccount.Email, 
    tbBillHeader.Paytype AS paytype, 
    tbBillheader.[note], 
    tbBillheader.[total], 
    tbBillheader.totalnet,
    COALESCE((SELECT SUM(SellCost) FROM vwBillsProfitsRawSell
              WHERE Number = tbBillHeader.number
              AND(tbBillHeader.billtype = 1 OR tbBillHeader.billtype = 3)), 0.0) AS SellCost,
    CAST(tbBillheader.extra AS FLOAT) AS Extra,
    tbBillheader.discount, 
    tbBillheader.extraval, 
    tbBillheader.discountval,
 CASE
        WHEN tbBillHeader.billtype IN(1, 3) THEN tbBillHeader.qr_code
        ELSE '0'
    END AS qr_code
FROM tbBillHeader
JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid
WHERE tbBillHeader.billtype<> 4
-- MSG: There is already an object named 'vwBills' in the database.

-- ERROR IN: vwPay1
CREATE VIEW vwPay1 AS SELECT tbBillHeader.guid, tbBillHeader.accountguid, tbBillHeader.number, tbBillHeader.billdate ,tbBillHeader.billdated , tbBillHeader.billtype as billtype, tbaccount.code || '-' || tbaccount.name as account, CASE tbBillHeader.billtype WHEN 0 THEN totalnet WHEN 1 THEN 0 END as amountin, CASE tbBillHeader.billtype WHEN 0 THEN 0 WHEN 1 THEN totalnet END as amountout ,tbBillHeader.note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid = tbaccount.guid WHERE tbBillHeader.paytype = 'نقدي' AND tbBillHeader.billtype = 0 ORDER by number
-- MSG: There is already an object named 'vwPay1' in the database.

-- ERROR IN: vwAccountPayments
CREATE VIEW vwAccountPayments AS SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype = 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.00 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=3) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.0 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=0 OR tbBillheader.billtype=3) UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbpay.amount AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=1 UNION ALL SELECT vwPay1.guid,vwPay1.number,'سداد فاتورة مشتريات' AS billtype,'نقدي' AS paytype,vwPay1.billdate,vwPay1.billdated,vwPay1.accountguid,tbAccount.name,tbAccount.AccType,vwPay1.amountout AS amountin,vwPay1.amountin AS amountout,vwPay1.note AS note FROM vwPay1 JOIN tbAccount ON vwPay1.accountguid=tbaccount.guid WHERE paytype='نقدي' UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,tbpay.amount AS amountin,0.0 AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=0 UNION ALL SELECT tbMaintenance.GUID,tbMaintenance.OrderNo AS number,'صيانة' AS billtype,'نقدي' AS paytype,tbMaintenance.MainDate AS paydate,tbMaintenance.MainDateD AS paydated,tbMaintenance.accountguid,tbaccount.Name AS account,tbAccount.AccType,0.0 AS amountin,tbMaintenance.Cost AS amountout,tbMaintenance.Note FROM tbMaintenance JOIN tbAccount ON tbAccount.Guid=tbMaintenance.AccountGuid WHERE tbMaintenance.MainState='جاهزة' UNION ALL SELECT tbaccount.guid,tbaccount.Code AS number,'رصيد إفتتاحي' AS billtype,'نقدي' AS paytype,tbAccount.CashDate AS paydate,tbAccount.CashDateD AS paydated,tbaccount.guid AS accountguid,tbAccount.name,tbAccount.AccType,tbAccount.amountin,tbAccount.amountout,tbAccount.note FROM tbaccount WHERE StartCash=1
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwDailySells
CREATE VIEW vwDailySells AS 
SELECT guid , billdated, mat, SUM(Qty) As Qty , CAST(SUM(TotalSellPrice) as float) as TotalSellPrice ,   CAST(SUM(TotalProfitsOut) as float) as TotalProfits  FROM vwDailySellsRaw
GROUP BY guid , billdated , mat
-- MSG: There is already an object named 'vwDailySells' in the database.

-- ERROR IN: vwBarCodeRpt
CREATE VIEW vwBarCodeRpt AS 
SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , tbMat.SellPrice , CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END  as CurrentQty,  tbMat.BarCode , 0 as Qty FROM tbMat
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRpt' in the database.

-- ERROR IN: vwBillProfitsRAW
CREATE VIEW vwBillProfitsRAW AS 
SELECT Guid as Guid , number, billtype, BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name ,0 as SellCost,   vwBillsProfitsRawBuy.Amount / vwBillsProfitsRawBuy.Qty  as BuyCost , 0 as TotalSellQty , vwBillsProfitsRawBuy.Qty  as TotalBuyQty  , 0 as TotalSell ,  vwBillsProfitsRawBuy.Amount  as TotalBuy  ,  0 as TotalSellCost, SellCost as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell,  0 as  NetBuy , Percentt  as BuyPrecent , 0 as SellPrecent FROM vwBillsProfitsRawBuy 
UNION ALL
SELECT Guid as Guid ,  number,   billtype,BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name , vwBillsProfitsRawSell.Amount  /  vwBillsProfitsRawSell.Qty  as SellCost , 0 as BuyCost ,  vwBillsProfitsRawSell.Qty  as TotalSellQty , 0 as TotalBuyQty , vwBillsProfitsRawSell.Amount  as TotalSell  , 0 as TotalBuy,  SellCost as TotalSellCost, 0 as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell , 0 as NetBuy ,   0 as BuyPrecent ,  Percentt  as SellPrecent FROM vwBillsProfitsRawSell
-- MSG: There is already an object named 'vwBillProfitsRAW' in the database.

-- ERROR IN: vwBillProfitsBills
CREATE VIEW vwBillProfitsBills AS 
SELECT guid, number, billtype , billdate, billdated , SUM(TotalSellCost) as TotalSellCost, SUM(TotalBuyCost) as TotalBuyCost  , SUM(TotalProfits) as TotalProfits from vwBillProfitsBillsRaw
GROUP BY  guid, number, billtype
-- MSG: Column 'vwBillProfitsBillsRaw.billdate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillProfitsBillsRaw
CREATE VIEW vwBillProfitsBillsRaw AS 
SELECT    vwBillProfitsRAW.guid ,vwBillProfitsRAW.Number, vwBillProfitsRAW.billType,  billdate , billdated , matguid , tbMat.code, tbMat.name ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost ,  TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) as  TotalBuyCost ,    TotalSellCost -  (TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) )  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = matguid   WHERE billtype ='مبيعات'
GROUP BY vwBillProfitsRAW.guid  ,vwBillProfitsRAW.Number  ,vwBillProfitsRAW.billType, matguid
-- MSG: Column 'vwBillProfitsRAW.BillDate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatEndDateRaw
CREATE VIEW vwMatEndDateRaw AS 
SELECT tbMat.guid,tbBillHeader.guid as billguid, tbMat.code || '-' || tbMat.Name as mat, SUM(tbBillBody.Qty) as qty , tbBillBody.EndDate FROM tbBillHeader JOIN tbBillBody 
ON tbBillHeader.guid = tbBillBody.ParentGuid 
JOIN tbMat ON tbBillBody.matguid = tbMat.guid 
JOIN vwMatQty ON tbMat.guid = vwMatQty.guid
WHERE (tbBillheader.billtype = 0 OR tbBillheader.billtype = 3) AND vwMatQty.Qty > 0
AND tbBillBody.endDate > ('1913-01-02 00:00:00')
GROUP BY tbMat.guid, tbmat.code, tbBillHeader.guid, tbmat.name, tbBillBody.EndDate
-- MSG: Invalid column name 'endDate'.
Invalid column name 'EndDate'.
Invalid column name 'EndDate'.

-- ERROR IN: vwMatEndDate
CREATE VIEW vwMatEndDate AS 
SELECT Guid,billguid, Mat,SUM(Qty) as Qty ,vwMatEndDateRaw.endDate, Round(julianday(enddate) - julianday('now')) as days, '' as Status FROM vwMatEndDateRaw
GROUP BY guid, Mat,Qty , vwMatEndDateRaw.EndDate,Days 
ORDER BY  guid, billguid, enddate ASC
-- MSG: The round function requires 2 to 3 arguments.

-- ERROR IN: vwAccountsBalance
CREATE VIEW vwAccountsBalance AS 
SELECT guid ,name, acctype , billdated , CAST(SUM(Payin) as FLOAT) as PayIn ,  CAST(SUM(payOut) as FLOAT) as payout, CAST(CAST(SUM(Payin) AS FLOAT) - CAST(SUM(PayOut) as FLOAT) as FLOAT) as balance FROM vwAccountsBalanceRaw
GROUP BY guid,  acctype , name
-- MSG: Column 'vwAccountsBalanceRaw.BillDateD' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwPay
CREATE VIEW vwPay AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate ,tbpay.paydated ,  CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code || '-' || tbaccount.name as account, CASE tbPay.paytype WHEN 0 THEN amount WHEN 1 THEN 0 END as amountin, CASE tbPay.paytype WHEN 0 THEN 0 WHEN 1 THEN amount END as amountout ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE tbpay.PayType = 1 OR tbPay.PayType = 0
ORDER by paydate, number
-- MSG: There is already an object named 'vwPay' in the database.

-- ERROR IN: vwPayPrint
CREATE VIEW vwPayPrint AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate , CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code , tbaccount.name as account, amount ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE paytype = 0 OR PayType = 1
-- MSG: There is already an object named 'vwPayPrint' in the database.

-- ERROR IN: vwBillsDelay
CREATE VIEW vwBillsDelay AS 
SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillheader.BillDate  ,tbBillheader.BillDated  , tbAccount.code|| '-' ||  tbAccount.name  as account,tbaccount.Mobile , tbAccount.Email ,    tbBillHeader.Paytype  as paytype  , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra 
, tbBillheader.discount FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid  WHERE IsDelay = 1
ORDER BY tbBillheader.NUMBER , billdate
-- MSG: There is already an object named 'vwBillsDelay' in the database.

-- ERROR IN: vwService
CREATE VIEW vwService AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwService' in the database.

-- ERROR IN: vwNotify
CREATE VIEW vwNotify AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwNotify' in the database.

-- ERROR IN: vwCash
CREATE VIEW vwCash AS 
SELECT  guid , billtype, billdated , SUM(amountin) as amountin, SUM(amountout) as amountout    FROM vwcashRaw
-- MSG: Column 'vwcashRaw.guid' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatInCash
CREATE VIEW vwMatInCash AS 
SELECT tbMat.Guid,tbMat.GroupName,tbMat.code,tbMat.name,tbMat.BuyPrice,tbMat.SellPrice, tbMat.DiscountVal ,tbMat.DiscountPercent ,   tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent,tbMat.Barcode,tbMat.MinQty,tbMat.MinPrice,tbMat.CurrentQty, tbMat.ShowInCash , tbPicture.Pic FROM tbMat JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid    
WHERE ShowInCash = 1
-- MSG: There is already an object named 'vwMatInCash' in the database.

-- ERROR IN: vwMat
CREATE VIEW vwMat AS  
SELECT tbMat.Guid , tbMat.GroupName , tbMat.Code , tbMat.Name ,tbMat.BuyPrice , tbMat.SellPrice ,tbMat.DiscountVal ,tbMat.DiscountPercent , tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent , tbMat.Barcode , tbMat.MinQty , tbMat.MinPrice , CASE WHEN vwMatQty.qty IS NULL THEN 0 ELSE  vwMatQty.qty END as CurrentQty , tbMat.EndDate , tbMat.ShowInCash FROM tbMat 
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwMat' in the database.

-- ERROR IN: vwMaintenaceBody
CREATE VIEW vwMaintenaceBody AS 
SELECT tbMaintenaceBody.guid, tbMaintenaceBody.matguid, tbMaintenaceBody.parentguid, tbMaintenaceBody.number, tbmat.code || '-' || tbMat.name as mat, tbMaintenaceBody.[qty] , tbMaintenaceBody.[price] , (tbMaintenaceBody.[qty] * tbMaintenaceBody.[price]) as total , tbMaintenaceBody.note   
FROM tbMaintenaceBody JOIN tbMaintenance ON tbMaintenaceBody.parentguid = tbMaintenance.guid 
JOIN tbmat on tbMaintenaceBody.matguid = tbMat.guid ORDER BY tbMaintenaceBody.number
-- MSG: There is already an object named 'vwMaintenaceBody' in the database.

-- ERROR IN: vwAccoutnSelect
CREATE VIEW vwAccoutnSelect AS 
SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note,  CAST( CASE WHEN (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) IS NULL THEN 0 ELSE (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) END as FLOAT) as balance FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelect' in the database.

-- ERROR IN: vwAccountsBalanceRaw
CREATE VIEW vwAccountsBalanceRaw AS 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbBillHeader.BillDateD, 0 as payin,  CAST(tbBillHeader.totalnet as FLOAT) as payout FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2) 
UNION ALL 
SELECT tbAccount.guid, tbaccount.name,  tbAccount.AccType , tbBillHeader.BillDateD, CAST(tbBillHeader.totalnet as FLOAT) as payin, 0 as payout  FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3) 
UNION ALL 
SELECT tbAccount.guid,tbaccount.name,  tbAccount.AccType , tbPay.PayDateD, CAST(tbpay.amount  as FLOAT) as payin,  0 as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 0
UNION ALL 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbPay.PayDateD, 0 as payin, CAST(tbpay.amount as FLOAT) as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 1
UNION ALL 
SELECT tbAccount.guid,tbaccount.name ,  tbAccount.AccType ,  tbMaintenance.MainDateD as paydated,   0 as amountin,  CAST(tbMaintenance.Remain as FLOAT) as amountout  FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL 
SELECT tbaccount.guid ,  tbaccount.name ,  tbAccount.AccType ,tbAccount.CashDateD as paydated,  tbAccount.amountin  ,  tbAccount.amountout    FROM tbaccount WHERE StartCash = 1
-- MSG: There is already an object named 'vwAccountsBalanceRaw' in the database.

-- ERROR IN: vwMaintenance
CREATE VIEW vwMaintenance AS 
SELECT tbMaintenance.GUID  , tbMaintenance.OrderNo ,  tbMaintenance.Model , tbMaintenance.accountguid , tbAccount.Code || '-' || tbaccount.Name as account , tbAccount.Mobile ,   tbMaintenance.Operator , tbMaintenance.MainDate  , tbMaintenance.MainDateD ,tbMaintenance.MainEndDate  , tbMaintenance.MainEndDateD ,      tbMaintenance.Cost,  tbMaintenance.PcCost,   tbMaintenance.Payment , tbMaintenance.Remain,  tbMaintenance.Note ,   tbMaintenance.MainState  , tbMaintenance.UserGuid FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid
-- MSG: There is already an object named 'vwMaintenance' in the database.

-- ERROR IN: vwMatQtyStore
CREATE VIEW vwMatQtyStore AS 
SELECT  guid, storeGuid, mat, SUM(StartQty) as StartQty, SUM(StartQtyPrice)as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice ,  SUM(QtyOut)  as qtyout ,  SUM(QtyOutPrice) as QtyOutPrice,    SUM(StartQty + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRawStore
GROUP BY  guid, storeGuid, mat
-- MSG: There is already an object named 'vwMatQtyStore' in the database.

-- ERROR IN: vwMatQty
CREATE VIEW vwMatQty AS 
SELECT  guid, groupname, mat, SUM(StartQty) as StartQty , SUM(StartQtyPrice) as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice,  SUM(QtyOut)  as qtyout , SUM(QtyOutPrice) as QtyOutPrice,  SUM(StartQty  + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRaw
GROUP BY  guid, groupname, mat
-- MSG: There is already an object named 'vwMatQty' in the database.

-- ERROR IN: vwCashRAW
CREATE VIEW vwCashRAW AS 
SELECT tbBillHeader.guid,  CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] ,   0 as amountin,tbBillheader.[totalnet] as amountout   FROM tbBillHeader
WHERE paytype <> 'آجل' AND isDelay = 0 AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3)  
UNION ALL
SELECT tbBillHeader.guid, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] , tbBillheader.[totalnet] as amountin,0 as amountout  FROM tbBillHeader
WHERE paytype <> 'آجل'  AND isDelay = 0 AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2)
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  0 as amountin, tbpay.amount as amountout   FROM tbPay 
WHERE paytype = 1  
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  tbpay.amount as amountin,  0 as amountout  FROM tbPay 
WHERE paytype = 0
UNION ALL
SELECT tbMaintenance.Guid, 'صيانة' as paytype , tbMaintenance.MainDated as Paydated ,tbMaintenance.Payment as amountin , 0 as amountout   FROM tbMaintenance WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL
SELECT tbaccount.guid , ('رصيد إفتتاحي' || '-' || tbaccount.name) as paytype, tbAccount.CashDateD as paydated,   tbAccount.amountin  ,  tbAccount.amountout   FROM tbaccount WHERE StartCash = 1
UNION ALL 
SELECT tbmat.guid , ('رصيد إبتدائي') as paytype, tbMat.StartDateD as paydated,    0 as  amountin ,    SUM(tbMat.StartQty * tbMat.BuyPrice)  as amountout   FROM tbMat  WHERE tbMat.IsStartQty = 1  GROUP BY paytype
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwBillProfits
CREATE VIEW "vwBillProfits" AS SELECT vwBillProfitsRAW.guid , billdate , billdated , matguid , tbMat.code, tbMat.name , tbMat.GroupName ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost , CASE WHEN (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty)  ELSE (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) END as TotalBuyCost ,  CASE WHEN (SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) ELSE SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty) END  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = vwBillProfitsRAW.matGuid  
GROUP BY  DATE(billdate) , billdated , matguid , tbMat.code, tbMat.name
-- MSG: An expression of non-boolean type specified in a context where a condition is expected, near 'THEN'.

-- ERROR IN: vwAccoutnSelectNew
CREATE VIEW vwAccoutnSelectNew AS SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note, tbAccount.StartCash AS balance  FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelectNew' in the database.

-- ERROR IN: vwBillBody
CREATE VIEW vwBillBody AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeader ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBody' in the database.

-- ERROR IN: vwProductSalesInSession
CREATE VIEW vwProductSalesInSession AS SELECT b.matguid AS ProductID, m.name AS ProductName, b.qty AS Quantity, b.price AS UnitPrice, (b.qty * b.price) AS TotalPrice, r.uid AS SessionID, r.user AS UserName, r.invoice_num AS InvoiceNumber, r.total AS InvoiceTotal FROM tbBillBodyNew b INNER JOIN cash_drawer_report_new r ON b.parentguid = r.parentGuid INNER JOIN tbMat m ON b.matguid = m.guid
-- MSG: There is already an object named 'vwProductSalesInSession' in the database.

-- ERROR IN: vwBillsFee
CREATE VIEW vwBillsFee AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valin , CAST(0 as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 1 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 2 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 0 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1 ) as valin , 0 as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 3 UNION ALL SELECT tbpay.guid,tbpay.number, 'سند صرف' as billtype, tbpay.paydate as BillDate ,tbpay.paydated as BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbpay.notes as note , tbpay.[amount] as total, tbpay.amount as totalnet, 0 as Extra , 0 as discount , 0 as extraval , 0 as discountval , 0 as valin , CAST(tbpay.amount AS Float) as valout FROM tbpay JOIN tbAccount ON tbpay.accountguid = tbAccount.guid WHERE tbaccount.Code = 3 UNION ALL SELECT tbMaintenance.Guid, tbMaintenance.OrderNo as number, 'صيانة' as billtype ,tbMaintenance.MainDate as BillDate, tbMaintenance.MainDated as BillDateD , tbaccount.code || '-' || tbAccount.name as account, tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbMaintenance.Note , tbMaintenance.Cost as total, tbMaintenance.Cost + tbMaintenance.ExtraVal as Totalnet , 0 as Extra , 0 as discount , tbMaintenance.ExtraVal as extraval , 0 as discountval , tbMaintenance.ExtraVal as valin , CAST(0 as FLOAT) as valout FROM tbMaintenance JOIN tbAccount ON tbMaintenance.accountguid = tbAccount.guid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwDailySellsRAW
CREATE VIEW vwDailySellsRAW AS SELECT tbMat.guid, tbBillHeader.BillDated, tbMat.code || '-' || tbMat.name as mat, SUM(tbBillBodyNew.qty) as Qty , CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) as float) - (Total - TotalNet) as TotalSellPrice, CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) - SUM(tbBillBodyNew.Qty * tbMat.BuyPrice) as float) - (Total - TotalNet) as TotalProfitsOut FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 AND isDelay = 0 GROUP BY tbBillHeader.BillDated ,tbMat.guid,tbMat.code, tbMat.[name]
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.
Column 'tbBillHeader.total' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
Column 'tbBillHeader.totalnet' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatSellsPic
CREATE VIEW vwMatSellsPic AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype ,tbBillheader.BillDate , tbBillheader.BillDated , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount , tbMat.[GroupName], tbMat.[code] as matcode , tbMat.name as matname, tbBillBodyNew.qty , tbBillbodyNew.price , tbBillBodyNew.qty * tbBillbodyNew.price as bodytotal, tbBillBodyNew.note as bodynote , tbPicture.Pic FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwMatSellsPic' in the database.

-- ERROR IN: vwBillBodyNew
CREATE VIEW vwBillBodyNew AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeaderNew ON tbBillBodyNew.parentguid = tbBillHeaderNew.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBodyNew' in the database.

-- ERROR IN: vwMatQtyRaw
CREATE VIEW vwMatQtyRaw AS SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice , 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, tbmat.startQty, SUM(tbmat.StartQtyPrice) as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat WHERE tbMat.IsStartQty = 1 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name]
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillsProfitsRawSell
CREATE VIEW vwBillsProfitsRawSell as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , CASE tbBillHeader.billtype WHEN 1 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) WHEN 3 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) END as SellCost, (100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwBillsProfitsRawBuy
CREATE VIEW vwBillsProfitsRawBuy as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , tbBillBodyNew.Qty* tbBillBodyNew.Price as SellCost ,(100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwMatQtyRawStore
CREATE VIEW vwMatQtyRawStore AS SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty , 0 as StartQtyPrice, 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] ,tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty, 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.Price ) as QtyInPrice , 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbMat.StoreGuid, tbMat.StartQty , tbMat.StartQtyPrice as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbMat.StoreGuid
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBarCodeRptwithTax
CREATE VIEW vwBarCodeRptwithTax AS SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , ROUND(tbMat.SellPrice+(tbMat.SellPrice*(tbMat.FeePercent*0.01)),2) as SellPrice, CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END as CurrentQty, tbMat.BarCode , 0 as Qty FROM tbMat LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRptwithTax' in the database.

-- ERROR IN: vwUserBills
CREATE VIEW vwUserBills AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , CAST(tbBillheader.totalnet as FLOAT) as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 1 OR BillType = 2) UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , 0 as AmountIn , tbBillheader.totalnet as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 0 OR BillType = 3) UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype ,tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 0 UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated ,0 as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 1 UNION ALL SELECT guid, 0 as number , 'صيانة' as billtype, 'نقدي' as paytype , tbMaintenance.MainDate as BillDate ,tbMaintenance.MainDateD as BillDated ,tbMaintenance.Payment as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbMaintenance WHERE tbMaintenance.MainState = 'جاهزة' UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 2 THEN 'تحويل' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 2
-- MSG: There is already an object named 'vwUserBills' in the database.

-- ERROR IN: vwBillPrint
CREATE VIEW vwBillPrint AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' WHEN 4 THEN 'عرض سعر' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype as paytype ,tbBillheader.BillDate , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount ,tbBillheader.extraval, tbBillheader.discountval, tbMat.[code] as matcode, tbMat.[unite] as matunite , tbMat.name as matname, tbBillBodyNew.qty , tbBillBodyNew.price , tbBillBodyNew.qty * tbBillBodyNew.price as bodytotal,tbBillBodyNew.price/100.00*tbBillBodyNew.TaxValue as totalwithtax, tbBillBodyNew.note as bodynote FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwBillPrint' in the database.

-- ERROR IN: vwBills
CREATE VIEW vwBills AS 
SELECT
    tbBillheader.guid,
    tbBillHeader.number, 
    CASE tbBillHeader.billtype
        WHEN 0 THEN 'مشتريات'
        WHEN 1 THEN 'مبيعات'
        WHEN 2 THEN 'مرتجع مشتريات'
        WHEN 3 THEN 'مرتجع مبيعات'
        WHEN 4 THEN 'عرض سعر'
        WHEN 5 THEN 'إدخال'
        WHEN 6 THEN 'إخراج'
    END AS billtype, 
    --إضافة شرط الـ QR Code
   
    tbBillheader.BillDate,
    tbBillheader.BillDated, 
    tbAccount.code || '-' || tbAccount.name AS account,
    tbaccount.Mobile, 
    tbAccount.Email, 
    tbBillHeader.Paytype AS paytype, 
    tbBillheader.[note], 
    tbBillheader.[total], 
    tbBillheader.totalnet,
    COALESCE((SELECT SUM(SellCost) FROM vwBillsProfitsRawSell
              WHERE Number = tbBillHeader.number
              AND(tbBillHeader.billtype = 1 OR tbBillHeader.billtype = 3)), 0.0) AS SellCost,
    CAST(tbBillheader.extra AS FLOAT) AS Extra,
    tbBillheader.discount, 
    tbBillheader.extraval, 
    tbBillheader.discountval,
 CASE
        WHEN tbBillHeader.billtype IN(1, 3) THEN tbBillHeader.qr_code
        ELSE '0'
    END AS qr_code
FROM tbBillHeader
JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid
WHERE tbBillHeader.billtype<> 4
-- MSG: There is already an object named 'vwBills' in the database.

-- ERROR IN: vwPay1
CREATE VIEW vwPay1 AS SELECT tbBillHeader.guid, tbBillHeader.accountguid, tbBillHeader.number, tbBillHeader.billdate ,tbBillHeader.billdated , tbBillHeader.billtype as billtype, tbaccount.code || '-' || tbaccount.name as account, CASE tbBillHeader.billtype WHEN 0 THEN totalnet WHEN 1 THEN 0 END as amountin, CASE tbBillHeader.billtype WHEN 0 THEN 0 WHEN 1 THEN totalnet END as amountout ,tbBillHeader.note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid = tbaccount.guid WHERE tbBillHeader.paytype = 'نقدي' AND tbBillHeader.billtype = 0 ORDER by number
-- MSG: There is already an object named 'vwPay1' in the database.

-- ERROR IN: vwAccountPayments
CREATE VIEW vwAccountPayments AS SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype = 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.00 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=3) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.0 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=0 OR tbBillheader.billtype=3) UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbpay.amount AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=1 UNION ALL SELECT vwPay1.guid,vwPay1.number,'سداد فاتورة مشتريات' AS billtype,'نقدي' AS paytype,vwPay1.billdate,vwPay1.billdated,vwPay1.accountguid,tbAccount.name,tbAccount.AccType,vwPay1.amountout AS amountin,vwPay1.amountin AS amountout,vwPay1.note AS note FROM vwPay1 JOIN tbAccount ON vwPay1.accountguid=tbaccount.guid WHERE paytype='نقدي' UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,tbpay.amount AS amountin,0.0 AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=0 UNION ALL SELECT tbMaintenance.GUID,tbMaintenance.OrderNo AS number,'صيانة' AS billtype,'نقدي' AS paytype,tbMaintenance.MainDate AS paydate,tbMaintenance.MainDateD AS paydated,tbMaintenance.accountguid,tbaccount.Name AS account,tbAccount.AccType,0.0 AS amountin,tbMaintenance.Cost AS amountout,tbMaintenance.Note FROM tbMaintenance JOIN tbAccount ON tbAccount.Guid=tbMaintenance.AccountGuid WHERE tbMaintenance.MainState='جاهزة' UNION ALL SELECT tbaccount.guid,tbaccount.Code AS number,'رصيد إفتتاحي' AS billtype,'نقدي' AS paytype,tbAccount.CashDate AS paydate,tbAccount.CashDateD AS paydated,tbaccount.guid AS accountguid,tbAccount.name,tbAccount.AccType,tbAccount.amountin,tbAccount.amountout,tbAccount.note FROM tbaccount WHERE StartCash=1
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwDailySells
CREATE VIEW vwDailySells AS 
SELECT guid , billdated, mat, SUM(Qty) As Qty , CAST(SUM(TotalSellPrice) as float) as TotalSellPrice ,   CAST(SUM(TotalProfitsOut) as float) as TotalProfits  FROM vwDailySellsRaw
GROUP BY guid , billdated , mat
-- MSG: There is already an object named 'vwDailySells' in the database.

-- ERROR IN: vwBarCodeRpt
CREATE VIEW vwBarCodeRpt AS 
SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , tbMat.SellPrice , CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END  as CurrentQty,  tbMat.BarCode , 0 as Qty FROM tbMat
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRpt' in the database.

-- ERROR IN: vwBillProfitsRAW
CREATE VIEW vwBillProfitsRAW AS 
SELECT Guid as Guid , number, billtype, BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name ,0 as SellCost,   vwBillsProfitsRawBuy.Amount / vwBillsProfitsRawBuy.Qty  as BuyCost , 0 as TotalSellQty , vwBillsProfitsRawBuy.Qty  as TotalBuyQty  , 0 as TotalSell ,  vwBillsProfitsRawBuy.Amount  as TotalBuy  ,  0 as TotalSellCost, SellCost as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell,  0 as  NetBuy , Percentt  as BuyPrecent , 0 as SellPrecent FROM vwBillsProfitsRawBuy 
UNION ALL
SELECT Guid as Guid ,  number,   billtype,BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name , vwBillsProfitsRawSell.Amount  /  vwBillsProfitsRawSell.Qty  as SellCost , 0 as BuyCost ,  vwBillsProfitsRawSell.Qty  as TotalSellQty , 0 as TotalBuyQty , vwBillsProfitsRawSell.Amount  as TotalSell  , 0 as TotalBuy,  SellCost as TotalSellCost, 0 as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell , 0 as NetBuy ,   0 as BuyPrecent ,  Percentt  as SellPrecent FROM vwBillsProfitsRawSell
-- MSG: There is already an object named 'vwBillProfitsRAW' in the database.

-- ERROR IN: vwBillProfitsBills
CREATE VIEW vwBillProfitsBills AS 
SELECT guid, number, billtype , billdate, billdated , SUM(TotalSellCost) as TotalSellCost, SUM(TotalBuyCost) as TotalBuyCost  , SUM(TotalProfits) as TotalProfits from vwBillProfitsBillsRaw
GROUP BY  guid, number, billtype
-- MSG: Column 'vwBillProfitsBillsRaw.billdate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillProfitsBillsRaw
CREATE VIEW vwBillProfitsBillsRaw AS 
SELECT    vwBillProfitsRAW.guid ,vwBillProfitsRAW.Number, vwBillProfitsRAW.billType,  billdate , billdated , matguid , tbMat.code, tbMat.name ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost ,  TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) as  TotalBuyCost ,    TotalSellCost -  (TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) )  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = matguid   WHERE billtype ='مبيعات'
GROUP BY vwBillProfitsRAW.guid  ,vwBillProfitsRAW.Number  ,vwBillProfitsRAW.billType, matguid
-- MSG: Column 'vwBillProfitsRAW.BillDate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatEndDateRaw
CREATE VIEW vwMatEndDateRaw AS 
SELECT tbMat.guid,tbBillHeader.guid as billguid, tbMat.code || '-' || tbMat.Name as mat, SUM(tbBillBody.Qty) as qty , tbBillBody.EndDate FROM tbBillHeader JOIN tbBillBody 
ON tbBillHeader.guid = tbBillBody.ParentGuid 
JOIN tbMat ON tbBillBody.matguid = tbMat.guid 
JOIN vwMatQty ON tbMat.guid = vwMatQty.guid
WHERE (tbBillheader.billtype = 0 OR tbBillheader.billtype = 3) AND vwMatQty.Qty > 0
AND tbBillBody.endDate > ('1913-01-02 00:00:00')
GROUP BY tbMat.guid, tbmat.code, tbBillHeader.guid, tbmat.name, tbBillBody.EndDate
-- MSG: Invalid column name 'endDate'.
Invalid column name 'EndDate'.
Invalid column name 'EndDate'.

-- ERROR IN: vwMatEndDate
CREATE VIEW vwMatEndDate AS 
SELECT Guid,billguid, Mat,SUM(Qty) as Qty ,vwMatEndDateRaw.endDate, Round(julianday(enddate) - julianday('now')) as days, '' as Status FROM vwMatEndDateRaw
GROUP BY guid, Mat,Qty , vwMatEndDateRaw.EndDate,Days 
ORDER BY  guid, billguid, enddate ASC
-- MSG: The round function requires 2 to 3 arguments.

-- ERROR IN: vwAccountsBalance
CREATE VIEW vwAccountsBalance AS 
SELECT guid ,name, acctype , billdated , CAST(SUM(Payin) as FLOAT) as PayIn ,  CAST(SUM(payOut) as FLOAT) as payout, CAST(CAST(SUM(Payin) AS FLOAT) - CAST(SUM(PayOut) as FLOAT) as FLOAT) as balance FROM vwAccountsBalanceRaw
GROUP BY guid,  acctype , name
-- MSG: Column 'vwAccountsBalanceRaw.BillDateD' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwPay
CREATE VIEW vwPay AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate ,tbpay.paydated ,  CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code || '-' || tbaccount.name as account, CASE tbPay.paytype WHEN 0 THEN amount WHEN 1 THEN 0 END as amountin, CASE tbPay.paytype WHEN 0 THEN 0 WHEN 1 THEN amount END as amountout ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE tbpay.PayType = 1 OR tbPay.PayType = 0
ORDER by paydate, number
-- MSG: There is already an object named 'vwPay' in the database.

-- ERROR IN: vwPayPrint
CREATE VIEW vwPayPrint AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate , CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code , tbaccount.name as account, amount ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE paytype = 0 OR PayType = 1
-- MSG: There is already an object named 'vwPayPrint' in the database.

-- ERROR IN: vwBillsDelay
CREATE VIEW vwBillsDelay AS 
SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillheader.BillDate  ,tbBillheader.BillDated  , tbAccount.code|| '-' ||  tbAccount.name  as account,tbaccount.Mobile , tbAccount.Email ,    tbBillHeader.Paytype  as paytype  , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra 
, tbBillheader.discount FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid  WHERE IsDelay = 1
ORDER BY tbBillheader.NUMBER , billdate
-- MSG: There is already an object named 'vwBillsDelay' in the database.

-- ERROR IN: vwService
CREATE VIEW vwService AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwService' in the database.

-- ERROR IN: vwNotify
CREATE VIEW vwNotify AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwNotify' in the database.

-- ERROR IN: vwCash
CREATE VIEW vwCash AS 
SELECT  guid , billtype, billdated , SUM(amountin) as amountin, SUM(amountout) as amountout    FROM vwcashRaw
-- MSG: Column 'vwcashRaw.guid' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatInCash
CREATE VIEW vwMatInCash AS 
SELECT tbMat.Guid,tbMat.GroupName,tbMat.code,tbMat.name,tbMat.BuyPrice,tbMat.SellPrice, tbMat.DiscountVal ,tbMat.DiscountPercent ,   tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent,tbMat.Barcode,tbMat.MinQty,tbMat.MinPrice,tbMat.CurrentQty, tbMat.ShowInCash , tbPicture.Pic FROM tbMat JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid    
WHERE ShowInCash = 1
-- MSG: There is already an object named 'vwMatInCash' in the database.

-- ERROR IN: vwMat
CREATE VIEW vwMat AS  
SELECT tbMat.Guid , tbMat.GroupName , tbMat.Code , tbMat.Name ,tbMat.BuyPrice , tbMat.SellPrice ,tbMat.DiscountVal ,tbMat.DiscountPercent , tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent , tbMat.Barcode , tbMat.MinQty , tbMat.MinPrice , CASE WHEN vwMatQty.qty IS NULL THEN 0 ELSE  vwMatQty.qty END as CurrentQty , tbMat.EndDate , tbMat.ShowInCash FROM tbMat 
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwMat' in the database.

-- ERROR IN: vwMaintenaceBody
CREATE VIEW vwMaintenaceBody AS 
SELECT tbMaintenaceBody.guid, tbMaintenaceBody.matguid, tbMaintenaceBody.parentguid, tbMaintenaceBody.number, tbmat.code || '-' || tbMat.name as mat, tbMaintenaceBody.[qty] , tbMaintenaceBody.[price] , (tbMaintenaceBody.[qty] * tbMaintenaceBody.[price]) as total , tbMaintenaceBody.note   
FROM tbMaintenaceBody JOIN tbMaintenance ON tbMaintenaceBody.parentguid = tbMaintenance.guid 
JOIN tbmat on tbMaintenaceBody.matguid = tbMat.guid ORDER BY tbMaintenaceBody.number
-- MSG: There is already an object named 'vwMaintenaceBody' in the database.

-- ERROR IN: vwAccoutnSelect
CREATE VIEW vwAccoutnSelect AS 
SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note,  CAST( CASE WHEN (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) IS NULL THEN 0 ELSE (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) END as FLOAT) as balance FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelect' in the database.

-- ERROR IN: vwAccountsBalanceRaw
CREATE VIEW vwAccountsBalanceRaw AS 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbBillHeader.BillDateD, 0 as payin,  CAST(tbBillHeader.totalnet as FLOAT) as payout FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2) 
UNION ALL 
SELECT tbAccount.guid, tbaccount.name,  tbAccount.AccType , tbBillHeader.BillDateD, CAST(tbBillHeader.totalnet as FLOAT) as payin, 0 as payout  FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3) 
UNION ALL 
SELECT tbAccount.guid,tbaccount.name,  tbAccount.AccType , tbPay.PayDateD, CAST(tbpay.amount  as FLOAT) as payin,  0 as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 0
UNION ALL 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbPay.PayDateD, 0 as payin, CAST(tbpay.amount as FLOAT) as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 1
UNION ALL 
SELECT tbAccount.guid,tbaccount.name ,  tbAccount.AccType ,  tbMaintenance.MainDateD as paydated,   0 as amountin,  CAST(tbMaintenance.Remain as FLOAT) as amountout  FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL 
SELECT tbaccount.guid ,  tbaccount.name ,  tbAccount.AccType ,tbAccount.CashDateD as paydated,  tbAccount.amountin  ,  tbAccount.amountout    FROM tbaccount WHERE StartCash = 1
-- MSG: There is already an object named 'vwAccountsBalanceRaw' in the database.

-- ERROR IN: vwMaintenance
CREATE VIEW vwMaintenance AS 
SELECT tbMaintenance.GUID  , tbMaintenance.OrderNo ,  tbMaintenance.Model , tbMaintenance.accountguid , tbAccount.Code || '-' || tbaccount.Name as account , tbAccount.Mobile ,   tbMaintenance.Operator , tbMaintenance.MainDate  , tbMaintenance.MainDateD ,tbMaintenance.MainEndDate  , tbMaintenance.MainEndDateD ,      tbMaintenance.Cost,  tbMaintenance.PcCost,   tbMaintenance.Payment , tbMaintenance.Remain,  tbMaintenance.Note ,   tbMaintenance.MainState  , tbMaintenance.UserGuid FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid
-- MSG: There is already an object named 'vwMaintenance' in the database.

-- ERROR IN: vwMatQtyStore
CREATE VIEW vwMatQtyStore AS 
SELECT  guid, storeGuid, mat, SUM(StartQty) as StartQty, SUM(StartQtyPrice)as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice ,  SUM(QtyOut)  as qtyout ,  SUM(QtyOutPrice) as QtyOutPrice,    SUM(StartQty + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRawStore
GROUP BY  guid, storeGuid, mat
-- MSG: There is already an object named 'vwMatQtyStore' in the database.

-- ERROR IN: vwMatQty
CREATE VIEW vwMatQty AS 
SELECT  guid, groupname, mat, SUM(StartQty) as StartQty , SUM(StartQtyPrice) as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice,  SUM(QtyOut)  as qtyout , SUM(QtyOutPrice) as QtyOutPrice,  SUM(StartQty  + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRaw
GROUP BY  guid, groupname, mat
-- MSG: There is already an object named 'vwMatQty' in the database.

-- ERROR IN: vwCashRAW
CREATE VIEW vwCashRAW AS 
SELECT tbBillHeader.guid,  CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] ,   0 as amountin,tbBillheader.[totalnet] as amountout   FROM tbBillHeader
WHERE paytype <> 'آجل' AND isDelay = 0 AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3)  
UNION ALL
SELECT tbBillHeader.guid, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] , tbBillheader.[totalnet] as amountin,0 as amountout  FROM tbBillHeader
WHERE paytype <> 'آجل'  AND isDelay = 0 AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2)
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  0 as amountin, tbpay.amount as amountout   FROM tbPay 
WHERE paytype = 1  
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  tbpay.amount as amountin,  0 as amountout  FROM tbPay 
WHERE paytype = 0
UNION ALL
SELECT tbMaintenance.Guid, 'صيانة' as paytype , tbMaintenance.MainDated as Paydated ,tbMaintenance.Payment as amountin , 0 as amountout   FROM tbMaintenance WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL
SELECT tbaccount.guid , ('رصيد إفتتاحي' || '-' || tbaccount.name) as paytype, tbAccount.CashDateD as paydated,   tbAccount.amountin  ,  tbAccount.amountout   FROM tbaccount WHERE StartCash = 1
UNION ALL 
SELECT tbmat.guid , ('رصيد إبتدائي') as paytype, tbMat.StartDateD as paydated,    0 as  amountin ,    SUM(tbMat.StartQty * tbMat.BuyPrice)  as amountout   FROM tbMat  WHERE tbMat.IsStartQty = 1  GROUP BY paytype
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwBillProfits
CREATE VIEW "vwBillProfits" AS SELECT vwBillProfitsRAW.guid , billdate , billdated , matguid , tbMat.code, tbMat.name , tbMat.GroupName ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost , CASE WHEN (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty)  ELSE (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) END as TotalBuyCost ,  CASE WHEN (SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) ELSE SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty) END  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = vwBillProfitsRAW.matGuid  
GROUP BY  DATE(billdate) , billdated , matguid , tbMat.code, tbMat.name
-- MSG: An expression of non-boolean type specified in a context where a condition is expected, near 'THEN'.

-- ERROR IN: vwAccoutnSelectNew
CREATE VIEW vwAccoutnSelectNew AS SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note, tbAccount.StartCash AS balance  FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelectNew' in the database.

-- ERROR IN: vwBillBody
CREATE VIEW vwBillBody AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeader ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBody' in the database.

-- ERROR IN: vwProductSalesInSession
CREATE VIEW vwProductSalesInSession AS SELECT b.matguid AS ProductID, m.name AS ProductName, b.qty AS Quantity, b.price AS UnitPrice, (b.qty * b.price) AS TotalPrice, r.uid AS SessionID, r.user AS UserName, r.invoice_num AS InvoiceNumber, r.total AS InvoiceTotal FROM tbBillBodyNew b INNER JOIN cash_drawer_report_new r ON b.parentguid = r.parentGuid INNER JOIN tbMat m ON b.matguid = m.guid
-- MSG: There is already an object named 'vwProductSalesInSession' in the database.

-- ERROR IN: vwBillsFee
CREATE VIEW vwBillsFee AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valin , CAST(0 as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 1 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 2 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 0 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1 ) as valin , 0 as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 3 UNION ALL SELECT tbpay.guid,tbpay.number, 'سند صرف' as billtype, tbpay.paydate as BillDate ,tbpay.paydated as BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbpay.notes as note , tbpay.[amount] as total, tbpay.amount as totalnet, 0 as Extra , 0 as discount , 0 as extraval , 0 as discountval , 0 as valin , CAST(tbpay.amount AS Float) as valout FROM tbpay JOIN tbAccount ON tbpay.accountguid = tbAccount.guid WHERE tbaccount.Code = 3 UNION ALL SELECT tbMaintenance.Guid, tbMaintenance.OrderNo as number, 'صيانة' as billtype ,tbMaintenance.MainDate as BillDate, tbMaintenance.MainDated as BillDateD , tbaccount.code || '-' || tbAccount.name as account, tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbMaintenance.Note , tbMaintenance.Cost as total, tbMaintenance.Cost + tbMaintenance.ExtraVal as Totalnet , 0 as Extra , 0 as discount , tbMaintenance.ExtraVal as extraval , 0 as discountval , tbMaintenance.ExtraVal as valin , CAST(0 as FLOAT) as valout FROM tbMaintenance JOIN tbAccount ON tbMaintenance.accountguid = tbAccount.guid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwDailySellsRAW
CREATE VIEW vwDailySellsRAW AS SELECT tbMat.guid, tbBillHeader.BillDated, tbMat.code || '-' || tbMat.name as mat, SUM(tbBillBodyNew.qty) as Qty , CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) as float) - (Total - TotalNet) as TotalSellPrice, CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) - SUM(tbBillBodyNew.Qty * tbMat.BuyPrice) as float) - (Total - TotalNet) as TotalProfitsOut FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 AND isDelay = 0 GROUP BY tbBillHeader.BillDated ,tbMat.guid,tbMat.code, tbMat.[name]
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.
Column 'tbBillHeader.total' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
Column 'tbBillHeader.totalnet' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatSellsPic
CREATE VIEW vwMatSellsPic AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype ,tbBillheader.BillDate , tbBillheader.BillDated , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount , tbMat.[GroupName], tbMat.[code] as matcode , tbMat.name as matname, tbBillBodyNew.qty , tbBillbodyNew.price , tbBillBodyNew.qty * tbBillbodyNew.price as bodytotal, tbBillBodyNew.note as bodynote , tbPicture.Pic FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwMatSellsPic' in the database.

-- ERROR IN: vwBillBodyNew
CREATE VIEW vwBillBodyNew AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeaderNew ON tbBillBodyNew.parentguid = tbBillHeaderNew.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBodyNew' in the database.

-- ERROR IN: vwMatQtyRaw
CREATE VIEW vwMatQtyRaw AS SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice , 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, tbmat.startQty, SUM(tbmat.StartQtyPrice) as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat WHERE tbMat.IsStartQty = 1 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name]
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillsProfitsRawSell
CREATE VIEW vwBillsProfitsRawSell as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , CASE tbBillHeader.billtype WHEN 1 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) WHEN 3 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) END as SellCost, (100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwBillsProfitsRawBuy
CREATE VIEW vwBillsProfitsRawBuy as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , tbBillBodyNew.Qty* tbBillBodyNew.Price as SellCost ,(100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwMatQtyRawStore
CREATE VIEW vwMatQtyRawStore AS SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty , 0 as StartQtyPrice, 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] ,tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty, 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.Price ) as QtyInPrice , 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbMat.StoreGuid, tbMat.StartQty , tbMat.StartQtyPrice as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbMat.StoreGuid
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBarCodeRptwithTax
CREATE VIEW vwBarCodeRptwithTax AS SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , ROUND(tbMat.SellPrice+(tbMat.SellPrice*(tbMat.FeePercent*0.01)),2) as SellPrice, CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END as CurrentQty, tbMat.BarCode , 0 as Qty FROM tbMat LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRptwithTax' in the database.

-- ERROR IN: vwUserBills
CREATE VIEW vwUserBills AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , CAST(tbBillheader.totalnet as FLOAT) as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 1 OR BillType = 2) UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , 0 as AmountIn , tbBillheader.totalnet as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 0 OR BillType = 3) UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype ,tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 0 UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated ,0 as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 1 UNION ALL SELECT guid, 0 as number , 'صيانة' as billtype, 'نقدي' as paytype , tbMaintenance.MainDate as BillDate ,tbMaintenance.MainDateD as BillDated ,tbMaintenance.Payment as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbMaintenance WHERE tbMaintenance.MainState = 'جاهزة' UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 2 THEN 'تحويل' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 2
-- MSG: There is already an object named 'vwUserBills' in the database.

-- ERROR IN: vwBillPrint
CREATE VIEW vwBillPrint AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' WHEN 4 THEN 'عرض سعر' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype as paytype ,tbBillheader.BillDate , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount ,tbBillheader.extraval, tbBillheader.discountval, tbMat.[code] as matcode, tbMat.[unite] as matunite , tbMat.name as matname, tbBillBodyNew.qty , tbBillBodyNew.price , tbBillBodyNew.qty * tbBillBodyNew.price as bodytotal,tbBillBodyNew.price/100.00*tbBillBodyNew.TaxValue as totalwithtax, tbBillBodyNew.note as bodynote FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwBillPrint' in the database.

-- ERROR IN: vwBills
CREATE VIEW vwBills AS 
SELECT
    tbBillheader.guid,
    tbBillHeader.number, 
    CASE tbBillHeader.billtype
        WHEN 0 THEN 'مشتريات'
        WHEN 1 THEN 'مبيعات'
        WHEN 2 THEN 'مرتجع مشتريات'
        WHEN 3 THEN 'مرتجع مبيعات'
        WHEN 4 THEN 'عرض سعر'
        WHEN 5 THEN 'إدخال'
        WHEN 6 THEN 'إخراج'
    END AS billtype, 
    --إضافة شرط الـ QR Code
   
    tbBillheader.BillDate,
    tbBillheader.BillDated, 
    tbAccount.code || '-' || tbAccount.name AS account,
    tbaccount.Mobile, 
    tbAccount.Email, 
    tbBillHeader.Paytype AS paytype, 
    tbBillheader.[note], 
    tbBillheader.[total], 
    tbBillheader.totalnet,
    COALESCE((SELECT SUM(SellCost) FROM vwBillsProfitsRawSell
              WHERE Number = tbBillHeader.number
              AND(tbBillHeader.billtype = 1 OR tbBillHeader.billtype = 3)), 0.0) AS SellCost,
    CAST(tbBillheader.extra AS FLOAT) AS Extra,
    tbBillheader.discount, 
    tbBillheader.extraval, 
    tbBillheader.discountval,
 CASE
        WHEN tbBillHeader.billtype IN(1, 3) THEN tbBillHeader.qr_code
        ELSE '0'
    END AS qr_code
FROM tbBillHeader
JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid
WHERE tbBillHeader.billtype<> 4
-- MSG: There is already an object named 'vwBills' in the database.

-- ERROR IN: vwPay1
CREATE VIEW vwPay1 AS SELECT tbBillHeader.guid, tbBillHeader.accountguid, tbBillHeader.number, tbBillHeader.billdate ,tbBillHeader.billdated , tbBillHeader.billtype as billtype, tbaccount.code || '-' || tbaccount.name as account, CASE tbBillHeader.billtype WHEN 0 THEN totalnet WHEN 1 THEN 0 END as amountin, CASE tbBillHeader.billtype WHEN 0 THEN 0 WHEN 1 THEN totalnet END as amountout ,tbBillHeader.note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid = tbaccount.guid WHERE tbBillHeader.paytype = 'نقدي' AND tbBillHeader.billtype = 0 ORDER by number
-- MSG: There is already an object named 'vwPay1' in the database.

-- ERROR IN: vwAccountPayments
CREATE VIEW vwAccountPayments AS SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype = 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.00 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=3) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.0 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=0 OR tbBillheader.billtype=3) UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbpay.amount AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=1 UNION ALL SELECT vwPay1.guid,vwPay1.number,'سداد فاتورة مشتريات' AS billtype,'نقدي' AS paytype,vwPay1.billdate,vwPay1.billdated,vwPay1.accountguid,tbAccount.name,tbAccount.AccType,vwPay1.amountout AS amountin,vwPay1.amountin AS amountout,vwPay1.note AS note FROM vwPay1 JOIN tbAccount ON vwPay1.accountguid=tbaccount.guid WHERE paytype='نقدي' UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,tbpay.amount AS amountin,0.0 AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=0 UNION ALL SELECT tbMaintenance.GUID,tbMaintenance.OrderNo AS number,'صيانة' AS billtype,'نقدي' AS paytype,tbMaintenance.MainDate AS paydate,tbMaintenance.MainDateD AS paydated,tbMaintenance.accountguid,tbaccount.Name AS account,tbAccount.AccType,0.0 AS amountin,tbMaintenance.Cost AS amountout,tbMaintenance.Note FROM tbMaintenance JOIN tbAccount ON tbAccount.Guid=tbMaintenance.AccountGuid WHERE tbMaintenance.MainState='جاهزة' UNION ALL SELECT tbaccount.guid,tbaccount.Code AS number,'رصيد إفتتاحي' AS billtype,'نقدي' AS paytype,tbAccount.CashDate AS paydate,tbAccount.CashDateD AS paydated,tbaccount.guid AS accountguid,tbAccount.name,tbAccount.AccType,tbAccount.amountin,tbAccount.amountout,tbAccount.note FROM tbaccount WHERE StartCash=1
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwDailySells
CREATE VIEW vwDailySells AS 
SELECT guid , billdated, mat, SUM(Qty) As Qty , CAST(SUM(TotalSellPrice) as float) as TotalSellPrice ,   CAST(SUM(TotalProfitsOut) as float) as TotalProfits  FROM vwDailySellsRaw
GROUP BY guid , billdated , mat
-- MSG: There is already an object named 'vwDailySells' in the database.

-- ERROR IN: vwBarCodeRpt
CREATE VIEW vwBarCodeRpt AS 
SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , tbMat.SellPrice , CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END  as CurrentQty,  tbMat.BarCode , 0 as Qty FROM tbMat
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRpt' in the database.

-- ERROR IN: vwBillProfitsRAW
CREATE VIEW vwBillProfitsRAW AS 
SELECT Guid as Guid , number, billtype, BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name ,0 as SellCost,   vwBillsProfitsRawBuy.Amount / vwBillsProfitsRawBuy.Qty  as BuyCost , 0 as TotalSellQty , vwBillsProfitsRawBuy.Qty  as TotalBuyQty  , 0 as TotalSell ,  vwBillsProfitsRawBuy.Amount  as TotalBuy  ,  0 as TotalSellCost, SellCost as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell,  0 as  NetBuy , Percentt  as BuyPrecent , 0 as SellPrecent FROM vwBillsProfitsRawBuy 
UNION ALL
SELECT Guid as Guid ,  number,   billtype,BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name , vwBillsProfitsRawSell.Amount  /  vwBillsProfitsRawSell.Qty  as SellCost , 0 as BuyCost ,  vwBillsProfitsRawSell.Qty  as TotalSellQty , 0 as TotalBuyQty , vwBillsProfitsRawSell.Amount  as TotalSell  , 0 as TotalBuy,  SellCost as TotalSellCost, 0 as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell , 0 as NetBuy ,   0 as BuyPrecent ,  Percentt  as SellPrecent FROM vwBillsProfitsRawSell
-- MSG: There is already an object named 'vwBillProfitsRAW' in the database.

-- ERROR IN: vwBillProfitsBills
CREATE VIEW vwBillProfitsBills AS 
SELECT guid, number, billtype , billdate, billdated , SUM(TotalSellCost) as TotalSellCost, SUM(TotalBuyCost) as TotalBuyCost  , SUM(TotalProfits) as TotalProfits from vwBillProfitsBillsRaw
GROUP BY  guid, number, billtype
-- MSG: Column 'vwBillProfitsBillsRaw.billdate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillProfitsBillsRaw
CREATE VIEW vwBillProfitsBillsRaw AS 
SELECT    vwBillProfitsRAW.guid ,vwBillProfitsRAW.Number, vwBillProfitsRAW.billType,  billdate , billdated , matguid , tbMat.code, tbMat.name ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost ,  TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) as  TotalBuyCost ,    TotalSellCost -  (TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) )  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = matguid   WHERE billtype ='مبيعات'
GROUP BY vwBillProfitsRAW.guid  ,vwBillProfitsRAW.Number  ,vwBillProfitsRAW.billType, matguid
-- MSG: Column 'vwBillProfitsRAW.BillDate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatEndDateRaw
CREATE VIEW vwMatEndDateRaw AS 
SELECT tbMat.guid,tbBillHeader.guid as billguid, tbMat.code || '-' || tbMat.Name as mat, SUM(tbBillBody.Qty) as qty , tbBillBody.EndDate FROM tbBillHeader JOIN tbBillBody 
ON tbBillHeader.guid = tbBillBody.ParentGuid 
JOIN tbMat ON tbBillBody.matguid = tbMat.guid 
JOIN vwMatQty ON tbMat.guid = vwMatQty.guid
WHERE (tbBillheader.billtype = 0 OR tbBillheader.billtype = 3) AND vwMatQty.Qty > 0
AND tbBillBody.endDate > ('1913-01-02 00:00:00')
GROUP BY tbMat.guid, tbmat.code, tbBillHeader.guid, tbmat.name, tbBillBody.EndDate
-- MSG: Invalid column name 'endDate'.
Invalid column name 'EndDate'.
Invalid column name 'EndDate'.

-- ERROR IN: vwMatEndDate
CREATE VIEW vwMatEndDate AS 
SELECT Guid,billguid, Mat,SUM(Qty) as Qty ,vwMatEndDateRaw.endDate, Round(julianday(enddate) - julianday('now')) as days, '' as Status FROM vwMatEndDateRaw
GROUP BY guid, Mat,Qty , vwMatEndDateRaw.EndDate,Days 
ORDER BY  guid, billguid, enddate ASC
-- MSG: The round function requires 2 to 3 arguments.

-- ERROR IN: vwAccountsBalance
CREATE VIEW vwAccountsBalance AS 
SELECT guid ,name, acctype , billdated , CAST(SUM(Payin) as FLOAT) as PayIn ,  CAST(SUM(payOut) as FLOAT) as payout, CAST(CAST(SUM(Payin) AS FLOAT) - CAST(SUM(PayOut) as FLOAT) as FLOAT) as balance FROM vwAccountsBalanceRaw
GROUP BY guid,  acctype , name
-- MSG: Column 'vwAccountsBalanceRaw.BillDateD' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwPay
CREATE VIEW vwPay AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate ,tbpay.paydated ,  CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code || '-' || tbaccount.name as account, CASE tbPay.paytype WHEN 0 THEN amount WHEN 1 THEN 0 END as amountin, CASE tbPay.paytype WHEN 0 THEN 0 WHEN 1 THEN amount END as amountout ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE tbpay.PayType = 1 OR tbPay.PayType = 0
ORDER by paydate, number
-- MSG: There is already an object named 'vwPay' in the database.

-- ERROR IN: vwPayPrint
CREATE VIEW vwPayPrint AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate , CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code , tbaccount.name as account, amount ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE paytype = 0 OR PayType = 1
-- MSG: There is already an object named 'vwPayPrint' in the database.

-- ERROR IN: vwBillsDelay
CREATE VIEW vwBillsDelay AS 
SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillheader.BillDate  ,tbBillheader.BillDated  , tbAccount.code|| '-' ||  tbAccount.name  as account,tbaccount.Mobile , tbAccount.Email ,    tbBillHeader.Paytype  as paytype  , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra 
, tbBillheader.discount FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid  WHERE IsDelay = 1
ORDER BY tbBillheader.NUMBER , billdate
-- MSG: There is already an object named 'vwBillsDelay' in the database.

-- ERROR IN: vwService
CREATE VIEW vwService AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwService' in the database.

-- ERROR IN: vwNotify
CREATE VIEW vwNotify AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwNotify' in the database.

-- ERROR IN: vwCash
CREATE VIEW vwCash AS 
SELECT  guid , billtype, billdated , SUM(amountin) as amountin, SUM(amountout) as amountout    FROM vwcashRaw
-- MSG: Column 'vwcashRaw.guid' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatInCash
CREATE VIEW vwMatInCash AS 
SELECT tbMat.Guid,tbMat.GroupName,tbMat.code,tbMat.name,tbMat.BuyPrice,tbMat.SellPrice, tbMat.DiscountVal ,tbMat.DiscountPercent ,   tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent,tbMat.Barcode,tbMat.MinQty,tbMat.MinPrice,tbMat.CurrentQty, tbMat.ShowInCash , tbPicture.Pic FROM tbMat JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid    
WHERE ShowInCash = 1
-- MSG: There is already an object named 'vwMatInCash' in the database.

-- ERROR IN: vwMat
CREATE VIEW vwMat AS  
SELECT tbMat.Guid , tbMat.GroupName , tbMat.Code , tbMat.Name ,tbMat.BuyPrice , tbMat.SellPrice ,tbMat.DiscountVal ,tbMat.DiscountPercent , tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent , tbMat.Barcode , tbMat.MinQty , tbMat.MinPrice , CASE WHEN vwMatQty.qty IS NULL THEN 0 ELSE  vwMatQty.qty END as CurrentQty , tbMat.EndDate , tbMat.ShowInCash FROM tbMat 
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwMat' in the database.

-- ERROR IN: vwMaintenaceBody
CREATE VIEW vwMaintenaceBody AS 
SELECT tbMaintenaceBody.guid, tbMaintenaceBody.matguid, tbMaintenaceBody.parentguid, tbMaintenaceBody.number, tbmat.code || '-' || tbMat.name as mat, tbMaintenaceBody.[qty] , tbMaintenaceBody.[price] , (tbMaintenaceBody.[qty] * tbMaintenaceBody.[price]) as total , tbMaintenaceBody.note   
FROM tbMaintenaceBody JOIN tbMaintenance ON tbMaintenaceBody.parentguid = tbMaintenance.guid 
JOIN tbmat on tbMaintenaceBody.matguid = tbMat.guid ORDER BY tbMaintenaceBody.number
-- MSG: There is already an object named 'vwMaintenaceBody' in the database.

-- ERROR IN: vwAccoutnSelect
CREATE VIEW vwAccoutnSelect AS 
SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note,  CAST( CASE WHEN (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) IS NULL THEN 0 ELSE (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) END as FLOAT) as balance FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelect' in the database.

-- ERROR IN: vwAccountsBalanceRaw
CREATE VIEW vwAccountsBalanceRaw AS 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbBillHeader.BillDateD, 0 as payin,  CAST(tbBillHeader.totalnet as FLOAT) as payout FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2) 
UNION ALL 
SELECT tbAccount.guid, tbaccount.name,  tbAccount.AccType , tbBillHeader.BillDateD, CAST(tbBillHeader.totalnet as FLOAT) as payin, 0 as payout  FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3) 
UNION ALL 
SELECT tbAccount.guid,tbaccount.name,  tbAccount.AccType , tbPay.PayDateD, CAST(tbpay.amount  as FLOAT) as payin,  0 as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 0
UNION ALL 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbPay.PayDateD, 0 as payin, CAST(tbpay.amount as FLOAT) as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 1
UNION ALL 
SELECT tbAccount.guid,tbaccount.name ,  tbAccount.AccType ,  tbMaintenance.MainDateD as paydated,   0 as amountin,  CAST(tbMaintenance.Remain as FLOAT) as amountout  FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL 
SELECT tbaccount.guid ,  tbaccount.name ,  tbAccount.AccType ,tbAccount.CashDateD as paydated,  tbAccount.amountin  ,  tbAccount.amountout    FROM tbaccount WHERE StartCash = 1
-- MSG: There is already an object named 'vwAccountsBalanceRaw' in the database.

-- ERROR IN: vwMaintenance
CREATE VIEW vwMaintenance AS 
SELECT tbMaintenance.GUID  , tbMaintenance.OrderNo ,  tbMaintenance.Model , tbMaintenance.accountguid , tbAccount.Code || '-' || tbaccount.Name as account , tbAccount.Mobile ,   tbMaintenance.Operator , tbMaintenance.MainDate  , tbMaintenance.MainDateD ,tbMaintenance.MainEndDate  , tbMaintenance.MainEndDateD ,      tbMaintenance.Cost,  tbMaintenance.PcCost,   tbMaintenance.Payment , tbMaintenance.Remain,  tbMaintenance.Note ,   tbMaintenance.MainState  , tbMaintenance.UserGuid FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid
-- MSG: There is already an object named 'vwMaintenance' in the database.

-- ERROR IN: vwMatQtyStore
CREATE VIEW vwMatQtyStore AS 
SELECT  guid, storeGuid, mat, SUM(StartQty) as StartQty, SUM(StartQtyPrice)as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice ,  SUM(QtyOut)  as qtyout ,  SUM(QtyOutPrice) as QtyOutPrice,    SUM(StartQty + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRawStore
GROUP BY  guid, storeGuid, mat
-- MSG: There is already an object named 'vwMatQtyStore' in the database.

-- ERROR IN: vwMatQty
CREATE VIEW vwMatQty AS 
SELECT  guid, groupname, mat, SUM(StartQty) as StartQty , SUM(StartQtyPrice) as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice,  SUM(QtyOut)  as qtyout , SUM(QtyOutPrice) as QtyOutPrice,  SUM(StartQty  + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRaw
GROUP BY  guid, groupname, mat
-- MSG: There is already an object named 'vwMatQty' in the database.

-- ERROR IN: vwCashRAW
CREATE VIEW vwCashRAW AS 
SELECT tbBillHeader.guid,  CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] ,   0 as amountin,tbBillheader.[totalnet] as amountout   FROM tbBillHeader
WHERE paytype <> 'آجل' AND isDelay = 0 AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3)  
UNION ALL
SELECT tbBillHeader.guid, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] , tbBillheader.[totalnet] as amountin,0 as amountout  FROM tbBillHeader
WHERE paytype <> 'آجل'  AND isDelay = 0 AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2)
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  0 as amountin, tbpay.amount as amountout   FROM tbPay 
WHERE paytype = 1  
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  tbpay.amount as amountin,  0 as amountout  FROM tbPay 
WHERE paytype = 0
UNION ALL
SELECT tbMaintenance.Guid, 'صيانة' as paytype , tbMaintenance.MainDated as Paydated ,tbMaintenance.Payment as amountin , 0 as amountout   FROM tbMaintenance WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL
SELECT tbaccount.guid , ('رصيد إفتتاحي' || '-' || tbaccount.name) as paytype, tbAccount.CashDateD as paydated,   tbAccount.amountin  ,  tbAccount.amountout   FROM tbaccount WHERE StartCash = 1
UNION ALL 
SELECT tbmat.guid , ('رصيد إبتدائي') as paytype, tbMat.StartDateD as paydated,    0 as  amountin ,    SUM(tbMat.StartQty * tbMat.BuyPrice)  as amountout   FROM tbMat  WHERE tbMat.IsStartQty = 1  GROUP BY paytype
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwBillProfits
CREATE VIEW "vwBillProfits" AS SELECT vwBillProfitsRAW.guid , billdate , billdated , matguid , tbMat.code, tbMat.name , tbMat.GroupName ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost , CASE WHEN (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty)  ELSE (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) END as TotalBuyCost ,  CASE WHEN (SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) ELSE SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty) END  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = vwBillProfitsRAW.matGuid  
GROUP BY  DATE(billdate) , billdated , matguid , tbMat.code, tbMat.name
-- MSG: An expression of non-boolean type specified in a context where a condition is expected, near 'THEN'.

-- ERROR IN: vwAccoutnSelectNew
CREATE VIEW vwAccoutnSelectNew AS SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note, tbAccount.StartCash AS balance  FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelectNew' in the database.

-- ERROR IN: vwBillBody
CREATE VIEW vwBillBody AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeader ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBody' in the database.

-- ERROR IN: vwProductSalesInSession
CREATE VIEW vwProductSalesInSession AS SELECT b.matguid AS ProductID, m.name AS ProductName, b.qty AS Quantity, b.price AS UnitPrice, (b.qty * b.price) AS TotalPrice, r.uid AS SessionID, r.user AS UserName, r.invoice_num AS InvoiceNumber, r.total AS InvoiceTotal FROM tbBillBodyNew b INNER JOIN cash_drawer_report_new r ON b.parentguid = r.parentGuid INNER JOIN tbMat m ON b.matguid = m.guid
-- MSG: There is already an object named 'vwProductSalesInSession' in the database.

-- ERROR IN: vwBillsFee
CREATE VIEW vwBillsFee AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valin , CAST(0 as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 1 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 2 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 0 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1 ) as valin , 0 as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 3 UNION ALL SELECT tbpay.guid,tbpay.number, 'سند صرف' as billtype, tbpay.paydate as BillDate ,tbpay.paydated as BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbpay.notes as note , tbpay.[amount] as total, tbpay.amount as totalnet, 0 as Extra , 0 as discount , 0 as extraval , 0 as discountval , 0 as valin , CAST(tbpay.amount AS Float) as valout FROM tbpay JOIN tbAccount ON tbpay.accountguid = tbAccount.guid WHERE tbaccount.Code = 3 UNION ALL SELECT tbMaintenance.Guid, tbMaintenance.OrderNo as number, 'صيانة' as billtype ,tbMaintenance.MainDate as BillDate, tbMaintenance.MainDated as BillDateD , tbaccount.code || '-' || tbAccount.name as account, tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbMaintenance.Note , tbMaintenance.Cost as total, tbMaintenance.Cost + tbMaintenance.ExtraVal as Totalnet , 0 as Extra , 0 as discount , tbMaintenance.ExtraVal as extraval , 0 as discountval , tbMaintenance.ExtraVal as valin , CAST(0 as FLOAT) as valout FROM tbMaintenance JOIN tbAccount ON tbMaintenance.accountguid = tbAccount.guid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwDailySellsRAW
CREATE VIEW vwDailySellsRAW AS SELECT tbMat.guid, tbBillHeader.BillDated, tbMat.code || '-' || tbMat.name as mat, SUM(tbBillBodyNew.qty) as Qty , CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) as float) - (Total - TotalNet) as TotalSellPrice, CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) - SUM(tbBillBodyNew.Qty * tbMat.BuyPrice) as float) - (Total - TotalNet) as TotalProfitsOut FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 AND isDelay = 0 GROUP BY tbBillHeader.BillDated ,tbMat.guid,tbMat.code, tbMat.[name]
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.
Column 'tbBillHeader.total' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
Column 'tbBillHeader.totalnet' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatSellsPic
CREATE VIEW vwMatSellsPic AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype ,tbBillheader.BillDate , tbBillheader.BillDated , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount , tbMat.[GroupName], tbMat.[code] as matcode , tbMat.name as matname, tbBillBodyNew.qty , tbBillbodyNew.price , tbBillBodyNew.qty * tbBillbodyNew.price as bodytotal, tbBillBodyNew.note as bodynote , tbPicture.Pic FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwMatSellsPic' in the database.

-- ERROR IN: vwBillBodyNew
CREATE VIEW vwBillBodyNew AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeaderNew ON tbBillBodyNew.parentguid = tbBillHeaderNew.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBodyNew' in the database.

-- ERROR IN: vwMatQtyRaw
CREATE VIEW vwMatQtyRaw AS SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice , 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, tbmat.startQty, SUM(tbmat.StartQtyPrice) as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat WHERE tbMat.IsStartQty = 1 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name]
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillsProfitsRawSell
CREATE VIEW vwBillsProfitsRawSell as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , CASE tbBillHeader.billtype WHEN 1 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) WHEN 3 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) END as SellCost, (100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwBillsProfitsRawBuy
CREATE VIEW vwBillsProfitsRawBuy as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , tbBillBodyNew.Qty* tbBillBodyNew.Price as SellCost ,(100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwMatQtyRawStore
CREATE VIEW vwMatQtyRawStore AS SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty , 0 as StartQtyPrice, 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] ,tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty, 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.Price ) as QtyInPrice , 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbMat.StoreGuid, tbMat.StartQty , tbMat.StartQtyPrice as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbMat.StoreGuid
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBarCodeRptwithTax
CREATE VIEW vwBarCodeRptwithTax AS SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , ROUND(tbMat.SellPrice+(tbMat.SellPrice*(tbMat.FeePercent*0.01)),2) as SellPrice, CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END as CurrentQty, tbMat.BarCode , 0 as Qty FROM tbMat LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRptwithTax' in the database.

-- ERROR IN: vwUserBills
CREATE VIEW vwUserBills AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , CAST(tbBillheader.totalnet as FLOAT) as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 1 OR BillType = 2) UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , 0 as AmountIn , tbBillheader.totalnet as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 0 OR BillType = 3) UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype ,tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 0 UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated ,0 as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 1 UNION ALL SELECT guid, 0 as number , 'صيانة' as billtype, 'نقدي' as paytype , tbMaintenance.MainDate as BillDate ,tbMaintenance.MainDateD as BillDated ,tbMaintenance.Payment as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbMaintenance WHERE tbMaintenance.MainState = 'جاهزة' UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 2 THEN 'تحويل' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 2
-- MSG: There is already an object named 'vwUserBills' in the database.

-- ERROR IN: vwBillPrint
CREATE VIEW vwBillPrint AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' WHEN 4 THEN 'عرض سعر' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype as paytype ,tbBillheader.BillDate , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount ,tbBillheader.extraval, tbBillheader.discountval, tbMat.[code] as matcode, tbMat.[unite] as matunite , tbMat.name as matname, tbBillBodyNew.qty , tbBillBodyNew.price , tbBillBodyNew.qty * tbBillBodyNew.price as bodytotal,tbBillBodyNew.price/100.00*tbBillBodyNew.TaxValue as totalwithtax, tbBillBodyNew.note as bodynote FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwBillPrint' in the database.

-- ERROR IN: vwBills
CREATE VIEW vwBills AS 
SELECT
    tbBillheader.guid,
    tbBillHeader.number, 
    CASE tbBillHeader.billtype
        WHEN 0 THEN 'مشتريات'
        WHEN 1 THEN 'مبيعات'
        WHEN 2 THEN 'مرتجع مشتريات'
        WHEN 3 THEN 'مرتجع مبيعات'
        WHEN 4 THEN 'عرض سعر'
        WHEN 5 THEN 'إدخال'
        WHEN 6 THEN 'إخراج'
    END AS billtype, 
    --إضافة شرط الـ QR Code
   
    tbBillheader.BillDate,
    tbBillheader.BillDated, 
    tbAccount.code || '-' || tbAccount.name AS account,
    tbaccount.Mobile, 
    tbAccount.Email, 
    tbBillHeader.Paytype AS paytype, 
    tbBillheader.[note], 
    tbBillheader.[total], 
    tbBillheader.totalnet,
    COALESCE((SELECT SUM(SellCost) FROM vwBillsProfitsRawSell
              WHERE Number = tbBillHeader.number
              AND(tbBillHeader.billtype = 1 OR tbBillHeader.billtype = 3)), 0.0) AS SellCost,
    CAST(tbBillheader.extra AS FLOAT) AS Extra,
    tbBillheader.discount, 
    tbBillheader.extraval, 
    tbBillheader.discountval,
 CASE
        WHEN tbBillHeader.billtype IN(1, 3) THEN tbBillHeader.qr_code
        ELSE '0'
    END AS qr_code
FROM tbBillHeader
JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid
WHERE tbBillHeader.billtype<> 4
-- MSG: There is already an object named 'vwBills' in the database.

-- ERROR IN: vwPay1
CREATE VIEW vwPay1 AS SELECT tbBillHeader.guid, tbBillHeader.accountguid, tbBillHeader.number, tbBillHeader.billdate ,tbBillHeader.billdated , tbBillHeader.billtype as billtype, tbaccount.code || '-' || tbaccount.name as account, CASE tbBillHeader.billtype WHEN 0 THEN totalnet WHEN 1 THEN 0 END as amountin, CASE tbBillHeader.billtype WHEN 0 THEN 0 WHEN 1 THEN totalnet END as amountout ,tbBillHeader.note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid = tbaccount.guid WHERE tbBillHeader.paytype = 'نقدي' AND tbBillHeader.billtype = 0 ORDER by number
-- MSG: There is already an object named 'vwPay1' in the database.

-- ERROR IN: vwAccountPayments
CREATE VIEW vwAccountPayments AS SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype = 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.00 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=3) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.0 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=0 OR tbBillheader.billtype=3) UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbpay.amount AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=1 UNION ALL SELECT vwPay1.guid,vwPay1.number,'سداد فاتورة مشتريات' AS billtype,'نقدي' AS paytype,vwPay1.billdate,vwPay1.billdated,vwPay1.accountguid,tbAccount.name,tbAccount.AccType,vwPay1.amountout AS amountin,vwPay1.amountin AS amountout,vwPay1.note AS note FROM vwPay1 JOIN tbAccount ON vwPay1.accountguid=tbaccount.guid WHERE paytype='نقدي' UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,tbpay.amount AS amountin,0.0 AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=0 UNION ALL SELECT tbMaintenance.GUID,tbMaintenance.OrderNo AS number,'صيانة' AS billtype,'نقدي' AS paytype,tbMaintenance.MainDate AS paydate,tbMaintenance.MainDateD AS paydated,tbMaintenance.accountguid,tbaccount.Name AS account,tbAccount.AccType,0.0 AS amountin,tbMaintenance.Cost AS amountout,tbMaintenance.Note FROM tbMaintenance JOIN tbAccount ON tbAccount.Guid=tbMaintenance.AccountGuid WHERE tbMaintenance.MainState='جاهزة' UNION ALL SELECT tbaccount.guid,tbaccount.Code AS number,'رصيد إفتتاحي' AS billtype,'نقدي' AS paytype,tbAccount.CashDate AS paydate,tbAccount.CashDateD AS paydated,tbaccount.guid AS accountguid,tbAccount.name,tbAccount.AccType,tbAccount.amountin,tbAccount.amountout,tbAccount.note FROM tbaccount WHERE StartCash=1
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwDailySells
CREATE VIEW vwDailySells AS 
SELECT guid , billdated, mat, SUM(Qty) As Qty , CAST(SUM(TotalSellPrice) as float) as TotalSellPrice ,   CAST(SUM(TotalProfitsOut) as float) as TotalProfits  FROM vwDailySellsRaw
GROUP BY guid , billdated , mat
-- MSG: There is already an object named 'vwDailySells' in the database.

-- ERROR IN: vwBarCodeRpt
CREATE VIEW vwBarCodeRpt AS 
SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , tbMat.SellPrice , CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END  as CurrentQty,  tbMat.BarCode , 0 as Qty FROM tbMat
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRpt' in the database.

-- ERROR IN: vwBillProfitsRAW
CREATE VIEW vwBillProfitsRAW AS 
SELECT Guid as Guid , number, billtype, BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name ,0 as SellCost,   vwBillsProfitsRawBuy.Amount / vwBillsProfitsRawBuy.Qty  as BuyCost , 0 as TotalSellQty , vwBillsProfitsRawBuy.Qty  as TotalBuyQty  , 0 as TotalSell ,  vwBillsProfitsRawBuy.Amount  as TotalBuy  ,  0 as TotalSellCost, SellCost as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell,  0 as  NetBuy , Percentt  as BuyPrecent , 0 as SellPrecent FROM vwBillsProfitsRawBuy 
UNION ALL
SELECT Guid as Guid ,  number,   billtype,BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name , vwBillsProfitsRawSell.Amount  /  vwBillsProfitsRawSell.Qty  as SellCost , 0 as BuyCost ,  vwBillsProfitsRawSell.Qty  as TotalSellQty , 0 as TotalBuyQty , vwBillsProfitsRawSell.Amount  as TotalSell  , 0 as TotalBuy,  SellCost as TotalSellCost, 0 as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell , 0 as NetBuy ,   0 as BuyPrecent ,  Percentt  as SellPrecent FROM vwBillsProfitsRawSell
-- MSG: There is already an object named 'vwBillProfitsRAW' in the database.

-- ERROR IN: vwBillProfitsBills
CREATE VIEW vwBillProfitsBills AS 
SELECT guid, number, billtype , billdate, billdated , SUM(TotalSellCost) as TotalSellCost, SUM(TotalBuyCost) as TotalBuyCost  , SUM(TotalProfits) as TotalProfits from vwBillProfitsBillsRaw
GROUP BY  guid, number, billtype
-- MSG: Column 'vwBillProfitsBillsRaw.billdate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillProfitsBillsRaw
CREATE VIEW vwBillProfitsBillsRaw AS 
SELECT    vwBillProfitsRAW.guid ,vwBillProfitsRAW.Number, vwBillProfitsRAW.billType,  billdate , billdated , matguid , tbMat.code, tbMat.name ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost ,  TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) as  TotalBuyCost ,    TotalSellCost -  (TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) )  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = matguid   WHERE billtype ='مبيعات'
GROUP BY vwBillProfitsRAW.guid  ,vwBillProfitsRAW.Number  ,vwBillProfitsRAW.billType, matguid
-- MSG: Column 'vwBillProfitsRAW.BillDate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatEndDateRaw
CREATE VIEW vwMatEndDateRaw AS 
SELECT tbMat.guid,tbBillHeader.guid as billguid, tbMat.code || '-' || tbMat.Name as mat, SUM(tbBillBody.Qty) as qty , tbBillBody.EndDate FROM tbBillHeader JOIN tbBillBody 
ON tbBillHeader.guid = tbBillBody.ParentGuid 
JOIN tbMat ON tbBillBody.matguid = tbMat.guid 
JOIN vwMatQty ON tbMat.guid = vwMatQty.guid
WHERE (tbBillheader.billtype = 0 OR tbBillheader.billtype = 3) AND vwMatQty.Qty > 0
AND tbBillBody.endDate > ('1913-01-02 00:00:00')
GROUP BY tbMat.guid, tbmat.code, tbBillHeader.guid, tbmat.name, tbBillBody.EndDate
-- MSG: Invalid column name 'endDate'.
Invalid column name 'EndDate'.
Invalid column name 'EndDate'.

-- ERROR IN: vwMatEndDate
CREATE VIEW vwMatEndDate AS 
SELECT Guid,billguid, Mat,SUM(Qty) as Qty ,vwMatEndDateRaw.endDate, Round(julianday(enddate) - julianday('now')) as days, '' as Status FROM vwMatEndDateRaw
GROUP BY guid, Mat,Qty , vwMatEndDateRaw.EndDate,Days 
ORDER BY  guid, billguid, enddate ASC
-- MSG: The round function requires 2 to 3 arguments.

-- ERROR IN: vwAccountsBalance
CREATE VIEW vwAccountsBalance AS 
SELECT guid ,name, acctype , billdated , CAST(SUM(Payin) as FLOAT) as PayIn ,  CAST(SUM(payOut) as FLOAT) as payout, CAST(CAST(SUM(Payin) AS FLOAT) - CAST(SUM(PayOut) as FLOAT) as FLOAT) as balance FROM vwAccountsBalanceRaw
GROUP BY guid,  acctype , name
-- MSG: Column 'vwAccountsBalanceRaw.BillDateD' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwPay
CREATE VIEW vwPay AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate ,tbpay.paydated ,  CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code || '-' || tbaccount.name as account, CASE tbPay.paytype WHEN 0 THEN amount WHEN 1 THEN 0 END as amountin, CASE tbPay.paytype WHEN 0 THEN 0 WHEN 1 THEN amount END as amountout ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE tbpay.PayType = 1 OR tbPay.PayType = 0
ORDER by paydate, number
-- MSG: There is already an object named 'vwPay' in the database.

-- ERROR IN: vwPayPrint
CREATE VIEW vwPayPrint AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate , CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code , tbaccount.name as account, amount ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE paytype = 0 OR PayType = 1
-- MSG: There is already an object named 'vwPayPrint' in the database.

-- ERROR IN: vwBillsDelay
CREATE VIEW vwBillsDelay AS 
SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillheader.BillDate  ,tbBillheader.BillDated  , tbAccount.code|| '-' ||  tbAccount.name  as account,tbaccount.Mobile , tbAccount.Email ,    tbBillHeader.Paytype  as paytype  , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra 
, tbBillheader.discount FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid  WHERE IsDelay = 1
ORDER BY tbBillheader.NUMBER , billdate
-- MSG: There is already an object named 'vwBillsDelay' in the database.

-- ERROR IN: vwService
CREATE VIEW vwService AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwService' in the database.

-- ERROR IN: vwNotify
CREATE VIEW vwNotify AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwNotify' in the database.

-- ERROR IN: vwCash
CREATE VIEW vwCash AS 
SELECT  guid , billtype, billdated , SUM(amountin) as amountin, SUM(amountout) as amountout    FROM vwcashRaw
-- MSG: Column 'vwcashRaw.guid' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatInCash
CREATE VIEW vwMatInCash AS 
SELECT tbMat.Guid,tbMat.GroupName,tbMat.code,tbMat.name,tbMat.BuyPrice,tbMat.SellPrice, tbMat.DiscountVal ,tbMat.DiscountPercent ,   tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent,tbMat.Barcode,tbMat.MinQty,tbMat.MinPrice,tbMat.CurrentQty, tbMat.ShowInCash , tbPicture.Pic FROM tbMat JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid    
WHERE ShowInCash = 1
-- MSG: There is already an object named 'vwMatInCash' in the database.

-- ERROR IN: vwMat
CREATE VIEW vwMat AS  
SELECT tbMat.Guid , tbMat.GroupName , tbMat.Code , tbMat.Name ,tbMat.BuyPrice , tbMat.SellPrice ,tbMat.DiscountVal ,tbMat.DiscountPercent , tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent , tbMat.Barcode , tbMat.MinQty , tbMat.MinPrice , CASE WHEN vwMatQty.qty IS NULL THEN 0 ELSE  vwMatQty.qty END as CurrentQty , tbMat.EndDate , tbMat.ShowInCash FROM tbMat 
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwMat' in the database.

-- ERROR IN: vwMaintenaceBody
CREATE VIEW vwMaintenaceBody AS 
SELECT tbMaintenaceBody.guid, tbMaintenaceBody.matguid, tbMaintenaceBody.parentguid, tbMaintenaceBody.number, tbmat.code || '-' || tbMat.name as mat, tbMaintenaceBody.[qty] , tbMaintenaceBody.[price] , (tbMaintenaceBody.[qty] * tbMaintenaceBody.[price]) as total , tbMaintenaceBody.note   
FROM tbMaintenaceBody JOIN tbMaintenance ON tbMaintenaceBody.parentguid = tbMaintenance.guid 
JOIN tbmat on tbMaintenaceBody.matguid = tbMat.guid ORDER BY tbMaintenaceBody.number
-- MSG: There is already an object named 'vwMaintenaceBody' in the database.

-- ERROR IN: vwAccoutnSelect
CREATE VIEW vwAccoutnSelect AS 
SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note,  CAST( CASE WHEN (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) IS NULL THEN 0 ELSE (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) END as FLOAT) as balance FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelect' in the database.

-- ERROR IN: vwAccountsBalanceRaw
CREATE VIEW vwAccountsBalanceRaw AS 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbBillHeader.BillDateD, 0 as payin,  CAST(tbBillHeader.totalnet as FLOAT) as payout FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2) 
UNION ALL 
SELECT tbAccount.guid, tbaccount.name,  tbAccount.AccType , tbBillHeader.BillDateD, CAST(tbBillHeader.totalnet as FLOAT) as payin, 0 as payout  FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3) 
UNION ALL 
SELECT tbAccount.guid,tbaccount.name,  tbAccount.AccType , tbPay.PayDateD, CAST(tbpay.amount  as FLOAT) as payin,  0 as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 0
UNION ALL 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbPay.PayDateD, 0 as payin, CAST(tbpay.amount as FLOAT) as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 1
UNION ALL 
SELECT tbAccount.guid,tbaccount.name ,  tbAccount.AccType ,  tbMaintenance.MainDateD as paydated,   0 as amountin,  CAST(tbMaintenance.Remain as FLOAT) as amountout  FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL 
SELECT tbaccount.guid ,  tbaccount.name ,  tbAccount.AccType ,tbAccount.CashDateD as paydated,  tbAccount.amountin  ,  tbAccount.amountout    FROM tbaccount WHERE StartCash = 1
-- MSG: There is already an object named 'vwAccountsBalanceRaw' in the database.

-- ERROR IN: vwMaintenance
CREATE VIEW vwMaintenance AS 
SELECT tbMaintenance.GUID  , tbMaintenance.OrderNo ,  tbMaintenance.Model , tbMaintenance.accountguid , tbAccount.Code || '-' || tbaccount.Name as account , tbAccount.Mobile ,   tbMaintenance.Operator , tbMaintenance.MainDate  , tbMaintenance.MainDateD ,tbMaintenance.MainEndDate  , tbMaintenance.MainEndDateD ,      tbMaintenance.Cost,  tbMaintenance.PcCost,   tbMaintenance.Payment , tbMaintenance.Remain,  tbMaintenance.Note ,   tbMaintenance.MainState  , tbMaintenance.UserGuid FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid
-- MSG: There is already an object named 'vwMaintenance' in the database.

-- ERROR IN: vwMatQtyStore
CREATE VIEW vwMatQtyStore AS 
SELECT  guid, storeGuid, mat, SUM(StartQty) as StartQty, SUM(StartQtyPrice)as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice ,  SUM(QtyOut)  as qtyout ,  SUM(QtyOutPrice) as QtyOutPrice,    SUM(StartQty + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRawStore
GROUP BY  guid, storeGuid, mat
-- MSG: There is already an object named 'vwMatQtyStore' in the database.

-- ERROR IN: vwMatQty
CREATE VIEW vwMatQty AS 
SELECT  guid, groupname, mat, SUM(StartQty) as StartQty , SUM(StartQtyPrice) as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice,  SUM(QtyOut)  as qtyout , SUM(QtyOutPrice) as QtyOutPrice,  SUM(StartQty  + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRaw
GROUP BY  guid, groupname, mat
-- MSG: There is already an object named 'vwMatQty' in the database.

-- ERROR IN: vwCashRAW
CREATE VIEW vwCashRAW AS 
SELECT tbBillHeader.guid,  CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] ,   0 as amountin,tbBillheader.[totalnet] as amountout   FROM tbBillHeader
WHERE paytype <> 'آجل' AND isDelay = 0 AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3)  
UNION ALL
SELECT tbBillHeader.guid, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] , tbBillheader.[totalnet] as amountin,0 as amountout  FROM tbBillHeader
WHERE paytype <> 'آجل'  AND isDelay = 0 AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2)
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  0 as amountin, tbpay.amount as amountout   FROM tbPay 
WHERE paytype = 1  
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  tbpay.amount as amountin,  0 as amountout  FROM tbPay 
WHERE paytype = 0
UNION ALL
SELECT tbMaintenance.Guid, 'صيانة' as paytype , tbMaintenance.MainDated as Paydated ,tbMaintenance.Payment as amountin , 0 as amountout   FROM tbMaintenance WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL
SELECT tbaccount.guid , ('رصيد إفتتاحي' || '-' || tbaccount.name) as paytype, tbAccount.CashDateD as paydated,   tbAccount.amountin  ,  tbAccount.amountout   FROM tbaccount WHERE StartCash = 1
UNION ALL 
SELECT tbmat.guid , ('رصيد إبتدائي') as paytype, tbMat.StartDateD as paydated,    0 as  amountin ,    SUM(tbMat.StartQty * tbMat.BuyPrice)  as amountout   FROM tbMat  WHERE tbMat.IsStartQty = 1  GROUP BY paytype
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwBillProfits
CREATE VIEW "vwBillProfits" AS SELECT vwBillProfitsRAW.guid , billdate , billdated , matguid , tbMat.code, tbMat.name , tbMat.GroupName ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost , CASE WHEN (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty)  ELSE (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) END as TotalBuyCost ,  CASE WHEN (SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) ELSE SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty) END  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = vwBillProfitsRAW.matGuid  
GROUP BY  DATE(billdate) , billdated , matguid , tbMat.code, tbMat.name
-- MSG: An expression of non-boolean type specified in a context where a condition is expected, near 'THEN'.

-- ERROR IN: vwAccoutnSelectNew
CREATE VIEW vwAccoutnSelectNew AS SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note, tbAccount.StartCash AS balance  FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelectNew' in the database.

-- ERROR IN: vwBillBody
CREATE VIEW vwBillBody AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeader ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBody' in the database.

-- ERROR IN: vwProductSalesInSession
CREATE VIEW vwProductSalesInSession AS SELECT b.matguid AS ProductID, m.name AS ProductName, b.qty AS Quantity, b.price AS UnitPrice, (b.qty * b.price) AS TotalPrice, r.uid AS SessionID, r.user AS UserName, r.invoice_num AS InvoiceNumber, r.total AS InvoiceTotal FROM tbBillBodyNew b INNER JOIN cash_drawer_report_new r ON b.parentguid = r.parentGuid INNER JOIN tbMat m ON b.matguid = m.guid
-- MSG: There is already an object named 'vwProductSalesInSession' in the database.

-- ERROR IN: vwBillsFee
CREATE VIEW vwBillsFee AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valin , CAST(0 as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 1 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 2 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 0 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1 ) as valin , 0 as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 3 UNION ALL SELECT tbpay.guid,tbpay.number, 'سند صرف' as billtype, tbpay.paydate as BillDate ,tbpay.paydated as BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbpay.notes as note , tbpay.[amount] as total, tbpay.amount as totalnet, 0 as Extra , 0 as discount , 0 as extraval , 0 as discountval , 0 as valin , CAST(tbpay.amount AS Float) as valout FROM tbpay JOIN tbAccount ON tbpay.accountguid = tbAccount.guid WHERE tbaccount.Code = 3 UNION ALL SELECT tbMaintenance.Guid, tbMaintenance.OrderNo as number, 'صيانة' as billtype ,tbMaintenance.MainDate as BillDate, tbMaintenance.MainDated as BillDateD , tbaccount.code || '-' || tbAccount.name as account, tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbMaintenance.Note , tbMaintenance.Cost as total, tbMaintenance.Cost + tbMaintenance.ExtraVal as Totalnet , 0 as Extra , 0 as discount , tbMaintenance.ExtraVal as extraval , 0 as discountval , tbMaintenance.ExtraVal as valin , CAST(0 as FLOAT) as valout FROM tbMaintenance JOIN tbAccount ON tbMaintenance.accountguid = tbAccount.guid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwDailySellsRAW
CREATE VIEW vwDailySellsRAW AS SELECT tbMat.guid, tbBillHeader.BillDated, tbMat.code || '-' || tbMat.name as mat, SUM(tbBillBodyNew.qty) as Qty , CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) as float) - (Total - TotalNet) as TotalSellPrice, CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) - SUM(tbBillBodyNew.Qty * tbMat.BuyPrice) as float) - (Total - TotalNet) as TotalProfitsOut FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 AND isDelay = 0 GROUP BY tbBillHeader.BillDated ,tbMat.guid,tbMat.code, tbMat.[name]
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.
Column 'tbBillHeader.total' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
Column 'tbBillHeader.totalnet' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatSellsPic
CREATE VIEW vwMatSellsPic AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype ,tbBillheader.BillDate , tbBillheader.BillDated , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount , tbMat.[GroupName], tbMat.[code] as matcode , tbMat.name as matname, tbBillBodyNew.qty , tbBillbodyNew.price , tbBillBodyNew.qty * tbBillbodyNew.price as bodytotal, tbBillBodyNew.note as bodynote , tbPicture.Pic FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwMatSellsPic' in the database.

-- ERROR IN: vwBillBodyNew
CREATE VIEW vwBillBodyNew AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeaderNew ON tbBillBodyNew.parentguid = tbBillHeaderNew.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBodyNew' in the database.

-- ERROR IN: vwMatQtyRaw
CREATE VIEW vwMatQtyRaw AS SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice , 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, tbmat.startQty, SUM(tbmat.StartQtyPrice) as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat WHERE tbMat.IsStartQty = 1 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name]
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillsProfitsRawSell
CREATE VIEW vwBillsProfitsRawSell as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , CASE tbBillHeader.billtype WHEN 1 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) WHEN 3 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) END as SellCost, (100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwBillsProfitsRawBuy
CREATE VIEW vwBillsProfitsRawBuy as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , tbBillBodyNew.Qty* tbBillBodyNew.Price as SellCost ,(100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwMatQtyRawStore
CREATE VIEW vwMatQtyRawStore AS SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty , 0 as StartQtyPrice, 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] ,tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty, 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.Price ) as QtyInPrice , 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbMat.StoreGuid, tbMat.StartQty , tbMat.StartQtyPrice as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbMat.StoreGuid
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBarCodeRptwithTax
CREATE VIEW vwBarCodeRptwithTax AS SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , ROUND(tbMat.SellPrice+(tbMat.SellPrice*(tbMat.FeePercent*0.01)),2) as SellPrice, CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END as CurrentQty, tbMat.BarCode , 0 as Qty FROM tbMat LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRptwithTax' in the database.

-- ERROR IN: vwUserBills
CREATE VIEW vwUserBills AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , CAST(tbBillheader.totalnet as FLOAT) as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 1 OR BillType = 2) UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , 0 as AmountIn , tbBillheader.totalnet as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 0 OR BillType = 3) UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype ,tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 0 UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated ,0 as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 1 UNION ALL SELECT guid, 0 as number , 'صيانة' as billtype, 'نقدي' as paytype , tbMaintenance.MainDate as BillDate ,tbMaintenance.MainDateD as BillDated ,tbMaintenance.Payment as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbMaintenance WHERE tbMaintenance.MainState = 'جاهزة' UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 2 THEN 'تحويل' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 2
-- MSG: There is already an object named 'vwUserBills' in the database.

-- ERROR IN: vwBillPrint
CREATE VIEW vwBillPrint AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' WHEN 4 THEN 'عرض سعر' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype as paytype ,tbBillheader.BillDate , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount ,tbBillheader.extraval, tbBillheader.discountval, tbMat.[code] as matcode, tbMat.[unite] as matunite , tbMat.name as matname, tbBillBodyNew.qty , tbBillBodyNew.price , tbBillBodyNew.qty * tbBillBodyNew.price as bodytotal,tbBillBodyNew.price/100.00*tbBillBodyNew.TaxValue as totalwithtax, tbBillBodyNew.note as bodynote FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwBillPrint' in the database.

-- ERROR IN: vwBills
CREATE VIEW vwBills AS 
SELECT
    tbBillheader.guid,
    tbBillHeader.number, 
    CASE tbBillHeader.billtype
        WHEN 0 THEN 'مشتريات'
        WHEN 1 THEN 'مبيعات'
        WHEN 2 THEN 'مرتجع مشتريات'
        WHEN 3 THEN 'مرتجع مبيعات'
        WHEN 4 THEN 'عرض سعر'
        WHEN 5 THEN 'إدخال'
        WHEN 6 THEN 'إخراج'
    END AS billtype, 
    --إضافة شرط الـ QR Code
   
    tbBillheader.BillDate,
    tbBillheader.BillDated, 
    tbAccount.code || '-' || tbAccount.name AS account,
    tbaccount.Mobile, 
    tbAccount.Email, 
    tbBillHeader.Paytype AS paytype, 
    tbBillheader.[note], 
    tbBillheader.[total], 
    tbBillheader.totalnet,
    COALESCE((SELECT SUM(SellCost) FROM vwBillsProfitsRawSell
              WHERE Number = tbBillHeader.number
              AND(tbBillHeader.billtype = 1 OR tbBillHeader.billtype = 3)), 0.0) AS SellCost,
    CAST(tbBillheader.extra AS FLOAT) AS Extra,
    tbBillheader.discount, 
    tbBillheader.extraval, 
    tbBillheader.discountval,
 CASE
        WHEN tbBillHeader.billtype IN(1, 3) THEN tbBillHeader.qr_code
        ELSE '0'
    END AS qr_code
FROM tbBillHeader
JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid
WHERE tbBillHeader.billtype<> 4
-- MSG: There is already an object named 'vwBills' in the database.

-- ERROR IN: vwPay1
CREATE VIEW vwPay1 AS SELECT tbBillHeader.guid, tbBillHeader.accountguid, tbBillHeader.number, tbBillHeader.billdate ,tbBillHeader.billdated , tbBillHeader.billtype as billtype, tbaccount.code || '-' || tbaccount.name as account, CASE tbBillHeader.billtype WHEN 0 THEN totalnet WHEN 1 THEN 0 END as amountin, CASE tbBillHeader.billtype WHEN 0 THEN 0 WHEN 1 THEN totalnet END as amountout ,tbBillHeader.note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid = tbaccount.guid WHERE tbBillHeader.paytype = 'نقدي' AND tbBillHeader.billtype = 0 ORDER by number
-- MSG: There is already an object named 'vwPay1' in the database.

-- ERROR IN: vwAccountPayments
CREATE VIEW vwAccountPayments AS SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype = 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.00 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=3) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.0 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=0 OR tbBillheader.billtype=3) UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbpay.amount AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=1 UNION ALL SELECT vwPay1.guid,vwPay1.number,'سداد فاتورة مشتريات' AS billtype,'نقدي' AS paytype,vwPay1.billdate,vwPay1.billdated,vwPay1.accountguid,tbAccount.name,tbAccount.AccType,vwPay1.amountout AS amountin,vwPay1.amountin AS amountout,vwPay1.note AS note FROM vwPay1 JOIN tbAccount ON vwPay1.accountguid=tbaccount.guid WHERE paytype='نقدي' UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,tbpay.amount AS amountin,0.0 AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=0 UNION ALL SELECT tbMaintenance.GUID,tbMaintenance.OrderNo AS number,'صيانة' AS billtype,'نقدي' AS paytype,tbMaintenance.MainDate AS paydate,tbMaintenance.MainDateD AS paydated,tbMaintenance.accountguid,tbaccount.Name AS account,tbAccount.AccType,0.0 AS amountin,tbMaintenance.Cost AS amountout,tbMaintenance.Note FROM tbMaintenance JOIN tbAccount ON tbAccount.Guid=tbMaintenance.AccountGuid WHERE tbMaintenance.MainState='جاهزة' UNION ALL SELECT tbaccount.guid,tbaccount.Code AS number,'رصيد إفتتاحي' AS billtype,'نقدي' AS paytype,tbAccount.CashDate AS paydate,tbAccount.CashDateD AS paydated,tbaccount.guid AS accountguid,tbAccount.name,tbAccount.AccType,tbAccount.amountin,tbAccount.amountout,tbAccount.note FROM tbaccount WHERE StartCash=1
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwDailySells
CREATE VIEW vwDailySells AS 
SELECT guid , billdated, mat, SUM(Qty) As Qty , CAST(SUM(TotalSellPrice) as float) as TotalSellPrice ,   CAST(SUM(TotalProfitsOut) as float) as TotalProfits  FROM vwDailySellsRaw
GROUP BY guid , billdated , mat
-- MSG: There is already an object named 'vwDailySells' in the database.

-- ERROR IN: vwBarCodeRpt
CREATE VIEW vwBarCodeRpt AS 
SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , tbMat.SellPrice , CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END  as CurrentQty,  tbMat.BarCode , 0 as Qty FROM tbMat
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRpt' in the database.

-- ERROR IN: vwBillProfitsRAW
CREATE VIEW vwBillProfitsRAW AS 
SELECT Guid as Guid , number, billtype, BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name ,0 as SellCost,   vwBillsProfitsRawBuy.Amount / vwBillsProfitsRawBuy.Qty  as BuyCost , 0 as TotalSellQty , vwBillsProfitsRawBuy.Qty  as TotalBuyQty  , 0 as TotalSell ,  vwBillsProfitsRawBuy.Amount  as TotalBuy  ,  0 as TotalSellCost, SellCost as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell,  0 as  NetBuy , Percentt  as BuyPrecent , 0 as SellPrecent FROM vwBillsProfitsRawBuy 
UNION ALL
SELECT Guid as Guid ,  number,   billtype,BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name , vwBillsProfitsRawSell.Amount  /  vwBillsProfitsRawSell.Qty  as SellCost , 0 as BuyCost ,  vwBillsProfitsRawSell.Qty  as TotalSellQty , 0 as TotalBuyQty , vwBillsProfitsRawSell.Amount  as TotalSell  , 0 as TotalBuy,  SellCost as TotalSellCost, 0 as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell , 0 as NetBuy ,   0 as BuyPrecent ,  Percentt  as SellPrecent FROM vwBillsProfitsRawSell
-- MSG: There is already an object named 'vwBillProfitsRAW' in the database.

-- ERROR IN: vwBillProfitsBills
CREATE VIEW vwBillProfitsBills AS 
SELECT guid, number, billtype , billdate, billdated , SUM(TotalSellCost) as TotalSellCost, SUM(TotalBuyCost) as TotalBuyCost  , SUM(TotalProfits) as TotalProfits from vwBillProfitsBillsRaw
GROUP BY  guid, number, billtype
-- MSG: Column 'vwBillProfitsBillsRaw.billdate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillProfitsBillsRaw
CREATE VIEW vwBillProfitsBillsRaw AS 
SELECT    vwBillProfitsRAW.guid ,vwBillProfitsRAW.Number, vwBillProfitsRAW.billType,  billdate , billdated , matguid , tbMat.code, tbMat.name ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost ,  TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) as  TotalBuyCost ,    TotalSellCost -  (TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) )  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = matguid   WHERE billtype ='مبيعات'
GROUP BY vwBillProfitsRAW.guid  ,vwBillProfitsRAW.Number  ,vwBillProfitsRAW.billType, matguid
-- MSG: Column 'vwBillProfitsRAW.BillDate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatEndDateRaw
CREATE VIEW vwMatEndDateRaw AS 
SELECT tbMat.guid,tbBillHeader.guid as billguid, tbMat.code || '-' || tbMat.Name as mat, SUM(tbBillBody.Qty) as qty , tbBillBody.EndDate FROM tbBillHeader JOIN tbBillBody 
ON tbBillHeader.guid = tbBillBody.ParentGuid 
JOIN tbMat ON tbBillBody.matguid = tbMat.guid 
JOIN vwMatQty ON tbMat.guid = vwMatQty.guid
WHERE (tbBillheader.billtype = 0 OR tbBillheader.billtype = 3) AND vwMatQty.Qty > 0
AND tbBillBody.endDate > ('1913-01-02 00:00:00')
GROUP BY tbMat.guid, tbmat.code, tbBillHeader.guid, tbmat.name, tbBillBody.EndDate
-- MSG: Invalid column name 'endDate'.
Invalid column name 'EndDate'.
Invalid column name 'EndDate'.

-- ERROR IN: vwMatEndDate
CREATE VIEW vwMatEndDate AS 
SELECT Guid,billguid, Mat,SUM(Qty) as Qty ,vwMatEndDateRaw.endDate, Round(julianday(enddate) - julianday('now')) as days, '' as Status FROM vwMatEndDateRaw
GROUP BY guid, Mat,Qty , vwMatEndDateRaw.EndDate,Days 
ORDER BY  guid, billguid, enddate ASC
-- MSG: The round function requires 2 to 3 arguments.

-- ERROR IN: vwAccountsBalance
CREATE VIEW vwAccountsBalance AS 
SELECT guid ,name, acctype , billdated , CAST(SUM(Payin) as FLOAT) as PayIn ,  CAST(SUM(payOut) as FLOAT) as payout, CAST(CAST(SUM(Payin) AS FLOAT) - CAST(SUM(PayOut) as FLOAT) as FLOAT) as balance FROM vwAccountsBalanceRaw
GROUP BY guid,  acctype , name
-- MSG: Column 'vwAccountsBalanceRaw.BillDateD' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwPay
CREATE VIEW vwPay AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate ,tbpay.paydated ,  CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code || '-' || tbaccount.name as account, CASE tbPay.paytype WHEN 0 THEN amount WHEN 1 THEN 0 END as amountin, CASE tbPay.paytype WHEN 0 THEN 0 WHEN 1 THEN amount END as amountout ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE tbpay.PayType = 1 OR tbPay.PayType = 0
ORDER by paydate, number
-- MSG: There is already an object named 'vwPay' in the database.

-- ERROR IN: vwPayPrint
CREATE VIEW vwPayPrint AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate , CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code , tbaccount.name as account, amount ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE paytype = 0 OR PayType = 1
-- MSG: There is already an object named 'vwPayPrint' in the database.

-- ERROR IN: vwBillsDelay
CREATE VIEW vwBillsDelay AS 
SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillheader.BillDate  ,tbBillheader.BillDated  , tbAccount.code|| '-' ||  tbAccount.name  as account,tbaccount.Mobile , tbAccount.Email ,    tbBillHeader.Paytype  as paytype  , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra 
, tbBillheader.discount FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid  WHERE IsDelay = 1
ORDER BY tbBillheader.NUMBER , billdate
-- MSG: There is already an object named 'vwBillsDelay' in the database.

-- ERROR IN: vwService
CREATE VIEW vwService AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwService' in the database.

-- ERROR IN: vwNotify
CREATE VIEW vwNotify AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwNotify' in the database.

-- ERROR IN: vwCash
CREATE VIEW vwCash AS 
SELECT  guid , billtype, billdated , SUM(amountin) as amountin, SUM(amountout) as amountout    FROM vwcashRaw
-- MSG: Column 'vwcashRaw.guid' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatInCash
CREATE VIEW vwMatInCash AS 
SELECT tbMat.Guid,tbMat.GroupName,tbMat.code,tbMat.name,tbMat.BuyPrice,tbMat.SellPrice, tbMat.DiscountVal ,tbMat.DiscountPercent ,   tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent,tbMat.Barcode,tbMat.MinQty,tbMat.MinPrice,tbMat.CurrentQty, tbMat.ShowInCash , tbPicture.Pic FROM tbMat JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid    
WHERE ShowInCash = 1
-- MSG: There is already an object named 'vwMatInCash' in the database.

-- ERROR IN: vwMat
CREATE VIEW vwMat AS  
SELECT tbMat.Guid , tbMat.GroupName , tbMat.Code , tbMat.Name ,tbMat.BuyPrice , tbMat.SellPrice ,tbMat.DiscountVal ,tbMat.DiscountPercent , tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent , tbMat.Barcode , tbMat.MinQty , tbMat.MinPrice , CASE WHEN vwMatQty.qty IS NULL THEN 0 ELSE  vwMatQty.qty END as CurrentQty , tbMat.EndDate , tbMat.ShowInCash FROM tbMat 
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwMat' in the database.

-- ERROR IN: vwMaintenaceBody
CREATE VIEW vwMaintenaceBody AS 
SELECT tbMaintenaceBody.guid, tbMaintenaceBody.matguid, tbMaintenaceBody.parentguid, tbMaintenaceBody.number, tbmat.code || '-' || tbMat.name as mat, tbMaintenaceBody.[qty] , tbMaintenaceBody.[price] , (tbMaintenaceBody.[qty] * tbMaintenaceBody.[price]) as total , tbMaintenaceBody.note   
FROM tbMaintenaceBody JOIN tbMaintenance ON tbMaintenaceBody.parentguid = tbMaintenance.guid 
JOIN tbmat on tbMaintenaceBody.matguid = tbMat.guid ORDER BY tbMaintenaceBody.number
-- MSG: There is already an object named 'vwMaintenaceBody' in the database.

-- ERROR IN: vwAccoutnSelect
CREATE VIEW vwAccoutnSelect AS 
SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note,  CAST( CASE WHEN (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) IS NULL THEN 0 ELSE (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) END as FLOAT) as balance FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelect' in the database.

-- ERROR IN: vwAccountsBalanceRaw
CREATE VIEW vwAccountsBalanceRaw AS 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbBillHeader.BillDateD, 0 as payin,  CAST(tbBillHeader.totalnet as FLOAT) as payout FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2) 
UNION ALL 
SELECT tbAccount.guid, tbaccount.name,  tbAccount.AccType , tbBillHeader.BillDateD, CAST(tbBillHeader.totalnet as FLOAT) as payin, 0 as payout  FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3) 
UNION ALL 
SELECT tbAccount.guid,tbaccount.name,  tbAccount.AccType , tbPay.PayDateD, CAST(tbpay.amount  as FLOAT) as payin,  0 as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 0
UNION ALL 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbPay.PayDateD, 0 as payin, CAST(tbpay.amount as FLOAT) as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 1
UNION ALL 
SELECT tbAccount.guid,tbaccount.name ,  tbAccount.AccType ,  tbMaintenance.MainDateD as paydated,   0 as amountin,  CAST(tbMaintenance.Remain as FLOAT) as amountout  FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL 
SELECT tbaccount.guid ,  tbaccount.name ,  tbAccount.AccType ,tbAccount.CashDateD as paydated,  tbAccount.amountin  ,  tbAccount.amountout    FROM tbaccount WHERE StartCash = 1
-- MSG: There is already an object named 'vwAccountsBalanceRaw' in the database.

-- ERROR IN: vwMaintenance
CREATE VIEW vwMaintenance AS 
SELECT tbMaintenance.GUID  , tbMaintenance.OrderNo ,  tbMaintenance.Model , tbMaintenance.accountguid , tbAccount.Code || '-' || tbaccount.Name as account , tbAccount.Mobile ,   tbMaintenance.Operator , tbMaintenance.MainDate  , tbMaintenance.MainDateD ,tbMaintenance.MainEndDate  , tbMaintenance.MainEndDateD ,      tbMaintenance.Cost,  tbMaintenance.PcCost,   tbMaintenance.Payment , tbMaintenance.Remain,  tbMaintenance.Note ,   tbMaintenance.MainState  , tbMaintenance.UserGuid FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid
-- MSG: There is already an object named 'vwMaintenance' in the database.

-- ERROR IN: vwMatQtyStore
CREATE VIEW vwMatQtyStore AS 
SELECT  guid, storeGuid, mat, SUM(StartQty) as StartQty, SUM(StartQtyPrice)as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice ,  SUM(QtyOut)  as qtyout ,  SUM(QtyOutPrice) as QtyOutPrice,    SUM(StartQty + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRawStore
GROUP BY  guid, storeGuid, mat
-- MSG: There is already an object named 'vwMatQtyStore' in the database.

-- ERROR IN: vwMatQty
CREATE VIEW vwMatQty AS 
SELECT  guid, groupname, mat, SUM(StartQty) as StartQty , SUM(StartQtyPrice) as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice,  SUM(QtyOut)  as qtyout , SUM(QtyOutPrice) as QtyOutPrice,  SUM(StartQty  + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRaw
GROUP BY  guid, groupname, mat
-- MSG: There is already an object named 'vwMatQty' in the database.

-- ERROR IN: vwCashRAW
CREATE VIEW vwCashRAW AS 
SELECT tbBillHeader.guid,  CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] ,   0 as amountin,tbBillheader.[totalnet] as amountout   FROM tbBillHeader
WHERE paytype <> 'آجل' AND isDelay = 0 AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3)  
UNION ALL
SELECT tbBillHeader.guid, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] , tbBillheader.[totalnet] as amountin,0 as amountout  FROM tbBillHeader
WHERE paytype <> 'آجل'  AND isDelay = 0 AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2)
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  0 as amountin, tbpay.amount as amountout   FROM tbPay 
WHERE paytype = 1  
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  tbpay.amount as amountin,  0 as amountout  FROM tbPay 
WHERE paytype = 0
UNION ALL
SELECT tbMaintenance.Guid, 'صيانة' as paytype , tbMaintenance.MainDated as Paydated ,tbMaintenance.Payment as amountin , 0 as amountout   FROM tbMaintenance WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL
SELECT tbaccount.guid , ('رصيد إفتتاحي' || '-' || tbaccount.name) as paytype, tbAccount.CashDateD as paydated,   tbAccount.amountin  ,  tbAccount.amountout   FROM tbaccount WHERE StartCash = 1
UNION ALL 
SELECT tbmat.guid , ('رصيد إبتدائي') as paytype, tbMat.StartDateD as paydated,    0 as  amountin ,    SUM(tbMat.StartQty * tbMat.BuyPrice)  as amountout   FROM tbMat  WHERE tbMat.IsStartQty = 1  GROUP BY paytype
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwBillProfits
CREATE VIEW "vwBillProfits" AS SELECT vwBillProfitsRAW.guid , billdate , billdated , matguid , tbMat.code, tbMat.name , tbMat.GroupName ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost , CASE WHEN (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty)  ELSE (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) END as TotalBuyCost ,  CASE WHEN (SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) ELSE SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty) END  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = vwBillProfitsRAW.matGuid  
GROUP BY  DATE(billdate) , billdated , matguid , tbMat.code, tbMat.name
-- MSG: An expression of non-boolean type specified in a context where a condition is expected, near 'THEN'.

-- ERROR IN: vwAccoutnSelectNew
CREATE VIEW vwAccoutnSelectNew AS SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note, tbAccount.StartCash AS balance  FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelectNew' in the database.

-- ERROR IN: vwBillBody
CREATE VIEW vwBillBody AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeader ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBody' in the database.

-- ERROR IN: vwProductSalesInSession
CREATE VIEW vwProductSalesInSession AS SELECT b.matguid AS ProductID, m.name AS ProductName, b.qty AS Quantity, b.price AS UnitPrice, (b.qty * b.price) AS TotalPrice, r.uid AS SessionID, r.user AS UserName, r.invoice_num AS InvoiceNumber, r.total AS InvoiceTotal FROM tbBillBodyNew b INNER JOIN cash_drawer_report_new r ON b.parentguid = r.parentGuid INNER JOIN tbMat m ON b.matguid = m.guid
-- MSG: There is already an object named 'vwProductSalesInSession' in the database.

-- ERROR IN: vwBillsFee
CREATE VIEW vwBillsFee AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valin , CAST(0 as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 1 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 2 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 0 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1 ) as valin , 0 as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 3 UNION ALL SELECT tbpay.guid,tbpay.number, 'سند صرف' as billtype, tbpay.paydate as BillDate ,tbpay.paydated as BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbpay.notes as note , tbpay.[amount] as total, tbpay.amount as totalnet, 0 as Extra , 0 as discount , 0 as extraval , 0 as discountval , 0 as valin , CAST(tbpay.amount AS Float) as valout FROM tbpay JOIN tbAccount ON tbpay.accountguid = tbAccount.guid WHERE tbaccount.Code = 3 UNION ALL SELECT tbMaintenance.Guid, tbMaintenance.OrderNo as number, 'صيانة' as billtype ,tbMaintenance.MainDate as BillDate, tbMaintenance.MainDated as BillDateD , tbaccount.code || '-' || tbAccount.name as account, tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbMaintenance.Note , tbMaintenance.Cost as total, tbMaintenance.Cost + tbMaintenance.ExtraVal as Totalnet , 0 as Extra , 0 as discount , tbMaintenance.ExtraVal as extraval , 0 as discountval , tbMaintenance.ExtraVal as valin , CAST(0 as FLOAT) as valout FROM tbMaintenance JOIN tbAccount ON tbMaintenance.accountguid = tbAccount.guid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwDailySellsRAW
CREATE VIEW vwDailySellsRAW AS SELECT tbMat.guid, tbBillHeader.BillDated, tbMat.code || '-' || tbMat.name as mat, SUM(tbBillBodyNew.qty) as Qty , CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) as float) - (Total - TotalNet) as TotalSellPrice, CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) - SUM(tbBillBodyNew.Qty * tbMat.BuyPrice) as float) - (Total - TotalNet) as TotalProfitsOut FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 AND isDelay = 0 GROUP BY tbBillHeader.BillDated ,tbMat.guid,tbMat.code, tbMat.[name]
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.
Column 'tbBillHeader.total' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
Column 'tbBillHeader.totalnet' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatSellsPic
CREATE VIEW vwMatSellsPic AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype ,tbBillheader.BillDate , tbBillheader.BillDated , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount , tbMat.[GroupName], tbMat.[code] as matcode , tbMat.name as matname, tbBillBodyNew.qty , tbBillbodyNew.price , tbBillBodyNew.qty * tbBillbodyNew.price as bodytotal, tbBillBodyNew.note as bodynote , tbPicture.Pic FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwMatSellsPic' in the database.

-- ERROR IN: vwBillBodyNew
CREATE VIEW vwBillBodyNew AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeaderNew ON tbBillBodyNew.parentguid = tbBillHeaderNew.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBodyNew' in the database.

-- ERROR IN: vwMatQtyRaw
CREATE VIEW vwMatQtyRaw AS SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice , 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, tbmat.startQty, SUM(tbmat.StartQtyPrice) as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat WHERE tbMat.IsStartQty = 1 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name]
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillsProfitsRawSell
CREATE VIEW vwBillsProfitsRawSell as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , CASE tbBillHeader.billtype WHEN 1 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) WHEN 3 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) END as SellCost, (100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwBillsProfitsRawBuy
CREATE VIEW vwBillsProfitsRawBuy as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , tbBillBodyNew.Qty* tbBillBodyNew.Price as SellCost ,(100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwMatQtyRawStore
CREATE VIEW vwMatQtyRawStore AS SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty , 0 as StartQtyPrice, 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] ,tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty, 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.Price ) as QtyInPrice , 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbMat.StoreGuid, tbMat.StartQty , tbMat.StartQtyPrice as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbMat.StoreGuid
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBarCodeRptwithTax
CREATE VIEW vwBarCodeRptwithTax AS SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , ROUND(tbMat.SellPrice+(tbMat.SellPrice*(tbMat.FeePercent*0.01)),2) as SellPrice, CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END as CurrentQty, tbMat.BarCode , 0 as Qty FROM tbMat LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRptwithTax' in the database.

-- ERROR IN: vwUserBills
CREATE VIEW vwUserBills AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , CAST(tbBillheader.totalnet as FLOAT) as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 1 OR BillType = 2) UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , 0 as AmountIn , tbBillheader.totalnet as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 0 OR BillType = 3) UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype ,tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 0 UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated ,0 as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 1 UNION ALL SELECT guid, 0 as number , 'صيانة' as billtype, 'نقدي' as paytype , tbMaintenance.MainDate as BillDate ,tbMaintenance.MainDateD as BillDated ,tbMaintenance.Payment as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbMaintenance WHERE tbMaintenance.MainState = 'جاهزة' UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 2 THEN 'تحويل' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 2
-- MSG: There is already an object named 'vwUserBills' in the database.

-- ERROR IN: vwBillPrint
CREATE VIEW vwBillPrint AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' WHEN 4 THEN 'عرض سعر' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype as paytype ,tbBillheader.BillDate , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount ,tbBillheader.extraval, tbBillheader.discountval, tbMat.[code] as matcode, tbMat.[unite] as matunite , tbMat.name as matname, tbBillBodyNew.qty , tbBillBodyNew.price , tbBillBodyNew.qty * tbBillBodyNew.price as bodytotal,tbBillBodyNew.price/100.00*tbBillBodyNew.TaxValue as totalwithtax, tbBillBodyNew.note as bodynote FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwBillPrint' in the database.

-- ERROR IN: vwBills
CREATE VIEW vwBills AS 
SELECT
    tbBillheader.guid,
    tbBillHeader.number, 
    CASE tbBillHeader.billtype
        WHEN 0 THEN 'مشتريات'
        WHEN 1 THEN 'مبيعات'
        WHEN 2 THEN 'مرتجع مشتريات'
        WHEN 3 THEN 'مرتجع مبيعات'
        WHEN 4 THEN 'عرض سعر'
        WHEN 5 THEN 'إدخال'
        WHEN 6 THEN 'إخراج'
    END AS billtype, 
    --إضافة شرط الـ QR Code
   
    tbBillheader.BillDate,
    tbBillheader.BillDated, 
    tbAccount.code || '-' || tbAccount.name AS account,
    tbaccount.Mobile, 
    tbAccount.Email, 
    tbBillHeader.Paytype AS paytype, 
    tbBillheader.[note], 
    tbBillheader.[total], 
    tbBillheader.totalnet,
    COALESCE((SELECT SUM(SellCost) FROM vwBillsProfitsRawSell
              WHERE Number = tbBillHeader.number
              AND(tbBillHeader.billtype = 1 OR tbBillHeader.billtype = 3)), 0.0) AS SellCost,
    CAST(tbBillheader.extra AS FLOAT) AS Extra,
    tbBillheader.discount, 
    tbBillheader.extraval, 
    tbBillheader.discountval,
 CASE
        WHEN tbBillHeader.billtype IN(1, 3) THEN tbBillHeader.qr_code
        ELSE '0'
    END AS qr_code
FROM tbBillHeader
JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid
WHERE tbBillHeader.billtype<> 4
-- MSG: There is already an object named 'vwBills' in the database.

-- ERROR IN: vwPay1
CREATE VIEW vwPay1 AS SELECT tbBillHeader.guid, tbBillHeader.accountguid, tbBillHeader.number, tbBillHeader.billdate ,tbBillHeader.billdated , tbBillHeader.billtype as billtype, tbaccount.code || '-' || tbaccount.name as account, CASE tbBillHeader.billtype WHEN 0 THEN totalnet WHEN 1 THEN 0 END as amountin, CASE tbBillHeader.billtype WHEN 0 THEN 0 WHEN 1 THEN totalnet END as amountout ,tbBillHeader.note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid = tbaccount.guid WHERE tbBillHeader.paytype = 'نقدي' AND tbBillHeader.billtype = 0 ORDER by number
-- MSG: There is already an object named 'vwPay1' in the database.

-- ERROR IN: vwAccountPayments
CREATE VIEW vwAccountPayments AS SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype = 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.00 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=3) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.0 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=0 OR tbBillheader.billtype=3) UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbpay.amount AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=1 UNION ALL SELECT vwPay1.guid,vwPay1.number,'سداد فاتورة مشتريات' AS billtype,'نقدي' AS paytype,vwPay1.billdate,vwPay1.billdated,vwPay1.accountguid,tbAccount.name,tbAccount.AccType,vwPay1.amountout AS amountin,vwPay1.amountin AS amountout,vwPay1.note AS note FROM vwPay1 JOIN tbAccount ON vwPay1.accountguid=tbaccount.guid WHERE paytype='نقدي' UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,tbpay.amount AS amountin,0.0 AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=0 UNION ALL SELECT tbMaintenance.GUID,tbMaintenance.OrderNo AS number,'صيانة' AS billtype,'نقدي' AS paytype,tbMaintenance.MainDate AS paydate,tbMaintenance.MainDateD AS paydated,tbMaintenance.accountguid,tbaccount.Name AS account,tbAccount.AccType,0.0 AS amountin,tbMaintenance.Cost AS amountout,tbMaintenance.Note FROM tbMaintenance JOIN tbAccount ON tbAccount.Guid=tbMaintenance.AccountGuid WHERE tbMaintenance.MainState='جاهزة' UNION ALL SELECT tbaccount.guid,tbaccount.Code AS number,'رصيد إفتتاحي' AS billtype,'نقدي' AS paytype,tbAccount.CashDate AS paydate,tbAccount.CashDateD AS paydated,tbaccount.guid AS accountguid,tbAccount.name,tbAccount.AccType,tbAccount.amountin,tbAccount.amountout,tbAccount.note FROM tbaccount WHERE StartCash=1
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwDailySells
CREATE VIEW vwDailySells AS 
SELECT guid , billdated, mat, SUM(Qty) As Qty , CAST(SUM(TotalSellPrice) as float) as TotalSellPrice ,   CAST(SUM(TotalProfitsOut) as float) as TotalProfits  FROM vwDailySellsRaw
GROUP BY guid , billdated , mat
-- MSG: There is already an object named 'vwDailySells' in the database.

-- ERROR IN: vwBarCodeRpt
CREATE VIEW vwBarCodeRpt AS 
SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , tbMat.SellPrice , CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END  as CurrentQty,  tbMat.BarCode , 0 as Qty FROM tbMat
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRpt' in the database.

-- ERROR IN: vwBillProfitsRAW
CREATE VIEW vwBillProfitsRAW AS 
SELECT Guid as Guid , number, billtype, BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name ,0 as SellCost,   vwBillsProfitsRawBuy.Amount / vwBillsProfitsRawBuy.Qty  as BuyCost , 0 as TotalSellQty , vwBillsProfitsRawBuy.Qty  as TotalBuyQty  , 0 as TotalSell ,  vwBillsProfitsRawBuy.Amount  as TotalBuy  ,  0 as TotalSellCost, SellCost as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell,  0 as  NetBuy , Percentt  as BuyPrecent , 0 as SellPrecent FROM vwBillsProfitsRawBuy 
UNION ALL
SELECT Guid as Guid ,  number,   billtype,BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name , vwBillsProfitsRawSell.Amount  /  vwBillsProfitsRawSell.Qty  as SellCost , 0 as BuyCost ,  vwBillsProfitsRawSell.Qty  as TotalSellQty , 0 as TotalBuyQty , vwBillsProfitsRawSell.Amount  as TotalSell  , 0 as TotalBuy,  SellCost as TotalSellCost, 0 as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell , 0 as NetBuy ,   0 as BuyPrecent ,  Percentt  as SellPrecent FROM vwBillsProfitsRawSell
-- MSG: There is already an object named 'vwBillProfitsRAW' in the database.

-- ERROR IN: vwBillProfitsBills
CREATE VIEW vwBillProfitsBills AS 
SELECT guid, number, billtype , billdate, billdated , SUM(TotalSellCost) as TotalSellCost, SUM(TotalBuyCost) as TotalBuyCost  , SUM(TotalProfits) as TotalProfits from vwBillProfitsBillsRaw
GROUP BY  guid, number, billtype
-- MSG: Column 'vwBillProfitsBillsRaw.billdate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillProfitsBillsRaw
CREATE VIEW vwBillProfitsBillsRaw AS 
SELECT    vwBillProfitsRAW.guid ,vwBillProfitsRAW.Number, vwBillProfitsRAW.billType,  billdate , billdated , matguid , tbMat.code, tbMat.name ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost ,  TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) as  TotalBuyCost ,    TotalSellCost -  (TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) )  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = matguid   WHERE billtype ='مبيعات'
GROUP BY vwBillProfitsRAW.guid  ,vwBillProfitsRAW.Number  ,vwBillProfitsRAW.billType, matguid
-- MSG: Column 'vwBillProfitsRAW.BillDate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatEndDateRaw
CREATE VIEW vwMatEndDateRaw AS 
SELECT tbMat.guid,tbBillHeader.guid as billguid, tbMat.code || '-' || tbMat.Name as mat, SUM(tbBillBody.Qty) as qty , tbBillBody.EndDate FROM tbBillHeader JOIN tbBillBody 
ON tbBillHeader.guid = tbBillBody.ParentGuid 
JOIN tbMat ON tbBillBody.matguid = tbMat.guid 
JOIN vwMatQty ON tbMat.guid = vwMatQty.guid
WHERE (tbBillheader.billtype = 0 OR tbBillheader.billtype = 3) AND vwMatQty.Qty > 0
AND tbBillBody.endDate > ('1913-01-02 00:00:00')
GROUP BY tbMat.guid, tbmat.code, tbBillHeader.guid, tbmat.name, tbBillBody.EndDate
-- MSG: Invalid column name 'endDate'.
Invalid column name 'EndDate'.
Invalid column name 'EndDate'.

-- ERROR IN: vwMatEndDate
CREATE VIEW vwMatEndDate AS 
SELECT Guid,billguid, Mat,SUM(Qty) as Qty ,vwMatEndDateRaw.endDate, Round(julianday(enddate) - julianday('now')) as days, '' as Status FROM vwMatEndDateRaw
GROUP BY guid, Mat,Qty , vwMatEndDateRaw.EndDate,Days 
ORDER BY  guid, billguid, enddate ASC
-- MSG: The round function requires 2 to 3 arguments.

-- ERROR IN: vwAccountsBalance
CREATE VIEW vwAccountsBalance AS 
SELECT guid ,name, acctype , billdated , CAST(SUM(Payin) as FLOAT) as PayIn ,  CAST(SUM(payOut) as FLOAT) as payout, CAST(CAST(SUM(Payin) AS FLOAT) - CAST(SUM(PayOut) as FLOAT) as FLOAT) as balance FROM vwAccountsBalanceRaw
GROUP BY guid,  acctype , name
-- MSG: Column 'vwAccountsBalanceRaw.BillDateD' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwPay
CREATE VIEW vwPay AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate ,tbpay.paydated ,  CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code || '-' || tbaccount.name as account, CASE tbPay.paytype WHEN 0 THEN amount WHEN 1 THEN 0 END as amountin, CASE tbPay.paytype WHEN 0 THEN 0 WHEN 1 THEN amount END as amountout ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE tbpay.PayType = 1 OR tbPay.PayType = 0
ORDER by paydate, number
-- MSG: There is already an object named 'vwPay' in the database.

-- ERROR IN: vwPayPrint
CREATE VIEW vwPayPrint AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate , CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code , tbaccount.name as account, amount ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE paytype = 0 OR PayType = 1
-- MSG: There is already an object named 'vwPayPrint' in the database.

-- ERROR IN: vwBillsDelay
CREATE VIEW vwBillsDelay AS 
SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillheader.BillDate  ,tbBillheader.BillDated  , tbAccount.code|| '-' ||  tbAccount.name  as account,tbaccount.Mobile , tbAccount.Email ,    tbBillHeader.Paytype  as paytype  , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra 
, tbBillheader.discount FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid  WHERE IsDelay = 1
ORDER BY tbBillheader.NUMBER , billdate
-- MSG: There is already an object named 'vwBillsDelay' in the database.

-- ERROR IN: vwService
CREATE VIEW vwService AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwService' in the database.

-- ERROR IN: vwNotify
CREATE VIEW vwNotify AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwNotify' in the database.

-- ERROR IN: vwCash
CREATE VIEW vwCash AS 
SELECT  guid , billtype, billdated , SUM(amountin) as amountin, SUM(amountout) as amountout    FROM vwcashRaw
-- MSG: Column 'vwcashRaw.guid' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatInCash
CREATE VIEW vwMatInCash AS 
SELECT tbMat.Guid,tbMat.GroupName,tbMat.code,tbMat.name,tbMat.BuyPrice,tbMat.SellPrice, tbMat.DiscountVal ,tbMat.DiscountPercent ,   tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent,tbMat.Barcode,tbMat.MinQty,tbMat.MinPrice,tbMat.CurrentQty, tbMat.ShowInCash , tbPicture.Pic FROM tbMat JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid    
WHERE ShowInCash = 1
-- MSG: There is already an object named 'vwMatInCash' in the database.

-- ERROR IN: vwMat
CREATE VIEW vwMat AS  
SELECT tbMat.Guid , tbMat.GroupName , tbMat.Code , tbMat.Name ,tbMat.BuyPrice , tbMat.SellPrice ,tbMat.DiscountVal ,tbMat.DiscountPercent , tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent , tbMat.Barcode , tbMat.MinQty , tbMat.MinPrice , CASE WHEN vwMatQty.qty IS NULL THEN 0 ELSE  vwMatQty.qty END as CurrentQty , tbMat.EndDate , tbMat.ShowInCash FROM tbMat 
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwMat' in the database.

-- ERROR IN: vwMaintenaceBody
CREATE VIEW vwMaintenaceBody AS 
SELECT tbMaintenaceBody.guid, tbMaintenaceBody.matguid, tbMaintenaceBody.parentguid, tbMaintenaceBody.number, tbmat.code || '-' || tbMat.name as mat, tbMaintenaceBody.[qty] , tbMaintenaceBody.[price] , (tbMaintenaceBody.[qty] * tbMaintenaceBody.[price]) as total , tbMaintenaceBody.note   
FROM tbMaintenaceBody JOIN tbMaintenance ON tbMaintenaceBody.parentguid = tbMaintenance.guid 
JOIN tbmat on tbMaintenaceBody.matguid = tbMat.guid ORDER BY tbMaintenaceBody.number
-- MSG: There is already an object named 'vwMaintenaceBody' in the database.

-- ERROR IN: vwAccoutnSelect
CREATE VIEW vwAccoutnSelect AS 
SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note,  CAST( CASE WHEN (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) IS NULL THEN 0 ELSE (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) END as FLOAT) as balance FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelect' in the database.

-- ERROR IN: vwAccountsBalanceRaw
CREATE VIEW vwAccountsBalanceRaw AS 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbBillHeader.BillDateD, 0 as payin,  CAST(tbBillHeader.totalnet as FLOAT) as payout FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2) 
UNION ALL 
SELECT tbAccount.guid, tbaccount.name,  tbAccount.AccType , tbBillHeader.BillDateD, CAST(tbBillHeader.totalnet as FLOAT) as payin, 0 as payout  FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3) 
UNION ALL 
SELECT tbAccount.guid,tbaccount.name,  tbAccount.AccType , tbPay.PayDateD, CAST(tbpay.amount  as FLOAT) as payin,  0 as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 0
UNION ALL 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbPay.PayDateD, 0 as payin, CAST(tbpay.amount as FLOAT) as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 1
UNION ALL 
SELECT tbAccount.guid,tbaccount.name ,  tbAccount.AccType ,  tbMaintenance.MainDateD as paydated,   0 as amountin,  CAST(tbMaintenance.Remain as FLOAT) as amountout  FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL 
SELECT tbaccount.guid ,  tbaccount.name ,  tbAccount.AccType ,tbAccount.CashDateD as paydated,  tbAccount.amountin  ,  tbAccount.amountout    FROM tbaccount WHERE StartCash = 1
-- MSG: There is already an object named 'vwAccountsBalanceRaw' in the database.

-- ERROR IN: vwMaintenance
CREATE VIEW vwMaintenance AS 
SELECT tbMaintenance.GUID  , tbMaintenance.OrderNo ,  tbMaintenance.Model , tbMaintenance.accountguid , tbAccount.Code || '-' || tbaccount.Name as account , tbAccount.Mobile ,   tbMaintenance.Operator , tbMaintenance.MainDate  , tbMaintenance.MainDateD ,tbMaintenance.MainEndDate  , tbMaintenance.MainEndDateD ,      tbMaintenance.Cost,  tbMaintenance.PcCost,   tbMaintenance.Payment , tbMaintenance.Remain,  tbMaintenance.Note ,   tbMaintenance.MainState  , tbMaintenance.UserGuid FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid
-- MSG: There is already an object named 'vwMaintenance' in the database.

-- ERROR IN: vwMatQtyStore
CREATE VIEW vwMatQtyStore AS 
SELECT  guid, storeGuid, mat, SUM(StartQty) as StartQty, SUM(StartQtyPrice)as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice ,  SUM(QtyOut)  as qtyout ,  SUM(QtyOutPrice) as QtyOutPrice,    SUM(StartQty + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRawStore
GROUP BY  guid, storeGuid, mat
-- MSG: There is already an object named 'vwMatQtyStore' in the database.

-- ERROR IN: vwMatQty
CREATE VIEW vwMatQty AS 
SELECT  guid, groupname, mat, SUM(StartQty) as StartQty , SUM(StartQtyPrice) as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice,  SUM(QtyOut)  as qtyout , SUM(QtyOutPrice) as QtyOutPrice,  SUM(StartQty  + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRaw
GROUP BY  guid, groupname, mat
-- MSG: There is already an object named 'vwMatQty' in the database.

-- ERROR IN: vwCashRAW
CREATE VIEW vwCashRAW AS 
SELECT tbBillHeader.guid,  CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] ,   0 as amountin,tbBillheader.[totalnet] as amountout   FROM tbBillHeader
WHERE paytype <> 'آجل' AND isDelay = 0 AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3)  
UNION ALL
SELECT tbBillHeader.guid, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] , tbBillheader.[totalnet] as amountin,0 as amountout  FROM tbBillHeader
WHERE paytype <> 'آجل'  AND isDelay = 0 AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2)
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  0 as amountin, tbpay.amount as amountout   FROM tbPay 
WHERE paytype = 1  
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  tbpay.amount as amountin,  0 as amountout  FROM tbPay 
WHERE paytype = 0
UNION ALL
SELECT tbMaintenance.Guid, 'صيانة' as paytype , tbMaintenance.MainDated as Paydated ,tbMaintenance.Payment as amountin , 0 as amountout   FROM tbMaintenance WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL
SELECT tbaccount.guid , ('رصيد إفتتاحي' || '-' || tbaccount.name) as paytype, tbAccount.CashDateD as paydated,   tbAccount.amountin  ,  tbAccount.amountout   FROM tbaccount WHERE StartCash = 1
UNION ALL 
SELECT tbmat.guid , ('رصيد إبتدائي') as paytype, tbMat.StartDateD as paydated,    0 as  amountin ,    SUM(tbMat.StartQty * tbMat.BuyPrice)  as amountout   FROM tbMat  WHERE tbMat.IsStartQty = 1  GROUP BY paytype
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwBillProfits
CREATE VIEW "vwBillProfits" AS SELECT vwBillProfitsRAW.guid , billdate , billdated , matguid , tbMat.code, tbMat.name , tbMat.GroupName ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost , CASE WHEN (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty)  ELSE (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) END as TotalBuyCost ,  CASE WHEN (SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) ELSE SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty) END  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = vwBillProfitsRAW.matGuid  
GROUP BY  DATE(billdate) , billdated , matguid , tbMat.code, tbMat.name
-- MSG: An expression of non-boolean type specified in a context where a condition is expected, near 'THEN'.

-- ERROR IN: vwAccoutnSelectNew
CREATE VIEW vwAccoutnSelectNew AS SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note, tbAccount.StartCash AS balance  FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelectNew' in the database.

-- ERROR IN: vwBillBody
CREATE VIEW vwBillBody AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeader ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBody' in the database.

-- ERROR IN: vwProductSalesInSession
CREATE VIEW vwProductSalesInSession AS SELECT b.matguid AS ProductID, m.name AS ProductName, b.qty AS Quantity, b.price AS UnitPrice, (b.qty * b.price) AS TotalPrice, r.uid AS SessionID, r.user AS UserName, r.invoice_num AS InvoiceNumber, r.total AS InvoiceTotal FROM tbBillBodyNew b INNER JOIN cash_drawer_report_new r ON b.parentguid = r.parentGuid INNER JOIN tbMat m ON b.matguid = m.guid
-- MSG: There is already an object named 'vwProductSalesInSession' in the database.

-- ERROR IN: vwBillsFee
CREATE VIEW vwBillsFee AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valin , CAST(0 as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 1 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 2 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 0 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1 ) as valin , 0 as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 3 UNION ALL SELECT tbpay.guid,tbpay.number, 'سند صرف' as billtype, tbpay.paydate as BillDate ,tbpay.paydated as BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbpay.notes as note , tbpay.[amount] as total, tbpay.amount as totalnet, 0 as Extra , 0 as discount , 0 as extraval , 0 as discountval , 0 as valin , CAST(tbpay.amount AS Float) as valout FROM tbpay JOIN tbAccount ON tbpay.accountguid = tbAccount.guid WHERE tbaccount.Code = 3 UNION ALL SELECT tbMaintenance.Guid, tbMaintenance.OrderNo as number, 'صيانة' as billtype ,tbMaintenance.MainDate as BillDate, tbMaintenance.MainDated as BillDateD , tbaccount.code || '-' || tbAccount.name as account, tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbMaintenance.Note , tbMaintenance.Cost as total, tbMaintenance.Cost + tbMaintenance.ExtraVal as Totalnet , 0 as Extra , 0 as discount , tbMaintenance.ExtraVal as extraval , 0 as discountval , tbMaintenance.ExtraVal as valin , CAST(0 as FLOAT) as valout FROM tbMaintenance JOIN tbAccount ON tbMaintenance.accountguid = tbAccount.guid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwDailySellsRAW
CREATE VIEW vwDailySellsRAW AS SELECT tbMat.guid, tbBillHeader.BillDated, tbMat.code || '-' || tbMat.name as mat, SUM(tbBillBodyNew.qty) as Qty , CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) as float) - (Total - TotalNet) as TotalSellPrice, CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) - SUM(tbBillBodyNew.Qty * tbMat.BuyPrice) as float) - (Total - TotalNet) as TotalProfitsOut FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 AND isDelay = 0 GROUP BY tbBillHeader.BillDated ,tbMat.guid,tbMat.code, tbMat.[name]
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.
Column 'tbBillHeader.total' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
Column 'tbBillHeader.totalnet' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatSellsPic
CREATE VIEW vwMatSellsPic AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype ,tbBillheader.BillDate , tbBillheader.BillDated , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount , tbMat.[GroupName], tbMat.[code] as matcode , tbMat.name as matname, tbBillBodyNew.qty , tbBillbodyNew.price , tbBillBodyNew.qty * tbBillbodyNew.price as bodytotal, tbBillBodyNew.note as bodynote , tbPicture.Pic FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwMatSellsPic' in the database.

-- ERROR IN: vwBillBodyNew
CREATE VIEW vwBillBodyNew AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeaderNew ON tbBillBodyNew.parentguid = tbBillHeaderNew.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBodyNew' in the database.

-- ERROR IN: vwMatQtyRaw
CREATE VIEW vwMatQtyRaw AS SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice , 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, tbmat.startQty, SUM(tbmat.StartQtyPrice) as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat WHERE tbMat.IsStartQty = 1 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name]
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillsProfitsRawSell
CREATE VIEW vwBillsProfitsRawSell as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , CASE tbBillHeader.billtype WHEN 1 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) WHEN 3 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) END as SellCost, (100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwBillsProfitsRawBuy
CREATE VIEW vwBillsProfitsRawBuy as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , tbBillBodyNew.Qty* tbBillBodyNew.Price as SellCost ,(100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwMatQtyRawStore
CREATE VIEW vwMatQtyRawStore AS SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty , 0 as StartQtyPrice, 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] ,tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty, 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.Price ) as QtyInPrice , 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbMat.StoreGuid, tbMat.StartQty , tbMat.StartQtyPrice as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbMat.StoreGuid
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBarCodeRptwithTax
CREATE VIEW vwBarCodeRptwithTax AS SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , ROUND(tbMat.SellPrice+(tbMat.SellPrice*(tbMat.FeePercent*0.01)),2) as SellPrice, CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END as CurrentQty, tbMat.BarCode , 0 as Qty FROM tbMat LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRptwithTax' in the database.

-- ERROR IN: vwUserBills
CREATE VIEW vwUserBills AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , CAST(tbBillheader.totalnet as FLOAT) as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 1 OR BillType = 2) UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , 0 as AmountIn , tbBillheader.totalnet as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 0 OR BillType = 3) UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype ,tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 0 UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated ,0 as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 1 UNION ALL SELECT guid, 0 as number , 'صيانة' as billtype, 'نقدي' as paytype , tbMaintenance.MainDate as BillDate ,tbMaintenance.MainDateD as BillDated ,tbMaintenance.Payment as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbMaintenance WHERE tbMaintenance.MainState = 'جاهزة' UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 2 THEN 'تحويل' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 2
-- MSG: There is already an object named 'vwUserBills' in the database.

-- ERROR IN: vwBillPrint
CREATE VIEW vwBillPrint AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' WHEN 4 THEN 'عرض سعر' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype as paytype ,tbBillheader.BillDate , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount ,tbBillheader.extraval, tbBillheader.discountval, tbMat.[code] as matcode, tbMat.[unite] as matunite , tbMat.name as matname, tbBillBodyNew.qty , tbBillBodyNew.price , tbBillBodyNew.qty * tbBillBodyNew.price as bodytotal,tbBillBodyNew.price/100.00*tbBillBodyNew.TaxValue as totalwithtax, tbBillBodyNew.note as bodynote FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwBillPrint' in the database.

-- ERROR IN: vwBills
CREATE VIEW vwBills AS 
SELECT
    tbBillheader.guid,
    tbBillHeader.number, 
    CASE tbBillHeader.billtype
        WHEN 0 THEN 'مشتريات'
        WHEN 1 THEN 'مبيعات'
        WHEN 2 THEN 'مرتجع مشتريات'
        WHEN 3 THEN 'مرتجع مبيعات'
        WHEN 4 THEN 'عرض سعر'
        WHEN 5 THEN 'إدخال'
        WHEN 6 THEN 'إخراج'
    END AS billtype, 
    --إضافة شرط الـ QR Code
   
    tbBillheader.BillDate,
    tbBillheader.BillDated, 
    tbAccount.code || '-' || tbAccount.name AS account,
    tbaccount.Mobile, 
    tbAccount.Email, 
    tbBillHeader.Paytype AS paytype, 
    tbBillheader.[note], 
    tbBillheader.[total], 
    tbBillheader.totalnet,
    COALESCE((SELECT SUM(SellCost) FROM vwBillsProfitsRawSell
              WHERE Number = tbBillHeader.number
              AND(tbBillHeader.billtype = 1 OR tbBillHeader.billtype = 3)), 0.0) AS SellCost,
    CAST(tbBillheader.extra AS FLOAT) AS Extra,
    tbBillheader.discount, 
    tbBillheader.extraval, 
    tbBillheader.discountval,
 CASE
        WHEN tbBillHeader.billtype IN(1, 3) THEN tbBillHeader.qr_code
        ELSE '0'
    END AS qr_code
FROM tbBillHeader
JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid
WHERE tbBillHeader.billtype<> 4
-- MSG: There is already an object named 'vwBills' in the database.

-- ERROR IN: vwPay1
CREATE VIEW vwPay1 AS SELECT tbBillHeader.guid, tbBillHeader.accountguid, tbBillHeader.number, tbBillHeader.billdate ,tbBillHeader.billdated , tbBillHeader.billtype as billtype, tbaccount.code || '-' || tbaccount.name as account, CASE tbBillHeader.billtype WHEN 0 THEN totalnet WHEN 1 THEN 0 END as amountin, CASE tbBillHeader.billtype WHEN 0 THEN 0 WHEN 1 THEN totalnet END as amountout ,tbBillHeader.note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid = tbaccount.guid WHERE tbBillHeader.paytype = 'نقدي' AND tbBillHeader.billtype = 0 ORDER by number
-- MSG: There is already an object named 'vwPay1' in the database.

-- ERROR IN: vwAccountPayments
CREATE VIEW vwAccountPayments AS SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype = 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.00 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=3) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.0 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=0 OR tbBillheader.billtype=3) UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbpay.amount AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=1 UNION ALL SELECT vwPay1.guid,vwPay1.number,'سداد فاتورة مشتريات' AS billtype,'نقدي' AS paytype,vwPay1.billdate,vwPay1.billdated,vwPay1.accountguid,tbAccount.name,tbAccount.AccType,vwPay1.amountout AS amountin,vwPay1.amountin AS amountout,vwPay1.note AS note FROM vwPay1 JOIN tbAccount ON vwPay1.accountguid=tbaccount.guid WHERE paytype='نقدي' UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,tbpay.amount AS amountin,0.0 AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=0 UNION ALL SELECT tbMaintenance.GUID,tbMaintenance.OrderNo AS number,'صيانة' AS billtype,'نقدي' AS paytype,tbMaintenance.MainDate AS paydate,tbMaintenance.MainDateD AS paydated,tbMaintenance.accountguid,tbaccount.Name AS account,tbAccount.AccType,0.0 AS amountin,tbMaintenance.Cost AS amountout,tbMaintenance.Note FROM tbMaintenance JOIN tbAccount ON tbAccount.Guid=tbMaintenance.AccountGuid WHERE tbMaintenance.MainState='جاهزة' UNION ALL SELECT tbaccount.guid,tbaccount.Code AS number,'رصيد إفتتاحي' AS billtype,'نقدي' AS paytype,tbAccount.CashDate AS paydate,tbAccount.CashDateD AS paydated,tbaccount.guid AS accountguid,tbAccount.name,tbAccount.AccType,tbAccount.amountin,tbAccount.amountout,tbAccount.note FROM tbaccount WHERE StartCash=1
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwDailySells
CREATE VIEW vwDailySells AS 
SELECT guid , billdated, mat, SUM(Qty) As Qty , CAST(SUM(TotalSellPrice) as float) as TotalSellPrice ,   CAST(SUM(TotalProfitsOut) as float) as TotalProfits  FROM vwDailySellsRaw
GROUP BY guid , billdated , mat
-- MSG: There is already an object named 'vwDailySells' in the database.

-- ERROR IN: vwBarCodeRpt
CREATE VIEW vwBarCodeRpt AS 
SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , tbMat.SellPrice , CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END  as CurrentQty,  tbMat.BarCode , 0 as Qty FROM tbMat
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRpt' in the database.

-- ERROR IN: vwBillProfitsRAW
CREATE VIEW vwBillProfitsRAW AS 
SELECT Guid as Guid , number, billtype, BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name ,0 as SellCost,   vwBillsProfitsRawBuy.Amount / vwBillsProfitsRawBuy.Qty  as BuyCost , 0 as TotalSellQty , vwBillsProfitsRawBuy.Qty  as TotalBuyQty  , 0 as TotalSell ,  vwBillsProfitsRawBuy.Amount  as TotalBuy  ,  0 as TotalSellCost, SellCost as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell,  0 as  NetBuy , Percentt  as BuyPrecent , 0 as SellPrecent FROM vwBillsProfitsRawBuy 
UNION ALL
SELECT Guid as Guid ,  number,   billtype,BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name , vwBillsProfitsRawSell.Amount  /  vwBillsProfitsRawSell.Qty  as SellCost , 0 as BuyCost ,  vwBillsProfitsRawSell.Qty  as TotalSellQty , 0 as TotalBuyQty , vwBillsProfitsRawSell.Amount  as TotalSell  , 0 as TotalBuy,  SellCost as TotalSellCost, 0 as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell , 0 as NetBuy ,   0 as BuyPrecent ,  Percentt  as SellPrecent FROM vwBillsProfitsRawSell
-- MSG: There is already an object named 'vwBillProfitsRAW' in the database.

-- ERROR IN: vwBillProfitsBills
CREATE VIEW vwBillProfitsBills AS 
SELECT guid, number, billtype , billdate, billdated , SUM(TotalSellCost) as TotalSellCost, SUM(TotalBuyCost) as TotalBuyCost  , SUM(TotalProfits) as TotalProfits from vwBillProfitsBillsRaw
GROUP BY  guid, number, billtype
-- MSG: Column 'vwBillProfitsBillsRaw.billdate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillProfitsBillsRaw
CREATE VIEW vwBillProfitsBillsRaw AS 
SELECT    vwBillProfitsRAW.guid ,vwBillProfitsRAW.Number, vwBillProfitsRAW.billType,  billdate , billdated , matguid , tbMat.code, tbMat.name ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost ,  TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) as  TotalBuyCost ,    TotalSellCost -  (TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) )  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = matguid   WHERE billtype ='مبيعات'
GROUP BY vwBillProfitsRAW.guid  ,vwBillProfitsRAW.Number  ,vwBillProfitsRAW.billType, matguid
-- MSG: Column 'vwBillProfitsRAW.BillDate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatEndDateRaw
CREATE VIEW vwMatEndDateRaw AS 
SELECT tbMat.guid,tbBillHeader.guid as billguid, tbMat.code || '-' || tbMat.Name as mat, SUM(tbBillBody.Qty) as qty , tbBillBody.EndDate FROM tbBillHeader JOIN tbBillBody 
ON tbBillHeader.guid = tbBillBody.ParentGuid 
JOIN tbMat ON tbBillBody.matguid = tbMat.guid 
JOIN vwMatQty ON tbMat.guid = vwMatQty.guid
WHERE (tbBillheader.billtype = 0 OR tbBillheader.billtype = 3) AND vwMatQty.Qty > 0
AND tbBillBody.endDate > ('1913-01-02 00:00:00')
GROUP BY tbMat.guid, tbmat.code, tbBillHeader.guid, tbmat.name, tbBillBody.EndDate
-- MSG: Invalid column name 'endDate'.
Invalid column name 'EndDate'.
Invalid column name 'EndDate'.

-- ERROR IN: vwMatEndDate
CREATE VIEW vwMatEndDate AS 
SELECT Guid,billguid, Mat,SUM(Qty) as Qty ,vwMatEndDateRaw.endDate, Round(julianday(enddate) - julianday('now')) as days, '' as Status FROM vwMatEndDateRaw
GROUP BY guid, Mat,Qty , vwMatEndDateRaw.EndDate,Days 
ORDER BY  guid, billguid, enddate ASC
-- MSG: The round function requires 2 to 3 arguments.

-- ERROR IN: vwAccountsBalance
CREATE VIEW vwAccountsBalance AS 
SELECT guid ,name, acctype , billdated , CAST(SUM(Payin) as FLOAT) as PayIn ,  CAST(SUM(payOut) as FLOAT) as payout, CAST(CAST(SUM(Payin) AS FLOAT) - CAST(SUM(PayOut) as FLOAT) as FLOAT) as balance FROM vwAccountsBalanceRaw
GROUP BY guid,  acctype , name
-- MSG: Column 'vwAccountsBalanceRaw.BillDateD' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwPay
CREATE VIEW vwPay AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate ,tbpay.paydated ,  CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code || '-' || tbaccount.name as account, CASE tbPay.paytype WHEN 0 THEN amount WHEN 1 THEN 0 END as amountin, CASE tbPay.paytype WHEN 0 THEN 0 WHEN 1 THEN amount END as amountout ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE tbpay.PayType = 1 OR tbPay.PayType = 0
ORDER by paydate, number
-- MSG: There is already an object named 'vwPay' in the database.

-- ERROR IN: vwPayPrint
CREATE VIEW vwPayPrint AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate , CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code , tbaccount.name as account, amount ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE paytype = 0 OR PayType = 1
-- MSG: There is already an object named 'vwPayPrint' in the database.

-- ERROR IN: vwBillsDelay
CREATE VIEW vwBillsDelay AS 
SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillheader.BillDate  ,tbBillheader.BillDated  , tbAccount.code|| '-' ||  tbAccount.name  as account,tbaccount.Mobile , tbAccount.Email ,    tbBillHeader.Paytype  as paytype  , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra 
, tbBillheader.discount FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid  WHERE IsDelay = 1
ORDER BY tbBillheader.NUMBER , billdate
-- MSG: There is already an object named 'vwBillsDelay' in the database.

-- ERROR IN: vwService
CREATE VIEW vwService AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwService' in the database.

-- ERROR IN: vwNotify
CREATE VIEW vwNotify AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwNotify' in the database.

-- ERROR IN: vwCash
CREATE VIEW vwCash AS 
SELECT  guid , billtype, billdated , SUM(amountin) as amountin, SUM(amountout) as amountout    FROM vwcashRaw
-- MSG: Column 'vwcashRaw.guid' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatInCash
CREATE VIEW vwMatInCash AS 
SELECT tbMat.Guid,tbMat.GroupName,tbMat.code,tbMat.name,tbMat.BuyPrice,tbMat.SellPrice, tbMat.DiscountVal ,tbMat.DiscountPercent ,   tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent,tbMat.Barcode,tbMat.MinQty,tbMat.MinPrice,tbMat.CurrentQty, tbMat.ShowInCash , tbPicture.Pic FROM tbMat JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid    
WHERE ShowInCash = 1
-- MSG: There is already an object named 'vwMatInCash' in the database.

-- ERROR IN: vwMat
CREATE VIEW vwMat AS  
SELECT tbMat.Guid , tbMat.GroupName , tbMat.Code , tbMat.Name ,tbMat.BuyPrice , tbMat.SellPrice ,tbMat.DiscountVal ,tbMat.DiscountPercent , tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent , tbMat.Barcode , tbMat.MinQty , tbMat.MinPrice , CASE WHEN vwMatQty.qty IS NULL THEN 0 ELSE  vwMatQty.qty END as CurrentQty , tbMat.EndDate , tbMat.ShowInCash FROM tbMat 
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwMat' in the database.

-- ERROR IN: vwMaintenaceBody
CREATE VIEW vwMaintenaceBody AS 
SELECT tbMaintenaceBody.guid, tbMaintenaceBody.matguid, tbMaintenaceBody.parentguid, tbMaintenaceBody.number, tbmat.code || '-' || tbMat.name as mat, tbMaintenaceBody.[qty] , tbMaintenaceBody.[price] , (tbMaintenaceBody.[qty] * tbMaintenaceBody.[price]) as total , tbMaintenaceBody.note   
FROM tbMaintenaceBody JOIN tbMaintenance ON tbMaintenaceBody.parentguid = tbMaintenance.guid 
JOIN tbmat on tbMaintenaceBody.matguid = tbMat.guid ORDER BY tbMaintenaceBody.number
-- MSG: There is already an object named 'vwMaintenaceBody' in the database.

-- ERROR IN: vwAccoutnSelect
CREATE VIEW vwAccoutnSelect AS 
SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note,  CAST( CASE WHEN (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) IS NULL THEN 0 ELSE (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) END as FLOAT) as balance FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelect' in the database.

-- ERROR IN: vwAccountsBalanceRaw
CREATE VIEW vwAccountsBalanceRaw AS 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbBillHeader.BillDateD, 0 as payin,  CAST(tbBillHeader.totalnet as FLOAT) as payout FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2) 
UNION ALL 
SELECT tbAccount.guid, tbaccount.name,  tbAccount.AccType , tbBillHeader.BillDateD, CAST(tbBillHeader.totalnet as FLOAT) as payin, 0 as payout  FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3) 
UNION ALL 
SELECT tbAccount.guid,tbaccount.name,  tbAccount.AccType , tbPay.PayDateD, CAST(tbpay.amount  as FLOAT) as payin,  0 as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 0
UNION ALL 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbPay.PayDateD, 0 as payin, CAST(tbpay.amount as FLOAT) as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 1
UNION ALL 
SELECT tbAccount.guid,tbaccount.name ,  tbAccount.AccType ,  tbMaintenance.MainDateD as paydated,   0 as amountin,  CAST(tbMaintenance.Remain as FLOAT) as amountout  FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL 
SELECT tbaccount.guid ,  tbaccount.name ,  tbAccount.AccType ,tbAccount.CashDateD as paydated,  tbAccount.amountin  ,  tbAccount.amountout    FROM tbaccount WHERE StartCash = 1
-- MSG: There is already an object named 'vwAccountsBalanceRaw' in the database.

-- ERROR IN: vwMaintenance
CREATE VIEW vwMaintenance AS 
SELECT tbMaintenance.GUID  , tbMaintenance.OrderNo ,  tbMaintenance.Model , tbMaintenance.accountguid , tbAccount.Code || '-' || tbaccount.Name as account , tbAccount.Mobile ,   tbMaintenance.Operator , tbMaintenance.MainDate  , tbMaintenance.MainDateD ,tbMaintenance.MainEndDate  , tbMaintenance.MainEndDateD ,      tbMaintenance.Cost,  tbMaintenance.PcCost,   tbMaintenance.Payment , tbMaintenance.Remain,  tbMaintenance.Note ,   tbMaintenance.MainState  , tbMaintenance.UserGuid FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid
-- MSG: There is already an object named 'vwMaintenance' in the database.

-- ERROR IN: vwMatQtyStore
CREATE VIEW vwMatQtyStore AS 
SELECT  guid, storeGuid, mat, SUM(StartQty) as StartQty, SUM(StartQtyPrice)as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice ,  SUM(QtyOut)  as qtyout ,  SUM(QtyOutPrice) as QtyOutPrice,    SUM(StartQty + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRawStore
GROUP BY  guid, storeGuid, mat
-- MSG: There is already an object named 'vwMatQtyStore' in the database.

-- ERROR IN: vwMatQty
CREATE VIEW vwMatQty AS 
SELECT  guid, groupname, mat, SUM(StartQty) as StartQty , SUM(StartQtyPrice) as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice,  SUM(QtyOut)  as qtyout , SUM(QtyOutPrice) as QtyOutPrice,  SUM(StartQty  + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRaw
GROUP BY  guid, groupname, mat
-- MSG: There is already an object named 'vwMatQty' in the database.

-- ERROR IN: vwCashRAW
CREATE VIEW vwCashRAW AS 
SELECT tbBillHeader.guid,  CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] ,   0 as amountin,tbBillheader.[totalnet] as amountout   FROM tbBillHeader
WHERE paytype <> 'آجل' AND isDelay = 0 AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3)  
UNION ALL
SELECT tbBillHeader.guid, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] , tbBillheader.[totalnet] as amountin,0 as amountout  FROM tbBillHeader
WHERE paytype <> 'آجل'  AND isDelay = 0 AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2)
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  0 as amountin, tbpay.amount as amountout   FROM tbPay 
WHERE paytype = 1  
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  tbpay.amount as amountin,  0 as amountout  FROM tbPay 
WHERE paytype = 0
UNION ALL
SELECT tbMaintenance.Guid, 'صيانة' as paytype , tbMaintenance.MainDated as Paydated ,tbMaintenance.Payment as amountin , 0 as amountout   FROM tbMaintenance WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL
SELECT tbaccount.guid , ('رصيد إفتتاحي' || '-' || tbaccount.name) as paytype, tbAccount.CashDateD as paydated,   tbAccount.amountin  ,  tbAccount.amountout   FROM tbaccount WHERE StartCash = 1
UNION ALL 
SELECT tbmat.guid , ('رصيد إبتدائي') as paytype, tbMat.StartDateD as paydated,    0 as  amountin ,    SUM(tbMat.StartQty * tbMat.BuyPrice)  as amountout   FROM tbMat  WHERE tbMat.IsStartQty = 1  GROUP BY paytype
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwBillProfits
CREATE VIEW "vwBillProfits" AS SELECT vwBillProfitsRAW.guid , billdate , billdated , matguid , tbMat.code, tbMat.name , tbMat.GroupName ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost , CASE WHEN (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty)  ELSE (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) END as TotalBuyCost ,  CASE WHEN (SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) ELSE SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty) END  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = vwBillProfitsRAW.matGuid  
GROUP BY  DATE(billdate) , billdated , matguid , tbMat.code, tbMat.name
-- MSG: An expression of non-boolean type specified in a context where a condition is expected, near 'THEN'.

-- ERROR IN: vwAccoutnSelectNew
CREATE VIEW vwAccoutnSelectNew AS SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note, tbAccount.StartCash AS balance  FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelectNew' in the database.

-- ERROR IN: vwBillBody
CREATE VIEW vwBillBody AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeader ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBody' in the database.

-- ERROR IN: vwProductSalesInSession
CREATE VIEW vwProductSalesInSession AS SELECT b.matguid AS ProductID, m.name AS ProductName, b.qty AS Quantity, b.price AS UnitPrice, (b.qty * b.price) AS TotalPrice, r.uid AS SessionID, r.user AS UserName, r.invoice_num AS InvoiceNumber, r.total AS InvoiceTotal FROM tbBillBodyNew b INNER JOIN cash_drawer_report_new r ON b.parentguid = r.parentGuid INNER JOIN tbMat m ON b.matguid = m.guid
-- MSG: There is already an object named 'vwProductSalesInSession' in the database.

-- ERROR IN: vwBillsFee
CREATE VIEW vwBillsFee AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valin , CAST(0 as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 1 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 2 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 0 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1 ) as valin , 0 as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 3 UNION ALL SELECT tbpay.guid,tbpay.number, 'سند صرف' as billtype, tbpay.paydate as BillDate ,tbpay.paydated as BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbpay.notes as note , tbpay.[amount] as total, tbpay.amount as totalnet, 0 as Extra , 0 as discount , 0 as extraval , 0 as discountval , 0 as valin , CAST(tbpay.amount AS Float) as valout FROM tbpay JOIN tbAccount ON tbpay.accountguid = tbAccount.guid WHERE tbaccount.Code = 3 UNION ALL SELECT tbMaintenance.Guid, tbMaintenance.OrderNo as number, 'صيانة' as billtype ,tbMaintenance.MainDate as BillDate, tbMaintenance.MainDated as BillDateD , tbaccount.code || '-' || tbAccount.name as account, tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbMaintenance.Note , tbMaintenance.Cost as total, tbMaintenance.Cost + tbMaintenance.ExtraVal as Totalnet , 0 as Extra , 0 as discount , tbMaintenance.ExtraVal as extraval , 0 as discountval , tbMaintenance.ExtraVal as valin , CAST(0 as FLOAT) as valout FROM tbMaintenance JOIN tbAccount ON tbMaintenance.accountguid = tbAccount.guid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwDailySellsRAW
CREATE VIEW vwDailySellsRAW AS SELECT tbMat.guid, tbBillHeader.BillDated, tbMat.code || '-' || tbMat.name as mat, SUM(tbBillBodyNew.qty) as Qty , CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) as float) - (Total - TotalNet) as TotalSellPrice, CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) - SUM(tbBillBodyNew.Qty * tbMat.BuyPrice) as float) - (Total - TotalNet) as TotalProfitsOut FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 AND isDelay = 0 GROUP BY tbBillHeader.BillDated ,tbMat.guid,tbMat.code, tbMat.[name]
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.
Column 'tbBillHeader.total' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
Column 'tbBillHeader.totalnet' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatSellsPic
CREATE VIEW vwMatSellsPic AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype ,tbBillheader.BillDate , tbBillheader.BillDated , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount , tbMat.[GroupName], tbMat.[code] as matcode , tbMat.name as matname, tbBillBodyNew.qty , tbBillbodyNew.price , tbBillBodyNew.qty * tbBillbodyNew.price as bodytotal, tbBillBodyNew.note as bodynote , tbPicture.Pic FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwMatSellsPic' in the database.

-- ERROR IN: vwBillBodyNew
CREATE VIEW vwBillBodyNew AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeaderNew ON tbBillBodyNew.parentguid = tbBillHeaderNew.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBodyNew' in the database.

-- ERROR IN: vwMatQtyRaw
CREATE VIEW vwMatQtyRaw AS SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice , 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, tbmat.startQty, SUM(tbmat.StartQtyPrice) as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat WHERE tbMat.IsStartQty = 1 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name]
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillsProfitsRawSell
CREATE VIEW vwBillsProfitsRawSell as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , CASE tbBillHeader.billtype WHEN 1 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) WHEN 3 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) END as SellCost, (100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwBillsProfitsRawBuy
CREATE VIEW vwBillsProfitsRawBuy as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , tbBillBodyNew.Qty* tbBillBodyNew.Price as SellCost ,(100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwMatQtyRawStore
CREATE VIEW vwMatQtyRawStore AS SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty , 0 as StartQtyPrice, 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] ,tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty, 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.Price ) as QtyInPrice , 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbMat.StoreGuid, tbMat.StartQty , tbMat.StartQtyPrice as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbMat.StoreGuid
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBarCodeRptwithTax
CREATE VIEW vwBarCodeRptwithTax AS SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , ROUND(tbMat.SellPrice+(tbMat.SellPrice*(tbMat.FeePercent*0.01)),2) as SellPrice, CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END as CurrentQty, tbMat.BarCode , 0 as Qty FROM tbMat LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRptwithTax' in the database.

-- ERROR IN: vwUserBills
CREATE VIEW vwUserBills AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , CAST(tbBillheader.totalnet as FLOAT) as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 1 OR BillType = 2) UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , 0 as AmountIn , tbBillheader.totalnet as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 0 OR BillType = 3) UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype ,tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 0 UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated ,0 as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 1 UNION ALL SELECT guid, 0 as number , 'صيانة' as billtype, 'نقدي' as paytype , tbMaintenance.MainDate as BillDate ,tbMaintenance.MainDateD as BillDated ,tbMaintenance.Payment as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbMaintenance WHERE tbMaintenance.MainState = 'جاهزة' UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 2 THEN 'تحويل' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 2
-- MSG: There is already an object named 'vwUserBills' in the database.

-- ERROR IN: vwBillPrint
CREATE VIEW vwBillPrint AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' WHEN 4 THEN 'عرض سعر' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype as paytype ,tbBillheader.BillDate , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount ,tbBillheader.extraval, tbBillheader.discountval, tbMat.[code] as matcode, tbMat.[unite] as matunite , tbMat.name as matname, tbBillBodyNew.qty , tbBillBodyNew.price , tbBillBodyNew.qty * tbBillBodyNew.price as bodytotal,tbBillBodyNew.price/100.00*tbBillBodyNew.TaxValue as totalwithtax, tbBillBodyNew.note as bodynote FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwBillPrint' in the database.

-- ERROR IN: vwBills
CREATE VIEW vwBills AS 
SELECT
    tbBillheader.guid,
    tbBillHeader.number, 
    CASE tbBillHeader.billtype
        WHEN 0 THEN 'مشتريات'
        WHEN 1 THEN 'مبيعات'
        WHEN 2 THEN 'مرتجع مشتريات'
        WHEN 3 THEN 'مرتجع مبيعات'
        WHEN 4 THEN 'عرض سعر'
        WHEN 5 THEN 'إدخال'
        WHEN 6 THEN 'إخراج'
    END AS billtype, 
    --إضافة شرط الـ QR Code
   
    tbBillheader.BillDate,
    tbBillheader.BillDated, 
    tbAccount.code || '-' || tbAccount.name AS account,
    tbaccount.Mobile, 
    tbAccount.Email, 
    tbBillHeader.Paytype AS paytype, 
    tbBillheader.[note], 
    tbBillheader.[total], 
    tbBillheader.totalnet,
    COALESCE((SELECT SUM(SellCost) FROM vwBillsProfitsRawSell
              WHERE Number = tbBillHeader.number
              AND(tbBillHeader.billtype = 1 OR tbBillHeader.billtype = 3)), 0.0) AS SellCost,
    CAST(tbBillheader.extra AS FLOAT) AS Extra,
    tbBillheader.discount, 
    tbBillheader.extraval, 
    tbBillheader.discountval,
 CASE
        WHEN tbBillHeader.billtype IN(1, 3) THEN tbBillHeader.qr_code
        ELSE '0'
    END AS qr_code
FROM tbBillHeader
JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid
WHERE tbBillHeader.billtype<> 4
-- MSG: There is already an object named 'vwBills' in the database.

-- ERROR IN: vwPay1
CREATE VIEW vwPay1 AS SELECT tbBillHeader.guid, tbBillHeader.accountguid, tbBillHeader.number, tbBillHeader.billdate ,tbBillHeader.billdated , tbBillHeader.billtype as billtype, tbaccount.code || '-' || tbaccount.name as account, CASE tbBillHeader.billtype WHEN 0 THEN totalnet WHEN 1 THEN 0 END as amountin, CASE tbBillHeader.billtype WHEN 0 THEN 0 WHEN 1 THEN totalnet END as amountout ,tbBillHeader.note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid = tbaccount.guid WHERE tbBillHeader.paytype = 'نقدي' AND tbBillHeader.billtype = 0 ORDER by number
-- MSG: There is already an object named 'vwPay1' in the database.

-- ERROR IN: vwAccountPayments
CREATE VIEW vwAccountPayments AS SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype = 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.00 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=3) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.0 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=0 OR tbBillheader.billtype=3) UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbpay.amount AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=1 UNION ALL SELECT vwPay1.guid,vwPay1.number,'سداد فاتورة مشتريات' AS billtype,'نقدي' AS paytype,vwPay1.billdate,vwPay1.billdated,vwPay1.accountguid,tbAccount.name,tbAccount.AccType,vwPay1.amountout AS amountin,vwPay1.amountin AS amountout,vwPay1.note AS note FROM vwPay1 JOIN tbAccount ON vwPay1.accountguid=tbaccount.guid WHERE paytype='نقدي' UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,tbpay.amount AS amountin,0.0 AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=0 UNION ALL SELECT tbMaintenance.GUID,tbMaintenance.OrderNo AS number,'صيانة' AS billtype,'نقدي' AS paytype,tbMaintenance.MainDate AS paydate,tbMaintenance.MainDateD AS paydated,tbMaintenance.accountguid,tbaccount.Name AS account,tbAccount.AccType,0.0 AS amountin,tbMaintenance.Cost AS amountout,tbMaintenance.Note FROM tbMaintenance JOIN tbAccount ON tbAccount.Guid=tbMaintenance.AccountGuid WHERE tbMaintenance.MainState='جاهزة' UNION ALL SELECT tbaccount.guid,tbaccount.Code AS number,'رصيد إفتتاحي' AS billtype,'نقدي' AS paytype,tbAccount.CashDate AS paydate,tbAccount.CashDateD AS paydated,tbaccount.guid AS accountguid,tbAccount.name,tbAccount.AccType,tbAccount.amountin,tbAccount.amountout,tbAccount.note FROM tbaccount WHERE StartCash=1
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwBillProfitsRAW
CREATE VIEW vwBillProfitsRAW AS 
SELECT Guid as Guid , number, billtype, BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name ,0 as SellCost,   vwBillsProfitsRawBuy.Amount / vwBillsProfitsRawBuy.Qty  as BuyCost , 0 as TotalSellQty , vwBillsProfitsRawBuy.Qty  as TotalBuyQty  , 0 as TotalSell ,  vwBillsProfitsRawBuy.Amount  as TotalBuy  ,  0 as TotalSellCost, SellCost as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell,  0 as  NetBuy , Percentt  as BuyPrecent , 0 as SellPrecent FROM vwBillsProfitsRawBuy 
UNION ALL
SELECT Guid as Guid ,  number,   billtype,BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name , vwBillsProfitsRawSell.Amount  /  vwBillsProfitsRawSell.Qty  as SellCost , 0 as BuyCost ,  vwBillsProfitsRawSell.Qty  as TotalSellQty , 0 as TotalBuyQty , vwBillsProfitsRawSell.Amount  as TotalSell  , 0 as TotalBuy,  SellCost as TotalSellCost, 0 as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell , 0 as NetBuy ,   0 as BuyPrecent ,  Percentt  as SellPrecent FROM vwBillsProfitsRawSell
-- MSG: There is already an object named 'vwBillProfitsRAW' in the database.

-- ERROR IN: vwBillProfitsBills
CREATE VIEW vwBillProfitsBills AS 
SELECT guid, number, billtype , billdate, billdated , SUM(TotalSellCost) as TotalSellCost, SUM(TotalBuyCost) as TotalBuyCost  , SUM(TotalProfits) as TotalProfits from vwBillProfitsBillsRaw
GROUP BY  guid, number, billtype
-- MSG: Column 'vwBillProfitsBillsRaw.billdate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillProfitsBillsRaw
CREATE VIEW vwBillProfitsBillsRaw AS 
SELECT    vwBillProfitsRAW.guid ,vwBillProfitsRAW.Number, vwBillProfitsRAW.billType,  billdate , billdated , matguid , tbMat.code, tbMat.name ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost ,  TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) as  TotalBuyCost ,    TotalSellCost -  (TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) )  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = matguid   WHERE billtype ='مبيعات'
GROUP BY vwBillProfitsRAW.guid  ,vwBillProfitsRAW.Number  ,vwBillProfitsRAW.billType, matguid
-- MSG: Column 'vwBillProfitsRAW.BillDate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatEndDateRaw
CREATE VIEW vwMatEndDateRaw AS 
SELECT tbMat.guid,tbBillHeader.guid as billguid, tbMat.code || '-' || tbMat.Name as mat, SUM(tbBillBody.Qty) as qty , tbBillBody.EndDate FROM tbBillHeader JOIN tbBillBody 
ON tbBillHeader.guid = tbBillBody.ParentGuid 
JOIN tbMat ON tbBillBody.matguid = tbMat.guid 
JOIN vwMatQty ON tbMat.guid = vwMatQty.guid
WHERE (tbBillheader.billtype = 0 OR tbBillheader.billtype = 3) AND vwMatQty.Qty > 0
AND tbBillBody.endDate > ('1913-01-02 00:00:00')
GROUP BY tbMat.guid, tbmat.code, tbBillHeader.guid, tbmat.name, tbBillBody.EndDate
-- MSG: Invalid column name 'endDate'.
Invalid column name 'EndDate'.
Invalid column name 'EndDate'.

-- ERROR IN: vwMatEndDate
CREATE VIEW vwMatEndDate AS 
SELECT Guid,billguid, Mat,SUM(Qty) as Qty ,vwMatEndDateRaw.endDate, Round(julianday(enddate) - julianday('now')) as days, '' as Status FROM vwMatEndDateRaw
GROUP BY guid, Mat,Qty , vwMatEndDateRaw.EndDate,Days 
ORDER BY  guid, billguid, enddate ASC
-- MSG: The round function requires 2 to 3 arguments.

-- ERROR IN: vwAccountsBalance
CREATE VIEW vwAccountsBalance AS 
SELECT guid ,name, acctype , billdated , CAST(SUM(Payin) as FLOAT) as PayIn ,  CAST(SUM(payOut) as FLOAT) as payout, CAST(CAST(SUM(Payin) AS FLOAT) - CAST(SUM(PayOut) as FLOAT) as FLOAT) as balance FROM vwAccountsBalanceRaw
GROUP BY guid,  acctype , name
-- MSG: Column 'vwAccountsBalanceRaw.BillDateD' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwPay
CREATE VIEW vwPay AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate ,tbpay.paydated ,  CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code || '-' || tbaccount.name as account, CASE tbPay.paytype WHEN 0 THEN amount WHEN 1 THEN 0 END as amountin, CASE tbPay.paytype WHEN 0 THEN 0 WHEN 1 THEN amount END as amountout ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE tbpay.PayType = 1 OR tbPay.PayType = 0
ORDER by paydate, number
-- MSG: There is already an object named 'vwPay' in the database.

-- ERROR IN: vwPayPrint
CREATE VIEW vwPayPrint AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate , CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code , tbaccount.name as account, amount ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE paytype = 0 OR PayType = 1
-- MSG: There is already an object named 'vwPayPrint' in the database.

-- ERROR IN: vwBillsDelay
CREATE VIEW vwBillsDelay AS 
SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillheader.BillDate  ,tbBillheader.BillDated  , tbAccount.code|| '-' ||  tbAccount.name  as account,tbaccount.Mobile , tbAccount.Email ,    tbBillHeader.Paytype  as paytype  , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra 
, tbBillheader.discount FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid  WHERE IsDelay = 1
ORDER BY tbBillheader.NUMBER , billdate
-- MSG: There is already an object named 'vwBillsDelay' in the database.

-- ERROR IN: vwService
CREATE VIEW vwService AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwService' in the database.

-- ERROR IN: vwNotify
CREATE VIEW vwNotify AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwNotify' in the database.

-- ERROR IN: vwCash
CREATE VIEW vwCash AS 
SELECT  guid , billtype, billdated , SUM(amountin) as amountin, SUM(amountout) as amountout    FROM vwcashRaw
-- MSG: Column 'vwcashRaw.guid' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatInCash
CREATE VIEW vwMatInCash AS 
SELECT tbMat.Guid,tbMat.GroupName,tbMat.code,tbMat.name,tbMat.BuyPrice,tbMat.SellPrice, tbMat.DiscountVal ,tbMat.DiscountPercent ,   tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent,tbMat.Barcode,tbMat.MinQty,tbMat.MinPrice,tbMat.CurrentQty, tbMat.ShowInCash , tbPicture.Pic FROM tbMat JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid    
WHERE ShowInCash = 1
-- MSG: There is already an object named 'vwMatInCash' in the database.

-- ERROR IN: vwMat
CREATE VIEW vwMat AS  
SELECT tbMat.Guid , tbMat.GroupName , tbMat.Code , tbMat.Name ,tbMat.BuyPrice , tbMat.SellPrice ,tbMat.DiscountVal ,tbMat.DiscountPercent , tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent , tbMat.Barcode , tbMat.MinQty , tbMat.MinPrice , CASE WHEN vwMatQty.qty IS NULL THEN 0 ELSE  vwMatQty.qty END as CurrentQty , tbMat.EndDate , tbMat.ShowInCash FROM tbMat 
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwMat' in the database.

-- ERROR IN: vwMaintenaceBody
CREATE VIEW vwMaintenaceBody AS 
SELECT tbMaintenaceBody.guid, tbMaintenaceBody.matguid, tbMaintenaceBody.parentguid, tbMaintenaceBody.number, tbmat.code || '-' || tbMat.name as mat, tbMaintenaceBody.[qty] , tbMaintenaceBody.[price] , (tbMaintenaceBody.[qty] * tbMaintenaceBody.[price]) as total , tbMaintenaceBody.note   
FROM tbMaintenaceBody JOIN tbMaintenance ON tbMaintenaceBody.parentguid = tbMaintenance.guid 
JOIN tbmat on tbMaintenaceBody.matguid = tbMat.guid ORDER BY tbMaintenaceBody.number
-- MSG: There is already an object named 'vwMaintenaceBody' in the database.

-- ERROR IN: vwAccoutnSelect
CREATE VIEW vwAccoutnSelect AS 
SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note,  CAST( CASE WHEN (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) IS NULL THEN 0 ELSE (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) END as FLOAT) as balance FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelect' in the database.

-- ERROR IN: vwAccountsBalanceRaw
CREATE VIEW vwAccountsBalanceRaw AS 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbBillHeader.BillDateD, 0 as payin,  CAST(tbBillHeader.totalnet as FLOAT) as payout FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2) 
UNION ALL 
SELECT tbAccount.guid, tbaccount.name,  tbAccount.AccType , tbBillHeader.BillDateD, CAST(tbBillHeader.totalnet as FLOAT) as payin, 0 as payout  FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3) 
UNION ALL 
SELECT tbAccount.guid,tbaccount.name,  tbAccount.AccType , tbPay.PayDateD, CAST(tbpay.amount  as FLOAT) as payin,  0 as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 0
UNION ALL 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbPay.PayDateD, 0 as payin, CAST(tbpay.amount as FLOAT) as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 1
UNION ALL 
SELECT tbAccount.guid,tbaccount.name ,  tbAccount.AccType ,  tbMaintenance.MainDateD as paydated,   0 as amountin,  CAST(tbMaintenance.Remain as FLOAT) as amountout  FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL 
SELECT tbaccount.guid ,  tbaccount.name ,  tbAccount.AccType ,tbAccount.CashDateD as paydated,  tbAccount.amountin  ,  tbAccount.amountout    FROM tbaccount WHERE StartCash = 1
-- MSG: There is already an object named 'vwAccountsBalanceRaw' in the database.

-- ERROR IN: vwMaintenance
CREATE VIEW vwMaintenance AS 
SELECT tbMaintenance.GUID  , tbMaintenance.OrderNo ,  tbMaintenance.Model , tbMaintenance.accountguid , tbAccount.Code || '-' || tbaccount.Name as account , tbAccount.Mobile ,   tbMaintenance.Operator , tbMaintenance.MainDate  , tbMaintenance.MainDateD ,tbMaintenance.MainEndDate  , tbMaintenance.MainEndDateD ,      tbMaintenance.Cost,  tbMaintenance.PcCost,   tbMaintenance.Payment , tbMaintenance.Remain,  tbMaintenance.Note ,   tbMaintenance.MainState  , tbMaintenance.UserGuid FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid
-- MSG: There is already an object named 'vwMaintenance' in the database.

-- ERROR IN: vwMatQtyStore
CREATE VIEW vwMatQtyStore AS 
SELECT  guid, storeGuid, mat, SUM(StartQty) as StartQty, SUM(StartQtyPrice)as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice ,  SUM(QtyOut)  as qtyout ,  SUM(QtyOutPrice) as QtyOutPrice,    SUM(StartQty + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRawStore
GROUP BY  guid, storeGuid, mat
-- MSG: There is already an object named 'vwMatQtyStore' in the database.

-- ERROR IN: vwMatQty
CREATE VIEW vwMatQty AS 
SELECT  guid, groupname, mat, SUM(StartQty) as StartQty , SUM(StartQtyPrice) as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice,  SUM(QtyOut)  as qtyout , SUM(QtyOutPrice) as QtyOutPrice,  SUM(StartQty  + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRaw
GROUP BY  guid, groupname, mat
-- MSG: There is already an object named 'vwMatQty' in the database.

-- ERROR IN: vwCashRAW
CREATE VIEW vwCashRAW AS 
SELECT tbBillHeader.guid,  CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] ,   0 as amountin,tbBillheader.[totalnet] as amountout   FROM tbBillHeader
WHERE paytype <> 'آجل' AND isDelay = 0 AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3)  
UNION ALL
SELECT tbBillHeader.guid, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] , tbBillheader.[totalnet] as amountin,0 as amountout  FROM tbBillHeader
WHERE paytype <> 'آجل'  AND isDelay = 0 AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2)
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  0 as amountin, tbpay.amount as amountout   FROM tbPay 
WHERE paytype = 1  
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  tbpay.amount as amountin,  0 as amountout  FROM tbPay 
WHERE paytype = 0
UNION ALL
SELECT tbMaintenance.Guid, 'صيانة' as paytype , tbMaintenance.MainDated as Paydated ,tbMaintenance.Payment as amountin , 0 as amountout   FROM tbMaintenance WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL
SELECT tbaccount.guid , ('رصيد إفتتاحي' || '-' || tbaccount.name) as paytype, tbAccount.CashDateD as paydated,   tbAccount.amountin  ,  tbAccount.amountout   FROM tbaccount WHERE StartCash = 1
UNION ALL 
SELECT tbmat.guid , ('رصيد إبتدائي') as paytype, tbMat.StartDateD as paydated,    0 as  amountin ,    SUM(tbMat.StartQty * tbMat.BuyPrice)  as amountout   FROM tbMat  WHERE tbMat.IsStartQty = 1  GROUP BY paytype
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwBillProfits
CREATE VIEW "vwBillProfits" AS SELECT vwBillProfitsRAW.guid , billdate , billdated , matguid , tbMat.code, tbMat.name , tbMat.GroupName ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost , CASE WHEN (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty)  ELSE (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) END as TotalBuyCost ,  CASE WHEN (SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) ELSE SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty) END  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = vwBillProfitsRAW.matGuid  
GROUP BY  DATE(billdate) , billdated , matguid , tbMat.code, tbMat.name
-- MSG: An expression of non-boolean type specified in a context where a condition is expected, near 'THEN'.

-- ERROR IN: vwAccoutnSelectNew
CREATE VIEW vwAccoutnSelectNew AS SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note, tbAccount.StartCash AS balance  FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelectNew' in the database.

-- ERROR IN: vwDailySells
CREATE VIEW vwDailySells AS 
SELECT guid , billdated, mat, SUM(Qty) As Qty , CAST(SUM(TotalSellPrice) as float) as TotalSellPrice ,   CAST(SUM(TotalProfitsOut) as float) as TotalProfits  FROM vwDailySellsRaw
GROUP BY guid , billdated , mat
-- MSG: There is already an object named 'vwDailySells' in the database.

-- ERROR IN: vwBarCodeRpt
CREATE VIEW vwBarCodeRpt AS 
SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , tbMat.SellPrice , CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END  as CurrentQty,  tbMat.BarCode , 0 as Qty FROM tbMat
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRpt' in the database.

-- ERROR IN: vwBillBody
CREATE VIEW vwBillBody AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeader ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBody' in the database.

-- ERROR IN: vwProductSalesInSession
CREATE VIEW vwProductSalesInSession AS SELECT b.matguid AS ProductID, m.name AS ProductName, b.qty AS Quantity, b.price AS UnitPrice, (b.qty * b.price) AS TotalPrice, r.uid AS SessionID, r.user AS UserName, r.invoice_num AS InvoiceNumber, r.total AS InvoiceTotal FROM tbBillBodyNew b INNER JOIN cash_drawer_report_new r ON b.parentguid = r.parentGuid INNER JOIN tbMat m ON b.matguid = m.guid
-- MSG: There is already an object named 'vwProductSalesInSession' in the database.

-- ERROR IN: vwBillsFee
CREATE VIEW vwBillsFee AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valin , CAST(0 as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 1 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 2 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 0 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1 ) as valin , 0 as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 3 UNION ALL SELECT tbpay.guid,tbpay.number, 'سند صرف' as billtype, tbpay.paydate as BillDate ,tbpay.paydated as BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbpay.notes as note , tbpay.[amount] as total, tbpay.amount as totalnet, 0 as Extra , 0 as discount , 0 as extraval , 0 as discountval , 0 as valin , CAST(tbpay.amount AS Float) as valout FROM tbpay JOIN tbAccount ON tbpay.accountguid = tbAccount.guid WHERE tbaccount.Code = 3 UNION ALL SELECT tbMaintenance.Guid, tbMaintenance.OrderNo as number, 'صيانة' as billtype ,tbMaintenance.MainDate as BillDate, tbMaintenance.MainDated as BillDateD , tbaccount.code || '-' || tbAccount.name as account, tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbMaintenance.Note , tbMaintenance.Cost as total, tbMaintenance.Cost + tbMaintenance.ExtraVal as Totalnet , 0 as Extra , 0 as discount , tbMaintenance.ExtraVal as extraval , 0 as discountval , tbMaintenance.ExtraVal as valin , CAST(0 as FLOAT) as valout FROM tbMaintenance JOIN tbAccount ON tbMaintenance.accountguid = tbAccount.guid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwDailySellsRAW
CREATE VIEW vwDailySellsRAW AS SELECT tbMat.guid, tbBillHeader.BillDated, tbMat.code || '-' || tbMat.name as mat, SUM(tbBillBodyNew.qty) as Qty , CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) as float) - (Total - TotalNet) as TotalSellPrice, CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) - SUM(tbBillBodyNew.Qty * tbMat.BuyPrice) as float) - (Total - TotalNet) as TotalProfitsOut FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 AND isDelay = 0 GROUP BY tbBillHeader.BillDated ,tbMat.guid,tbMat.code, tbMat.[name]
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.
Column 'tbBillHeader.total' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
Column 'tbBillHeader.totalnet' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatSellsPic
CREATE VIEW vwMatSellsPic AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype ,tbBillheader.BillDate , tbBillheader.BillDated , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount , tbMat.[GroupName], tbMat.[code] as matcode , tbMat.name as matname, tbBillBodyNew.qty , tbBillbodyNew.price , tbBillBodyNew.qty * tbBillbodyNew.price as bodytotal, tbBillBodyNew.note as bodynote , tbPicture.Pic FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwMatSellsPic' in the database.

-- ERROR IN: vwBillBodyNew
CREATE VIEW vwBillBodyNew AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeaderNew ON tbBillBodyNew.parentguid = tbBillHeaderNew.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBodyNew' in the database.

-- ERROR IN: vwMatQtyRaw
CREATE VIEW vwMatQtyRaw AS SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice , 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, tbmat.startQty, SUM(tbmat.StartQtyPrice) as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat WHERE tbMat.IsStartQty = 1 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name]
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillsProfitsRawSell
CREATE VIEW vwBillsProfitsRawSell as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , CASE tbBillHeader.billtype WHEN 1 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) WHEN 3 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) END as SellCost, (100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwBillsProfitsRawBuy
CREATE VIEW vwBillsProfitsRawBuy as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , tbBillBodyNew.Qty* tbBillBodyNew.Price as SellCost ,(100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwMatQtyRawStore
CREATE VIEW vwMatQtyRawStore AS SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty , 0 as StartQtyPrice, 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] ,tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty, 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.Price ) as QtyInPrice , 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbMat.StoreGuid, tbMat.StartQty , tbMat.StartQtyPrice as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbMat.StoreGuid
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBarCodeRptwithTax
CREATE VIEW vwBarCodeRptwithTax AS SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , ROUND(tbMat.SellPrice+(tbMat.SellPrice*(tbMat.FeePercent*0.01)),2) as SellPrice, CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END as CurrentQty, tbMat.BarCode , 0 as Qty FROM tbMat LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRptwithTax' in the database.

-- ERROR IN: vwUserBills
CREATE VIEW vwUserBills AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , CAST(tbBillheader.totalnet as FLOAT) as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 1 OR BillType = 2) UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , 0 as AmountIn , tbBillheader.totalnet as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 0 OR BillType = 3) UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype ,tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 0 UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated ,0 as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 1 UNION ALL SELECT guid, 0 as number , 'صيانة' as billtype, 'نقدي' as paytype , tbMaintenance.MainDate as BillDate ,tbMaintenance.MainDateD as BillDated ,tbMaintenance.Payment as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbMaintenance WHERE tbMaintenance.MainState = 'جاهزة' UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 2 THEN 'تحويل' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 2
-- MSG: There is already an object named 'vwUserBills' in the database.

-- ERROR IN: vwBillPrint
CREATE VIEW vwBillPrint AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' WHEN 4 THEN 'عرض سعر' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype as paytype ,tbBillheader.BillDate , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount ,tbBillheader.extraval, tbBillheader.discountval, tbMat.[code] as matcode, tbMat.[unite] as matunite , tbMat.name as matname, tbBillBodyNew.qty , tbBillBodyNew.price , tbBillBodyNew.qty * tbBillBodyNew.price as bodytotal,tbBillBodyNew.price/100.00*tbBillBodyNew.TaxValue as totalwithtax, tbBillBodyNew.note as bodynote FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwBillPrint' in the database.

-- ERROR IN: vwBills
CREATE VIEW vwBills AS 
SELECT
    tbBillheader.guid,
    tbBillHeader.number, 
    CASE tbBillHeader.billtype
        WHEN 0 THEN 'مشتريات'
        WHEN 1 THEN 'مبيعات'
        WHEN 2 THEN 'مرتجع مشتريات'
        WHEN 3 THEN 'مرتجع مبيعات'
        WHEN 4 THEN 'عرض سعر'
        WHEN 5 THEN 'إدخال'
        WHEN 6 THEN 'إخراج'
    END AS billtype, 
    --إضافة شرط الـ QR Code
   
    tbBillheader.BillDate,
    tbBillheader.BillDated, 
    tbAccount.code || '-' || tbAccount.name AS account,
    tbaccount.Mobile, 
    tbAccount.Email, 
    tbBillHeader.Paytype AS paytype, 
    tbBillheader.[note], 
    tbBillheader.[total], 
    tbBillheader.totalnet,
    COALESCE((SELECT SUM(SellCost) FROM vwBillsProfitsRawSell
              WHERE Number = tbBillHeader.number
              AND(tbBillHeader.billtype = 1 OR tbBillHeader.billtype = 3)), 0.0) AS SellCost,
    CAST(tbBillheader.extra AS FLOAT) AS Extra,
    tbBillheader.discount, 
    tbBillheader.extraval, 
    tbBillheader.discountval,
 CASE
        WHEN tbBillHeader.billtype IN(1, 3) THEN tbBillHeader.qr_code
        ELSE '0'
    END AS qr_code
FROM tbBillHeader
JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid
WHERE tbBillHeader.billtype<> 4
-- MSG: There is already an object named 'vwBills' in the database.

-- ERROR IN: vwPay1
CREATE VIEW vwPay1 AS SELECT tbBillHeader.guid, tbBillHeader.accountguid, tbBillHeader.number, tbBillHeader.billdate ,tbBillHeader.billdated , tbBillHeader.billtype as billtype, tbaccount.code || '-' || tbaccount.name as account, CASE tbBillHeader.billtype WHEN 0 THEN totalnet WHEN 1 THEN 0 END as amountin, CASE tbBillHeader.billtype WHEN 0 THEN 0 WHEN 1 THEN totalnet END as amountout ,tbBillHeader.note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid = tbaccount.guid WHERE tbBillHeader.paytype = 'نقدي' AND tbBillHeader.billtype = 0 ORDER by number
-- MSG: There is already an object named 'vwPay1' in the database.

-- ERROR IN: vwAccountPayments
CREATE VIEW vwAccountPayments AS SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype = 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.00 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=3) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.0 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=0 OR tbBillheader.billtype=3) UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbpay.amount AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=1 UNION ALL SELECT vwPay1.guid,vwPay1.number,'سداد فاتورة مشتريات' AS billtype,'نقدي' AS paytype,vwPay1.billdate,vwPay1.billdated,vwPay1.accountguid,tbAccount.name,tbAccount.AccType,vwPay1.amountout AS amountin,vwPay1.amountin AS amountout,vwPay1.note AS note FROM vwPay1 JOIN tbAccount ON vwPay1.accountguid=tbaccount.guid WHERE paytype='نقدي' UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,tbpay.amount AS amountin,0.0 AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=0 UNION ALL SELECT tbMaintenance.GUID,tbMaintenance.OrderNo AS number,'صيانة' AS billtype,'نقدي' AS paytype,tbMaintenance.MainDate AS paydate,tbMaintenance.MainDateD AS paydated,tbMaintenance.accountguid,tbaccount.Name AS account,tbAccount.AccType,0.0 AS amountin,tbMaintenance.Cost AS amountout,tbMaintenance.Note FROM tbMaintenance JOIN tbAccount ON tbAccount.Guid=tbMaintenance.AccountGuid WHERE tbMaintenance.MainState='جاهزة' UNION ALL SELECT tbaccount.guid,tbaccount.Code AS number,'رصيد إفتتاحي' AS billtype,'نقدي' AS paytype,tbAccount.CashDate AS paydate,tbAccount.CashDateD AS paydated,tbaccount.guid AS accountguid,tbAccount.name,tbAccount.AccType,tbAccount.amountin,tbAccount.amountout,tbAccount.note FROM tbaccount WHERE StartCash=1
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwBillProfitsRAW
CREATE VIEW vwBillProfitsRAW AS 
SELECT Guid as Guid , number, billtype, BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name ,0 as SellCost,   vwBillsProfitsRawBuy.Amount / vwBillsProfitsRawBuy.Qty  as BuyCost , 0 as TotalSellQty , vwBillsProfitsRawBuy.Qty  as TotalBuyQty  , 0 as TotalSell ,  vwBillsProfitsRawBuy.Amount  as TotalBuy  ,  0 as TotalSellCost, SellCost as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell,  0 as  NetBuy , Percentt  as BuyPrecent , 0 as SellPrecent FROM vwBillsProfitsRawBuy 
UNION ALL
SELECT Guid as Guid ,  number,   billtype,BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name , vwBillsProfitsRawSell.Amount  /  vwBillsProfitsRawSell.Qty  as SellCost , 0 as BuyCost ,  vwBillsProfitsRawSell.Qty  as TotalSellQty , 0 as TotalBuyQty , vwBillsProfitsRawSell.Amount  as TotalSell  , 0 as TotalBuy,  SellCost as TotalSellCost, 0 as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell , 0 as NetBuy ,   0 as BuyPrecent ,  Percentt  as SellPrecent FROM vwBillsProfitsRawSell
-- MSG: There is already an object named 'vwBillProfitsRAW' in the database.

-- ERROR IN: vwBillProfitsBills
CREATE VIEW vwBillProfitsBills AS 
SELECT guid, number, billtype , billdate, billdated , SUM(TotalSellCost) as TotalSellCost, SUM(TotalBuyCost) as TotalBuyCost  , SUM(TotalProfits) as TotalProfits from vwBillProfitsBillsRaw
GROUP BY  guid, number, billtype
-- MSG: Column 'vwBillProfitsBillsRaw.billdate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillProfitsBillsRaw
CREATE VIEW vwBillProfitsBillsRaw AS 
SELECT    vwBillProfitsRAW.guid ,vwBillProfitsRAW.Number, vwBillProfitsRAW.billType,  billdate , billdated , matguid , tbMat.code, tbMat.name ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost ,  TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) as  TotalBuyCost ,    TotalSellCost -  (TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) )  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = matguid   WHERE billtype ='مبيعات'
GROUP BY vwBillProfitsRAW.guid  ,vwBillProfitsRAW.Number  ,vwBillProfitsRAW.billType, matguid
-- MSG: Column 'vwBillProfitsRAW.BillDate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatEndDateRaw
CREATE VIEW vwMatEndDateRaw AS 
SELECT tbMat.guid,tbBillHeader.guid as billguid, tbMat.code || '-' || tbMat.Name as mat, SUM(tbBillBody.Qty) as qty , tbBillBody.EndDate FROM tbBillHeader JOIN tbBillBody 
ON tbBillHeader.guid = tbBillBody.ParentGuid 
JOIN tbMat ON tbBillBody.matguid = tbMat.guid 
JOIN vwMatQty ON tbMat.guid = vwMatQty.guid
WHERE (tbBillheader.billtype = 0 OR tbBillheader.billtype = 3) AND vwMatQty.Qty > 0
AND tbBillBody.endDate > ('1913-01-02 00:00:00')
GROUP BY tbMat.guid, tbmat.code, tbBillHeader.guid, tbmat.name, tbBillBody.EndDate
-- MSG: Invalid column name 'endDate'.
Invalid column name 'EndDate'.
Invalid column name 'EndDate'.

-- ERROR IN: vwMatEndDate
CREATE VIEW vwMatEndDate AS 
SELECT Guid,billguid, Mat,SUM(Qty) as Qty ,vwMatEndDateRaw.endDate, Round(julianday(enddate) - julianday('now')) as days, '' as Status FROM vwMatEndDateRaw
GROUP BY guid, Mat,Qty , vwMatEndDateRaw.EndDate,Days 
ORDER BY  guid, billguid, enddate ASC
-- MSG: The round function requires 2 to 3 arguments.

-- ERROR IN: vwAccountsBalance
CREATE VIEW vwAccountsBalance AS 
SELECT guid ,name, acctype , billdated , CAST(SUM(Payin) as FLOAT) as PayIn ,  CAST(SUM(payOut) as FLOAT) as payout, CAST(CAST(SUM(Payin) AS FLOAT) - CAST(SUM(PayOut) as FLOAT) as FLOAT) as balance FROM vwAccountsBalanceRaw
GROUP BY guid,  acctype , name
-- MSG: Column 'vwAccountsBalanceRaw.BillDateD' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwPay
CREATE VIEW vwPay AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate ,tbpay.paydated ,  CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code || '-' || tbaccount.name as account, CASE tbPay.paytype WHEN 0 THEN amount WHEN 1 THEN 0 END as amountin, CASE tbPay.paytype WHEN 0 THEN 0 WHEN 1 THEN amount END as amountout ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE tbpay.PayType = 1 OR tbPay.PayType = 0
ORDER by paydate, number
-- MSG: There is already an object named 'vwPay' in the database.

-- ERROR IN: vwPayPrint
CREATE VIEW vwPayPrint AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate , CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code , tbaccount.name as account, amount ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE paytype = 0 OR PayType = 1
-- MSG: There is already an object named 'vwPayPrint' in the database.

-- ERROR IN: vwBillsDelay
CREATE VIEW vwBillsDelay AS 
SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillheader.BillDate  ,tbBillheader.BillDated  , tbAccount.code|| '-' ||  tbAccount.name  as account,tbaccount.Mobile , tbAccount.Email ,    tbBillHeader.Paytype  as paytype  , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra 
, tbBillheader.discount FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid  WHERE IsDelay = 1
ORDER BY tbBillheader.NUMBER , billdate
-- MSG: There is already an object named 'vwBillsDelay' in the database.

-- ERROR IN: vwService
CREATE VIEW vwService AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwService' in the database.

-- ERROR IN: vwNotify
CREATE VIEW vwNotify AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwNotify' in the database.

-- ERROR IN: vwCash
CREATE VIEW vwCash AS 
SELECT  guid , billtype, billdated , SUM(amountin) as amountin, SUM(amountout) as amountout    FROM vwcashRaw
-- MSG: Column 'vwcashRaw.guid' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatInCash
CREATE VIEW vwMatInCash AS 
SELECT tbMat.Guid,tbMat.GroupName,tbMat.code,tbMat.name,tbMat.BuyPrice,tbMat.SellPrice, tbMat.DiscountVal ,tbMat.DiscountPercent ,   tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent,tbMat.Barcode,tbMat.MinQty,tbMat.MinPrice,tbMat.CurrentQty, tbMat.ShowInCash , tbPicture.Pic FROM tbMat JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid    
WHERE ShowInCash = 1
-- MSG: There is already an object named 'vwMatInCash' in the database.

-- ERROR IN: vwMat
CREATE VIEW vwMat AS  
SELECT tbMat.Guid , tbMat.GroupName , tbMat.Code , tbMat.Name ,tbMat.BuyPrice , tbMat.SellPrice ,tbMat.DiscountVal ,tbMat.DiscountPercent , tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent , tbMat.Barcode , tbMat.MinQty , tbMat.MinPrice , CASE WHEN vwMatQty.qty IS NULL THEN 0 ELSE  vwMatQty.qty END as CurrentQty , tbMat.EndDate , tbMat.ShowInCash FROM tbMat 
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwMat' in the database.

-- ERROR IN: vwMaintenaceBody
CREATE VIEW vwMaintenaceBody AS 
SELECT tbMaintenaceBody.guid, tbMaintenaceBody.matguid, tbMaintenaceBody.parentguid, tbMaintenaceBody.number, tbmat.code || '-' || tbMat.name as mat, tbMaintenaceBody.[qty] , tbMaintenaceBody.[price] , (tbMaintenaceBody.[qty] * tbMaintenaceBody.[price]) as total , tbMaintenaceBody.note   
FROM tbMaintenaceBody JOIN tbMaintenance ON tbMaintenaceBody.parentguid = tbMaintenance.guid 
JOIN tbmat on tbMaintenaceBody.matguid = tbMat.guid ORDER BY tbMaintenaceBody.number
-- MSG: There is already an object named 'vwMaintenaceBody' in the database.

-- ERROR IN: vwAccoutnSelect
CREATE VIEW vwAccoutnSelect AS 
SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note,  CAST( CASE WHEN (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) IS NULL THEN 0 ELSE (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) END as FLOAT) as balance FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelect' in the database.

-- ERROR IN: vwAccountsBalanceRaw
CREATE VIEW vwAccountsBalanceRaw AS 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbBillHeader.BillDateD, 0 as payin,  CAST(tbBillHeader.totalnet as FLOAT) as payout FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2) 
UNION ALL 
SELECT tbAccount.guid, tbaccount.name,  tbAccount.AccType , tbBillHeader.BillDateD, CAST(tbBillHeader.totalnet as FLOAT) as payin, 0 as payout  FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3) 
UNION ALL 
SELECT tbAccount.guid,tbaccount.name,  tbAccount.AccType , tbPay.PayDateD, CAST(tbpay.amount  as FLOAT) as payin,  0 as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 0
UNION ALL 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbPay.PayDateD, 0 as payin, CAST(tbpay.amount as FLOAT) as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 1
UNION ALL 
SELECT tbAccount.guid,tbaccount.name ,  tbAccount.AccType ,  tbMaintenance.MainDateD as paydated,   0 as amountin,  CAST(tbMaintenance.Remain as FLOAT) as amountout  FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL 
SELECT tbaccount.guid ,  tbaccount.name ,  tbAccount.AccType ,tbAccount.CashDateD as paydated,  tbAccount.amountin  ,  tbAccount.amountout    FROM tbaccount WHERE StartCash = 1
-- MSG: There is already an object named 'vwAccountsBalanceRaw' in the database.

-- ERROR IN: vwMaintenance
CREATE VIEW vwMaintenance AS 
SELECT tbMaintenance.GUID  , tbMaintenance.OrderNo ,  tbMaintenance.Model , tbMaintenance.accountguid , tbAccount.Code || '-' || tbaccount.Name as account , tbAccount.Mobile ,   tbMaintenance.Operator , tbMaintenance.MainDate  , tbMaintenance.MainDateD ,tbMaintenance.MainEndDate  , tbMaintenance.MainEndDateD ,      tbMaintenance.Cost,  tbMaintenance.PcCost,   tbMaintenance.Payment , tbMaintenance.Remain,  tbMaintenance.Note ,   tbMaintenance.MainState  , tbMaintenance.UserGuid FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid
-- MSG: There is already an object named 'vwMaintenance' in the database.

-- ERROR IN: vwMatQtyStore
CREATE VIEW vwMatQtyStore AS 
SELECT  guid, storeGuid, mat, SUM(StartQty) as StartQty, SUM(StartQtyPrice)as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice ,  SUM(QtyOut)  as qtyout ,  SUM(QtyOutPrice) as QtyOutPrice,    SUM(StartQty + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRawStore
GROUP BY  guid, storeGuid, mat
-- MSG: There is already an object named 'vwMatQtyStore' in the database.

-- ERROR IN: vwMatQty
CREATE VIEW vwMatQty AS 
SELECT  guid, groupname, mat, SUM(StartQty) as StartQty , SUM(StartQtyPrice) as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice,  SUM(QtyOut)  as qtyout , SUM(QtyOutPrice) as QtyOutPrice,  SUM(StartQty  + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRaw
GROUP BY  guid, groupname, mat
-- MSG: There is already an object named 'vwMatQty' in the database.

-- ERROR IN: vwCashRAW
CREATE VIEW vwCashRAW AS 
SELECT tbBillHeader.guid,  CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] ,   0 as amountin,tbBillheader.[totalnet] as amountout   FROM tbBillHeader
WHERE paytype <> 'آجل' AND isDelay = 0 AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3)  
UNION ALL
SELECT tbBillHeader.guid, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] , tbBillheader.[totalnet] as amountin,0 as amountout  FROM tbBillHeader
WHERE paytype <> 'آجل'  AND isDelay = 0 AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2)
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  0 as amountin, tbpay.amount as amountout   FROM tbPay 
WHERE paytype = 1  
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  tbpay.amount as amountin,  0 as amountout  FROM tbPay 
WHERE paytype = 0
UNION ALL
SELECT tbMaintenance.Guid, 'صيانة' as paytype , tbMaintenance.MainDated as Paydated ,tbMaintenance.Payment as amountin , 0 as amountout   FROM tbMaintenance WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL
SELECT tbaccount.guid , ('رصيد إفتتاحي' || '-' || tbaccount.name) as paytype, tbAccount.CashDateD as paydated,   tbAccount.amountin  ,  tbAccount.amountout   FROM tbaccount WHERE StartCash = 1
UNION ALL 
SELECT tbmat.guid , ('رصيد إبتدائي') as paytype, tbMat.StartDateD as paydated,    0 as  amountin ,    SUM(tbMat.StartQty * tbMat.BuyPrice)  as amountout   FROM tbMat  WHERE tbMat.IsStartQty = 1  GROUP BY paytype
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwBillProfits
CREATE VIEW "vwBillProfits" AS SELECT vwBillProfitsRAW.guid , billdate , billdated , matguid , tbMat.code, tbMat.name , tbMat.GroupName ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost , CASE WHEN (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty)  ELSE (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) END as TotalBuyCost ,  CASE WHEN (SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) ELSE SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty) END  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = vwBillProfitsRAW.matGuid  
GROUP BY  DATE(billdate) , billdated , matguid , tbMat.code, tbMat.name
-- MSG: An expression of non-boolean type specified in a context where a condition is expected, near 'THEN'.

-- ERROR IN: vwAccoutnSelectNew
CREATE VIEW vwAccoutnSelectNew AS SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note, tbAccount.StartCash AS balance  FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelectNew' in the database.

-- ERROR IN: vwDailySells
CREATE VIEW vwDailySells AS 
SELECT guid , billdated, mat, SUM(Qty) As Qty , CAST(SUM(TotalSellPrice) as float) as TotalSellPrice ,   CAST(SUM(TotalProfitsOut) as float) as TotalProfits  FROM vwDailySellsRaw
GROUP BY guid , billdated , mat
-- MSG: There is already an object named 'vwDailySells' in the database.

-- ERROR IN: vwBarCodeRpt
CREATE VIEW vwBarCodeRpt AS 
SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , tbMat.SellPrice , CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END  as CurrentQty,  tbMat.BarCode , 0 as Qty FROM tbMat
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRpt' in the database.

-- ERROR IN: vwBillBody
CREATE VIEW vwBillBody AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeader ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBody' in the database.

-- ERROR IN: vwProductSalesInSession
CREATE VIEW vwProductSalesInSession AS SELECT b.matguid AS ProductID, m.name AS ProductName, b.qty AS Quantity, b.price AS UnitPrice, (b.qty * b.price) AS TotalPrice, r.uid AS SessionID, r.user AS UserName, r.invoice_num AS InvoiceNumber, r.total AS InvoiceTotal FROM tbBillBodyNew b INNER JOIN cash_drawer_report_new r ON b.parentguid = r.parentGuid INNER JOIN tbMat m ON b.matguid = m.guid
-- MSG: There is already an object named 'vwProductSalesInSession' in the database.

-- ERROR IN: vwBillsFee
CREATE VIEW vwBillsFee AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valin , CAST(0 as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 1 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 2 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 0 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1 ) as valin , 0 as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 3 UNION ALL SELECT tbpay.guid,tbpay.number, 'سند صرف' as billtype, tbpay.paydate as BillDate ,tbpay.paydated as BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbpay.notes as note , tbpay.[amount] as total, tbpay.amount as totalnet, 0 as Extra , 0 as discount , 0 as extraval , 0 as discountval , 0 as valin , CAST(tbpay.amount AS Float) as valout FROM tbpay JOIN tbAccount ON tbpay.accountguid = tbAccount.guid WHERE tbaccount.Code = 3 UNION ALL SELECT tbMaintenance.Guid, tbMaintenance.OrderNo as number, 'صيانة' as billtype ,tbMaintenance.MainDate as BillDate, tbMaintenance.MainDated as BillDateD , tbaccount.code || '-' || tbAccount.name as account, tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbMaintenance.Note , tbMaintenance.Cost as total, tbMaintenance.Cost + tbMaintenance.ExtraVal as Totalnet , 0 as Extra , 0 as discount , tbMaintenance.ExtraVal as extraval , 0 as discountval , tbMaintenance.ExtraVal as valin , CAST(0 as FLOAT) as valout FROM tbMaintenance JOIN tbAccount ON tbMaintenance.accountguid = tbAccount.guid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwDailySellsRAW
CREATE VIEW vwDailySellsRAW AS SELECT tbMat.guid, tbBillHeader.BillDated, tbMat.code || '-' || tbMat.name as mat, SUM(tbBillBodyNew.qty) as Qty , CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) as float) - (Total - TotalNet) as TotalSellPrice, CAST(SUM(tbBillBodyNew.Qty * tbBillBodyNew.Price) - SUM(tbBillBodyNew.Qty * tbMat.BuyPrice) as float) - (Total - TotalNet) as TotalProfitsOut FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 AND isDelay = 0 GROUP BY tbBillHeader.BillDated ,tbMat.guid,tbMat.code, tbMat.[name]
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.
Column 'tbBillHeader.total' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
Column 'tbBillHeader.totalnet' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatSellsPic
CREATE VIEW vwMatSellsPic AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype ,tbBillheader.BillDate , tbBillheader.BillDated , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount , tbMat.[GroupName], tbMat.[code] as matcode , tbMat.name as matname, tbBillBodyNew.qty , tbBillbodyNew.price , tbBillBodyNew.qty * tbBillbodyNew.price as bodytotal, tbBillBodyNew.note as bodynote , tbPicture.Pic FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwMatSellsPic' in the database.

-- ERROR IN: vwBillBodyNew
CREATE VIEW vwBillBodyNew AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeaderNew ON tbBillBodyNew.parentguid = tbBillHeaderNew.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBodyNew' in the database.

-- ERROR IN: vwMatQtyRaw
CREATE VIEW vwMatQtyRaw AS SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice , 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, tbmat.startQty, SUM(tbmat.StartQtyPrice) as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat WHERE tbMat.IsStartQty = 1 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name]
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillsProfitsRawSell
CREATE VIEW vwBillsProfitsRawSell as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , CASE tbBillHeader.billtype WHEN 1 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) WHEN 3 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) END as SellCost, (100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwBillsProfitsRawBuy
CREATE VIEW vwBillsProfitsRawBuy as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , tbBillBodyNew.Qty* tbBillBodyNew.Price as SellCost ,(100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwMatQtyRawStore
CREATE VIEW vwMatQtyRawStore AS SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty , 0 as StartQtyPrice, 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] ,tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty, 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.Price ) as QtyInPrice , 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbMat.StoreGuid, tbMat.StartQty , tbMat.StartQtyPrice as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbMat.StoreGuid
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBarCodeRptwithTax
CREATE VIEW vwBarCodeRptwithTax AS SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , ROUND(tbMat.SellPrice+(tbMat.SellPrice*(tbMat.FeePercent*0.01)),2) as SellPrice, CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END as CurrentQty, tbMat.BarCode , 0 as Qty FROM tbMat LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRptwithTax' in the database.

-- ERROR IN: vwUserBills
CREATE VIEW vwUserBills AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , CAST(tbBillheader.totalnet as FLOAT) as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 1 OR BillType = 2) UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , 0 as AmountIn , tbBillheader.totalnet as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 0 OR BillType = 3) UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype ,tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 0 UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated ,0 as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 1 UNION ALL SELECT guid, 0 as number , 'صيانة' as billtype, 'نقدي' as paytype , tbMaintenance.MainDate as BillDate ,tbMaintenance.MainDateD as BillDated ,tbMaintenance.Payment as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbMaintenance WHERE tbMaintenance.MainState = 'جاهزة' UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 2 THEN 'تحويل' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 2
-- MSG: There is already an object named 'vwUserBills' in the database.

-- ERROR IN: vwBillPrint
CREATE VIEW vwBillPrint AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' WHEN 4 THEN 'عرض سعر' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype as paytype ,tbBillheader.BillDate , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount ,tbBillheader.extraval, tbBillheader.discountval, tbMat.[code] as matcode, tbMat.[unite] as matunite , tbMat.name as matname, tbBillBodyNew.qty , tbBillBodyNew.price , tbBillBodyNew.qty * tbBillBodyNew.price as bodytotal,tbBillBodyNew.price/100.00*tbBillBodyNew.TaxValue as totalwithtax, tbBillBodyNew.note as bodynote FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwBillPrint' in the database.

-- ERROR IN: vwBills
CREATE VIEW vwBills AS 
SELECT
    tbBillheader.guid,
    tbBillHeader.number, 
    CASE tbBillHeader.billtype
        WHEN 0 THEN 'مشتريات'
        WHEN 1 THEN 'مبيعات'
        WHEN 2 THEN 'مرتجع مشتريات'
        WHEN 3 THEN 'مرتجع مبيعات'
        WHEN 4 THEN 'عرض سعر'
        WHEN 5 THEN 'إدخال'
        WHEN 6 THEN 'إخراج'
    END AS billtype, 
    --إضافة شرط الـ QR Code
   
    tbBillheader.BillDate,
    tbBillheader.BillDated, 
    tbAccount.code || '-' || tbAccount.name AS account,
    tbaccount.Mobile, 
    tbAccount.Email, 
    tbBillHeader.Paytype AS paytype, 
    tbBillheader.[note], 
    tbBillheader.[total], 
    tbBillheader.totalnet,
    COALESCE((SELECT SUM(SellCost) FROM vwBillsProfitsRawSell
              WHERE Number = tbBillHeader.number
              AND(tbBillHeader.billtype = 1 OR tbBillHeader.billtype = 3)), 0.0) AS SellCost,
    CAST(tbBillheader.extra AS FLOAT) AS Extra,
    tbBillheader.discount, 
    tbBillheader.extraval, 
    tbBillheader.discountval,
 CASE
        WHEN tbBillHeader.billtype IN(1, 3) THEN tbBillHeader.qr_code
        ELSE '0'
    END AS qr_code
FROM tbBillHeader
JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid
WHERE tbBillHeader.billtype<> 4
-- MSG: There is already an object named 'vwBills' in the database.

-- ERROR IN: vwPay1
CREATE VIEW vwPay1 AS SELECT tbBillHeader.guid, tbBillHeader.accountguid, tbBillHeader.number, tbBillHeader.billdate ,tbBillHeader.billdated , tbBillHeader.billtype as billtype, tbaccount.code || '-' || tbaccount.name as account, CASE tbBillHeader.billtype WHEN 0 THEN totalnet WHEN 1 THEN 0 END as amountin, CASE tbBillHeader.billtype WHEN 0 THEN 0 WHEN 1 THEN totalnet END as amountout ,tbBillHeader.note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid = tbaccount.guid WHERE tbBillHeader.paytype = 'نقدي' AND tbBillHeader.billtype = 0 ORDER by number
-- MSG: There is already an object named 'vwPay1' in the database.

-- ERROR IN: vwAccountPayments
CREATE VIEW vwAccountPayments AS SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype = 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.00 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=3) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.0 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=0 OR tbBillheader.billtype=3) UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbpay.amount AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=1 UNION ALL SELECT vwPay1.guid,vwPay1.number,'سداد فاتورة مشتريات' AS billtype,'نقدي' AS paytype,vwPay1.billdate,vwPay1.billdated,vwPay1.accountguid,tbAccount.name,tbAccount.AccType,vwPay1.amountout AS amountin,vwPay1.amountin AS amountout,vwPay1.note AS note FROM vwPay1 JOIN tbAccount ON vwPay1.accountguid=tbaccount.guid WHERE paytype='نقدي' UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,tbpay.amount AS amountin,0.0 AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=0 UNION ALL SELECT tbMaintenance.GUID,tbMaintenance.OrderNo AS number,'صيانة' AS billtype,'نقدي' AS paytype,tbMaintenance.MainDate AS paydate,tbMaintenance.MainDateD AS paydated,tbMaintenance.accountguid,tbaccount.Name AS account,tbAccount.AccType,0.0 AS amountin,tbMaintenance.Cost AS amountout,tbMaintenance.Note FROM tbMaintenance JOIN tbAccount ON tbAccount.Guid=tbMaintenance.AccountGuid WHERE tbMaintenance.MainState='جاهزة' UNION ALL SELECT tbaccount.guid,tbaccount.Code AS number,'رصيد إفتتاحي' AS billtype,'نقدي' AS paytype,tbAccount.CashDate AS paydate,tbAccount.CashDateD AS paydated,tbaccount.guid AS accountguid,tbAccount.name,tbAccount.AccType,tbAccount.amountin,tbAccount.amountout,tbAccount.note FROM tbaccount WHERE StartCash=1
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwDailySells
CREATE VIEW vwDailySells AS 
SELECT guid , billdated, mat, SUM(Qty) As Qty , CAST(SUM(TotalSellPrice) as float) as TotalSellPrice ,   CAST(SUM(TotalProfitsOut) as float) as TotalProfits  FROM vwDailySellsRaw
GROUP BY guid , billdated , mat
-- MSG: There is already an object named 'vwDailySells' in the database.

-- ERROR IN: vwBarCodeRpt
CREATE VIEW vwBarCodeRpt AS 
SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , tbMat.SellPrice , CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END  as CurrentQty,  tbMat.BarCode , 0 as Qty FROM tbMat
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRpt' in the database.

-- ERROR IN: vwBillProfitsRAW
CREATE VIEW vwBillProfitsRAW AS 
SELECT Guid as Guid , number, billtype, BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name ,0 as SellCost,   vwBillsProfitsRawBuy.Amount / vwBillsProfitsRawBuy.Qty  as BuyCost , 0 as TotalSellQty , vwBillsProfitsRawBuy.Qty  as TotalBuyQty  , 0 as TotalSell ,  vwBillsProfitsRawBuy.Amount  as TotalBuy  ,  0 as TotalSellCost, SellCost as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell,  0 as  NetBuy , Percentt  as BuyPrecent , 0 as SellPrecent FROM vwBillsProfitsRawBuy 
UNION ALL
SELECT Guid as Guid ,  number,   billtype,BillDate as BilLDate, BillDateD as BillDateD,  matguid as MatGuid, code, name , vwBillsProfitsRawSell.Amount  /  vwBillsProfitsRawSell.Qty  as SellCost , 0 as BuyCost ,  vwBillsProfitsRawSell.Qty  as TotalSellQty , 0 as TotalBuyQty , vwBillsProfitsRawSell.Amount  as TotalSell  , 0 as TotalBuy,  SellCost as TotalSellCost, 0 as TotalBuyCost  ,  ExCost  as ExCost , 0 as NetSell , 0 as NetBuy ,   0 as BuyPrecent ,  Percentt  as SellPrecent FROM vwBillsProfitsRawSell
-- MSG: There is already an object named 'vwBillProfitsRAW' in the database.

-- ERROR IN: vwBillProfitsBills
CREATE VIEW vwBillProfitsBills AS 
SELECT guid, number, billtype , billdate, billdated , SUM(TotalSellCost) as TotalSellCost, SUM(TotalBuyCost) as TotalBuyCost  , SUM(TotalProfits) as TotalProfits from vwBillProfitsBillsRaw
GROUP BY  guid, number, billtype
-- MSG: Column 'vwBillProfitsBillsRaw.billdate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillProfitsBillsRaw
CREATE VIEW vwBillProfitsBillsRaw AS 
SELECT    vwBillProfitsRAW.guid ,vwBillProfitsRAW.Number, vwBillProfitsRAW.billType,  billdate , billdated , matguid , tbMat.code, tbMat.name ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost ,  TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) as  TotalBuyCost ,    TotalSellCost -  (TotalSellQty * (SELECT  vwBillProfits.TotalBuyCost  FROM vwBillProfits WHERE tbMat.Guid = matguid  )   / (SELECT  vwBillProfits.TotalSellQty FROM vwBillProfits WHERE tbMat.Guid = matguid  ) )  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = matguid   WHERE billtype ='مبيعات'
GROUP BY vwBillProfitsRAW.guid  ,vwBillProfitsRAW.Number  ,vwBillProfitsRAW.billType, matguid
-- MSG: Column 'vwBillProfitsRAW.BillDate' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatEndDateRaw
CREATE VIEW vwMatEndDateRaw AS 
SELECT tbMat.guid,tbBillHeader.guid as billguid, tbMat.code || '-' || tbMat.Name as mat, SUM(tbBillBody.Qty) as qty , tbBillBody.EndDate FROM tbBillHeader JOIN tbBillBody 
ON tbBillHeader.guid = tbBillBody.ParentGuid 
JOIN tbMat ON tbBillBody.matguid = tbMat.guid 
JOIN vwMatQty ON tbMat.guid = vwMatQty.guid
WHERE (tbBillheader.billtype = 0 OR tbBillheader.billtype = 3) AND vwMatQty.Qty > 0
AND tbBillBody.endDate > ('1913-01-02 00:00:00')
GROUP BY tbMat.guid, tbmat.code, tbBillHeader.guid, tbmat.name, tbBillBody.EndDate
-- MSG: Invalid column name 'endDate'.
Invalid column name 'EndDate'.
Invalid column name 'EndDate'.

-- ERROR IN: vwMatEndDate
CREATE VIEW vwMatEndDate AS 
SELECT Guid,billguid, Mat,SUM(Qty) as Qty ,vwMatEndDateRaw.endDate, Round(julianday(enddate) - julianday('now')) as days, '' as Status FROM vwMatEndDateRaw
GROUP BY guid, Mat,Qty , vwMatEndDateRaw.EndDate,Days 
ORDER BY  guid, billguid, enddate ASC
-- MSG: The round function requires 2 to 3 arguments.

-- ERROR IN: vwAccountsBalance
CREATE VIEW vwAccountsBalance AS 
SELECT guid ,name, acctype , billdated , CAST(SUM(Payin) as FLOAT) as PayIn ,  CAST(SUM(payOut) as FLOAT) as payout, CAST(CAST(SUM(Payin) AS FLOAT) - CAST(SUM(PayOut) as FLOAT) as FLOAT) as balance FROM vwAccountsBalanceRaw
GROUP BY guid,  acctype , name
-- MSG: Column 'vwAccountsBalanceRaw.BillDateD' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwPay
CREATE VIEW vwPay AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate ,tbpay.paydated ,  CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code || '-' || tbaccount.name as account, CASE tbPay.paytype WHEN 0 THEN amount WHEN 1 THEN 0 END as amountin, CASE tbPay.paytype WHEN 0 THEN 0 WHEN 1 THEN amount END as amountout ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE tbpay.PayType = 1 OR tbPay.PayType = 0
ORDER by paydate, number
-- MSG: There is already an object named 'vwPay' in the database.

-- ERROR IN: vwPayPrint
CREATE VIEW vwPayPrint AS 
SELECT tbpay.guid, tbpay.accountguid, tbpay.number, tbpay.paydate , CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as paytype, tbaccount.code , tbaccount.name as account, amount ,tbpay.notes FROM tbPay JOIN tbAccount ON tbPay.accountguid = tbaccount.guid
WHERE paytype = 0 OR PayType = 1
-- MSG: There is already an object named 'vwPayPrint' in the database.

-- ERROR IN: vwBillsDelay
CREATE VIEW vwBillsDelay AS 
SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillheader.BillDate  ,tbBillheader.BillDated  , tbAccount.code|| '-' ||  tbAccount.name  as account,tbaccount.Mobile , tbAccount.Email ,    tbBillHeader.Paytype  as paytype  , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra 
, tbBillheader.discount FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid  WHERE IsDelay = 1
ORDER BY tbBillheader.NUMBER , billdate
-- MSG: There is already an object named 'vwBillsDelay' in the database.

-- ERROR IN: vwService
CREATE VIEW vwService AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwService' in the database.

-- ERROR IN: vwNotify
CREATE VIEW vwNotify AS 
SELECT tbService.Guid , tbService.Number , tbService.ServiceDate ,tbService.ServiceDateD , tbService.AgentGuid , tbAccount.Name as Agent, tbService.ServiceType, tbService.Description , tbService.EndDate , tbService.EndDateD , tbService.NotifyBefore , tbService.State FROM tbService JOIN tbAccount ON tbService.AgentGuid = tbAccount.Guid
-- MSG: There is already an object named 'vwNotify' in the database.

-- ERROR IN: vwCash
CREATE VIEW vwCash AS 
SELECT  guid , billtype, billdated , SUM(amountin) as amountin, SUM(amountout) as amountout    FROM vwcashRaw
-- MSG: Column 'vwcashRaw.guid' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwMatInCash
CREATE VIEW vwMatInCash AS 
SELECT tbMat.Guid,tbMat.GroupName,tbMat.code,tbMat.name,tbMat.BuyPrice,tbMat.SellPrice, tbMat.DiscountVal ,tbMat.DiscountPercent ,   tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent,tbMat.Barcode,tbMat.MinQty,tbMat.MinPrice,tbMat.CurrentQty, tbMat.ShowInCash , tbPicture.Pic FROM tbMat JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid    
WHERE ShowInCash = 1
-- MSG: There is already an object named 'vwMatInCash' in the database.

-- ERROR IN: vwMat
CREATE VIEW vwMat AS  
SELECT tbMat.Guid , tbMat.GroupName , tbMat.Code , tbMat.Name ,tbMat.BuyPrice , tbMat.SellPrice ,tbMat.DiscountVal ,tbMat.DiscountPercent , tbMat.ActivateOffer ,tbMat.FromDate , tbMat.FromDateD ,  tbMat.ToDate , tbMat.ToDateD ,  tbMat.FeePercent , tbMat.Barcode , tbMat.MinQty , tbMat.MinPrice , CASE WHEN vwMatQty.qty IS NULL THEN 0 ELSE  vwMatQty.qty END as CurrentQty , tbMat.EndDate , tbMat.ShowInCash FROM tbMat 
LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwMat' in the database.

-- ERROR IN: vwMaintenaceBody
CREATE VIEW vwMaintenaceBody AS 
SELECT tbMaintenaceBody.guid, tbMaintenaceBody.matguid, tbMaintenaceBody.parentguid, tbMaintenaceBody.number, tbmat.code || '-' || tbMat.name as mat, tbMaintenaceBody.[qty] , tbMaintenaceBody.[price] , (tbMaintenaceBody.[qty] * tbMaintenaceBody.[price]) as total , tbMaintenaceBody.note   
FROM tbMaintenaceBody JOIN tbMaintenance ON tbMaintenaceBody.parentguid = tbMaintenance.guid 
JOIN tbmat on tbMaintenaceBody.matguid = tbMat.guid ORDER BY tbMaintenaceBody.number
-- MSG: There is already an object named 'vwMaintenaceBody' in the database.

-- ERROR IN: vwAccoutnSelect
CREATE VIEW vwAccoutnSelect AS 
SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note,  CAST( CASE WHEN (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) IS NULL THEN 0 ELSE (SELECT  CAST (balance as FLOAT) as balance FROM vwAccountsBalance WHERE guid = tbAccount.Guid ) END as FLOAT) as balance FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelect' in the database.

-- ERROR IN: vwAccountsBalanceRaw
CREATE VIEW vwAccountsBalanceRaw AS 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbBillHeader.BillDateD, 0 as payin,  CAST(tbBillHeader.totalnet as FLOAT) as payout FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2) 
UNION ALL 
SELECT tbAccount.guid, tbaccount.name,  tbAccount.AccType , tbBillHeader.BillDateD, CAST(tbBillHeader.totalnet as FLOAT) as payin, 0 as payout  FROM tbBillHeader JOIN tbAccount
ON tbBillHeader.accountguid = tbaccount.guid 
WHERE paytype = 'آجل' AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3) 
UNION ALL 
SELECT tbAccount.guid,tbaccount.name,  tbAccount.AccType , tbPay.PayDateD, CAST(tbpay.amount  as FLOAT) as payin,  0 as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 0
UNION ALL 
SELECT tbAccount.guid,tbaccount.name, tbAccount.AccType , tbPay.PayDateD, 0 as payin, CAST(tbpay.amount as FLOAT) as payout FROM tbPay JOIN tbAccount
ON tbpay.accountguid = tbaccount.guid 
WHERE paytype = 1
UNION ALL 
SELECT tbAccount.guid,tbaccount.name ,  tbAccount.AccType ,  tbMaintenance.MainDateD as paydated,   0 as amountin,  CAST(tbMaintenance.Remain as FLOAT) as amountout  FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL 
SELECT tbaccount.guid ,  tbaccount.name ,  tbAccount.AccType ,tbAccount.CashDateD as paydated,  tbAccount.amountin  ,  tbAccount.amountout    FROM tbaccount WHERE StartCash = 1
-- MSG: There is already an object named 'vwAccountsBalanceRaw' in the database.

-- ERROR IN: vwMaintenance
CREATE VIEW vwMaintenance AS 
SELECT tbMaintenance.GUID  , tbMaintenance.OrderNo ,  tbMaintenance.Model , tbMaintenance.accountguid , tbAccount.Code || '-' || tbaccount.Name as account , tbAccount.Mobile ,   tbMaintenance.Operator , tbMaintenance.MainDate  , tbMaintenance.MainDateD ,tbMaintenance.MainEndDate  , tbMaintenance.MainEndDateD ,      tbMaintenance.Cost,  tbMaintenance.PcCost,   tbMaintenance.Payment , tbMaintenance.Remain,  tbMaintenance.Note ,   tbMaintenance.MainState  , tbMaintenance.UserGuid FROM tbMaintenance
JOIN tbAccount ON tbAccount.Guid =  tbMaintenance.AccountGuid
-- MSG: There is already an object named 'vwMaintenance' in the database.

-- ERROR IN: vwMatQtyStore
CREATE VIEW vwMatQtyStore AS 
SELECT  guid, storeGuid, mat, SUM(StartQty) as StartQty, SUM(StartQtyPrice)as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice ,  SUM(QtyOut)  as qtyout ,  SUM(QtyOutPrice) as QtyOutPrice,    SUM(StartQty + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRawStore
GROUP BY  guid, storeGuid, mat
-- MSG: There is already an object named 'vwMatQtyStore' in the database.

-- ERROR IN: vwMatQty
CREATE VIEW vwMatQty AS 
SELECT  guid, groupname, mat, SUM(StartQty) as StartQty , SUM(StartQtyPrice) as StartQtyPrice,  SUM(QtyIn) as qtyin, SUM(QtyInPrice) as QtyInPrice,  SUM(QtyOut)  as qtyout , SUM(QtyOutPrice) as QtyOutPrice,  SUM(StartQty  + QtyIn) - SUM(QtyOut) as qty  FROM vwMatQtyRaw
GROUP BY  guid, groupname, mat
-- MSG: There is already an object named 'vwMatQty' in the database.

-- ERROR IN: vwCashRAW
CREATE VIEW vwCashRAW AS 
SELECT tbBillHeader.guid,  CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] ,   0 as amountin,tbBillheader.[totalnet] as amountout   FROM tbBillHeader
WHERE paytype <> 'آجل' AND isDelay = 0 AND (tbBillheader.billtype = 0  OR tbBillheader.billtype = 3)  
UNION ALL
SELECT tbBillHeader.guid, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype,
tbBillHeader.[billdated] , tbBillheader.[totalnet] as amountin,0 as amountout  FROM tbBillHeader
WHERE paytype <> 'آجل'  AND isDelay = 0 AND (tbBillheader.billtype = 1  OR tbBillheader.billtype = 2)
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  0 as amountin, tbpay.amount as amountout   FROM tbPay 
WHERE paytype = 1  
UNION ALL
SELECT tbpay.guid , CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END as paytype, tbPay.Paydated,  tbpay.amount as amountin,  0 as amountout  FROM tbPay 
WHERE paytype = 0
UNION ALL
SELECT tbMaintenance.Guid, 'صيانة' as paytype , tbMaintenance.MainDated as Paydated ,tbMaintenance.Payment as amountin , 0 as amountout   FROM tbMaintenance WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
UNION ALL
SELECT tbaccount.guid , ('رصيد إفتتاحي' || '-' || tbaccount.name) as paytype, tbAccount.CashDateD as paydated,   tbAccount.amountin  ,  tbAccount.amountout   FROM tbaccount WHERE StartCash = 1
UNION ALL 
SELECT tbmat.guid , ('رصيد إبتدائي') as paytype, tbMat.StartDateD as paydated,    0 as  amountin ,    SUM(tbMat.StartQty * tbMat.BuyPrice)  as amountout   FROM tbMat  WHERE tbMat.IsStartQty = 1  GROUP BY paytype
-- MSG: Invalid column name 'paytype'.

-- ERROR IN: vwBillProfits
CREATE VIEW "vwBillProfits" AS SELECT vwBillProfitsRAW.guid , billdate , billdated , matguid , tbMat.code, tbMat.name , tbMat.GroupName ,    SUM(TotalSellQty) as TotalSellQty, SUM(TotalBuyQty) as TotalBuyQty, SUM(TotalSellCost) as TotalSellCost , CASE WHEN (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty)  ELSE (SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) END as TotalBuyCost ,  CASE WHEN (SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty)) IS NULL THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) WHEN 0 THEN SUM(TotalSellCost)  - SUM(tbMat.BuyPrice * vwBillProfitsRAW.TotalSellQty) ELSE SUM(TotalSellCost)  -  SUM(TotalBuyCost) / SUM(TotalBuyQty) * SUM(TotalSellQty) END  as TotalProfits  FROM vwBillProfitsRAW
JOIN tbMat ON tbMat.Guid = vwBillProfitsRAW.matGuid  
GROUP BY  DATE(billdate) , billdated , matguid , tbMat.code, tbMat.name
-- MSG: An expression of non-boolean type specified in a context where a condition is expected, near 'THEN'.

-- ERROR IN: vwAccoutnSelectNew
CREATE VIEW vwAccoutnSelectNew AS SELECT tbAccount.Guid,tbAccount.Code, tbAccount.Name, tbAccount.Email , tbAccount.Mobile, tbAccount.AccType, tbAccount.address, tbAccount.Note, tbAccount.StartCash AS balance  FROM tbAccount
-- MSG: There is already an object named 'vwAccoutnSelectNew' in the database.

-- ERROR IN: vwBillBody
CREATE VIEW vwBillBody AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeader ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBody' in the database.

-- ERROR IN: vwProductSalesInSession
CREATE VIEW vwProductSalesInSession AS SELECT b.matguid AS ProductID, m.name AS ProductName, b.qty AS Quantity, b.price AS UnitPrice, (b.qty * b.price) AS TotalPrice, r.uid AS SessionID, r.user AS UserName, r.invoice_num AS InvoiceNumber, r.total AS InvoiceTotal FROM tbBillBodyNew b INNER JOIN cash_drawer_report_new r ON b.parentguid = r.parentGuid INNER JOIN tbMat m ON b.matguid = m.guid
-- MSG: There is already an object named 'vwProductSalesInSession' in the database.

-- ERROR IN: vwBillsFee
CREATE VIEW vwBillsFee AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valin , CAST(0 as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 1 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 2 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , 0 as valin , CAST ((tbBillheader.totalnet-tbBillheader.total) as float) as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 0 UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbBillheader.BillDate ,tbBillheader.BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , tbBillHeader.Paytype as paytype , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , CAST(tbBillheader.extra AS FLOAT) as Extra , tbBillheader.discount , tbBillheader.extraval , tbBillheader.discountval , (CAST ((tbBillheader.totalnet-tbBillheader.total) as float) * -1 ) as valin , 0 as valout FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE billtype = 3 UNION ALL SELECT tbpay.guid,tbpay.number, 'سند صرف' as billtype, tbpay.paydate as BillDate ,tbpay.paydated as BillDated , tbAccount.code|| '-' || tbAccount.name as account,tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbpay.notes as note , tbpay.[amount] as total, tbpay.amount as totalnet, 0 as Extra , 0 as discount , 0 as extraval , 0 as discountval , 0 as valin , CAST(tbpay.amount AS Float) as valout FROM tbpay JOIN tbAccount ON tbpay.accountguid = tbAccount.guid WHERE tbaccount.Code = 3 UNION ALL SELECT tbMaintenance.Guid, tbMaintenance.OrderNo as number, 'صيانة' as billtype ,tbMaintenance.MainDate as BillDate, tbMaintenance.MainDated as BillDateD , tbaccount.code || '-' || tbAccount.name as account, tbaccount.Mobile , tbAccount.TaxNumber , 'نقدي' as paytype , tbMaintenance.Note , tbMaintenance.Cost as total, tbMaintenance.Cost + tbMaintenance.ExtraVal as Totalnet , 0 as Extra , 0 as discount , tbMaintenance.ExtraVal as extraval , 0 as discountval , tbMaintenance.ExtraVal as valin , CAST(0 as FLOAT) as valout FROM tbMaintenance JOIN tbAccount ON tbMaintenance.accountguid = tbAccount.guid WHERE (tbMaintenance.MainState = 'تم الإصلاح' OR tbMaintenance.MainState = 'تم التسليم' )
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwDailySellsRAW
CREATE VIEW vwDailySellsRAW AS SELECT tbMat.guid, tbBillHeader.BillDated, tbMat.code || '-' || tbMat.name as mat, SUM(tbBillBodyNew.qty) as Qty,SUM(CAST((tbBillBodyNew.Qty * tbBillBodyNew.Price) * (tbBillHeader.TotalNet / NULLIF(tbBillHeader.Total, 0)) AS float)) as TotalSellPrice,SUM(CAST((tbBillBodyNew.Qty * tbBillBodyNew.Price) * (tbBillHeader.TotalNet / NULLIF(tbBillHeader.Total, 0)) - (tbBillBodyNew.Qty * tbMat.BuyPrice) AS float)) as TotalProfitsOut FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 AND isDelay = 0 GROUP BY tbBillHeader.BillDated, tbMat.guid, tbMat.code, tbMat.[name],tbBillHeader.TotalNet,tbBillHeader.Total
-- MSG: Operand data type nvarchar(max) is invalid for divide operator.

-- ERROR IN: vwMatSellsPic
CREATE VIEW vwMatSellsPic AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype ,tbBillheader.BillDate , tbBillheader.BillDated , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount , tbMat.[GroupName], tbMat.[code] as matcode , tbMat.name as matname, tbBillBodyNew.qty , tbBillbodyNew.price , tbBillBodyNew.qty * tbBillbodyNew.price as bodytotal, tbBillBodyNew.note as bodynote , tbPicture.Pic FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid JOIN tbPicture ON tbMat.Guid = tbPicture.Parentguid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwMatSellsPic' in the database.

-- ERROR IN: vwBillBodyNew
CREATE VIEW vwBillBodyNew AS SELECT tbBillBodyNew.guid, tbBillBodyNew.matguid, tbBillBodyNew.parentguid, tbBillBodyNew.number, tbMat.name as mat, Round(tbBillBodyNew.[qty],2) as qty , tbBillBodyNew.[price] ,tbBillBodyNew.TaxValue, (tbBillBodyNew.[qty] * (tbBillBodyNew.[price] - tbBillBodyNew.[disVal])) as total , tbBillBodyNew.note , tbBillBodyNew.disVal FROM tbBillBodyNew JOIN tbBillHeaderNew ON tbBillBodyNew.parentguid = tbBillHeaderNew.guid JOIN tbmat on tbBillBodyNew.matguid = tbMat.guid ORDER BY tbBillBodyNew.number
-- MSG: There is already an object named 'vwBillBodyNew' in the database.

-- ERROR IN: vwMatQtyRaw
CREATE VIEW vwMatQtyRaw AS SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice , 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, 0 as startQty , 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbBillBodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name] UNION ALL SELECT tbMat.guid, tbmat.groupname, tbMat.code || '-' || tbMat.name as mat, tbmat.startQty, SUM(tbmat.StartQtyPrice) as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat WHERE tbMat.IsStartQty = 1 GROUP BY tbMat.guid,tbmat.groupname,tbMat.code, tbMat.[name]
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBillsProfitsRawSell
CREATE VIEW vwBillsProfitsRawSell as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , CASE tbBillHeader.billtype WHEN 1 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) WHEN 3 THEN(tbMat.BuyPrice * tbBillBodyNew.qty) END as SellCost, (100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwBillsProfitsRawBuy
CREATE VIEW vwBillsProfitsRawBuy as SELECT tbBillHeader.Guid , tbBillHeader.Number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END as billtype, tbBillHeader.Paytype as paytype ,tbBillheader.BillDate,tbBillheader.BillDateD ,tbMat.Guid as MatGuid, tbMat.Code , tbMat.Name, tbBillBodyNew.Qty , tbBillBodyNew.Qty* tbBillBodyNew.Price as amount , tbBillBodyNew.Qty* tbBillBodyNew.Price as SellCost ,(100 * (tbBillHeader.Total - tbBillHeader.TotalNet) / tbBillHeader.Total) as Percentt , (tbBillHeader.Total - tbBillHeader.TotalNet) as ExCost FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbMat.Guid = tbBillBodyNew.MatGuid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3
-- MSG: The data types nvarchar(max) and nvarchar(max) are incompatible in the subtract operator.

-- ERROR IN: vwMatQtyRawStore
CREATE VIEW vwMatQtyRawStore AS SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty , 0 as StartQtyPrice, 0 as QtyIn, 0 as QtyInPrice, SUM(tbBillBodyNew.qty) as QtyOut , SUM(tbBillBodyNew.qty * tbBillBodyNew.price) as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 1 OR tbBillheader.billtype = 2 OR tbBillheader.billtype = 6 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] ,tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbBillHeader.StoreGuid, 0 as StartQty, 0 as StartQtyPrice, SUM(tbBillBodyNew.qty) as QtyIn , SUM(tbBillBodyNew.qty * tbBillBodyNew.Price ) as QtyInPrice , 0 as QtyOut , 0 as QtyOutPrice FROM tbMat JOIN tbBillBodyNew ON tbMat.guid = tbBillBodyNew.matguid JOIN tbBillHeader ON tbBillheader.guid = tbbillbodyNew.parentguid WHERE tbBillheader.billtype = 0 OR tbBillheader.billtype = 3 OR tbBillheader.billtype = 5 GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbBillHeader.StoreGuid UNION ALL SELECT tbMat.guid, tbMat.code || '-' || tbMat.name as mat, tbMat.StoreGuid, tbMat.StartQty , tbMat.StartQtyPrice as StartQtyPrice, 0 as QtyIn , 0 as QtyInPrice, 0 as QtyOut , 0 as QtyOutPrice FROM tbMat GROUP BY tbMat.guid,tbMat.code, tbMat.[name] , tbMat.StoreGuid
-- MSG: Column 'tbMat.StartQty' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

-- ERROR IN: vwBarCodeRptwithTax
CREATE VIEW vwBarCodeRptwithTax AS SELECT tbMat.Guid , tbMat.GroupName, tbMat.Code , tbMat.Name , tbMat.BuyPrice , ROUND(tbMat.SellPrice+(tbMat.SellPrice*(tbMat.FeePercent*0.01)),2) as SellPrice, CASE WHEN vwMatQty.QtyIn IS NULL THEN 0 ELSE vwMatQty.QtyIn END as QtyIn, CASE WHEN vwMatQty.QtyOut IS NULL THEN 0 ELSE vwMatQty.QtyOut END as QtyOut, CASE WHEN vwMatQty.Qty IS NULL THEN 0 ELSE vwMatQty.Qty END as CurrentQty, tbMat.BarCode , 0 as Qty FROM tbMat LEFT JOIN vwMatQty ON vwMatQty.Guid = tbMat.Guid
-- MSG: There is already an object named 'vwBarCodeRptwithTax' in the database.

-- ERROR IN: vwUserBills
CREATE VIEW vwUserBills AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , CAST(tbBillheader.totalnet as FLOAT) as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 1 OR BillType = 2) UNION ALL SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' END as billtype, paytype , tbBillheader.BillDate ,tbBillheader.BillDated , 0 as AmountIn , tbBillheader.totalnet as AmountOut , accountguid , userguid FROM tbBillHeader JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid WHERE paytype <> 'آجل' AND(billtype = 0 OR BillType = 3) UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype ,tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 0 UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 0 THEN 'قبض' WHEN 1 THEN 'صرف' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated ,0 as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 1 UNION ALL SELECT guid, 0 as number , 'صيانة' as billtype, 'نقدي' as paytype , tbMaintenance.MainDate as BillDate ,tbMaintenance.MainDateD as BillDated ,tbMaintenance.Payment as AmountIn , 0.0 as AmountOut , accountguid , userguid FROM tbMaintenance WHERE tbMaintenance.MainState = 'جاهزة' UNION ALL SELECT guid, number, CASE tbPay.paytype WHEN 2 THEN 'تحويل' END as billtype, 'نقدي' as paytype , tbPay.payDate as BillDate ,tbPay.payDateD as BillDated , tbPay.amount as AmountIn , tbPay.amount as AmountOut , accountguid , userguid FROM tbPay WHERE paytype = 2
-- MSG: There is already an object named 'vwUserBills' in the database.

-- ERROR IN: vwBillPrint
CREATE VIEW vwBillPrint AS SELECT tbBillheader.guid,tbBillHeader.number, CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' WHEN 5 THEN 'إدخال' WHEN 6 THEN 'إخراج' WHEN 4 THEN 'عرض سعر' END as billtype, tbAccount.code as accountcode, tbAccount.name as accountname , tbBillHeader.Paytype as paytype ,tbBillheader.BillDate , tbBillheader.[note] , tbBillheader.[total] , tbBillheader.totalnet , tbBillheader.extra , tbBillheader.discount ,tbBillheader.extraval, tbBillheader.discountval, tbMat.[code] as matcode, tbMat.[unite] as matunite , tbMat.name as matname, tbBillBodyNew.qty , tbBillBodyNew.price , tbBillBodyNew.qty * tbBillBodyNew.price as bodytotal,tbBillBodyNew.price/100.00*tbBillBodyNew.TaxValue as totalwithtax, tbBillBodyNew.note as bodynote FROM tbBillHeader JOIN tbBillBodyNew ON tbBillBodyNew.parentguid = tbBillHeader.guid JOIN tbMat ON tbBillBodyNew.matguid = tbMat.guid JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid ORDER BY tbBillBodyNew.NUMBER , billdate
-- MSG: There is already an object named 'vwBillPrint' in the database.

-- ERROR IN: vwBills
CREATE VIEW vwBills AS 
SELECT
    tbBillheader.guid,
    tbBillHeader.number, 
    CASE tbBillHeader.billtype
        WHEN 0 THEN 'مشتريات'
        WHEN 1 THEN 'مبيعات'
        WHEN 2 THEN 'مرتجع مشتريات'
        WHEN 3 THEN 'مرتجع مبيعات'
        WHEN 4 THEN 'عرض سعر'
        WHEN 5 THEN 'إدخال'
        WHEN 6 THEN 'إخراج'
    END AS billtype, 
    --إضافة شرط الـ QR Code
   
    tbBillheader.BillDate,
    tbBillheader.BillDated, 
    tbAccount.code || '-' || tbAccount.name AS account,
    tbaccount.Mobile, 
    tbAccount.Email, 
    tbBillHeader.Paytype AS paytype, 
    tbBillheader.[note], 
    tbBillheader.[total], 
    tbBillheader.totalnet,
    COALESCE((SELECT SUM(SellCost) FROM vwBillsProfitsRawSell
              WHERE Number = tbBillHeader.number
              AND(tbBillHeader.billtype = 1 OR tbBillHeader.billtype = 3)), 0.0) AS SellCost,
    CAST(tbBillheader.extra AS FLOAT) AS Extra,
    tbBillheader.discount, 
    tbBillheader.extraval, 
    tbBillheader.discountval,
 CASE
        WHEN tbBillHeader.billtype IN(1, 3) THEN tbBillHeader.qr_code
        ELSE '0'
    END AS qr_code
FROM tbBillHeader
JOIN tbAccount ON tbBillheader.accountguid = tbAccount.guid
WHERE tbBillHeader.billtype<> 4
-- MSG: There is already an object named 'vwBills' in the database.

-- ERROR IN: vwPay1
CREATE VIEW vwPay1 AS SELECT tbBillHeader.guid, tbBillHeader.accountguid, tbBillHeader.number, tbBillHeader.billdate ,tbBillHeader.billdated , tbBillHeader.billtype as billtype, tbaccount.code || '-' || tbaccount.name as account, CASE tbBillHeader.billtype WHEN 0 THEN totalnet WHEN 1 THEN 0 END as amountin, CASE tbBillHeader.billtype WHEN 0 THEN 0 WHEN 1 THEN totalnet END as amountout ,tbBillHeader.note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid = tbaccount.guid WHERE tbBillHeader.paytype = 'نقدي' AND tbBillHeader.billtype = 0 ORDER by number
-- MSG: There is already an object named 'vwPay1' in the database.

-- ERROR IN: vwAccountPayments
CREATE VIEW vwAccountPayments AS SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype = 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.00 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=1 OR tbBillheader.billtype=2) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'سداد فاتورة مشتريات' WHEN 1 THEN 'سداد فاتورة مبيعات' WHEN 2 THEN 'سداد فاتورة مرتجع مشتريات' WHEN 3 THEN 'سداد فاتورة مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,0.00 AS amountin,tbBillheader.[totalnet] AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=3) AND tbBillheader.paytype != 'آجل' UNION ALL SELECT tbBillHeader.guid,tbBillHeader.number,CASE tbBillHeader.billtype WHEN 0 THEN 'مشتريات' WHEN 1 THEN 'مبيعات' WHEN 2 THEN 'مرتجع مشتريات' WHEN 3 THEN 'مرتجع مبيعات' END AS billtype,tbBillHeader.Paytype AS paytype,tbBillHeader.[billdate],tbBillHeader.[billdated],tbbillheader.accountguid,tbAccount.name,tbAccount.AccType,tbBillheader.[totalnet] AS amountin,0.0 AS amountout,tbBillHeader.Note FROM tbBillHeader JOIN tbAccount ON tbBillHeader.accountguid=tbAccount.guid WHERE (tbBillheader.billtype=0 OR tbBillheader.billtype=3) UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,0.0 AS amountin,tbpay.amount AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=1 UNION ALL SELECT vwPay1.guid,vwPay1.number,'سداد فاتورة مشتريات' AS billtype,'نقدي' AS paytype,vwPay1.billdate,vwPay1.billdated,vwPay1.accountguid,tbAccount.name,tbAccount.AccType,vwPay1.amountout AS amountin,vwPay1.amountin AS amountout,vwPay1.note AS note FROM vwPay1 JOIN tbAccount ON vwPay1.accountguid=tbaccount.guid WHERE paytype='نقدي' UNION ALL SELECT tbpay.guid,tbpay.number,CASE paytype WHEN 0 THEN 'سند قبض' WHEN 1 THEN 'سند صرف' END AS billtype,'نقدي' AS paytype,tbPay.Paydate,tbPay.Paydated,tbpay.accountguid,tbAccount.name,tbAccount.AccType,tbpay.amount AS amountin,0.0 AS amountout,tbPay.notes AS note FROM tbPay JOIN tbAccount ON tbpay.accountguid=tbaccount.guid WHERE paytype=0 UNION ALL SELECT tbMaintenance.GUID,tbMaintenance.OrderNo AS number,'صيانة' AS billtype,'نقدي' AS paytype,tbMaintenance.MainDate AS paydate,tbMaintenance.MainDateD AS paydated,tbMaintenance.accountguid,tbaccount.Name AS account,tbAccount.AccType,0.0 AS amountin,tbMaintenance.Cost AS amountout,tbMaintenance.Note FROM tbMaintenance JOIN tbAccount ON tbAccount.Guid=tbMaintenance.AccountGuid WHERE tbMaintenance.MainState='جاهزة' UNION ALL SELECT tbaccount.guid,tbaccount.Code AS number,'رصيد إفتتاحي' AS billtype,'نقدي' AS paytype,tbAccount.CashDate AS paydate,tbAccount.CashDateD AS paydated,tbaccount.guid AS accountguid,tbAccount.name,tbAccount.AccType,tbAccount.amountin,tbAccount.amountout,tbAccount.note FROM tbaccount WHERE StartCash=1
-- MSG: Invalid column name 'paytype'.