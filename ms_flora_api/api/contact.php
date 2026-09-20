<?php

header("Content-Type: application/json; charset=UTF-8");

require_once "../config/database.php";

$data = json_decode(
    file_get_contents("php://input"),
    true
);

$businessId =
    (int)($data["business_id"] ?? 0);

$provinceId =
    (int)($data["province_id"] ?? 0);

$districtId =
    (int)($data["district_id"] ?? 0);

$localGovernmentId =
    (int)($data["local_government_id"] ?? 0);

$wardId =
    (int)($data["ward_id"] ?? 0);

$tole =
    trim($data["tole"] ?? "");

$fullAddress =
    trim($data["full_address"] ?? "");

$mobileNo =
    trim($data["mobile_no"] ?? "");

$whatsappNo =
    trim($data["whatsapp_no"] ?? "");

$email =
    trim($data["email"] ?? "");

$website =
    trim($data["website"] ?? "");


if ($businessId <= 0) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid business ID"
    ]);
    exit;
}

if ($provinceId <= 0) {
    echo json_encode([
        "success" => false,
        "message" => "Please select a province"
    ]);
    exit;
}

if ($districtId <= 0) {
    echo json_encode([
        "success" => false,
        "message" => "Please select a district"
    ]);
    exit;
}

if ($localGovernmentId <= 0) {
    echo json_encode([
        "success" => false,
        "message" => "Please select a local government"
    ]);
    exit;
}

if ($wardId <= 0) {
    echo json_encode([
        "success" => false,
        "message" => "Please select a ward"
    ]);
    exit;
}


try {

    // Check business
    $checkBusiness = $conn->prepare("
        SELECT id
        FROM businesses
        WHERE id = ?
        LIMIT 1
    ");

    $checkBusiness->bind_param(
        "i",
        $businessId
    );

    $checkBusiness->execute();

    $businessResult =
        $checkBusiness->get_result();

    if ($businessResult->num_rows === 0) {

        echo json_encode([
            "success" => false,
            "message" => "Business not found"
        ]);

        exit;
    }

    $checkBusiness->close();


    // Validate address hierarchy
    $checkAddress = $conn->prepare("
        SELECT
            nw.id
        FROM nepal_wards nw
        INNER JOIN local_governments lg
            ON lg.id = nw.local_government_id
        INNER JOIN districts d
            ON d.id = lg.district_id
        INNER JOIN provinces p
            ON p.id = d.province_id
        WHERE
            nw.id = ?
            AND nw.local_government_id = ?
            AND lg.district_id = ?
            AND d.province_id = ?
        LIMIT 1
    ");

    $checkAddress->bind_param(
        "iiii",
        $wardId,
        $localGovernmentId,
        $districtId,
        $provinceId
    );

    $checkAddress->execute();

    $addressResult =
        $checkAddress->get_result();

    if ($addressResult->num_rows === 0) {

        echo json_encode([
            "success" => false,
            "message" => "Invalid address selection"
        ]);

        exit;
    }

    $checkAddress->close();


    // Check whether contact already exists
    $checkContact = $conn->prepare("
        SELECT id
        FROM business_contacts
        WHERE business_id = ?
        LIMIT 1
    ");

    $checkContact->bind_param(
        "i",
        $businessId
    );

    $checkContact->execute();

    $contactResult =
        $checkContact->get_result();

    $exists =
        $contactResult->num_rows > 0;

    $checkContact->close();


    if ($exists) {

        $stmt = $conn->prepare("
            UPDATE business_contacts
            SET
                province_id = ?,
                district_id = ?,
                local_government_id = ?,
                ward_id = ?,
                tole = ?,
                full_address = ?,
                mobile_no = ?,
                whatsapp_no = ?,
                email = ?,
                website = ?,
                updated_at = CURRENT_TIMESTAMP
            WHERE business_id = ?
        ");

        $stmt->bind_param(
            "iiiissssssi",
            $provinceId,
            $districtId,
            $localGovernmentId,
            $wardId,
            $tole,
            $fullAddress,
            $mobileNo,
            $whatsappNo,
            $email,
            $website,
            $businessId
        );

    } else {

        $stmt = $conn->prepare("
            INSERT INTO business_contacts
            (
                business_id,
                province_id,
                district_id,
                local_government_id,
                ward_id,
                tole,
                full_address,
                mobile_no,
                whatsapp_no,
                email,
                website,
                created_at,
                updated_at
            )
            VALUES
            (
                ?,
                ?,
                ?,
                ?,
                ?,
                ?,
                ?,
                ?,
                ?,
                ?,
                ?,
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP
            )
        ");

        $stmt->bind_param(
            "iiiiissssss",
            $businessId,
            $provinceId,
            $districtId,
            $localGovernmentId,
            $wardId,
            $tole,
            $fullAddress,
            $mobileNo,
            $whatsappNo,
            $email,
            $website
        );
    }


    if (!$stmt->execute()) {
        throw new Exception($stmt->error);
    }

    $stmt->close();


    echo json_encode([
        "success" => true,
        "message" => "Address & contact saved successfully"
    ]);

} catch (Exception $e) {

    http_response_code(500);

    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
}