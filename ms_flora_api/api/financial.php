<?php

header("Content-Type: application/json; charset=UTF-8");

require_once "../config/database.php";

$data = json_decode(
    file_get_contents("php://input"),
    true
);

$businessId = (int)($data["business_id"] ?? 0);

if ($businessId <= 0) {
    http_response_code(400);

    echo json_encode([
        "success" => false,
        "message" => "Business ID required"
    ]);

    exit;
}

$fiscalYear = $data["fiscal_year"] ?? null;
$currency = $data["currency"] ?? "NPR";
$accountingStartDate = $data["accounting_start_date"] ?? null;
$defaultPaymentMethod = $data["default_payment_method"] ?? "Cash";

$cashEnabled = !empty($data["cash_enabled"]) ? 1 : 0;
$bankEnabled = !empty($data["bank_enabled"]) ? 1 : 0;
$qrEnabled = !empty($data["qr_enabled"]) ? 1 : 0;
$creditEnabled = !empty($data["credit_enabled"]) ? 1 : 0;

$sql = "
INSERT INTO financial_settings
(
    business_id,
    fiscal_year,
    currency,
    accounting_start_date,
    default_payment_method,
    cash_enabled,
    bank_enabled,
    qr_enabled,
    credit_enabled
)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)

ON DUPLICATE KEY UPDATE
    fiscal_year = VALUES(fiscal_year),
    currency = VALUES(currency),
    accounting_start_date = VALUES(accounting_start_date),
    default_payment_method = VALUES(default_payment_method),
    cash_enabled = VALUES(cash_enabled),
    bank_enabled = VALUES(bank_enabled),
    qr_enabled = VALUES(qr_enabled),
    credit_enabled = VALUES(credit_enabled)
";

$stmt = $conn->prepare($sql);

if (!$stmt) {
    http_response_code(500);

    echo json_encode([
        "success" => false,
        "message" => "Database query failed: " . $conn->error
    ]);

    exit;
}

$stmt->bind_param(
    "issssiiii",
    $businessId,
    $fiscalYear,
    $currency,
    $accountingStartDate,
    $defaultPaymentMethod,
    $cashEnabled,
    $bankEnabled,
    $qrEnabled,
    $creditEnabled
);

if (!$stmt->execute()) {
    http_response_code(500);

    echo json_encode([
        "success" => false,
        "message" => "Failed to save financial settings: " . $stmt->error
    ]);

    $stmt->close();
    exit;
}

$stmt->close();

echo json_encode([
    "success" => true,
    "message" => "Financial settings saved"
]);