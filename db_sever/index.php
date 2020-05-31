<?php

$url1=$_SERVER['REQUEST_URI'];
    header("Refresh: 2; URL=$url1");

// echo "Hello There World";
$servername = $_ENV["servername_CI"];;
$username = $_ENV["username_CI"];
$password = $_ENV["dbPassword_CI"];;
$dbname = "crowdIt";

// Create connection
$conn = mysqli_connect($servername, $username, $password, $dbname);

// Check connection
if (!$conn) {
  die("Connection failed: " . mysqli_connect_error());
}
// echo  "<br>" ."Connected successfully";

if($_GET['table']==""){

    $result = $conn->query("select * from person");

echo "<br>";
echo "<table border='1'>";
while ($row = mysqli_fetch_assoc($result)) { // Important line !!! Check summary get row on array ..
    echo "<tr>";
    foreach ($row as $field => $value) { // I you want you can right this line like this: foreach($row as $value) {
        echo "<td>" . $value . "</td>"; // I just did not use "htmlspecialchars()" function. 
    }
    echo "</tr>";
}
echo "</table>";

}



$data = json_decode( file_get_contents( 'php://input' ), true );

$id = $data['id'];
$zipcode = $data['zipcode'];
$insert_placeid = $data['placeid'];
$get_placeid = $_GET['placeid'];


// $zipcode = $_GET['zipcode'];

$result = $conn->query("insert into person(id, zipcode, time, placeid )
                      values ($id, $zipcode, CURRENT_TIMESTAMP, \"$insert_placeid\")");


// $get_placeid = $_GET['placeid'];
// $results = $conn->query("select * from person where id=\"$get_placeid\"");
$result = $conn->query("select count(*) from person where placeid=\"$get_placeid\"");


$rows = array();
   while($r = mysqli_fetch_assoc($result)) {
     $rows[] = $r;
   }

 print json_encode($rows);





// echo "<br>";
// echo "<table border='1'>";
// while ($row = mysqli_fetch_assoc($result)) { // Important line !!! Check summary get row on array ..
//     echo "<tr>";
//     foreach ($row as $field => $value) { // I you want you can right this line like this: foreach($row as $value) {
//         echo "<td>" . $value . "</td>"; // I just did not use "htmlspecialchars()" function. 
//     }
//     echo "</tr>";
// }
// echo "</table>";



$conn->close();


?>
