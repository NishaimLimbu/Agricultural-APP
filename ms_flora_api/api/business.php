<?php

header("Content-Type: application/json; charset=UTF-8");

require_once "../config/database.php";

$data = json_decode(
    file_get_contents("php://input"),
    true
);

$userId = (int)($data["user_id"] ?? 0);

$businessName = trim($data["business_name"] ?? "");
$businessType = trim($data["business_type"] ?? "");
$category = trim($data["category"] ?? "");
$registrationNo = trim($data["registration_no"] ?? "");
$panNo = trim($data["pan_no"] ?? "");
$ownerName = trim($data["owner_name"] ?? "");

if ($userId <= 0 || $businessName === "") {

    http_response_code(400);

    echo json_encode([
        "success" => false,
        "message" => "User ID and business name are required"
    ]);

    exit;
}

try {

    /*
     * Start MySQLi transaction
     */
    $conn->begin_transaction();

    /*
     * Generate business code
     */
    $businessCode = "MSF-" . date("YmdHis");

    /*
     * Insert business
     */
    $stmt = $conn->prepare(
        "INSERT INTO businesses
        (
            business_code,
            business_name,
            business_type,
            category,
            registration_no,
            pan_no,
            owner_name
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)"
    );

    if (!$stmt) {
        throw new Exception($conn->error);
    }

    $stmt->bind_param(
        "sssssss",
        $businessCode,
        $businessName,
        $businessType,
        $category,
        $registrationNo,
        $panNo,
        $ownerName
    );

    if (!$stmt->execute()) {
        throw new Exception($stmt->error);
    }

    $businessId = $conn->insert_id;

    $stmt->close();

    /*
     * Connect user with business as Owner
     */
    $stmt = $conn->prepare(
        "INSERT INTO business_users
        (
            user_id,
            business_id,
            username,
            mobile_no,
            email,
            role
        )
        SELECT
            id,
            ?,
            username,
            mobile_no,
            email,
            'Owner'
        FROM users
        WHERE id = ?"
    );

    if (!$stmt) {
        throw new Exception($conn->error);
    }

    $stmt->bind_param(
        "ii",
        $businessId,
        $userId
    );

    if (!$stmt->execute()) {
        throw new Exception($stmt->error);
    }

    /*
     * Check that user actually existed
     */
    if ($stmt->affected_rows === 0) {
        throw new Exception("User not found");
    }

    $stmt->close();

    /*
     * Commit transaction
     */
    $conn->commit();

    echo json_encode([
        "success" => true,
        "message" => "Business created successfully",
        "business_id" => (int)$businessId
    ]);

} catch (Exception $e) {

    /*
     * Rollback if something failed
     */
    $conn->rollback();

    http_response_code(500);

    echo json_encode([
        "success" => false,
        "message" => "Business creation failed: " . $e->getMessage()
    ]);
}