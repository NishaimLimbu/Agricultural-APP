<?php

header("Content-Type: application/json; charset=UTF-8");

require_once "../config/database.php";

try {

    $sql = "
        SELECT id, name
        FROM provinces
        ORDER BY name ASC
    ";

    $result = $conn->query($sql);

    if (!$result) {
        throw new Exception($conn->error);
    }

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

} catch (Exception $e) {

    http_response_code(500);

    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
}