DROP TABLE IF EXISTS folio_reporting.invoice_transactions;

-- Create a derived table that joins invoice and invoice_lines fields to transactions for expenditure reports in system currency
--
-- Tables included:
--   folio_finance.transaction
--   folio_invoice.invoices
--   folio_invoice.invoice_lines
--   folio_finance.fund
--   folio_finance.budget
CREATE TABLE folio_reporting.invoice_transactions AS
SELECT
    ft.id AS transaction_id,
    json_extract_path_text(ft.jsonb::json, 'amount') AS transaction_amount,
    json_extract_path_text(ft.jsonb::json, 'currency') AS transaction_currency,
    ft.expenseclassid AS transaction_expense_class_id,
    ft.fiscalyearid AS transaction_fiscal_year_id,
    ft.fromfundid AS transaction_from_fund_id,
    json_extract_path_text(ff.jsonb::json, 'name') AS transaction_from_fund_name,
    json_extract_path_text(ff.jsonb::json, 'code') AS transaction_from_fund_code,
    fb.id AS transaction_from_budget_id,
    json_extract_path_text(fb.jsonb::json, 'name') AS transaction_from_budget_name,
    json_extract_path_text(ft.jsonb::json, 'sourceInvoiceId') AS invoice_id,
    json_extract_path_text(ft.jsonb::json, 'sourceInvoiceLineId') AS invoice_line_id,
    json_extract_path_text(ft.jsonb::json, 'transactionType') AS transaction_type,
    json_extract_path_text(ii.jsonb::json, 'invoiceDate') AS invoice_date,
    json_extract_path_text(ii.jsonb::json, 'paymentDate') AS invoice_payment_date,
    json_extract_path_text(ii.jsonb::json, 'exchangeRate') AS invoice_exchange_rate,
    json_extract_path_text(il.jsonb::json, 'total') AS invoice_line_total,
    json_extract_path_text(ii.jsonb::json, 'currency') AS invoice_currency,
    json_extract_path_text(il.jsonb::json, 'poLineId') AS po_line_id,
    json_extract_path_text(ii.jsonb::json, 'vendorId') AS invoice_vendor_id
FROM
    folio_finance.transaction AS ft
    LEFT JOIN folio_invoice.invoices AS ii ON json_extract_path_text(ft.jsonb::json, 'sourceInvoiceId') = ii.id
    LEFT JOIN folio_invoice.invoice_lines AS il ON json_extract_path_text(ft.jsonb::json, 'sourceInvoiceLineId') = il.id
    LEFT JOIN folio_finance.fund AS ff ON ft.fromfundid = ff.id
    LEFT JOIN folio_finance.budget AS fb ON ft.fromfundid = fb.fundid
WHERE (json_extract_path_text(ft.jsonb::json, 'transactionType') = 'Pending payment'
    OR json_extract_path_text(ft.jsonb::json, 'transactionType') = 'Payment')
AND ft.__current
AND ii.__current
AND il.__current
AND ff.__current
AND fb.__current;

CREATE INDEX ON folio_reporting.invoice_transactions (transaction_id);

CREATE INDEX ON folio_reporting.invoice_transactions (transaction_amount);

CREATE INDEX ON folio_reporting.invoice_transactions (transaction_currency);

CREATE INDEX ON folio_reporting.invoice_transactions (transaction_expense_class_id);

CREATE INDEX ON folio_reporting.invoice_transactions (transaction_fiscal_year_id);

CREATE INDEX ON folio_reporting.invoice_transactions (transaction_from_fund_id);

CREATE INDEX ON folio_reporting.invoice_transactions (transaction_from_fund_name);

CREATE INDEX ON folio_reporting.invoice_transactions (transaction_from_fund_code);

CREATE INDEX ON folio_reporting.invoice_transactions (transaction_from_budget_id);

CREATE INDEX ON folio_reporting.invoice_transactions (transaction_from_budget_name);

CREATE INDEX ON folio_reporting.invoice_transactions (invoice_id);

CREATE INDEX ON folio_reporting.invoice_transactions (invoice_line_id);

CREATE INDEX ON folio_reporting.invoice_transactions (transaction_type);

CREATE INDEX ON folio_reporting.invoice_transactions (invoice_date);

CREATE INDEX ON folio_reporting.invoice_transactions (invoice_payment_date);

CREATE INDEX ON folio_reporting.invoice_transactions (invoice_exchange_rate);

CREATE INDEX ON folio_reporting.invoice_transactions (invoice_line_total);

CREATE INDEX ON folio_reporting.invoice_transactions (invoice_currency);

CREATE INDEX ON folio_reporting.invoice_transactions (po_line_id);

CREATE INDEX ON folio_reporting.invoice_transactions (invoice_vendor_id);

