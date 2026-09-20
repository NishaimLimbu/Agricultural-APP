<?php

header("Content-Type: application/json; charset=UTF-8");

require_once "../config/database.php";

$districtId = (int)($_GET["district_id"] ?? 0);

if ($districtId <= 0) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid district_id"
    ]);
    exit;
}

try {

    $stmt = $conn->prepare("
        SELECT
            id,
            name,
            type,
            ward_count
        FROM local_governments
        WHERE district_id = ?
        ORDER BY name ASC
    ");

    if (!$stmt) {
        throw new Exception($conn->error);
    }

    $stmt->bind_param("i", $districtId);
    $stmt->execute();

    $result = $stmt->get_result();

    $data = [];

    while ($row = $result->fetch_assoc()) {
        $data[] = [
            "id" => (int)$row["id"],
            "name" => $row["name"],
            "type" => $row["type"],
            "ward_count" => (int)$row["ward_count"]
        ];
    }

    echo json_encode([
        "success" => true,
        "data" => $data
    ]);

    $stmt->close();

} catch (Exception $e) {

    http_response_code(500);

    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
}