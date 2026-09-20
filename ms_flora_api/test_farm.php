```php
<?php

$url = "http://localhost/ms_flora_api/api/farm.php";

$data = [
    "business_id" => 1,

    "farm_name" => "MS FLORA Test Farm",

    "total_land_area" => 5.00,

    "land_unit" => "Ropani",

    "cultivated_area" => 4.00,

    "open_field_area" => 1.00,

    "tunnel_count" => 14,

    "greenhouse_count" => 0,

    "production_type" => "Mushroom",

    "irrigation_type" => "Manual",

    "land_condition" => "Owner",

    "land_owner_name" => null,

    "lease_agreement_years" => null
];

$ch = curl_init($url);

curl_setopt($ch, CURLOPT_POST, true);

curl_setopt(
    $ch,
    CURLOPT_POSTFIELDS,
    json_encode($data)
);

curl_setopt(
    $ch,
    CURLOPT_HTTPHEADER,
    [
        "Content-Type: application/json"
    ]
);

curl_setopt(
    $ch,
    CURLOPT_RETURNTRANSFER,
    true
);

$response = curl_exec($ch);

if ($response === false) {

    echo "CURL ERROR: ";
    echo curl_error($ch);

} else {

    echo "<pre>";
    echo $response;
    echo "</pre>";
}

curl_close($ch);

?>
```
