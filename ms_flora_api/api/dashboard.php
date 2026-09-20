<?php

header("Content-Type: application/json; charset=UTF-8");

require_once "../config/database.php";

$businessId = (int)($_GET["business_id"] ?? 0);

if ($businessId <= 0) {

    http_response_code(400);

    echo json_encode([
        "success" => false,
        "message" => "Business ID required"
    ]);

    exit;
}

/*
|--------------------------------------------------------------------------
| BUSINESS INFORMATION
|--------------------------------------------------------------------------
*/

$stmt = $conn->prepare(
    "SELECT
        business_name,
        business_code,
        owner_name
     FROM businesses
     WHERE id = ?"
);

$stmt->bind_param("i", $businessId);

$stmt->execute();

$result = $stmt->get_result();

$business = $result->fetch_assoc();

$stmt->close();


/*
|--------------------------------------------------------------------------
| FARM OVERVIEW
|--------------------------------------------------------------------------
*/

$stmt = $conn->prepare(
    "SELECT
        COUNT(*) AS farm_count,
        COALESCE(SUM(tunnel_count), 0) AS tunnel_count
     FROM farms
     WHERE business_id = ?"
);

$stmt->bind_param("i", $businessId);

$stmt->execute();

$result = $stmt->get_result();

$farm = $result->fetch_assoc();

$stmt->close();


/*
|--------------------------------------------------------------------------
| DASHBOARD RESPONSE
|--------------------------------------------------------------------------
*/

echo json_encode([

    "success" => true,

    "business" => $business,

    "overview" => [

        "farms" =>
            (int)($farm["farm_count"] ?? 0),

        "tunnels" =>
            (int)($farm["tunnel_count"] ?? 0),

        /*
         * These will be connected to the real
         * Bulk, Production, Sales, Expense
         * and Employee tables later.
         */

        "bulks" => 0,

        "today_yield_kg" => 0,

        "today_sales" => 0,

        "today_expenses" => 0,

        "employees" => 0
    ]
]);