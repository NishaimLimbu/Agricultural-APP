<?php

header("Content-Type: application/json; charset=UTF-8");

require_once "../config/database.php";

$data = json_decode(
    file_get_contents("php://input"),
    true
);

$mobileNo = trim(
    $data["mobile_no"] ?? ""
);

$password = $data["password"] ?? "";

if ($mobileNo === "" || $password === "") {

    http_response_code(400);

    echo json_encode([
        "success" => false,
        "message" => "Mobile number and password are required"
    ]);

    exit;
}

try {

    // Find user by mobile number

    $stmt = $conn->prepare("
        SELECT
            id,
            username,
            mobile_no,
            email,
            password_hash,
            status
        FROM users
        WHERE mobile_no = ?
        LIMIT 1
    ");

    if (!$stmt) {
        throw new Exception(
            "Login query failed: " . $conn->error
        );
    }

    $stmt->bind_param(
        "s",
        $mobileNo
    );

    $stmt->execute();

    $result = $stmt->get_result();

    if ($result->num_rows === 0) {

        $stmt->close();

        http_response_code(401);

        echo json_encode([
            "success" => false,
            "message" => "Invalid mobile number or password"
        ]);

        exit;
    }

    $user = $result->fetch_assoc();

    $stmt->close();


    // Check account status

    if ($user["status"] !== "active") {

        http_response_code(403);

        echo json_encode([
            "success" => false,
            "message" => "Your account is not active"
        ]);

        exit;
    }


    // Verify password

    if (!password_verify(
        $password,
        $user["password_hash"]
    )) {

        http_response_code(401);

        echo json_encode([
            "success" => false,
            "message" => "Invalid mobile number or password"
        ]);

        exit;
    }


    // Find business connected to this user

    $businessStmt = $conn->prepare("
        SELECT
            business_id,
            role
        FROM business_users
        WHERE user_id = ?
        LIMIT 1
    ");

    if (!$businessStmt) {
        throw new Exception(
            "Business user query failed: " .
            $conn->error
        );
    }

    $userId = (int)$user["id"];

    $businessStmt->bind_param(
        "i",
        $userId
    );

    $businessStmt->execute();

    $businessResult =
        $businessStmt->get_result();

    if ($businessResult->num_rows === 0) {

        $businessStmt->close();

        http_response_code(404);

        echo json_encode([
            "success" => false,
            "message" => "No business is linked to this account"
        ]);

        exit;
    }

    $business =
        $businessResult->fetch_assoc();

    $businessStmt->close();


    // Successful login

    echo json_encode([
        "success" => true,
        "message" => "Login successful",
        "user" => [
            "id" => (int)$user["id"],
            "username" => $user["username"],
            "mobile_no" => $user["mobile_no"],
            "email" => $user["email"],
            "status" => $user["status"]
        ],
        "business" => [
            "business_id" => (int)$business["business_id"],
            "role" => $business["role"]
        ]
    ]);

} catch (Exception $e) {

    http_response_code(500);

    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
}