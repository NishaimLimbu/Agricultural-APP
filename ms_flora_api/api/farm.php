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


/*
|--------------------------------------------------------------------------
| Farm Information
|--------------------------------------------------------------------------
*/

$farmName = trim(
    $data["farm_name"] ?? ""
);

$totalLandArea = trim(
    $data["total_land_area"] ?? ""
);

$landUnit = trim(
    $data["land_unit"] ?? ""
);

$cultivatedArea =
    $data["cultivated_area"] ?? null;

$openFieldArea =
    $data["open_field_area"] ?? null;

$tunnelCount = (int)(
    $data["tunnel_count"] ?? 0
);

$greenhouseCount = (int)(
    $data["greenhouse_count"] ?? 0
);

$productionType = trim(
    $data["production_type"] ?? ""
);

$irrigationType = trim(
    $data["irrigation_type"] ?? ""
);


/*
|--------------------------------------------------------------------------
| Owner / Lease Information
|--------------------------------------------------------------------------
*/

$landCondition = trim(
    $data["land_condition"] ?? "Owner"
);

$landOwnerName = trim(
    $data["land_owner_name"] ?? ""
);

$leaseAgreementYears =
    $data["lease_agreement_years"] ?? null;


/*
|--------------------------------------------------------------------------
| Basic Validation
|--------------------------------------------------------------------------
*/

if ($farmName === "") {
    http_response_code(400);

    echo json_encode([
        "success" => false,
        "message" => "Farm name is required"
    ]);

    exit;
}


if ($totalLandArea === "") {
    http_response_code(400);

    echo json_encode([
        "success" => false,
        "message" => "Total land area is required"
    ]);

    exit;
}


if (!in_array($landUnit, ["Ropani", "Bigha"])) {
    http_response_code(400);

    echo json_encode([
        "success" => false,
        "message" => "Invalid land unit"
    ]);

    exit;
}


if (!in_array($landCondition, ["Owner", "Lease"])) {
    http_response_code(400);

    echo json_encode([
        "success" => false,
        "message" => "Invalid land condition"
    ]);

    exit;
}


/*
|--------------------------------------------------------------------------
| Owner / Lease Logic
|--------------------------------------------------------------------------
*/

if ($landCondition === "Owner") {

    $landOwnerName = null;
    $leaseAgreementYears = null;

} else {

    if ($landOwnerName === "") {
        http_response_code(400);

        echo json_encode([
            "success" => false,
            "message" => "Land owner name is required"
        ]);

        exit;
    }

    $leaseAgreementYears =
        (int)$leaseAgreementYears;

    if ($leaseAgreementYears <= 0) {
        http_response_code(400);

        echo json_encode([
            "success" => false,
            "message" =>
                "Valid lease agreement years are required"
        ]);

        exit;
    }
}


/*
|--------------------------------------------------------------------------
| Insert Farm
|--------------------------------------------------------------------------
|
| Actual table name: farms
|
*/

$sql = "
INSERT INTO farms
(
    business_id,
    farm_name,
    total_land_area,
    land_unit,
    cultivated_area,
    open_field_area,
    tunnel_count,
    greenhouse_count,
    production_type,
    irrigation_type,
    land_condition,
    land_owner_name,
    lease_agreement_years
)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
";


$stmt = $conn->prepare($sql);

if (!$stmt) {
    http_response_code(500);

    echo json_encode([
        "success" => false,
        "message" =>
            "Database query failed: " .
            $conn->error
    ]);

    exit;
}


/*
|--------------------------------------------------------------------------
| Bind Parameters
|--------------------------------------------------------------------------
*/

$stmt->bind_param(
    "isssssiissssi",
    $businessId,
    $farmName,
    $totalLandArea,
    $landUnit,
    $cultivatedArea,
    $openFieldArea,
    $tunnelCount,
    $greenhouseCount,
    $productionType,
    $irrigationType,
    $landCondition,
    $landOwnerName,
    $leaseAgreementYears
);


/*
|--------------------------------------------------------------------------
| Execute
|--------------------------------------------------------------------------
*/

if (!$stmt->execute()) {
    http_response_code(500);

    echo json_encode([
        "success" => false,
        "message" =>
            "Failed to save farm information: " .
            $stmt->error
    ]);

    $stmt->close();

    exit;
}


$farmId = $conn->insert_id;

$stmt->close();


/*
|--------------------------------------------------------------------------
| Success Response
|--------------------------------------------------------------------------
*/

echo json_encode([
    "success" => true,
    "message" =>
        "Farm information saved successfully",
    "farm_id" => (int)$farmId
]);

?>