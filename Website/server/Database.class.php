<?php
class Database {
    // مشخصات بانک اطلاعاتی
    private $username = 'ggsafeir_4a4693c';
    private $password = '274e37e7afed8d9e';
    private $database = 'ggsafeir_app';

    private $mysqli = null;

    function __construct() {
        $this->mysqli = new mysqli(null, $this->username, $this->password, $this->database);

        if ($this->mysqli->connect_errno) {
            throw new Exception($this->mysqli->connect_error, $this->mysqli->connect_errno);
        }
    }

    function __destruct() {
        $this->mysqli->close();
    }

    function getAppData() {
        $this->query('SET NAMES utf8');

        $query = "SELECT * "
               . "FROM `app` "
               . "WHERE `id`=1;";
        $result = $this->query($query);

        $appData = $result->fetch_assoc();
        $appData['is_disabled']    = intval($appData['is_disabled'], 10) == 1;
        $appData['latest_version'] = floatval($appData['latest_version']);

        return $appData;
    }

    function isBanned($username, $machine) {
        $query = "SELECT `id` "
               . "FROM `user_ban` "
               . "WHERE `username`='{$username}' AND `end` >= NOW();";
        $result = $this->query($query);

        if ($result->num_rows != 0)
            return true;

        $query = "SELECT `id` "
               . "FROM `pc_ban` "
               . "WHERE `machine_id`='{$machine}' AND `end` >= NOW();";
        $result = $this->query($query);

        if ($result->num_rows != 0)
            return true;

        return false;
    }

    function addLog($username, $machine) {
        $now = date('Y-m-d H:i:s');
        $ip = $_SERVER['REMOTE_ADDR'];

        $query = "INSERT INTO `log` "
               . "(`username`, `machine_id`, `time`, `ip`) "
               . "VALUES "
               . "('{$username}', '{$machine}', '{$now}', '{$ip}');";
        $result = $this->query($query);
    }

    function getRooms($username) {
        $query = "SELECT * "
               . "FROM `rooms`;";
        $result = $this->query($query);

        $rooms = array();
        while ($room = $result->fetch_assoc()) {
            $room['RoomId'] = intval($room['RoomId'], 10);
            $room['ServerId'] = intval($room['ServerId'], 10);
            $room['EntryLevel'] = intval($room['EntryLevel'], 10);
            $room['MaxUsers'] = intval($room['MaxUsers'], 10);
            $room['IsBanned'] = $this->IsUserBannedFromRoom($username, $room['RoomName']);

            array_push($rooms, $room);
        }

        return $rooms;
    }

    function getBlocks() {
        $query = "SELECT `username` "
               . "FROM `chat_block`;";
        $result = $this->query($query);

        $blocks = array();
        while ($block = $result->fetch_assoc()) {
            array_push($blocks, $block['username']);
        }

        return $blocks;
    }

    function IsUserBannedFromRoom($username, $roomName) {
        $query = "SELECT * "
               . "FROM `room_ban` "
               . "WHERE `username`='{$username}' AND `room_name`='{$roomName}' AND `end` >= NOW();";
        $result = $this->query($query);

        if ($result->num_rows != 0)
            return 1;

        return 0;
    }

    private function query($query) {
        return $this->mysqli->query($query);
    }
}