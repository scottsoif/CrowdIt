<?php
//  To run server, enter following command in terminal
//      php -S 0.0.0.0:60

$url1 = $_SERVER['REQUEST_URI'];
header("Refresh: 200; URL=$url1");  // refresh table every 200 seconds

$servername = $_ENV["servername_CI"];
$username = $_ENV["username_CI"];
$password = $_ENV["dbPassword_CI"];
$dbname = "crowdIt";

$data = json_decode(file_get_contents('php://input') , true);

// Create connection
$conn = mysqli_connect($servername, $username, $password, $dbname);

// Insert bulk PLACES for testing
// for ($i = 3; $i < 566; $i++){
// $result1 = $conn->query("insert into person(userid, zipcode, time, placeid )
// values (\"G7E50C1L-A37C-4C$i-A2Z0-C239YD21BA11\", 0, CURRENT_TIMESTAMP, \"ChIJ8f13aq5ZwokRHrZ2nx4TP3Y\");");
// }

// Check connection
if (!$conn)
{
    die("Connection failed: " . mysqli_connect_error());
}

if ($_GET['table'] == "1")
{ 
    // Prints Whole DB as Table

  $result = $conn->query("select userid, placeid, time from person order by time desc");
    echo "<br>";
    echo "<table border='1' style=\"float: left;\">";
    while ($row = mysqli_fetch_assoc($result)){
        echo "<tr>";
        foreach ($row as $field => $value){
            if ($counter % 2 == 0)
                echo "<td bgcolor=\"pink\">" . $value . "</td bgcolor=\"yellow\">"; 
            else
                echo "<td bgcolor=\"cyan\">" . $value . "</td bgcolor=\"cyan\">"; 
        }
        $counter++;
        echo "</tr>";
    }
    echo "</table>";


    $result = $conn->query("select * from places");
    echo "<br>";
    echo "<table border='1' style=\"float: right;\">";
    $counter = 0;
    while ($row = mysqli_fetch_assoc($result))
    { 
        echo "<tr>";
        foreach ($row as $field => $value)
        { 
          if ($counter % 2 == 0)
              echo "<td bgcolor=\"yellow\">" . $value . "</td bgcolor=\"yellow\">"; 
          else
              echo "<td bgcolor=\"cyan\">" . $value . "</td bgcolor=\"cyan\">"; 
            
        }
        $counter++;
        echo "</tr>";
    }
    echo "</table>";


}
else if ($data['userid'] != "")
{ // insert current location of device 
    $data = json_decode(file_get_contents('php://input') , true);

    $userid = $data['userid'];
    $zipcode = $data['zipcode'];
    $insert_placeid = $data['placeid'];

    foreach ($insert_placeid as $place)
    {

        $result1 = $conn->query("insert into person(userid, zipcode, time, placeid )
                      values (\"$userid\", $zipcode, CURRENT_TIMESTAMP, \"$place[0]\");");
        $result2 = $conn->query("insert ignore into places(placeid, placename)
                      values(\"$place[0]\", \"$place[1]\");");
    }

}

else if ($_GET['userid'] == "")
{ // Returns # of people in specific location (by place_id)
    $get_placeid = $_GET['placeid'];
    $result = $conn->query("select count(*) from person 
                      where placeid=\"$get_placeid\" and 
                      time >= CURRENT_TIMESTAMP - interval 15000 minute");

    $rows = array();
    while ($r = mysqli_fetch_assoc($result))
    {
        $rows[] = $r;
    }
    print json_encode($rows);
    logger("Num People", "debug.log", json_encode($rows));

}

$conn->close();

function logger($logMsg="logger", $filename="logger", $logData=""){     
    date_default_timezone_set('est');
    $log  = date("D M j Y H:i:s")." | $logMsg : ".print_r($logData,1).PHP_EOL .                  
    "-------------------------".PHP_EOL;
    file_put_contents($filename, $log, FILE_APPEND);                      
}

?>
