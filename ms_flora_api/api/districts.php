<?php

header("Content-Type: application/json; charset=UTF-8");

require_once "../config/database.php";

$provinceId = (int)($_GET["province_id"] ?? 0);

if ($provinceId <= 0) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid province_id"
    ]);
    exit;
}

try {

    $stmt = $conn->prepare("
        SELECT id, name
        FROM districts
        WHERE province_id = ?
        ORDER BY name ASC
    ");

    if (!$stmt) {
        throw new Exception($conn->error);
    }

    $stmt->bind_param("i", $provinceId);
    $stmt->execute();

    $result = $stmt->get_result();

    $data = [];

    while ($row = $result->fetch_assoc()) {
        $data[] = [
            "id" => (int)$row["id"],
            "name" => $row["name"]
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