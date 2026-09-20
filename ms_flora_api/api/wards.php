<?php

header("Content-Type: application/json; charset=UTF-8");

require_once "../config/database.php";

$localGovernmentId =
    (int)($_GET["local_government_id"] ?? 0);

if ($localGovernmentId <= 0) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid local_government_id"
    ]);
    exit;
}

try {

    $stmt = $conn->prepare("
        SELECT
            id,
            ward_no
        FROM nepal_wards
        WHERE local_government_id = ?
        ORDER BY ward_no ASC
    ");

    if (!$stmt) {
        throw new Exception($conn->error);
    }

    $stmt->bind_param("i", $localGovernmentId);
    $stmt->execute();

    $result = $stmt->get_result();

    $data = [];

    while ($row = $result->fetch_assoc()) {
        $data[] = [
            "id" => (int)$row["id"],
            "ward_no" => (int)$row["ward_no"]
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